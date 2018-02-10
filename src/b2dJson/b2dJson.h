/*
* Author: Chris Campbell - www.iforce2d.net
*
* This software is provided 'as-is', without any express or implied
* warranty.  In no event will the authors be held liable for any damages
* arising from the use of this software.
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
* 1. The origin of this software must not be misrepresented; you must not
* claim that you wrote the original software. If you use this software
* in a product, an acknowledgment in the product documentation would be
* appreciated but is not required.
* 2. Altered source versions must be plainly marked as such, and must not be
* misrepresented as being the original software.
* 3. This notice may not be removed or altered from any source distribution.
*/

#ifndef B2DJSON_H
#define B2DJSON_H

#include <stdio.h>
#include <map>
#include <string>
#include <Box2D/Box2D.h>
#include "json/json.h"

class b2dJsonImage;
class EditorDocument;

class b2dJson
{
protected:
    bool m_useHumanReadableFloats;
    std::map<int,b2Body*> m_indexToBodyMap;
    std::map<b2Body*,int> m_bodyToIndexMap;
    std::map<b2Joint*,int> m_jointToIndexMap;
    std::vector<b2Body*> m_bodies;
    std::vector<b2Joint*> m_joints;
    std::vector<b2dJsonImage*> m_images;

    std::map<b2Body*,std::string> m_bodyToNameMap;
    std::map<b2Fixture*,std::string> m_fixtureToNameMap;
    std::map<b2Joint*,std::string> m_jointToNameMap;
    std::map<b2dJsonImage*,std::string> m_imageToNameMap;

public:
    //constructor
    b2dJson(bool useHumanReadableFloats = false);
    ~b2dJson();

    void clear();

    //writing functions
    Json::Value writeToValue(b2World* world);
    std::string writeToString(b2World* world);
    bool writeToFile(b2World* world, const char* filename);

    Json::Value b2j(b2World* world);
    Json::Value b2j(b2Body* body);
    Json::Value b2j(b2Fixture* fixture);
    Json::Value b2j(b2Joint* joint);
    Json::Value b2j(b2dJsonImage* image);

    void setBodyName(b2Body* body, const char* name);
    void setFixtureName(b2Fixture* fixture, const char* name);
    void setJointName(b2Joint* joint, const char* name);
    void setImageName(b2dJsonImage* image, const char* name);

    void addImage(b2dJsonImage* image);

    //reading functions
    b2World* readFromValue(Json::Value worldValue);
    b2World* readFromString(std::string str, std::string& errorMsg);
    b2World* readFromFile(const char* filename, std::string& errorMsg);

    b2World* j2b2World(Json::Value worldValue);
    b2Body* j2b2Body(b2World* world, Json::Value bodyValue);
    b2Fixture* j2b2Fixture(b2Body* body, Json::Value fixtureValue);
    b2Joint* j2b2Joint(b2World* world, Json::Value jointValue);
    b2dJsonImage* j2b2dJsonImage(Json::Value imageValue);

    int getBodiesByName(std::string name, std::vector<b2Body*>& bodies);
    int getFixturesByName(std::string name, std::vector<b2Fixture*>& fixtures);
    int getJointsByName(std::string name, std::vector<b2Joint*>& joints);
    int getImagesByName(std::string name, std::vector<b2dJsonImage*>& images);

    int getAllImages(std::vector<b2dJsonImage*>& images);

    b2Body* getBodyByName(std::string name);
    b2Fixture* getFixtureByName(std::string name);
    b2Joint* getJointByName(std::string name);
    b2dJsonImage* getImageByName(std::string name);

    std::map<b2Joint*,std::string> getJointToNameMap() const { return m_jointToNameMap; }
    std::map<b2Fixture*,std::string> getFixtureToNameMap() const { return m_fixtureToNameMap; }

    std::string getBodyName(b2Body* body);
    std::string getFixtureName(b2Fixture* fixture);
    std::string getJointName(b2Joint* joint);
    std::string getImageName(b2dJsonImage* img);

protected:
    //member helpers
    void vecToJson(const char* name, unsigned int v, Json::Value& value, int index = -1);
    void vecToJson(const char* name, float v, Json::Value& value, int index = -1);
    void vecToJson(const char* name, b2Vec2 vec, Json::Value& value, int index = -1);
    void floatToJson(const char* name, float f, Json::Value& value);
    b2Body* lookupBodyFromIndex( unsigned int index );
    int lookupBodyIndex( b2Body* body );
    int lookupJointIndex( b2Joint* joint );

    //static helpers
    static std::string floatToHex(float f);
    static float hexToFloat(std::string str);
    static float jsonToFloat(const char* name, Json::Value& value, int index = -1, float defaultValue = 0);
    static b2Vec2 jsonToVec(const char* name, Json::Value& value, int index = -1, b2Vec2 defaultValue = b2Vec2(0,0));
};

#endif // B2DJSON_H







