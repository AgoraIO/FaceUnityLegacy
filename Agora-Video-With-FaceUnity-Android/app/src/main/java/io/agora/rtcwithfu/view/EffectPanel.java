package io.agora.rtcwithfu.view;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.faceunity.FURenderer;
import com.faceunity.entity.Effect;
import com.faceunity.fulivedemo.entity.EffectEnum;
import com.faceunity.fulivedemo.ui.BeautyControlView;
import com.faceunity.fulivedemo.ui.adapter.EffectRecyclerAdapter;
import com.faceunity.fulivedemo.utils.ToastUtil;

import java.util.List;

import io.agora.rtcwithfu.R;

public class EffectPanel {
    private static final int[] PERMISSIONS_CODE = {
            0x1,                    // beauty
            0x2 | 0x4,              // sticker
            0x20 | 0x40,            // AR mask
            0x80,                   // face change
            0x800,                  // expression
            0x100,                  // background
            0x200,                  // gesture
            0x80000,                // make up
            0x10,                   // ani moji
            0x20000,                // music filter
            0x10000,                // face warp
            0x8000,                 // portrait driven
    };

    private static final int[] FUNCTION_TYPES = {
            R.string.home_function_name_beauty,
            R.string.home_function_name_normal,
            R.string.home_function_name_ar,
            R.string.home_function_name_face_change,
            R.string.home_function_name_expression,
            R.string.home_function_name_background,
            R.string.home_function_name_gesture,
            R.string.home_function_name_makeup,
            R.string.home_function_name_animoji,
            R.string.home_function_name_music_filter,
            R.string.home_function_name_face_warp,
            R.string.home_function_name_portrait_drive,
    };


    private boolean[] permissions = new boolean[FUNCTION_TYPES.length];

    private Context mContext;
    private View mContainer;
    private RecyclerView mTypeList;
    private LinearLayout mEffectPanel;
    private LayoutInflater mInflater;
    private EffectRecyclerAdapter.OnDescriptionChangeListener mDescriptionListener;

    private FURenderer mFURenderer;

    public EffectPanel(View container, @NonNull FURenderer renderer,
                       EffectRecyclerAdapter.OnDescriptionChangeListener listener) {
        initPermissions();

        mContainer = container;
        mContext = mContainer.getContext();
        mInflater = LayoutInflater.from(mContext);

        mTypeList = (RecyclerView) mContainer.findViewById(R.id.effect_type_list);
        RecyclerView.LayoutManager layoutManager = new LinearLayoutManager(
                mContext, LinearLayoutManager.HORIZONTAL, false);
        mTypeList.setLayoutManager(layoutManager);
        mTypeList.setAdapter(new EffectTypeAdapter());

        mEffectPanel = (LinearLayout) mContainer.findViewById(R.id.effect_panel_container);
        mEffectPanel.setVisibility(View.GONE);

        mFURenderer = renderer;
        mDescriptionListener = listener;
    }

    private void initPermissions() {
        boolean isLite = FURenderer.getVersion().contains("lite");
        int moduleCode = FURenderer.getModuleCode();

        for (int i = 0; i < FUNCTION_TYPES.length; i++) {
            permissions[i] = ((moduleCode == 0) || (PERMISSIONS_CODE[i] & moduleCode) > 0);

            if (isLite && (FUNCTION_TYPES[i] == R.string.home_function_name_background ||
                    FUNCTION_TYPES[i] == R.string.home_function_name_gesture)) {
                permissions[i] = false;
            }
        }
    }

    private class EffectTypeAdapter extends RecyclerView.Adapter<EffectTypeAdapter.ItemViewHolder> {
        private int mSelectedPosition = 0;

        @Override
        public ItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new ItemViewHolder(mInflater.inflate(R.layout.effect_type_list_item, null));
        }

