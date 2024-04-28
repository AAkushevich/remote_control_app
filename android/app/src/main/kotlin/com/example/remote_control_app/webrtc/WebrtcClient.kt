/*

package com.example.remote_control_app.webrtc

import android.content.Context
import android.content.Intent
import android.media.projection.MediaProjection
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager
import com.example.remote_control_app.utils.DataModel
import com.example.remote_control_app.utils.DataModelType
import com.google.gson.Gson
import org.webrtc.*
import org.webrtc.PeerConnection.Observer
import javax.inject.Inject

class WebrtcClient @Inject constructor(
    private val context: Context, private val gson: Gson
) {
    private lateinit var username: String
    private lateinit var observer: Observer

    var listener: Listener? = null
    private var permissionIntent: Intent? = null

    private var peerConnection: PeerConnection? = null
    private val eglBaseContext = EglBase.create().eglBaseContext
    private val peerConnectionFactory by lazy { createPeerConnectionFactory() }

    private val mediaConstraint = MediaConstraints().apply {
        mandatory.add(MediaConstraints.KeyValuePair("OfferToReceiveVideo", "true"))
    }

    private val iceServer = listOf(
        PeerConnection.IceServer(
            "turn:openrelay.metered.ca:443?transport=tcp", "openrelayproject", "openrelayproject"
        )
    )

    private var screenCapturer: VideoCapturer? = null
    private val localVideoSource by lazy { peerConnectionFactory.createVideoSource(false) }
    private val localTrackId = "local_track"
    private val localStreamId = "local_stream"
    private var localVideoTrack: VideoTrack? = null
    private var localStream: MediaStream? = null

    init {
        initPeerConnectionFactory(context)
    }

    fun initializeWebrtcClient(
        username: String, observer: Observer) {
        this.username = username
        this.observer = observer
        peerConnection = createPeerConnection(observer)
    }

    fun setPermissionIntent(intent: Intent) {
        this.permissionIntent = intent
    }

    fun startScreenCapturing(view: SurfaceViewRenderer) {
        val displayMetrics = DisplayMetrics()
        val windowsManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        windowsManager.defaultDisplay.getMetrics(displayMetrics)

        val screenWidthPixels = displayMetrics.widthPixels
        val screenHeightPixels = displayMetrics.heightPixels

        val surfaceTextureHelper = SurfaceTextureHelper.create(
            Thread.currentThread().name, eglBaseContext
        )

        screenCapturer = createScreenCapturer()
        screenCapturer!!.initialize(
            surfaceTextureHelper,
            context,
            localVideoSource.capturerObserver
        )
        screenCapturer!!.startCapture(screenWidthPixels, screenHeightPixels, 15)

        localVideoTrack =
            peerConnectionFactory.createVideoTrack(localTrackId + "_video", localVideoSource)
        localVideoTrack?.addSink(view)
        localStream = peerConnectionFactory.createLocalMediaStream(localStreamId)
        localStream?.addTrack(localVideoTrack)
        peerConnection?.addStream(localStream)

    }

    private fun createScreenCapturer(): VideoCapturer {
        return ScreenCapturerAndroid(permissionIntent, object : MediaProjection.Callback() {
            override fun onStop() {
                super.onStop()
                Log.d("TAG", "onStop: stopped screen casting permission")
            }
        })
    }

    private fun initPeerConnectionFactory(application: Context) {
        val options = PeerConnectionFactory.InitializationOptions.builder(application)
            .setEnableInternalTracer(true).setFieldTrials("WebRTC-H264HighProfile/Enabled/")
            .createInitializationOptions()
        PeerConnectionFactory.initialize(options)
    }

    private fun createPeerConnectionFactory(): PeerConnectionFactory {
        return PeerConnectionFactory.builder().setVideoDecoderFactory(
            DefaultVideoDecoderFactory(eglBaseContext)
        ).setVideoEncoderFactory(
            DefaultVideoEncoderFactory(
                eglBaseContext, true, true
            )
        ).setOptions(PeerConnectionFactory.Options().apply {
            disableEncryption = false
            disableNetworkMonitor = false
        }).createPeerConnectionFactory()
    }

    private fun createPeerConnection(observer: Observer): PeerConnection? {
        return peerConnectionFactory.createPeerConnection(
            iceServer, observer
        )
    }

    fun call(target: String) {
        peerConnection?.createOffer(object : MySdpObserver() {
            override fun onCreateSuccess(desc: SessionDescription?) {
                super.onCreateSuccess(desc)
                peerConnection?.setLocalDescription(object : MySdpObserver() {
                    override fun onSetSuccess() {
                        super.onSetSuccess()
                        listener?.onTransferEventToSocket(
                            DataModel(
                                type = DataModelType.Offer, username, target, desc?.description
                            )
                        )
                    }
                }, desc)
            }
        }, mediaConstraint)
    }

    fun answer(target: String) {
        peerConnection?.createAnswer(object : MySdpObserver() {
            override fun onCreateSuccess(desc: SessionDescription?) {
                super.onCreateSuccess(desc)
                peerConnection?.setLocalDescription(object : MySdpObserver() {
                    override fun onSetSuccess() {
                        super.onSetSuccess()
                        listener?.onTransferEventToSocket(
                            DataModel(
                                type = DataModelType.Answer,
                                username = username,
                                target = target,
                                data = desc?.description
                            )
                        )
                    }
                }, desc)
            }
        }, mediaConstraint)
    }

    fun onRemoteSessionReceived(sessionDescription: SessionDescription) {
        peerConnection?.setRemoteDescription(MySdpObserver(), sessionDescription)
    }

    fun addIceCandidate(iceCandidate: IceCandidate) {
        peerConnection?.addIceCandidate(iceCandidate)
    }

    fun sendIceCandidate(candidate: IceCandidate, target: String) {
        addIceCandidate(candidate)
        listener?.onTransferEventToSocket(
            DataModel(
                type = DataModelType.IceCandidates,
                username = username,
                target = target,
                data = gson.toJson(candidate)
            )
        )
    }

    fun closeConnection() {
        try {
            screenCapturer?.stopCapture()
            screenCapturer?.dispose()
            localStream?.dispose()
            peerConnection?.close()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun restart() {
        closeConnection()

    }

    interface Listener {
        fun onTransferEventToSocket(data: DataModel)
    }
}*/
