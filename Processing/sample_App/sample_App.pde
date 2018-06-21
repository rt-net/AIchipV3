//シリアル通信ライブラリを取り込む
import processing.serial.*;
//ポートのインスタンス
Serial port;
// シリアルポートから取得したデータ(Byte)
int inByte;
float m_duty = 0;

void setup(){
  //画面の設定
  size(100,100);
  //シリアルポート設定（Bluetoothのポート）
  //port=new Serial(this,"/dev/tty.RNBT-4EA9-RNI-SPP",115200); //Mac
  port=new Serial(this,"COM4",115200); //Windows
  port.write(command0(0));
}

void draw(){
  background(51);
}

void serialEvent(Serial p){
    // 設定したシリアルポートからデータを読み取り
    inByte = port.read();
    println(hex(inByte));
}

void keyPressed() {
if (key == CODED) {      // コード化されているキーが押された
    if (keyCode == LEFT) {  
      if(m_duty > -1){
        m_duty -= 0.1;
        //println(m_duty);
      }
      port.write(command0(m_duty));
    }else if(keyCode == RIGHT){
      if(m_duty < 1){
        m_duty += 0.1;
        //println(m_duty);
      }
      port.write(command0(m_duty));
    }
  }
}

void mousePressed(){
  byte[] command = new byte[10];
    //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   1;
  //値
  command[4] =  byte(1);
  //ダミー
  command[5] = 0;
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  port.write(command);
}

void mouseReleased(){
    byte[] command = new byte[10];
    //ヘッダー
  command[0] =  99;
  command[1] = 109;
  command[2] = 100;
  //id 
  command[3] =   1;
  //値
  command[4] =  byte(0);
  //ダミー
  command[5] = 0;
  command[6] = 0;
  command[7] = 0;
  command[8] = 0;
  command[9] = 0;
  port.write(command);
}

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
