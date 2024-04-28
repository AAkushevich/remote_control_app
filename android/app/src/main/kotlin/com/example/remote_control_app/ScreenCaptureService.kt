package com.example.remote_control_app

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.DisplayMetrics
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.example.remote_control_app.utils.MethodChannelSender

class ScreenCaptureService : Service() {

    private lateinit var mediaProjectionManager: MediaProjectionManager
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private lateinit var mediaCodec: MediaCodec
    private var displayWidth: Int = 0
    private var displayHeight: Int = 0
    private var displayMetrics: DisplayMetrics? = null
    private val screenDensity: Int
        get() = displayMetrics?.densityDpi ?: DisplayMetrics.DENSITY_DEFAULT

    private val frameRate = 25 // Desired frame rate for screen capture
    private val frameInterval = 1000 / frameRate.toLong() // Frame interval in milliseconds

    private var frameIndex = 0

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()

        displayMetrics = resources.displayMetrics
        displayWidth = resources.displayMetrics.widthPixels
        displayHeight = resources.displayMetrics.heightPixels
        mediaProjectionManager = getSystemService(Context.MEDIA_PROJECTION_SERVICE) as MediaProjectionManager

        startScreenCapture()
    }

    @SuppressLint("WrongConstant")
    private fun createMediaCodec() {
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, displayWidth, displayHeight)
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatSurface)
        format.setInteger(MediaFormat.KEY_BIT_RATE, 100000)
        format.setInteger(MediaFormat.KEY_FRAME_RATE, frameRate)
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)

        try {
            mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
            mediaCodec.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        } catch (e: Exception) {
            e.printStackTrace()
        }
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

    private fun startMediaProjection(intent: Intent) {
        val resultCode = intent.getIntExtra(EXTRA_RESULT_CODE, -1)
        val data = intent.getParcelableExtra<Intent>(EXTRA_DATA)
        mediaProjection = data?.let { mediaProjectionManager.getMediaProjection(resultCode, it) }

        createMediaCodec()

        virtualDisplay = mediaProjection?.createVirtualDisplay(
            "ScreenCapture",
            displayWidth,
            displayHeight,
            screenDensity,
            DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
            mediaCodec.createInputSurface(),
            null,
            Handler(Looper.getMainLooper())
        )

        mediaCodec.start()
        startCapturing()
    }

    private fun startCapturing() {
        val bufferInfo = MediaCodec.BufferInfo()

        Handler().postDelayed(object : Runnable {
            override fun run() {
                val outputBufferIndex = mediaCodec.dequeueOutputBuffer(bufferInfo, 33333)
                if (outputBufferIndex >= 0) {
                    val outputBuffer = mediaCodec.getOutputBuffer(outputBufferIndex)
                    val outData = ByteArray(bufferInfo.size)
                    outputBuffer?.position(bufferInfo.offset)
                    outputBuffer?.limit(bufferInfo.offset + bufferInfo.size)
                    outputBuffer?.get(outData)

                    sendVideoFrame(outData)

                    mediaCodec.releaseOutputBuffer(outputBufferIndex, false)
                }

                if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                    stopScreenCapture()
                } else {
                    Handler(Looper.getMainLooper()).postDelayed(this, frameInterval)
                }
            }
        }, frameInterval)
    }

    private fun stopScreenCapture() {
        mediaCodec.stop()
        mediaCodec.release()
        mediaProjection?.stop()
        mediaProjection = null
        virtualDisplay?.release()
        virtualDisplay = null
        stopForeground(true)
        stopSelf()
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

    private fun sendVideoFrame(frameData: ByteArray) {
        MethodChannelSender.sendVideoFrame(frameData)
    }

    companion object {
        private const val NOTIFICATION_ID = 1
        const val ACTION_START_CAPTURE = "com.example.remote_control_app.START_CAPTURE"
        const val EXTRA_RESULT_CODE = "com.example.remote_control_app.EXTRA_RESULT_CODE"
        const val EXTRA_DATA = "com.example.remote_control_app.EXTRA_DATA"
    }
}
