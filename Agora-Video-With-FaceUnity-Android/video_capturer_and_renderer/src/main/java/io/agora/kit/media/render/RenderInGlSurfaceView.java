package io.agora.kit.media.render;

import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import android.util.Log;
import android.view.View;

import java.util.concurrent.TimeUnit;

import io.agora.kit.media.capture.VideoCaptureFrame;
import io.agora.kit.media.gles.ProgramTexture2d;
import io.agora.kit.media.gles.ProgramTextureOES;
import io.agora.kit.media.gles.core.GlUtil;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class RenderInGlSurfaceView extends BaseRender {
    public final static String TAG = RenderInGlSurfaceView.class.getSimpleName();

    private GLSurfaceView mGLSurfaceView;
    private int mCameraTextureId;
    private int mEffectTextureId;
    private float[] mMTX = new float[16];
    private float[] mMVP = new float[16];


    private boolean mLastMirror;
    private boolean mMVPInit;

    private int mViewWidth;
    private int mViewHeight;

    private volatile boolean mNeedsDraw = false;
    private volatile boolean mRequestDestroy = false;

    private ProgramTexture2d mFullFrameRectTexture2D;
    private ProgramTextureOES mTextureOES;

    private GLSurfaceView.Renderer mGLRenderer = new GLSurfaceView.Renderer() {
        public void onSurfaceCreated(GL10 gl, EGLConfig config) {
            mFullFrameRectTexture2D = new ProgramTexture2d();
            mTextureOES = new ProgramTextureOES();
            mCameraTextureId = GlUtil.createTextureObject(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
            mTexConnector.onDataAvailable(new Integer(mCameraTextureId));

            Log.e(TAG, "onSurfaceCreated gl " + gl + " " + config + " " + mGLSurfaceView + " " + mGLRenderer);
        }

        public void onSurfaceChanged(GL10 gl, int width, int height) {
            GLES20.glViewport(0, 0, width, height);
            mViewWidth = width;
            mViewHeight = height;
            if (mNeedsDraw) {
                mMVP = GlUtil.changeMVPMatrix(GlUtil.IDENTITY_MATRIX, mViewWidth, mViewHeight,
                        mVideoCaptureFrame.mFormat.getHeight(), mVideoCaptureFrame.mFormat.getWidth());
            }
            mFPSUtil.resetLimit();

            Log.e(TAG, "onSurfaceChanged gl " + gl + " " + width + " " + height + " " + mGLSurfaceView + " " + mGLRenderer);
        }

        public void onDrawFrame(GL10 gl) {
            if (mNeedsDraw) {
                VideoCaptureFrame frame = mVideoCaptureFrame;
                try {
                    frame.mSurfaceTexture.updateTexImage();

                    frame.mSurfaceTexture.getTransformMatrix(mMTX);
                    frame.mTexMatrix = mMTX;
                } catch (Exception e) {
                    Log.e(TAG, "updateTexImage failed, ignore " + Log.getStackTraceString(e));
                    return;
                }

                if (frame.mImage == null) {
                    mFullFrameRectTexture2D.drawFrame(mEffectTextureId, frame.mTexMatrix, mMVP);
                    Log.e(TAG, "return with texture id");
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

                if (mRequestDestroy) {
                    doDestroy();
                }
            }
        }
    };

    public RenderInGlSurfaceView() {
        super();
    }

    public boolean setRenderView(View view) {
        if (view instanceof GLSurfaceView) {
            mGLSurfaceView = (GLSurfaceView) view;
            mGLSurfaceView.setEGLContextClientVersion(2);
            mGLSurfaceView.setPreserveEGLContextOnPause(true);
            mGLSurfaceView.setRenderer(mGLRenderer);
            mGLSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
            Log.i(TAG, "setRenderSurfaceView");
            return true;
        }
        return false;
    }

    @Override
    public void runInRenderThread(Runnable r) {
        if (mGLSurfaceView != null) {
            mGLSurfaceView.queueEvent(r);
        }

    }

    private void flipFrontX() {
        Matrix.scaleM(mMVP, 0, -1, 1, 1);
    }

    public void destroy() {
        mRequestDestroy = true;

        try {
            mDestroyLatch.await(100, TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            doDestroy();
            Log.e(TAG, Log.getStackTraceString(e));
        }
    }

    private void doDestroy() {
        mNeedsDraw = false;

        if (mFullFrameRectTexture2D != null) {
            mFullFrameRectTexture2D.release();
            mFullFrameRectTexture2D = null;
        }

        if (mTextureOES != null) {
            mTextureOES.release();
            mTextureOES = null;
        }

        mTexConnector.disconnect();
        mFrameConnector.disconnect();
        mTransmitConnector.disconnect();

        mDestroyLatch.countDown();

        Log.e(TAG, "doDestroy " + mDestroyLatch.getCount());
    }

    public int onDataAvailable(VideoCaptureFrame frame) {
        mVideoCaptureFrame = frame;

        if (mRequestDestroy && !mNeedsDraw) {
            return -1;
        }

        mNeedsDraw = true;

        mGLSurfaceView.requestRender();
        return 0;
    }
}

