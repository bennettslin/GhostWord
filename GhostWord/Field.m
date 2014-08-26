//
//  Field.m
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "Field.h"
#import "LetterTile.h"

@implementation Field

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//-(LetterTile *)getTileFromTouches:(NSSet *)touches event:(UIEvent *)event {
//  CGPoint locationPoint = [[touches anyObject] locationInView:self];
//  UIView *touchedView = [self hitTest:locationPoint withEvent:event];
//  
//
//  }
//  return nil;
//}
//
//-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//  UIView *hit =  [super hitTest:point withEvent:event];
//  
//  if (hit == self) {
//    return nil;
//  }
//  
//  return hit;
//}

@end
