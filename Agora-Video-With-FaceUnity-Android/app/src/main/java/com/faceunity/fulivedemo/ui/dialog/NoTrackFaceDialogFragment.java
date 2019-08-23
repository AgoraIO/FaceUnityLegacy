package com.faceunity.fulivedemo.ui.dialog;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.annotation.StringRes;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import io.agora.rtcwithfu.R;
import com.faceunity.fulivedemo.utils.OnMultiClickListener;


/**
 * @author LiuQiang on 2018.08.28
 * 没有检测到人脸的提示框
 */
public class NoTrackFaceDialogFragment extends BaseDialogFragment {
    public static final String MESSAGE = "message";
    private OnDismissListener mOnDismissListener;

    public static NoTrackFaceDialogFragment newInstance(String message) {
        NoTrackFaceDialogFragment fragment = new NoTrackFaceDialogFragment();
        Bundle args = new Bundle();
        args.putString(MESSAGE, message);
        fragment.setArguments(args);
        return fragment;
    }

    public void setOnDismissListener(OnDismissListener onDismissListener) {
        mOnDismissListener = onDismissListener;
    }

    @Override
    protected View createDialogView(LayoutInflater inflater, @Nullable ViewGroup container) {
        View view = inflater.inflate(R.layout.dialog_not_track_face, container, false);
        TextView textView = (TextView) view.findViewById(R.id.tv_tip_message);
        String message = getArguments().getString(MESSAGE);
        if (!TextUtils.isEmpty(message)) {
            textView.setText(message);
        }
        view.findViewById(R.id.btn_done).setOnClickListener(new OnMultiClickListener() {
            @Override
            protected void onMultiClick(View v) {
                dismiss();
                if (mOnDismissListener != null) {
                    mOnDismissListener.onDismiss();
                }
            }
        });
        setCancelable(false);
        return view;
    }

    @Override
    protected int getDialogWidth() {
        return getResources().getDimensionPixelSize(R.dimen.x490);
    }

    @Override
    protected int getDialogHeight() {
        return getResources().getDimensionPixelSize(R.dimen.x450);
    }

}
