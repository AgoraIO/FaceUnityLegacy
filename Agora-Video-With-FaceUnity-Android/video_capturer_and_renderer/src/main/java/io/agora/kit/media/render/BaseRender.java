package io.agora.kit.media.render;

import android.content.Context;
import android.view.View;

import java.util.concurrent.CountDownLatch;

import io.agora.kit.media.capture.VideoCaptureFrame;
import io.agora.kit.media.connector.SinkConnector;
import io.agora.kit.media.connector.SrcConnector;
import io.agora.kit.media.util.FPSUtil;

/**
 * Created by yong on 2019/8/16.
 */

public abstract class BaseRender implements SinkConnector<VideoCaptureFrame> {
    protected VideoCaptureFrame mVideoCaptureFrame;
    protected SrcConnector<Integer> mTexConnector;
    protected SrcConnector<VideoCaptureFrame> mFrameConnector;
    protected SrcConnector<VideoCaptureFrame> mTransmitConnector;
    protected FPSUtil mFPSUtil;
    protected CountDownLatch mDestroyLatch;

    protected BaseRender() {
        mVideoCaptureFrame = null;
        mDestroyLatch = new CountDownLatch(1);
        mFPSUtil = new FPSUtil();
        mTexConnector = new SrcConnector<>();
        mFrameConnector = new SrcConnector<>();
        mTransmitConnector = new SrcConnector<>();
    }

    //set render view
    public abstract boolean setRenderView(View view);

    //send info to render thread
    public abstract void runInRenderThread(Runnable r);

    //pass render data to render thread
    public abstract int onDataAvailable(VideoCaptureFrame frame);

    //destroy all data
    public abstract void destroy();


    public SrcConnector<Integer> getTexConnector() {
        return mTexConnector;
    }

    public SrcConnector<VideoCaptureFrame> getFrameConnector() {
        return mFrameConnector;
    }

    public SrcConnector<VideoCaptureFrame> getTransmitConnector() {
        return mTransmitConnector;
    }

}
