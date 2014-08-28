//
//  WonGameViewController.h
//  GhostWord
//
//  Created by Bennett Lin on 8/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WonGameViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *wonMessageLabel;

-(void)wonMessageLabelText:(NSString *)string numberOfLines:(NSUInteger)numberOfLines;

@end
