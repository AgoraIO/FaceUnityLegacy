package io.agora.rtcwithfu.activities;

import android.content.Intent;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.net.Uri;
import android.opengl.EGL14;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.faceunity.FURenderer;
import com.faceunity.encoder.MediaAudioEncoder;
import com.faceunity.encoder.MediaEncoder;
import com.faceunity.encoder.MediaMuxerWrapper;
import com.faceunity.encoder.MediaVideoEncoder;
import com.faceunity.fulivedemo.renderer.CameraRenderer;
import com.faceunity.fulivedemo.ui.adapter.EffectRecyclerAdapter;
import com.faceunity.fulivedemo.utils.ToastUtil;
import com.faceunity.utils.Constant;
import com.faceunity.utils.MiscUtil;

import java.io.File;
import java.io.IOException;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import io.agora.rtcwithfu.Constants;
import io.agora.rtcwithfu.R;
import io.agora.rtcwithfu.RtcEngineEventHandler;
import io.agora.rtcwithfu.view.EffectPanel;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.mediaio.IVideoFrameConsumer;
import io.agora.rtc.mediaio.IVideoSource;
import io.agora.rtc.mediaio.MediaIO;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;

/**
 * This activity demonstrates how to make FU and Agora RTC SDK work together
 * <p>
 * The FU activity which possesses remote video chatting ability.
 */
