package io.agora.rtcwithfu;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.opengl.EGL14;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.faceunity.authpack;
import com.faceunity.encoder.TextureMovieEncoder;
import com.faceunity.gles.FullFrameRect;
import com.faceunity.gles.LandmarksPoints;
import com.faceunity.gles.Texture2dProgram;
import com.faceunity.utils.CameraUtils;
import com.faceunity.utils.FPSUtil;
import com.faceunity.utils.MiscUtil;
import com.faceunity.wrapper.faceunity;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.Arrays;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import io.agora.AGEventHandler;
import io.agora.Constants;
import io.agora.rtc.RtcEngine;
import io.agora.rtc.mediaio.IVideoFrameConsumer;
import io.agora.rtc.mediaio.IVideoSink;
import io.agora.rtc.mediaio.IVideoSource;
import io.agora.rtc.mediaio.MediaIO;
import io.agora.rtc.mediaio.SurfaceTextureHelper;
import io.agora.rtc.video.VideoCanvas;
import io.agora.rtcwithfu.view.AspectFrameLayout;
import io.agora.rtcwithfu.view.EffectAndFilterSelectAdapter;

import static com.faceunity.encoder.TextureMovieEncoder.IN_RECORDING;
import static com.faceunity.encoder.TextureMovieEncoder.START_RECORDING;

/**
 * This activity demonstrates how to make FU and Agora RTC SDK work together
 * <p>
 * Created by lirui on 2016/12/13.
 */

