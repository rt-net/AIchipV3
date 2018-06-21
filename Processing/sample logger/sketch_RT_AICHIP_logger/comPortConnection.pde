class ComPortConnection {
  int x;
  int y;
  color color_box;
  Textfield tf;
  ControlP5 _cp5;

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


 void drawUI() {

    f.s.noFill(); //塗りつぶさない

    f.s.rectMode(CORNER);
    f.s.strokeWeight(5);
    f.s.stroke(color_box);
    f.s.smooth();
    f.s.rect(x, y, 450, 110);


    f.s.fill(255, 255, 255);
    f.s.textSize(20);
    //text("input COM Port", x+230, y+30);
    com_port = tf.getText();

  }
  
  
  
  void changeBoxColor(color col){
    color_box = col;
  }

}


public void controlEvent(ControlEvent theEvent) {

  //println(theEvent.getController().getName());




  if (theEvent.getController().getName() == "CONNECT"  )
  {
    if (flag_CONNECT_button_created == true) {
      try {
        f.s.port = new Serial(this, com_port, 115200);  // select port
        println("接続に成功しました.");
        comp.changeBoxColor(color(200,50,50,100));
      }
      catch (RuntimeException e) {
        println("COM portが開けません.");
        comp.changeBoxColor(color(0, 155, 255, 50));
      }
    }

    if (flag_CONNECT_button_created == false) flag_CONNECT_button_created = true;
  }

  if (theEvent.getController().getName() == "DISCONNECT" )
  {

    if (flag_DISCONNECT_button_created == true) {
      try {
        f.s.port.stop();
        println("接続を解除しました.");
        comp.changeBoxColor(color(0, 155, 255, 50));
      }
      catch (NullPointerException e) {
        println("接続の解除に失敗しました.");
        comp.changeBoxColor(color(0, 155, 255, 50));
      }
    }

    if (flag_DISCONNECT_button_created == false) flag_DISCONNECT_button_created = true;
  }
}

