//
//  ViewController.h
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MatchDelegate;

@interface MatchViewController : UIViewController

@property (weak, nonatomic) id<MatchDelegate> delegate;

-(void)preLoadModel;

@end

@protocol MatchDelegate <NSObject>

-(void)backToMainMenu;
-(void)helpButtonPressed;

@end