@SuppressWarnings("deprecation")
public abstract class RTCWithFUExampleActivity extends FUBaseUIActivity
        implements Camera.PreviewCallback, AGEventHandler {

    protected abstract int draw(byte[] cameraNV21Byte, byte[] fuImgNV21Bytes, int cameraTextureId, int cameraWidth, int cameraHeight, int frameId, int[] ints, int currentCameraType);

    protected abstract byte[] getFuImgNV21Bytes();

    public final static String TAG = RTCWithFUExampleActivity.class.getSimpleName();

    private Context mContext;

    private GLSurfaceView mGLSurfaceView;
    private GLRenderer mGLRenderer;
    private int mViewWidth;
    private int mViewHeight;

    private Camera mCamera;
    private int mCurrentCameraType = Camera.CameraInfo.CAMERA_FACING_FRONT;
    private int mCameraOrientation;
    private int mCameraWidth = 1280;
    private int mCameraHeight = 720;

    private SurfaceTextureHelper mSurfaceTextureHelper;

    private static final int PREVIEW_BUFFER_COUNT = 3;
    private byte[][] previewCallbackBuffer;

    private byte[] mCameraNV21Byte;
    private byte[] mFuImgNV21Bytes;

    private int mFrameId = 0;

    private int mFaceBeautyItem = 0; // Face beauty
    private int mEffectItem = 0; // Effect/Sticky

    private float mFilterLevel = 1.0f;
    private float mFaceBeautyColorLevel = 0.2f;
    private float mFaceBeautyBlurLevel = 6.0f;
    private float mFaceBeautyALLBlurLevel = 0.0f;
    private float mFaceBeautyCheekThin = 1.0f;
    private float mFaceBeautyEnlargeEye = 0.5f;
    private float mFaceBeautyRedLevel = 0.5f;
    private int mFaceShape = 3;
    private float mFaceShapeLevel = 0.5f;

    private String mFilterName = EffectAndFilterSelectAdapter.FILTERS_NAME[0];

    private boolean isNeedEffectItem = true;
    private String mEffectFileName = EffectAndFilterSelectAdapter.EFFECT_ITEM_FILE_NAME[1];

    private TextureMovieEncoder mTextureMovieEncoder;
    private String mVideoFileName;

    private HandlerThread mCreateItemThread;
    private Handler mCreateItemHandler;

    private boolean isInPause = true;

    private boolean isInAvatarMode = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.i(TAG, "onCreate");
        mContext = getBaseContext();
        super.onCreate(savedInstanceState);

        mGLSurfaceView = (GLSurfaceView) findViewById(R.id.glsv);
        mGLSurfaceView.setEGLContextClientVersion(2);
        mGLRenderer = new GLRenderer();
        mGLSurfaceView.setRenderer(mGLRenderer);
        mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        mCreateItemThread = new HandlerThread("CreateItemThread");
        mCreateItemThread.start();
        mCreateItemHandler = new CreateItemHandler(mCreateItemThread.getLooper());

        initUIandEvent();
    }

    @Override
    protected void onResume() {
        Log.i(TAG, "onResume " + mCurrentCameraType);

        super.onResume();

        openCamera(mCurrentCameraType, mCameraWidth, mCameraHeight);

        mGLSurfaceView.onResume();

        setConfig();
    }

    @Override
    protected void onPause() {
        Log.i(TAG, "onPause");

        super.onPause();

        mCreateItemHandler.removeMessages(CreateItemHandler.HANDLE_CREATE_ITEM);

        releaseCamera();

        mGLSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mGLRenderer.notifyPause();
                mGLRenderer.destroySurfaceTexture();

                mEffectItem = 0;
                mFaceBeautyItem = 0;
                // Note: Never use a destroyed item
                faceunity.fuDestroyAllItems();
                isNeedEffectItem = true;
                faceunity.fuOnDeviceLost();
                mFrameId = 0;
            }
        });

        mGLSurfaceView.onPause();

        FPSUtil.reset();
    }

    private void setConfig() {

        IVideoSource source = new IVideoSource() {

            @Override
            public boolean onInitialize(IVideoFrameConsumer iVideoFrameConsumer) {
                RTCWithFUExampleActivity.this.mIVideoFrameConsumer = iVideoFrameConsumer;
                return true;
            }

            @Override
            public boolean onStart() {
                RTCWithFUExampleActivity.this.mVideoFrameConsumerReady = true;
                return true;
            }

            @Override
            public void onStop() {
                RTCWithFUExampleActivity.this.mVideoFrameConsumerReady = false;
            }

            @Override
            public void onDispose() {
                RTCWithFUExampleActivity.this.mVideoFrameConsumerReady = false;
            }

            @Override
            public int getBufferType() {
                // Different PixelFormat should use different BufferType
                // If you choose TEXTURE_2D/TEXTURE_OES, you should use BufferType.TEXTURE
                return MediaIO.BufferType.BYTE_ARRAY.intValue();
            }
        };
        worker().setVideoSource(source);

        worker().setLocalVideoRenderer(new IVideoSink() {
            @Override
            public boolean onInitialize() {
                return true;
            }

            @Override
            public boolean onStart() {
                return true;
            }

            @Override
            public void onStop() {

            }

            @Override
            public void onDispose() {

            }

            @Override
            public long getEGLContextHandle() {
                return 0;
            }

            @Override
            public int getBufferType() {
                return 0;
            }

            @Override
            public int getPixelFormat() {
                return 0;
            }

            @Override
            public void consumeByteBufferFrame(ByteBuffer byteBuffer, int i, int i1, int i2, int i3, long l) {

            }

            @Override
            public void consumeByteArrayFrame(byte[] bytes, int i, int i1, int i2, int i3, long l) {

            }

            @Override
            public void consumeTextureFrame(int i, int i1, int i2, int i3, int i4, long l, float[] floats) {

            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        Log.i(TAG, "onDestroy");
        mEffectFileName = EffectAndFilterSelectAdapter.EFFECT_ITEM_FILE_NAME[1];

        mCreateItemThread.quitSafely();
        mCreateItemThread = null;
        mCreateItemHandler = null;
    }

    private IVideoFrameConsumer mIVideoFrameConsumer;
    private boolean mVideoFrameConsumerReady;

    @Override
    protected void initUIandEvent() {
        event().addEventHandler(this);

        String roomName = getIntent().getStringExtra(Constants.ACTION_KEY_ROOM_NAME);

        worker().configEngine(io.agora.rtc.Constants.CLIENT_ROLE_BROADCASTER
                , Constants.VIDEO_PROFILES[Constants.DEFAULT_PROFILE_IDX]);

        worker().joinChannel(roomName, config().mUid);

        RelativeLayout container = (RelativeLayout) findViewById(R.id.remote_video_view_container);
        container.setOnTouchListener(this);
    }

    @Override
    protected void deInitUIandEvent() {
        worker().leaveChannel(config().mChannel);

        event().removeEventHandler(this);
    }

    private void setupRemoteVideo(int uid) {
        RelativeLayout container = (RelativeLayout) findViewById(R.id.remote_video_view_container);

        if (container.getChildCount() >= 1) {
            return;
        }

        SurfaceView surfaceView = RtcEngine.CreateRendererView(getBaseContext());
        surfaceView.setZOrderMediaOverlay(true);
        container.addView(surfaceView);
        rtcEngine().setupRemoteVideo(new VideoCanvas(surfaceView, VideoCanvas.RENDER_MODE_ADAPTIVE, uid));

        surfaceView.setTag(uid); // for mark purpose
    }

    private void onRemoteUserLeft() {
        RelativeLayout container = (RelativeLayout) findViewById(R.id.remote_video_view_container);
        container.removeAllViews();
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
        mCameraNV21Byte = data;
        mCamera.addCallbackBuffer(data);
        isInPause = false;
    }

    class GLRenderer implements GLSurfaceView.Renderer {

        FullFrameRect mFullScreenFUDisplay;
        FullFrameRect mCameraDisplay;

        int mCameraTextureId;
        SurfaceTexture mCameraSurfaceTexture;

        int faceTrackingStatus = 0;
        int systemErrorStatus = 0; // success number
        float[] isCalibrating = new float[1];

        LandmarksPoints landmarksPoints;
        float[] landmarksData = new float[150];
        float[] expressionData = new float[46];
        float[] rotationData = new float[4];
        float[] pupilPosData = new float[2];
        float[] rotationModeData = new float[1];

        int fuTex;
        final float[] mtx = new float[16];

        @Override
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            Log.i(TAG, "onSurfaceCreated fu version " + faceunity.fuGetVersion());

            mFullScreenFUDisplay = new FullFrameRect(new Texture2dProgram(
                    Texture2dProgram.ProgramType.TEXTURE_2D));
            mCameraDisplay = new FullFrameRect(new Texture2dProgram(
                    Texture2dProgram.ProgramType.TEXTURE_EXT));
            mCameraTextureId = mCameraDisplay.createTextureObject();

            landmarksPoints = new LandmarksPoints(); // Can calculate and draw face landmarks when certificate is valid

            switchCameraSurfaceTexture();

            try {
                InputStream is = getAssets().open("v3.bundle");
                byte[] v3data = new byte[is.available()];
                int len = is.read(v3data);
                is.close();
                faceunity.fuSetup(v3data, null, authpack.A());
                // faceunity.fuSetMaxFaces(1); // Set max faces for SDK
                Log.i(TAG, "fuSetup v3 len " + len);

                is = getAssets().open("anim_model.bundle");
                byte[] animModelData = new byte[is.available()];
                is.read(animModelData);
                is.close();
                faceunity.fuLoadAnimModel(animModelData);
                faceunity.fuSetExpressionCalibration(1);

                is = getAssets().open("face_beautification.bundle");
                byte[] itemData = new byte[is.available()];
                len = is.read(itemData);
                Log.i(TAG, "beautification len " + len);
                is.close();
                mFaceBeautyItem = faceunity.fuCreateItemFromPackage(itemData);

            } catch (IOException e) {
                e.printStackTrace();
            }

        }

        @Override
        public void onSurfaceChanged(GL10 gl, int width, int height) {
            Log.i(TAG, "onSurfaceChanged " + width + " " + height);
            GLES20.glViewport(0, 0, width, height);
            mViewWidth = width;
            mViewHeight = height;
        }

        @Override
        public void onDrawFrame(GL10 gl) {

            FPSUtil.fps(TAG);

            if (isInPause) {
                mFullScreenFUDisplay.drawFrame(fuTex, mtx);
                mGLSurfaceView.requestRender();
                return;
            }

            /**
             * Update texture when Camera data available
             */
            try {
                mCameraSurfaceTexture.updateTexImage();
                mCameraSurfaceTexture.getTransformMatrix(mtx);
            } catch (Exception e) {
                e.printStackTrace();
            }

            final int isTracking = faceunity.fuIsTracking();
            if (isTracking != faceTrackingStatus) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if (isTracking == 0) {
                            mFaceTrackingStatusTextView.setText(R.string.fu_base_is_tracking_text);
                            mFaceTrackingStatusTextView.setVisibility(View.VISIBLE);
                            Arrays.fill(landmarksData, 0);
                        } else {
                            mFaceTrackingStatusTextView.setVisibility(View.INVISIBLE);
                        }
                    }
                });
                faceTrackingStatus = isTracking;
            }

            final int systemError = faceunity.fuGetSystemError();
            if (systemError != systemErrorStatus) {
                systemErrorStatus = systemError;
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Log.e(TAG, "system error " + systemError + " " + faceunity.fuGetSystemErrorString(systemError));
                        tvSystemError.setText(faceunity.fuGetSystemErrorString(systemError));
                    }
                });
            }

            if (isNeedEffectItem) {
                isNeedEffectItem = false;
                mCreateItemHandler.sendMessage(Message.obtain(mCreateItemHandler, CreateItemHandler.HANDLE_CREATE_ITEM, mEffectFileName));
            }

            faceunity.fuItemSetParam(mFaceBeautyItem, "filter_level", mFilterLevel);
            faceunity.fuItemSetParam(mFaceBeautyItem, "color_level", mFaceBeautyColorLevel);
            faceunity.fuItemSetParam(mFaceBeautyItem, "blur_level", mFaceBeautyBlurLevel);
            faceunity.fuItemSetParam(mFaceBeautyItem, "skin_detect", mFaceBeautyALLBlurLevel);
            faceunity.fuItemSetParam(mFaceBeautyItem, "filter_name", mFilterName);
            faceunity.fuItemSetParam(mFaceBeautyItem, "cheek_thinning", mFaceBeautyCheekThin);
            faceunity.fuItemSetParam(mFaceBeautyItem, "eye_enlarging", mFaceBeautyEnlargeEye);
            faceunity.fuItemSetParam(mFaceBeautyItem, "face_shape", mFaceShape);
            faceunity.fuItemSetParam(mFaceBeautyItem, "face_shape_level", mFaceShapeLevel);
            faceunity.fuItemSetParam(mFaceBeautyItem, "red_level", mFaceBeautyRedLevel);

            if (mCameraNV21Byte == null || mCameraNV21Byte.length == 0) {
                Log.e(TAG, "camera nv21 bytes null");
                mGLSurfaceView.requestRender();
                return;
            }

            if (isInAvatarMode) {
                /**
                 * fuTrackFace and fuAvatarToTexture are recommended for Avatar sticky/effect
                 */
                fuTex = drawAvatar();
            } else {
                fuTex = draw(mCameraNV21Byte, mFuImgNV21Bytes, mCameraTextureId, mCameraWidth, mCameraHeight, mFrameId++, new int[]{mFaceBeautyItem, mEffectItem}, mCurrentCameraType);
            }

            mFullScreenFUDisplay.drawFrame(fuTex, mtx);

            /**
             * Draw preview from camera and landmarks for Avatar sticky/effect
             **/
            if (isInAvatarMode) {
                int[] originalViewport = new int[4];
                GLES20.glGetIntegerv(GLES20.GL_VIEWPORT, originalViewport, 0);
                GLES20.glViewport(0, mViewHeight * 2 / 3, mViewWidth / 3, mViewHeight / 3);
                mCameraDisplay.drawFrame(mCameraTextureId, mtx);
                landmarksPoints.draw();
                GLES20.glViewport(originalViewport[0], originalViewport[1], originalViewport[2], originalViewport[3]);
            }

            final float[] isCalibratingTmp = new float[1];
            faceunity.fuGetFaceInfo(0, "is_calibrating", isCalibratingTmp);
            if (isCalibrating[0] != isCalibratingTmp[0]) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if ((isCalibrating[0] = isCalibratingTmp[0]) > 0 && EffectAndFilterSelectAdapter.EFFECT_ITEM_FILE_NAME[6].equals(mEffectFileName)) {
                            isCalibratingText.setVisibility(View.VISIBLE);
                            isCalibratingText.setText(R.string.expression_calibrating);
                            showNum = 0;
                            isCalibratingText.postDelayed(mCalibratingRunnable, 500);
                        } else {
                            isCalibratingText.removeCallbacks(mCalibratingRunnable);
                            isCalibratingText.setVisibility(View.GONE);
                        }
                    }
                });
            }

            if (mTextureMovieEncoder != null && mTextureMovieEncoder.checkRecordingStatus(START_RECORDING)) {
                mVideoFileName = MiscUtil.createFileName() + "_camera.mp4";
                File outFile = new File(mVideoFileName);
                mTextureMovieEncoder.startRecording(new TextureMovieEncoder.EncoderConfig(
                        outFile, mCameraHeight, mCameraWidth,
                        3000000, EGL14.eglGetCurrentContext(), mCameraSurfaceTexture.getTimestamp()
                ));
                mTextureMovieEncoder.setTextureId(mFullScreenFUDisplay, fuTex, mtx);
                // forbid click until start or stop success
                mTextureMovieEncoder.setOnEncoderStatusUpdateListener(new TextureMovieEncoder.OnEncoderStatusUpdateListener() {
                    @Override
                    public void onStartSuccess() {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.i(TAG, "start encoder success");
                                mRecordingBtn.setVisibility(View.VISIBLE);
                            }
                        });
                    }

                    @Override
                    public void onStopSuccess() {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.i(TAG, "stop encoder success");
                                mRecordingBtn.setVisibility(View.VISIBLE);
                            }
                        });
                    }
                });

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(mContext, "video file saved to "
                                + mVideoFileName, Toast.LENGTH_SHORT).show();
                    }
                });
            }

            if (mTextureMovieEncoder != null && mTextureMovieEncoder.checkRecordingStatus(IN_RECORDING)) {
                mTextureMovieEncoder.setTextureId(mFullScreenFUDisplay, fuTex, mtx);
                mTextureMovieEncoder.frameAvailable(mCameraSurfaceTexture);
            }

            mGLSurfaceView.requestRender();

            float[] transformMatrix = new float[]{
                    1.0f, 0.0f, 0.0f, 0.0f,
                    0.0f, 1.0f, 0.0f, 0.0f,
                    0.0f, 0.0f, 1.0f, 0.0f,
                    0.0f, 0.0f, 0.0f, 1.0f
            };

            if (mVideoFrameConsumerReady) {
                // If data input type is OES Texture(always from camera)
                // mIVideoFrameConsumer.consumeTextureFrame(mCameraTextureId, MediaIO.PixelFormat.TEXTURE_OES.intValue(), mCameraWidth, mCameraHeight, 270, System.currentTimeMillis(), transformMatrix);

                // If data input type is Texture2D(always processed by face beatification sdk)
                // mIVideoFrameConsumer.consumeTextureFrame(fuTex, MediaIO.PixelFormat.TEXTURE_2D.intValue(), mCameraWidth, mCameraHeight, 270, System.currentTimeMillis(), transformMatrix);

                // If data input type is raw data(byte array, may processed by face beatification sdk)
                mIVideoFrameConsumer.consumeByteArrayFrame(getFuImgNV21Bytes(), MediaIO.PixelFormat.NV21.intValue(), mCameraWidth, mCameraHeight, mCameraOrientation, System.currentTimeMillis());

                // If data input type is raw data(byte array, may from camera)
                // mIVideoFrameConsumer.consumeByteArrayFrame(mCameraNV21Byte, MediaIO.PixelFormat.NV21.intValue(), mCameraWidth, mCameraHeight, 90, System.currentTimeMillis());
            }
        }

        int drawAvatar() {
            faceunity.fuTrackFace(mCameraNV21Byte, 0, mCameraWidth, mCameraHeight);

            /**
             * landmarks
             */
            Arrays.fill(landmarksData, 0.0f);
            faceunity.fuGetFaceInfo(0, "landmarks", landmarksData);
            if (landmarksPoints != null) {
                landmarksPoints.refresh(landmarksData, mCameraWidth, mCameraHeight, mCameraOrientation, mCurrentCameraType);
            }

            /**
             *rotation
             */
            Arrays.fill(rotationData, 0.0f);
            faceunity.fuGetFaceInfo(0, "rotation", rotationData);
            /**
             * expression
             */
            Arrays.fill(expressionData, 0.0f);
            faceunity.fuGetFaceInfo(0, "expression", expressionData);

            /**
             * pupil pos
             */
            Arrays.fill(pupilPosData, 0.0f);
            faceunity.fuGetFaceInfo(0, "pupil_pos", pupilPosData);

            /**
             * rotation mode
             */
            Arrays.fill(rotationModeData, 0.0f);
            faceunity.fuGetFaceInfo(0, "rotation_mode", rotationModeData);

            int isTracking = faceunity.fuIsTracking();

            // rotation is a 4-element unit, if not available, use 1,0,0,0
            if (isTracking <= 0) {
                rotationData[3] = 1.0f;
            }

            /**
             * adjust rotation mode
             */
            if (isTracking <= 0) {
                rotationModeData[0] = (360 - mCameraOrientation) / 90;
            }

            return faceunity.fuAvatarToTexture(pupilPosData,
                    expressionData,
                    rotationData,
                    rotationModeData,
                    /*flags*/0,
                    mCameraWidth,
                    mCameraHeight,
                    mFrameId++,
                    new int[]{mEffectItem},
                    isTracking);
        }

        public void switchCameraSurfaceTexture() {
            Log.i(TAG, "switchCameraSurfaceTexture " + mCameraSurfaceTexture + " " + mCameraTextureId + " " + mCamera);
            if (mCameraSurfaceTexture != null) {
                faceunity.fuOnCameraChange();
                destroySurfaceTexture();
            }

            if (mCameraTextureId == 0 || mCamera == null) {
                return;
            }

            mCameraSurfaceTexture = new SurfaceTexture(mCameraTextureId);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    handleCameraStartPreview(mCameraSurfaceTexture);
                }
            });
        }

        public void notifyPause() {
            faceTrackingStatus = 0;

            if (mTextureMovieEncoder != null && mTextureMovieEncoder.checkRecordingStatus(IN_RECORDING)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mRecordingBtn.performClick();
                    }
                });
            }

            if (mFullScreenFUDisplay != null) {
                mFullScreenFUDisplay.release(false);
                mFullScreenFUDisplay = null;
            }

            if (mCameraDisplay != null) {
                mCameraDisplay.release(false);
                mCameraDisplay = null;
            }
        }

        public void destroySurfaceTexture() {
            if (mCameraSurfaceTexture != null) {
                mCameraSurfaceTexture.release();
                mCameraSurfaceTexture = null;
            }
        }
    }

    class CreateItemHandler extends Handler {

        static final int HANDLE_CREATE_ITEM = 1;

        CreateItemHandler(Looper looper) {
            super(looper);
        }

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case HANDLE_CREATE_ITEM:
                    try {
                        final String effectFileName = (String) msg.obj;
                        final int newEffectItem;
                        if (effectFileName.equals("none")) {
                            newEffectItem = 0;
                        } else {
                            InputStream is = mContext.getAssets().open(effectFileName);
                            byte[] itemData = new byte[is.available()];
                            int len = is.read(itemData);
                            Log.i(TAG, "effect len " + len);
                            is.close();
                            newEffectItem = faceunity.fuCreateItemFromPackage(itemData);
                            mGLSurfaceView.queueEvent(new Runnable() {
                                @Override
                                public void run() {
                                    faceunity.fuItemSetParam(newEffectItem, "isAndroid", 1.0);
                                    faceunity.fuItemSetParam(newEffectItem, "rotationAngle", 360 - mCameraOrientation);
                                }
                            });
                        }
                        mGLSurfaceView.queueEvent(new Runnable() {
                            @Override
                            public void run() {
                                if (mEffectItem != 0 && mEffectItem != newEffectItem) {
                                    faceunity.fuDestroyItem(mEffectItem);
                                }
                                isInAvatarMode = Arrays.asList(EffectAndFilterSelectAdapter.AVATAR_EFFECT).contains(effectFileName);
                                mEffectItem = newEffectItem;
                            }
                        });
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                    break;
            }
        }
    }

    @SuppressWarnings("deprecation")
    private void openCamera(int cameraType, int desiredWidth, int desiredHeight) {
        Log.i(TAG, "openCamera " + cameraType + " " + desiredWidth + " " + desiredHeight);

        if (mCamera != null) {
            throw new RuntimeException("camera already initialized");
        }

        Camera.CameraInfo info = new Camera.CameraInfo();
        int cameraId = 0;
        int numCameras = Camera.getNumberOfCameras();

        Log.i(TAG, "getNumberOfCameras " + numCameras);

        for (int camIdx = 0; camIdx < numCameras; camIdx++) {

            Log.i(TAG, "getCameraInfo before " + camIdx + " " + info.canDisableShutterSound + " " + info.facing + " " + info.orientation);

            Camera.getCameraInfo(camIdx, info);

            Log.i(TAG, "getCameraInfo " + camIdx + " " + info.canDisableShutterSound + " " + info.facing + " " + info.orientation);

            if (info.facing == cameraType) {
                cameraId = camIdx;
                mCamera = Camera.open(camIdx);
                mCurrentCameraType = cameraType;
                Log.i(TAG, "open hardware " + mCurrentCameraType + " " + camIdx + " " + desiredWidth + " " + desiredHeight);
                break;
            }
        }

        if (mCamera == null) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(RTCWithFUExampleActivity.this,
                            "Open Camera Failed! Make sure it is not locked!", Toast.LENGTH_SHORT)
                            .show();
                }
            });
            throw new RuntimeException("unable to open camera");
        }

        Log.i(TAG, "after camera opened " + cameraType + " " + desiredWidth + " " + desiredHeight);

        mCameraOrientation = CameraUtils.getCameraOrientation(cameraId);
        CameraUtils.setCameraDisplayOrientation(this, cameraId, mCamera);

        Camera.Parameters parameters = mCamera.getParameters();

        CameraUtils.setFocusModes(parameters);

        int[] size = CameraUtils.choosePreviewSize(parameters, desiredWidth, desiredHeight);
        mCameraWidth = size[0];
        mCameraHeight = size[1];

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                AspectFrameLayout aspectFrameLayout = (AspectFrameLayout) findViewById(R.id.afl);
                aspectFrameLayout.setAspectRatio(1.0f * mCameraHeight / mCameraWidth);
            }
        });

        mCamera.setParameters(parameters);
    }

    /**
     * set preview and start preview after the surface created
     */
    private void handleCameraStartPreview(SurfaceTexture surfaceTexture) {
        Log.i(TAG, "handleCameraStartPreview " + previewCallbackBuffer + " " + surfaceTexture);

        try {
            if (previewCallbackBuffer == null) {
                Log.i(TAG, "allocate preview callback buffer " + PREVIEW_BUFFER_COUNT + " " + mCameraWidth + " " + mCameraHeight);
                previewCallbackBuffer = new byte[PREVIEW_BUFFER_COUNT][mCameraWidth * mCameraHeight * 3 / 2];
            }
            mCamera.setPreviewCallbackWithBuffer(this);
            for (int i = 0; i < PREVIEW_BUFFER_COUNT; i++) {
                mCamera.addCallbackBuffer(previewCallbackBuffer[i]);
            }

            mCamera.setPreviewTexture(surfaceTexture);

            mCamera.startPreview();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void releaseCamera() {
        Log.i(TAG, "release camera");
        isInPause = true;

        if (mCamera != null) {
            try {
                mCamera.stopPreview();
                mCamera.setPreviewTexture(null);
                mCamera.setPreviewCallbackWithBuffer(null);
                mCamera.release();
                mCamera = null;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        isInPause = true;
    }

    @Override
    protected void onCameraChange() {
        if (isInPause) {
            return;
        }

        Log.i(TAG, "onCameraChange " + mCurrentCameraType);

        releaseCamera();

        mCameraNV21Byte = null;
        mFrameId = 0;

        if (mCurrentCameraType == Camera.CameraInfo.CAMERA_FACING_FRONT) {
            openCamera(Camera.CameraInfo.CAMERA_FACING_BACK, mCameraWidth, mCameraHeight);
        } else {
            openCamera(Camera.CameraInfo.CAMERA_FACING_FRONT, mCameraWidth, mCameraHeight);
        }

        mGLSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mGLRenderer.switchCameraSurfaceTexture();
                faceunity.fuItemSetParam(mEffectItem, "isAndroid", 1.0);
                faceunity.fuItemSetParam(mEffectItem, "rotationAngle", 360 - mCameraOrientation);
            }
        });
    }

    @Override
    protected void onStartRecording() {
        MiscUtil.Logger(TAG, "start recording", false);
        mTextureMovieEncoder = new TextureMovieEncoder();
    }

    @Override
    protected void onStopRecording() {
        if (mTextureMovieEncoder != null && mTextureMovieEncoder.checkRecordingStatus(IN_RECORDING)) {
            MiscUtil.Logger(TAG, "stop recording", false);
            mGLSurfaceView.queueEvent(new Runnable() {
                @Override
                public void run() {
                    mTextureMovieEncoder.stopRecording();
                }
            });
        }
    }

    @Override
    protected void onBlurLevelSelected(int level) {
        mFaceBeautyBlurLevel = level;
    }

    @Override
    protected void onALLBlurLevelSelected(int isAll) {
        mFaceBeautyALLBlurLevel = isAll;
    }

    @Override
    protected void onCheekThinSelected(int progress, int max) {
        mFaceBeautyCheekThin = 1.0f * progress / max;
    }

    @Override
    protected void onColorLevelSelected(int progress, int max) {
        mFaceBeautyColorLevel = 1.0f * progress / max;
    }

    @Override
    protected void onEffectSelected(String effectItemName) {
        if (effectItemName.equals(mEffectFileName)) {
            return;
        }
        mCreateItemHandler.removeMessages(CreateItemHandler.HANDLE_CREATE_ITEM);
        mEffectFileName = effectItemName;
        isNeedEffectItem = true;
    }

    @Override
    protected void onFilterLevelSelected(int progress, int max) {
        mFilterLevel = 1.0f * progress / max;
    }

    @Override
    protected void onEnlargeEyeSelected(int progress, int max) {
        mFaceBeautyEnlargeEye = 1.0f * progress / max;
    }

    @Override
    protected void onFilterSelected(String filterName) {
        mFilterName = filterName;
    }

    @Override
    protected void onRedLevelSelected(int progress, int max) {
        mFaceBeautyRedLevel = 1.0f * progress / max;
    }

    @Override
    protected void onFaceShapeLevelSelected(int progress, int max) {
        mFaceShapeLevel = (1.0f * progress) / max;
    }

    @Override
    protected void onFaceShapeSelected(int faceShape) {
        mFaceShape = faceShape;
    }

    private int showNum = 0;

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
