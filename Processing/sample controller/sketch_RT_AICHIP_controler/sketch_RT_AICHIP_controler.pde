/**
 * @file   sketch_RT_AICHIP_controler.pde
 * @brief  AICHIPにコマンドを送りLEDの点灯状態,motorのduty比などをコントロールする <br>
 *         controlP5というライブラリを使用しているのでimportすること <br>
 *         メニューバーのSketch >Import Library > AddLibraryから追加が可能<br>
 *         Processing 2.2.1での動作推奨<br>
 *         Processing2.2.1にはExport機能で実行ファイルを出力してもSerial通信関係のライブラリが正常に機能しないバグがあり. <br>
 *
 * @author RTCorp. Ryota Takahashi
 */
/////////////////////////////
//各種importファイル
/////////////////////////////
import processing.serial.*;
import controlP5.*;           //Sketch >Import Library > AddLibraryから追加が可能

///////////////////////////////////////
//変数宣言
///////////////////////////////////////
ComPortConnection comp;
Serial port;

boolean flag_DISCONNECT_button_created = false;
boolean flag_CONNECT_button_created    = false;
String com_port;  
Knob duty_nob;

int state_l_led = 0;
int state_r_led = 0;


/**
 * プログラム起動時に一度だけ呼ばれる処理
 *         <ul>
 *          <li>ボタン等のUIを使用するためのクラス </li>
 *          <li>画面等の初期化 </li>
 *         </ul>
 *
 * @param void
 * @return void
 */
void setup() 
{
  //画面等の初期化
  background(0);
  frameRate(60);
  PFont pfont = createFont("Arial", 20, true); 
  ControlFont font = new ControlFont(pfont, 241);
  textSize(20);
  size(500, 500);

//ボタン等のUIを使用するためのクラス
  ControlP5 cp5 = new ControlP5(this);
  comp  = new ComPortConnection(20, 20, "COM4", cp5);

  //モータduty決定用のノブ
  duty_nob = cp5.addKnob("DUTY")
    .setRange(-32767, 32767)
      .setValue(0)
        .setPosition(100, 150)
          .setRadius(150)
            .setDragDirection(Knob.HORIZONTAL)
              .setLabelVisible(true)
                ;

  cp5.getController("DUTY")
    .getCaptionLabel()
      .setFont(font)
        .toUpperCase(false)
          .setSize(24) 
            ;      
  cp5.getController("DUTY")
    .getValueLabel()
      .setFont(font)
        .toUpperCase(false)
          .setSize(24) 
            ;      
  //左LEDの状態決定用のボタン
   cp5.addButton("L_LED")
        .setPosition(25, 150)
          .setSize(80, 40)
            .setColorForeground(0xffaa0000)
              .setColorBackground(0xff660000)
            ;

   cp5.getController("L_LED")
      .getCaptionLabel()
        .setFont(font)
          .toUpperCase(false)
            .setSize(24)
              ;      
  //右LEDの状態決定用のボタン
   cp5.addButton("R_LED")
        .setPosition(385, 150)
          .setSize(80, 40)
            .setColorForeground(0xaaaaff00)
              .setColorBackground(0xaa66ff00)
            ;

   cp5.getController("R_LED")
      .getCaptionLabel()
        .setFont(font)
          .toUpperCase(false)
            .setSize(24)
              ;      

}

/**
 * frameの描画の度に呼ばれる<br>
 *  <ul>
 *    <li>背景を塗りつぶし<li>
 *  </ul>
 *
 * @param void
 * @return void
 */
void draw()
{  
  //背景を塗りつぶし
  background(0);
  comp.updateUI();   
}  



/**
 * ボタンが押されるたびに呼ばれる<br>
 *
 * @param void
 * @return void
 */
public void controlEvent(ControlEvent theEvent) {

  //CONNECTボタンを押したときの処理
  if (theEvent.getController().getName() == "CONNECT"  )
  {
    if (flag_CONNECT_button_created == true) {
      try {
        port = new Serial(this, com_port, 115200);  // select port
        println("接続に成功しました.");
        comp.changeBoxColor(color(200, 50, 50, 100));
      }
      catch (RuntimeException e) {
        println("COM portが開けません.");
        comp.changeBoxColor(color(0, 155, 255, 50));
      }
    }

    if (flag_CONNECT_button_created == false) flag_CONNECT_button_created = true;
  }
  //DISCONNECTボタンを押したときの処理
  if (theEvent.getController().getName() == "DISCONNECT" )
  {

    if (flag_DISCONNECT_button_created == true) {
      try {
        port.stop();
        println("接続を解除しました.");
        comp.changeBoxColor(color(0, 155, 255, 50));
        port = null;
      }
      catch (NullPointerException e) {
        println("接続の解除に失敗しました.");
        comp.changeBoxColor(color(0, 155, 255, 50));
      }
    }

    if (flag_DISCONNECT_button_created == false) flag_DISCONNECT_button_created = true;
  }
  //ノブの値を変更したときの処理
  if (theEvent.getController().getName() == "DUTY" ) {
    if (port != null) {
      port.write(command0( duty_nob.getValue() /32767.0 ));
      
      port.write(command1(0));
      port.write(command2(0));
    
      if(duty_nob.getValue()>0 ){
        port.write(command3( (int)(duty_nob.getValue()/327.67), 100 -  (int)(duty_nob.getValue()/327.67) ));
      }
      else{
        port.write(command4( -(int)(duty_nob.getValue()/327.67), 100 + (int)(duty_nob.getValue()/327.67) ));
      }
      
    }
  }
  //L_LEDボタンを押したときの処理
  if (theEvent.getController().getName() == "L_LED" )
  {
    port.write(command5(-145));
    state_l_led = 1 - state_l_led;
    port.write(command2(state_l_led));
  }
  //R_LEDボタンを押したときの処理
  if (theEvent.getController().getName() == "R_LED" )
  {
    state_r_led = 1 - state_r_led;
    port.write(command1(state_r_led)); 
  }
  
  
}

