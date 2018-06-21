package com.example.android.bluetoothchat;

/**
 * Created by nakagawayuki on 15/08/19.
 */

import java.lang.String;
import java.net.ConnectException;
import java.util.ArrayList;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;

public class AI_CHIP extends BluetoothChatService{
    // Debugging
    private static final String TAG = "AI_CHIP";

    //Member Val
    private int mGetData;
    public float[] mGyroref = {0,0,0};

    /**
     * Constructor. Prepares a new BluetoothChat session.
     *
     * @param context The UI Activity Context
     * @param handler A Handler to send messages back to the UI Activity
     */
    public AI_CHIP(Context context, Handler handler) {
        super(context, handler);
    }

    //ACC[0] =ACC_x
    //ACC[1] =ACC_y
    //ACC[2] =ACC_z
    public float[] get_ACC(){
        int start_byte = 8;
        int start_bit;
        float[] ACC = {0,0,0};
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return ACC;
        }

        for(int i = 0; i < 3; i++) {
            if(i != 0) {
                start_byte = start_byte + 2;
            }
            start_bit = start_byte * 2;
            String[] hexdata = {"0","0"};
            String data = get_Data();
            hexdata[0] = data.substring(start_bit+2,start_bit+4);
            hexdata[1] = data.substring(start_bit,start_bit+2);
            ACC[i] = (float)Integer.parseInt(hexdata[0]+hexdata[1],16);
            if(ACC[i] > 32767){
                ACC[i] -= 65536;
            }
            // System.out.println(ACC);
            ACC[i] = ACC[i] / 2048;

        }
        return ACC;
    }

    public float get_Temp(){
        int start_byte = 14;
        int start_bit = start_byte * 2;
        float Temp = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return Temp;
        }

        String[] hexdata = {"0","0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit+2,start_bit+4);
        hexdata[1] = data.substring(start_bit,start_bit+2);
        Temp = (float)Integer.parseInt(hexdata[0]+hexdata[1],16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        if(Temp > 32767){
            Temp -= 65536;
        }
        System.out.println(Temp);
        Temp = 35 + Temp / 340;
        return Temp;
    }

    public void set_Gyro(){
        int start_byte = 16;
        int start_bit;
        float[] Gyro = {0,0,0};

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }

        for(int i = 0; i < 3; i++) {
            if (i != 1) {
                start_byte = start_byte + 2;
            }
            start_bit = start_byte * 2;
            String[] hexdata = {"0","0"};
            String data = get_Data();
            hexdata[0] = data.substring(start_bit+2,start_bit+4);
            hexdata[1] = data.substring(start_bit,start_bit+2);
            System.out.println(hexdata[0]+hexdata[1]);
            Gyro[i] = (float)Integer.parseInt(hexdata[0]+hexdata[1],16);
            if(Gyro[i] > 32767){
                Gyro[i] = Gyro[i] - 65536;
            }
            // System.out.println(ACC);
            mGyroref[i] = Gyro[i];
            System.out.println("mGyroref["+i+"] = " + mGyroref[i]);
        }
    }

    //Gyro[0] =Gyro_x
    //Gyro[1] =Gyro_y
    //Gyro[2] =Gyro_z
    public float[] get_Gyro(){
        int start_byte = 16;
        int start_bit;
        float[] Gyro = {0,0,0};

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return Gyro;
        }

        for(int i = 0; i < 3; i++) {
            if (i != 1) {
                start_byte = start_byte + 2;
            }
            start_bit = start_byte * 2;
            String[] hexdata = {"0", "0"};
            String data = get_Data();
            hexdata[0] = data.substring(start_bit + 2, start_bit + 4);
            hexdata[1] = data.substring(start_bit, start_bit + 2);
            Gyro[i] = (float) Integer.parseInt(hexdata[0] + hexdata[1], 16);
            if (Gyro[i] > 32767) {
                Gyro[i] -= 65536;
            }
            // System.out.println(ACC);
            System.out.println("mGyroref[i] = " + (Gyro[i] - mGyroref[i]));
            Gyro[i] = (float) ((Gyro[i] - mGyroref[i]) / 16.4);

        }
        return Gyro;
    }


    //Mag[0] =Mag_x
    //Mag[1] =Mag_y
    //Mag[2] =Mag_z
    public float[] get_Mag(){
        int start_byte = 22;
        int start_bit;
        float[] Mag = {0,0,0};

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return Mag;
        }

        for(int i = 0; i < 3; i++) {
            if(i != 1) {
                start_byte = start_byte + 2;
            }
            start_bit = start_byte * 2;
            String[] hexdata = {"0","0"};
            String data = get_Data();
            hexdata[0] = data.substring(start_bit+2,start_bit+4);
            hexdata[1] = data.substring(start_bit,start_bit+2);
            Mag[i] = (float)Integer.parseInt(hexdata[0]+hexdata[1],16);
            if(Mag[i] > 32767){
                Mag[i] -= 65536;
            }
            // System.out.println(ACC);
            Mag[i] = (float) (0.3 * Mag[i]);
        }
        return Mag;
    }

    public float get_Angle() {
        int start_byte = 28;
        int start_bit = start_byte * 2;
        float angle = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return angle;
        }

        String[] hexdata = {"0", "0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit + 2, start_bit + 4);
        hexdata[1] = data.substring(start_bit, start_bit + 2);
        angle = (float) Integer.parseInt(hexdata[0] + hexdata[1], 16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        if (angle > 32767) {
            angle -= 65536;
        }
        System.out.println(angle);
        angle = (float) (angle * 2 * Math.PI * 32767);
        return angle;
    }

    public float get_Duty() {
        int start_byte = 30;
        int start_bit = start_byte * 2;
        float duty = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return duty;
        }

        String[] hexdata = {"0", "0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit + 2, start_bit + 4);
        hexdata[1] = data.substring(start_bit, start_bit + 2);
        duty = (float) Integer.parseInt(hexdata[0] + hexdata[1], 16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        if (duty > 32767) {
            duty -= 65536;
        }
        System.out.println(duty);
        duty = 100 * duty / 32767;
        return duty;
    }

    public float get_isStop() {
        int start_byte = 32;
        int start_bit = start_byte * 2;
        int isStop = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return isStop;
        }

        String hexdata = "0";
        String data = get_Data();
        hexdata = data.substring(start_bit, start_bit + 2);
        isStop = Integer.parseInt(hexdata, 16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        System.out.println(isStop);
        return isStop;
    }

    public float get_isCurve() {
        int start_byte = 33;
        int start_bit = start_byte * 2;
        int isCurve = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return isCurve;
        }

        String hexdata = "0";
        String data = get_Data();
        hexdata = data.substring(start_bit, start_bit + 2);
        isCurve = Integer.parseInt(hexdata, 16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        System.out.println(isCurve);
        return isCurve;
    }

    public float get_isSlope() {
        int start_byte = 34;
        int start_bit = start_byte * 2;
        int isSlope = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return isSlope;
        }

        String hexdata = "0";
        String data = get_Data();
        hexdata = data.substring(start_bit, start_bit + 2);
        isSlope = Integer.parseInt(hexdata, 16);
        //if(Integer.parseInt(data.substring(18, 19), 16) >= 8){
        System.out.println(isSlope);
        return isSlope;
    }

    public float get_Lipo() {
        int start_byte = 39;
        int start_bit = start_byte * 2;
        float Lipo = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return Lipo;
        }

        String[] hexdata = {"0", "0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit + 2, start_bit + 4);
        hexdata[1] = data.substring(start_bit, start_bit + 2);
        Lipo = (float) Integer.parseInt(hexdata[0] + hexdata[1], 16);

        System.out.println(Lipo);
        Lipo = Lipo / 13107;
        return Lipo;
    }

    public float get_Time() {
        int start_byte = 35;
        int start_bit = start_byte * 2;
        float Time = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return Time;
        }

        String[] hexdata = {"0", "0", "0", "0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit + 6, start_bit + 8);
        hexdata[1] = data.substring(start_bit + 4, start_bit + 6);
        hexdata[2] = data.substring(start_bit + 2, start_bit + 4);
        hexdata[3] = data.substring(start_bit, start_bit + 2);
        Time = (float) Integer.parseInt(hexdata[0] + hexdata[1] + hexdata[2] + hexdata[3], 16);

        System.out.println(Time);
        Time = Time / 13107;
        return Time;
    }

    public float get_battery() {
        int start_byte = 41;
        int start_bit = start_byte * 2;
        float battery = 0;

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return battery;
        }

        String[] hexdata = {"0", "0"};
        String data = get_Data();
        hexdata[0] = data.substring(start_bit + 2, start_bit + 4);
        hexdata[1] = data.substring(start_bit, start_bit + 2);
        battery = (float) Integer.parseInt(hexdata[0] + hexdata[1], 16);

        System.out.println(battery);
        battery = battery / 13107;
        return battery;
    }

    public String get_Data(){

        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return "";
        }

        Boolean loop = Boolean.TRUE;

        while(Boolean.TRUE) {
            byte[] bytes = super.getBuffer();
            //buffer = buffer << 64;
            //System.out.println(buffer[32]);
            //int data = 1;
            //return data;
            StringBuffer strbuf = new StringBuffer(bytes.length * 2);

            // バイト配列の要素数分、処理を繰り返す。
            for (int index = 0; index < bytes.length; index++) {
                // バイト値を自然数に変換。
                int bt = bytes[index] & 0xff;

                // バイト値が0x10以下か判定。
                if (bt < 0x10) {
                    // 0x10以下の場合、文字列バッファに0を追加。
                    strbuf.append("0");
                }

                // バイト値を16進数の文字列に変換して、文字列バッファに追加。
                mGetData = bt;
                strbuf.append(Integer.toHexString(mGetData));
            }
            int result = strbuf.toString().indexOf("ffff5254345700");
            if(result == -1){

            }else {
                System.out.println(strbuf.toString());
                /// 16進数の文字列を返す。
                //loop = Boolean.FALSE;
                return strbuf.toString();
            }
        }
        return "0";
    }

    public void motor_run(int duty){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 0;
        byte[] power = {0,0};

        int input_data =32767 * duty/100;
        if (input_data < 0) {
            input_data += 65536;
        }
        //System.out.println("Int -> " + input_data);
        power[0] = (byte) (0x000000ff & (input_data));
        power[1] = (byte) (0x000000ff & (input_data >>> 8));
        //System.out.println("power -> "+power[0] +", "+ power[1]);

        byte[] command = {99,109,100,id, (byte) power[0], power[1],0,0,0,0};
        super.write(command);
    }

    public void led_g_switch(Boolean flag){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 1;
        byte led = 0;

        if(flag == Boolean.TRUE){
            led  = 1;
        }else{
            led = 0;
        }
        byte[] command = {99,109,100,id,led,0,0,0,0,0};
        super.write(command);
    }

    public void led_r_switch(Boolean flag){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 2;
        byte led = 0;

        if(flag == Boolean.TRUE){
            led  = 1;
        }else{
            led = 0;
        }
        byte[] command = {99,109,100,id,led,0,0,0,0,0};
        super.write(command);
    }

    public void led_g_flash(short on_time, short off_time){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 3;
        byte[] time = {0,0,0,0};
        //Log.d("AI_CHIP", String.valueOf("on -> "+on_time));
        time[0] = (byte)(on_time  & 0x00ff);
        time[1] = (byte)((on_time & 0xff00)>>>8);
        time[2] = (byte)(off_time  & 0x00ff);
        time[3] = (byte)((off_time & 0xff00)>>>8);
        //byte[] command = makeCommand("test");
        byte[] command =  {99,109,100,id,time[0],time[1],time[2],time[3],0,0};
        super.write(command);
    }

    public void led_r_flash(short on_time, short off_time){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 4;
        byte[] time = {0,0,0,0};
        //Log.d("AI_CHIP", String.valueOf("on -> "+on_time));
        time[0] = (byte)(on_time  & 0x00ff);
        time[1] = (byte)((on_time & 0xff00)>>>8);
        time[2] = (byte)(off_time  & 0x00ff);
        time[3] = (byte)((off_time & 0xff00)>>>8);
        //byte[] command = makeCommand("test");
        byte[] command =  {99,109,100,id,time[0],time[1],time[2],time[3],0,0};
        super.write(command);
    }

    public void angle_set(short angle){
        if (super.getState() != BluetoothChatService.STATE_CONNECTED) {
            return;
        }
        byte id = 5;
        byte[] set_angle = {0,0};
        if(angle >= 0){
            int input_data = (int)(32767 * (float)angle/180 );//32767
            //Log.d(TAG, String.valueOf("seekbar -> "+input_data));
            String data_string = Integer.toBinaryString(input_data);
            //Log.d("AI_CHIP", String.valueOf("data_string -> "+data_string));

            set_angle[0] = (byte)(input_data  & 0x00ff);
            set_angle[1] = (byte)((input_data & 0xff00)>>>8);

        }else{
            short input_data = (short) ((float)32767 * (float) angle /180);//32767
            //input_data += 65535;
            //Log.d(TAG, String.valueOf("seekbar ->"+input_data));
            set_angle[0] = (byte)(input_data & 0x00ff);
            set_angle[1] = (byte)((input_data & 0xff00) >>> 8);

        }

        byte[] command = {99,109,100,id,set_angle[0],set_angle[1],0,0,0,0};
        super.write(command);
    }
}
