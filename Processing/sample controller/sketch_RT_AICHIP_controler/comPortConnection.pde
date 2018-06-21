/**
 * @file   comPortConnection.pde
 * @brief   <br>
 *         COMポートの接続に関するUIの定義と描画を行う
 * @author RTCorp. Ryota Takahashi
 */

/**
 * COMポート接続に関するUI群のクラス
 */
class ComPortConnection {
  int x;
  int y;
  color color_box;
  Textfield tf;
  ControlP5 _cp5;


  /**
   *  コンストラクタで表示座標,デフォルトで表示する文字列を指定する.
   *  @param x_ 表示位置x
   *  @param y_ 表示位置y
   *  @param default_comPort テキストボックスにデフォルトで表示される文字列
   *  @param contp5 表示フレーム内で定義されているControlP5の参照
   */
  ComPortConnection(int x_, int y_, String default_comPort,  ControlP5 contp5) {

    x = x_;
    y = y_;
    color_box = color(0, 155, 255, 50);
    _cp5 = contp5;
    PFont pfont = createFont("Arial", 20, true); 
    ControlFont font = new ControlFont(pfont, 241);

    _cp5.addButton("CONNECT")
      .setValue(1)
        .setPosition(x+10, y+10)
          .setSize(200, 40)
            ;

    _cp5.getController("CONNECT")
      .getCaptionLabel()
        .setFont(font)
          .toUpperCase(false)
            .setSize(24)
              ;      

  
    _cp5.addButton("DISCONNECT")
      .setValue(100)
        .setPosition(x+10, y+60)
          .setSize(200, 40)
            .updateSize()
              ;
    _cp5.getController("DISCONNECT")
      .getCaptionLabel()
        .setFont(font)
          .toUpperCase(false)
            .setSize(24)
              ;      


    tf = _cp5.addTextfield("COMPORT")
      .setPosition(x+220, y+40)
        .setSize(200, 40)
          .setFont(createFont("arial", 20))
            .setAutoClear(false)
              .setCaptionLabel("");
    ;
    tf.setText(default_comPort);
 
  }

  /**
   *  UIの更新処理,draw()内で呼ぶこと
   *  @param void
   *  @return void
   */
 void updateUI() {

    noFill(); //塗りつぶさない

    rectMode(CORNER);
    strokeWeight(5);
    stroke(color_box);
    smooth();
    rect(x, y, 450, 110);


    fill(255, 255, 255);
    textSize(20);
    com_port = tf.getText();

  }
  
  
  /**
   *  UIの囲み枠の色の変更
   *  @param col 囲み枠の色
   *  @return void
   */
  void changeBoxColor(color col){
    color_box = col;
  }

}


