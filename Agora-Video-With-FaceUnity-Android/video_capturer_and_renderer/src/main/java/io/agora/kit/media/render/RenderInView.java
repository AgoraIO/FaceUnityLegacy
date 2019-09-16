package io.agora.kit.media.render;

import android.graphics.SurfaceTexture;
import android.opengl.GLES11Ext;
import android.opengl.GLES20;
import android.opengl.Matrix;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.TextureView;
import android.view.View;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.concurrent.TimeUnit;

import io.agora.kit.media.capture.VideoCaptureFrame;
import io.agora.kit.media.gles.ProgramTexture2d;
import io.agora.kit.media.gles.ProgramTextureOES;
import io.agora.kit.media.gles.core.EglCore;
import io.agora.kit.media.gles.core.GlUtil;
import io.agora.kit.media.gles.core.WindowSurface;

public class RenderInView extends BaseRender implements SurfaceHolder.Callback, TextureView.SurfaceTextureListener {
    public final static String TAG = RenderInView.class.getSimpleName();

    private Surface renderSurface;
    private SurfaceView renderSurfaceView;
    private TextureView renderTextureView;
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


    private RenderThread mRenderThread;
    private ArrayList<Runnable> mEventQueue = new ArrayList<Runnable>();

    //Thread use to render picture
    private class RenderThread extends Thread implements
            SurfaceTexture.OnFrameAvailableListener {
        private volatile RenderHandler mRenderHandler;

        private Object mStartLock = new Object();
        private boolean mReady = false;
        private boolean isSurfaceCreated = false;
        private boolean isSurfaceBackGroud = false;
        private EglCore mEglCore;
        private WindowSurface mWindowSurface = null;

        @Override
        public void run() {
            Looper.prepare();

            mRenderHandler = new RenderHandler(this);
            synchronized (mStartLock) {
                mReady = true;
                mStartLock.notify();
            }
            mEglCore = new EglCore(null, 0);
            Looper.loop();
            Log.d(TAG, "looper quit");
            releaseGl();
            mEglCore.release();
            isSurfaceCreated = false;
            synchronized (mStartLock) {
                mReady = false;
            }
        }

        public void waitUntilReady() {
            synchronized (mStartLock) {
                while (!mReady) {
                    try {
                        mStartLock.wait();
                    } catch (InterruptedException ie) { /* not expected */ }
                }
            }
        }

        private void shutdown() {
            Log.d(TAG, "shutdown");
            Looper.myLooper().quit();
        }

        public RenderHandler getHandler() {
            return mRenderHandler;
        }

        private void surfaceAvailable(Surface surface) {
            Log.d(TAG, "surfaceAvailable surface" + surface);
            mWindowSurface = new WindowSurface(mEglCore, surface, false);
            mWindowSurface.makeCurrent();
            if (!isSurfaceCreated) {
                mFullFrameRectTexture2D = new ProgramTexture2d();
                mTextureOES = new ProgramTextureOES();
                mCameraTextureId = GlUtil.createTextureObject(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
                mTexConnector.onDataAvailable(new Integer(mCameraTextureId));
            }
            isSurfaceCreated = true;

        }

        private void surfaceTexureAvailable(int width, int height, SurfaceTexture surfaceTexture) {

            mWindowSurface = new WindowSurface(mEglCore, surfaceTexture);
            mWindowSurface.makeCurrent();
            if (!isSurfaceCreated) {
                mFullFrameRectTexture2D = new ProgramTexture2d();
                mTextureOES = new ProgramTextureOES();
                mCameraTextureId = GlUtil.createTextureObject(GLES11Ext.GL_TEXTURE_EXTERNAL_OES);
                mTexConnector.onDataAvailable(new Integer(mCameraTextureId));
            }
            surfaceChanged(width, height);
            isSurfaceCreated = true;
            isSurfaceBackGroud = false;
        }

        private void surfaceChanged(int width, int height) {
            GLES20.glViewport(0, 0, width, height);
            mViewWidth = width;
            mViewHeight = height;
            if (mNeedsDraw) {
                mMVP = GlUtil.changeMVPMatrix(GlUtil.IDENTITY_MATRIX, mViewWidth, mViewHeight,
                        mVideoCaptureFrame.mFormat.getHeight(), mVideoCaptureFrame.mFormat.getWidth());
            }
            mFPSUtil.resetLimit();
            isSurfaceBackGroud = false;
        }

        private void releaseGl() {
            GlUtil.checkGlError("releaseGl start");

            if (mWindowSurface != null) {
                mWindowSurface.release();
                mWindowSurface = null;
            }
            GlUtil.checkGlError("releaseGl done");

            mEglCore.makeNothingCurrent();
        }

        private void surfaceDestroyed() {
            Log.d(TAG, "RenderThread surfaceDestroyed");
            isSurfaceBackGroud = true;
            //releaseGl();
            //isSurfaceCreated = false;
        }

        @Override
        public void onFrameAvailable(SurfaceTexture surfaceTexture) {
            mRenderHandler.sendFrameAvailable();
        }

        private void frameAvailable() {
            draw();
        }

        private void draw() {
            if (mNeedsDraw) {
                if(!isSurfaceBackGroud){
                    mWindowSurface.makeCurrent();
                }
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
                mWindowSurface.swapBuffers();
                mFPSUtil.limit();

                if (mRequestDestroy) {
                    doDestroy();
                }
            }
        }


        public void excuteEvent() {
            Runnable event = null;
            if (!mEventQueue.isEmpty()) {
                event = mEventQueue.remove(0);
            }
            if (event != null) {
                event.run();
                event = null;
            }
        }
    }

    private static class RenderHandler extends Handler {
        private static final int MSG_SURFACE_AVAILABLE = 0;
        private static final int MSG_SURFACE_SIZE_CHANGED = 1;
        private static final int MSG_SURFACE_DESTROYED = 2;
        private static final int MSG_SHUTDOWN = 3;
        private static final int MSG_FRAME_AVAILABLE = 4;
        private static final int MSG_REDRAW = 9;
        private static final int MSG_SURFACE_VIEW_CHANGED = 10;
        private static final int MSG_SURFACE_VIEW_DESTORY = 11;
        private static final int MSG_SURFACE_TEXTURE_AVAILABLE = 12;
        private static final int MSG_SURFACE_TEXTURE_DESTORY = 13;
        private static final int MSG_SURFACE_TEXTURE_CHANGED = 14;
        private static final int MSG_QUEUE_EVENT = 15;

        private WeakReference<RenderThread> mWeakRenderThread;

        public RenderHandler(RenderThread rt) {
            mWeakRenderThread = new WeakReference<RenderThread>(rt);
        }

        public void sendSurfaceAvailable(Surface surface) {
            Log.i(TAG, "sendSurfaceAvailable");
            sendMessage(obtainMessage(MSG_SURFACE_AVAILABLE, surface));
        }

        public void sendSurfaceViewChanged(int width, int height) {
            Log.i(TAG, "sendSurfaceViewChanged");
            sendMessage(obtainMessage(MSG_SURFACE_VIEW_CHANGED, width, height));
        }

        public void sendSurfaceViewDestroyed(SurfaceHolder surfaceHolder) {
            Log.i(TAG, "sendSurfaceViewDestroyed");
            sendMessage(obtainMessage(MSG_SURFACE_VIEW_DESTORY,
                    surfaceHolder));
        }


        public void sendTextureViewAvailable(SurfaceTexture surfaceTexture, int width, int height) {
            Log.i(TAG, "sendTextureViewAvailable");
            sendMessage(obtainMessage(MSG_SURFACE_TEXTURE_AVAILABLE, width, height, surfaceTexture));
        }

        public void sendTextureViewChanged(int width, int height) {
            Log.i(TAG, "sendTextureViewChanged");
            sendMessage(obtainMessage(MSG_SURFACE_TEXTURE_CHANGED,
                    width, height));
        }

        public void sendTexureViewDestroy(SurfaceTexture surfaceTexture) {
            Log.i(TAG, "sendTexureViewDestroy");
            sendMessage(obtainMessage(MSG_SURFACE_TEXTURE_DESTORY,
                    surfaceTexture));
        }

        public void sendQueueEvent() {
            Log.i(TAG, "sendQueueEvent");
            sendMessage(obtainMessage(MSG_QUEUE_EVENT));
        }

        public void sendShutdown() {
            Log.i(TAG, "sendShutdown");
            sendMessage(obtainMessage(MSG_SHUTDOWN));
        }

        public void sendFrameAvailable() {
            sendMessage(obtainMessage(MSG_FRAME_AVAILABLE));
        }

        public void sendRedraw() {
            sendMessage(obtainMessage(MSG_REDRAW));
        }

        @Override
        public void handleMessage(Message msg) {
            int what = msg.what;
            RenderThread renderThread = mWeakRenderThread.get();
            if (renderThread == null) {
                Log.w(TAG, "RenderHandler.handleMessage: weak ref is null");
                return;
            }

            switch (what) {
                case MSG_SURFACE_AVAILABLE:
                    renderThread.surfaceAvailable((Surface) msg.obj);
                    break;
                case MSG_SURFACE_TEXTURE_AVAILABLE:
                    renderThread.surfaceTexureAvailable(msg.arg1, msg.arg2, (SurfaceTexture) msg.obj);
                    break;
                case MSG_SURFACE_VIEW_CHANGED:
                case MSG_SURFACE_TEXTURE_CHANGED:
                case MSG_SURFACE_SIZE_CHANGED:
                    renderThread.surfaceChanged(msg.arg1, msg.arg2);
                    break;
                case MSG_SURFACE_VIEW_DESTORY:
                case MSG_SURFACE_TEXTURE_DESTORY:
                case MSG_SURFACE_DESTROYED:
                    renderThread.surfaceDestroyed();
                    break;
                case MSG_SHUTDOWN:
                    renderThread.shutdown();
                    break;
                case MSG_FRAME_AVAILABLE:
                    renderThread.frameAvailable();
                    break;
                case MSG_REDRAW:
                    renderThread.draw();
                    break;
                case MSG_QUEUE_EVENT:
                    renderThread.excuteEvent();
                    break;
                default:
                    throw new RuntimeException("unknown message " + what);
            }
        }
    }


    private void flipFrontX() {
        Matrix.scaleM(mMVP, 0, -1, 1, 1);
    }

    @Override
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
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendShutdown();
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


    @Override
    public int onDataAvailable(VideoCaptureFrame frame) {
        mVideoCaptureFrame = frame;
        if (mRequestDestroy && !mNeedsDraw) {
            return -1;
        }
        mNeedsDraw = true;
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendFrameAvailable();
        return 0;
    }

    public RenderInView() {
        super();
        initRenderThread();
    }

    private void initRenderThread() {
        mRenderThread = new RenderThread();
        mRenderThread.setName("Self RenderThread");
        mRenderThread.start();
        mRenderThread.waitUntilReady();
    }

    private void setRenderSurfaceView(SurfaceView surfaceView) {
        renderSurfaceView = surfaceView;
        this.renderSurfaceView.getHolder().addCallback(this);
    }

    private void setRenderTextureView(TextureView textureView) {
        renderTextureView = textureView;
        this.renderTextureView.setSurfaceTextureListener(this);
    }

    public void setRenderSurface(Surface surface) {
        renderSurface = surface;
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendSurfaceAvailable(renderSurface);
    }

    @Override
    public boolean setRenderView(View view) {
        if (view instanceof SurfaceView) {
            setRenderSurfaceView((SurfaceView) view);
            Log.i(TAG, "setRenderSurfaceView");
            return true;
        } else if (view instanceof TextureView) {
            Log.i(TAG, "setRenderTextureView");
            setRenderTextureView((TextureView) view);
            return true;
        }
        return false;
    }

    public void runInRenderThread(Runnable r) {
        if (r == null) {
            throw new IllegalArgumentException("r must not be null");
        }
        mEventQueue.add(r);
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendQueueEvent();
    }


    //surfaceview deal with
    @Override
    public void surfaceCreated(SurfaceHolder surfaceHolder) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.removeCallbacksAndMessages(null);
        rh.sendSurfaceAvailable(surfaceHolder.getSurface());
    }

    @Override
    public void surfaceChanged(SurfaceHolder surfaceHolder, int format, int width, int height) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendSurfaceViewChanged(width, height);
    }

    @Override
    public void surfaceDestroyed(SurfaceHolder surfaceHolder) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendSurfaceViewDestroyed(surfaceHolder);
    }

    //textureView deal with
    @Override
    public void onSurfaceTextureAvailable(SurfaceTexture surfaceTexture, int width, int height) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.removeCallbacksAndMessages(null);
        rh.sendTextureViewAvailable(surfaceTexture, width, height);
    }

    @Override
    public void onSurfaceTextureSizeChanged(SurfaceTexture surfaceTexture, int width, int height) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendTextureViewChanged(width, height);
    }

    @Override
    public boolean onSurfaceTextureDestroyed(SurfaceTexture surfaceTexture) {
        RenderHandler rh = mRenderThread.getHandler();
        rh.sendTexureViewDestroy(surfaceTexture);
        return false;
    }

    @Override
    public void onSurfaceTextureUpdated(SurfaceTexture surfaceTexture) {

    }

}

