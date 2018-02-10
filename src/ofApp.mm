#include "ofApp.h"


//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetLogLevel(OF_LOG_VERBOSE);
    ofSeedRandom();
    
    if (nWorlds == 1)  worldY[0] += 190;
    for (int i=0;i<nControls; i++) {
        controlX[i] = controlX[i] * 64;
        controlY[i] = screenH - (controlY[i]+1)*64;
        controlImage[i].load(controlImageFilename[i]);
    }
    
    ofSetFrameRate(60);
    ofEnableAntiAliasing();
    
    for (int i=0; i<nWorlds; i++) {
        //background[i].load("background" + std::to_string((int)ofRandom(1, 5)) + ".png");
        background[i].load("background2.png");
        foreground[i].load("foreground2.png");
        // the world bounds
        bounds[i].set(0, 0, worldW, worldH);
        box2d[i].init();
        box2d[i].setFPS(60);
        box2d[i].setGravity(gravityX, gravityY);
        box2d[i].createBounds(bounds[0]);
        box2d[i].enableEvents();
        ofAddListener(box2d[i].contactStartEvents, this, &ofApp::contactStart);
        ofAddListener(box2d[i].contactEndEvents, this, &ofApp::contactEnd);
    }
    
    // add some boxes to world
    for (int i=0; i < 50; i++) {
        boxen.push_back(shared_ptr<FluxlyBox>(new FluxlyBox));
        FluxlyBox * b = boxen.back().get();
        if (i<7) {
            b->type = i;
        } else {
            b->type = ofRandom(1,6);
        }
        float w = ofRandom(5,10)*2;  // should be multiple of 2 or power of 2?
        //float w = 16.0;
        b->setPhysics(1, 0.5, 1);
        b->setup(box2d[0].getWorld(), ofRandom(10, worldW-10), ofRandom(10, worldH-10), w, w);
        b->id = i;
        b->w = w;
        BoxData * bd = new BoxData();
        bd->boxId = i;
        b->body->SetUserData(bd);
        b->eyePeriod = ofRandom(200, 500);
        b->init();
    }
    
   /* for (int i=1; i<boxen.size(); i++) {
        if (ofRandom(0,100)<60) {
        shared_ptr<ofxBox2dJoint> joint = shared_ptr<ofxBox2dJoint>(new ofxBox2dJoint);
        joint.get()->setup(box2d[0].getWorld(), boxen[i-1].get()->body, boxen[i].get()->body);
        joint.get()->setLength(1);
        joints.push_back(joint);
        }
    }*/
    
    vagRounded.load("vag.ttf", 18);
}

static bool shouldRemoveLightning(shared_ptr<ofxBox2dBaseShape>shape) {
    return true;
}

static bool shouldRemoveConnection(shared_ptr<FluxlyConnection>shape) {
    return true;
}

//--------------------------------------------------------------
void ofApp::update(){
    // Check for tick events
    globalTick++;
    for (int i=0; i<boxen.size(); i++) {
        if ((globalTick % boxen[i]->eyePeriod) == 0) {
            if (boxen[i]->eyeState == 1) {
                boxen[i]->eyeState = 0;
            } else {
                boxen[i]->eyeState = 1;
            }
        }
    }
    if (((globalTick % lightningPeriod) == 0) && (lightning.size() > 0)) {
        removeLightning();
    }

    if ((globalTick % lightningWait) == 0) {
        lightningAdded = false;
    }
    
    if (controlState[GRAVITY_UP_CONTROL] == 2 ) {
        //Wakeup?
        if (controlState[MORE_GRAVITY_CONTROL] == 2) {
            if (gravityY < gravityYMax) gravityY++;
        }
        if (gravityY > gravityYMin) gravityY--;
    } else {
        if (controlState[MORE_GRAVITY_CONTROL] == 2) {
            if (gravityY < gravityYMax) gravityY++;
        } else {
            gravityY = origGravityY;
        }
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
        clouds[i].get()->setRotationFriction(.99);      // NOT WORKING?
        clouds[i].get()->setDamping(.99, .99);         // NOT WORKING
    }
    
    if (controlState[CLOUD_CONTROL] == 2 ) {
        addCloud();
    }
    if ((controlState[LIGHTNING_CONTROL] == 2 ) && !lightningAdded) {
        addLightning();
    }
    
    if ((controlState[TELEPORT_CONTROL] == 2 ) && !teleported) {
        int r = ofRandom(0, boxen.size());
        for (int i=0; i<joints.size(); i++) {
            if ((connections[i]->id1 == r) || (connections[i]->id2 == r)) {
                
                // NEED TO DESTROY THE JOINT
                
                //joints.erase( joints.begin() + connections[i]->jointId] );
                //connections.erase( connections.begin() + i );
                boxen[r]->nJoints--;
                ofLog(OF_LOG_VERBOSE, "Removed joint count: %d",boxen[r]->nJoints);
            }
        }
        boxen[r]->teleport();
        teleported = true;
    }
    
    if ((controlState[EARTHQUAKE_CONTROL] == 2) && !earthquakeApplied) {
        for (int i=0; i<boxen.size(); i++) {
            ofLog(OF_LOG_VERBOSE, "shake %d", i);
            boxen[i].get()->shake();
            earthquakeApplied = true;
        }
    }
        
    box2d[0].setGravity(gravityX, gravityY);
    //box2d[1].setGravity(gravityX, gravityY);
    //eventString = ofToString(gravityY);
    
    if (connections.size()>0) {
    for (int i=0; i<connections.size(); i++) {
        //Go through list of connections and add joints
        //ofLog(OF_LOG_VERBOSE, "id1: %d  id2: %d", connections[i]->id1, connections[i]->id2);
        tempId1 = connections[i]->id1;
        tempId2 = connections[i]->id2;
        
        if ((boxen[tempId1]->nJoints < maxJoints) && (boxen[tempId2]->nJoints < maxJoints)
            && notConnectedYet(tempId1, tempId2) && complementaryColors(tempId1, tempId2)){
          
            shared_ptr<ofxBox2dJoint> joint = shared_ptr<ofxBox2dJoint>(new ofxBox2dJoint);
            joint.get()->setup(box2d[0].getWorld(), boxen[tempId1].get()->body, boxen[tempId2].get()->body);
            joint.get()->setLength(1);
            joints.push_back(joint);
            boxen[tempId1]->connections[boxen[tempId1]->nJoints] = tempId2;
            boxen[tempId2]->connections[boxen[tempId1]->nJoints] = tempId1;
            boxen[tempId1]->nJoints++;
            boxen[tempId2]->nJoints++;
        }
     }
      // Remove everything from connections vector
      //ofLog(OF_LOG_VERBOSE, "Connections: %d", connections.size());
      ofRemove(connections, shouldRemoveConnection);
      //ofLog(OF_LOG_VERBOSE, "Connections after remove: %d", connections.size());
    }
    
    box2d[0].update();
    //box2d[1].update();
}

