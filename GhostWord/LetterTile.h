//
//  LetterTile.h
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LetterTile : UILabel

@property (nonatomic) unichar myChar;
@property (nonatomic) CGPoint homeCenter;

-(id)initWithChar:(unichar)myChar;

-(void)beginTouch;
-(void)endTouch;
-(BOOL)isTouched;

@end
