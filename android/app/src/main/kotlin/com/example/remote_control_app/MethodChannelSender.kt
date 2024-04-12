package com.example.remote_control_app

import io.flutter.plugin.common.MethodChannel

object MethodChannelSender {
    private var methodChannel: MethodChannel? = null

    fun setMethodChannel(channel: MethodChannel) {
        methodChannel = channel
    }

    fun sendScreenshotBytes(screenshotBytes: ByteArray) {
        methodChannel?.invokeMethod("receive_screenshot_data", screenshotBytes)
    }
}