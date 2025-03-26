package com.example.send_sms
import android.content.Intent
import android.net.Uri
import android.telephony.SmsManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendSms") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                val simSlot = call.argument<Int>("simSlot")

                if (phoneNumber != null && message != null && simSlot != null) {
                    sendSms(phoneNumber, message, simSlot)
                    result.success("SMS Sent Successfully!")
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid phone number or message", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSms(phoneNumber: String, message: String, simSlot: Int) {
        try {
            val smsManager = if (simSlot == 0) {
                SmsManager.getDefault() // SIM 1
            } else {
                applicationContext.getSystemService(SmsManager::class.java) // SIM 2
            }
            smsManager.sendTextMessage(phoneNumber, null, message, null, null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}