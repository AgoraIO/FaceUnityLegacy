package io.agora.FUDemo.activities;

import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.faceunity.fulivedemo.ui.seekbar.DiscreteSeekBar;

import java.util.HashMap;

import io.agora.FUDemo.R;
import io.agora.FUDemo.view.EffectAndFilterSelectAdapter;
import io.agora.FUDemo.view.EffectPanel;

/**
 * Abstract activity which has FU UI, waiting sub activities
 * to implements how to deal with FU rendering parameters.
 */
public abstract class FUBaseActivity extends RTCBaseActivity
                implements View.OnClickListener, View.OnTouchListener {
    private final String TAG = "FUBaseUIActivity";

    protected Button mRecordingBtn;
    private int mRecordStatus = 0;

    protected TextView isCalibratingText;

    protected EffectPanel mEffectPanel;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_base);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WindowManager.LayoutParams params = getWindow().getAttributes();
        params.screenBrightness = 0.7f;
        getWindow().setAttributes(params);

        mRecordingBtn = (Button) findViewById(R.id.btn_recording);
        mRecordingBtn.setOnClickListener(this);
    }

    private HashMap<View, int[]> mTouchPointMap = new HashMap<>();

    @Override
    public boolean onTouch(View v, MotionEvent event) {
        int action = event.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN:
                int last_X = (int) event.getRawX();
                int last_Y = (int) event.getRawY();
                mTouchPointMap.put(v, new int[]{last_X, last_Y});
                break;
            case MotionEvent.ACTION_MOVE:
                int[] lastPoint = mTouchPointMap.get(v);
                if (lastPoint != null) {
                    int dx = (int) event.getRawX() - lastPoint[0];
                    int dy = (int) event.getRawY() - lastPoint[1];

                    int left = (int) v.getX() + dx;
                    int top = (int) v.getY() + dy;
                    v.setX(left);
                    v.setY(top);
                    lastPoint[0] = (int) event.getRawX();
                    lastPoint[1] = (int) event.getRawY();

                    mTouchPointMap.put(v, lastPoint);
                    v.getParent().requestLayout();
                }
                break;
            case MotionEvent.ACTION_UP:
                break;
        }
        return true;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.btn_choose_camera:
                onCameraChange();
                break;
            case R.id.btn_recording:
                if (mRecordStatus == 0) {
                    mRecordingBtn.setText(R.string.btn_stop_recording);
                    onStartRecording();
                    mRecordStatus ^= 1;
                } else {
                    mRecordingBtn.setText(R.string.btn_start_recording);
                    onStopRecording();
                    mRecordStatus ^= 1;
                }
                break;
        }
    }

    abstract protected void onCameraChange();

    abstract protected void onStartRecording();

    abstract protected void onStopRecording();
}
