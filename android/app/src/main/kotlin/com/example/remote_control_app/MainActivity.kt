package com.example.remote_control_app

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Bundle
import android.os.IBinder
import android.os.Message
import android.os.Messenger
import android.os.RemoteException
import android.util.Log
import com.example.remote_control_app.utils.MethodChannelSender
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class MainActivity : FlutterActivity() {
    private lateinit var methodChannel: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        EventBus.getDefault().register(this)
        startAccessibilityService()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "command_channel")
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method.equals("perform_gesture")) {
                val data: String? = call.arguments.toString()
                if (data != null) {
                    EventBus.getDefault().post(MessageEvent(data))
                    println("[Important point] MainActivity() : Received coords: $data")
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: MessageEvent) {

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
    }

    private fun startAccessibilityService() {
        val intent = Intent(this, MyAccessibilityService::class.java)
        startService(intent)
    }

    override fun onDestroy() {
        EventBus.getDefault().unregister(this)
        super.onDestroy()
    }
}