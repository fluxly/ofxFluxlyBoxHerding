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

#ifndef VEHICLES_DEMO_H
#define VEHICLES_DEMO_H


//This demo shows how to load a Box2D world from a JSON file
//and access named joints in the file to manipulate later.
//
//All the joints in the scene labelled 'drivejoint' are put into 
//a vector so they can be controlled by user input. The file to
//load the scene from along with the speed that the drive joints 
//should rotate at is given to the class constructor. 

#include <vector>
#include <string>
#include <Box2D/Box2D.h>
#include "GLES1DebugDraw.h"
#include "b2dJsonImage_OpenGL.h"

struct DemoParameters {
	std::string m_filename;
	float m_driveJointSpeed;
	bool m_doDebugDraw;
	DemoParameters( std::string fn, float ds, bool ddd ) : m_filename(fn), m_driveJointSpeed(ds), m_doDebugDraw(ddd) {}
};

class LoadRUBEDemo
{
public:
	enum _buttonId {
		b_left = 	0x01,
		b_right = 	0x02
	};
	
	LoadRUBEDemo(DemoParameters params);	
	void ButtonDown(_buttonId buttonId);	
	void ButtonUp(_buttonId buttonId);
	void Step();
	void Render(float zoom);
	b2Vec2 GetCurrentVehicleLocation();
	
protected:	
	//main stuff
	b2World* m_world;
	GLES1DebugDraw m_debugDraw;
	
	//control state
	int m_buttonState;

	//drive joint info
	std::vector<b2Joint*> m_driveJoints;
	float m_driveSpeed;
	
	//current location, used to move the view smoothly instead of
	//rigidly sticking to the current vehicles location
	b2Vec2 m_currentViewCenter;
	
	//images loaded from scene file
	std::vector<b2dJsonImage_OpenGL*> m_images;
	bool m_doDebugDraw;
};

#endif
