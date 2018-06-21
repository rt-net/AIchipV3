/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.bluetoothchat;

import java.lang.String;
import java.util.ArrayList;

import android.app.ActionBar;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.SeekBar;
import android.widget.ProgressBar;
import android.speech.RecognizerIntent;

import com.example.android.common.logger.Log;


/**
 * This fragment controls Bluetooth to communicate with other devices.
 */
public class BluetoothChatFragment extends Fragment {

    private static final String TAG = "BluetoothChatFragment";

    // Intent request codes
    private static final int REQUEST_CONNECT_DEVICE_SECURE = 1;
    private static final int REQUEST_CONNECT_DEVICE_INSECURE = 2;
    private static final int REQUEST_ENABLE_BT = 3;
    private static final int REQUEST_CODE = 4;
    //private static final int RESULT_OK = 4;

    // Layout Views
    private ListView mConversationView;
    private EditText mOutEditText;
    private Button mSendButton;
    //scratch
    private Boolean mGLEDstate = Boolean.FALSE;
    private Boolean mRLEDstate = Boolean.FALSE;

    private SeekBar mSendSeekBar;
    private Button mStartButton;
    private Button mStopButton;
    private Button mBackButton;
    private Button mRedButton;
    private Button mGreenButton;
    private TextView mBatteryView;
    private ProgressBar mAccx;
    private ProgressBar mAccy;
    private ProgressBar mAccz;

    /**
     * Name of the connected device
     */
    private String mConnectedDeviceName = null;

    /**
     * Array adapter for the conversation thread
     */
    private ArrayAdapter<String> mConversationArrayAdapter;

    /**
     * String buffer for outgoing messages
     */
    private StringBuffer mOutStringBuffer;

    /**
     * Local Bluetooth adapter
     */
    private BluetoothAdapter mBluetoothAdapter = null;

    /**
     * Member object for the chat services
     */
    //private BluetoothChatService mChatService = null;

    /**
     * Member object for the chat services
     */
    private AI_CHIP mAIChat = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        // Get local Bluetooth adapter
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

