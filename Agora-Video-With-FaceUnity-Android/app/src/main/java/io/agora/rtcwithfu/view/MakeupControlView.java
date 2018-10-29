package io.agora.rtcwithfu.view;

import android.animation.ValueAnimator;
import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SimpleItemAnimator;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.faceunity.FURenderer;
import com.faceunity.entity.Makeup;
import com.faceunity.fulivedemo.entity.MakeupEnum;
import com.faceunity.fulivedemo.ui.CheckGroup;
import com.faceunity.fulivedemo.ui.seekbar.DiscreteSeekBar;

import java.util.List;

import io.agora.rtcwithfu.R;

import static com.faceunity.fulivedemo.entity.BeautyParameterModel.sMakeupLevel;
import static com.faceunity.fulivedemo.entity.BeautyParameterModel.sMakeups;

public class MakeupControlView {
    private Context mContext;
    private LayoutInflater mInflater;
    private FURenderer mFURenderer;

    private ConstraintLayout mConstraintLayout;
    private CheckGroup mBottomCheckGroup;
    private RecyclerView mMakeupMidRecycler;
    private MakeupAdapter mMakeupAdapter;
    private DiscreteSeekBar mBeautySeekBar;
    private ImageView mMakeupNone;
    private ValueAnimator mBottomLayoutAnimator;

    public MakeupControlView(Context context, FURenderer renderer) {
        mContext = context;
        mFURenderer = renderer;
        mInflater = LayoutInflater.from(mContext);
    }

