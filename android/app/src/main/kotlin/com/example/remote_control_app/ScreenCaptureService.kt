package com.example.remote_control_app
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.flow.MutableSharedFlow
import java.nio.ByteBuffer

class ScreenCaptureService : Service() {

    private val TAG = "ScreenCaptureService"
    private val INTERVAL = 1000L // Interval in milliseconds

    private lateinit var mediaProjectionManager: MediaProjectionManager
    private var mediaProjection: MediaProjection? = null
    private var windowManager: WindowManager? = null
    private var displayWidth: Int = 0
    private var displayHeight: Int = 0
    private var screenDensity: Int = 0
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private val handler = Handler()

    private val captureRunnable = object : Runnable {
        override fun run() {
            captureScreen()
            handler.postDelayed(this, INTERVAL)
        }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val metrics = DisplayMetrics()
        windowManager?.defaultDisplay?.getMetrics(metrics)
        screenDensity = metrics.densityDpi
        displayWidth = metrics.widthPixels
        displayHeight = metrics.heightPixels
        imageReader = ImageReader.newInstance(displayWidth, displayHeight, PixelFormat.RGBA_8888, 2)

    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_START_CAPTURE) {
            val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, 0)
            val data = intent.getParcelableExtra<Intent>(EXTRA_DATA)

            startCapture(resultCode, data)
            startForeground(NOTIFICATION_ID, createNotification()) // Start service as foreground

        } else if (intent?.action == ACTION_STOP_CAPTURE) {
            stopCapture()
            stopForeground(true) // Stop service as foreground
            stopSelf() // Stop the service
        }

        return START_NOT_STICKY
    }

    private fun startCapture(resultCode: Int, data: Intent?) {
        mediaProjection = data?.let { mediaProjectionManager.getMediaProjection(resultCode, it) }
        virtualDisplay = mediaProjection?.createVirtualDisplay(
                "ScreenCapture",
                displayWidth,
                displayHeight,
                screenDensity,
                DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                imageReader?.surface,
                null,
                null
        )
        handler.post(captureRunnable)
    }

    private fun stopCapture() {
        handler.removeCallbacks(captureRunnable)
        mediaProjection?.stop()
        mediaProjection = null
        virtualDisplay?.release()
        virtualDisplay = null
        imageReader?.close()
        imageReader = null
    }

    private fun captureScreen() {
        val image = imageReader?.acquireLatestImage()
        image?.let {
            val buffer: ByteBuffer = it.planes[0].buffer
            val bytes = ByteArray(buffer.remaining())
            buffer.get(bytes)

            // Log a summary of the screenshot bytes
            val byteSummary = "ScreenCaptureService Screenshot bytes size: ${bytes.size}"
            Log.d(TAG, byteSummary)

            // Send the screenshot data via a broadcast intent
            val screenshotIntent = Intent("screenshot_event")
            screenshotIntent.putExtra("screenshotData", bytes)
            sendBroadcast(screenshotIntent)

            it.close()
        }
    }

    private fun createNotification(): Notification {
        val channelId =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    createNotificationChannel("screen_capture_channel", "Screen Capture Channel")
                } else {
                    "" // If SDK version is lower than Oreo, channel ID is not used
                }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notificationBuilder = NotificationCompat.Builder(this, channelId)
                .setContentTitle("Screen Capture Service")
                .setContentText("Capturing screen...")
                .setContentIntent(pendingIntent)
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        return notificationBuilder.build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        val notificationChannel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(notificationChannel)
        return channelId
    }

    companion object {
        private const val NOTIFICATION_ID = 1
        const val ACTION_START_CAPTURE = "com.example.remote_control_app.START_CAPTURE"
        const val ACTION_STOP_CAPTURE = "com.example.remote_control_app.STOP_CAPTURE"
        const val EXTRA_RESULT_CODE = "com.example.remote_control_app.EXTRA_RESULT_CODE"
        const val EXTRA_DATA = "com.example.remote_control_app.EXTRA_DATA"
        const val EXTRA_BINARY_MESSENGER = "com.example.remote_control_app.EXTRA_BINARY_MESSENGER"

    }
}

object ScreenshotEventBus {
    val screenshotFlow = MutableSharedFlow<ByteArray>()  // Define a shared flow to emit screenshot data
}

