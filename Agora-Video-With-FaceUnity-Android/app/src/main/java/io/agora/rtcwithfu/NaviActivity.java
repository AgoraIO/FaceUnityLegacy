package io.agora.rtcwithfu;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import io.agora.Constants;

public class NaviActivity extends Activity {

    private EditText mChannelName;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_navi);

        mChannelName = (EditText) findViewById(R.id.edt_channel);
    }

    public void onStartBroadcastClick(View view) {
        if (mChannelName.getText().toString().isEmpty()) {
            Toast.makeText(this, "please input the channel name", Toast.LENGTH_SHORT).show();
            return;
        }

        Intent i = new Intent(this, MainActivity.class);
        i.putExtra(Constants.ACTION_KEY_ROOM_NAME, mChannelName.getText().toString());

        startActivity(i);
    }

}
