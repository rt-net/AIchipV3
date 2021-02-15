
public class PFrame extends JFrame {
  SecondApplet s;


  public PFrame(int width, int height) {
    setBounds(100, 100, width, height);
    setLocationRelativeTo(null);
    s = new SecondApplet();
    s.setframesize(width,height);
    add(s);

    s.init();
    show();
    s.noLoop();
  }
}

public class SecondApplet extends PApplet {
  Serial port; 
  myTextarea mta1, mta2;
  
  int[] buf     = new int[100];
  int[] inByte  = new int[100];
  int width;
  int height;
//int[] ad_new  = new int[100];
//int[] ad_base = new int[100];

  ControlP5 cp5;
    PFont pfont = createFont("Arial", 20, true); 
    ControlFont font = new ControlFont(pfont, 241);

  public void setup() {
    size(width,height);
    cp5 = new ControlP5(this);
    
    background(0);
    noStroke();
    comp  = new ComPortConnection(20, 20, "COM28", cp5);
    mta1  = new myTextarea(20, 230, 200, 200, cp5, "mta1" );
    mta2  = new myTextarea(230, 230, 200, 200, cp5, "mta2" );
    
    mta1.println("Hello !");
    mta1.println("Here is Aprication console. ");
    mta2.println("Hello !!");
                 
  }

  public void draw() {
    background(0);
    
    mta1.update();
    mta2.update();
    comp.drawUI();
    
  }
  
  public void setframesize(int wid,int hei){
    width = wid;
    height = hei; 
  }
  
  public void controlEvent(ControlEvent theEvent) {
  
    println(theEvent.getController().getName());
  
    if (theEvent.getController().getName() == "CONNECT"  )
    {
      if (flag_CONNECT_button_created == true) {
        mta1.println("Now connecting ...");
  
        try {
          port = new Serial(this, com_port, 115200);  // select port
          mta1.println("Connection is successful");
          comp.changeBoxColor(color(200, 50, 50, 100));
        }
        catch (RuntimeException e) {
          mta1.println("Cannot open COM port.");
          comp.changeBoxColor(color(0, 155, 255, 50));
        }
      }
  
      if (flag_CONNECT_button_created == false) flag_CONNECT_button_created = true;
    }
  
    if (theEvent.getController().getName() == "DISCONNECT" )
    {  

      if (flag_DISCONNECT_button_created == true) {
        try {
          port.stop();
          mta1.println("Disconnected.");
          comp.changeBoxColor(color(0, 155, 255, 50));
        }
        catch (NullPointerException e) {
          mta1.println("Disconnecting is fail.");
          comp.changeBoxColor(color(0, 155, 255, 50));
        }
      }
  
      if (flag_DISCONNECT_button_created == false) flag_DISCONNECT_button_created = true;
    }
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


  int concatenate4Byte_uint(int byte0, int byte1, int byte2, int byte3) {
    return 0;
  }


  void serialEvent(Serial p)
  {
    String str = "d" ;
    if (port.available() != 0)
    {
      for (int i=42; i>=1; i--)
      {
        buf[i] = buf[i-1];
      }

      buf[0] = port.read();
      str = str(char(buf[0]));
      mta2.println(str +"  "+ str(buf[0])+"  "+hex(buf[0], 2)  );
    }
     

    //受信データの先頭4byteが0xff,0xff,0x52,0x54なのでこのパターンを目印に
    //データをinByteに格納し物理量に変換
    if (
           buf[39] == 0x54  
        && buf[40] == 0x52 
        && buf[41] == 0xff 
        && buf[42] == 0xff )
    {
      
      for (int i = 0; i <43; i ++) {
        inByte[i] = buf[42-i];
      }
      port.clear();

      //受信値を角速度ベクトルに変換
      omega_vec[0] = radians(((float)(concatenate2Byte_int(inByte[17], inByte[16]) ) )/16.4);
      omega_vec[1] = radians(((float)(concatenate2Byte_int(inByte[19], inByte[18]) ) )/16.4);
      omega_vec[2] = radians(((float)(concatenate2Byte_int(inByte[21], inByte[20]) ) )/16.4);
      gyro_graph.addPoint( degrees(omega_vec[0])/2000.0, degrees(omega_vec[1])/2000.0, degrees(omega_vec[2])/2000.0 );

      //受信値を加速度ベクトルに変換
      acc_vec[0]   = (float)(concatenate2Byte_int(inByte[9], inByte[8]))/2048.0; 
      acc_vec[1]   = (float)(concatenate2Byte_int(inByte[11], inByte[10]))/2048.0; 
      acc_vec[2]   = (float)(concatenate2Byte_int(inByte[13], inByte[12]))/2048.0;  
      acc_graph.addPoint( acc_vec[0]/4.0, acc_vec[1]/4.0, acc_vec[2]/4.0 );

      //受信値を温度に変換
      temperature = (float)(concatenate2Byte_int(inByte[15], inByte[14]))/340.0 + 35.0;
      temp_graph.addPoint(temperature/80.0);

      //受信値を地磁気ベクトルに変換
      mag_vec[0]   = (float)(concatenate2Byte_int(inByte[23], inByte[22])) * 0.3;  
      mag_vec[1]   = (float)(concatenate2Byte_int(inByte[25], inByte[24])) * 0.3; 
      mag_vec[2]   = (float)(concatenate2Byte_int(inByte[27], inByte[26])) * 0.3;
      mag_graph.addPoint( mag_vec[0]/600.0, mag_vec[1]/600.0, mag_vec[2]/600.0 );

      //受信値を角度に変換
      deg          = degrees((float)(concatenate2Byte_int(inByte[29], inByte[28])  ) * 2 *PI / 32767.0 ) ; 

      deg_graph.addPoint(deg/180.0);
      //受信値をdutyに変換
      duty         = (float)(concatenate2Byte_int(inByte[31], inByte[30])/32767.0 * 100.0);
      duty_graph.addPoint(duty/100.0);

      //受信値をStateに変換 
      isStop       = inByte[32];
      isCurve      = inByte[33];
      isSlope      = inByte[34];
      state_graph.addPoint( (float)(isStop)/3.5 + 3.0/7.0, (float)(isCurve)/3.5 - 1.0/7.0, (float)(isSlope)/3.5 + -5.0/7.0 );

      V_Lipo       = (float)(concatenate2Byte_uint(inByte[40], inByte[39]) / 13107.0 );
      V_Battery    = (float)(concatenate2Byte_uint(inByte[42], inByte[41]) / 13107.0 );
      voltage_graph.addPoint(V_Lipo/5.0, V_Battery/5.0);

      //ノルムの計算
      acc_norm = sqrt(acc_vec[0]*acc_vec[0]+acc_vec[1]*acc_vec[1]+acc_vec[2]*acc_vec[2]);
      mag_norm = sqrt(mag_vec[0]*mag_vec[0]+mag_vec[1]*mag_vec[1]+mag_vec[2]*mag_vec[2]);
    }
  
    
  }
   
}

