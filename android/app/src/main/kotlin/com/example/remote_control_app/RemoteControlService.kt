package com.example.remote_control_app

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.util.Log
import android.view.accessibility.AccessibilityEvent

import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import org.json.JSONObject
import toCommand

class RemoteControlService : AccessibilityService() {

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: MessageEvent) {
        val jsonObject = JSONObject(event.message)
        val command = jsonObject.toCommand()

        when(command.type) {
            "touch" -> {
                performTouch(command.startCoords.x, command.startCoords.y)
            }
            "swipe" -> {
                performSwipe(
                    command.startCoords.x, command.startCoords.y,
                    command.endCoords.x, command.endCoords.y)
            }
        }

    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) { }

    private fun performTouch(x: Double, y: Double) {
        val clickPath = Path().apply {
            moveTo(x.toFloat(), y.toFloat())
        }
        val clickGesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(clickPath, 0, 1)).build()
        dispatchGesture(clickGesture, object : GestureResultCallback() {}, null)
    }

    private fun performSwipe(startX: Double, startY: Double, endX: Double, endY: Double) {
        val swipePath = Path().apply {
            moveTo(startX.toFloat(), startY.toFloat())
            lineTo(endX.toFloat(), endY.toFloat())
        }
        val swipeGesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(swipePath, 0, 1))
            .build()
        dispatchGesture(swipeGesture, null, null)
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        println("[Important point] MyAccessibilityService() onServiceConnected()")
        EventBus.getDefault().register(this);
        Log.d("AccessibilityService", "Service connected, registering EventBus")
    }

    override fun onInterrupt() {
        EventBus.getDefault().unregister(this)
    }

}

class MessageEvent(val message: String)