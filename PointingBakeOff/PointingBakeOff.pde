import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;
import java.awt.event.KeyEvent;


//when in doubt, consult the Processsing reference: https://processing.org/reference/

int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
Robot robot; //initialized in setup 


int offset = 45;

int numRepeats = 20; //sets the number of times each button repeats in the test

Table table;
int origX;
int origY;
int time;
int id = 0;

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(60);
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }
  
  table = new Table();
  table.addColumn("trial num");
  table.addColumn("id");
  table.addColumn("original x position");
  table.addColumn("original y position");
  table.addColumn("target x position");
  table.addColumn("target y position");
  table.addColumn("target width");
  table.addColumn("time taken");
  table.addColumn("accuracy");

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  surface.setLocation(0,0);// put window in top left corner of screen (doesn't always work)
  
  robot.mouseMove(getButtonLocation(0).x + buttonSize/2, getButtonLocation(0).y + offset+ buttonSize/2);
  origX = getButtonLocation(0).x + buttonSize/2;
  origY = getButtonLocation(0).y + offset+ buttonSize/2;
}


void draw()
{
  background(50); //set background to dark grey

  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    saveTable(table, "data/trials.csv");
    return; //return, nothing else to do now test is over
  }

  fill(255); //set fill color to white
  text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on
  int textOffset = 20;
  float startText = height / 10;
  text("Instructions: Move the mouse cursor to the red square and left click in order to select the square.", width / 2, startText); 
  text("You can do this either by moving the mouse manually", width / 2, startText + textOffset);
  text("or by using the WASD keys to navigate to the neighboring squares of the square the cursor is on.", width / 2, startText + 2 * textOffset);
  text("You will be evaluated on both speed and accuracy.", width / 2, startText + 3 * textOffset);
  text("The timer will start upon the first selection of a square.", width / 2, startText + 4 * textOffset);

  for (int i = 0; i < 16; i++)// for all button
    drawButton(i); //draw button

  // Draw arrow from cursor to target square
  Rectangle targetBounds = getButtonLocation(trials.get(trialNum));
  strokeWeight(5);
  stroke(255, 255, 0);
  line(mouseX, mouseY, targetBounds.x + targetBounds.width / 2, targetBounds.y + targetBounds.height / 2);
  noStroke();
  //fill(255, 255, 0, 250); // set fill color to translucent yellow
  //ellipse(mouseX, mouseY, 20, 20); //draw user cursor as a circle with a diameter of 20
}

void mousePressed() // test to see if hit was in target!
{
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) {//check if first click, if so, start timer
    startTime = millis();
    time = startTime;
  }

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

  int accuracy = 0;
 //check to see if mouse cursor is inside button 
  if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height)) // test to see if hit was within bounds
  {
    accuracy = 1;
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
  }
  
  trialNum++; //Increment trial number
  
  int currtime = millis();
  
  TableRow row = table.addRow();
  row.setInt("trial num", trialNum);
  print(trialNum);
  print(",");
  row.setInt("id", id);
  print(id);
  print(",");
  row.setInt("original x position", origX);
  print(origX);
  print(",");
  row.setInt("original y position", origY);
  print(origY);
  print(",");
  row.setInt("target x position", bounds.x + bounds.width / 2);
  print(bounds.x + bounds.width / 2);
  print(",");
  row.setInt("target y position", bounds.y + bounds.width / 2);
  print(bounds.y + bounds.width / 2);
  print(",");
  row.setInt("target width", buttonSize);
  print(buttonSize);
  print(",");
  row.setFloat("time taken", (currtime - time) / 1000f);
  print((currtime - time) / 1000f);
  print(",");
  row.setInt("accuracy", accuracy);
  println(accuracy);
  time = currtime;
  origX = mouseX;
  origY = mouseY;

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(int i)
{
  Rectangle bounds = getButtonLocation(i);

  if (trials.get(trialNum) == i) // see if current button is the target
  {
    if ((mouseX > bounds.x && mouseX < bounds.x + bounds.width) && (mouseY > bounds.y && mouseY < bounds.y + bounds.height))
      fill(0, 255, 0);
    else 
      fill(255, 0, 0);
  }
  else
    fill(200); // if not, fill gray

  rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  if (keyCode == KeyEvent.VK_UP || keyCode == KeyEvent.VK_W) {
    if (mouseY > margin + buttonSize) {
      robot.mouseMove(mouseX, mouseY+offset-padding-buttonSize);
    }
    
  } else if (keyCode == KeyEvent.VK_DOWN || keyCode == KeyEvent.VK_S) {
    if (mouseY <= margin + buttonSize*3 + padding*3) {
      robot.mouseMove(mouseX, mouseY+offset+padding+buttonSize);
    }
  } else if (keyCode == KeyEvent.VK_LEFT || keyCode == KeyEvent.VK_A) {
    if (mouseX > margin + buttonSize) {
      robot.mouseMove(mouseX - padding - buttonSize, mouseY+offset);
    }
  } else if (keyCode == KeyEvent.VK_RIGHT || keyCode == KeyEvent.VK_D) {
    if (mouseX <= margin + buttonSize*3 + padding*3) {
      robot.mouseMove(mouseX + padding + buttonSize, mouseY+offset);
    }
  }
}
