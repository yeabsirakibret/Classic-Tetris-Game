int grid[][];

float 
  freeX = 300,
  block_size = 20,
  speed = 1;

int
  rot = 0,
  r_max = 0,
  c_max = 0,
  score = 0;
  
int[][] shape;

char cur_shape_chr;

ArrayList<String> coming_shapes = new ArrayList<String>();
ArrayList<int[]> coming_colors = new ArrayList<int[]>();

ArrayList<Block> blocks = new ArrayList<Block>();
ArrayList<Block> p_blocks = new ArrayList<Block>();

ArrayList<Block> next_blocks = new ArrayList<Block>();

boolean isShapeAlive = true, locked = false;

int[][] colors = {{127,127,127}, {0, 255, 255}, {255, 255, 0}, {128, 0, 128}, {0, 255, 0}, {255, 0, 0}, {0, 0, 255}, {255, 127, 0}, {127, 127, 127}, {57,57,50}};


int c_code;

void setup(){
  size(700,700);
 
  //frameRate(2);
  r_max = int(height/block_size);
  c_max = int((width-freeX)/block_size);
  
  grid = new int[r_max][c_max];
  make_wall();
  addComingShapes();
  
  spawnShape();
}

void addComingShapes(){
  String s = "OISZLJT";
  for(int i=0; i<10; i++){
    coming_shapes.add(s.charAt(int(random(0, s.length())))+"");
    coming_colors.add(new int[]{int(random(1,colors.length-2))});
  }
   
}

void spawnShape(){
  
  c_code = coming_colors.get(0)[0];

   
  if(coming_shapes.size() <5)
    addComingShapes();
    
  isShapeAlive = true;
  rot = 0;
  cur_shape_chr = coming_shapes.get(0).charAt(0);
  coming_shapes.remove(0);
  coming_colors.remove(0);
  shape = Shapes.get_shape(cur_shape_chr)[rot%Shapes.all_shapes.length];
  float middle_offset = (int(((width-freeX)/block_size)/2)-2)*block_size;
  
  
  
  addBlocks(middle_offset, 0);
  add_ghost(middle_offset, 0);
  
}

void addBlocks(float offsetX, float offsetY){
  blocks = new ArrayList<Block>();
   
  float start_x = offsetX, start_y = offsetY;
  
  for(int i=0; i<shape.length; i++){
    start_x = offsetX;
    for(int j=0; j<shape[i].length; j++){
      
      blocks.add(new Block(start_x, start_y, block_size, speed, shape[i][j] == 1, colors[c_code], c_code));
      
      start_x += block_size;
    }
    
    start_y += block_size;
  }
  
}


void add_ghost(float offsetX, float offsetY){
  
  p_blocks = new ArrayList<Block>();

  
  float start_x = offsetX, start_y = offsetY;
  
  for(int i=0; i<shape.length; i++){
    start_x = offsetX;
    for(int j=0; j<shape[i].length; j++){
      
      Block temp = new Block(start_x, start_y, block_size, speed, (shape[i][j] == 1), colors[c_code], c_code);
      temp.isGhost = true;
      p_blocks.add(temp);
       
      start_x += block_size;
    }
    
    start_y += block_size;
  }
  
}


void clearRow(){
  for(int row=0; row<grid.length-1; row++){
    
    if(isRowFull(row)){
      
      for(int col=0; col<grid[row].length; col++){ 
        
        grid[row][col] = 0;
        
      }
      
      if(score%3 == 0 && score != 0) speed ++;
      score++;
      
    }
  }
  
  for(int row=1; row<grid.length-1; row++){
    
    if(isRowEmpty(row)){
      
      int[] temp = grid[row];
      
      grid[row] = grid[row-1];
      
      grid[row-1]= temp;
      
    }
  }
  
    
}

boolean isRowFull(int row){
  for(int col=0; col<grid[0].length; col++)
    if(grid[row][col] == 0)
      return false;
  
  return true;
}

boolean isRowEmpty(int row){
  for(int col=0; col<grid[0].length; col++)
    if(grid[row][col] != 0)
      return false;
  
  return true;
}


