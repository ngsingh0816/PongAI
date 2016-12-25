//
//  PlayPingPongState.m
//  Pong
//
//  Created by Neil Singh on 12/1/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import "PlayPingPongState.h"
#import "GLView.h"
#import "MenuState.h"
#import "PingPongAI.h"

State getNextStatePingPongPlay(State s, Action a, GameState* gameState) {
	State nextState = s;
	
	// Apply the action
	if (a == PING_PONG_ACTION_UP) {
		nextState.paddles[1].y -= 0.04;
		if (nextState.paddles[1].y < 0)
			nextState.paddles[1].y = 0;
	}
	else if (a == PING_PONG_ACTION_DOWN) {
		nextState.paddles[1].y += 0.04;
		if (nextState.paddles[1].y > 1 - nextState.paddles[1].height)
			nextState.paddles[1].y = 1 - nextState.paddles[1].height;
	}
	
	nextState.reward = 0;
	
	[ gameState setState:nextState ];
	
	// Move the ball
	NSPoint lines[3];
	int numLines = [ gameState updateBall:lines ];
	
	nextState = [ gameState state ];
	nextState.ball.vy += 0.005;
	
	// Update the player's paddle
	float value = nextState.paddles[0].y;
	if ([ gameState upPressed ])
		value -= 0.04;
	if ([ gameState downPressed ])
		value += 0.04;
	
	if (value < 0)
		value = 0;
	if (value > 1 - nextState.paddles[0].height)
		value = 1 - nextState.paddles[0].height;
	nextState.paddles[0].y = value;
	
	[ gameState setState:nextState ];
	
	// Check for collisions
	[ gameState checkCollisions:lines numberOfSegments:numLines ];
	
	nextState = [ gameState state ];
	
	// If the AI paddle has missed, give it a bad reward
	if (nextState.ball.x >= 1)
		nextState.reward = -1;
	// If the enemy paddle has missed, give it a good reward
	if (nextState.ball.x <= 0)
		nextState.reward = 1;
	
	return nextState;
}

@implementation PlayState

- (instancetype) initWithLock:(NSLock *)_lock {
	if ((self = [ super initWithLock:_lock ])) {
		speed = 1;
		ai = [ [ FollowerAI alloc ] initFromFile:[ NSString stringWithFormat:@"%@/follower", [ [ NSBundle mainBundle ] resourcePath ] ] ];
		[ ai setGetNextStateFunction:getNextStatePlayer ];
		[ ai setGameState:self ];
	}
	return self;
}

- (void) resetState {
	for (int z = 0; z < 2; z++) {
		state.paddles[z].height = 0.2;
		state.paddles[z].y = 0.5 - state.paddles[z].height / 2;
	}
	state.ball.x = 0.5;
	state.ball.y = 0.5;
	state.ball.vx = 0.03;
	state.ball.vy = 0.01;
	
	[ super resetState ];
}

- (void) doCollisionForPaddle:(int)p {
	[ super doCollisionForPaddle:p ];
	
	if (p == 1) {
		// Update the current's reward
		state.reward = 1;
	}
}

- (void) updateState {
	[ lock lock ];
	
	[ super updateState ];
	
	// Update our AI
	state = [ ai performExploitationStep:state ];
	
	// Check if the ball goes out of bounds
	if ([ self isBallOutOfBounds ])
		[ self resetState ];
	
	[ lock unlock ];
}

- (double) stateRate {
	return 1 / 15.0 / speed;
}

- (void) backPressed:(id)sender {
	GameState* nextState = [ [ MenuState alloc ] initWithLock:lock ];
	[ nextState setGLView:glView ];
	[ glView transitionToNextState:nextState ];
}

- (void) chooseSpeed:(id)sender {
	speed = [ [ (MDPopup*)sender itemAtIndex:[ (MDPopup*)sender selectedItem ] ] doubleValue ];
}

- (BOOL) enterPressed {
	if (![ super enterPressed ])
		return FALSE;
	
	MDControlView* view = ViewForIdentity(@"Menu");
	MDRect frame = [ view frame ];
	MDButton* back = [ [ MDButton alloc ] initWithFrame:MakeRect(15, 15, frame.width - 30, 30) background:MD_BUTTON_DEFAULT_BUTTON_COLOR ];
	[ back setAlpha:0.7 ];
	[ back setText:@"Back" ];
	[ back setTarget:self ];
	[ back setAction:@selector(backPressed:) ];
	[ view addSubView:back ];
	
	MDPopup* speedSelect = [ [ MDPopup alloc ] initWithFrame:
							MakeRect(70, frame.height - 15 - MD_POPUP_DEFAULT_SIZE.height, frame.width - 85,
									 MD_POPUP_DEFAULT_SIZE.height)
												  background:MD_POPUP_DEFAULT_COLOR ];
	[ speedSelect setTarget:self ];
	[ speedSelect setAction:@selector(chooseSpeed:) ];
	for (int z = 0; z < 7; z++)
		[ speedSelect addItem:[ NSString stringWithFormat:@"%0.1f", z * 0.5 + 1 ] ];
	[ speedSelect selectItem:round((speed - 1) / 0.5) ];
	[ view addSubView:speedSelect ];
	
	MDLabel* speedLabel = [ [ MDLabel alloc ] initWithFrame:
						   MakeRect(15, frame.height - 15, 0, 0)
												 background:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ speedLabel setTextColor:[ NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1 ] ];
	[ speedLabel setText:@"Speed:" ];
	[ speedLabel setTextAlignment:NSTextAlignmentLeft ];
	[ view addSubView:speedLabel ];
	
	return TRUE;
}

@end
