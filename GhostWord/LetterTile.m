//
//  LetterTile.m
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LetterTile.h"
#import "Constants.h"

@interface LetterTile ()

@property (nonatomic) BOOL isTouched;

@end

@implementation LetterTile

- (instancetype)initWithChar:(unichar)myChar {
  self = [super init];
    if (self) {

      [self resetFrameAndFont];
      self.myChar = myChar;
      unichar chars[1] = {myChar};
      self.text = [NSString stringWithCharacters:chars length:1];
      self.textAlignment = NSTextAlignmentCenter;
      self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
      
      self.backgroundColor = kTileNormalColour;
      self.layer.cornerRadius = kTileWidth / 4;
      self.clipsToBounds = YES;
      
      self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)beginTouch {
  self.isTouched = YES;
  self.frame = CGRectMake(0, 0, kTileWidth * kTouchScaleFactor, kTileHeight * kTouchScaleFactor);
  self.layer.cornerRadius = kTileWidth * kTouchScaleFactor / 4;
  self.backgroundColor = kTileTouchedColour;
}

-(void)endTouch {
  self.isTouched = NO;
  self.frame = CGRectMake(self.center.x - kTileWidth / 2, self.center.y - kTileHeight / 2, kTileWidth, kTileHeight);
  self.layer.cornerRadius = kTileWidth / 4;
  self.backgroundColor = kTileNormalColour;
}

-(BOOL)isTouched {
  return self.isTouched;
}

-(void)finalise {
  self.backgroundColor = [UIColor redColor];
}

-(void)definalise {
  self.backgroundColor = kTileNormalColour;
}

-(void)resetFrameAndFont {
  CGRect newFrame = self.frame;
  newFrame.size.width = kTileWidth;
  newFrame.size.height = kTileHeight;
  self.frame = newFrame;
  self.font = [UIFont fontWithName:kFontModern size:kTileWidth];
}

@end
