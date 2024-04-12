package com.example.remote_control_app
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.Rect
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
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class ScreenCaptureService : Service() {

    private lateinit var mediaProjectionManager: MediaProjectionManager
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private val handler = Handler()
    private lateinit var screenShotBitmap: Bitmap
    private lateinit var screenShotCanvas: Canvas
    private lateinit var screenShotPaint: Paint
    private var displayWidth: Int = 0
    private var displayHeight: Int = 0
    private var displayMetrics: DisplayMetrics? = null
    private val screenDensity: Int
        get() = displayMetrics?.densityDpi ?: DisplayMetrics.DENSITY_DEFAULT

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate();

        displayMetrics = resources.displayMetrics
        displayWidth = resources.displayMetrics.widthPixels
        displayHeight = resources.displayMetrics.heightPixels
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager

        startScreenCapture()
    }

    private fun startScreenCapture() {
        val projectionIntent = mediaProjectionManager.createScreenCaptureIntent()
        projectionIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(projectionIntent)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_START_CAPTURE) {
            startForeground(NOTIFICATION_ID, createNotification())
            startMediaProjection(intent)
        }
        return START_NOT_STICKY
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


    private fun createNotification(): Notification {
        val channelId = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel("capture_screenshot_channel", "Screen Capture Channel")
        } else {
            ""
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Screen Capture Service")
            .setContentText("Capturing screen...")
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .build()
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(channelId: String, channelName: String): String {
        val notificationChannel = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_DEFAULT)
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(notificationChannel)
        return channelId
    }

    private fun startMediaProjection(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, -1)
        val data = intent.getParcelableExtra<Intent>(EXTRA_DATA)
        mediaProjection = data?.let { mediaProjectionManager.getMediaProjection(resultCode, it) }
        imageReader = ImageReader.newInstance(displayWidth, displayHeight, PixelFormat.RGBA_8888, 2)
        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "Screenshot",
            displayWidth,
            displayHeight,
            screenDensity,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            imageReader?.surface,
            null,
            handler
        )

        handler.postDelayed(captureRunnable, CAPTURE_DELAY)
    }

    private val captureRunnable = object : Runnable {
        override fun run() {
            captureScreen()
            handler.postDelayed(this, CAPTURE_DELAY)
        }
    }

    private fun captureScreen() {
        val image = imageReader?.acquireLatestImage() ?: return
        val planes = image.planes
        val buffer = planes[0].buffer
        val pixelStride = planes[0].pixelStride
        val rowStride = planes[0].rowStride
        val rowPadding = rowStride - pixelStride * image.width

        screenShotBitmap = Bitmap.createBitmap(
            image.width + rowPadding / pixelStride,
            image.height,
            Bitmap.Config.ARGB_8888
        )

        screenShotBitmap.copyPixelsFromBuffer(buffer)

        val width = image.width
        val height = image.height
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val sourceRect = Rect(0, 0, width, height)
        val destRect = Rect(0, 0, width, height)
        screenShotCanvas = Canvas(bitmap)
        screenShotCanvas.drawBitmap(screenShotBitmap, sourceRect, destRect, null)

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream)
        val screenshotBytes = stream.toByteArray()

        sendScreenshot(screenshotBytes)

        image.close()
    }

    private fun sendScreenshot(screenshotData: ByteArray) {
        MethodChannelSender.sendScreenshotBytes(screenshotData)
    }

    private fun stopScreenCapture() {
        mediaProjection?.stop()
        mediaProjection = null
        virtualDisplay?.release()
        virtualDisplay = null
        imageReader?.close()
        imageReader = null
    }

    companion object {
        private const val NOTIFICATION_ID = 1
        const val ACTION_START_CAPTURE = "com.example.remote_control_app.START_CAPTURE"
        const val EXTRA_RESULT_CODE = "com.example.remote_control_app.EXTRA_RESULT_CODE"
        const val EXTRA_DATA = "com.example.remote_control_app.EXTRA_DATA"
        private const val CAPTURE_DELAY = 1000L // Delay between captures in milliseconds
        const val REQUEST_CODE_SCREEN_CAPTURE = 101 // Add this line

    }
}


