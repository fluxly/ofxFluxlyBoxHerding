#include "ofApp.h"
#import <AVFoundation/AVFoundation.h>


//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    ofSetLogLevel("Pd", OF_LOG_VERBOSE); // see verbose info inside
    // try to set the preferred iOS sample rate, but get the actual sample rate
    // being used by the AVSession since newer devices like the iPhone 6S only
    // want specific values (ie 48000 instead of 44100)
    float sampleRate = setAVSessionSampleRate(44100);
    
    // the number if libpd ticks per buffer,
    // used to compute the audio buffer len: tpb * blocksize (always 64)
    int ticksPerBuffer = 8; // 8 * 64 = buffer len of 512
    
    // setup OF sound stream using the current *actual* samplerate
    ofSoundStreamSetup(2, 0, this, sampleRate, ofxPd::blockSize()*ticksPerBuffer, 3);
    
    // setup Pd
    //
    // set 4th arg to true for queued message passing using an internal ringbuffer,
    // this is useful if you need to control where and when the message callbacks
    // happen (ie. within a GUI thread)
    //
    // note: you won't see any message prints until update() is called since
    // the queued messages are processed there, this is normal
    //
    if(!pd.init(2, 1, sampleRate, ticksPerBuffer-1, false)) {
        OF_EXIT_APP(1);
    }
    
    // Setup externals
   
    midiChan = 1; // midi channels are 1-16
    
    // subscribe to receive source names
    pd.subscribe("toOF");
    pd.subscribe("env");
    
    // add message receiver, required if you want to receieve messages
    pd.addReceiver(*this);   // automatically receives from all subscribed sources
    pd.ignoreSource(*this, "env");      // don't receive from "env"
    //pd.ignoreSource(*this);           // ignore all sources
    //pd.receiveSource(*this, "toOF");  // receive only from "toOF"
    
    // add midi receiver, required if you want to recieve midi messages
    pd.addMidiReceiver(*this);  // automatically receives from all channels
    //pd.ignoreMidiChannel(*this, 1);     // ignore midi channel 1
    //pd.ignoreMidiChannel(*this);        // ignore all channels
    //pd.receiveMidiChannel(*this, 1);    // receive only from channel 1
    
    // add the data/pd folder to the search path
    //pd.addToSearchPath("pd/abs");
    
    // audio processing on
    pd.start();
    pd.openPatch("YakShaveriOS2.pd");
    
    ofSeedRandom();

    for (int i=0;i<nControls; i++) {
        controlX[i] = controlX[i] * 64;
        controlY[i] = screenH - (controlY[i]+1)*64;
        controlImage[i].load(controlImageFilename[i]);
    }
    
    ofSetFrameRate(60);
    ofEnableAntiAliasing();
    
    //background.load("background" + std::to_string((int)ofRandom(1, 5)) + ".png");
    background.load("background2.png");
    colorwheel.load("colorWheel.png");
    
    // the world bounds
    bounds.set(0, 0, worldW, worldH);
    box2d.init();
    box2d.setFPS(60);
    box2d.setGravity(0, 0);
    box2d.createBounds(bounds);
    box2d.enableEvents();
    ofAddListener(box2d.contactStartEvents, this, &ofApp::contactStart);
    ofAddListener(box2d.contactEndEvents, this, &ofApp::contactEnd);

    box2d.registerGrabbing();
    
    vagRounded.load("vag.ttf", 18);
    
    newGame();

}

