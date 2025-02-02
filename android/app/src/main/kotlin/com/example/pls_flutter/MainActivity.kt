package com.example.pls_flutter
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val SAMPLE_CHANNEL = "hungnguy.pls.flutter.dev/sample"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SAMPLE_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getSampleChannel") {
                    val greeting = getGreeting();
                    result.success(greeting)
                } else {
                    result.notImplemented()
                }
        }
    }

    fun getGreeting(): String {
        return "Hello World in Kotlin!!!!!!!";
    }
}
