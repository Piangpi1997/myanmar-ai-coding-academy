package com.piangpi.myanmaracademy

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.Base64
import android.view.View
import android.webkit.*
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.ByteArrayInputStream

class RestrictedPreviewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView = RestrictedPreview(context, viewId, messenger)
}

/** A disposable, offline-only learning renderer. Never add a JavaScript interface. */
@Suppress("DEPRECATION")
private class RestrictedPreview(context: Context, id: Int, messenger: BinaryMessenger) : PlatformView {
    private val root = FrameLayout(context)
    private val web = WebView(context)
    private val channel = MethodChannel(messenger, "academy/web-preview/$id")
    private var disposed = false
    private var broken = false
    private var messages = 0

    init {
        web.setBackgroundColor(android.graphics.Color.WHITE)
        web.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = false
            databaseEnabled = false
            allowFileAccess = false
            allowContentAccess = false
            allowFileAccessFromFileURLs = false
            allowUniversalAccessFromFileURLs = false
            blockNetworkLoads = true
            blockNetworkImage = true
            mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
            javaScriptCanOpenWindowsAutomatically = false
            setSupportMultipleWindows(false)
            mediaPlaybackRequiresUserGesture = true
            cacheMode = WebSettings.LOAD_NO_CACHE
            if (Build.VERSION.SDK_INT >= 26) safeBrowsingEnabled = true
        }
        CookieManager.getInstance().setAcceptThirdPartyCookies(web, false)
        // Defensive removal of historical built-in bridges; no app bridge is installed.
        listOf("searchBoxJavaBridge_", "accessibility", "accessibilityTraversal").forEach(web::removeJavascriptInterface)
        web.setDownloadListener { _, _, _, _, _ -> /* No downloads. */ }
        web.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean = true
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean = true
            override fun shouldInterceptRequest(view: WebView?, request: WebResourceRequest?): WebResourceResponse? {
                val scheme = request?.url?.scheme
                return if (scheme == "data" || scheme == "about") null else
                    WebResourceResponse("text/plain", "UTF-8", ByteArrayInputStream(ByteArray(0)))
            }
            override fun onPageFinished(view: WebView?, url: String?) { notify("ready", "") }
            override fun onReceivedError(view: WebView?, request: WebResourceRequest?, error: WebResourceError?) {
                if (request?.isForMainFrame == true) notify("error", "Preview could not be rendered")
            }
            override fun onRenderProcessGone(view: WebView?, detail: RenderProcessGoneDetail?): Boolean {
                broken = true
                root.removeView(web)
                web.destroy()
                root.addView(TextView(context).apply { text = "Preview stopped. Reset the preview to continue." })
                notify("error", "Preview renderer stopped")
                return true
            }
        }
        web.webChromeClient = object : WebChromeClient() {
            override fun onConsoleMessage(message: ConsoleMessage?): Boolean {
                if (message != null && messages++ < 80) {
                    notify(if (message.messageLevel() == ConsoleMessage.MessageLevel.ERROR) "error" else "console",
                        "${message.lineNumber()}: ${message.message()}".take(1000))
                }
                return true
            }
            override fun onPermissionRequest(request: PermissionRequest?) { request?.deny() }
            override fun onGeolocationPermissionsShowPrompt(origin: String?, callback: GeolocationPermissions.Callback?) { callback?.invoke(origin, false, false) }
            override fun onShowFileChooser(view: WebView?, callback: ValueCallback<Array<Uri>>?, params: FileChooserParams?): Boolean { callback?.onReceiveValue(null); return true }
            override fun onCreateWindow(view: WebView?, dialog: Boolean, gesture: Boolean, message: android.os.Message?): Boolean = false
            override fun onJsAlert(view: WebView?, url: String?, message: String?, result: JsResult?): Boolean { result?.cancel(); return true }
            override fun onJsConfirm(view: WebView?, url: String?, message: String?, result: JsResult?): Boolean { result?.cancel(); return true }
            override fun onJsPrompt(view: WebView?, url: String?, message: String?, defaultValue: String?, result: JsPromptResult?): Boolean { result?.cancel(); return true }
        }
        if (Build.VERSION.SDK_INT >= 29) {
            web.webViewRenderProcessClient = object : WebViewRenderProcessClient() {
                override fun onRenderProcessUnresponsive(view: WebView, renderer: WebViewRenderProcess?) {
                    notify("error", "Preview script stopped responding")
                    renderer?.terminate()
                }
                override fun onRenderProcessResponsive(view: WebView, renderer: WebViewRenderProcess?) {}
            }
        }
        root.addView(web, FrameLayout.LayoutParams(-1, -1))
        // This channel exists between Flutter and native Android, never in the web page.
        channel.setMethodCallHandler { call, result ->
            if (call.method != "load") { result.notImplemented(); return@setMethodCallHandler }
            val html = call.argument<String>("html")
            if (disposed || broken || html == null || html.toByteArray(Charsets.UTF_8).size > 524288) {
                result.error("preview_unavailable", "Preview unavailable or document too large", null)
            } else {
                messages = 0
                web.stopLoading()
                web.clearHistory()
                web.loadData(Base64.encodeToString(html.toByteArray(Charsets.UTF_8), Base64.NO_WRAP), "text/html", "base64")
                result.success(null)
            }
        }
    }
    private fun notify(kind: String, text: String) {
        if (!disposed) channel.invokeMethod("event", mapOf("kind" to kind, "text" to text))
    }
    override fun getView(): View = root
    override fun dispose() {
        disposed = true
        channel.setMethodCallHandler(null)
        if (!broken) { web.stopLoading(); root.removeView(web); web.destroy() }
    }
}
