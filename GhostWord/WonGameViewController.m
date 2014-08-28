//
//  WonGameViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/26/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "WonGameViewController.h"
#import "Constants.h"

@interface WonGameViewController ()

@end

@implementation WonGameViewController {
  CGFloat _myWidth;
  CGFloat _myHeight;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  _myWidth = self.view.bounds.size.width * kWonGameWidthFactor;
  _myHeight = self.view.bounds.size.height * kWonGameHeightFactor;
  
  self.wonMessageLabel.font = [UIFont fontWithName:kFontModern size:kTileHeight];
  self.wonMessageLabel.textColor = kColourLightTan;
  self.wonMessageLabel.adjustsFontSizeToFitWidth = YES;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)wonMessageLabelText:(NSString *)string numberOfLines:(NSUInteger)numberOfLines {
  
  CGFloat margin = _myHeight * 0.05;
  
  self.wonMessageLabel.text = string;
  self.wonMessageLabel.numberOfLines = numberOfLines;
  switch (self.wonMessageLabel.numberOfLines) {
    case 1:
      self.wonMessageLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, kTileHeight);
      break;
    case 2:
      self.wonMessageLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, kTileHeight * 2);
      break;
  }
  self.wonMessageLabel.center = CGPointMake(_myWidth / 2, _myHeight / 2);
}

@end