void ofApp::newGame() {
    int masterTempo =ofRandom(50, 2000)/200;
    
    //pd.sendFloat("masterTempoIn", masterTempo);
    // add some static bodies
 /*   int n= ofRandom(0, 5);
    for (int i=0; i < n; i++) {
        int w = ofRandom(20, 100);
        int x = ofRandom(10, worldW/2-w/2);
        int y = ofRandom(10, worldH/2-w/2);
       
        for (int j=0; j < 2; j++) {
            for (int k=0; k<2; k++) {
              ground.push_back(shared_ptr<FluxlyGround>(new FluxlyGround));
              FluxlyGround * g = ground.back().get();
              g->setPhysics(0, 0.5, 0);
              g->w = w;
              g->setup(box2d.getWorld(),worldW/2-(x-(worldW/2)*j), worldH/2-(y-(worldH/2)*k), g->w/2);
            }
        }
    }
    */
    int nBoxes;
    int nCircles;
        nCircles = 5;
        nBoxes = 0;
    // add some boxes to world
    for (int i=0; i < nBoxes; i++) {
    // for (int i=0; i < 8; i++) {
        boxen.push_back(shared_ptr<FluxlyBox>(new FluxlyBox));
        FluxlyBox * b = boxen.back().get();
        if (i<7) {  // guarantee one of each color
            b->type = i;
        } else {
            b->type = ofRandom(1,6);
        }
        float w = ofRandom(50 ,75);
        //float w = 16.0;
        b->setPhysics(1, .5, 1);    // density, bounce, friction
        b->setup(box2d.getWorld(), ofRandom(10, worldW-10), ofRandom(10, worldH-10), w, w);
        b->id = i;
        b->w = w;
        b->instrument = (i % 5)+2;
        BoxData * bd = new BoxData();
        bd->boxId = i;
        b->setRotation(ofRandom(0,360));
        b->body->SetUserData(bd);
        b->eyePeriod = ofRandom(200, 500);
        b->init();
    }
    // add some circles to world
    for (int i=0; i < nCircles; i++) {
        // for (int i=0; i < 8; i++) {
        circles.push_back(shared_ptr<FluxlyCircle>(new FluxlyCircle));
        FluxlyCircle * c = circles.back().get();
        if (i<7) {  // guarantee one of each color
            c->type = i;
        } else {
            c->type = ofRandom(1,6);
        }
        float w = ofRandom(50 ,100);  // should be multiple of 2 or power of 2?
        //float w = 16.0;
        c->setPhysics(1, .5, 1);    // density, bounce, friction
        c->setup(box2d.getWorld(), ofRandom(10, worldW-10), ofRandom(10, worldH-10), w/2);
        c->id = i;
        c->w = w;
        c->instrument = (i % 5)+2;
        BoxData * bd = new BoxData();
        bd->boxId = i;
        c->setRotation(ofRandom(0,360));
        c->body->SetUserData(bd);
        c->eyePeriod = ofRandom(200, 500);
        c->init();
    }
}

static bool shouldRemoveLightning(shared_ptr<ofxBox2dBaseShape>shape) {
    return true;
}

static bool shouldRemoveConnection(shared_ptr<FluxlyConnection>shape) {
    return true;
}

