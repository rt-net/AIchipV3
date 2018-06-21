/**
 * @file   myTextArea.pde
 * @brief  テキストデータ表示用エリアのクラスmyTextareaを定義
 * @author Ryota Takahashi
 */


/**
 *  テキストデータ表示用エリアのクラス
 *  Control p5のtextAreaと文字格納用バッファ, バッファへのデータ追加をサポート
 */ 
 
 
/**
 *  コンストラクタで表示座標, 線の弾き方等を渡す
 *  @param x_ 表示位置x
 *  @param y_ 表示位置y
 *  @param wid 横幅
 *  @param hei 縦幅
 *  @param name テキストエリアの名前(重複禁止)
 *  @param cp5_ 表示フレーム内で定義されているControlP5の参照
 */
public class myTextarea{
  int buf_size = 10000;
  String buf = "";  
  Textarea myTextarea;
  
  
  /**
   *  コンストラクタでTextareaを定義
   */
  myTextarea(int x, int y, int wid, int hei, ControlP5 cp5_,String name){
         
    myTextarea = cp5_.addTextarea(name)
                  .setPosition(x,y)
                  .setSize(wid,hei)
                  .setFont(createFont("arial",15))
                  .setLineHeight(15)
                  .setColor(color(128))
                  .setColorBackground(color(255,100))
                  .setColorForeground(color(255,100));
                  ;
    
  }

  /**
   *  表示のアップデート draw()内で呼ぶこと
   */
  void update(){
    myTextarea.setText(buf);
  }

  /**
   *  改行なしの出力
   *  @parame 表示したい文字列
   */
  void print(String str){
    if(buf.length() + str.length() > buf_size) buf = "";//buf = buf.substring( buf.length() + str.length() ,buf_size-1 );
    buf += str; 
  }
  
  /**
   *  改行付きの出力
   *  @parame 表示したい文字列
   */
  void println(String str){
   if(buf.length() + str.length() > buf_size) buf = "";//buf.substring( buf.length() + str.length() ,buf_size-1 );
    buf += str + "\n";
  }
  
}

