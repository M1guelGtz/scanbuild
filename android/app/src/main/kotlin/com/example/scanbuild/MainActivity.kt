package com.example.scanbuild

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "visionprice/secure_screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        runOnUiThread {
                            window.setFlags(
                                WindowManager.LayoutParams.FLAG_SECURE,
                                WindowManager.LayoutParams.FLAG_SECURE
                            )
                            result.success(true)
                        }
                    }
                    "disable" -> {
                        runOnUiThread {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    // NOTA: FLAG_SECURE NO se aplica aquí en onCreate. El control del flag
    // está centralizado en Dart (SecureScreen.kEnabled). De esta forma,
    // alternar entre "protegido" y "permite capturas" se hace cambiando un
    // único booleano en lib/services/secure_screen.dart sin tocar Kotlin.
}