//--------------------------------------------------------------
void ofApp::update() {
    // since this is a test and we don't know if init() was called with
    // queued = true or not, we check it here
    if(pd.isQueued()) {
        // process any received messages, if you're using the queue and *do not*
        // call these, you won't receieve any messages or midi!
        pd.receiveMessages();
        pd.receiveMidi();
    }
    
    if (controlState[COLORWHEEL_CONTROL] == 2 ) {
        globalTick++;
        paused = true;
        showColorWheel = true;
    }
    
    if ((controlState[SHOW_JOINTS_CONTROL ] == 2) && !jointsShown) {
        for (int i=0; i<boxen.size(); i++) {
            ofLog(OF_LOG_VERBOSE, "Box %d joints: %d",i, boxen[i]->nJoints);
            jointsShown = true;
        }
    }
    
    if (!paused) {
        box2d.update();
        
        // Check for tick events
        globalTick++;
        /*
        for (int i=0; i<boxen.size(); i++) {
            if ((globalTick % boxen[i]->eyePeriod) == 0)  {
                if (boxen[i]->eyeState == 1) {
                    boxen[i]->eyeState = 0;
                } else {
                    boxen[i]->eyeState = 1;
                }
            }
        }
        for (int i=0; i<circles.size(); i++) {
            if ((globalTick % circles[i]->eyePeriod) == 0) {
                if (circles[i]->eyeState == 1)  {
                    circles[i]->eyeState = 0;
                } else {
                    circles[i]->eyeState = 1;
                }
            }
        }*/
        for (int i=0; i<boxen.size(); i++) {
            if (boxen[i]->spinning) {
                boxen[i]->eyeState = 1;
            } else {
                boxen[i]->eyeState = 0;
            }
        }
        for (int i=0; i<circles.size(); i++) {
            if (circles[i]->spinning) {
                circles[i]->eyeState = 1;
            } else {
                circles[i]->eyeState = 0;
            }
        }
        if (((globalTick % lightningPeriod) == 0) && (lightning.size() > 0)) {
            removeLightning();
        }
        
        if ((globalTick % lightningWait) == 0) {
            lightningAdded = false;
        }
        
        if (((globalTick % 60) == 0) && (teleportingId > 0)) {
            teleportingId = -1;
        }
        
        if (controlState[GRAVITY_UP_CONTROL] == 2 ) {
            if (gravityY > gravityYMin) gravityY--;
        } else {
            gravityY = origGravityY;
        }
        
        if (controlState[WIND_FROM_EAST_CONTROL] == 2) {
            //Wakeup?
            if (controlState[WIND_FROM_WEST_CONTROL] == 2) {
                if (gravityX < gravityXMax) gravityX++;
            }
            if (gravityX > gravityXMin) gravityX--;
        } else {
            if (controlState[WIND_FROM_WEST_CONTROL] == 2) {
                if (gravityX < gravityXMax) gravityX++;
            } else {
                gravityX = origGravityX;
            }
        }
        
        for (int i=0; i<clouds.size(); i++) {
            clouds[i].get()->setRotation(0);
            clouds[i].get()->setRotationFriction(1);
            clouds[i].get()->setDamping(0, 0);
            clouds[i].get()->pushUp();
        }
        
        for (int i=0; i<boxen.size(); i++) {
            boxen[i].get()->setRotationFriction(1);
            boxen[i].get()->setDamping(0, 0);
            boxen[i].get()->checkToSendNote();
            boxen[i].get()->checkToSendTempo();
            
            if (boxen[i].get()->sendTempo) {
                ofLog(OF_LOG_VERBOSE, "Changed masterTempo %d: %f", i, boxen[i]->tempo);
                pd.sendFloat("masterTempoIn", boxen[i]->tempo/4);
                boxen[i].get()->sendTempo = false;
            }
           /*
            if (boxen[i].get()->sendOn) {
                pd.sendFloat("toggle"+to_string(boxen[i].get()->instrument), 1.0);
                boxen[i].get()->sendOn = false;
            }
            if (boxen[i].get()->sendOff) {
                pd.sendFloat("toggle"+to_string(boxen[i].get()->instrument), 0.0);
                boxen[i].get()->sendOff = false;
            }
            pd.readArray("scope"+to_string(i % 6), boxen[i].get()->scopeArray);
            */
        }
        
        for (int i=0; i<circles.size(); i++) {
            circles[i].get()->setRotationFriction(1);
            circles[i].get()->setDamping(0, 0);
            circles[i].get()->checkToSendNote();
            circles[i].get()->checkToSendTempo();
            
            if (circles[i].get()->sendTempo) {
                ofLog(OF_LOG_VERBOSE, "Changed tempo %d: %f", i, circles[i]->tempo);
                pd.sendFloat("tempo"+to_string(circles[i].get()->instrument), circles[i]->tempo);
                circles[i].get()->sendTempo = false;
            }
            if (circles[i].get()->sendOn) {
                pd.sendFloat("toggle"+to_string(circles[i].get()->instrument), 1.0);
                circles[i].get()->sendOn = false;
            }
            if (circles[i].get()->sendOff) {
                pd.sendFloat("toggle"+to_string(circles[i].get()->instrument), 0.0);
                circles[i].get()->sendOff = false;
            }
            pd.readArray("scope"+to_string(circles[i].get()->instrument), circles[i].get()->scopeArray);
        }
        
       //box2d.setGravity(gravityX, gravityY);
        
       // if (connections.size() > 0) {
        if (false) {
            for (int i=0; i<connections.size(); i++) {
                //Go through list of connections and add joints
                ofLog(OF_LOG_VERBOSE, "List size: %d  id1: %d  id2: %d", connections.size(), connections[i]->id1, connections[i]->id2);
                
                tempId1 = connections[i]->id1;
                tempId2 = connections[i]->id2;
                
                if ((boxen[tempId1]->nJoints < maxJoints) && (boxen[tempId2]->nJoints < maxJoints)
                    && notConnectedYet(tempId1, tempId2) && complementaryColors(tempId1, tempId2)) {
                    
                    ofLog(OF_LOG_VERBOSE, "CONNECT: %d -> %d", tempId1, tempId2);
                    /*shared_ptr<ofxBox2dJoint> joint = shared_ptr<ofxBox2dJoint>(new ofxBox2dJoint);
                     joint.get()->setup(box2d[0].getWorld(), boxen[tempId1].get()->body, boxen[tempId2].get()->body);
                     joint.get()->setLength(1);
                     joints.push_back(joint);*/
                    
                    shared_ptr<FluxlyJointConnection> jc = shared_ptr<FluxlyJointConnection>(new FluxlyJointConnection);
                    ofxBox2dJoint *j = new ofxBox2dJoint;
                    j->setup(box2d.getWorld(), boxen[tempId1].get()->body, boxen[tempId2].get()->body);
                    j->setLength(1);
                    jc.get()->id1 = tempId1;
                    jc.get()->id2 = tempId2;
                    jc.get()->joint = j;
                    joints.push_back(jc);
                    
                    boxen[tempId1]->nJoints++;
                    boxen[tempId2]->nJoints++;
                }
            }
        }
        // Remove everything from connections vector
        //ofLog(OF_LOG_VERBOSE, "Connections: %d", connections.size());
        ofRemove(connections, shouldRemoveConnection);
        //ofLog(OF_LOG_VERBOSE, "Connections after remove: %d", connections.size());
        
       
    }
}

