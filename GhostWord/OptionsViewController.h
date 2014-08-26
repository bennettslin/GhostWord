//
//  OptionsViewController.h
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionsDelegate;

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) id<OptionsDelegate> delegate;

-(void)resignTextField:(UITextField *)textField;

@end

@protocol OptionsDelegate <NSObject>

-(void)enableOverlay:(BOOL)enable;

@end