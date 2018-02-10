#pragma once

#include "ofxiOS.h"
#include "b2dJson.h"
#include "ofxBox2d.h"
#include "FluxlyClasses.h"

#define nControls (10)
#define nWorlds (1)
#define lightningPeriod (18)
#define lightningWait (8)

#define GRAVITY_UP_CONTROL (0)
#define BOXEN_CONTROL (1)
#define WIND_FROM_EAST_CONTROL (2)
#define WIND_FROM_WEST_CONTROL (3)
#define MORE_GRAVITY_CONTROL (4)
#define LIGHTNING_CONTROL (5)
#define CLOUD_CONTROL (6)
#define EARTHQUAKE_CONTROL (7)
#define TELEPORT_CONTROL (8)
#define BUBBLE_CONTROL (9)

class BoxData {
public:
    int boxId;
};

class FluxlyConnection {
public:
    int id1;
    int id2;
};

class ofApp : public ofxiOSApp {
	
  public:
        void setup();
        void update();
        void draw();
        void exit();
	
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);
        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        //void checkControls();
        void contactStart(ofxBox2dContactArgs &e);
        void contactEnd(ofxBox2dContactArgs &e);
        Boolean inBounds(int controlId, int x1, int y1);
        void addCloud();
        void addLightning();
        void removeLightning();
        bool notConnectedYet(int n1, int n2);
    bool complementaryColors(int n1, int n2);

        b2dJson json;
        string errorMsg;
        int controlType[nControls] = {
            GRAVITY_UP_CONTROL, BOXEN_CONTROL, WIND_FROM_EAST_CONTROL, WIND_FROM_WEST_CONTROL, MORE_GRAVITY_CONTROL,
            LIGHTNING_CONTROL, CLOUD_CONTROL, EARTHQUAKE_CONTROL,TELEPORT_CONTROL, BUBBLE_CONTROL
         };
    
    int controlX[nControls] = { 0, 1, 2, 3, 4, 0, 1, 2, 3, 4 };
    int controlY[nControls] = { 1, 1, 1, 1, 1, 0, 0, 0, 0, 0 };
    int controlW = 60;
    int controlH = 60;
    // 0 = inactive, 1 = not pressed, 2 = pressed
    int controlState[nControls] = {
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    };
    int startTouchId[nControls] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    };
    int touchMargin = 2;
    
    float gravityX = 0.0;
    float gravityY = 10.0;
    float gravityXMin = -10.0;  // was -20
    float gravityXMax = 10.0;
    float gravityYMin = -10.0;
    float gravityYMax = 10.0;
    float origGravityX = 0.0;
    float origGravityY = 10.0;
    
    ofTrueTypeFont vagRounded;
    string eventString;
    
    int worldX[2] = { 0, 0 };
    int worldY[2] = { 0, 384 };
    int worldW = 318;
    int worldH = 440;
    int screenW = 320;
    int screenH = 568;
    int globalTick = 0;
    int tempId1;
    int tempId2;
    int maxJoints = 3;
    
    bool lightningAdded = false;
    bool earthquakeApplied = false;
    bool teleported = false;
    
    ofImage controlImage[nControls];
    ofImage background[nWorlds];
    ofImage foreground[nWorlds];

    string controlImageFilename[nControls] = {
        "lessGravity.png", "moreBoxen.png", "windFromEast.png", "windFromWest.png", "moreGravity.png",
        "lightningControl.png", "cloudControl.png", "shake.png",  "teleport.png", "bubbles.png"
    };
    
    string playerImage[nWorlds] = { "fluxum.png" };
    
    ofxBox2d box2d[nWorlds];
    
   // vector <shared_ptr<FluxlyPlayer> > player;
    vector <shared_ptr<FluxlyBox> > boxen;
    vector <shared_ptr<FluxlyCloud> > clouds;
    vector <shared_ptr<FluxlyLightning> > lightning;
    //vector <shared_ptr<FluxlyCircle> > circles;
    //vector <shared_ptr<ofxBox2dCircle> > bubbles;
    vector <shared_ptr<ofxBox2dJoint> > joints;
    vector <shared_ptr<FluxlyConnection> > connections;
    
    ofRectangle bounds[nWorlds];
};


