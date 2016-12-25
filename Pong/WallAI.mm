//
//  WallAI.m
//  Pong
//
//  Created by Neil Singh on 12/1/16.
//  Copyright © 2016 Neil Singh. All rights reserved.
//

#import "WallAI.h"

@implementation WallAI

// Basic info
- (unsigned long) numberOfStates {
	return 0;
}

- (unsigned long) numberOfActions {
	return 0;
}

- (double) learningRate:(unsigned long)t {
	return 0;
}

- (double) discountFactor:(unsigned long)t {
	return 0;
}

- (void) resetNumberOfSteps {
	numberOfSteps = 0;
}

// Markov Decision Process Discretization
- (unsigned long) getDescretizedState:(State*)state {
	return 0;
}

- (double) getRewardForState:(State*)state {
	return 0;
}

// Settings for choosing the exploration function
- (unsigned long) minNumberOfEstimates {
	return 0;
}

- (double) optimisticRewardEstimate {
	return 0;
}

@end
