package com.piangpi.myanmaracademy

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "academy/restricted-web-preview", RestrictedPreviewFactory(flutterEngine.dartExecutor.binaryMessenger)
        )
    }
}
