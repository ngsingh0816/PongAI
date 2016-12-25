//
//  FollowerAI.m
//  Pong
//
//  Created by Neil Singh on 12/1/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import "FollowerAI.h"

@implementation FollowerAI

// Basic info
- (unsigned long) numberOfStates {
	return 144 * 2 * 3 * 12 + 1;
}

- (unsigned long) numberOfActions {
	return 3;
}

- (double) learningRateConstant {
	return 2250;
}

- (double) discountFactor {
	return 0.85;				// solve for d^(estimated time steps from hit to hit) = 0.01
	// estimated time steps = 20
}

// Markov Decision Process Discretization
- (unsigned long) getDescretizedState:(State)state {
	// State 0 is for the state where you missed
	if (state.reward == -1)
		return 0;
	
	// Get the 12 x 12 grid of the ball
	int ballX = floor(state.ball.x * 12);
	if (ballX == 12)
		ballX = 11;
	int ballY = floor(state.ball.y * 12);
	if (ballY == 12)
		ballY = 11;
	
	// Get the X velocity
	int xVel = state.ball.vx > 0;
	
	// Get the Y velocity
	int yVel = 1 + (state.ball.vy > 0);
	if (fabs(state.ball.vy) < 0.015)
		yVel = 0;
	
	// Get the paddle location
	int paddleLoc = floor(12.0 * state.paddles[1].y / (1 - state.paddles[1].height));
	if (state.paddles[1].y == 1 - state.paddles[1].height)
		paddleLoc = 11;
	
	// Return the overall state
	unsigned long numStates = [ self numberOfStates ];
	return 1 + ballX * (numStates / 12) + ballY * (numStates / (12 * 12)) +
	xVel * (numStates / (12 * 12 * 2)) + yVel * (numStates / (12 * 12 * 2 * 3)) + paddleLoc;
}

// Settings for choosing the exploration function
- (unsigned long) minNumberOfEstimates {
	return 12 * 12 * 3;						// 12 x 12 grid x 3 actions per grid entry
}

- (double) optimisticRewardEstimate {
	return 1 / (1 - 0.85);					// Geometric series of discount factor
}

@end
