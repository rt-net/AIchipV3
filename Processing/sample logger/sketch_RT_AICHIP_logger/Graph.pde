/**
 * @file   Graph.pde
 * @brief  グラフを表示するための抽象クラス<br>
 *         各種グラフはGraphクラスを継承して作成 <br>
 *         3本までの波形を表示可能 
 * @author Ryota Takahashi
 */


/**
 *  グラフの表示用の抽象クラス
 */
abstract class Graph {
  int point_num = 72000;

  int graph_x;
  int graph_y;

  int width_graph;
  int height_graph;
  int v_divide_num;
  int h_divide_num;
  color color_graph;
  String name_graph;

  boolean flag_valsX_visible = true; 
  boolean flag_valsY_visible = true;
  boolean flag_valsZ_visible = true;

  int graph_end;

  int[] valsX;
  int[] valsY;
  int[] valsZ;
  ControlP5  _cp5;  
  Range range;

  float range_L = 0.0;
  float range_H = 30.0;

  /**
   *  コンストラクタで表示座標, 線の弾き方等を渡す
   *  @param x_ 表示位置x
   *  @param y_ 表示位置y
   *  @param wd_graph グラフの横幅
   *  @param he_graph グラフの縦幅
   *  @param v_div_num グラフの縦線の分割数
   *  @param h_div_num グラフの横線の分割数
   *  @param col グラフの色
   *  @param na_graph グラフの名前(重複禁止)
   *  @param contp5 表示フレーム内で定義されているControlP5の参照
   */
  Graph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    graph_x = x_;
    graph_y = y_;
    width_graph  = wd_graph;
    height_graph = he_graph;
    v_divide_num = v_div_num;
    h_divide_num = h_div_num;
    color_graph = col;
    name_graph = na_graph;