//--------------------------------------------------------------
void ofApp::draw(){
    ofBackground(0, 0, 0);
    ofSetHexColor(0xFFFFFF);
    ofSetRectMode(OF_RECTMODE_CORNER);
    background[0].draw(0, 0, worldW, worldH);
    //foreground[0].draw(ofRandom(worldW), ofRandom(worldH), ofRandom(worldW/2), ofRandom(worldH/2));
        ofSetHexColor(0xFFFFFF);
    
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
    }
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    for (int i=0; i<boxen.size(); i++) {
        boxen[i].get()->draw();
    }
    
    for (int i=0; i<clouds.size(); i++) {
        clouds[i].get()->draw();
    }
    for (int i=0; i<lightning.size(); i++) {
        lightning[i].get()->draw();
    }
    
    vagRounded.drawString(ofToString(ofGetFrameRate()), 10,20);
}

//--------------------------------------------------------------
void ofApp::exit(){

}

//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    // add code to attach touch to button
    for (int i=0; i<nControls; i++) {
        if (inBounds(i, touch.x, touch.y)) {
            if (controlState[i]>0) controlState[i] = 2;
            startTouchId[i] = touch.id;
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    for (int i=0; i<nControls; i++) {
        if (!inBounds(i, touch.x, touch.y) && (startTouchId[i] == touch.id)) {
            if (controlState[i]>0) controlState[i] = 1;
            startTouchId[i] = 0;
        }
    }
}

//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    for (int i=0; i<nControls; i++) {
        if (startTouchId[i] == touch.id) {
            if (controlState[i]>1) controlState[i] = 1;
            startTouchId[i] = 0;
            if (i == EARTHQUAKE_CONTROL) {
                earthquakeApplied = false;
            }
            if (i == TELEPORT_CONTROL) {
                teleported = false;
            }
        }
    }
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
                // Add to list of connections to make in the update
                connections.push_back(shared_ptr<FluxlyConnection>(new FluxlyConnection));
                FluxlyConnection * c = connections.back().get();
                c->id1 = bd1->boxId;
                c->id2 = bd2->boxId;
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
    c->setup(box2d[0].getWorld(), ofRandom(20, 300), ofRandom(10, 100), 32, 32);
}

void ofApp::addLightning() {
    ofLog(OF_LOG_VERBOSE, "Add lightning!");
    lightning.push_back(shared_ptr<FluxlyLightning>(new FluxlyLightning));
    FluxlyLightning * l = lightning.back().get();
    l->setPhysics(5, 0, .3);
    l->setRotationFriction(.99);
    l->setDamping(.99, .99);
    l->setup(box2d[0].getWorld(), ofRandom(20, 300), ofRandom(10, 100), 62, 649);
    lightningAdded = true;
}

void ofApp::removeLightning() {
    ofLog(OF_LOG_VERBOSE, "Remove lightning!");
    ofRemove(lightning, shouldRemoveLightning);
}

bool ofApp::notConnectedYet(int n1, int n2) {
    bool retVal = true;
    for (int i=0; i < boxen[n1]->nJoints; i++) {
        if (boxen[n1]->connections[i] == n2) retVal =  false;
    }
    return retVal;
}

bool ofApp::complementaryColors(int n1, int n2) {
    bool retVal = false;
    if ((abs(boxen[n1]->type - boxen[n2]->type) == 1) || ((n1 == 0) || (n2 == 0))) retVal = true;
    return retVal;
}

