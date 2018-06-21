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


  text("omegaX[deg/s]", 810, 20);
  text("omegaY[deg/s]", 810, 40);
  text("omegaZ[deg/s]", 810, 60);
  text(degrees(omega_vec[0]), 970, 20);
  text(degrees(omega_vec[1]), 970, 40);
  text(degrees(omega_vec[2]), 970, 60); 

  text(temperature, 810, 80);
  text("[degree C]", 900, 80);

  
}



String byte_info[] = {
  "ヘッダー",        //0  byte  
  " "       , 
  " "       ,   
  " "       ,
  "製品固有識別子L", //4  byte
  "製品固有識別子H", //5  byte
  "製品バージョン",  //6  byte  
  "タイムスタンプ",  //7  byte
  "ACC X",           //8  byte
  " "    ,
  "ACC Y",           //10 byte
  " "    ,
  "ACC Z",           //12 byte
  " "    ,
  "TEMP",            //14 byte
  " "    ,
  "GYRO X",          //16 byte
  " "    ,
  "GYRO Y",          //18 byte
  " "    ,
  "GYRO Z",          //20 byte
  " "    ,
  "MAG X",           //22 byte
  " "    ,
  "MAG Y",           //24 byte
  " "    ,
  "MAG Z",           //26 byte
  " ",
  "DEG  ",           //28 byte
  " "    ,
  "DUTY ",           //30 byte
  " "    ,
  "isStop" ,         //32 byte
  "isCurve",        //33 byte
  "isSlope",         //34 byte
  "TIME "  ,         //35 byte  
  ""       ,         
  ""       ,
  ""          
};




