//
//  HelpViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "HelpViewController.h"
#import "Constants.h"

@interface HelpViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation HelpViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  CGFloat myWidth = self.view.bounds.size.width * kHelpWidthFactor;
  CGFloat myHeight = self.view.bounds.size.height * kHelpHeightFactor;
  
  if (myHeight < 568 * kHelpHeightFactor) {
    myHeight = 568 * kHelpHeightFactor;
  }
  
  CGFloat margin = myWidth * 0.05;
  
  self.textView.frame = CGRectMake(0, 0, myWidth - margin * 2,
                                   myHeight - margin * 2);
  self.textView.center = CGPointMake(myWidth / 2, myHeight / 2);
  self.textView.text = @"Players build towards a word by adding one letter each turn, while trying to force their opponent to complete the word.\n\nIf a player believes a word has been completed, or that a word cannot be formed with the letters played thus far, he may challenge. If the other player can form a word by adding new letters, she wins. Otherwise, she loses.";
  self.textView.userInteractionEnabled = NO;
  self.textView.textColor = kColourDarkTan;
  self.textView.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 24 : 48)];
  self.textView.backgroundColor = [UIColor clearColor];
  // Do any additional setup after loading the view.
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