    valsX = new int[point_num];
    valsY = new int[point_num];
    valsZ = new int[point_num];
    graph_end = 0;
    _cp5 = contp5;
  }


  /**
   *  表示するグラフを変更
   *  @param en_valsX
   *  @param en_valsY
   *  @param en_valsZ
   *  @return void
   */
  void setEnValsVisible(boolean en_valsX, boolean en_valsY, boolean en_valsZ) {
    flag_valsX_visible = en_valsX; 
    flag_valsY_visible = en_valsY;
    flag_valsZ_visible = en_valsZ;
  } 


  /**
   *  書きたいグラフに応じた処理を記述する抽象メソッド
   *
   *  @param  void
   *  @return void
   */
  abstract void customPart();

  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @param  Y_val 要素Yの値
   *  @param  Z_val 要素Zの値 
   *  @return void
   */
  void writeGraphVal(String name, float X_val, float Y_val, float Z_val) {
    textSize(20);
    text(name, graph_x, graph_y-4);

    fill(255, 0, 0, 200);
    text("■", graph_x+200, graph_y-8);
    fill(0, 255, 0, 200);
    text("■", graph_x+320, graph_y-8);
    fill(0, 0, 255, 200);
    text("■", graph_x+440, graph_y-8);

    fill(255, 255, 255, 255);
    text("X:", graph_x+220, graph_y-4);
    text("Y:", graph_x+340, graph_y-4);
    text("Z:", graph_x+460, graph_y-4);

    text(X_val, graph_x+240, graph_y-4);
    text(Y_val, graph_x+360, graph_y-4);
    text(Z_val, graph_x+480, graph_y-4);

    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }

  /**
   *  グラフの枠線,縦線,横線の描画
   *  @param  void 
   *  @return void
   */
  void drawFrame() {
    noFill(); //塗りつぶさない
    rectMode(CORNER);
    strokeWeight(5);
    smooth();

    //枠線の描画
    stroke(color_graph);
    rect(graph_x, graph_y, width_graph, height_graph);
    //センターラインの描画
    strokeWeight(3);
    line(graph_x, graph_y+ height_graph/2, graph_x + width_graph, graph_y+ height_graph/2 );
    //縦線の描画
    strokeWeight(1);
    int offset = 20-(int)((range_L - (float)((int)(range_L)))*20);
    
    for (int i=0; i<v_divide_num; i++) {
      line( offset  +  graph_x+i* width_graph/v_divide_num, graph_y, offset  +  graph_x+i* width_graph/v_divide_num, graph_y + height_graph);
    }
    //横線の描画
    for (int i=1; i<h_divide_num; i++) {
      line(graph_x, graph_y +i* height_graph/h_divide_num, graph_x + width_graph, graph_y +i* height_graph/h_divide_num );
    }
  }

  /**
   *  グラフの描画, draw()内で毎回呼ぶこと
   */
  void drawGraph() {
    //描画範囲を制限
    range_L = constrain(range_L,0,1770);
    range_H = constrain(range_H,30,1800);
    
    //グラフの外形の描画
    drawFrame();

    //グラフの描画    
    int num_point_selected_area = (int) ( 6000 * (range_H - range_L) /300.0 ) ; 
    int width_point2point =  width_graph / num_point_selected_area ;
    int index_L =  (int)(range_L*20.0);
    index_L = constrain(index_L,0,point_num);
 
    for ( int i = 0; i < num_point_selected_area -1; i++ ) {

      if (i + index_L  < graph_end   ) {
        strokeWeight(2);
        if ( flag_valsX_visible == true) {
          stroke(255, 0, 0, 200);
          line(graph_x+i* width_point2point, graph_y+ height_graph/2 - valsX[index_L+i], graph_x+(i+1) * width_point2point, graph_y+ height_graph/2 - valsX[index_L+i+1]);
        }
        if ( flag_valsY_visible == true) {
          stroke(0, 255, 0, 200);
          line(graph_x+i* width_point2point, graph_y+ height_graph/2 - valsY[index_L+i], graph_x+(i+1) * width_point2point, graph_y+ height_graph/2 - valsY[index_L+i+1]);
        }

        if ( flag_valsZ_visible == true) {
          stroke(0, 0, 255, 200);
          line(graph_x+i* width_point2point, graph_y+ height_graph/2 - valsZ[index_L+i], graph_x+(i+1) * width_point2point, graph_y+ height_graph/2 - valsZ[index_L+i+1]);
        }
      }
    }

    //グラフに応じた処理
    customPart();
  }


  /**
   *  グラフへの点の追加 <br>
   *  描画点は-1.0から1.0に正規化して代入 <br>
   *  -1.0から1.0の範囲外の点は-1.0もしくは1.0に変更して描画
   *  @param y_X 波形Xのy座標
   *  @param y_Y 波形Yのy座標
   *  @param y_Z 波形Zのy座標
   */
  void addPoint(float y_X, float y_Y, float y_Z ) {
    if (graph_end<point_num) {
      y_X = constrain(y_X, -1.0, 1.0);
      y_Y = constrain(y_Y, -1.0, 1.0);
      y_Z = constrain(y_Z, -1.0, 1.0);

      //グラフをセット
      valsX[graph_end] = (int)(y_X* height_graph/2.0);
      valsY[graph_end] = (int)(y_Y* height_graph/2.0);
      valsZ[graph_end] = (int)(y_Z* height_graph/2.0);

      if (graph_end > width_graph* 5/6) {
        range_L += 0.05;
        range_H += 0.05;
      }

      graph_end ++;
    }
  }

  /**
   *  グラフへの点の追加 <br>
   *  描画点は-1.0から1.0に正規化して代入 <br>
   *  -1.0から1.0の範囲外の点は-1.0もしくは1.0に変更して描画
   *  @param y_X 波形Xのy座標
   *  @param y_Y 波形Yのy座標
   */
  void addPoint(float y_X, float y_Y) {
    if (graph_end<point_num) {
      y_X = constrain(y_X, -1.0, 1.0);
      y_Y = constrain(y_Y, -1.0, 1.0);


      //グラフをセット
      valsX[graph_end] = (int)(y_X* height_graph/2.0);
      valsY[graph_end] = (int)(y_Y* height_graph/2.0);
      valsZ[graph_end] = 0;

      if (graph_end > width_graph* 5/6) {
        range_L += 0.05;
        range_H += 0.05;
      }

      graph_end ++;
    }
  }

  /**
   *  グラフへの点の追加 <br>
   *  描画点は-1.0から1.0に正規化して代入 <br>
   *  -1.0から1.0の範囲外の点は-1.0もしくは1.0に変更して描画
   *  @param y_X 波形Xのy座標
   */
  void addPoint(float y_X) {
    if (graph_end<point_num) {
      y_X = constrain(y_X, -1.0, 1.0);

      //グラフをセット
      valsX[graph_end] = (int)(y_X* height_graph/2.0);
      valsY[graph_end] = 0;
      valsZ[graph_end] = 0;

      if (graph_end > width_graph* 5/6) {
        range_L += 0.05;
        range_H += 0.05;
      }

      graph_end ++;
    }
  }
  
  /**
   *  グラフの点を消す<br>
   *  @param void
   *  @return void
   */
  void clear() {
      graph_end =0;
       range_L = 0.0;
       range_H = 30.0;
  }
}