    public View createView() {
        View view = LayoutInflater.from(mContext)
                .inflate(R.layout.layout_fu_makeup, null);

        mConstraintLayout = (ConstraintLayout) view.findViewById(R.id.fu_makeup_layout);

        mBottomCheckGroup = (CheckGroup) view.findViewById(R.id.makeup_radio_group);
        mBottomCheckGroup.setOnCheckedChangeListener(new CheckGroup.OnCheckedChangeListener() {
            int checkedId_old = View.NO_ID;

            @Override
            public void onCheckedChanged(CheckGroup group, int checkedId) {
                switch (checkedId) {
                    case R.id.makeup_radio_lipstick:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_LIPSTICK);
                        break;
                    case R.id.makeup_radio_blusher:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_BLUSHER);
                        break;
                    case R.id.makeup_radio_eyebrow:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_EYEBROW);
                        break;
                    case R.id.makeup_radio_eye_shadow:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_EYE_SHADOW);
                        break;
                    case R.id.makeup_radio_eye_liner:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_EYE_LINER);
                        break;
                    case R.id.makeup_radio_eyelash:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_EYELASH);
                        break;
                    case R.id.makeup_radio_contact_lens:
                        mMakeupAdapter.setMakeupType(Makeup.MAKEUP_TYPE_CONTACT_LENS);
                        break;
                }

                if ((checkedId == View.NO_ID || checkedId == checkedId_old) && checkedId_old != View.NO_ID) {
                    int endHeight = (int) mContext.getResources().getDimension(R.dimen.x98);
                    int startHeight = mConstraintLayout.getHeight();
                    changeBottomLayoutAnimator(startHeight, endHeight);
                } else if (checkedId != View.NO_ID && checkedId_old == View.NO_ID) {
                    int startHeight = (int) mContext.getResources().getDimension(R.dimen.x98);
                    int endHeight = (int) mContext.getResources().getDimension(R.dimen.x366);
                    changeBottomLayoutAnimator(startHeight, endHeight);
                }
                checkedId_old = checkedId;
            }
        });

        mMakeupMidRecycler = (RecyclerView) view.findViewById(R.id.makeup_mid_recycler);
        mMakeupMidRecycler.setLayoutManager(new LinearLayoutManager(
                mContext, LinearLayoutManager.HORIZONTAL, false));
        mMakeupMidRecycler.setAdapter(mMakeupAdapter = new MakeupAdapter());
        ((SimpleItemAnimator) mMakeupMidRecycler.getItemAnimator()).setSupportsChangeAnimations(false);
        mMakeupNone = (ImageView) view.findViewById(R.id.makeup_none);
        mMakeupNone.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupAdapter.clickPosition(-1);
            }
        });

        mBeautySeekBar = (DiscreteSeekBar) view.findViewById(R.id.makeup_seek_bar);
        mBeautySeekBar.setOnProgressChangeListener(new DiscreteSeekBar.OnProgressChangeListener() {
            @Override
            public void onProgressChanged(DiscreteSeekBar seekBar, int value, boolean fromUser) {
                if (!fromUser) return;
                mMakeupAdapter.setMakeupLevel(1.0f * value / 100);
            }

            @Override
            public void onStartTrackingTouch(DiscreteSeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(DiscreteSeekBar seekBar) {

            }
        });

        return view;
    }

    private void changeBottomLayoutAnimator(final int startHeight, final int endHeight) {
        if (mBottomLayoutAnimator != null && mBottomLayoutAnimator.isRunning()) {
            mBottomLayoutAnimator.end();
        }

        mBottomLayoutAnimator = ValueAnimator.ofInt(startHeight, endHeight).setDuration(150);
        mBottomLayoutAnimator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator animation) {
                int height = (int) animation.getAnimatedValue();
                ViewGroup.LayoutParams params = mConstraintLayout.getLayoutParams();
                if (params == null) return;
                params.height = height;
                mConstraintLayout.setLayoutParams(params);
            }
        });
        mBottomLayoutAnimator.start();
    }

    private class MakeupAdapter extends RecyclerView.Adapter<MakeupAdapter.ViewHolder> {
        private int[] selectPos = {-1, -1, -1, -1, -1, -1, -1};
        private int selectMakeupType = -1;

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            return new ViewHolder(mInflater.
                    inflate(R.layout.layout_makeup_recycler, parent, false));
        }

        @Override
        public void onBindViewHolder(ViewHolder holder, int position) {
            final List<Makeup> makeups = getItems();
            final int clickPos = holder.getAdapterPosition();
            holder.makeupImg.setImageResource(makeups.get(position).resId());
            if (selectMakeupType >= 0 && selectPos[selectMakeupType] == position) {
                holder.makeupImg.setBackgroundResource(R.drawable.control_filter_select);
            } else {
                holder.makeupImg.setBackgroundResource(0);
            }
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    clickPosition(clickPos);
                }
            });
        }

        @Override
        public int getItemCount() {
            return getItems().size();
        }

        public void setMakeupType(int makeupType) {
            selectMakeupType = makeupType;
            mMakeupNone.setImageResource(selectPos[selectMakeupType] >= 0 ?
                    R.drawable.makeup_none_normal : R.drawable.makeup_none_checked);
            setMakeupProgress();
            notifyDataSetChanged();
        }

        private void clickPosition(int position) {
            selectPos[selectMakeupType] = position;
            Makeup select;
            if (position >= 0) {
                select = getItems().get(position);
                select.setLevel(getMakeupLevel(select.bundleName()));
                mFURenderer.onMakeupSelected(select);
            } else {
                select = MakeupEnum.MakeupNone.makeup();
                select.setMakeupType(selectMakeupType);
                mFURenderer.onMakeupSelected(select);
            }
            sMakeups[selectMakeupType] = select;
            setMakeupProgress();
            notifyDataSetChanged();
            mMakeupNone.setImageResource(position >= 0 ? R.drawable.makeup_none_normal : R.drawable.makeup_none_checked);
        }

        public void setMakeupProgress() {
            if (selectMakeupType == -1 || selectPos[selectMakeupType] == -1) {
                mBeautySeekBar.setVisibility(View.GONE);
            } else {
                mBeautySeekBar.setVisibility(View.VISIBLE);
                mBeautySeekBar.setProgress((int) (100 * getMakeupLevel(getItems().get(selectPos[selectMakeupType]).bundleName())));
            }
        }

        private List<Makeup> getItems() {
            return MakeupEnum.getMakeupsByMakeupType(selectMakeupType);
        }

        public float getMakeupLevel(String makeupName) {
            Float level = sMakeupLevel.get(makeupName);
            float l = level == null ? 0.5f : level;
            return l;
        }

        public void setMakeupLevel(float makeupLevel) {
            String makeupName = getItems().get(selectPos[selectMakeupType]).bundleName();
            sMakeupLevel.put(makeupName, makeupLevel);
            mFURenderer.onMakeupLevelSelected(selectMakeupType, makeupLevel);
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            ImageView makeupImg;

            ViewHolder(View itemView) {
                super(itemView);
                makeupImg = (ImageView) itemView.findViewById(R.id.makeup_recycler_img);
            }
        }
    }
}