        // If the adapter is null, then Bluetooth is not supported
        if (mBluetoothAdapter == null) {
            FragmentActivity activity = getActivity();
            Toast.makeText(activity, "Bluetooth is not available", Toast.LENGTH_LONG).show();
            activity.finish();
        }

    }


    @Override
    public void onStart() {
        super.onStart();
        // If BT is not on, request that it be enabled.
        // setupChat() will then be called during onActivityResult
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
            // Otherwise, setup the chat session
        } else if (mAIChat == null) {
            setupChat();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (mAIChat != null) {
            mAIChat.stop();
        }
    }

    @Override
    public void onResume() {
        super.onResume();

        // Performing this check in onResume() covers the case in which BT was
        // not enabled during onStart(), so we were paused to enable it...
        // onResume() will be called when ACTION_REQUEST_ENABLE activity returns.
        if (mAIChat != null) {
            // Only if the state is STATE_NONE, do we know that we haven't started already
            if (mAIChat.getState() == BluetoothChatService.STATE_NONE) {
                // Start the Bluetooth chat services
                mAIChat.start();
            }
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_bluetooth_chat, container, false);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        mConversationView = (ListView) view.findViewById(R.id.in);
        mOutEditText = (EditText) view.findViewById(R.id.edit_text_out);
        mSendButton = (Button) view.findViewById(R.id.button_send);
        //scratch
        //define
        mStartButton = (Button) view.findViewById(R.id.startbutton);
        mStopButton = (Button) view.findViewById(R.id.stopbutton);
        mBackButton = (Button) view.findViewById(R.id.backbutton);
        mGreenButton = (Button) view.findViewById(R.id.greenbutton);
        mRedButton = (Button) view.findViewById(R.id.redbutton);
        mBatteryView = (TextView) view.findViewById(R.id.battery_View);
        mSendSeekBar = (SeekBar) view.findViewById(R.id.seekBar);
        mAccx = (ProgressBar) view.findViewById(R.id.acc_x);
        mAccy = (ProgressBar) view.findViewById(R.id.acc_y);
        mAccz = (ProgressBar) view.findViewById(R.id.acc_z);

        //function
        mSendSeekBar.setMax(100 * 2);
        mSendSeekBar.setProgress(100);
        mSendSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            // トグルがドラッグされると呼ばれる
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                progress = progress - 100;
                mAIChat.motor_run(progress);
                float data = mAIChat.get_Duty();
                //mConversationArrayAdapter.add("Duty:  " + data);
                //mAIChat.get_Data();
            }

            // トグルがタッチされた時に呼ばれる
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            // トグルがリリースされた時に呼ばれる
            public void onStopTrackingTouch(SeekBar seekBar) {
            }

        });
    }

    /**
     * Set up the UI and background operations for chat.
     */
    private void setupChat() {
        Log.d(TAG, "setupChat()");

        // Initialize the array adapter for the conversation thread
        mConversationArrayAdapter = new ArrayAdapter<String>(getActivity(), R.layout.message);

        mConversationView.setAdapter(mConversationArrayAdapter);

        // Initialize the compose field with a listener for the return key
        mOutEditText.setOnEditorActionListener(mWriteListener);

        // Initialize the send button with a listener that for click events
        mSendButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // Send a message using content of the edit text widget
                View view = getView();
                if (null != view) {
                    TextView textView = (TextView) view.findViewById(R.id.edit_text_out);
                    String message = textView.getText().toString();
                    sendMessage(message);
                }
            }
        });

        // Initialize the send button with a listener that for click events
        mStartButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                mAIChat.motor_run(100);
                float data = mAIChat.get_Duty();
                mConversationArrayAdapter.add("Duty: " + data);
            }
        });

        // Initialize the send button with a listener that for click events
        mStopButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                mAIChat.motor_run(0);
                float data = mAIChat.get_Duty();
                mConversationArrayAdapter.add("Duty:  " + data);
            }
        });

        // Initialize the send button with a listener that for click events
        mBackButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                mAIChat.motor_run(-100);
                float data = mAIChat.get_Duty();
                mConversationArrayAdapter.add("Duty:  " + data);
            }
        });

        // Initialize the send button with a listener that for click events
        mGreenButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                if(mGLEDstate == Boolean.FALSE){
                    mAIChat.led_g_switch(Boolean.TRUE);
                    mGLEDstate = Boolean.TRUE;
                }else{
                    mAIChat.led_g_switch(Boolean.FALSE);
                    mGLEDstate = Boolean.FALSE;
                }
            }
        });

        // Initialize the send button with a listener that for click events
        mRedButton.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                if(mRLEDstate == Boolean.FALSE){
                    mAIChat.led_r_switch(Boolean.TRUE);
                    mRLEDstate = Boolean.TRUE;
                }else{
                    mAIChat.led_r_switch(Boolean.FALSE);
                    mRLEDstate = Boolean.FALSE;
                }
            }
        });


        mAIChat = new AI_CHIP(getActivity(), mHandler);
        // Initialize the buffer for outgoing messages
        mOutStringBuffer = new StringBuffer("");
    }

    /**
     * Makes this device discoverable.
     */
    private void ensureDiscoverable() {
        if (mBluetoothAdapter.getScanMode() !=
                BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE) {
            Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
            discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
            startActivity(discoverableIntent);
        }
    }


    /**
     * Sends a message.
     *
     * @param message A string of text to send.
     */
    private void sendMessage(String message) {
        // Check that we're actually connected before trying anything

        if (mAIChat.getState() != BluetoothChatService.STATE_CONNECTED) {
            Toast.makeText(getActivity(), R.string.not_connected, Toast.LENGTH_SHORT).show();
            return;
        }

        // Check that there's actually something to send
        if (message.length() > 0) {
            // Get the message bytes and tell the BluetoothChatService to write
            byte[] send = message.getBytes();
            //mAIChat.write(send);

            //scratch
            String get = new String(send);
            Log.d(TAG,"Send Message -> " + get);

            byte[] mSend = {99,109,100,0,0,0,0,0,0,0};

            if(get.equals("get")){
                float data = mAIChat.get_Angle();
                Log.d(TAG, "data -> "+String.valueOf(data));
                //float[] data = mAIChat.get_Mag();
                /*
                Log.d(TAG, "x data -> " + data[0]);
                Log.d(TAG, "y data -> " + data[1]);
                Log.d(TAG, "z data -> " + data[2]);
                */
            }
            if(get.equals("set")){
                mAIChat.set_Gyro();
            }
            if(get.equals("0")){
                mAIChat.motor_run((short)0);
            }
            if(get.equals("gon")){
                mAIChat.led_g_switch(Boolean.TRUE);
            }
            if(get.equals("goff")){
                mAIChat.led_g_switch(Boolean.FALSE);
            }
            if(get.equals("ron")){
                mAIChat.led_r_switch(Boolean.TRUE);
            }
            if(get.equals("roff")){
                mAIChat.led_r_switch(Boolean.FALSE);
            }
            if(get.equals("gf")){
                mAIChat.led_g_flash((short) 100, (short) 100);
            }
            if(get.equals("rf")){
                mAIChat.led_r_flash((short) 100,(short)100);
            }
            //mSend = {0,0,0,0,0,0,0,0,0,0};
            //mAIChat.write(mSend);

            // Reset out string buffer to zero and clear the edit text field
            mOutStringBuffer.setLength(0);
            mOutEditText.setText(mOutStringBuffer);
        }else{
            // インテント作成
            Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH); // ACTION_WEB_SEARCH
            intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
            intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "VoiceRecognitionTest"); // お好きな文字に変更できます
            // インテント発行
            Log.d(TAG, "intent_result");
            startActivityForResult(intent, REQUEST_CODE);
        }
    }

    /**
     * The action listener for the EditText widget, to listen for the return key
     */
    private TextView.OnEditorActionListener mWriteListener
            = new TextView.OnEditorActionListener() {
        public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
            // If the action is a key-up event on the return key, send the message
            if (actionId == EditorInfo.IME_NULL && event.getAction() == KeyEvent.ACTION_UP) {
                String message = view.getText().toString();
                sendMessage(message);
            }
            return true;
        }
    };

    /**
     * Updates the status on the action bar.
     *
     * @param resId a string resource ID
     */
    private void setStatus(int resId) {
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        final ActionBar actionBar = activity.getActionBar();
        if (null == actionBar) {
            return;
        }
        actionBar.setSubtitle(resId);
    }

    /**
     * Updates the status on the action bar.
     *
     * @param subTitle status
     */
    private void setStatus(CharSequence subTitle) {
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        final ActionBar actionBar = activity.getActionBar();
        if (null == actionBar) {
            return;
        }
        actionBar.setSubtitle(subTitle);
    }

    /**
     * The Handler that gets information back from the BluetoothChatService
     */
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            FragmentActivity activity = getActivity();
            switch (msg.what) {
                case Constants.MESSAGE_STATE_CHANGE:
                    switch (msg.arg1) {
                        case BluetoothChatService.STATE_CONNECTED:
                            setStatus(getString(R.string.title_connected_to, mConnectedDeviceName));
                            mConversationArrayAdapter.clear();
                            break;
                        case BluetoothChatService.STATE_CONNECTING:
                            setStatus(R.string.title_connecting);
                            break;
                        case BluetoothChatService.STATE_LISTEN:
                        case BluetoothChatService.STATE_NONE:
                            setStatus(R.string.title_not_connected);
                            break;
                    }
                    break;
                case Constants.MESSAGE_WRITE:
                    byte[] writeBuf = (byte[]) msg.obj;
                    // construct a string from the buffer
                    String writeMessage = new String(writeBuf);
                    //mConversationArrayAdapter.add("Me:  " + writeMessage);
                    break;
                case Constants.MESSAGE_READ:
                    //Get sensor data here.
                    byte[] readBuf = (byte[]) msg.obj;
                    // construct a string from the valid bytes in the buffer
                    String readMessage = new String(readBuf, 0, msg.arg1);
                    //mConversationArrayAdapter.add(mConnectedDeviceName + ":  " + readMessage);
                    String battery = String.valueOf(mAIChat.get_battery());
                    mBatteryView.setText(battery + "V");
                    float[] acc_data = mAIChat.get_ACC();
                    int[] acc = {0,0,0};
                    acc[0]= (int) (100 * (acc_data[0] * 2048 + 32767) / 65536);
                    mAccx.setProgress(acc[0]);
                    acc[1] = (int) (100 * (acc_data[1] * 2048 + 32767) / 65536);
                    mAccy.setProgress(acc[1]);
                    acc[2] = (int) (100 * (acc_data[2] * 2048 + 32767) / 65536);
                    mAccz.setProgress(acc[2]);

                    break;
                case Constants.MESSAGE_DEVICE_NAME:
                    // save the connected device's name
                    mConnectedDeviceName = msg.getData().getString(Constants.DEVICE_NAME);
                    if (null != activity) {
                        Toast.makeText(activity, "Connected to "
                                + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
                    }
                    break;
                case Constants.MESSAGE_TOAST:
                    if (null != activity) {
                        Toast.makeText(activity, msg.getData().getString(Constants.TOAST),
                                Toast.LENGTH_SHORT).show();
                    }
                    break;
            }
        }
    };

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case REQUEST_CODE:
                if (resultCode == Activity.RESULT_OK) {
                    String resultsString = "";
                    //Log.d(TAG, "request_code!!!");
                    // 結果文字列リスト
                    ArrayList<String> results = data.getStringArrayListExtra(
                            RecognizerIntent.EXTRA_RESULTS);

                    for (int i = 0; i < results.size(); i++) {
                        // ここでは、文字列が複数あった場合に結合しています
                        resultsString += results.get(i);
                    }

                    // トーストを使って結果を表示
                    Toast.makeText(getActivity(), results.get(0), Toast.LENGTH_LONG).show();
                    if(results.get(0).equals("動け")) {
                        mAIChat.motor_run(100);
                    }
                    if(results.get(0).equals("池")) {
                        mAIChat.motor_run(100);
                    }
                    if(results.get(0).equals("行け")) {
                        mAIChat.motor_run(100);
                    }
                    if(results.get(0).equals("go")) {
                        mAIChat.motor_run(100);
                    }
                    if(results.get(0).equals("ゆっくり")) {
                        mAIChat.motor_run(50);
                    }
                    if(results.get(0).equals("GO")) {
                        mAIChat.motor_run(100);
                    }
                    if(results.get(0).equals("ストップ")) {
                        mAIChat.motor_run(0);
                    }
                    if(results.get(0).equals("stop")) {
                        mAIChat.motor_run(0);
                    }
                    if(results.get(0).equals("止まれ")) {
                        mAIChat.motor_run(0);
                    }
                    if(results.get(0).equals("誉")) {
                        mAIChat.motor_run(0);
                    }
                    if(results.get(0).equals("もどれ")) {
                        mAIChat.motor_run(-100);
                    }
                    if(results.get(0).equals("戻れ")) {
                        mAIChat.motor_run(-100);
                    }
                    if(results.get(0).equals("back")) {
                        mAIChat.motor_run(-100);
                    }
                    if(results.get(0).equals("バック")) {
                        mAIChat.motor_run(-100);
                    }

                }
                break;

            case REQUEST_CONNECT_DEVICE_SECURE:
                // When DeviceListActivity returns with a device to connect
                if (resultCode == Activity.RESULT_OK) {
                    connectDevice(data, true);
                }
                break;
            case REQUEST_CONNECT_DEVICE_INSECURE:
                // When DeviceListActivity returns with a device to connect
                if (resultCode == Activity.RESULT_OK) {
                    connectDevice(data, false);
                }
                break;
            case REQUEST_ENABLE_BT:
                // When the request to enable Bluetooth returns
                if (resultCode == Activity.RESULT_OK) {
                    // Bluetooth is now enabled, so set up a chat session
                    setupChat();
                } else {
                    // User did not enable Bluetooth or an error occurred
                    Log.d(TAG, "BT not enabled");
                    Toast.makeText(getActivity(), R.string.bt_not_enabled_leaving,
                            Toast.LENGTH_SHORT).show();
                    getActivity().finish();
                }
        }
    }

    /**
     * Establish connection with other divice
     *
     * @param data   An {@link Intent} with {@link DeviceListActivity#EXTRA_DEVICE_ADDRESS} extra.
     * @param secure Socket Security type - Secure (true) , Insecure (false)
     */
    private void connectDevice(Intent data, boolean secure) {
        // Get the device MAC address
        String address = data.getExtras()
                .getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);
        // Get the BluetoothDevice object
        BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
        // Attempt to connect to the device
        mAIChat.connect(device, secure);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        inflater.inflate(R.menu.bluetooth_chat, menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case R.id.secure_connect_scan: {
                // Launch the DeviceListActivity to see devices and do scan
                Intent serverIntent = new Intent(getActivity(), DeviceListActivity.class);
                startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE_SECURE);
                return true;
            }
            case R.id.insecure_connect_scan: {
                // Launch the DeviceListActivity to see devices and do scan
                Intent serverIntent = new Intent(getActivity(), DeviceListActivity.class);
                startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE_INSECURE);
                return true;
            }
            case R.id.discoverable: {
                // Ensure this device is discoverable by others
                ensureDiscoverable();
                return true;
            }
        }
        return false;
    }

}
