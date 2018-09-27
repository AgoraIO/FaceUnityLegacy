package io.agora.rtcwithfu;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import io.agora.AGApplication;
import io.agora.EngineConfig;
import io.agora.MyEngineEventHandler;
import io.agora.WorkerThread;
import io.agora.rtc.RtcEngine;

/**
 * Created by Yao Ximing on 2018/2/4.
 */

public abstract class AgoraBaseActivity extends AppCompatActivity {
    private final static String TAG = "AgoraBaseActivity";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ((AGApplication) getApplication()).initWorkerThread();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        deInitUIandEvent();
    }

    protected abstract void initUIandEvent();

    protected abstract void deInitUIandEvent();

    protected RtcEngine rtcEngine() {
        return ((AGApplication) getApplication()).getWorkerThread().getRtcEngine();
    }

    protected final WorkerThread worker() {
        return ((AGApplication) getApplication()).getWorkerThread();
    }

    protected final EngineConfig config() {
        return ((AGApplication) getApplication()).getWorkerThread().getEngineConfig();
    }

    protected final MyEngineEventHandler event() {
        return ((AGApplication) getApplication()).getWorkerThread().eventHandler();
    }
}
