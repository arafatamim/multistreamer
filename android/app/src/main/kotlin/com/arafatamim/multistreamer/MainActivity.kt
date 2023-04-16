package com.arafatamim.multistreamer

import android.os.Bundle
import androidx.annotation.NonNull
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLException
import com.yausername.youtubedl_android.YoutubeDLRequest
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.reactivex.rxjava3.android.schedulers.AndroidSchedulers
import io.reactivex.rxjava3.core.*
import io.reactivex.rxjava3.disposables.CompositeDisposable
import io.reactivex.rxjava3.schedulers.Schedulers

class MainActivity : FlutterActivity() {
  private val compositeDisposable = CompositeDisposable()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    YoutubeDL.getInstance().init(this)
  }

  override fun onDestroy() {
    compositeDisposable.dispose()
    super.onDestroy()
  }

  private val CHANNEL = "com.arafatamim.multistreamer/youtubedl"
  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
        call,
        result ->
      when (call.method) {
        "dumpJson" -> {
          val url = call.argument<String>("url")
          val disposable =
              Observable.fromCallable {
                    val request = YoutubeDLRequest(url)
                    request.addOption("--skip-download")
                    request.addOption("--dump-json")
                    YoutubeDL.getInstance().execute(request)
                  }
                  .subscribeOn(Schedulers.newThread())
                  .observeOn(AndroidSchedulers.mainThread())
                  .subscribe(
                      { resp -> result.success(resp.out) },
                      { e -> result.error("YoutubeDLException", e.message, null) }
                  )
          compositeDisposable.add(disposable)
        }
        "fetchUrl" -> {
          val url = call.argument<String>("url")
          val disposable =
              Observable.fromCallable {
                    val request = YoutubeDLRequest(url)
                    request.addOption("-f", "best")
                    YoutubeDL.getInstance().getInfo(request)
                  }
                  .subscribeOn(Schedulers.newThread())
                  .observeOn(AndroidSchedulers.mainThread())
                  .subscribe(
                      { info -> result.success(info.getUrl()) },
                      { e -> result.error("YoutubeDLException", e.message, null) }
                  )
          compositeDisposable.add(disposable)
        }
        "fetchThumbnail" -> {
          val url = call.argument<String>("url")
          val request = YoutubeDLRequest(url)
          request.addOption("--get-thumbnail")
          try {
            val resp = YoutubeDL.getInstance().execute(request)
            result.success(resp.out)
          } catch (e: YoutubeDLException) {
            result.error("YoutubeDLException", e.message, null)
          }
        }
        "getVersion" -> {
          YoutubeDL.getInstance().version(this)?.let { version -> result.success(version) }
              ?: run { result.error("YoutubeDLException", "Version could not be loaded", null) }
        }
        "updateLibrary" -> {
          val disposable =
              Observable.fromCallable { YoutubeDL.getInstance().updateYoutubeDL(getApplication(), YoutubeDL.UpdateChannel.STABLE) }
                  .subscribeOn(Schedulers.newThread())
                  .observeOn(AndroidSchedulers.mainThread())
                  .subscribe(
                      { status ->
                        when (status) {
                          YoutubeDL.UpdateStatus.DONE -> result.success(0)
                          YoutubeDL.UpdateStatus.ALREADY_UP_TO_DATE -> result.success(1)
                          else -> result.error("YoutubeDLException", "Invalid status", null)
                        }
                      },
                      { e -> result.error("YoutubeDLException", e.message, null) }
                  )
          compositeDisposable.add(disposable)
        }
        else -> result.notImplemented()
      }
    }
  }
}
