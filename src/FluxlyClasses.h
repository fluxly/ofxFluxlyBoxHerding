//
//  FluxlyClasses.h
//  Fluxly
//
//  Created by as220 on 11/14/17.
//

#ifndef customClasses_h
#define customClasses_h

//--------------------------------------------

class FluxlyPlayer : public ofxBox2dRect {
public:
    ofImage playerImage;
    
    FluxlyPlayer() {
        playerImage.load("fluxum1.png");
    }

    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        ofSetHexColor(0xFFFFFF);
        playerImage.draw(0, 0, 64, 64 );
        ofPopMatrix();
    }
    void jump() {
        if ((getVelocity().y > -1)) {
            addImpulseForce(ofxBox2dBaseShape::getPosition(),  ofVec2f(0, -7.0));
        }
    }
    void moveX(float x) {
        ofxBox2dBaseShape::setVelocity(x, ofxBox2dBaseShape::getVelocity().y);
    }
    void standUp() {
        
    }
};

//--------------------------------------------

class FluxlyBox : public ofxBox2dRect {
public:
    FluxlyBox() {
    }
    
    ofColor color;
    /* Color type:
     1: ff0000  or  f62394
     2: 8b20bb  or  0024ba
     3: 007ac7  or  00b3d4
     4: 01b700  or  83ce01
     5: fffa00  or  ffcf00
     6: ffa600  or  ff7d01
    */
    
    int id;
    int w;
    int eyeState = 0;
    int eyePeriod = 100;
    int type;
    int origType;
    int nJoints = 0;
    int connections[4];
    ofTrueTypeFont vag;
    
    b2BodyDef * def;
    
    ofImage myEyesOpen;
    ofImage myEyesClosed;
    ofImage grayOverlay;
    
    void init() {
        myEyesOpen.load("eyesOpen.png");
        myEyesClosed.load("eyesClosed.png");
       // grayOverlay.load("grayOverlay.png");
        vag.load("vag.ttf", 9);
      
        origType = type;
        
        switch (type) {
            case 0:
                color = ofColor::fromHex(0xffffff);
                break;
            case 1:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0xff0000);
                } else {
                    color = ofColor::fromHex(0xf62394);
                }
                break;
            case 2:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0x8b20bb);
                } else {
                    color = ofColor::fromHex(0x0024ba);
                }
                break;
            case 3:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0x007ac7);
                } else {
                    color = ofColor::fromHex(0x00b3d4);
                }
                break;
            case 4:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0x01b700);
                } else {
                    color = ofColor::fromHex(0x83ce01);
                }
                break;
            case 5:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0xfffa00);
                } else {
                    color = ofColor::fromHex(0xffcf00);
                }
                break;
            case 6:
                if (ofRandom(10)>5) {
                    color = ofColor::fromHex(0xffa600);
                } else {
                    color = ofColor::fromHex(0xff7d01);
                }
                break;
        }
    }
    
    void shake() {
        ofLog(OF_LOG_VERBOSE, "shake");
        addImpulseForce(ofxBox2dBaseShape::getPosition(),  ofVec2f(ofRandom(.02, .06), ofRandom(.02, .06)));
    }
    
    void teleport() {
        ofLog(OF_LOG_VERBOSE, "teleport %d", id);
        
        setPosition(ofRandom(20, 250), ofRandom(20, 350));
    }
    
    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofSetColor(color.r, color.g, color.b);
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        mesh.draw();
       /* if (nJoints == 3) {
            ofSetHexColor(0xffffff);
            grayOverlay.draw(0, 0, w, w);
        }*/
        
        ofSetHexColor(0xFFFFFF);
        if (nJoints > 2) {
            if (eyeState == 0) {
                //ofLog(OF_LOG_VERBOSE, "closed");
                myEyesClosed.draw(0, 0, w, w);
            } else {
                myEyesOpen.draw(0, 0, w, w);
            }
        }
       // ofSetHexColor(0x000000);
       // vag.drawString(std::to_string(id), -5,-5);
        ofPopMatrix();
        
    }
};

//--------------------------------------------

class FluxlyCircle : public ofxBox2dCircle {
public:
    FluxlyCircle() {
    }
    
    ofColor color;
    
    void draw() {
        if(!isBody()) return;
        ofPushMatrix();
        ofSetColor(color.r, color.g, color.b);
        ofTranslate(ofxBox2dBaseShape::getPosition());
        //ofRotate(getRotation(), 0, 0, 1);
        ofDrawCircle(0, 0, getRadius());
        ofPopMatrix();
    }
};

//--------------------------------------------

class FluxlyCloud : public ofxBox2dRect {
public:
    ofImage playerImage;
    
    FluxlyCloud() {
        playerImage.load("cloud.png");
    }
    void pushUp() {
    
    }
    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        ofSetHexColor(0xFFFFFF);
        playerImage.draw(0, 0, 62, 42 );
        ofPopMatrix();
    }
};

class FluxlyLightning : public ofxBox2dRect {
public:
    ofImage lightningImage;
    
    FluxlyLightning() {
        lightningImage.load("lightning.png");
    }
    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        ofSetHexColor(0xFFFFFF);
        lightningImage.draw(0, 0, 62, 649 );
        ofPopMatrix();
    }
};

#endif /* customClasses_h */
