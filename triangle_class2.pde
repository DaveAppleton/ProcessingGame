import ddf.minim.*;




class projectile {
  int xpos, ystart, accTime;
  float xvel, yvel;
  float acceleration = 1;
  float ypos;
  boolean first = true;
  
 projectile(int x, int y, float vx, float vy)
 { 
    xpos = x;
    ystart = y;
    xvel = vx;
    yvel = vy;
    accTime = 0; 
   
 }
  
  boolean motion()
  {
     accTime++;
     if (!first)
       clear();
     first = false;
     xpos += xvel;
     ypos = ystart + yvel * accTime + acceleration * accTime * accTime / 2.0;
     
     if (xpos < -8) return false;
     if (xpos > width + 8) return false;
     if (ypos > height + 8) return false;
     
     stroke(255, 0, 0);
     fill(255, 0, 0);
     ellipseMode(CENTER);
     ellipse(xpos,ypos, 8, 8);
     return true;
  } 

  void clear()
  {
     stroke(255, 255, 255);
     fill(255, 255, 255);
     ellipseMode(CENTER);
     ellipse(xpos,ypos, 8, 8);
  }  
}
// -------- end of projectile --------------------

class spaceShip {
  int oldx,oldy;
  float r = 255;
  float g = 0;
  float b = 0;
  boolean first;
  boolean newFlight;
  int dY = 20;
  int dX = 15;
  boolean beenHit = false;
  projectile[] pj = new projectile[4];
  Minim minim;
  AudioPlayer shot;
  
  
  spaceShip (triangle_class2 parent, int baseX, int baseY)
  {
     this.oldx = baseX;
     this.oldy = baseY;
     r = random(256);
     g = random(256);
     b = random(256);
     minim = new Minim(parent);
     shot = minim.loadFile("hit.mp3",2048);
     first = true;
     newFlight = true;
  } 
  
  void stop()
  {
    shot.close();
    minim.stop();

  }
  
  void setColor(float re, float gr, float bl)
  {
    r = re;
    g = gr;
    b = bl;
    //
  }
  
  void clear()
  {
      stroke(255,255,255);
      fill(255,255,255);
      triangle(oldx,oldy,oldx-dX,oldy+dY,oldx+dX,oldy+dY);  
  }
  boolean motion()
  {
    if (beenHit)
    {
      boolean projectilesMoving = false;
      for (int i = 0; i < pj.length; i++)
        projectilesMoving |= pj[i].motion();
      return projectilesMoving;
    }
    if (!first)
      clear();
    first = false;
    stroke(0,0,0);
    fill(r,g,b);
    oldy -= random(2);
    oldx += random(20) - 10;
    oldx = (oldx + 400) % 400;
    oldy = (oldy + 500) % 500; 
    triangle(oldx,oldy,oldx-dX,oldy+dY,oldx+dX,oldy+dY);
    return true;
  }
  
  void iClickedYou(int x,int y)
  {
    //
    if (!((y > oldy) && (y < oldy+dY)))
      return;
    if (!((x > oldx) && (x < oldx+dX)))
      return;
    if (beenHit) // eliminate the double explosions that we saw
      return;
    beenHit = true;  
    clear();  
    shot.play();
    pj[0] = new projectile(x,y,-3,-12);
    pj[1] = new projectile(x,y,3,-12);
    pj[2] = new projectile(x,y,-3,-8);
    pj[3] = new projectile(x,y,3,-8);  
  }
}
// ----- end of spaceShip

  Minim minim;
  AudioPlayer theme;
  AudioPlayer gameover;
  PImage  keen;

  spaceShip c[] = new spaceShip[5];
  int dx[] = {0,0,50,-50,0};
  int dy[] = {0,50,50,50,100};
  PFont fontA;
  boolean inPlay = true;


void setup()
{
  size(400,500);
  for (int i = 0; i < dx.length; i++)
  {
    c[i] = new spaceShip(this,200+dx[i],350+dy[i]);
    
  }
  fontA = loadFont("Ziggurat-HTF-Black-32.vlw");
    textFont(fontA, 32);
  background(255,255,255,0);
  minim = new Minim(this);
  theme = minim.loadFile("theme.mp3",2048);
  gameover = minim.loadFile("GAMEOVERSND.WAV");
  theme.loop();
  keen = loadImage("ck_goodbye_large.gif");
  
  //shot = minim.loadFile("alien-noise-01.wav",2048);
  //input = minim.getLineIn();

}

void stop()
{
    //shot.close();
    for (int i = 0; i < c.length; i++)
      c[i].stop();
      if (theme.isLooping())
        theme.close();
      gameover.close();
      minim.stop();
    // this calls the stop method that
    // you are overriding by defining your own
    // it must be called so that your application
    // can do all the cleanup it would normally do
    super.stop();
}

String[] s = { "Commander Keen","Invasion","of the","Vorticons" };
int[] pos = {40,130,150,130 };

void draw()
{
  if (!inPlay)
    return;
  fill(0);
  for (int i = 0; i < pos.length; i++ )
  {
    text(s[i],pos[i],100+40*i);
  }
  
  inPlay = false;
  for (int i = 0; i < c.length; i++)
    inPlay |= c[i].motion();
  delay(50);
  
  if (!inPlay)
  {
    stroke(255,0,0);
    fill(0,128,128);
    text("GAME OVER",80,440);
    theme.pause();
    gameover.play();
    image(keen,60,110);
    
  }
}

void mouseClicked()
{
  for (int i = 0; i < c.length; i++)
    c[i].iClickedYou(mouseX,mouseY);
}


