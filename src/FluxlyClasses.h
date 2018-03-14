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
    int count = 0;
    int stroke = 1;
    int prevState =0;
    bool sendOn = false;
    bool sendOff = false;
    bool sendTempo = false;
    bool spinning = false;
    
    float prevTempo = 0;
    float tempo = 0;
    
    int instrument;
    
    vector<float> scopeArray;
    
    ofTrueTypeFont vag;
    
    b2BodyDef * def;
    
    ofImage myEyesOpen;
    ofImage myEyesClosed;
    ofImage grayOverlay;
    ofImage spriteImg;
    
    void init() {

        myEyesOpen.load("eyesOpen.png");
        myEyesClosed.load("eyesClosed.png");
       // grayOverlay.load("grayOverlay.png");
        vag.load("vag.ttf", 9);
      
        origType = type;
        
        switch (type) {
            case 0:
                spriteImg.load("meshBox1.png");
                color = ofColor::fromHex(0xffffff);
                break;
            case 1:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox2.png");
                    color = ofColor::fromHex(0xff0000);
                } else {
                    spriteImg.load("meshBox2.png");
                    color = ofColor::fromHex(0xf62394);
                }
                break;
            case 2:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox3.png");
                    color = ofColor::fromHex(0x8b20bb);
                } else {
                    spriteImg.load("meshBox3.png");
                    color = ofColor::fromHex(0x0024ba);
                }
                break;
            case 3:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox4.png");
                    color = ofColor::fromHex(0x007ac7);
                } else {
                    spriteImg.load("meshBox4.png");
                    color = ofColor::fromHex(0x00b3d4);
                }
                break;
            case 4:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox5.png");
                    color = ofColor::fromHex(0x01b700);
                } else {
                    spriteImg.load("meshBox5.png");
                    color = ofColor::fromHex(0x83ce01);
                }
                break;
            case 5:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox6.png");
                    color = ofColor::fromHex(0xfffa00);
                } else {
                    spriteImg.load("meshBox6.png");
                    color = ofColor::fromHex(0xffcf00);
                }
                break;
            case 6:
                if (ofRandom(10)>5) {
                    spriteImg.load("meshBox6.png");
                    color = ofColor::fromHex(0xffa600);
                } else {
                    spriteImg.load("meshBox6.png");
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
    
    void drawAnimation() {
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        if (eyeState == 1) {
            if (count<100) count++;
            ofNoFill();
            ofSetColor(color);
            ofSetLineWidth(stroke);
            if (type<=6) {
                for (int i=0; i < count; i++) {
                    ofDrawRectangle(0, 0, w*2+i*12, w*2+i*12);
                }
            }
            ofFill();
        } else {
            count = 0;
        }
        
        ofPopMatrix();
    }
    
    void drawSoundWave() {
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        if (eyeState == 1) {
            float w = 500 / (float) scopeArray.size(), h = 100;
            float x = -500;
            ofSetColor(ofColor::fromHex(0x333333));
            for(int j = 0; j < scopeArray.size()-1; j++) {
                ofDrawLine(x,scopeArray[j]*h, x+w,scopeArray[j+1]*h);
                ofDrawLine(x+500,scopeArray[j]*h, x+500+w,scopeArray[j+1]*h);
                x += w;
            }
            ofFill();
        } else {
            count = 0;
        }
        ofPopMatrix();
    }
    
    void checkToSendNote() {
        if ((eyeState == 1) && (prevState == 0)) {
            sendOn = true;
            prevState = 1;
        }
        if ((eyeState == 0) && (prevState == 1 )) {
            sendOff = true;
            prevState = 0;
        }
    }
    
    void checkToSendTempo() {
         tempo = (body->GetAngularVelocity()/24)*8;
        if (tempo != prevTempo) {
            sendTempo = true;
        } else {
            sendTempo = false;
        }
        prevTempo = tempo;
        if (abs(tempo) > 0.015) {
            spinning = true;
        } else {
            spinning = false;
        }
    }
    
    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofSetColor(color.r, color.g, color.b);
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        
        spriteImg.draw(0, 0, w, w);
        
       /* if (nJoints == 3) {
            ofSetHexColor(0xffffff);
            grayOverlay.draw(0, 0, w, w);
        }*/
        
        ofSetHexColor(0xFFFFFF);
        if (eyeState == 0) {
                //ofLog(OF_LOG_VERBOSE, "closed");
                myEyesClosed.draw(0, 0, w/2, w/2);
            } else {
                myEyesOpen.draw(0, 0, w/2, w/2);
            }
       // ofSetHexColor(0x000000);
        //vag.drawString(std::to_string(nJoints), -5,-5);
        ofPopMatrix();
    }
};


class FluxlyGround : public ofxBox2dCircle {
public:
    ofImage foregroundImg;
    int w;
    int h;
    
    FluxlyGround() {
        foregroundImg.load("foreground2.png");
    }
    
        void draw() {
        if(!isBody()) return;
        ofPushMatrix();
        ofSetHexColor(0xFFFFFF);
        ofTranslate(ofxBox2dBaseShape::getPosition());
        foregroundImg.draw(0, 0, w, w);
        ofPopMatrix();
    }
};


//--------------------------------------------

