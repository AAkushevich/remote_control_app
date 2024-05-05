import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class MyAccessibilityService : AccessibilityService() {

    override fun onInterrupt() { }

    override fun onCreate() {
        super.onCreate()
        Log.d("MyAccessibilityService", "onCreate")
    }
    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("MyAccessibilityService", "onServiceConnected")
    }
    override fun onDestroy() {
        super.onDestroy()
        Log.d("MyAccessibilityService", "onDestroy")
    }
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        Log.d("MyAccessibilityService", "onAccessibilityEvent: ${event?.eventType}")
        when (event?.eventType) {
            AccessibilityEvent.TYPE_VIEW_CLICKED -> {
                println("onAccessibilityEvent")
                // Check if the event source is your app's specific view to trigger the swipe
                if (event.source?.className == "android.widget.Button" && event.source?.text == "Swipe") {
                    println("event.source?.className == \"android.widget.Button\" && event.source?.text == \"Swipe\"")
                    performSwipe()
                }
            }
        }
    }

    private fun performSwipe() {
        println("performSwipe")
        val swipeLeftAction = AccessibilityNodeInfo.AccessibilityAction(
                AccessibilityNodeInfo.ACTION_PREVIOUS_AT_MOVEMENT_GRANULARITY,
                null
        )

        rootInActiveWindow?.let { rootNode ->
            rootNode.findAccessibilityNodeInfosByText("Swipeable View's Text")?.forEach { swipeableNode ->
                swipeableNode.performAction(AccessibilityNodeInfo.ACTION_FOCUS)
                swipeableNode.performAction(swipeLeftAction.id)
            }
        }
    }
}
