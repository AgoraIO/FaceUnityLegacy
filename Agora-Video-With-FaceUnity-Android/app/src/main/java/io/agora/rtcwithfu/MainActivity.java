package io.agora.rtcwithfu;

import android.Manifest;
import android.app.Activity;
import android.app.ListActivity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.hardware.Camera;
import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.ListView;
import android.widget.SimpleAdapter;
import android.widget.Toast;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

import io.agora.Constants;

/**
 * This sample app demonstrates how to use FU SDK with Agora RTC SDK together
 * <p>
 * FU SDK does not couple with other SDKs
 * FU SDK receives video data, process it and product new video data
 * If you need sending processed video data to Agora SD-RTN, this is the just right sample for you
 * <p>
 * Activity为FUDualInputToTextureExampleActivity or FURenderToNV21ImageExampleActivity as the output for FU SDK and send data to Agora SD-RTN
 * <p>
 * Tips:
 * For more information for FU SDK, please checkout https://github.com/Faceunity/FULiveDemoDroid
 * For more information for Agora RTC SDK, please checkout https://github.com/AgoraIO/
 * For knowledge about Android Graphics, OpenGL ES or Camera, please checkout https://github.com/google/grafika
 */

public class MainActivity extends ListActivity {

    private static final String TAG = "MainActivity";

    // map keys
    private static final String TITLE = "title";
    private static final String DESCRIPTION = "description";
    private static final String CLASS_NAME = "class_name";

    private static final String[][] EXAMPLES = {
            {"fuDualInputToTexture",
                    "Dual-input, NV21/texture from camera, processed texture for outcome",
                    "FUDualInputToTextureExampleActivity"},
            {"fuRenderToNV21Image",
                    "Single-input, NV21 from camera, processed NV21 or texture for outcome",
                    "FURenderToNV21ImageExampleActivity"},
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        WindowManager.LayoutParams params = getWindow().getAttributes();
        params.screenBrightness = 0.7f;
        getWindow().setAttributes(params);

        setListAdapter(new SimpleAdapter(
                this,
                createActivityList(),
                android.R.layout.two_line_list_item,
                new String[]{TITLE, DESCRIPTION},
                new int[]{android.R.id.text1, android.R.id.text2}
        ));
    }

    /**
     * Creates the list of activities from the string arrays.
     */
    private List<Map<String, Object>> createActivityList() {
        List<Map<String, Object>> testList = new ArrayList<>();

        for (String[] example : EXAMPLES) {
            Map<String, Object> tmp = new HashMap<>();
            tmp.put(TITLE, example[0]);
            tmp.put(DESCRIPTION, example[1]);
            Intent intent = new Intent();
            // Do the class name resolution here, so we crash up front rather than when the
            // activity list item is selected if the class name is wrong.
            try {
                Class cls = Class.forName("io.agora.rtcwithfu." + example[2]);
                intent.setClass(this, cls);
                tmp.put(CLASS_NAME, intent);
            } catch (ClassNotFoundException cnfe) {
                throw new RuntimeException("Unable to find " + example[2], cnfe);
            }
            testList.add(tmp);
        }
        return testList;
    }

    @Override
    protected void onListItemClick(final ListView l, View v, final int position, long id) {
        super.onListItemClick(l, v, position, id);

        checkCameraPermission(this, new OnCameraAndAudioPermissionListener() {
            @Override
            public void onGrantResult(boolean granted) {
                Log.i(TAG, "onGrantResult " + granted);
                if (granted) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> map = (Map<String, Object>) l.getItemAtPosition(position);
                    Intent intent = (Intent) map.get(CLASS_NAME);
                    intent.putExtra(Constants.ACTION_KEY_ROOM_NAME, getIntent().getStringExtra(Constants.ACTION_KEY_ROOM_NAME));
                    startActivity(intent);

                    finish();
                }
            }
        });

        Log.i(TAG, "onListItemClick " + v + " " + position + " " + id);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        Log.i(TAG, "onRequestPermissionsResult " + Arrays.toString(permissions) + " " + Arrays.toString(grantResults));

        // now I just regard it as CAMERA

        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, getString(R.string.msg_permission_rejected),
                        Toast.LENGTH_SHORT).show();
                return;
            }
        }

        Toast.makeText(this, getString(R.string.msg_permission_granted),
                Toast.LENGTH_SHORT).show();
    }

    private static final int REQUEST_CODE_ALL_PERMISSIONS = 999;

    public static boolean checkCameraPermission(Context context, OnCameraAndAudioPermissionListener listener) {
        boolean granted = true;

        boolean needToDoRealTest = isFlyme() || Build.VERSION.SDK_INT < Build.VERSION_CODES.M;

        Log.i(TAG, "checkCameraPermission API Level " + Build.VERSION.SDK_INT + " " + needToDoRealTest);

        if (needToDoRealTest) {
            Camera mCamera = null;
            try {
                mCamera = Camera.open();
                Camera.Parameters mParameters = mCamera.getParameters();
                mCamera.setParameters(mParameters);
            } catch (Exception e) {
                granted = false;
                Log.i(TAG, Log.getStackTraceString(e));
            }
            if (mCamera != null) {
                mCamera.release();
            }

            AudioRecord mAudioRecord = null;
            try {
                mAudioRecord = new AudioRecord(MediaRecorder.AudioSource.MIC, 32000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, AudioRecord.getMinBufferSize(32000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT));
                mAudioRecord.startRecording();
            } catch (Exception e) {
                granted = false;
                Log.i(TAG, Log.getStackTraceString(e));
            }
            if (mAudioRecord != null) {
                mAudioRecord.stop();
                mAudioRecord.release();
            }

            File mFile = null;
            try {
                mFile = new File(Environment.getExternalStorageDirectory() + "/io.agora.rtcwithfu_test_per");
                mFile.createNewFile();
            } catch (Exception e) {
                granted = false;
                Log.i(TAG, Log.getStackTraceString(e));
            }
            if (mFile != null) {
                mFile.delete();
            }
        } else {
            granted = !(ContextCompat.checkSelfPermission((Activity) context, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission((Activity) context, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission((Activity) context, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED);
        }
        if (granted) {
            if (listener != null) {
                listener.onGrantResult(true);
            }
        } else {
            if (context instanceof Activity) {
                ActivityCompat.requestPermissions((Activity) context,
                        new String[]{Manifest.permission.CAMERA,
                                Manifest.permission.WRITE_EXTERNAL_STORAGE,
                                Manifest.permission.RECORD_AUDIO}, REQUEST_CODE_ALL_PERMISSIONS);
            }
        }
        return granted;
    }

    private static boolean isFlyme() {
        if (Build.FINGERPRINT.contains("Flyme")
                || Pattern.compile("Flyme", Pattern.CASE_INSENSITIVE).matcher(Build.DISPLAY).find()
                || Build.MANUFACTURER.contains("Meizu")
                || Build.BRAND.contains("MeiZu")) {
            return true;
        } else {
            return false;
        }
    }

    public interface OnCameraAndAudioPermissionListener {
        void onGrantResult(boolean granted);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
