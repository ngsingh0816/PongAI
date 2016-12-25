/*
	MDControl.h
	MovieDraw
 
	Copyright (c) 2013. All rights reserved.
*/

#import "MDControlView.h"
#import "GLString.h"

@interface MDControl : MDControlView {
	NSMutableString* text;
	NSColor* textColor;
	id target;
	SEL action;
	SEL doubleAction;
	int state;
	NSFont* textFont;
	BOOL down;
	BOOL keyDown;
	BOOL up;
	GLString* glStr;
	BOOL continuous;
	BOOL scrolled;
	unsigned int ccount;
	unsigned int fpsCounter;
}

// Creation
+ (id) mdControl;
+ (id) mdControlWithFrame: (MDRect)rect background: (NSColor*)bkg;
- (id) init;
- (id) initWithFrame: (MDRect)rect background: (NSColor*)bkg;

// Text
- (void) setText: (NSString*)str;
- (NSString*) text;
- (void) setTextColor: (NSColor*)color;
- (NSColor*) textColor;
- (void) setTextFont: (NSFont*) font;
- (NSFont*) textFont;
- (GLString*) glStr;

// Action
- (void) setTarget: (id) tar;
- (id) target;
- (void) setAction: (SEL) sel;
- (SEL) action;
- (void) setDoubleAction:(SEL)sel;
- (SEL) doubleAction;
- (void) setContinuous:(BOOL) cont;
- (BOOL) continuous;
- (void) setContinuousCount:(unsigned int)count;
- (unsigned int) continuousCount;

// State
- (int) state;
- (void) setState: (int)nstate;


@end
