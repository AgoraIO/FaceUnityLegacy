package io.agora.FUDemo;

/**
 * Created by Yao Ximing on 2018/2/4.
 */

public interface VideoFrameHandler {
    void pushVideoFrame(int textureId, int format, int width, int height, int rotation,
                        long timestamp, float[] matrix);
}
