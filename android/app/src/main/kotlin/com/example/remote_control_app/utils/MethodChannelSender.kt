package com.example.remote_control_app.utils

import io.flutter.plugin.common.MethodChannel

object MethodChannelSender {
    var methodChannel: MethodChannel? = null

    fun setGestureMethodChannel(channel: MethodChannel) {
        methodChannel = channel
    }

}