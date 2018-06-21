/**
 * @file   command.pde
 * @brief  AI-CHIPの各種コマンドを定義したファイル <br>
 *         AI-CHIPのコマンドは固定長10byteで書式は以下 <br>
 *         0byte目 99   (c) <br>
 *         1byte目 109  (m) <br>
 *         2byte目 100　(d) <br>
 *         3byte目 id　     <br>
 *         4byte目 -9byte目 データフィールド(使わないフィールドは0をセット) <br>
 *
 * @author RTCorp. Ryota Takahashi
 */

/**
 * id 0: dutyの変更コマンド
 *
 * @param duty dutyを-1.0から1.0で指定 <br>
 *             負の値はモーターを逆の方向に回す
 * @return 10byteのコマンド配列
 */
byte[] command0(float duty){
  byte[] command = new byte[10];
  int int_duty;
  int duty_L;
  int duty_H;
  
  int_duty = (int)(duty * 32767.0);
  if(int_duty<0)
  {
    int_duty += 65535;
  }
  duty_L = int_duty & 0x000000ff ;
  duty_H = (int_duty & 0x0000ff00)>>8;
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   0;
  //値
  command[4] = byte(duty_L);
  command[5] = byte(duty_H);
  //ダミー
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  
  return command;
}

/**
 * id 1: 右(緑)LEDの制御コマンド
 *
 * @param state 1:点灯 0:消灯 
 * @return 10byteのコマンド配列
 */
byte[] command1(int state){
  byte[] command = new byte[10];
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   1;
  //値
  command[4] =  byte(state);
  //ダミー
  command[5] = 0;
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  
  return command;
}

/**
 * id 2: 左(赤)LEDの制御コマンド
 *
 * @param state 1:点灯 0:消灯
 * @return 10byteのコマンド配列
 */
byte[] command2(int state){
  byte[] command = new byte[10];
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   2;
  //値
  command[4] = byte(state);
  //ダミー
  command[5] = 0;
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  
  return command;
}

/**
 * id 3 右(緑)LEDの点滅制御コマンド  
 *
 * @param 点滅時のon時間の指定 on_time[msec]
 * @param 点滅時のoff時間の指定 off_time[msec]
 * @return 10byteのコマンド配列
 */
byte[] command3(int on_time, int off_time){
  byte[] command = new byte[10];
  int int_duty;
  int on_time_L;
  int on_time_H;
  int off_time_L;
  int off_time_H;
  
  on_time_L = on_time & 0x000000ff ;
  on_time_H = (on_time & 0x0000ff00)>>8;
 
  off_time_L =  off_time & 0x000000ff ;
  off_time_H = (off_time & 0x0000ff00)>>8;
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   3;
  //値
  command[4] = byte(on_time_L);
  command[5] = byte(on_time_H);
  command[6] = byte(off_time_L);
  command[7] = byte(off_time_H);
  //ダミー
  command[8] = 0;
  command[9] = 0;
  
  return command;
}

/**
 * id 4 左(赤)LEDの点滅制御コマンド  
 *
 * @param 点滅時のon時間の指定 on_time[msec]
 * @param 点滅時のoff時間の指定 off_time[msec]
 * @return 10byteのコマンド配列
 */
byte[] command4(int on_time, int off_time){
  byte[] command = new byte[10];
  int int_duty;
  int on_time_L;
  int on_time_H;
  int off_time_L;
  int off_time_H;
  
  on_time_L = on_time & 0x000000ff ;
  on_time_H = (on_time & 0x0000ff00)>>8;
 
  off_time_L =  off_time & 0x000000ff ;
  off_time_H = (off_time & 0x0000ff00)>>8;
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   4;
  //値
  command[4] = byte(on_time_L);
  command[5] = byte(on_time_H);
  command[6] = byte(off_time_L);
  command[7] = byte(off_time_H);
  //ダミー
  command[8] = 0;
  command[9] = 0;
  
  return command;
}

/**
 * id 5: 車体角度の指定コマンド
 *
 * @param 車体角度を-180度から180度で指定 <br>
 * @return 10byteのコマンド配列
 */
byte[] command5(float deg){
  byte[] command = new byte[10];
  int int_deg;
  int deg_L;
  int deg_H;
  
  int_deg = (int)(deg/180.0 *32767);
  if(int_deg<0)
  {
    int_deg += 65535;
  }
  deg_L = int_deg & 0x000000ff ;
  deg_H = (int_deg & 0x0000ff00)>>8;
  
  //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   5;
  //値
  command[4] = byte(deg_L);
  command[5] = byte(deg_H);
  //ダミー
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  
  return command;
}


