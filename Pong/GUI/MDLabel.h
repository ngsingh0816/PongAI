/*
	MDLabel.h
	MovieDraw
 
	Copyright (c) 2013. All rights reserved.
*/

#import "MDControl.h"

@interface MDLabel : MDControl {
	float rotation;
	NSTextAlignment align;
	NSString* realText;
	BOOL oneLine;
	BOOL changeHeight;
	BOOL wrap;
	BOOL truncate;
}

+ (id) mdLabel;
+ (id) mdLabelWithFrame: (MDRect)rect background: (NSColor*)bkg;
- (void) setRotation: (float)rot;
- (float) rotation;
- (void) setTextAlignment: (NSTextAlignment) alignment;
- (NSTextAlignment) textAlignment;
- (void) setOneLine:(BOOL)one;
- (BOOL) oneLine;
- (void) setChangeHeight: (BOOL)change;
- (BOOL) changeHeight;
- (void) setWraps: (BOOL)wr;
- (BOOL) wraps;
- (void) setTruncates:(BOOL)trun;
- (BOOL) truncates;

@end
