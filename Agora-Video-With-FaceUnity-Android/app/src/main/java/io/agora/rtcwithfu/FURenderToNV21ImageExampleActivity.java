package io.agora.rtcwithfu;

import android.hardware.Camera;

import com.faceunity.wrapper.faceunity;

/**
 * 这个 Activity 演示了如何通过 fuRenderToNV21Image
 * 实现在无 GL Context 的情况下输入 NV21 的人脸图像，输出添加道具及美颜后的 NV21 图像
 * 和 dual-input 对应，可以认为 single-input
 * <p>
 * FU SDK 使用者可以将拿到处理后的 NV21 图像与自己的原有项目对接
 * <p>
 * Created by lirui on 2016/12/13.
 */

@SuppressWarnings("deprecation")
public class FURenderToNV21ImageExampleActivity extends RTCWithFUExampleActivity {

    private byte[] mFuImgNV21Bytes;

    @Override
    protected int draw(byte[] cameraNV21Byte, byte[] fuImgNV21Bytes, int cameraTextureId, int cameraWidth, int cameraHeight, int frameId, int[] arrayItems, int currentCameraType) {
        if (fuImgNV21Bytes == null) {
            fuImgNV21Bytes = new byte[cameraNV21Byte.length];
        }
        System.arraycopy(cameraNV21Byte, 0, fuImgNV21Bytes, 0, cameraNV21Byte.length);

        mFuImgNV21Bytes = fuImgNV21Bytes;

        /**
         * 这个函数执行完成后，入参的 NV21 byte array 会被改变
         */
        return faceunity.fuRenderToNV21Image(fuImgNV21Bytes, cameraWidth, cameraHeight, frameId,
                arrayItems, currentCameraType == Camera.CameraInfo.CAMERA_FACING_FRONT ? 0 : faceunity.FU_ADM_FLAG_FLIP_X);

    }

    @Override
    protected byte[] getFuImgNV21Bytes() {
        return mFuImgNV21Bytes;
    }
}
