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

fun parseArgs(args: String): List<Pair<String, String>> {
  // parse args like --proxy 0.0.0.0 --force-ipv6 to List<Pair<String, String>> with boolean keys as empty values
  val argsList = args.split(" ").toMutableList()
  val argsMap = mutableListOf<Pair<String, String>>()
  var key: String? = null
  for (arg in argsList) {
    if (arg.startsWith("--")) {
      key = arg.substring(2)
      argsMap.add(Pair(key, ""))
    } else {
      if (key != null) {
        argsMap[argsMap.size - 1] = Pair(key, arg)
        key = null
      }
    }
  }
  return argsMap
}

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
          val legacyServerConnect = call.argument<Boolean>("legacyServerConnect")
          val noCheckCertificates = call.argument<Boolean>("noCheckCertificates")
          val extraArgs = call.argument<String>("extraArgs")

          val disposable =
              Observable.fromCallable {
                      val request = YoutubeDLRequest(url!!)
                      request.addOption("--skip-download")
                      request.addOption("--dump-json")

                      if (legacyServerConnect != null && legacyServerConnect) {
                        request.addOption("--legacy-server-connect")
                      }

                      if (noCheckCertificates != null && noCheckCertificates) {
                        request.addOption("--no-check-certificates")
                      }

                      if (extraArgs != null) {
                        val args = parseArgs(extraArgs)
                        for (arg in args) {
                          if (arg.second.isEmpty()) {
                            request.addOption("--${arg.first}")
                          } else {
                            request.addOption("--${arg.first}", arg.second)
                          }
                        }
                      }

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
                    val request = YoutubeDLRequest(url!!)
                    request.addOption("-f", "best")
                    YoutubeDL.getInstance().getInfo(request)
                  }
                  .subscribeOn(Schedulers.newThread())
                  .observeOn(AndroidSchedulers.mainThread())
                  .subscribe(
                      { info -> result.success(info.url) },
                      { e -> result.error("YoutubeDLException", e.message, null) }
                  )
          compositeDisposable.add(disposable)
        }
        "fetchThumbnail" -> {
          val url = call.argument<String>("url")
          val request = YoutubeDLRequest(url!!)
          request.addOption("--get-thumbnail")
          try {
            val resp = YoutubeDL.getInstance().execute(request)
            result.success(resp.out)
          } catch (e: YoutubeDLException) {
            result.error("YoutubeDLException", e.message, null)
          }
        }
        "getVersion" -> {
          val disposable =
              Observable.fromCallable { YoutubeDL.getInstance().versionName(this) }
                  .subscribeOn(Schedulers.newThread())
                  .observeOn(AndroidSchedulers.mainThread())
                  .subscribe(
                      { version -> result.success(version) },
                      { e -> result.error("YoutubeDLException", e.message, null) }
                  )
          compositeDisposable.add(disposable)
        }
        "updateLibrary" -> {
          val disposable =
              Observable.fromCallable {
                    YoutubeDL.getInstance()
                        .updateYoutubeDL(getApplication(), YoutubeDL.UpdateChannel.STABLE)
                  }
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
