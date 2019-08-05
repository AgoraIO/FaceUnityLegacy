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
import com.faceunity.fulivedemo.ui.adapter.EffectRecyclerAdapter;
import com.faceunity.fulivedemo.ui.control.BeautyControlView;
import com.faceunity.fulivedemo.ui.control.MakeupControlView;
import com.faceunity.fulivedemo.utils.ToastUtil;

import java.util.ArrayList;
import java.util.List;

import io.agora.rtcwithfu.R;

public class EffectPanel {
    // TODO Needs to refine names
    private static final String[] PERMISSIONS_CODE = {
            "9-0",                    // Beauty
            "524288-0",               // Makeup
            "6-0",                    // Sticker
            "16-0",                   // Animoji
            "1048576-0",              // Hair
            "96-0",                   // AR Mask
            "128-0",                  // Face Change
            "8388608-0",              // Poster Face
            "2048-0",                 // Expression
            "131072-0",               // Douyin
            "256-0",                  // Background
            "512-0",                  // Gesture
            "65536-0",                // Face Warp
            "32768-0",                // Dynamic Portrait
            "0-16",                   // Avatar Face
            "16777216-0"              // Live Photo
    };

    private static final int[] FUNCTION_TYPE = {
            Effect.EFFECT_TYPE_NONE,
            Effect.EFFECT_TYPE_NONE,
            Effect.EFFECT_TYPE_NORMAL,
            Effect.EFFECT_TYPE_ANIMOJI,
            Effect.EFFECT_TYPE_NONE,
            Effect.EFFECT_TYPE_AR,
            Effect.EFFECT_TYPE_FACE_CHANGE,
            Effect.EFFECT_TYPE_POSTER_FACE,
            Effect.EFFECT_TYPE_EXPRESSION,
            Effect.EFFECT_TYPE_MUSIC_FILTER,
            Effect.EFFECT_TYPE_BACKGROUND,
            Effect.EFFECT_TYPE_GESTURE,
            Effect.EFFECT_TYPE_FACE_WARP,
            Effect.EFFECT_TYPE_PORTRAIT_DRIVE,
            Effect.EFFECT_TYPE_NONE,
            Effect.EFFECT_TYPE_LIVE_PHOTO
    };

    private static final int[] FUNCTION_NAME = {
            R.string.home_function_name_beauty,
            R.string.home_function_name_makeup,
            R.string.home_function_name_normal,
            R.string.home_function_name_animoji,
            R.string.home_function_name_hair,
            R.string.home_function_name_ar,
            R.string.home_function_name_face_change,
            R.string.home_function_name_poster_face,
            R.string.home_function_name_expression,
            R.string.home_function_name_music_filter,
            R.string.home_function_name_background,
            R.string.home_function_name_gesture,
            R.string.home_function_name_face_warp,
            R.string.home_function_name_portrait_drive,
            R.string.home_function_name_avatar,
            R.string.home_function_name_live_photo
    };

    private static final int[] FUNCTION_RES = {
            R.drawable.main_beauty,
            R.drawable.main_makeup,
            R.drawable.main_effect,
            R.drawable.main_animoji,
            R.drawable.main_hair,
            R.drawable.main_ar_mask,
            R.drawable.main_change_face,
            R.drawable.main_poster_face,
            R.drawable.main_expression,
            R.drawable.main_music_fiter,
            R.drawable.main_background,
            R.drawable.main_gesture,
            R.drawable.main_face_warp,
            R.drawable.main_portrait_drive,
            R.drawable.main_avatar,
            R.drawable.main_live_photo
    };

    private List<Integer> hasFaceUnityPermissionsList = new ArrayList<>();
    private final boolean[] hasFaceUnityPermissions = new boolean[FUNCTION_NAME.length];

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
        int moduleCode0 = FURenderer.getModuleCode(0);
        int moduleCode1 = FURenderer.getModuleCode(1);

