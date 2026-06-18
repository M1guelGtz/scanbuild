package com.miguel.scanbuild

import android.database.ContentObserver
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName = "visionprice/secure_screen"

    private val securityChannelName = "visionprice/usb_debugging"

    private val securityEventsChannelName = "visionprice/usb_debugging_events"
    private var adbObserver: ContentObserver? = null

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

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isUsbDebuggingEnabled" -> {
                        try {
                            val adbEnabled = Settings.Global.getInt(
                                contentResolver,
                                Settings.Global.ADB_ENABLED,
                                0
                            )
                            result.success(adbEnabled == 1)
                        } catch (e: Exception) {
                            result.error("ADB_CHECK_FAILED", e.message, null)
                        }
                    }
                    "isAppDebuggable" -> {
                        val debuggable = 0 != (applicationInfo.flags and
                            android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE)
                        result.success(debuggable)
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, securityEventsChannelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    val handler = Handler(Looper.getMainLooper())
                    val observer = object : ContentObserver(handler) {
                        override fun onChange(selfChange: Boolean) {
                            val enabled = Settings.Global.getInt(
                                contentResolver,
                                Settings.Global.ADB_ENABLED,
                                0
                            ) == 1
                            events?.success(enabled)
                        }
                    }
                    contentResolver.registerContentObserver(
                        Settings.Global.getUriFor(Settings.Global.ADB_ENABLED),
                        false,
                        observer
                    )
                    adbObserver = observer
                }

                override fun onCancel(arguments: Any?) {
                    adbObserver?.let { contentResolver.unregisterContentObserver(it) }
                    adbObserver = null
                }
            })
    }
}
