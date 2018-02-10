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


#include <vector>
#import <OpenGLES/ES1/gl.h>
#include "b2dJson/b2dJson.h"
#include "LoadRUBEDemo.h"
#include "b2dJsonImage_OpenGL.h"

using namespace std;

//This demo shows how to load a Box2D world from a JSON file
//and access named joints in the file to manipulate later.
//
//All the joints in the scene labelled 'drivejoint' are put into 
//a vector so they can be controlled by user input. The file to
//load the scene from along with the speed that the drive joints 
//should rotate at is given to the class constructor.

LoadRUBEDemo::LoadRUBEDemo(DemoParameters params)
{			
	//load world from JSON file
	b2dJson json;
	std::string errorMsg;
	m_world = json.readFromFile(params.m_filename.c_str(), errorMsg);
	if ( m_world ) {
		m_debugDraw.SetFlags(b2Draw::e_shapeBit);
		m_world->SetDebugDraw( &m_debugDraw );
		
		//get named drive joints from the JSON info
		json.getJointsByName("drivejoint", m_driveJoints);
		
		//load images
		vector<b2dJsonImage*> images;
		json.getAllImages(images);
		for (int i = 0; i < (int)images.size(); i++) {
			b2dJsonImage_OpenGL* img = new b2dJsonImage_OpenGL( images[i] );
			m_images.push_back( img );
		}
	}
	
	m_driveSpeed = params.m_driveJointSpeed;
	m_doDebugDraw = params.m_doDebugDraw;
	
	//set up initial state
	m_buttonState = 0;
	m_currentViewCenter = GetCurrentVehicleLocation();
}

void LoadRUBEDemo::ButtonDown(_buttonId buttonId)
{
	switch (buttonId)
	{
		case b_left: m_buttonState |= b_left; break;
		case b_right: m_buttonState |= b_right; break;
	}
}

void LoadRUBEDemo::ButtonUp(_buttonId buttonId)
{
	switch (buttonId)
	{
		case b_left: m_buttonState &= ~b_left; break;
		case b_right: m_buttonState &= ~b_right; break;
	}
}

void LoadRUBEDemo::Step()
{
	if ( ! m_world )
		return;
	
	m_world->Step(1/60.0f, 10, 10);
	
	//set motor speeds for current vehicle
	float32 motorSpeed = m_buttonState == b_left ? 1 : m_buttonState == b_right ? -1 : 0;
	motorSpeed *= m_driveSpeed;
	/*switch ( m_vehicle )
	{
		case e_bike : motorSpeed *= 30; break;
		case e_car : motorSpeed *= 30; break;
		case e_truck : motorSpeed *= 15; break;
		case e_tank : motorSpeed *= 10; break;
		case e_walker : motorSpeed *= -3; break;
	}*/
	for (int i = 0; i < m_driveJoints.size(); i++) {
		b2Joint* joint = m_driveJoints[i];
		b2JointType type = joint->GetType();
		switch (type) {
			case e_revoluteJoint :
				((b2RevoluteJoint*)joint)->SetMotorSpeed(motorSpeed);
				break;
			case e_wheelJoint :
				((b2WheelJoint*)joint)->SetMotorSpeed(motorSpeed);
				break;
			default:;
		}
	}
}

void LoadRUBEDemo::Render(float zoom)
{
	glViewport(0, 0, 480, 320);
	
	m_currentViewCenter = 0.75f * m_currentViewCenter + 0.25f * GetCurrentVehicleLocation();
	glOrthof(m_currentViewCenter.x - 1.5f * zoom, m_currentViewCenter.x + 1.5f * zoom,
			 m_currentViewCenter.y - zoom, m_currentViewCenter.y + zoom,
			 -1, 1);
	
	if ( m_doDebugDraw && m_world )
		m_world->DrawDebugData();
	
	//draw images
	for (int i = 0; i < (int)m_images.size(); i++) 
		m_images[i]->render();
}

b2Vec2 LoadRUBEDemo::GetCurrentVehicleLocation()
{
	if ( ! m_driveJoints.empty() ) 
		return m_driveJoints[0]->GetBodyA()->GetPosition();
	else
		return b2Vec2(0,0);
}