void showBlocks(){
  
  for(int i=0; i<blocks.size(); i++){
    Block b = blocks.get(i);
    Block pb = p_blocks.get(i);
    
    b.show();
    pb.show();
   
   int grid_row = int(b.y/block_size);
   
   int grid_col = int(b.x/block_size);
   
   
     
   
   if(grid_col < 0)
     grid_col = 0;   
   
   if((getMMY(true, blocks)[1] < height-b.s && 
   !(grid[(grid_row+1)%grid.length][grid_col%grid[0].length] != 0))||!b.isActive){
     b.move();
   }else if(b.isActive){
     stampShape();
     
   }
   
  }
}

void make_wall(){
 
  for(int row=0; row<grid.length; row++){
    for(int col=0; col<grid[row].length; col++){ 
      if(row == grid.length-1){
        grid[row][col] = colors.length-1;
      }
    }
  }
  
}

void draw_grid(){
  float start_x, start_y = 0;
  
  for(int row=0; row<grid.length; row++){
    start_x = 0;
    for(int col=0; col<grid[row].length; col++){
      int cell = grid[row][col];
      
      
      fill(colors[cell][0], colors[cell][1], colors[cell][2]);
    
      rect(start_x, start_y, block_size, block_size);
      
      start_x += block_size;
    }
    start_y += block_size;
  }
}


void horizontalMove(int dir){
  float [] mmX = getMMX(true, blocks);

    
    for(Block b:blocks){
      
        if((mmX[0] != 0 && dir== -1) || (mmX[1] != int((width-freeX)-b.s) && dir== 1)){
          
           b.x += (b.s)*dir;
  
        }
      
    }
  
  
  mmX = getMMX(true, p_blocks);
  for(Block b:p_blocks){
    if((mmX[0] != 0 && dir== -1) || (mmX[1] != int((width-freeX)-b.s) && dir== 1))
      b.x += (b.s)*dir;
  }
  
  add_ghost(getMMX(false, blocks)[0], 0);
  
}

float[] getMMX(boolean filter, ArrayList<Block> blocks){
  float [] min_max = {99999, -999999};
  float [] min_max_active = {99999, -999999};
  
  for(Block b:blocks){
    if(b.x < min_max[0])
      min_max[0] = b.x;
    
    if(b.x > min_max[1])
      min_max[1] = b.x;
      
    if(b.x < min_max_active[0] && b.isActive == true)
      min_max_active[0] = b.x;
    
    if(b.x > min_max_active[1] && b.isActive == true)
      min_max_active[1] = b.x;
      
  }
  
  return (filter)?min_max_active:min_max;
}


float[] getMMY(boolean filter, ArrayList<Block> blocks){
  float [] min_max = {99999, -999999};
  float [] min_max_active = {99999, -999999};
  
  for(Block b:blocks){
    if(b.y < min_max[0])
      min_max[0] = b.y;
    
    if(b.y > min_max[1])
      min_max[1] = b.y;
      
    if(b.y < min_max_active[0] && b.isActive == true)
      min_max_active[0] = b.y;
    
    if(b.y > min_max_active[1] && b.isActive == true)
      min_max_active[1] = b.y;
      
  }
  
  return (filter)?min_max_active:min_max;
}


void rotateShape(){
  rot = (rot - 1);
 
  shape = Shapes.get_shape(cur_shape_chr)[abs(rot)%Shapes.get_shape(cur_shape_chr).length];
  
  addBlocks(getMMX(false, blocks)[0], getMMY(false, blocks)[0]);
  
  add_ghost(getMMX(false, blocks)[0], 0);
  
}

void stampShape(){
  isShapeAlive = false;
  
  for(Block b:blocks){
    int grid_row = int(b.y/block_size);
    int grid_col = int(b.x/block_size);
    
    if(grid_col > c_max-1)grid_col = c_max-1;
    if(grid_row > r_max-1)grid_row = r_max-2;
    
    
    if(b.isActive == true)
      grid[grid_row][grid_col] = b.c_code;
   
  }
}