//--------------------------------------------------------------
void ofApp::draw() {
    ofBackground(0, 0, 0);
    ofSetHexColor(0xFFFFFF);
    ofSetRectMode(OF_RECTMODE_CORNER);
    background.draw(0, 0, worldW, worldH);
    ofSetHexColor(0xFFFFFF);
    /*
    for (int i=0;i < nControls; i++) {
        if (controlState[i] > 0) {
            ofPushMatrix();
            if (controlState[i] == 1) {
                ofSetHexColor(0xFFFFFF);
            } else {
                ofSetHexColor(0xFFFF00);
            }
            ofTranslate(controlX[i], controlY[i]);
            controlImage[i].draw(0, 0, controlW, controlH);
            ofPopMatrix();
        }
    }*/
    
    ofSetRectMode(OF_RECTMODE_CENTER);

    for (int i=0; i<ground.size(); i++) {
        ground[i].get()->draw();
    }
    
    /*for (int i=0; i<boxen.size(); i++) {
        boxen[i].get()->drawAnimation();
        
    }*/
    
    for (int i=0; i<circles.size(); i++) {
        circles[i].get()->drawAnimation();
    }
    /*for (int i=0; i<boxen.size(); i++) {
        boxen[i].get()->drawSoundWave();
    }*/
    for (int i=0; i<circles.size(); i++) {
        circles[i].get()->drawSoundWave();
    }
    for (int i=0; i<boxen.size(); i++) {
        boxen[i].get()->draw();
    }
    for (int i=0; i<circles.size(); i++) {
        circles[i].get()->draw();
    }
    
    for (int i=0; i<clouds.size(); i++) {
        clouds[i].get()->draw();
    }
    for (int i=0; i<lightning.size(); i++) {
        lightning[i].get()->draw();
    }
    if (controlState[SHOW_JOINTS_CONTROL] == 2) {
        for (int i=0; i<joints.size(); i++) {
          ofSetColor( ofColor::fromHex(0xff0000) );
          joints[i]->joint->draw();
        }
    }
    
    if (showColorWheel) {
        ofSetHexColor(0xFFFFFF);
        ofPushMatrix();
        
        ofTranslate(screenW/2, screenH/3);
        ofRotate(globalTick % 1080);
        colorwheel.draw(0, 0, screenW-20, screenW-20);
        ofPopMatrix();
    }
    
    //vagRounded.drawString(ofToString(ofGetFrameRate()), 10,20);
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    // add code to attach touch to button
   /* for (int i=0; i<nControls; i++) {
        if (inBounds(i, touch.x, touch.y)) {
            if (controlState[i]>0) controlState[i] = 2;
            startTouchId[i] = touch.id;
        }
    }*/
    
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
  /*  for (int i=0; i<nControls; i++) {
        if (!inBounds(i, touch.x, touch.y) && (startTouchId[i] == touch.id)) {
            if (controlState[i]>0) controlState[i] = 1;
            startTouchId[i] = 0;
        }
    }
   */
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
   /* for (int i=0; i<nControls; i++) {
        if (startTouchId[i] == touch.id) {
            if (controlState[i]>1) controlState[i] = 1;
            startTouchId[i] = 0;
    
            if (i == TELEPORT_CONTROL) {
                teleported = false;
            }
            if (i == SHOW_JOINTS_CONTROL) {
                jointsShown = false;
            }
            if (i == PAUSE_MORE_CONTROL) {
                paused = false;
            }
            if (i == COLORWHEEL_CONTROL) {
                paused = false;
                showColorWheel = false;
            }
        }
    }*/
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){

}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){

}

