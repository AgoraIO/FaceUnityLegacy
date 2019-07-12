package io.agora.video.render;

import android.content.Context;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import android.util.Log;

import io.agora.video.capture.VideoCaptureFrame;
import io.agora.video.connector.SinkConnector;
import io.agora.video.connector.SrcConnector;
import io.agora.video.gles.ProgramTexture2d;
import io.agora.video.gles.ProgramTextureOES;
import io.agora.video.gles.core.GlUtil;
import io.agora.video.util.FPSUtil;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class VideoRender implements SinkConnector<VideoCaptureFrame> {
    public final static String TAG = VideoRender.class.getSimpleName();

    private GLSurfaceView mGLSurfaceView;
    private Context mContext;
    private VideoCaptureFrame mVideoCaptureFrame;
    private int mCameraTextureId;
    private int mEffectTextureId;
    private float[] mMTX = new float[16];
    private float[] mMVP = new float[16];

    private SrcConnector<Integer> mTexConnector;
    private SrcConnector<VideoCaptureFrame> mFrameConnector;
    private SrcConnector<VideoCaptureFrame> mTransmitConnector;

    private FPSUtil mFPSUtil;
    private boolean mLastMirror;
    private boolean mMVPInit;

    private int mViewWidth;
    private int mViewHeight;

    private boolean isDraw = false;

    private ProgramTexture2d mFullFrameRectTexture2D;
    private ProgramTextureOES mTextureOES;

    private GLSurfaceView.Renderer mGLRenderer = new GLSurfaceView.Renderer() {
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            mFullFrameRectTexture2D = new ProgramTexture2d();
            mTextureOES = new ProgramTextureOES();
            mCameraTextureId = GlUtil.createTextureObject(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
            mTexConnector.onDataAvailable(new Integer(mCameraTextureId));
        }

        public void onSurfaceChanged(GL10 gl, int width, int height) {
            GLES20.glViewport(0, 0, width, height);
            mViewWidth = width;
            mViewHeight = height;
            if (isDraw) {
                mMVP = GlUtil.changeMVPMatrix(GlUtil.IDENTITY_MATRIX, mViewWidth, mViewHeight,
                        mVideoCaptureFrame.mFormat.getHeight(), mVideoCaptureFrame.mFormat.getWidth());
            }
            mFPSUtil.resetLimit();
        }

        public void onDrawFrame(GL10 gl) {
            if (isDraw) {
                VideoCaptureFrame frame = mVideoCaptureFrame;
                try {
                    frame.mSurfaceTexture.updateTexImage();

                    frame.mSurfaceTexture.getTransformMatrix(mMTX);
                    frame.mTexMatrix = mMTX;
                } catch (Exception e) {
                    Log.e(TAG, "updateTexImage failed, ignore");
                    return;
                }

                if (frame.mImage == null) {
                    mFullFrameRectTexture2D.drawFrame(mEffectTextureId, frame.mTexMatrix, mMVP);
                    return;
                }

                mEffectTextureId = mFrameConnector.onDataAvailable(frame);

                if (!mMVPInit) {
                    mMVP = GlUtil.changeMVPMatrix(GlUtil.IDENTITY_MATRIX, mViewWidth, mViewHeight,
                            frame.mFormat.getHeight(), frame.mFormat.getWidth());
                    mMVPInit = true;
                }

                if (frame.mMirror != mLastMirror) {
                    mLastMirror = frame.mMirror;
                    flipFrontX();
                }

                if (mEffectTextureId <= 0) {
                    mTextureOES.drawFrame(frame.mTextureId, frame.mTexMatrix, mMVP);
                } else {
                    frame.mTextureId = mEffectTextureId;
                    mFullFrameRectTexture2D.drawFrame(frame.mTextureId, frame.mTexMatrix, mMVP);
                }

                mTransmitConnector.onDataAvailable(frame);

                mFPSUtil.limit();
                mGLSurfaceView.requestRender();
            }
        }
    };

    public VideoRender(Context context) {
        mContext = context;
        mFPSUtil = new FPSUtil();
        mTexConnector = new SrcConnector<>();
        mFrameConnector = new SrcConnector<>();
        mTransmitConnector = new SrcConnector<>();
    }

    public void setRenderView(GLSurfaceView glSurfaceView) {
        mGLSurfaceView = glSurfaceView;
        mGLSurfaceView.setEGLContextClientVersion(2);
        mGLSurfaceView.setRenderer(mGLRenderer);
        mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
    }

    public SrcConnector<Integer> getTexConnector() {
        return mTexConnector;
    }

    public SrcConnector<VideoCaptureFrame> getFrameConnector() {
        return mFrameConnector;
    }

    public SrcConnector<VideoCaptureFrame> getTransmitConnector() {
        return mTransmitConnector;
    }

    private void flipFrontX() {
        Matrix.scaleM(mMVP, 0, -1, 1, 1);
    }

    public void destroy() {
        isDraw = false;
        if (mFullFrameRectTexture2D != null) {
            mFullFrameRectTexture2D.release();
            mFullFrameRectTexture2D = null;
        }

        if (mTextureOES != null) {
            mTextureOES.release();
            mTextureOES = null;
        }

        mGLSurfaceView.onPause();

        mTexConnector.disconnect();
        mFrameConnector.disconnect();
        mTransmitConnector.disconnect();
    }

    public int onDataAvailable(VideoCaptureFrame frame) {
        isDraw = true;
        mVideoCaptureFrame = frame;
        mGLSurfaceView.requestRender();
        return 0;
    }
}

