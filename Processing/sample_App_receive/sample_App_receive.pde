import processing.serial.*;
import processing.opengl.*;

Serial port; 
int[] buf     = new int[100];
int[] inByte  = new int[100];

String byte_info[] = {
  "ヘッダー", //0  byte
  " ", 
  " ", 
  " ", 
  "製品固有識別子L", //4  byte
  "製品固有識別子H", //5  byte
  "製品バージョン", //6  byte  
  "タイムスタンプ", //7  byte
  "ACC X", //8  byte
  " ", 
  "ACC Y", //10 byte
  " ", 
  "ACC Z", //12 byte
  " ", 
  "TEMP", //14 byte
  " ", 
  "GYRO X", //16 byte
  " ", 
  "GYRO Y", //18 byte
  " ", 
  "GYRO Z", //20 byte
  " ", 
  "MAG X", //22 byte
  " ", 
  "MAG Y", //24 byte
  " ", 
  "MAG Z", //26 byte
  " ", 
  "角度",  //28 byte
  " ", 
  "duty ", //30 byte
  " ", 
  "isStop ", //32 byte
  "isCurve", //33 byte
  "isSlope", //34 byte
  "経過時間",//35 byte
  " ",
  " ",
  " ", 
  "Lipo電圧 ", //39byte
  " ",
  "モーター電圧",//41byte
  " ",
};
float[] omega_vec         = {
  0.0, 0.0, 0.0
};           //角速度ベクトル (x,y,z)[rad]
float[] acc_vec           = {
  0.0, 0.0, 0.0
};           //加速度ベクトル (x,y,z) [g]
float[] mag_vec           = {
  0.0, 0.0, 0.0
};           //地磁気ベクトル (x,y,z) [uT]

float   acc_norm          = 0.0;                       //加速度ベクトルのノルム 
float   mag_norm          = 0.0;                       //地磁気ベクトルのノルム
float   mag_cor_norm      = 0.0;                       //補正した地磁気ベクトルのノルム
float   temperature       = 0.0;                       //センサ温度[度C]
float   voltage_Bat       = 0.0;                       //バッテリー電圧
float   voltage_Lipo      = 0.0;                       //Lipo電圧 
int     isSlope           =0;                          //AIチップの姿勢を表す変数 坂
int     isStop            =0;                          //AIチップの姿勢を表す変数 静止
int     isCurve           =0;                          //AIチップの姿勢を表す変数 カーブ

long    time              = 0;                          //経過時間[ms]


//起動時に一回だけ呼ばれる
void setup() 
{
  size(650, 600, P3D);
  frameRate(60);
  println(Serial.list());
  port = new Serial(this, "COM4", 115200);  // 認識されているCOMポートに応じて変更してください
}

//60fpsで描画するので1秒に60回呼ばれる
void draw()
{
  background(0);  
  writeSenValue();

}

