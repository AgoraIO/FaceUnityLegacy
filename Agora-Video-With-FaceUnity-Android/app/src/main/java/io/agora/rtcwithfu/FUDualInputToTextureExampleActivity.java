package io.agora.rtcwithfu;

import android.hardware.Camera;

import com.faceunity.wrapper.faceunity;

/**
 * 这个 Activity 演示了从 Camera 取数据,用 fuDualInputToTexture 处理并预览展示
 * 所谓 dual-input，指从 CPU 和 GPU 同时拿数据，
 * CPU 拿到的是 NV21 的 byte array，GPU 拿到的是对应的 texture
 * <p>
 * Created by lirui on 2016/12/13.
 */

@SuppressWarnings("deprecation")
public class FUDualInputToTextureExampleActivity extends RTCWithFUExampleActivity {

    private byte[] mFuImgNV21Bytes;

    @Override
    protected int draw(byte[] cameraNV21Byte, byte[] fuImgNV21Bytes, int cameraTextureId, int cameraWidth, int cameraHeight, int frameId, int[] arrayItems, int currentCameraType) {
        boolean isOESTexture = true; // Tip: camera texture 类型是默认的是 OES_Texture 的，和 Texture2D 不同
        int flags = isOESTexture ? faceunity.FU_ADM_FLAG_EXTERNAL_OES_TEXTURE : 0;
        boolean isNeedReadBack = true; // 是否需要写回，如果是，则入参的 byte array 会被修改为带有 fu 特效的；支持写回自定义大小的内存数组中
        flags = isNeedReadBack ? flags | faceunity.FU_ADM_FLAG_ENABLE_READBACK : flags;
        if (isNeedReadBack) {
            if (fuImgNV21Bytes == null) {
                fuImgNV21Bytes = new byte[cameraNV21Byte.length];
            }
            System.arraycopy(cameraNV21Byte, 0, fuImgNV21Bytes, 0, cameraNV21Byte.length);
        } else {
            fuImgNV21Bytes = cameraNV21Byte;
        }
        flags |= currentCameraType == Camera.CameraInfo.CAMERA_FACING_FRONT ? 0 : faceunity.FU_ADM_FLAG_FLIP_X;

        mFuImgNV21Bytes = fuImgNV21Bytes;

            /*
             * 这里拿到 fu 处理过后的 texture，可以对这个 texture 做后续操作，如硬编、预览。
             */
        return faceunity.fuDualInputToTexture(fuImgNV21Bytes, cameraTextureId, flags,
                cameraWidth, cameraHeight, frameId, arrayItems);
    }

    @Override
    protected byte[] getFuImgNV21Bytes() {
        return mFuImgNV21Bytes;
    }
}
