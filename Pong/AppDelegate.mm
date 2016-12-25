//
//  AppDelegate.m
//  ECE 448 MP2 EC
//
//  Created by Neil Singh on 10/24/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import "AppDelegate.h"
#import "game.h"

@interface AppDelegate (InternalMethods)
- (void) setupRenderTimer;
- (void) updateGLView:(NSTimer *)timer;
- (void) createFailed;
@end

GLView* glview = nil;

@implementation AppDelegate

- (void) awakeFromNib
{
	[ NSApp setDelegate:(id)self ];   // We want delegate notifications
	renderTimer = nil;
	[ glWindow makeFirstResponder:self ];
	glView = [ [ GLView alloc ] initWithFrame:NSMakeRect(0, 0, 340, 340)
									colorBits:16 depthBits:16 fullscreen:FALSE ];
	if( glView != nil )
	{
		[ glWindow setAcceptsMouseMovedEvents:YES ];
		[ [ glWindow contentView ] addSubview:glView ];
		[ glWindow makeKeyAndOrderFront:self ];
		[ glWindow makeFirstResponder:glView ];
		[ self setupRenderTimer ];
		[ glView setAppDeletgate:self ];
		
		glview = glView;
		[ self reset:self ];
	}
	else
		[ self createFailed ];
}


/*
 * Setup timer to update the OpenGL view.
 */
- (void) setupRenderTimer
{
	NSTimeInterval timeInterval = 1 / 60.0;
	
	renderTimer = [ NSTimer scheduledTimerWithTimeInterval:timeInterval
													  target:self
													selector:@selector( updateGLView: )
													userInfo:nil repeats:YES  ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSEventTrackingRunLoopMode ];
	[ [ NSRunLoop currentRunLoop ] addTimer:renderTimer
									forMode:NSModalPanelRunLoopMode ];
}

#define	n	8
int* game = NULL;
bool player = false;

+ (void) doTurn:(NSString*)play strategy:(NSString*)strat depth:(int)d {
	strategy_function s = offensive_evaluation;
	if ([ strat isEqualToString:@"Defensive" ])
		s = defensive_evaluation;
	
	if ([ play isEqualToString:@"Human" ]) {
		bool p = player;
		dispatch_async(dispatch_get_main_queue(), ^{
			[ glview setGame:game ];
			[ glview setIsTurn:p ];
		});
	} else if ([ play isEqualToString:@"Minimax" ]) {
		Move m = minimax(game, player, s, d);
		dispatch_async(dispatch_get_main_queue(), ^{
			[ glview makeMove:m ];
		});
	} else if ([ play isEqualToString:@"Alpha-Beta" ]) {
		Move m = alpha_beta(game, player, s, d);
		dispatch_async(dispatch_get_main_queue(), ^{
			[ glview makeMove:m ];
		});
	} else if ([ play isEqualToString:@"Greedy" ]) {
		Move m = greedy(game, player, s, d);
		dispatch_async(dispatch_get_main_queue(), ^{
			[ glview makeMove:m ];
		});
	}
	
	player = !player;
}

- (void) userMadeInput:(int*)g {
	memcpy(game, g, sizeof(int) * n * n);
	
	if (game_is_done(game))
		return;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
		[ AppDelegate doTurn:[ [ (player ? player2 : player1) selectedItem ] title ]
					strategy:[ [ (player ? strategy2 : strategy2) selectedItem ] title ]
					   depth:[ (player ? depth2 : depth1) intValue ] ];
	});
}

- (IBAction) reset:(id)sender {
	if (game)
		clean_up(game);
	game = setup_game();
	
	[ glView setGame:game ];
	
	player = false;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
		[ AppDelegate doTurn:[ [ (player ? player2 : player1) selectedItem ] title ]
					strategy:[ [ (player ? strategy2 : strategy2) selectedItem ] title ]
					   depth:[ (player ? depth2 : depth1) intValue ] ];
	});
}


/*
 * Called by the rendering timer.
 */
- (void) updateGLView:(NSTimer *)timer
{
	if( glView != nil )
		[ glView drawRect:[ glView frame ] ];
}


/*
 * Handle key presses
 */
- (void) keyDown:(NSEvent *)theEvent
{
	unichar unicodeKey;
	
	unicodeKey = [ [ theEvent characters ] characterAtIndex:0 ];
	switch( unicodeKey )
	{
			// Handle key presses here
	}
}


/*
 * Called if we fail to create a valid OpenGL view
 */
- (void) createFailed
{
	NSWindow *infoWindow;
	
	infoWindow = NSGetCriticalAlertPanel( @"Initialization failed",
										 @"Failed to initialize OpenGL",
										 @"OK", nil, nil );
	[ NSApp runModalForWindow:infoWindow ];
	[ infoWindow close ];
	[ NSApp terminate:self ];
}


/*
 * Cleanup
 */
- (void) dealloc
{
	if( renderTimer != nil && [ renderTimer isValid ] )
		[ renderTimer invalidate ];
}

@end
