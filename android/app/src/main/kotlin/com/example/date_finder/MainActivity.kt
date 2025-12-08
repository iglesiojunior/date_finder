package com.example.date_finder

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.date_finder.BuildConfig

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.date_finder/api_key"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGoogleMapsApiKey") {
                val apiKey = BuildConfig.GOOGLE_MAPS_API_KEY
                if (apiKey.isNotEmpty()) {
                    result.success(apiKey)
                } else {
                    result.error("UNAVAILABLE", "API key not found", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
