package com.example.remote_control_app.utils

import io.flutter.plugin.common.MethodChannel

object MethodChannelSender {
    private var methodChannel: MethodChannel? = null

    fun setMethodChannel(channel: MethodChannel) {
        methodChannel = channel
    }

    fun sendScreenshotBytes(screenshotBytes: ByteArray) {
        methodChannel?.invokeMethod("receive_screenshot_data", screenshotBytes)
    }

    // Add a new method to send the encoded video frame
    fun sendVideoFrame(frameData: ByteArray) {
        methodChannel?.invokeMethod("receive_video_frame", frameData)
    }
}