        @Override
        public void onBindViewHolder(ItemViewHolder holder, int position) {
            final int pos = holder.getAdapterPosition();
            holder.mText.setText(FUNCTION_TYPES[pos]);

            int color;
            if (!permissions[pos]) {
                color = R.color.warmGrayColor;
            } else {
                color = (pos == mSelectedPosition)
                        ? R.color.faceUnityYellow
                        : R.color.colorWhite;
            }

            holder.mText.setTextColor(mContext.getResources().getColor(color));

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (pos != mSelectedPosition) {
                        if (!permissions[pos]) {
                            ToastUtil.showToast(mContext, R.string.sorry_no_permission);
                            return;
                        }
                        mSelectedPosition = pos;
                        onEffectTypeSelected(mSelectedPosition);
                    } else {
                        mEffectPanel.removeAllViews();
                        mEffectPanel.setVisibility(View.GONE);
                        mSelectedPosition = -1;
                    }
                    notifyDataSetChanged();
                }
            });
        }

        @Override
        public int getItemCount() {
            return FUNCTION_TYPES.length;
        }

        class ItemViewHolder extends RecyclerView.ViewHolder {
            private TextView mText;

            private ItemViewHolder(View itemView) {
                super(itemView);
                mText = (TextView) itemView.findViewById(R.id.effect_type_name);
            }
        }
    }

    private void onEffectTypeSelected(int position) {
        mEffectPanel.setVisibility(View.VISIBLE);
        mEffectPanel.removeAllViews();

        int functionType = FUNCTION_TYPES[position];
        if (functionType == R.string.home_function_name_beauty) {
            addBeautyPanel();
        } else if (functionType == R.string.home_function_name_makeup) {
            addMakeupPanel();
        } else {
            addEffectRecyclerView(toEffectType(functionType));
        }
        
        adjustFURenderer(functionType, mFURenderer);
    }

    private void addBeautyPanel() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.layout_fu_beauty, null);
        mEffectPanel.addView(view, LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);

        BeautyControlView mBeautyControl = (BeautyControlView)
                view.findViewById(R.id.fu_beauty_control);
        mBeautyControl.setOnFUControlListener(mFURenderer);
        mBeautyControl.setOnDescriptionShowListener(new BeautyControlView.OnDescriptionShowListener() {
            @Override
            public void onDescriptionShowListener(int str) {
                //showDescription(str, 1000);
            }
        });
        mBeautyControl.onResume();
    }

    private void addMakeupPanel() {
        MakeupControlView control = new MakeupControlView(mContext, mFURenderer);
        mEffectPanel.addView(control.createView(), LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
    }

    private void addEffectRecyclerView(int effectType) {
        RecyclerView list = new RecyclerView(mContext);

        LinearLayoutManager manager = new LinearLayoutManager(mContext,
                LinearLayoutManager.HORIZONTAL, false);
        list.setLayoutManager(manager);

        EffectRecyclerAdapter adapter = new EffectRecyclerAdapter(
                mContext, effectType, mFURenderer);
        adapter.setOnDescriptionChangeListener(mDescriptionListener);
        list.setAdapter(adapter);

        mEffectPanel.addView(list, LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);
    }

    private int toEffectType(int functionType) {
        switch (functionType) {
            case R.string.home_function_name_normal:
                return Effect.EFFECT_TYPE_NORMAL;
            case R.string.home_function_name_ar:
                return Effect.EFFECT_TYPE_AR;
            case R.string.home_function_name_face_change:
                return Effect.EFFECT_TYPE_FACE_CHANGE;
            case R.string.home_function_name_expression:
                return Effect.EFFECT_TYPE_EXPRESSION;
            case R.string.home_function_name_background:
                return Effect.EFFECT_TYPE_BACKGROUND;
            case R.string.home_function_name_gesture:
                return Effect.EFFECT_TYPE_GESTURE;
            case R.string.home_function_name_animoji:
                return Effect.EFFECT_TYPE_ANIMOJI;
            case R.string.home_function_name_music_filter:
                return Effect.EFFECT_TYPE_MUSIC_FILTER;
            case R.string.home_function_name_face_warp:
                return Effect.EFFECT_TYPE_FACE_WARP;
            case R.string.home_function_name_portrait_drive:
                return Effect.EFFECT_TYPE_PORTRAIT_DRIVE;
            default:
                return Effect.EFFECT_TYPE_NORMAL;
        }
    }

    private void adjustFURenderer(int functionType, FURenderer renderer) {
        if (functionType == R.string.home_function_name_beauty) {
            renderer.setDefaultEffect(null);
            renderer.setNeedFaceBeauty(false);
        } else if (functionType == R.string.home_function_name_makeup) {
            renderer.setDefaultEffect(null);
            renderer.setNeedFaceBeauty(true);
        } else {
            int effectType = toEffectType(functionType);
            List<Effect> effectList = EffectEnum.getEffectsByEffectType(effectType);
            renderer.setDefaultEffect(effectList.size() > 1 ? effectList.get(1) : null);
            renderer.setNeedAnimoji3D(functionType == R.string.home_function_name_animoji);
            renderer.setNeedFaceBeauty(functionType != R.string.home_function_name_animoji &&
                    functionType != R.string.home_function_name_portrait_drive);
        }
    }
}