//--------------------------------------------------------------
void ofApp::gotFocus(){

}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){

}

void ofApp::contactStart(ofxBox2dContactArgs &e) {
    if(e.a != NULL && e.b != NULL) {
      
    }
}

//--------------------------------------------------------------
void ofApp::contactEnd(ofxBox2dContactArgs &e) {
    if(e.a != NULL && e.b != NULL) {
        b2Body *b1 = e.a->GetBody();
        BoxData *bd1 = (BoxData *)b1->GetUserData();
        if (bd1 !=NULL) {
            b2Body *b2 = e.b->GetBody();
            BoxData *bd2 = (BoxData *)b2->GetUserData();
            if (bd2 !=NULL) {
                if ((bd1->boxId != teleportingId) &&  (bd1->boxId != teleportingId)) {
                  // Add to list of connections to make in the update
                  connections.push_back(shared_ptr<FluxlyConnection>(new FluxlyConnection));
                  FluxlyConnection * c = connections.back().get();
                  c->id1 = bd1->boxId;
                  c->id2 = bd2->boxId;
                } else {
                    ofLog(OF_LOG_VERBOSE, "Ignoring %d", teleportingId);
                }
            }
        }
    }
}

Boolean ofApp::inBounds(int controlId, int x1, int y1) {
   // ofLog(OF_LOG_VERBOSE, "x %d, y %d, w %d, h %d, startx %d starty %d", x1, y1, controlX[controlId]+controlW+touchMargin,controlY[controlId]+controlH+touchMargin, controlX[controlId], controlY[controlId] );
    if ((x1 < (controlX[controlId]+controlW+touchMargin)) &&
        (x1 > (controlX[controlId]-touchMargin)) &&
        (y1 < (controlY[controlId]+controlH+touchMargin)) &&
        (y1 > (controlY[controlId]-touchMargin))) {
        return true;
    } else {
        return false;
    }
}

void ofApp::addCloud() {
    ofLog(OF_LOG_VERBOSE, "Add cloud!");
    clouds.push_back(shared_ptr<FluxlyCloud>(new FluxlyCloud));
    FluxlyCloud * c = clouds.back().get();
    c->setPhysics(1, 0, .3);
    c->setup(box2d.getWorld(), ofRandom(20, 300), ofRandom(10, 100), 32, 32);
}

