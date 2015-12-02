import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import kinect4WinSDK.*;

Box2DProcessing box2d;
Kinect kinect;
ArrayList <SkeletonData> bodies;
ArrayList<Boundary> boundaries;
ArrayList<Box> boxes;
Circle circle;
public PVector v2;

void setup()
{
  frameRate(30);
  size(640, 480);
  background(0);
  kinect = new Kinect(this);
  smooth();
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -20);
  bodies = new ArrayList<SkeletonData>();
  boundaries = new ArrayList<Boundary>();
  //boundaries.add(new Boundary(width, 0, width/2, 5));
  boundaries.add(new Boundary(width/2, height, width, 5));
  boundaries.add(new Boundary(width, height/2, 5, height));
  boundaries.add(new Boundary(0, height/2, 5, height));
  boxes = new ArrayList<Box>();
}
 
void draw()
{
  background(255, 120, 120);
  box2d.step();
   if (random(1) < 0.1) {
    Box p = new Box(random(width),random(0, 20));
    boxes.add(p);
  }
 // image(kinect.GetDepth(), 0, 0, width, height);
  image(kinect.GetMask(), 0, 0, width, height);
  for (int i=0; i<bodies.size (); i++) 
  {
    drawSkeleton(bodies.get(i));
    drawPosition(bodies.get(i));
  }
 for (Box b: boxes) {
    b.display();
  }
}

void drawPosition(SkeletonData _s) 
{
  noStroke();
  fill(0, 100, 255);
  String s1 = str(_s.dwTrackingID);
  text(s1, _s.position.x*width/2, _s.position.y*height/2);
}
 
void drawSkeleton(SkeletonData _s) 
{ 
  // Left hand
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_LEFT, 
  Kinect.NUI_SKELETON_POSITION_HAND_LEFT);
 
   // Right hand
  DrawBone(_s, 
  Kinect.NUI_SKELETON_POSITION_WRIST_RIGHT, 
  Kinect.NUI_SKELETON_POSITION_HAND_RIGHT);
 
}
 
void DrawBone(SkeletonData _s, int _j1, int _j2) 
{
  noFill();
  stroke(255, 255, 0);
  circle = new Circle(20, _s.skeletonPositions[_j1].x*width, 
    _s.skeletonPositions[_j1].y*height ); 
    
  if (_s.skeletonPositionTrackingState[_j1] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED &&
    _s.skeletonPositionTrackingState[_j2] != Kinect.NUI_SKELETON_POSITION_NOT_TRACKED)
    {
      circle.display();
      for(Box b: boxes)
      {
        circle.attract(b);
      }
    }
   v2 = new PVector(_s.skeletonPositions[_j1].x*width, 
    _s.skeletonPositions[_j1].y*height);
   
}
 
void appearEvent(SkeletonData _s) 
{
  if (_s.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    bodies.add(_s);
  }
}
 
void disappearEvent(SkeletonData _s) 
{
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_s.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.remove(i);
      }
    }
  }
}
 
void moveEvent(SkeletonData _b, SkeletonData _a) 
{
  if (_a.trackingState == Kinect.NUI_SKELETON_NOT_TRACKED) 
  {
    return;
  }
  synchronized(bodies) {
    for (int i=bodies.size ()-1; i>=0; i--) 
    {
      if (_b.dwTrackingID == bodies.get(i).dwTrackingID) 
      {
        bodies.get(i).copy(_a);
        break;
      }
    }
  }
}