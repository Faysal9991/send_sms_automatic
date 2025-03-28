package com.example.send_sms

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import android.os.Bundle
import android.telephony.SubscriptionManager
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"
    private val TAG = "SMS_DEBUG"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                val simSlot = call.argument<Int>("simSlot")

                if (phoneNumber != null && message != null && simSlot != null) {
                    try {
                        // Comprehensive SIM detection and logging
                        logSimCardDetails()
                        
                        sendSms(phoneNumber, message, simSlot)
                        result.success("SMS Sent Successfully from SIM $simSlot")
                    } catch (e: Exception) {
                        Log.e(TAG, "SMS Send Error", e)
                        result.error("SMS_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid phone number, message, or sim slot", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun logSimCardDetails() {
        val context = applicationContext
        
        // Check permissions
        if (!checkPhoneStatePermission()) {
            Log.e(TAG, "READ_PHONE_STATE permission not granted")
            return
        }

        // Telephony Manager approach
        val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        Log.d(TAG, "Telephony Manager SIM Count: ${telephonyManager.phoneCount}")

        // Subscription Manager approach
        val subscriptionManager = context.getSystemService(SubscriptionManager::class.java)
        
        try {
            val activeSubscriptions = getActiveSubscriptions(subscriptionManager)
            
            Log.d(TAG, "Total Active Subscriptions: ${activeSubscriptions.size}")
            
            activeSubscriptions.forEachIndexed { index, subscriptionInfo ->
                Log.d(TAG, "Subscription $index Details:")
                Log.d(TAG, "Subscription ID: ${subscriptionInfo.subscriptionId}")
                Log.d(TAG, "Display Name: ${subscriptionInfo.displayName}")
                Log.d(TAG, "Carrier Name: ${subscriptionInfo.carrierName}")
                Log.d(TAG, "SIM Slot Index: ${subscriptionInfo.simSlotIndex}")
                Log.d(TAG, "Is Network Roaming: ${subscriptionInfo.dataRoaming}")
            }
        } catch (e: SecurityException) {
            Log.e(TAG, "Security Exception while accessing subscriptions", e)
        }
    }

    private fun checkPhoneStatePermission(): Boolean {
        return ActivityCompat.checkSelfPermission(
            applicationContext, 
            Manifest.permission.READ_PHONE_STATE
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun getActiveSubscriptions(subscriptionManager: SubscriptionManager): List<android.telephony.SubscriptionInfo> {
        return if (checkPhoneStatePermission()) {
            subscriptionManager.activeSubscriptionInfoList ?: emptyList()
        } else {
            emptyList()
        }
    }

    private fun sendSms(phoneNumber: String, message: String, simSlot: Int) {
        val context = applicationContext
        val subscriptionManager = context.getSystemService(SubscriptionManager::class.java)
        
        // Check permissions
        if (!checkPhoneStatePermission()) {
            throw SecurityException("READ_PHONE_STATE permission not granted")
        }

        val activeSubscriptions = getActiveSubscriptions(subscriptionManager)
        
        if (activeSubscriptions.isEmpty()) {
            // Additional diagnostic logging
            val telephonyManager = context.getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            Log.e(TAG, "No active SIM detected")
            Log.e(TAG, "Telephony Manager SIM State: ${telephonyManager.simState}")
            Log.e(TAG, "Telephony Manager Network Operator: ${telephonyManager.networkOperatorName}")
            
            throw IllegalStateException("No active SIM cards found. Check device SIM status.")
        }

        // More robust SIM selection
        val targetSubscription = when (simSlot) {
            1 -> activeSubscriptions.firstOrNull { it.simSlotIndex == 0 }
            2 -> activeSubscriptions.firstOrNull { it.simSlotIndex == 1 }
            else -> throw IllegalArgumentException("Invalid SIM slot: $simSlot")
        } ?: throw IllegalStateException("Requested SIM slot not available")

        // Use the correct method to get SMS manager for a specific subscription
        val smsManager = SmsManager.getSmsManagerForSubscriptionId(targetSubscription.subscriptionId)

        // Send message logic remains the same
        if (message.length > 160) {
            val parts = smsManager.divideMessage(message)
            smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
        } else {
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        }
    }
}