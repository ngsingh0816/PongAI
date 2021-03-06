/*
	MDImageView.h
	MovieDraw
 
	Copyright (c) 2013. All rights reserved.
*/

#import "MDControl.h"

#define MD_IMAGEVIEW_DEFAULT_SIZE	NSMakeSize(32, 32)
#define MD_IMAGEVIEW_DEFAULT_COLOR	[ NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1 ]

@interface MDImageView : MDControl
{
	NSString* image;
	NSColor* mouseDownColor;
	unsigned int gImage;
	float rotation;
	unsigned int texBuffer;
}

+ (MDImageView*) imageView;
+ (MDImageView*) imageViewWithFrame: (MDRect)rect background:(NSColor*)bkg;
- (void) setImage:(NSString*)image;
- (void) setImageData:(NSData*)image;
- (void) setImage:(NSString*)image onThread:(BOOL)thread;
- (void) setImageData:(NSData*)image onThread:(BOOL)thread;
- (NSString*) image;
- (unsigned int) glImage;
- (void) setMouseDownColor:(NSColor*)color;
- (NSColor*) mouseDownColor;
- (void) setRotation:(float)rot;
- (float) rotation;

@end