void keyPressed(){
  
  if(keyCode == LEFT){
  
      if(isHorFree(-1))horizontalMove(-1);
    
  }else if(keyCode == RIGHT){
   
      
      if(isHorFree(1))horizontalMove(1);
  
  }else if(keyCode == UP){
    
    int before_minX = int(getMMX(true, blocks)[0]/block_size);
    int before_maxX = int(getMMX(true, blocks)[1]/block_size);
    
    rotateShape();
    while(getMMX(true, blocks)[0] < 0)
      horizontalMove(1);
      
    while(getMMX(true, blocks)[1] > (width-freeX)-block_size)
      horizontalMove(-1);
   
    if(before_minX == 0)
      horizontalMove(-1);
      
    if(before_maxX == c_max-1)
      horizontalMove(1);
  
    
  
  }else if(keyCode == DOWN){
    
     for(int i=0; i<blocks.size(); i++)
       blocks.get(i).y = p_blocks.get(i).y;
       
     
    
  }
  
 
}

int getMinDropDistance(ArrayList<Block> blks){
  int min_dist = 9999;
    
    for(Block b: blks){
      
      if(b.isActive){
        int dis_now = blockDropDistance(b);
      
        if(dis_now < min_dist)
          min_dist = dis_now;
        
      }
      
    }
  return min_dist;
}




int blockDropDistance(Block b){
  int drop = 0;
  
  int c = int(b.x/b.s), r = int(b.y/b.s);
  
  if(c<0)c=0;
  else if(c>c_max-1)c = c_max-1;
  
  while(grid[(r+1)%r_max][c] == 0 && r < r_max){
    drop++;
    r++;
  }
  
  
  return drop;
}


void showComingShape(){
  char coming = coming_shapes.get(0).charAt(0);
  
  int[][] coming_shape = Shapes.get_shape(coming)[0];
  int coming_color_isx = coming_colors.get(0)[0];
  
  float start_x = 400+100, start_y = block_size*6;
  
  for(int i=0; i<coming_shape.length; i++){
    start_x = 400+100;
    for(int j=0; j<coming_shape[i].length; j++){
      fill(colors[coming_color_isx][0], colors[coming_color_isx][1], colors[coming_color_isx][2]);
      if(coming_shape[i][j] == 1){
        rect(start_x, start_y, block_size, block_size);
      }
      start_x += block_size;
    }
    start_y += block_size;
  }
}

boolean isGameOver(){
  
  for(int col=0; col<grid[0].length; col++)
    if(grid[2][col] != 0)
      return true;
  
  return false;
  
}


void placeGhost(){
  float max_block = getMMY(true, blocks)[1];
  float max_ghost = getMMY(true, p_blocks)[1];
  
  if(max_block >= max_ghost){
    for(int i=0; i<blocks.size(); i++)
       p_blocks.get(i).y = blocks.get(i).y;
       
  }
  
  int min_dist = getMinDropDistance(p_blocks);
      
    for(Block b: p_blocks){
      b.y = int(b.y/block_size)*block_size;
      b.y += (min_dist*block_size);  
    }
}


boolean isHorFree(int dir){
  float [] mmX = getMMX(true, blocks);

    
    for(Block b:blocks){
      
        if((mmX[0] != 0 && dir== -1) || (mmX[1] != int((width-freeX)-b.s) && dir== 1)){
          
           float tempX =  b.x + (b.s*dir);
           
           if(grid[int(b.y/b.s)][abs(int(tempX/b.s))%c_max] != 0 && b.isActive)
             return false;
        }
      
    }
    
    return true;
}

void draw(){
  background(0);
  
  
  if(isGameOver()){
    score = 0;
    grid = new int[r_max][c_max];
    make_wall();
  }
  
  clearRow();
  
  stroke(100);
  draw_grid();
  stroke(0);
  

  
  if(isShapeAlive == false)
    spawnShape();
  
  fill(255);
  
  showBlocks();
  
  placeGhost();
  
  showComingShape();
  
  textSize(block_size*2);
  fill(255);
  text("NEXT", width-(block_size*10), 100);
  
  textSize(block_size*1.5);
  text("Score: "+score, width-(block_size*11), 500);
  
  
  
    
    
}
