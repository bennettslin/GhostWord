//
//  TurnEngine.h
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum player {
  kPlayer1,
  kPlayer2
} Player;

@protocol TurnEngineDelegate;

@interface TurnEngine : NSObject

@property (nonatomic) Player currentPlayer;
@property (nonatomic) NSUInteger currentTurn;
@property (nonatomic) BOOL challengeMode;
@property (strong, nonatomic) NSString *currentWord;

@property (weak, nonatomic) id<TurnEngineDelegate> delegate;

-(void)handleWhetherToStartOrContinueGame;
-(void)handleCompletionOfTurnWithChallenge:(BOOL)challenge;
-(void)handleEndOfGame;
-(void)saveTurnData;

@end

@protocol TurnEngineDelegate <NSObject>

-(void)setupNewKeyboard;
-(void)setupWordFieldForSavedGame;

-(NSString *)wordFromWordArrayCountingRecentTile:(BOOL)countRecentTile;

-(void)updateMessageLabel;
-(void)showWonGame;

@end