        for (int i = 0, count = 0; i < FUNCTION_NAME.length; i++) {
            String[] codeStr = PERMISSIONS_CODE[i].split("-");
            int code0 = Integer.valueOf(codeStr[0]);
            int code1 = Integer.valueOf(codeStr[1]);
            hasFaceUnityPermissions[i] = (moduleCode0 == 0 && moduleCode1 == 0) || ((code0 & moduleCode0) > 0 || (code1 & moduleCode1) > 0);
            if (hasFaceUnityPermissions[i]) {
                hasFaceUnityPermissionsList.add(count++, i);
            } else {
                hasFaceUnityPermissionsList.add(i);
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
        public void onBindViewHolder(ItemViewHolder holder, int p) {
            final int position = hasFaceUnityPermissionsList.get(p);

            holder.mText.setText(FUNCTION_NAME[position]);

            int color;
            if (!hasFaceUnityPermissions[position]) {
                color = R.color.warmGrayColor;
            } else {
                color = (position == mSelectedPosition)
                        ? R.color.faceUnityYellow
                        : R.color.colorWhite;
            }

            holder.mText.setTextColor(mContext.getResources().getColor(color));

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (position != mSelectedPosition) {
                        if (!hasFaceUnityPermissions[position]) {
                            ToastUtil.showToast(mContext, R.string.sorry_no_permission);
                            return;
                        }
                        mSelectedPosition = position;
                        boolean available = onEffectTypeSelected(mSelectedPosition);

                        if (!available) {
                            ToastUtil.showToast(mContext, R.string.sorry_not_available);
                            return;
                        }
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
            return FUNCTION_TYPE.length;
        }

        class ItemViewHolder extends RecyclerView.ViewHolder {
            private TextView mText;

            private ItemViewHolder(View itemView) {
                super(itemView);
                mText = (TextView) itemView.findViewById(R.id.effect_type_name);
            }
        }
    }

    private boolean onEffectTypeSelected(int position) {
        mEffectPanel.setVisibility(View.VISIBLE);
        mEffectPanel.removeAllViews();

        int functionName = FUNCTION_NAME[position];

        if (functionName == R.string.home_function_name_hair) {
            return false;
        }

        if (functionName == R.string.home_function_name_poster_face) {
            return false;
        }

        if (functionName == R.string.home_function_name_avatar) {
            return false;
        }

        if (functionName == R.string.home_function_name_live_photo) {
            return false;
        }

        if (functionName == R.string.home_function_name_beauty) {
            addBeautyPanel();
        } else if (functionName == R.string.home_function_name_makeup) {
            addMakeupPanel();
        } else {
            addEffectRecyclerView(toEffectType(functionName));
        }

        adjustFURenderer(functionName, mFURenderer);

        return true;
    }

    private void addBeautyPanel() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.layout_fu_beauty, null);
        mEffectPanel.addView(view, LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT);

        BeautyControlView control = (BeautyControlView)
                view.findViewById(R.id.fu_beauty_control);
        control.setOnFUControlListener(mFURenderer);
        control.setOnDescriptionShowListener(new BeautyControlView.OnDescriptionShowListener() {
            @Override
            public void onDescriptionShowListener(int str) {
                //showDescription(str, 1000);
            }
        });
        control.onResume();
    }

    private void addMakeupPanel() {
        MakeupControlView control = new MakeupControlView(mContext);
        control.setOnFUControlListener(mFURenderer);

        mEffectPanel.addView(control, LinearLayout.LayoutParams.MATCH_PARENT,
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

    private int toEffectType(int functionName) {
        switch (functionName) {
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
// EFFECT_TYPE_PORTRAIT_LIGHT
            case R.string.home_function_name_animoji:
                return Effect.EFFECT_TYPE_ANIMOJI;
            case R.string.home_function_name_portrait_drive:
                return Effect.EFFECT_TYPE_PORTRAIT_DRIVE;
            case R.string.home_function_name_face_warp:
                return Effect.EFFECT_TYPE_FACE_WARP;
            case R.string.home_function_name_music_filter:
                return Effect.EFFECT_TYPE_MUSIC_FILTER;
            case R.string.home_function_name_hair:
                return Effect.EFFECT_TYPE_HAIR_NORMAL;
// EFFECT_TYPE_POSTER_FACE
// EFFECT_TYPE_HAIR_GRADIENT
// EFFECT_TYPE_LIVE_PHOTO
// EFFECT_TYPE_AVATAR
            default:
                return Effect.EFFECT_TYPE_NORMAL;
        }
    }

    private void adjustFURenderer(int functionName, FURenderer renderer) {
        if (functionName == R.string.home_function_name_beauty) {
            renderer.setDefaultEffect(null);
//            renderer.setNeedFaceBeauty(false);
        } else if (functionName == R.string.home_function_name_makeup) {
            renderer.setDefaultEffect(null);
//            renderer.setNeedFaceBeauty(true);
        } else {
            int effectType = toEffectType(functionName);
            List<Effect> effectList = EffectEnum.getEffectsByEffectType(effectType);
            renderer.setDefaultEffect(effectList.size() > 1 ? effectList.get(1) : null);
//            renderer.setNeedAnimoji3D(functionName == R.string.home_function_name_animoji);
//            renderer.setNeedFaceBeauty(functionName != R.string.home_function_name_animoji &&
//                    functionType != R.string.home_function_name_portrait_drive);
        }
    }
}