void ofApp::addLightning() {
    ofLog(OF_LOG_VERBOSE, "Add lightning!");
    lightning.push_back(shared_ptr<FluxlyLightning>(new FluxlyLightning));
    FluxlyLightning * l = lightning.back().get();
    l->setPhysics(5, 0, .3);
    l->setRotationFriction(.99);
    l->setDamping(.99, .99);
    l->setup(box2d.getWorld(), ofRandom(20, 300), ofRandom(10, 100), 62, 649);
    lightningAdded = true;
}

void ofApp::removeLightning() {
    ofLog(OF_LOG_VERBOSE, "Remove lightning!");
    ofRemove(lightning, shouldRemoveLightning);
}

bool ofApp::notConnectedYet(int n1, int n2) {
    bool retVal = true;
   /* for (int i=0; i < boxen[n1]->nJoints; i++) {
        
        if (boxen[n1]->connections[i] == n2) {
           // ofLog(OF_LOG_VERBOSE, "Checking box %d connection list (length %d): %d == %d: Already connected",n1, boxen[n1]->nJoints, boxen[n1]->connections[i], n2);
            retVal =  false;
        } else {
            //ofLog(OF_LOG_VERBOSE, "Checking box %d connection list (length %d): %d == %d: Not yet connected",n1, boxen[n1]->nJoints, boxen[n1]->connections[i], n2);
        }
    }*/
    int myId1;
    int myId2;
    for (int i=0; i < joints.size(); i++) {
        myId1 = joints[i]->id1;
        myId2 = joints[i]->id2;
        if (((n1 == myId1) && (n2 == myId2)) || ((n2 == myId1) && (n1 == myId2))) {
          //  ofLog(OF_LOG_VERBOSE, "Checking box %d connection list (length %d): %d == %d, %d == %d: Already connected",
                //  n1, boxen[n1]->nJoints, n1, myId1, n1, myId2);
            retVal = false;
        } else {
           // ofLog(OF_LOG_VERBOSE, "Checking box %d connection list (length %d): %d == %d, %d == %d: Not Yet connected",
            //      n1, boxen[n1]->nJoints, n1, myId1, n1, myId2);
        }
    }
    return retVal;
}

bool ofApp::complementaryColors(int n1, int n2) {
    bool retVal = false;
    if ((abs(boxen[n1]->type - boxen[n2]->type) == 1) || ((n1 == 0) || (n2 == 0))) {
       // ofLog(OF_LOG_VERBOSE, "    CORRECT COLOR");
        retVal = true;
    } else {
       // ofLog(OF_LOG_VERBOSE, "    WRONG COLOR");
    }
    return retVal;
}


//--------------------------------------------------------------
void ofApp::audioReceived(float * input, int bufferSize, int nChannels) {
    pd.audioIn(input, bufferSize, nChannels);
}

//--------------------------------------------------------------
void ofApp::audioRequested(float * output, int bufferSize, int nChannels) {
    pd.audioOut(output, bufferSize, nChannels);
}

//--------------------------------------------------------------
// set the samplerate the Apple approved way since newer devices
// like the iPhone 6S only allow certain sample rates,
// the following code may not be needed once this functionality is
// incorporated into the ofxiOSSoundStream
// thanks to Seth aka cerupcat
float ofApp::setAVSessionSampleRate(float preferredSampleRate) {
    
    NSError *audioSessionError = nil;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    // disable active
    [session setActive:NO error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    
    // set category
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionDefaultToSpeaker error:&audioSessionError];
    if(audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    
    // try to set the preferred sample rate
    [session setPreferredSampleRate:preferredSampleRate error:&audioSessionError];
    if(audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    
    // *** Activate the audio session before asking for the "current" values ***
    [session setActive:YES error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@", (long)audioSessionError.code, audioSessionError.localizedDescription);
    }
    ofLogNotice() << "AVSession samplerate: " << session.sampleRate << ", I/O buffer duration: " << session.IOBufferDuration;
    
    // our actual samplerate, might be differnt aka 48k on iPhone 6S
    return session.sampleRate;
}


