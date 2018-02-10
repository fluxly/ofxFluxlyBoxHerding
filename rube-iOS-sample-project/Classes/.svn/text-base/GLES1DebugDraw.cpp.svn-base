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

#import <OpenGLES/ES1/gl.h>
#include "GLES1DebugDraw.h"

#ifndef DEGTORAD
#define DEGTORAD 0.0174532925199432957f
#define RADTODEG 57.295779513082320876f
#endif

/*
 * To enable blending for these rendering routines, do:
 * glEnable(GL_BLEND);
 * glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
*/

void GLES1DebugDraw::DrawPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color) 
{
    //set up vertex array
    GLfloat glverts[16]; //allow for polygons up to 8 vertices
    glVertexPointer(2, GL_FLOAT, 0, glverts); //tell OpenGL where to find vertices
    glEnableClientState(GL_VERTEX_ARRAY); //use vertices in subsequent calls to glDrawArrays
    
    //fill in vertex positions as directed by Box2D
    for (int i = 0; i < vertexCount; i++) {
		glverts[i*2]   = vertices[i].x;
		glverts[i*2+1] = vertices[i].y;
    }
	
    //edge lines
	glColor4f( color.r, color.g, color.b, 1 );
    glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLES1DebugDraw::DrawSolidPolygon(const b2Vec2* vertices, int32 vertexCount, const b2Color& color) 
{
    GLfloat glverts[16];
    glVertexPointer(2, GL_FLOAT, 0, glverts);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    for (int i = 0; i < vertexCount; i++) {
		glverts[i*2]   = vertices[i].x;
		glverts[i*2+1] = vertices[i].y;
    }
    
    //solid area
    glColor4f( color.r, color.g, color.b, 0.5f );
    glDrawArrays(GL_TRIANGLE_FAN, 0, vertexCount);
	
    //edge lines
	glColor4f( color.r, color.g, color.b, 1 );
    glDrawArrays(GL_LINE_LOOP, 0, vertexCount);
}

void GLES1DebugDraw::DrawCircle(const b2Vec2& center, float32 radius, const b2Color& color)
{		
	int numCircleVerts = 16;
    GLfloat glverts[numCircleVerts*2];
    glVertexPointer(2, GL_FLOAT, 0, glverts);
    glEnableClientState(GL_VERTEX_ARRAY);
	
	float angle = 0;
	for (int i = 0; i < numCircleVerts; i++, angle += DEGTORAD*360.0f/(numCircleVerts-1))
	{
		glverts[i*2]   = sinf(angle)*radius;
		glverts[i*2+1] = cosf(angle)*radius;
	}
	
	glPushMatrix();
	glTranslatef(center.x, center.y, 0);
	
    //edge lines
	glColor4f(color.r, color.g, color.b, 1);
	glDrawArrays(GL_LINE_LOOP, 0, numCircleVerts);
	
	glPopMatrix();
}

void GLES1DebugDraw::DrawSolidCircle(const b2Vec2& center, float32 radius, const b2Vec2& axis, const b2Color& color)
{		
	int numCircleVerts = 16;
    GLfloat glverts[numCircleVerts*2];
    glVertexPointer(2, GL_FLOAT, 0, glverts);
    glEnableClientState(GL_VERTEX_ARRAY);
	
	float angle = 0;
	for (int i = 0; i < numCircleVerts; i++, angle += DEGTORAD*360.0f/(numCircleVerts-1))
	{
		glverts[i*2]   = sinf(angle)*radius;
		glverts[i*2+1] = cosf(angle)*radius;
	}
	
	glPushMatrix();
	glTranslatef(center.x, center.y, 0);
	
    //solid area
	glColor4f(color.r, color.g, color.b, 0.5f);
	glDrawArrays(GL_TRIANGLE_FAN, 0, numCircleVerts);
	
    //edge lines
	glColor4f(color.r, color.g, color.b, 1);
	glDrawArrays(GL_LINE_LOOP, 0, numCircleVerts);
	
	b2Vec2 p1(0,0);
	b2Vec2 p2 = radius * axis;
	DrawSegment(p1, p2, color);
	
	glPopMatrix();
}

void GLES1DebugDraw::DrawSegment(const b2Vec2& p1, const b2Vec2& p2, const b2Color& color)
{
	GLfloat glverts[4];
    glVertexPointer(2, GL_FLOAT, 0, glverts);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glverts[0] = p1.x;
	glverts[1] = p1.y;
    glverts[2] = p2.x;
	glverts[3] = p2.y;
	
    //edge lines
	glColor4f( color.r, color.g, color.b, 1 );
    glDrawArrays(GL_LINES, 0, 2);
}





