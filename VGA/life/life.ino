const char ADDR[] = {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
const char DATA[] = {31, 33, 35, 37, 39, 41, 43, 45};
#define WRITE 53
#define RED 0b00110000
#define GREEN 0b00001100
#define BLUE 0b00000011
#define BLACK 0b00000000

#define MAXX 128
#define MAXY 32

char CELLS[MAXX][MAXY];

void setup() {
  randomSeed(11);
  init();
  clear_screen();
  init_cells();
}

void loop() {
  next_gen();
}

void clear_screen() {
  for (int y = 0; y < 128; y++) {
    for (int x = 0; x < 256; x ++) {
      int addr = y << 8 | x;
      set_address(addr);
      if(x<160 && y<120) {
        set_data( ((x%2==1)?RED:0)| ((x%4>1)?GREEN:0) | ((x%8>3)?BLUE:0) );
      } else {
        set_data(0);
      }
      pulse_write();
    }
  }  
}

void plot(int x, int y, int c){
    int addr = y << 8 | x;
    set_address(addr);
    set_data(c);
    pulse_write();
}
void set_address(int address) {
  for (int i = 0; i < 16; i++) {
    digitalWrite(ADDR[i], ((address>>i)&1));
  }
}

void set_data(int data) {
  for (int i = 0; i < 8; i++) {
    digitalWrite(DATA[i], ((data>>i)&1));
  }
}

void pulse_write() {
  digitalWrite(WRITE, 0);
  digitalWrite(WRITE, 1);
  digitalWrite(WRITE, 0);    
}

void init() {
  for (int n = 0; n < 16; n += 1) {
    pinMode(ADDR[n], OUTPUT);
  }
  for (int n = 0; n < 8; n += 1) {
    pinMode(DATA[n], OUTPUT);
  }
  pinMode(WRITE, OUTPUT);  
}

void init_cells(){
//  for(int i=0; i<999; i++){  
//    int x = random(MAXX-2)+1;
//    int y = random(MAXY-2)+1;
//    CELLS[x][y] = 1;
//  }
    int mx = MAXX/2;
    int my = MAXY/2;
    CELLS[mx+1][my] = 1;
    CELLS[mx][my] = 1;
    CELLS[mx-1][my+1] = 1;
    CELLS[mx][my+1] = 1;
    CELLS[mx][my+2] = 1;
}

void next_gen() {
  for(int y=1; y<MAXY-1; y++){
    for(int x=1; x<MAXX-1; x++){
      int count = count_cells_around(x, y);
      if (count==2)
        CELLS[x][y] = CELLS[x][y] + CELLS[x][y]*2;
      else if (count == 3)
        CELLS[x][y] = CELLS[x][y] + 2;
    }
  }
  for(int y=0; y<MAXY; y++){
    for(int x=0; x<MAXX; x++){
      int xx = x-MAXX/2+80;
      int yy = y-MAXY/2+60;
      if (CELLS[x][y] == 1) {
        plot(xx, yy, GREEN|BLUE);
        CELLS[x][y] = 0;
      } else if (CELLS[x][y] == 2) {
         plot(xx, yy, RED); 
         CELLS[x][y] = 1;
      } else if (CELLS[x][y] == 3) {
         plot(xx, yy, RED|GREEN); 
         CELLS[x][y] = 1;
     } else {
        plot(xx, yy, BLUE);
        CELLS[x][y] = 0;
      }
    }
  }
}

int count_cells_around(int x, int y) {
  int count = 0;
  for (int yy = -1; yy < 2; yy++) {
    for (int xx = -1; xx < 2; xx++) {
      if (xx==0 and yy==0) continue;
      if (CELLS[x+xx][y+yy] == 1 || CELLS[x+xx][y+yy] == 3)
        count++; 
    }
  }
  return count;
}