@SuppressWarnings("deprecation")
public class FUChatActivity extends FUBaseActivity implements Camera.PreviewCallback, RtcEngineEventHandler,
        CameraRenderer.OnRendererStatusListener, SensorEventListener,
        FURenderer.OnFUDebugListener, FURenderer.OnTrackingStatusChangedListener,
        EffectRecyclerAdapter.OnDescriptionChangeListener {

    private final static String TAG = FUChatActivity.class.getSimpleName();

    private final static int DESC_SHOW_LENGTH = 1500;

    private GLSurfaceView mGLSurfaceView;
    private FURenderer mFURenderer;
    private CameraRenderer mGLRenderer;

    private FrameLayout mLocalViewContainer;

    private FrameLayout mRemoteViewContainer;

    private SurfaceView mGLRemoteSurfaceView;

    private TextView mDescriptionText;
    private TextView mTrackingText;

    private int mCameraOrientation;

    private IVideoFrameConsumer mIVideoFrameConsumer;
    private boolean mVideoFrameConsumerReady;

    private int showNum = 0;

    // Video recording related
    private long mVideoRecordingStartTime = 0;
    private String mVideoFileName;
    private MediaMuxerWrapper mMuxer;
    private MediaVideoEncoder mVideoEncoder;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initUIAndEvent();
    }

    protected void initUIAndEvent() {
        // The settings of FURender may be slightly different,
        // determined when initializing the effect panel
        mFURenderer = new FURenderer
                .Builder(this)
                .maxFaces(4)
                .createEGLContext(false)
                .needReadBackImage(false)
                .setOnFUDebugListener(this)
                .setOnTrackingStatusChangedListener(this)
                .inputTextureType(FURenderer.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE)
                .build();

        mGLSurfaceView = (GLSurfaceView) findViewById(R.id.local_surface_view);
        mGLSurfaceView.setEGLContextClientVersion(2);
        mGLRenderer = new CameraRenderer(this, mGLSurfaceView, this);
        mGLSurfaceView.setRenderer(mGLRenderer);
        mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        mDescriptionText = (TextView) findViewById(R.id.effect_desc_text);
        mTrackingText = (TextView) findViewById(R.id.iv_face_detect);

        mLocalViewContainer = (FrameLayout) findViewById(R.id.local_video_view_container);

        mRemoteViewContainer = (FrameLayout) findViewById(R.id.remote_video_view_container);
        mRemoteViewContainer.setOnTouchListener(this);

        mEffectPanel = new EffectPanel(findViewById(R.id.effect_container), mFURenderer, this);

        getEventHandler().addEventHandler(this);
        joinChannel();
    }

    private void joinChannel() {
        getRtcEngine().setClientRole(io.agora.rtc.Constants.CLIENT_ROLE_BROADCASTER);
        getRtcEngine().setVideoEncoderConfiguration(new VideoEncoderConfiguration(
                VideoEncoderConfiguration.VD_480x360,
                VideoEncoderConfiguration.FRAME_RATE.FRAME_RATE_FPS_15, 400,
                VideoEncoderConfiguration.ORIENTATION_MODE.ORIENTATION_MODE_FIXED_PORTRAIT));

        String roomName = getIntent().getStringExtra(Constants.ACTION_KEY_ROOM_NAME);
        getWorker().joinChannel(roomName, getConfig().mUid);
    }

    private void switchVideoView() {
        if (mRemoteViewContainer.getChildCount() == 0) {
            return;
        }

        // TODO Support switch view
        if (mLocalViewContainer.getTag(97839220) != null) {

            RelativeLayout.LayoutParams rParams = (RelativeLayout.LayoutParams) mRemoteViewContainer.getLayoutParams();
            RelativeLayout.LayoutParams lParams = (RelativeLayout.LayoutParams) mLocalViewContainer.getLayoutParams();

//        mRemoteViewContainer.getLayoutParams().height = RelativeLayout.LayoutParams.MATCH_PARENT;
//        mRemoteViewContainer.getLayoutParams().width = RelativeLayout.LayoutParams.MATCH_PARENT;
//        mRemoteViewContainer.requestLayout();

            mLocalViewContainer.setOnTouchListener(null);
            mRemoteViewContainer.setOnTouchListener(this);

            mRemoteViewContainer.setLayoutParams(rParams);
            mLocalViewContainer.setLayoutParams(lParams);

            mRemoteViewContainer.requestLayout();
            mLocalViewContainer.requestLayout();

            mGLRemoteSurfaceView.setZOrderMediaOverlay(true);
            mGLRemoteSurfaceView.setZOrderOnTop(true);
            mGLRemoteSurfaceView.bringToFront();

//            mRemoteViewContainer.bringChildToFront(mGLSurfaceView);
//            mRemoteViewContainer.bringToFront();

            mLocalViewContainer.setTag(97839220, null);
        } else {
            RelativeLayout.LayoutParams rParams = (RelativeLayout.LayoutParams) mRemoteViewContainer.getLayoutParams();
            RelativeLayout.LayoutParams lParams = (RelativeLayout.LayoutParams) mLocalViewContainer.getLayoutParams();

//        mRemoteViewContainer.getLayoutParams().height = RelativeLayout.LayoutParams.MATCH_PARENT;
//        mRemoteViewContainer.getLayoutParams().width = RelativeLayout.LayoutParams.MATCH_PARENT;
//        mRemoteViewContainer.requestLayout();

            mRemoteViewContainer.setOnTouchListener(null);
            mLocalViewContainer.setOnTouchListener(this);

            RelativeLayout.LayoutParams tmpParams = new RelativeLayout.LayoutParams(rParams.width, rParams.height);
            mLocalViewContainer.setLayoutParams(tmpParams);
            mRemoteViewContainer.setLayoutParams(lParams);

            mLocalViewContainer.getParent().requestLayout();
            mRemoteViewContainer.getParent().requestLayout();

            mLocalViewContainer.bringToFront();
            mLocalViewContainer.bringChildToFront(mGLSurfaceView);

            mGLRemoteSurfaceView.setZOrderMediaOverlay(false);
            mGLRemoteSurfaceView.setZOrderOnTop(false);

            mGLSurfaceView.setZOrderMediaOverlay(true);
            mGLSurfaceView.setZOrderOnTop(true);

            mLocalViewContainer.setTag(97839220, 8888);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        setRtcVideos();

        mGLRenderer.onCreate();
        mGLRenderer.onResume();
    }

    private void setRtcVideos() {
        IVideoSource source = new IVideoSource() {
            @Override
            public boolean onInitialize(IVideoFrameConsumer iVideoFrameConsumer) {
                FUChatActivity.this.mIVideoFrameConsumer = iVideoFrameConsumer;
                return true;
            }

            @Override
            public boolean onStart() {
                FUChatActivity.this.mVideoFrameConsumerReady = true;
                return true;
            }

            @Override
            public void onStop() {
                FUChatActivity.this.mVideoFrameConsumerReady = false;
            }

            @Override
            public void onDispose() {
                FUChatActivity.this.mVideoFrameConsumerReady = false;
            }

            @Override
            public int getBufferType() {
                // Different PixelFormat should use different BufferType
                // If you choose TEXTURE_2D/TEXTURE_OES, you should use BufferType.TEXTURE
                return MediaIO.BufferType.BYTE_ARRAY.intValue();
            }
        };

        getWorker().setVideoSource(source);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mGLRenderer.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mGLRenderer.onDestroy();
    }

    @Override
    protected void deInitUIAndEvent() {
        getEventHandler().removeEventHandler(this);
        getWorker().leaveChannel(getConfig().mChannel);
    }

    @Override
    public void onJoinChannelSuccess(String channel, int uid, int elapsed) {

    }

    @Override
    public void onUserOffline(int uid, int reason) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                onRemoteUserLeft();
            }
        });
    }

    @Override
    public void onUserJoined(int uid, int elapsed) {

    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        camera.addCallbackBuffer(data);
        mGLSurfaceView.requestRender();
    }

    private void setupRemoteVideo(int uid) {
        if (mRemoteViewContainer.getChildCount() >= 1) {
            // Supports only one remote video
            return;
        }

        mGLRemoteSurfaceView = RtcEngine.CreateRendererView(getBaseContext());
        mGLRemoteSurfaceView.setZOrderMediaOverlay(true);

        mRemoteViewContainer.addView(mGLRemoteSurfaceView);

        getRtcEngine().setupRemoteVideo(new VideoCanvas(mGLRemoteSurfaceView,
                VideoCanvas.RENDER_MODE_HIDDEN, uid));

        // for mark purpose
        mGLRemoteSurfaceView.setTag(uid);
    }

    private void onRemoteUserLeft() {
        // TODO Support switch view
        if (mRemoteViewContainer.getChildCount() > 0
                && mGLSurfaceView == mRemoteViewContainer.getChildAt(0)) { // switch back if switched view before
            mLocalViewContainer.removeAllViews();
            mGLSurfaceView.setZOrderMediaOverlay(false);
            mLocalViewContainer.addView(mGLSurfaceView);
        }

        mRemoteViewContainer.removeAllViews();
    }

    @Override
    public void onFirstRemoteVideoDecoded(final int uid, int width, int height, int elapsed) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setupRemoteVideo(uid);
            }
        });
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        Log.i(TAG, "onSurfaceCreated: " + gl + " " + config);

        mFURenderer.onSurfaceCreated();
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        Log.i(TAG, "onSurfaceChanged: " + gl + " " + width + " " + height);
    }

    @Override
    public int onDrawFrame(byte[] cameraNV21Byte, int cameraTextureId, int cameraWidth, int cameraHeight, float[] mtx, long timeStamp) {
        int fuTextureId;
        // if (isDoubleInputType) {
        // fuTextureId = mFURenderer.onDrawFrame(cameraNV21Byte, cameraTextureId, cameraWidth, cameraHeight);
        byte[] backImage = new byte[cameraNV21Byte.length];
        fuTextureId = mFURenderer.onDrawFrame(cameraNV21Byte, cameraTextureId,
                cameraWidth, cameraHeight, backImage, cameraWidth, cameraHeight);

        if (mVideoFrameConsumerReady) {
            mIVideoFrameConsumer.consumeByteArrayFrame(backImage,
                    MediaIO.PixelFormat.NV21.intValue(), cameraWidth,
                    cameraHeight, mCameraOrientation, System.currentTimeMillis());
        }

        //} else {
        //    if (mFuNV21Byte == null) {
        //        mFuNV21Byte = new byte[cameraNV21Byte.length];
        //    }
        //    System.arraycopy(cameraNV21Byte, 0, mFuNV21Byte, 0, cameraNV21Byte.length);
        //    fuTextureId = mFURenderer.onDrawFrame(mFuNV21Byte, cameraWidth, cameraHeight);
        //}
        sendRecordingData(fuTextureId, mtx, timeStamp / Constant.NANO_IN_ONE_MILLI_SECOND);
        //checkPic(fuTextureId, mtx, cameraHeight, cameraWidth);
        return fuTextureId;
    }

    @Override
    public void onSurfaceDestroy() {
        Log.i(TAG, "onSurfaceDestroy");
        mFURenderer.onSurfaceDestroyed();
    }

    @Override
    public void onCameraChange(int currentCameraType, int cameraOrientation) {
        mFURenderer.onCameraChange(currentCameraType, cameraOrientation);
        mCameraOrientation = cameraOrientation;
    }

    @Override
    public void onSensorChanged(SensorEvent event) {

    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    @Override
    public void onTrackingStatusChanged(final int status) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mTrackingText.setVisibility(status > 0 ? View.GONE : View.VISIBLE);
            }
        });
    }

    @Override
    public void onFpsChange(double fps, double renderTime) {

    }

    @Override
    public void onDescriptionChangeListener(int description) {
        showDescription(description, DESC_SHOW_LENGTH);
    }

    protected void showDescription(int str, int time) {
        if (str == 0) {
            return;
        }
        mDescriptionText.removeCallbacks(effectDescriptionHide);
        mDescriptionText.setVisibility(View.VISIBLE);
        mDescriptionText.setText(str);
        mDescriptionText.postDelayed(effectDescriptionHide, time);
    }

    private Runnable effectDescriptionHide = new Runnable() {
        @Override
        public void run() {
            mDescriptionText.setText("");
            mDescriptionText.setVisibility(View.INVISIBLE);
        }
    };

    @Override
    protected void onViewSwitchRequested() {
        switchVideoView();
    }

    @Override
    protected void onCameraChangeRequested() {
        mGLRenderer.changeCamera();
    }

    @Override
    protected void onStartRecordingRequested() {
        startRecording();
    }

    @Override
    protected void onStopRecordingRequested() {
        stopRecording();
    }

    private final MediaEncoder.MediaEncoderListener mMediaEncoderListener = new MediaEncoder.MediaEncoderListener() {
        @Override
        public void onPrepared(final MediaEncoder encoder) {
            if (encoder instanceof MediaVideoEncoder) {
                final MediaVideoEncoder videoEncoder = (MediaVideoEncoder) encoder;
                mGLSurfaceView.queueEvent(new Runnable() {
                    @Override
                    public void run() {
                        videoEncoder.setEglContext(EGL14.eglGetCurrentContext());
                        mVideoEncoder = videoEncoder;
                    }
                });
            }
        }

        @Override
        public void onStopped(final MediaEncoder encoder) {
            mVideoEncoder = null;
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ToastUtil.showToast(FUChatActivity.this, R.string.save_video_success);
                    sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE,
                            Uri.fromFile(new File(mVideoFileName))));
                }
            });
        }
    };

    private void startRecording() {
        try {
            String videoFileName = Constant.APP_NAME + "_" + MiscUtil.getCurrentDate() + ".mp4";
            mVideoFileName = new File(Constant.cameraFilePath, videoFileName).getAbsolutePath();
            mMuxer = new MediaMuxerWrapper(mVideoFileName);

            // for video capturing
            new MediaVideoEncoder(mMuxer, mMediaEncoderListener,
                    mGLRenderer.getCameraHeight(), mGLRenderer.getCameraWidth());
            new MediaAudioEncoder(mMuxer, mMediaEncoderListener);

            mMuxer.prepare();
            mMuxer.startRecording();
        } catch (final IOException e) {
            Log.e(TAG, "startCapture:", e);
        }
    }

    protected void sendRecordingData(int texId, final float[] tex_matrix, final long timeStamp) {
        if (mVideoEncoder != null) {
            mVideoEncoder.frameAvailableSoon(texId, tex_matrix);
            if (mVideoRecordingStartTime == 0) mVideoRecordingStartTime = timeStamp;
        }
    }

    private void stopRecording() {
        if (mMuxer != null) {
            mMuxer.stopRecording();
        }
        System.gc();
    }

    private Runnable mCalibratingRunnable = new Runnable() {
        @Override
        public void run() {
            showNum++;
            StringBuilder builder = new StringBuilder();
            builder.append(getResources().getString(R.string.expression_calibrating));
            for (int i = 0; i < showNum; i++) {
                builder.append(".");
            }
            isCalibratingText.setText(builder);
            if (showNum < 6) {
                isCalibratingText.postDelayed(mCalibratingRunnable, 500);
            } else {
                isCalibratingText.setVisibility(View.INVISIBLE);
            }
        }
    };
}
