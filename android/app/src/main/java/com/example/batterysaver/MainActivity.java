package com.example.batterysaver;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.Methodchannel;
import io.flutter.plugin.common.Methodchannel.Result;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.Intentfilter;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), "batterysaver.flutter.dev/bluetooth").setMethodCallHandler();
        new MethodCallHndler () {
            @Override
            public void onMethodCall(MethodCall call, Result result){

            }
        }
  }
}
