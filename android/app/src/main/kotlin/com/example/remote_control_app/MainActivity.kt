package com.example.remote_control_app
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.service.controls.ControlsProviderService.TAG
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch


class MainActivity: FlutterActivity() {
    private var REQUEST_CODE_SCREEN_CAPTURE = 101
    private val mainScope = MainScope()
    private val CHANNEL_SCREENSHOT = "screenshot_event_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "capture_screenshot_channel")
                .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                    if (call.method == "startScreenSharing") {
                        startForegroundServiceForScreenSharing()
                        result.success(null)
                    } else {
                        result.notImplemented()
                    }
                }
        // Register the broadcast receiver to receive screenshot data
        val filter = IntentFilter("screenshot_event")
        registerReceiver(broadcastReceiver, filter)

    }

    private fun startForegroundServiceForScreenSharing() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            startActivityForResult(mediaProjectionManager.createScreenCaptureIntent(), REQUEST_CODE_SCREEN_CAPTURE)
        } else {
            // Handle devices with SDK version lower than Lollipop
            // Screen capturing not supported
            // You may display a message or take alternative actions
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        // Forward the result to the service
        val serviceIntent = Intent(this, ScreenCaptureService::class.java).apply {
            action = ScreenCaptureService.ACTION_START_CAPTURE
            putExtra(ScreenCaptureService.EXTRA_RESULT_CODE, resultCode)
            putExtra(ScreenCaptureService.EXTRA_DATA, data)
            putExtra(ScreenCaptureService.EXTRA_BINARY_MESSENGER, "unique_identifier")

        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private val broadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            // Handle the received screenshot data
            val screenshotData = intent?.getByteArrayExtra("screenshotData")
            Log.d(TAG, "MainActivity Screenshot bytes size: ${screenshotData?.size}")
            // Update UI with the screenshot data
        }
    }

}