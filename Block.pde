class Block{
  
  float x, y, s, speed;
  
  boolean isActive, isGhost = false;
  
  int[] tile_color;
  int c_code;
  

  
  Block(float x, float y, float s, float speed, boolean isActive, int[] tile_color, int c_code){
    this.x = x;
    this.y = y;
    this.s = s;
    this.speed = speed;
    this.isActive = isActive;
    this.tile_color = tile_color;
    this.c_code = c_code;
  }
  
  void show(){
    
    if(isActive){
       fill(tile_color[0], tile_color[1], tile_color[2]);
       
       if(isGhost){
         
         if(y > s*3){
           fill(tile_color[0], tile_color[1], tile_color[2], 100);
          
           rect(x,y,s,s);
          // fill(255);
         }
         
       }else{
         
         rect(x,y,s,s);
         
       }
     
    }else{
      //show disabled
     //fill(255,255,255, 20);
     //rect(x,y,s,s);
    }
   
  }
  
  void move(){
    y += speed;
  }
  
}
