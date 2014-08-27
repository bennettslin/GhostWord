//
//  OptionsViewController.h
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StartNewGameDelegate;

@interface StartNewGameViewController : UIViewController

@property (weak, nonatomic) id<StartNewGameDelegate> delegate;

-(void)resignTextField:(UITextField *)textField;

@end

@protocol StartNewGameDelegate <NSObject>

-(void)enableOverlay:(BOOL)enable;
-(void)presentMatchViewController;

@end