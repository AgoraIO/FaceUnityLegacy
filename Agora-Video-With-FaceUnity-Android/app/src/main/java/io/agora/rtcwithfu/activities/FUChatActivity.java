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
import android.util.TypedValue;
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

import io.agora.rtc.RtcEngine;
import io.agora.rtc.mediaio.IVideoFrameConsumer;
import io.agora.rtc.mediaio.IVideoSource;
import io.agora.rtc.mediaio.MediaIO;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtc.video.VideoEncoderConfiguration;
import io.agora.rtcwithfu.Constants;
import io.agora.rtcwithfu.R;
import io.agora.rtcwithfu.RtcEngineEventHandler;
import io.agora.rtcwithfu.view.EffectPanel;

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

    private GLSurfaceView mGLSurfaceViewLocal;
    private FURenderer mFURenderer;
    private CameraRenderer mGLRenderer;

    private RelativeLayout mParentContainer;
    private FrameLayout mBigViewContainer;
    private FrameLayout mSmallViewContainer;
    private boolean mBigViewIsLocalVideo = true;
    private int mRemoteUid = -1;

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
        mParentContainer = findViewById(R.id.parent_container);

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

        mGLSurfaceViewLocal = new GLSurfaceView(this);
        mGLSurfaceViewLocal.setEGLContextClientVersion(2);
        mGLRenderer = new CameraRenderer(this, mGLSurfaceViewLocal, this);
        mGLSurfaceViewLocal.setRenderer(mGLRenderer);
        mGLSurfaceViewLocal.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        mDescriptionText = findViewById(R.id.effect_desc_text);
        mTrackingText = findViewById(R.id.iv_face_detect);

        mBigViewContainer = findViewById(R.id.big_video_view_container);
        if (mBigViewContainer.getChildCount() > 0) {
            mBigViewContainer.removeAllViews();
        }
        mBigViewContainer.addView(mGLSurfaceViewLocal,
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT);

        mSmallViewContainer = findViewById(R.id.small_video_view_container);
        mSmallViewContainer.setOnTouchListener(this);

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

    private void swapLocalRemoteDisplay() {
        if (mBigViewIsLocalVideo) {
            RelativeLayout.LayoutParams localParams = (RelativeLayout.LayoutParams) mBigViewContainer.getLayoutParams();
            localParams.height = convert(200);
            localParams.width = convert(150);
            localParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            localParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            localParams.rightMargin = convert(16);
            localParams.topMargin = convert(70);
            mBigViewContainer.setLayoutParams(localParams);

            mParentContainer.removeView(mSmallViewContainer);
            RelativeLayout.LayoutParams remoteParams = (RelativeLayout.LayoutParams) mSmallViewContainer.getLayoutParams();
            remoteParams.height = RelativeLayout.LayoutParams.MATCH_PARENT;
            remoteParams.width = RelativeLayout.LayoutParams.MATCH_PARENT;
            remoteParams.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            remoteParams.removeRule(RelativeLayout.ALIGN_PARENT_TOP);
            remoteParams.rightMargin = 0;
            remoteParams.topMargin = 0;
            mParentContainer.addView(mSmallViewContainer, 0, remoteParams);
            mSmallViewContainer.removeView(mRemoteSurfaceView);
            mRemoteSurfaceView.setZOrderMediaOverlay(false);
            mSmallViewContainer.addView(mRemoteSurfaceView);
        } else {
            RelativeLayout.LayoutParams localParams = (RelativeLayout.LayoutParams) mBigViewContainer.getLayoutParams();
            localParams.removeRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            localParams.removeRule(RelativeLayout.ALIGN_PARENT_TOP);
            localParams.height = RelativeLayout.LayoutParams.MATCH_PARENT;
            localParams.width = RelativeLayout.LayoutParams.MATCH_PARENT;
            localParams.rightMargin = 0;
            localParams.topMargin = 0;
            mBigViewContainer.setLayoutParams(localParams);

            mParentContainer.removeView(mSmallViewContainer);
            RelativeLayout.LayoutParams remoteParams = (RelativeLayout.LayoutParams) mSmallViewContainer.getLayoutParams();
            remoteParams.height = convert(200);
            remoteParams.width = convert(150);
            remoteParams.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
            remoteParams.addRule(RelativeLayout.ALIGN_PARENT_TOP);
            remoteParams.rightMargin = convert(16);
            remoteParams.topMargin = convert(70);
            mParentContainer.addView(mSmallViewContainer, 1, remoteParams);
            mSmallViewContainer.removeView(mRemoteSurfaceView);
            mRemoteSurfaceView.setZOrderMediaOverlay(true);
            mSmallViewContainer.addView(mRemoteSurfaceView);
        }
        mBigViewIsLocalVideo = !mBigViewIsLocalVideo;
    }

    private int convert(int dp) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, getResources().getDisplayMetrics());
    }


    private void addViewMatchParent(FrameLayout parent, View child) {
        int matchParent = FrameLayout.LayoutParams.MATCH_PARENT;
        parent.addView(child, matchParent, matchParent);
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

    private void onRemoteUserLeft() {
        FrameLayout remoteLayout = getRemoteLayout();
        remoteLayout.removeAllViews();
        mRemoteUid = -1;
    }

    private FrameLayout getRemoteLayout() {
        return mBigViewIsLocalVideo ? mSmallViewContainer : mBigViewContainer;
    }

    @Override
    public void onUserJoined(int uid, int elapsed) {

    }

    @Override
    public void onPreviewFrame(byte[] data, Camera camera) {
        camera.addCallbackBuffer(data);
        mGLSurfaceViewLocal.requestRender();
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

    private SurfaceView mRemoteSurfaceView;

    private void setupRemoteVideo(int uid) {
        mRemoteUid = uid;

        mRemoteSurfaceView = RtcEngine.CreateRendererView(getBaseContext());
        mRemoteSurfaceView.setZOrderMediaOverlay(true);

        // for mark purpose
        mRemoteSurfaceView.setTag(uid);

        getRtcEngine().setupRemoteVideo(new VideoCanvas(
                mRemoteSurfaceView, VideoCanvas.RENDER_MODE_HIDDEN, uid));

        getRemoteLayout().addView(mRemoteSurfaceView);
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
        // switchVideoView();
        swapLocalRemoteDisplay();
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
                mGLSurfaceViewLocal.queueEvent(new Runnable() {
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
