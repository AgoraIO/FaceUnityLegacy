package io.agora.video;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.util.Log;

import io.agora.rtc.RtcEngine;
import io.agora.video.capture.VideoCapture;
import io.agora.video.capture.VideoCaptureFactory;
import io.agora.video.capture.VideoCaptureFrame;
import io.agora.video.connector.SinkConnector;
import io.agora.video.constant.Constant;
import io.agora.video.render.VideoRender;
import io.agora.video.transmit.VideoSource;
import io.agora.video.transmit.VideoTransmitter;

public class VideoManager {
    private static final String TAG = VideoManager.class.getSimpleName();
    private static volatile VideoManager mInstance;
    private Context mContext;

    private int mFacing = Constant.CAMERA_FACING_INVALID;

    private VideoCapture mVideoCapture;
    private VideoRender mVideoRender;
    private VideoTransmitter mVideoTransmitter;
    private VideoSource mVideoSource;

    private int mWidth;
    private int mHeight;
    private int mFrameRate;
    private boolean mNeedsPreview;

    private VideoManager(Context context) {
        mContext = context;
    }

    public static VideoManager createInstance(Context context) {
        if (mInstance == null) {
            synchronized (VideoManager.class) {
                if (mInstance == null) {
                    mInstance = new VideoManager(context);
                }
            }
        }
        return mInstance;
    }

    public boolean allocate(int width, int height, int frameRate, int facing) {
        if (facing == Constant.CAMERA_FACING_FRONT || facing == Constant.CAMERA_FACING_BACK) {
            mFacing = facing;
            mWidth = width;
            mHeight = height;
            mFrameRate = frameRate;
            if (mVideoCapture == null) {
                mVideoCapture = VideoCaptureFactory.createVideoCapture(mContext);
            }

            return mVideoCapture.allocate(width, height, frameRate, facing);
        } else {
            mFacing = Constant.CAMERA_FACING_INVALID;
            Log.e(TAG, "invalid camera id provided");
            return false;
        }
    }

    public void deallocate() {
        if (mVideoTransmitter != null) {
            detachToRTCEngine();
        }

        if (mVideoCapture != null) {
            mFacing = Constant.CAMERA_FACING_INVALID;
            mVideoCapture.deallocate();
            mVideoCapture = null;
        }

        if (mVideoRender != null) {
            mVideoRender.destroy();
            mVideoRender = null;
        }
    }

    public void startCapture() {
        if (mVideoCapture != null) {
            mVideoCapture.startCaptureMaybeAsync(mNeedsPreview);
        } else {
            Log.w(TAG, "camera not allocated or already deallocated");
        }
    }

    public void stopCapture() {
        if (mVideoCapture != null) {
            mVideoCapture.stopCaptureAndBlockUntilStopped();
        } else {
            Log.w(TAG, "camera not allocated or already deallocated");
        }

    }

    public void setRenderView(GLSurfaceView view) {
        if (view != null) {
            mNeedsPreview = true;
            if (mVideoRender == null) {
                mVideoRender = new VideoRender(mContext);
            }
            mVideoRender.setRenderView(view);
            mVideoCapture.getSrcConnector().connect(mVideoRender);
            mVideoRender.getTexConnector().connect(mVideoCapture);
        } else {
            mNeedsPreview = false;
            Log.w(TAG, "the render view provided is null");
        }
    }

    public void switchCamera() {
        switch (mFacing) {
            case Constant.CAMERA_FACING_INVALID:
                Log.e(TAG, "camera not allocated or already deallocated");
            case Constant.CAMERA_FACING_BACK:
                stopCapture();
                allocate(mWidth, mHeight, mFrameRate, Constant.CAMERA_FACING_FRONT);
                mFacing = Constant.CAMERA_FACING_FRONT;
                startCapture();
            case Constant.CAMERA_FACING_FRONT:
                stopCapture();
                allocate(mWidth, mHeight, mFrameRate, Constant.CAMERA_FACING_BACK);
                mFacing = Constant.CAMERA_FACING_BACK;
                startCapture();
            default:
                Log.e(TAG, "no facing matched");
        }

    }

    public void connectEffectHandler(SinkConnector<VideoCaptureFrame> connector) {
        if (connector != null) {
            if (mNeedsPreview) {
                mVideoRender.getFrameConnector().connect(connector);
            } else {
                mVideoCapture.getSrcConnector().connect(connector);
            }
        } else {
            Log.w(TAG, "effectHandler is null");
        }
    }

    public void setMirrorMode(boolean mirror) {
        if (mVideoCapture != null) {
            if (mFacing == Constant.CAMERA_FACING_FRONT) {
                mVideoCapture.setMirrorMode(mirror);
            } else {
                Log.w(TAG, "mirror mode only applies to front camera");
            }
        } else {
            Log.w(TAG, "camera not allocated or already deallocated");
        }

    }

    public void attachToRTCEngine(RtcEngine engine) {
        if (engine != null) {
            mVideoSource = new VideoSource();
            engine.setVideoSource(mVideoSource);
            mVideoTransmitter = new VideoTransmitter(mVideoSource);
            if (mNeedsPreview) {
                mVideoRender.getTransmitConnector().connect(mVideoTransmitter);
            } else {
                mVideoCapture.getTransmitConnector().connect(mVideoTransmitter);
            }
        } else {
            Log.w(TAG, "the engine provided is null");
        }
    }

    public void detachToRTCEngine() {
        if (mVideoTransmitter != null) {
            if (mNeedsPreview) {
                mVideoRender.getTransmitConnector().disconnect();
            } else {
                mVideoCapture.getTransmitConnector().disconnect();
            }
            mVideoTransmitter = null;
        } else {
            Log.w(TAG, "not attached to engine, no need to detach");
        }
    }
}
