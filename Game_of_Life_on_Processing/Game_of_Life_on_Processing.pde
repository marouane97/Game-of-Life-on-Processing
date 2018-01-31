import controlP5.*;
import java.util.*;
/*
TODO:
 resize the grid to not calculate for cells behind the tool bars
 */

int grid[][];
int cols, rows, resolution = 5;

boolean paused = false;
boolean topBarOpen = true;

int fps = 60;
String currentShape = "Point";

ControlP5 cp5;
ButtonBar topBar, bottomBar;

int buttonHight = 20;

void setup() {
  size(400, 400);
  //fullScreen();



  //UI *********************

  cp5 = new ControlP5(this);
  //String[] topBarButtons = {"Point", "Block", "Beehive", "Blinker", "Toad", "Beacon"};
  //topBar = cp5.addButtonBar("top-bar")
  //  .setPosition(0, 0)
  //  .setSize(width, buttonHight)
  //  .addItems(topBarButtons);

  String[] bottomBarButtons = {"Play/Pause", "Toggle Top-Bar", "Clear"};
  bottomBar = cp5.addButtonBar("bottom-bar")
    .setPosition(0, height-buttonHight)
    .setSize(width, buttonHight)
    .addItems(bottomBarButtons);


  List stillLivesList = Arrays.asList("Point", "Block", "Beehive", "Loaf", "Boat", "Tub");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("Still lives")
    .setPosition(0, 0)
    .setSize(width/3, 100)
    .setBarHeight(buttonHight)
    .setItemHeight(buttonHight)
    .addItems(stillLivesList)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    .setOpen(false)
    ;

  List oscillatorsList = Arrays.asList("Blinker", "Toad", "Beacon","Pulsar", "Pentadecathlon");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("Oscillators")
    .setPosition(width/3, 0)
    .setSize(width/3, 100)
    .setBarHeight(buttonHight)
    .setItemHeight(buttonHight)
    .addItems(oscillatorsList)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    .setOpen(false)  
    ;

  List spaceshipsList = Arrays.asList("Glider","Lightweight spaceship");
  /* add a ScrollableList, by default it behaves like a DropdownList */
  cp5.addScrollableList("Spaceships")
    .setPosition(width/3*2, 0)
    .setSize(width/3, 100)
    .setBarHeight(buttonHight)
    .setItemHeight(buttonHight)
    .addItems(spaceshipsList)
    .setType(ScrollableList.LIST) // currently supported DROPDOWN and LIST
    .setOpen(false)  
    ;

  //UI *********************


  cols = width / resolution;
  rows = (height) / resolution;

  grid = new int[cols][rows];
  for (int i=0; i<cols; i++) {
    for (int j=0; j< rows; j++) {
      grid[i][j] = floor(random(2));
    }
  }
}

void draw() {
  background(20);
  frameRate(fps);


  for (int i=0; i<cols; i++) {
    for (int j=0; j<rows; j++) {
      int x = i * resolution;
      int y = j * resolution;

      if (grid[i][j] == 1) {
        fill(255);
        stroke(0);
        rect(x, y, resolution-1, resolution-1);
      }
    }
  }

  if (!paused) {
    int next[][] = new int[cols][rows];

    for (int i=0; i<cols; i++) {
      for (int j=0; j< rows; j++) {
        int state = grid[i][j];
        //cout neighbors
        int neighbors = countNeighbors(grid, i, j);

        if (state == 0 && neighbors == 3) {
          next[i][j] = 1;
        } else if (state == 1 && (neighbors < 2 || neighbors > 3)) {
          next[i][j] = 0;
        } else {
          next[i][j] = state;
        }
      }
    }
    grid = next;
  }
}

void controlEvent(ControlEvent e) {
  if (e.isController()) {
    //Still lives dropdown
    if (e.getController().getName().equals("Still lives")) {
      switch(floor(e.getController().getValue())) {
      case 0:
        currentShape = "Point";
        break;
      case 1:
        currentShape = "Block";
        break;
      case 2:
        currentShape = "Beehive";
        break;
      case 3:
        currentShape = "Loaf";
        break;
      case 4:
        currentShape = "Boat";
        break;
      case 5:
        currentShape = "Tub";
        break;
      default:
        currentShape = "Point";
      }
    }//Still lives dropdown

    //Oscillators dropdown
    if (e.getController().getName().equals("Oscillators")) {
      switch(floor(e.getController().getValue())) {
      case 0:
        currentShape = "Blinker";
        break;
      case 1:
        currentShape = "Toad";
        break;
      case 2:
        currentShape = "Beacon";
        break;
      default:
        currentShape = "Point";
      }
    }    //Oscillators dropdown
    
    //Spaceships dropdown
    if (e.getController().getName().equals("Spaceships")) {
      switch(floor(e.getController().getValue())) {
      case 0:
        currentShape = "Glider";
        break;
      case 1:
        currentShape = "Lightweight spaceship";
        break;
      default:
        currentShape = "Point";
      }
    }    //Spaceships dropdown


    //bottom-bar logic
    if (e.getController().getName().equals("bottom-bar")) {
      switch(floor(e.getController().getValue())) {
      case 0:
        paused = !paused;
        break;
      case 1:
        if (topBarOpen) {
          topBarOpen = false;
          topBar.setPosition(0, -buttonHight);
        } else {
          topBar.setPosition(0, 0);
          topBarOpen = true;
        }
      case 2://clear
        for (int[] row: grid)
          Arrays.fill(row, 0);
        break;
      }
    }


    print("control event from : "+e.getController().getName());
    println(", value : "+e.getController().getValue());
  }
}

