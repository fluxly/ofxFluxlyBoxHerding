#pragma once

#include "ofxiOS.h"
#include "b2dJson.h"
#include "ofxBox2d.h"
#include "FluxlyClasses.h"
#include "ofxPd.h"

#define nControls (10)
#define lightningPeriod (18)
#define lightningWait (8)

#define GRAVITY_UP_CONTROL (0)
#define WIND_FROM_EAST_CONTROL (1)
#define WIND_FROM_WEST_CONTROL (2)
#define SHOW_JOINTS_CONTROL (3)
#define PAUSE_MORE_CONTROL (4)
#define LIGHTNING_CONTROL (5)
#define CLOUD_CONTROL (6)
#define TELEPORT_CONTROL (7)
#define COLORWHEEL_CONTROL (8)
#define BUBBLE_CONTROL (9)

// a namespace for the Pd types
using namespace pd;

class BoxData {
public:
    int boxId;
};

class FluxlyConnection {
public:
    int id1;
    int id2;
};

class FluxlyJointConnection {
public:
    int id1;
    int id2;
    ofxBox2dJoint *joint;
};

class ofApp : public ofxiOSApp, public PdReceiver, public PdMidiReceiver {
	
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
            GRAVITY_UP_CONTROL, WIND_FROM_EAST_CONTROL, WIND_FROM_WEST_CONTROL, SHOW_JOINTS_CONTROL, PAUSE_MORE_CONTROL,
            LIGHTNING_CONTROL, CLOUD_CONTROL, TELEPORT_CONTROL, COLORWHEEL_CONTROL, BUBBLE_CONTROL
         };
    
    ofxPd pd;
    vector<Patch> instances;
    
    // audio callbacks
    void audioReceived(float * input, int bufferSize, int nChannels);
    void audioRequested(float * output, int bufferSize, int nChannels);
    
    // sets the preferred sample rate, returns the *actual* samplerate
    // which may be different ie. iPhone 6S only wants 48k
    float setAVSessionSampleRate(float preferredSampleRate);
    
    int midiChan;
    int tempo = 1;
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
    int maxJoints = 4;
    
    bool lightningAdded = false;
    bool earthquakeApplied = false;
    bool teleported = false;
    bool jointsShown = false;
    bool paused = false;
    bool showColorWheel = false;
    int teleportingId = -1;
    
    ofImage controlImage[nControls];
    ofImage background;
    ofImage foreground;
    ofImage colorwheel;

    string controlImageFilename[nControls] = {
        "lessGravity.png", "windFromEast.png", "windFromWest.png", "showJoints.png", "pauseMore.png",
        "lightningControl.png", "cloudControl.png", "teleport.png",  "colorWheelControl.png", "bubbles.png"
    };
    
    ofxBox2d box2d;
    
    vector <shared_ptr<FluxlyBox> > boxen;
    vector <shared_ptr<FluxlyCloud> > clouds;
    vector <shared_ptr<FluxlyLightning> > lightning;
    vector <shared_ptr<FluxlyJointConnection> > joints;
    vector <shared_ptr<FluxlyConnection> > connections;
    
    ofRectangle bounds;
};


