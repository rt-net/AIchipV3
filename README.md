# AIchipV3

本リポジトリはAI Chip V3（以下AI Chip）に関する資料およびサンプルプログラムを
まとめたものです.  各種ファイルの内容は以下になります.  


## MCUXpresso  

### 概要

[MCUpresso](https://www.nxp.com/jp/support/developer-resources/software-development-tools/mcuxpresso-software-and-tools/mcuxpresso-integrated-development-environment-ide:MCUXpresso-IDE) はAI Chipボード上の制御マイコン(lpc1343)の統合開発環境です.     
出荷時にAI Chipには基本的な動作を実現するためのファームウェアが書き込まれています.  
このファームウェアのプロジェクトファイルが本フォルダに入っています.
本プロジェクトファイルのソースの関数などについては以下に記述があります.  
<http://rt-net.github.io/AIchipV3/>   



### ファイル内容：
 * workspace



## firmware

AI Chip上のマイコンに出荷時点で書き込まれている
ファームウェアです.



## circuit  
AI Chipの回路図です.

### ファイル内容

 * AIchipV3-MainBoard    メイン基板の回路図      
 * AIchipV3-MotorDriver  モータドライバモジュールの回路図



## manual  

### 概要

各種マニュアルです.  お使いになられる前にマニュアルを熟読してください.

### ファイル内容

 * AIChipV3_manual_20180717.pdf
   * 製品ついての基本的な説明とprosessing等サンプルプログラムの使用方法に関する記述です.      
 * AIChipV3_wiring-manual_20180717.pdf  
   * AI Chip制御ボードと電池, モーターの配線方法について記述です. 
 * AIChipV3_MCUXpresso_20180717.pdf  
   * AI Chip上のマイコンでプログラミングをする際に参照してください. 



## Processing  

### 概要

[processing](https://processing.org/)とはarudinoのようにC言語likeな文法で簡単なプログラミングができる言語です.   
グラフィック等の表示が比較的に簡単にできるのでちょっとしたプログラミングに適しています.  
AI Chipのいくつかのサンプルはprocessingを用いて記述されています.  .  


### ファイル内容

 * sample controller　Bluetooth経由でPCからAI Chipの速度やLEDの点灯をコントロールするサンプル      
 * sample logger    　Bluetooth経由でPCからAI Chipのデータをリアルタイムでグラフに表示するサンプル
 * sample App       　Bluetooth経由でPCからAI Chipを動かす最小限のサンプル(矢印キーでモーターの速度変更)
 * sample recieve     Bluetooth経由でAI Chipからデータを受信する際の最低限のサンプル




## Android 

### 概要

　Bluetooth経由でAndoroid端末からAI Chipをコントロールするサンプルプログラムです.  
　このサンプルプログラムはAndroid Studio(統合開発環境)用です.

### アプリ機能
  
 * AI Chipへ、複数のUIで命令が出せる  
 * モーター速度コントロール用シークバー  
 * モーターの前進、後進、停止ボタン  
 * LED点灯用ボタン  
 * LED、モーター、センサー制御用コマンド入力フォーム  
 * 音声認識によるモーター制御 （行け、動け、ゆっくり、止まれ等） 