class FluxlyCircle : public ofxBox2dCircle {
public:
    FluxlyCircle() {
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
    int count = 0;
    int stroke = 1;
    int prevState =0;
    bool sendOn = false;
    bool sendOff = false;
    bool sendTempo = false;
    bool spinning = false;
    
    float prevTempo = 0;
    float tempo = 0;
    int instrument;
    
    vector<float> scopeArray;
    
    ofTrueTypeFont vag;
    
    b2BodyDef * def;
    
    ofImage myEyesOpen;
    ofImage myEyesClosed;
    ofImage grayOverlay;
    ofImage spriteImg;
    
    void init() {
        
        myEyesOpen.load("eyesOpen.png");
        myEyesClosed.load("eyesClosed.png");
        // grayOverlay.load("grayOverlay.png");
        vag.load("vag.ttf", 9);
        
        origType = type;
        
        switch (type) {
            case 0:
                spriteImg.load("mesh1.png");
                color = ofColor::fromHex(0xffffff);
                break;
            case 1:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh2.png");
                    color = ofColor::fromHex(0xff0000);
                } else {
                    spriteImg.load("mesh2.png");
                    color = ofColor::fromHex(0xf62394);
                }
                break;
            case 2:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh3.png");
                    color = ofColor::fromHex(0x8b20bb);
                } else {
                    spriteImg.load("mesh3.png");
                    color = ofColor::fromHex(0x0024ba);
                }
                break;
            case 3:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh4.png");
                    color = ofColor::fromHex(0x007ac7);
                } else {
                    spriteImg.load("mesh4.png");
                    color = ofColor::fromHex(0x00b3d4);
                }
                break;
            case 4:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh5.png");
                    color = ofColor::fromHex(0x01b700);
                } else {
                    spriteImg.load("mesh5.png");
                    color = ofColor::fromHex(0x83ce01);
                }
                break;
            case 5:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh6.png");
                    color = ofColor::fromHex(0xfffa00);
                } else {
                    spriteImg.load("mesh6.png");
                    color = ofColor::fromHex(0xffcf00);
                }
                break;
            case 6:
                if (ofRandom(10)>5) {
                    spriteImg.load("mesh6.png");
                    color = ofColor::fromHex(0xffa600);
                } else {
                    spriteImg.load("mesh6.png");
                    color = ofColor::fromHex(0xff7d01);
                }
                break;
        }
    }
    
    void checkToSendTempo() {
        tempo = (body->GetAngularVelocity()/24)*8;
        if (tempo != prevTempo) {
            sendTempo = true;
        } else {
            sendTempo = false;
        }
        prevTempo = tempo;
        if (abs(tempo) > 0.015) {
            spinning = true;
        } else {
            spinning = false;
        }
    }
    
    void drawAnimation() {
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        if (eyeState == 1) {
            if (count<100) count++;
            ofNoFill();
            ofSetColor(color);
            ofSetLineWidth(stroke);
            if (type<=6) {
                for (int i=0; i < count; i++) {
                    ofDrawCircle(0, 0, w+i*6);
                }
            }
            if (false) {
                for (int i=0; i < 5; i++) {
                    ofDrawLine(-count*3, -i*6, count*3, -i*6);
                    ofDrawLine(-count*3, i*6, count*3, i*6);
                    ofDrawLine(-i*6, -count*3, -i*6, count*3);
                    ofDrawLine(i*6, -count*3, i*6, count*3);
                }
            }
            ofFill();
        } else {
            count = 0;
        }
        
        ofPopMatrix();
    }
    
    void drawSoundWave() {
        ofPushMatrix();
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        if (eyeState == 1) {
            float w = 500 / (float) scopeArray.size(), h = 100;
            float x = -500;
            ofSetColor(ofColor::fromHex(0x333333));
            for(int j = 0; j < scopeArray.size()-1; j++) {
                ofDrawLine(x,scopeArray[j]*h, x+w,scopeArray[j+1]*h);
                ofDrawLine(x+500,scopeArray[j]*h, x+500+w,scopeArray[j+1]*h);
                x += w;
            }
            ofFill();
        } else {
            count = 0;
        }
        ofPopMatrix();
    }
    
    void checkToSendNote() {
        if ((eyeState == 1) && (prevState == 0)) {
            sendOn = true;
            prevState = 1;
        }
        if ((eyeState == 0) && (prevState == 1 )) {
            sendOff = true;
            prevState = 0;
        }
        
    }
    
    void draw() {
        if(body == NULL) {
            return;
        }
        ofPushMatrix();
        ofSetColor(color.r, color.g, color.b);
        ofTranslate(ofxBox2dBaseShape::getPosition());
        ofRotate(getRotation(), 0, 0, 1);
        
        spriteImg.draw(0, 0, w, w);
        
        /* if (nJoints == 3) {
         ofSetHexColor(0xffffff);
         grayOverlay.draw(0, 0, w, w);
         }*/
        
        ofSetHexColor(0xFFFFFF);
        if (eyeState == 0) {
            //ofLog(OF_LOG_VERBOSE, "closed");
            myEyesClosed.draw(0, 0, w/2, w/2);
        } else {
            myEyesOpen.draw(0, 0, w/2, w/2);
        }
        // ofSetHexColor(0x000000);
        //vag.drawString(std::to_string(nJoints), -5,-5);
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