//COMポートで受信したときに呼ばれる関数
void serialEvent(Serial p)
{

  if (port.available() != 0)
  {
    for (int i=43; i>=1; i--)
    {
      buf[i] = buf[i-1];
    }
    buf[0] = port.read();
   
}

  //受信データの先頭4byteが0xff,0xff,0x52,0x54なのでこのパターンを目印に
  //データをinByteに格納し物理量に変換
  // 0xff,0xff,0x52,0x54のパターンが現れるのは10msec毎
  if (
  buf[39] == 0x54  
    && buf[40] == 0x52 
    && buf[41] == 0xff 
    && buf[42] == 0xff )
  {
  
    for (int i = 0; i < 43; i ++)
    {
      inByte[i] = buf[42-i];
    }
    port.clear();

    //コンソールに受信データを表示
    println("=================="); 
    println("Byte", "16進", "10進", "結合データ(符号なし)", "結合データ(符号付)", "リファレンス");

    for (int i = 0; i<43; i++)
    {
      if (i<=9)
      {
        if (i %2 == 0 && i> 7 ) println(i, "   ", hex(inByte[i], 2), inByte[i], inByte[i] + (inByte[i+1]<<8), byte_info[i]);
        else println(i, "   ", hex(inByte[i], 2), inByte[i], byte_info[i]);
      } else
      {
        if (i %2 == 0 && i> 7 ) println(i, "  ", hex(inByte[i], 2), inByte[i], inByte[i] + (inByte[i+1]<<8), byte_info[i] );
        else println(i, "  ", hex(inByte[i], 2), inByte[i], byte_info[i] );
      }
    }

    //センサ値を角加速度ベクトルに変換
    omega_vec[0] = radians(((float)(concatenate2Byte_int(inByte[17], inByte[16]) ) )/16.4);
    omega_vec[1] = radians(((float)(concatenate2Byte_int(inByte[19], inByte[18]) ) )/16.4);
    omega_vec[2] = radians(((float)(concatenate2Byte_int(inByte[21], inByte[20]) ) )/16.4);
    //センサ値を加速度ベクトルに変換
    acc_vec[0]   = (float)(concatenate2Byte_int(inByte[9], inByte[8]))/2048.0; 
    acc_vec[1]   = (float)(concatenate2Byte_int(inByte[11], inByte[10]))/2048.0; 
    acc_vec[2]   = (float)(concatenate2Byte_int(inByte[13], inByte[12]))/2048.0;  
    acc_norm = sqrt(acc_vec[0]*acc_vec[0]+acc_vec[1]*acc_vec[1]+acc_vec[2]*acc_vec[2]);
    //センサ値を地磁気ベクトルに変換
    mag_vec[0]   = (float)(concatenate2Byte_int(inByte[23], inByte[22])) * 0.3;  
    mag_vec[1]   = (float)(concatenate2Byte_int(inByte[25], inByte[24])) * 0.3; 
    mag_vec[2]   = (float)(concatenate2Byte_int(inByte[27], inByte[26])) * 0.3;
    mag_norm = sqrt(mag_vec[0]*mag_vec[0]+mag_vec[1]*mag_vec[1]+mag_vec[2]*mag_vec[2]);
    //センサ値を温度に変換
    temperature = (float)(concatenate2Byte_int(inByte[15], inByte[14]))/340 + 35.0;
    //AIミニ四駆の姿勢を得る
    isStop  = inByte[32];
    isCurve = inByte[33];
    isSlope = inByte[34];
    
    //センサ値を電圧に変換
    voltage_Lipo = (float)(concatenate2Byte_uint(inByte[40], inByte[39]) / 13107.0 );
    //センサ値を電圧に変換
    voltage_Bat = (float)(concatenate2Byte_uint(inByte[42], inByte[41]) / 13107.0 );
    //センサ値を電圧に変換
    time = inByte[35] + (inByte[36]<<8) + (inByte[37]<<16) + (inByte[38]<<24);   
  }
}

//画面上に各センサの出力値を描画
void writeSenValue()
{
  fill(255, 255, 255);
  textSize(20);
  text("accX[g]", 10, 20);
  text("accY[g]", 10, 40);
  text("accZ[g]", 10, 60);
  text("|a|=", 10, 80);
  text(acc_vec[0], 90, 20);
  text(acc_vec[1], 90, 40);
  text(acc_vec[2], 90, 60); 
  text(acc_norm, 60, 80); 

  text("magX[uT]", 180, 20);
  text("magY[uT]", 180, 40);
  text("magZ[uT]", 180, 60);
  text("|m|=", 180, 80);
  text(mag_vec[0], 300, 20);
  text(mag_vec[1], 300, 40);
  text(mag_vec[2], 300, 60);  
  text(mag_norm, 230, 80);  

  text("omegaX[deg/s]", 400, 20);
  text("omegaY[deg/s]", 400, 40);
  text("omegaZ[deg/s]", 400, 60);
  text(degrees(omega_vec[0]), 550, 20);
  text(degrees(omega_vec[1]), 550, 40);
  text(degrees(omega_vec[2]), 550, 60); 

  text(temperature, 400, 80);
  text("[degree C]", 500, 80);

  text(voltage_Bat, 170, 100);
  text("Voltage_Bat [V]", 10, 100);
  
  text(voltage_Lipo, 170, 120);
  text("Voltage_Lipo [V]", 10, 120);
  
  text(isSlope, 160, 140);
  text("isSlope", 10, 140);
  text(isCurve, 160, 160);
  text("isCurve", 10, 160);
  text(isStop,  160, 180);
  text("isStop",  10, 180);
  text(time,    160, 200);
  text("time[ms]",  10, 200);
  
  
}

int concatenate2Byte_int(int H_byte, int L_byte) {
  int con; 
  con = L_byte + (H_byte<<8);
  if (con > 32767) {
    con -=  65536;
  }
  return con;
}


int concatenate2Byte_uint(int H_byte, int L_byte) {
  int con; 
  con = L_byte + (H_byte<<8);
  return con;
}






