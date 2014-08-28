//
//  ViewController.h
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol MatchDelegate;

@interface MatchViewController : UIViewController

@property (weak, nonatomic) id<MatchDelegate> delegate;

  // bools
@property (nonatomic) GameEndedReason gameEndedReason;

-(void)preLoadModel;
-(void)handleWonGame;

@end

@protocol MatchDelegate <NSObject>

-(void)backToMainMenu; // for test purposes only
-(void)helpButtonPressed;
-(void)showWonGameVCWithString:(NSString *)string numberOfLines:(NSUInteger)numberOfLines;
-(void)showResignActionSheet;

@end