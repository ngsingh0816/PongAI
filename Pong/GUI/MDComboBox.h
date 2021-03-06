/*
	MDComboBox.h
	MovieDraw
 
	Copyright (c) 2013. All rights reserved.
*/

#import "MDControl.h"

@class MDPopupMenu, MDTextField, MDButton;

#define MD_COMBOBOX_DEFAULT_SIZE	NSMakeSize(96, 20)
#define MD_COMBOBOX_DEFAULT_COLOR	[ [ NSColor whiteColor ] colorUsingColorSpace:[ NSColorSpace genericRGBColorSpace ] ]
#define MD_COMBOBOX_DEFAULT_COLOR2	[ NSColor colorWithCalibratedRed:0.930 green:0.930 blue:0.930 alpha:1 ]
#define MD_COMBOBOX_DEFAULT_BORDER_COLOR	[ NSColor colorWithCalibratedRed:0.565 green:0.565 blue:0.565 alpha:1 ]

@interface MDComboBox : MDControl {
	NSMutableArray* titems;
	NSMutableArray* strings;
	MDPopupMenu* popUp;
	MDTextField* field;
	MDButton* downButton;
}

+ (MDComboBox*) mdComboBox;
+ (MDComboBox*) mdComboBoxWithFrame:(MDRect)rect background:(NSColor*)bkg;
- (void) addItem:(NSString*)str;
- (void) removeItem: (NSString*)str;
- (NSString*) stringValue;
- (void) selectItem: (unsigned long)item;
- (MDTextField*) field;
- (void) downPressed;

@end
