package io.agora.FUDemo.activities;

import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;

import io.agora.FUDemo.RTCApplication;
import io.agora.FUDemo.EngineConfig;
import io.agora.FUDemo.MyRtcEngineEventHandler;
import io.agora.FUDemo.WorkerThread;
import io.agora.rtc.RtcEngine;

/**
 * Base activity enabling sub activities to communicate using
 * remote video calls.
 */
public abstract class RTCBaseActivity extends AppCompatActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ((RTCApplication) getApplication()).initWorkerThread();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        deInitUIAndEvent();
    }

    protected abstract void initUIAndEvent();

    protected abstract void deInitUIAndEvent();

    protected RtcEngine getRtcEngine() {
        return ((RTCApplication) getApplication()).getWorkerThread().getRtcEngine();
    }

    protected final WorkerThread getWorker() {
        return ((RTCApplication) getApplication()).getWorkerThread();
    }

    protected final EngineConfig getConfig() {
        return ((RTCApplication) getApplication()).getWorkerThread().getEngineConfig();
    }

    protected final MyRtcEngineEventHandler getEventHandler() {
        return ((RTCApplication) getApplication()).getWorkerThread().eventHandler();
    }
}