/**
 * ジャイロのグラフ 
 */
class GyroGraph extends Graph {
  GyroGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text("  2000", graph_x+width_graph, graph_y                 );
    text("  1000", graph_x+width_graph, graph_y+height_graph/4  );
    text("     0", graph_x+width_graph, graph_y+height_graph/2  );
    text(" -1000", graph_x+width_graph, graph_y+height_graph*3/4);  
    text(" -2000", graph_x+width_graph, graph_y+height_graph    );

    textSize(20);
    text("Gyro [deg/s]", graph_x, graph_y-4);

    writeGraphVal("Gyro [deg/s]", degrees(omega_vec[0]), degrees(omega_vec[1]), degrees(omega_vec[2]));
  }
}

/**
 * 加速度のグラフ 
 */
class AccGraph extends Graph {
  AccGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text("  4", super.graph_x+super.width_graph, super.graph_y                       );
    text("  2", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("  0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -2", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text(" -4", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Acc [G]", acc_vec[0], acc_vec[1], acc_vec[2]);
  }
}

/**
 * 地磁気のグラフ 
 */
class MagGraph extends Graph {
  MagGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text("  600", super.graph_x+super.width_graph, super.graph_y                       );
    text("  300", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("  0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -300", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text(" -600", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Mag [uT]", mag_vec[0], mag_vec[1], mag_vec[2]);
  }
}

/**
 * 角度のグラフ 
 */
class DegGraph extends Graph {
  DegGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
    setEnValsVisible(true, false, false);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text(" 180", super.graph_x+super.width_graph, super.graph_y                       );
    text("  90", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("   0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -90", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text("-180", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Deg [degree]", deg);
  }

  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @return void
   */
  void writeGraphVal(String name, float X_val) {
    textSize(20);
    fill(255, 255, 255, 255);
    text(name, graph_x, graph_y-4);

    fill(255, 0, 0, 200);
    text("■", graph_x+200, graph_y-8);

    fill(255, 255, 255, 255);
    text("Deg:", graph_x+220, graph_y-4);

    text(X_val, graph_x+300, graph_y-4);

    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }
}

/**
 * モーターdutyのグラフ 
 */
class DutyGraph extends Graph {
  DutyGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
    setEnValsVisible(true, false, false);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text(" 100", super.graph_x+super.width_graph, super.graph_y                       );
    text("  50", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("   0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -50", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text("-100", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Duty [%]", duty);
  }

  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @return void
   */
  void writeGraphVal(String name, float X_val) {


    textSize(20);
    fill(255, 255, 255, 255);
    text(name, graph_x, graph_y-4);

    fill(255, 0, 0, 200);
    text("■", graph_x+200, graph_y-8);

    fill(255, 255, 255, 255);
    text("duty:", graph_x+220, graph_y-4);

    text(X_val, graph_x+300, graph_y-4);

    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }
}

/**
 * 機体状態のグラフ 
 */
class StateGraph extends Graph {
  StateGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text("0", graph_x + width_graph, graph_y + height_graph * 6/7   );
    text("1", graph_x + width_graph, graph_y + height_graph * 5/7   );

    text("0", graph_x + width_graph, graph_y + height_graph * 4/7   );
    text("1", graph_x + width_graph, graph_y + height_graph * 3/7   );

    text("0", graph_x + width_graph, graph_y + height_graph * 2/7   );
    text("1", graph_x + width_graph, graph_y + height_graph * 1/7   );

    writeGraphVal("State [boolean]", isStop, isCurve, isSlope);
  }

  /**
   *  グラフの枠線,縦線,横線の描画　<br>
   *  StateGraphではセンターラインがいらないので override
   *  @param  void 
   *  @return void
   */
  void drawFrame() {
    noFill(); //塗りつぶさない
    rectMode(CORNER);
    strokeWeight(5);
    smooth();

    //枠線の描画
    stroke(color_graph);
    rect(graph_x, graph_y, width_graph, height_graph);

    //太線の描画
    strokeWeight(3);
    line(graph_x, graph_y+ height_graph * 4/7, graph_x + width_graph, graph_y+ height_graph * 4/7 );
    line(graph_x, graph_y+ height_graph * 6/7, graph_x + width_graph, graph_y+ height_graph * 6/7 );
    line(graph_x, graph_y+ height_graph * 2/7, graph_x + width_graph, graph_y+ height_graph * 2/7 );

    //縦線の描画
    strokeWeight(1);
    int offset = 20 -(int)((range_L - (float)((int)(range_L)))*20);
    
    for (int i=0; i<v_divide_num; i++) {
      line( offset  +  graph_x+i* width_graph/v_divide_num, graph_y, offset  +  graph_x+i* width_graph/v_divide_num, graph_y + height_graph);
    }
    //横線の描画
    for (int i=1; i<h_divide_num; i++) {
      line(graph_x, graph_y +i* height_graph/h_divide_num, graph_x + width_graph, graph_y +i* height_graph/h_divide_num );
    }
  }


  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @param  Y_val 要素Yの値
   *  @param  Z_val 要素Zの値 
   *  @return void
   */
  void writeGraphVal(String name, int X_val, int Y_val, int Z_val) {
    textSize(20);

    fill(255, 0, 0, 200);
    text("■", graph_x+170, graph_y-8);
    fill(0, 255, 0, 200);
    text("■", graph_x+300, graph_y-8);
    fill(0, 0, 255, 200);
    text("■", graph_x+440, graph_y-8);

    fill(255, 255, 255, 255);
    textSize(20);   
    text(name, super.graph_x, super.graph_y-4);
    text("isStop:", super.graph_x+200, super.graph_y-4);
    text("isCurve:", super.graph_x+330, super.graph_y-4);
    text("isSlope:", super.graph_x+470, super.graph_y-4);

    text(X_val, super.graph_x+270, super.graph_y-4);
    text(Y_val, super.graph_x+410, super.graph_y-4);
    text(Z_val, super.graph_x+550, super.graph_y-4);
    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }
}

/**
 * マイコン用電源, モーター用電源の電圧のグラフ
 */
class VoltageGraph extends Graph {
  VoltageGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
    setEnValsVisible(true, true, false);
  }

  void customPart() {
    fill(255, 255, 255, 255);
    textSize(15);
    text("  5.0", super.graph_x+super.width_graph, super.graph_y                       );
    text("  2.5", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("  0.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -2.5", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text(" -5.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Voltage [V]", V_Lipo, V_Battery);
  }


  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @param  Y_val 要素Yの値
   *  @return void
   */
  void writeGraphVal(String name, float X_val, float Y_val) {

    textSize(20);

    fill(255, 0, 0, 200);
    text("■", graph_x+170, graph_y-8);
    fill(0, 255, 0, 200);
    text("■", graph_x+370, graph_y-8);


    fill(255, 255, 255, 255);
    textSize(20);   
    text(name, graph_x, graph_y-4);
    text("V_Lipo:", graph_x+200, graph_y-4);
    text("V_Battery:", graph_x+400, graph_y-4);

    text(X_val, graph_x+270, graph_y-4);
    text(Y_val, graph_x+500, graph_y-4);

    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }
}


/**
 * MPU9150の温度のグラフ
 */
class TempGraph extends Graph {
  TempGraph(int x_, int y_, int wd_graph, int he_graph, int v_div_num, int h_div_num, color col, String na_graph, ControlP5 contp5) {
    super(x_, y_, wd_graph, he_graph, v_div_num, h_div_num, col, na_graph, contp5);
    setEnValsVisible(true, false, false);
  }


  void customPart() {

    fill(255, 255, 255, 255);
    textSize(15);
    text("  80.0", super.graph_x+super.width_graph, super.graph_y                       );
    text("  45.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/4  );
    text("   0.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph/2  );
    text(" -45.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph*3/4);  
    text(" -80.0", super.graph_x+super.width_graph, super.graph_y+super.height_graph    );

    writeGraphVal("Temperature [deg C]", temperature);
  }

  /**
   *  グラフ値をグラフの上に描画
   *  @param  name  グラフの表示名 
   *  @param  X_val 要素Xの値
   *  @return void
   */
  void writeGraphVal(String name, float X_val) {

    textSize(20);

    fill(255, 0, 0, 200);
    text("■", graph_x+200, graph_y-8);


    fill(255, 255, 255, 255);
    textSize(20);   
    text(name, graph_x, graph_y-4);
    text("temp:", graph_x+220, graph_y-4);

    text(X_val, graph_x+300, graph_y-4);

    textSize(15);
    text(range_L, graph_x, graph_y+height_graph+15);
    text(range_H, graph_x+width_graph-50, graph_y+height_graph+15);
  }
}

