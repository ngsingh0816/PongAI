/*
	MDOpenPanel.h
	MovieDraw
 
	Copyright (c) 2013. All rights reserved.
*/

#import "MDWindow.h"

@interface MDOpenPanel : MDWindow {
	id actTar;
	SEL actSel;
	NSMutableArray* fileTypes;
	NSMutableString* filename;
	unsigned int folderImg;
	NSMutableArray* images;
	BOOL showHidden;
	NSMutableArray* undo;
	unsigned int undoPointer;
	NSMutableArray* redo;
	unsigned int redoPointer;
	BOOL button;
	NSArray* files;
	BOOL shouldUpdate;
	NSThread* thread;
}

+ (id) mdOpenPanel;
+ (id) mdOpenPanelWithFrame: (MDRect)rect background: (NSColor*)bkg;
- (void) setActionTarget: (id) otar;
- (id) actionTarget;
- (void) setActionSelector: (SEL) osel;
- (SEL) actionSelector;
- (void) setFileTypes: (NSArray*) array;
- (NSMutableArray*) fileTypes;
- (void) setShowHidden: (BOOL)show;
- (BOOL) showHidden;

@end
