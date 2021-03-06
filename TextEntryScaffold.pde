import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 538; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;
PImage keyboard;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  //noCursor();
  watch = loadImage("watchhand3smaller.png");
  keyboard = loadImage("keyboard.png");
  //finger = loadImage("pngeggSmaller.png"); //not using this
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(2880, 1440); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 50)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
}

//state to know if we are zoomed or not
boolean zoomL = false;
boolean zoomM = false;
boolean zoomR = false;

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  
   //check to see if the user finished. You can't change the score computation.
  if (finishTime!=0)
  {
    fill(0);
    textAlign(CENTER);
    text("Trials complete!",800,400); //output
    text("Total time taken: " + (finishTime - startTime),800, 440); //output
    text("Total letters entered: " + lettersEnteredTotal,800,480); //output
    text("Total letters expected: " + lettersExpectedTotal,800,520); //output
    text("Total errors entered: " + errorsTotal,800,280); //output
    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    text("Raw WPM: " + wpm,800,600); //output
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    text("Freebie errors: " + nf(freebieErrors,1,3),800,640); //output
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    text("Penalty: " + penalty,800,680);
    text("WPM w/ penalty: " + (wpm-penalty),800,720); //yes, minus, because higher WPM is better
    return;
  }
  
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
    
    //conditional rendering for different zooms
    if(zoomL || zoomM || zoomR){
     fill(255, 255, 0); //red button
      rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28); //draw left red button
      fill(0, 255, 255); //green button
      rect((width/2) - sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
      fill(255, 0, 255); //blue button
      rect((width/2) + sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
      
      fill(255, 0, 255); //blue button
      rect(width/2-sizeOfInputArea/2, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28); //draw left red button
      fill(255, 255, 0); //red button
      rect((width/2) - sizeOfInputArea/6, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
      fill(0, 255, 255); //green button
      rect((width/2) + sizeOfInputArea/6, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
      
      fill(0, 255, 255); //green button
      rect(width/2-sizeOfInputArea/2, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28); //draw left red button
      fill(255, 0, 255); //blue button
      rect((width/2) - sizeOfInputArea/6, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
      fill(255, 255, 0); //red button
      rect((width/2) + sizeOfInputArea/6, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28); //draw right green button
    }

    if(zoomL){
      displayZoom("QWEASDZXC");
    }else if(zoomM){
      displayZoom("RTYFGHVBN");
    }else if(zoomR){
      displayZoom("UIOJKLM P");
    }
    else{// no zoom
      //example design draw code
      fill(255, 0, 0); //red button
      rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84); //draw left red button
      fill(0, 255, 0); //green button
      rect((width/2) - sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84); //draw right green button
      fill(0, 0, 255); //blue button
      rect((width/2) + sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84); //draw right green button
      textAlign(CENTER);
      fill(200);
      
      float watchscale = DPIofYourDeviceScreen/430.0; //normalizes the image size
      pushMatrix();
      translate(width/2, height/2 + sizeOfInputArea*.1);
      scale(watchscale);
      imageMode(CENTER);
      image(keyboard, 0, 0);
      popMatrix();
      //image(keyboard, width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2);
    }
    
    // Printing the current string in the app
    if(currentTyped.length() < 15){
      fill(255,255,255);
      textAlign(CENTER);
      text("" + currentTyped, width/2, height/2-sizeOfInputArea/2.6); //draw current letter
    } else {
      fill(255,255,255);
      textAlign(CENTER);
      text("" + currentTyped.substring(currentTyped.length()-15, currentTyped.length()), width/2, height/2-sizeOfInputArea/2.6); //draw current letter  
    }
    
  }
 
 
  //drawFinger(); //no longer needed as we'll be deploying to an actual touschreen device
}

void displayZoom(String s){
      fill(0, 0, 0);
      text(s.charAt(0), width/2 - sizeOfInputArea/2, height/2-sizeOfInputArea/3 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(1), (width/2) - sizeOfInputArea/6, height/2-sizeOfInputArea/3 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(2), (width/2) + sizeOfInputArea/6, height/2-sizeOfInputArea/3 + sizeOfInputArea*.18); //draw current letter
      
      text(s.charAt(3), width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea*.05 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(4), (width/2) - sizeOfInputArea/6, height/2 - sizeOfInputArea*.05 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(5), (width/2) + sizeOfInputArea/6, height/2 - sizeOfInputArea*.05 + sizeOfInputArea*.18); //draw current letter
      
      text(s.charAt(6), width/2 - sizeOfInputArea/2, height/2 + sizeOfInputArea*.25 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(7), (width/2) - sizeOfInputArea/6, height/2 + sizeOfInputArea*.25 + sizeOfInputArea*.18); //draw current letter
      text(s.charAt(8), (width/2) + sizeOfInputArea/6, height/2 + sizeOfInputArea*.25 + sizeOfInputArea*.18); //draw current letter
      
     
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


boolean currentlyTouch = false;
float startTouchX = 0;
float startTouchY = 0;
void mousePressed()
{
  startTouchX = mouseX;
  startTouchY = mouseY;
  currentlyTouch = true;
  /*
  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  {
    currentLetter --;
    if (currentLetter<'_') //wrap around to z
      currentLetter = 'z';
  }

  if (didMouseClick(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  {
    currentLetter ++;
    if (currentLetter>'z') //wrap back to space (aka underscore)
      currentLetter = '_';
  }

  if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  {
    if (currentLetter=='_') //if underscore, consider that a space bar
      currentTyped+=" ";
    else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
      currentTyped+=currentLetter;
  }*/
  
  
  
}

//on mouse release, check for swipes
void mouseReleased(){
  //decide if swipe or touch
  float halfScreenArea = sizeOfInputArea / 2;
  if(currentlyTouch){
    if(mouseX - startTouchX > halfScreenArea){//spacebar
      currentTyped = currentTyped + " ";
      currentlyTouch = false;
      return;
    }else if(startTouchX - mouseX > halfScreenArea){//backspace
      if(currentTyped.length() > 0){
        currentTyped = currentTyped.substring(0, currentTyped.length()-1);
      }
      currentlyTouch = false;
      return;
    }
    else if(mouseY - startTouchY > halfScreenArea){
      zoomL = false;
      zoomR = false;
      zoomM = false;
      return;
    }
  }
  
  
  
  //if we aren't currently zoomed, check for zoom zones
  if(!zoomL && !zoomM && !zoomR){
    if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84)) //check if click in left button
    {
      //left third
      //currentLetter = 'L';
      zoomL = true;
    }
    
    if (didMouseClick((width/2) - sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84)) //check if click in left button
    {
      //middle third
      //currentLetter = 'M';
      zoomM = true;
    }
    
    if (didMouseClick((width/2) + sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.84)) //check if click in left button
    {
      //right third
      //currentLetter = 'R';
      zoomR = true;
    }
  }else{    
    if(didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28)){//top left
      if(zoomL){
        currentTyped+="q";
      }else if(zoomM){
        currentTyped+="r";
      }else if(zoomR){
        currentTyped+="u";
      }
    }
    
    if(didMouseClick((width/2) - sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28)){//top middle
      if(zoomL){
        currentTyped+="w";
      }else if(zoomM){
        currentTyped+="t";
        currentLetter = 't';
      }else if(zoomR){
        currentTyped+="i";
      }
    }
    
    if(didMouseClick((width/2) + sizeOfInputArea/6, height/2-sizeOfInputArea/3, sizeOfInputArea/3, sizeOfInputArea*.28)){//top right
      if(zoomL){
        currentTyped+="e";
      }else if(zoomM){
        currentTyped+="y";
      }else if(zoomR){
        currentTyped+="o";
      }
    }
    
    if(didMouseClick(width/2-sizeOfInputArea/2, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28)){//middle left
      if(zoomL){
        currentTyped+="a";
      }else if(zoomM){
        currentTyped+="f";
      }else if(zoomR){
        currentTyped+="j";
      }
    }
    
    if(didMouseClick((width/2) - sizeOfInputArea/6, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28)){//middle middle
      if(zoomL){
        currentTyped+="s";
      }else if(zoomM){
        currentTyped+="g";
      }else if(zoomR){
        currentTyped+="k";
      }
    }
    
    if(didMouseClick((width/2) + sizeOfInputArea/6, height/2 - sizeOfInputArea*.05, sizeOfInputArea/3, sizeOfInputArea*.28)){//middle right
      if(zoomL){
        currentTyped+="d";
      }else if(zoomM){
        currentTyped+="h";
      }else if(zoomR){
        currentTyped+="l";
      }
    }
    
    if(didMouseClick(width/2-sizeOfInputArea/2, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28)){//botto  left
      if(zoomL){
        currentTyped+="z";
      }else if(zoomM){
        currentTyped+="v";
      }else if(zoomR){
        currentTyped+="m";
      }
    }
    
    if(didMouseClick((width/2) - sizeOfInputArea/6, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28)){//bottom middle
      if(zoomL){
        currentTyped+="x";
      }else if(zoomM){
        currentTyped+="b";
      }else if(zoomR){
        //currentTyped+="";
      }
    }
    
    if(didMouseClick((width/2) + sizeOfInputArea/6, height/2 + sizeOfInputArea*.05 + sizeOfInputArea*.18, sizeOfInputArea/3, sizeOfInputArea*.28)){//bottom right
       if(zoomL){
        currentTyped+="c";
      }else if(zoomM){
        currentTyped+="n";
      }else if(zoomR){
        currentTyped+="p";
      }
    }
    
    //if we're already zoomed, then select a character and set zoom to false
    if( (zoomL || zoomM || zoomR) && didMouseClick(width/2 - sizeOfInputArea/2, height/2 - sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea*.16)){
      zoomL = false;
      zoomM = false;
      zoomR = false;
    }
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger,52,341);
  if (mousePressed)
     fill(0);
  else
     fill(255);
  ellipse(0,0,5,5);

  popMatrix();
  }
  

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