int countNeighbors(int[][] grid, int x, int y) {
  int sum = 0;

  for (int i=-1; i<2; i++) {
    for (int j=-1; j<2; j++) {
      int col = (x + i + cols) % cols;
      int row = (y + j + rows) % rows;
      sum += grid[col][row];
    }
  }
  sum -= grid[x][y];
  return sum;
}

void mousePressed() {
    changeCell();
}
void mouseWheel(MouseEvent e) {
  float event = e.getCount();
  if (fps <= 1) {
    fps++;
  } else {
    fps += -event;
  }
}

void changeCell() {
  int x = floor(mouseX / resolution);
  int y = floor((mouseY) / resolution);



  try {
    switch(currentShape) {
      //drawBlinker drawToad drawBeacon
    case "Point":
      drawPoint(x, y);
      break;
    case "Block":
      drawBlock(x, y);
      break;
    case "Beehive":
      drawBeehive(x, y);
      break;
    case "Blinker":
      drawBlinker(x, y);
      break;
    case "Toad":
      drawToad(x, y);
      break;
    case "Beacon":
      drawBeacon(x, y);
      break;
    case "Loaf":
      drawLoaf(x,y);
      break;
    case "Boat":
      drawBoat(x,y);
      break;
    case "Tub":
      drawTub(x,y);
      break;
    case "Glider":
      drawGlider(x,y);
      break;
    case "Lightweight spaceship":
      drawLightweightSpaceship(x,y);
      break;
    }
  }
  catch(Exception e) {
  }
}

//SHAPES
void drawPoint(int x, int y) {
  grid[x][y] = (grid[x][y] == 1) ? 0 : 1;
}
//start from top left cell
void drawBlock(int x, int y) {
  grid[x][y] = 1;
  grid[x+1][y] = 1;
  grid[x][y+1] = 1;
  grid[x+1][y+1] = 1;
}
void drawBeehive(int x, int y) {
  grid[x+1][y] = 1;
  grid[x+2][y] = 1;

  grid[x+1][y+2] = 1;
  grid[x+2][y+2] = 1;

  grid[x][y+1] = 1;
  grid[x+3][y+1] = 1;
}
void drawBlinker(int x, int y) {
  grid[x-1][y] = 1;
  grid[x][y] = 1;
  grid[x+1][y] = 1;
}
void drawToad(int x, int y) {
  drawBlinker(x+1, y);
  drawBlinker(x, y+1);
}
void drawBeacon(int x, int y) {
  drawBlock(x, y);
  drawBlock(x+2, y+2);
}
void drawLoaf(int x, int y){
  grid[x+1][y] = 1;
  grid[x+2][y] = 1;
  grid[x][y+1] = 1;
  grid[x+3][y+1] = 1;
  grid[x+1][y+2] = 1;
  grid[x+3][y+2] = 1;
  grid[x+2][y+3] = 1;
}

void drawBoat(int x, int y){
  drawBlock(x,y);
  grid[x+1][y+1] = 0;
  grid[x+2][y+1] = 1;
  grid[x+1][y+2] = 1;
}

void drawTub(int x, int y){
  drawBoat(x,y);
  grid[x][y] = 0;
}

void drawGlider(int x, int y){
  drawBlock(x+1,y+1);
  grid[x+1][y+1] = 0;
  grid[x][y+1] = 1;
  grid[x+2][y] = 1;
}

void drawLightweightSpaceship(int x, int y){
  grid[x+1][y] = 1;
  grid[x][y+1] = 1;
  grid[x+4][y] = 1;
  grid[x+4][y+2] = 1;
  
  drawBlock(x,y+2);
  grid[x+1][y+2] = 0;
  
  grid[x+2][y+3] = 1;
  grid[x+3][y+3] = 1;
}