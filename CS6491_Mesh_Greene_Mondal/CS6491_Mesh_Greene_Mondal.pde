import processing.opengl.*;
import java.nio.*;
//  ******************* LITM: Layer-Interpolating Tet Mesh, 2017 ***********************
Boolean 
  animating=true, 
  PickedFocus=false, 
  center=true, 
  track=false, 
  showViewer=false, 
  showBalls=true, 
  showControl=true, 
  showCurve=true, 
  showPath=true, 
  showKeys=true, 
  showSkater=false, 
  scene1=false,
  solidBalls=false,
  showCorrectedKeys=true,
  showQuads=true,
  showVecs=true,
  showTube=true,
  flipped = false;
float 
 h_floor=0, h_ceiling=600,  h=h_floor,
  t=0, 
  s=0,
  rb=30, rt=rb; // radius of the balls and tubes
  
int
  f=0, maxf=2*30, level=4, method=5;
String SDA = "angle";
float defectAngle=0;
pts P = new pts(); // polyloop in 3D
pts Q = new pts(); // second polyloop in 3D
pts R, S; 
pts Ptubes = new pts();
pts Qtubes = new pts();
pts QPtubes = new pts();
pts Ptriangles = new pts();
pts Qtriangles = new pts();
pts Pedges = new pts();
pts Qedges = new pts();
pts EdgeTubes = new pts();
//GL gl;

