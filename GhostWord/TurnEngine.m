//
//  TurnEngine.m
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "TurnEngine.h"

@interface TurnEngine ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation TurnEngine

-(id)init {
  self = [super init];
  if (self) {
    self.defaults = [NSUserDefaults standardUserDefaults];
  }
  return self;
}

-(void)handleWhetherToStartOrContinueGame {
  
    // no saved game, start new game
  if (![self.defaults objectForKey:@"word"]) {
    [self resetGameValues];
    
      // saved game
  } else {
    self.currentPlayer = [self.defaults integerForKey:@"player"];
    self.currentTurn = [self.defaults integerForKey:@"turn"];
    self.currentWord = [self.defaults stringForKey:@"word"];
    self.challengeMode = [self.defaults boolForKey:@"challenge"];

    [self.delegate setupWordFieldForSavedGame];
  }
  
  [self.delegate setupNewKeyboard];
  [self.delegate updateMessageLabel];
}

-(void)handleCompletionOfTurnWithChallenge:(BOOL)challenge {
  self.currentPlayer = (self.currentPlayer + 1) % 2;
  self.currentTurn++;
  self.challengeMode = challenge;
  
  [self saveTurnData];
  [self.delegate updateMessageLabel];
}

-(void)saveTurnData {
  [self.defaults setInteger:self.currentPlayer forKey:@"player"];
  [self.defaults setInteger:self.currentTurn forKey:@"turn"];
  
  NSString *word = [self.delegate wordFromWordArrayCountingRecentTile:NO];
  if (word.length > 0) {
    [self.defaults setObject:word forKey:@"word"];
  }
  
  [self.defaults setBool:self.challengeMode forKey:@"challenge"];
}

-(void)handleEndOfGame {

  [self resetGameValues];
  [self.defaults removeObjectForKey:@"word"];
//  [NSUserDefaults resetStandardUserDefaults];
  
  [self.delegate showWonGame];
}

-(void)resetGameValues {
  self.currentPlayer = kPlayer1;
  self.currentTurn = 1;
  self.currentWord = nil;
  self.challengeMode = NO;
}

@end
