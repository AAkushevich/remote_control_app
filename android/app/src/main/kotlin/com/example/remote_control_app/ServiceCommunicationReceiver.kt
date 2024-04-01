package com.example.remote_control_app
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.Log

class ServiceCommunicationReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("BroadcastReceiver", "Received broadcast message")

        // Extract data from the intent
        val chunkIndex = intent.getIntExtra("chunkIndex", 0)
        val totalChunks = intent.getIntExtra("totalChunks", 0)
        val screenshotChunk = intent.getByteArrayExtra("screenshotChunk")

        // Log the extracted data
        Log.d("BroadcastReceiver", "Chunk index: $chunkIndex")
        Log.d("BroadcastReceiver", "Total chunks: $totalChunks")
        Log.d("BroadcastReceiver", "Screenshot chunk size: ${screenshotChunk?.size}")
    }
}