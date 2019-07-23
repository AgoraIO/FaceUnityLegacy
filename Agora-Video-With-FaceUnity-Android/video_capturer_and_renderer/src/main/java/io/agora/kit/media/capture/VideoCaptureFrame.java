package io.agora.kit.media.capture;

import android.graphics.SurfaceTexture;
import android.opengl.Matrix;

import java.util.Arrays;

public class VideoCaptureFrame {
    public static final int NO_TEXTURE = -1;
    public static final float[] DEFAULT_MATRIX = new float[16];
    public VideoCaptureFormat mFormat;
    public int mTextureId = NO_TEXTURE;
    public float[] mTexMatrix;
    public int mRotation;
    public long mTimeStamp;
    public byte[] mImage;
    public SurfaceTexture mSurfaceTexture;
    public boolean mMirror;

    public VideoCaptureFrame(VideoCaptureFormat format, SurfaceTexture texture, int textureId, byte[] image, float[] matrix, long ts, int rotation, boolean mirror) {
        mFormat = format;
        mTextureId = textureId;
        mImage = image;
        mTimeStamp = ts;
        mRotation = rotation;
        mSurfaceTexture = texture;
        mMirror = mirror;

        if (matrix != null && matrix.length == 16) {
            mTexMatrix = matrix;
        } else {
            mTexMatrix = DEFAULT_MATRIX;
            Matrix.setIdentityM(mTexMatrix, 0);
        }
    }

    public String toString() {
        return "VideoCaptureFrame{" +
                "mFormat=" + mFormat +
                ", mRotation=" + mRotation +
                ", mMirror=" + mMirror +
                ", mTimeStamp=" + mTimeStamp +
                ", mTextureId=" + mTextureId +
                ", mTexMatrix=" + Arrays.toString(mTexMatrix) +
                '}';
    }
}