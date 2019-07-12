package io.agora.video.transmit;

import io.agora.rtc.mediaio.MediaIO;
import io.agora.video.capture.VideoCaptureFrame;
import io.agora.video.connector.SinkConnector;

public class VideoTransmitter implements SinkConnector<VideoCaptureFrame> {
    private VideoSource mSource;

    public VideoTransmitter(VideoSource source) {
        mSource = source;
    }

    public int onDataAvailable(VideoCaptureFrame data) {
        if (mSource.getConsumer() != null) {
            mSource.getConsumer().consumeByteArrayFrame(data.mImage,
                    MediaIO.PixelFormat.NV21.intValue(), data.mFormat.getWidth(),
                    data.mFormat.getHeight(), data.mRotation, data.mTimeStamp);
        }
        return 0;
    }
}