void setup()
{
  Anna = loadImage("data/Anna.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  Db = loadImage("data/Db.jpg"); 
  textureMode(NORMAL);   
  blendMode(BLEND);
  //glShadeModel(GL.GL_SMOOTH);
  ambientLight(0,20,50); 
  pointLight(255,220,190,width/2,height/2,0); 
  size(900, 900, P3D); // P3D means that we will do 3D graphics
  //size(600, 600, P3D); // P3D means that we will do 3D graphics
  P.declare(); Q.declare(); // P is a polyloop in 3D: declared in pts
  //P.resetOnCircle(6,100); Q.copyFrom(P); // use this to get started if no model exists on file: move points, save to file, comment this line
  P.loadPts("data/pts");  
  Q.loadPts("data/pts2"); // loads saved models from file (comment out if they do not exist yet)
  noSmooth();
  //smooth();
  frameRate(30);
  R=P; S=Q;
  Ptubes.declare();
  Qtubes.declare();
  QPtubes.declare();
  Ptriangles.declare();
  Qtriangles.declare();
  Pedges.declare();
  Qedges.declare();
  EdgeTubes.declare();
}

void draw()
{
  Ptubes.empty();
  Qtubes.empty();
  QPtubes.empty();
  Ptriangles.empty();
  Qtriangles.empty();
  Pedges.empty();
  Qedges.empty();
  EdgeTubes.empty();
  background(255);
  hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(h); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  R.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
 
 if(showTube)
 {
  // tubes for floor
  boolean empty = true;
  for(int i = 0;i < P.nv; i++)
  {
    for(int j = i+1; j < P.nv; j++)
    {
      for(int k = j+1; k < P.nv; k++)
      {
        pt A = P.G[i];
        pt B = P.G[j];
        pt C = P.G[k];
        
        pt center = circumCenter(A,B,C);
        boolean flag = false;
        for(int m = 0; m < P.nv; m++)
        {
          pt M = P.G[m];
          if(M == A || M == B || M == C)
            continue;
          else
          {
            if(isInCircle(A,center,M))
            {
              flag = true;         
              break;
            }
          }
        }
        if(!flag)
        {
          addTube(A,B,0);
          addTube(B,C,0);
          addTube(A,C,0);
          addEdge(A,B,0);
          addEdge(B,C,0);
          addEdge(A,C,0);
          Ptriangles.addPt(A);
          Ptriangles.addPt(B);
          Ptriangles.addPt(C);
        }
      }
    }
  }
  
  // tubes for ceiling
  for(int i = 0;i < Q.nv; i++)
  {
    for(int j = i+1; j < Q.nv; j++)
    {
      for(int k = j+1; k < Q.nv; k++)
      {
        pt A = Q.G[i];
        pt B = Q.G[j];
        pt C = Q.G[k];
        
        pt center = circumCenter(A,B,C);
        boolean flag = false;
        for(int m = 0; m < Q.nv; m++)
        {
          pt M = Q.G[m];
          if(M == A || M == B || M == C)
            continue;
          else
          {
            if(isInCircle(A,center,M))
            {
              flag = true;         
              break;
            }
          }
        }
        if(!flag)
        {
          addTube(A,B,1);
          addTube(B,C,1);
          addTube(A,C,1);
          addEdge(A,B,1);
          addEdge(B,C,1);
          addEdge(A,C,1);
          Qtriangles.addPt(A);
          Qtriangles.addPt(B);
          Qtriangles.addPt(C);
        }
      }
    }
  }
 
   for (int i = 0; i < Pedges.nv-1; i+=2)
  {
      pt A = Pedges.G[i];
      pt B = Pedges.G[i+1];
      pt C = Qedges.G[0];
      pt D = Qedges.G[1];


    float avgDist = (d(A,C)+d(B,D))/2;
    for (int j = 0; j < Qedges.nv-1; j+=2){
      pt Ctemp = Qedges.G[j];
      pt Dtemp = Qedges.G[j+1];
      float tempAvg1 = (d(A,Ctemp)+d(B,Dtemp))/2;
      float tempAvg2 = (d(A,Dtemp)+d(B,Ctemp))/2;
      if (min(tempAvg1,tempAvg2) < avgDist){
        if (tempAvg1 < tempAvg2){
          avgDist = tempAvg1;
          C = Ctemp;
          D = Dtemp;
        }
        else {
          avgDist = tempAvg2;
          C = Dtemp;
          D = Ctemp;
        }
      }
    }
    
    EdgeTubes.addTube(A,C);
    EdgeTubes.addTube(B,D);
    float diagAC = d(A,D);
    float diagBD = d(B,C);
    if (diagAC < diagBD) EdgeTubes.addTube(A,D);
    else EdgeTubes.addTube(B,C);
    }
   
  for(int i = 0; i < Ptriangles.nv-2; i+=3)
  {
    empty = true;
    pt A = Ptriangles.G[i];
    pt B = Ptriangles.G[i+1];
    pt C = Ptriangles.G[i+2];
    //pt minPt = findBulge(A,B,C,1);
    if (Pedges.findTube(A,B)>=0||Pedges.findTube(B,C)>=0||Pedges.findTube(A,C)>=0) empty=false;
    pt minPt = findBulge(A,B,C,1);
    pt center = circumCenter(minPt,C,A,B);
    float radius = d(center,A); 
    //for (int k = 0; k < P.nv; k++)
    //{
    //  if (d(center,P.G[k])<radius && k!=i && k!=(i+1) && k!=(i+2))
    //  {
    //    //another point is in the sphere!
    //    empty = false;
    //    break;
    //  }
    //}
    //for (int k = 0; k < Q.nv; k++)
    //{
    //  if (d(center,Q.G[k])<radius && k!=minPt) // && k != minPt ID
    //  {
    //    //another point is in the sphere!
    //    empty = false;
    //    break;
    //  }
    //}
    if (empty)
    {
    addTube(minPt,A,2);
    addTube(minPt,B,2);
    addTube(minPt,C,2);
    }
  }
  

  //fill(lime);
  //for(int i = 0; i < Pedges.nv; i+=2)
  //{
  //  beam(Pedges.G[i],Pedges.G[i+1],rt);
  //}

  

  
  for(int i = 0; i < Qtriangles.nv-2; i+=3)
  {
    empty = true;
    pt A = Qtriangles.G[i];
    pt B = Qtriangles.G[i+1];
    pt C = Qtriangles.G[i+2];
    if (Qedges.findTube(A,B)>=0||Qedges.findTube(B,C)>=0||Qedges.findTube(A,C)>=0) empty=false;
    pt minPt = findBulge(A,B,C,0);
    //int minPt = findBulge(A,B,C,0);
    pt center = circumCenter(minPt,C,A,B);
    float radius = d(center,A); 
    //for (int k = 0; k < P.nv; k++)
    //{
    //  if (d(center,P.G[k])<radius && k!=minPt) // && k != center ID
    //  {
    //    //another point is in the sphere!
    //    empty = false;
    //    break;
    //  }
    //}
    //for (int k = 0; k < Q.nv; k++)
    //{
    //  if (d(center,Q.G[k])<radius && k!=i && k!=(i+1) && k!=(i+2))
    //  {
    //    //another point is in the sphere!
    //    empty = false;
    //    break;
    //  }
    //}
    if (empty)
    {
    addTube(A,minPt,2);
    addTube(B,minPt,2);
    addTube(C,minPt,2);
    }
  }
  
    if(showBalls) 
  {
    //fill(orange);
    fill(#CCCCCC);
    P.drawBalls(rb);
    //fill(green); 
    fill(#CCCCCC);
    Q.drawBalls(rb);  
    fill(red,100); 
    R.showPicked(rb+5); 
  }  
  
  //fill(orange);
  fill(#CCCCCC);
  for(int i = 0; i < Ptubes.nv - 1; i+=2)
  {
    beam(Ptubes.G[i],Ptubes.G[i+1],rt);
  }
  
  fill(#CCCCCC);
  for(int i = 0; i < EdgeTubes.nv - 1; i+=2)
  {
    beam(EdgeTubes.G[i],EdgeTubes.G[i+1],rt);
  }
  
  fill(#CCCCCC);
  for(int i = 0; i < QPtubes.nv - 1; i+=2)
  {
    beam(QPtubes.G[i],QPtubes.G[i+1],rt);
  }
  
  //fill(green);
  fill(#CCCCCC);
  for(int i = 0; i < Qtubes.nv - 1; i+=2)
  {
    beam(Qtubes.G[i],Qtubes.G[i+1],rt);
  }
  

  
  //fill(red);
  //for(int i = 0; i < Pedges.nv - 1; i+=2)
  //{
  //  beam(Pedges.G[i],Pedges.G[i+1],rt);
  //}
  //fill(red);
  //for(int i = 0; i < Qedges.nv - 1; i+=2)
  //{
  //  beam(Qedges.G[i],Qedges.G[i+1],rt);
  //}
  
}
  
  
  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible

  //*** TEAM: please fix these so that they provice the correct counts
  scribeHeader("Site count: "+3+" floor + "+7+" ceiling",1);
  scribeHeader("Beam count: "+3+" floor + "+7+" ceiling +"+6+" mixed",2);
  scribeHeader("Tet count: "+20,3);
 
  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if(mousePressed) {stroke(cyan); strokeWeight(3); noFill(); ellipse(mouseX,mouseY,20,20); strokeWeight(1);}
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX+14,mouseY+20,26,26); fill(red); text(key,mouseX-5+14,mouseY+4+20); strokeWeight(1); }
  if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  change=true;
}