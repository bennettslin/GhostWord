//
//  OptionsViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "StartNewGameViewController.h"
#import "Constants.h"

#define kSegmentFontSize (kIsIPhone ? 20.f : 32.f)
#define kSegmentWidth (kSegmentFontSize * 4)

@interface StartNewGameViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *player1NameField;
@property (weak, nonatomic) IBOutlet UITextField *player2NameField;

@property (strong, nonatomic) NSArray *playerKeys;
@property (strong, nonatomic) NSArray *placeholderNames;
@property (strong, nonatomic) NSArray *playerNameFields;

@property (weak, nonatomic) IBOutlet UILabel *minimumLettersName;
@property (weak, nonatomic) IBOutlet UILabel *minimumLettersLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *minimumLettersControl;

@property (weak, nonatomic) IBOutlet UILabel *rulesName;
@property (weak, nonatomic) IBOutlet UILabel *rulesLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rulesControl;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

@property (strong, nonatomic) NSUserDefaults *defaults;


@end

@implementation StartNewGameViewController {
  CGFloat _myWidth;
}

-(void)viewDidLoad {
  [super viewDidLoad];
  
  _myWidth = self.view.bounds.size.width * kStartGameWidthFactor;
  CGFloat myHeight = self.view.bounds.size.height * kStartGameHeightFactor;
  
  if (myHeight < 568 * kStartGameHeightFactor) {
    myHeight = 568 * kStartGameHeightFactor;
  }
  
  CGFloat margin = _myWidth * 0.05;
  CGFloat yPadding = kIsIPhone ? 15.f : 25.f;
  
  self.playerKeys = @[kPlayer1Key, kPlayer2Key];
  self.placeholderNames = @[kPlaceholder1Name, kPlaceholder2Name];
  self.playerNameFields = @[self.player1NameField, self.player2NameField];
  
  for (UITextField *textField in self.playerNameFields) {
    NSUInteger index = [self.playerNameFields indexOfObject:textField];
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    textField.placeholder = self.placeholderNames[index];
    NSUInteger textFieldHeight = kIsIPhone ? 40 : 72;
    textField.frame = CGRectMake(margin, margin + textFieldHeight * index * 1.125, _myWidth - margin * 2, textFieldHeight);
    textField.font = [UIFont fontWithName:kFontModern size:kIsIPhone ? 36.f : 72.f];
    textField.textColor = kColourSolidBlue;
    textField.backgroundColor = kColourLightBlue;
    textField.tintColor = kColourSolidBlue;
  }
  
  self.minimumLettersName.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 30 : 54)];
  self.minimumLettersName.textColor = [kColourLightTan colorWithAlphaComponent:0.8f];
  self.minimumLettersName.text = @"Minimum letters";
  [self.minimumLettersName sizeToFit];
  
  self.minimumLettersName.center = CGPointMake(_myWidth / 2, self.player2NameField.center.y + self.player2NameField.frame.size.height / 2 + yPadding + self.minimumLettersName.frame.size.height / 2);
  
    // segmented controls
  UIFont *font = [UIFont boldSystemFontOfSize:kSegmentFontSize];
  NSDictionary *attributes = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
  
  [self.minimumLettersControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
  CGRect minimumFrame = self.minimumLettersControl.frame;
  minimumFrame.size.width = kSegmentWidth * 2;
  minimumFrame.size.height = kIsIPhone ? 42.f : 60.f;
  self.minimumLettersControl.frame = minimumFrame;
  self.minimumLettersControl.center = CGPointMake(_myWidth / 2, self.minimumLettersName.center.y + self.minimumLettersName.frame.size.height / 2 + self.minimumLettersControl.frame.size.height / 2);
  for (int i = 0; i < 2; i++) {
    [self.minimumLettersControl setWidth:kSegmentWidth forSegmentAtIndex:i];
  }
  
  self.minimumLettersLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 20 : 40)];
  self.minimumLettersLabel.textColor = [kColourLightTan colorWithAlphaComponent:0.8f];
  self.minimumLettersLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, (kIsIPhone ? 50 : 100));
  self.minimumLettersLabel.adjustsFontSizeToFitWidth = YES;
  self.minimumLettersLabel.numberOfLines = 2;
  
  self.minimumLettersLabel.center = CGPointMake(_myWidth / 2, self.minimumLettersControl.center.y + self.minimumLettersControl.frame.size.height / 2 + self.minimumLettersLabel.frame.size.height / 2);
  
  self.rulesName.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 30 : 54)];
  self.rulesName.textColor = [kColourLightTan colorWithAlphaComponent:0.8f];
  self.rulesName.text = @"Game rules";
  [self.rulesName sizeToFit];
  
  self.rulesName.center = CGPointMake(_myWidth / 2, self.minimumLettersLabel.center.y + self.minimumLettersLabel.frame.size.height / 2 + yPadding + self.rulesName.frame.size.height / 2);
  
  [self.rulesControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
  CGRect rulesFrame = self.rulesControl.frame;
  rulesFrame.size.width = _myWidth - margin * 2;
  rulesFrame.size.height = kIsIPhone ? 42.f : 60.f;
  self.rulesControl.frame = rulesFrame;
  self.rulesControl.center = CGPointMake(_myWidth / 2, self.rulesName.center.y + self.rulesName.frame.size.height / 2 + self.rulesControl.frame.size.height / 2);
  for (int i = 0; i < 3; i++) {
    [self.rulesControl setWidth:rulesFrame.size.width / 3 forSegmentAtIndex:i];
  }
  
  self.rulesLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 20 : 40)];
  self.rulesLabel.textColor = [kColourLightTan colorWithAlphaComponent:0.8f];
  self.rulesLabel.adjustsFontSizeToFitWidth = YES;
  
  self.startGameButton.titleLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 36 : 72)];
  [self.startGameButton sizeToFit];
  self.startGameButton.center = CGPointMake(_myWidth / 2, myHeight - margin - self.startGameButton.frame.size.height / 4);
  
  self.defaults = [NSUserDefaults standardUserDefaults];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  if (![self.defaults objectForKey:@"minimumLetters"]) {
    [self.defaults setInteger:0 forKey:@"minimumLetters"];
    [self.defaults synchronize];
  }
  self.minimumLettersControl.selectedSegmentIndex = [self.defaults integerForKey:@"minimumLetters"];

  if (![self.defaults objectForKey:@"rules"]) {
    [self.defaults setInteger:0 forKey:@"rules"];
    [self.defaults synchronize];
  }
  self.rulesControl.selectedSegmentIndex = [self.defaults integerForKey:@"rules"];
  
  for (int i = 0; i < 2; i++) {
    
    NSString *playerKey = self.playerKeys[i];
    NSString *userDefaultName = [self.defaults objectForKey:playerKey];
    NSString *placeholderName = self.placeholderNames[i];
    UITextField *textField = self.playerNameFields[i];
    
    if (!userDefaultName || [userDefaultName isEqualToString:@""] ||
        [userDefaultName isEqualToString:placeholderName]) {
      textField.text = nil;
      [self.defaults setObject:placeholderName forKey:playerKey];
    } else {
      textField.text = [self.defaults objectForKey:playerKey];
    }
  }
  [self updateText];
}

-(IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
  
  if (sender == self.minimumLettersControl) {
    [self.defaults setInteger:sender.selectedSegmentIndex forKey:@"minimumLetters"];
  } else if (sender == self.rulesControl) {
    [self.defaults setInteger:sender.selectedSegmentIndex forKey:@"rules"];
  }
  [self.defaults synchronize];
  [self updateText];
}

#pragma mark - state change methods

-(void)saveNameForPlayerIndex:(NSUInteger)index {
  
  UITextField *textField = self.playerNameFields[index];
  NSString *playerKey = self.playerKeys[index];
  NSString *placeholderName = self.placeholderNames[index];
  
  NSString *trimmedString = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (![trimmedString isEqualToString:[self.defaults objectForKey:playerKey]]) {
    if (!trimmedString || [trimmedString isEqualToString:@""]) {
      [self.defaults setObject:placeholderName forKey:playerKey];
    } else {
      [self.defaults setObject:trimmedString forKey:playerKey];
    }
    [self.defaults synchronize];
//    NSLog(@"newPlayerName is '%@'", [self.defaults objectForKey:playerKey]);
  }
}

#pragma mark - text field methods

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
  return !(newString.length > 25);
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
  [self.delegate enableOverlay:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
  [self resignTextField:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self resignTextField:textField];
  return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [self resignTextField:nil];
}

-(void)resignTextField:(UITextField *)textField {
  textField = !textField ? [self checkTextFieldFirstResponder] : textField;
  
  if (textField) {
    [textField resignFirstResponder];
    NSUInteger index = [self.playerNameFields indexOfObject:textField];
    [self saveNameForPlayerIndex:index];
    [self.delegate enableOverlay:YES];
  }
}

-(UITextField *)checkTextFieldFirstResponder {
  
  for (UITextField *textField in self.playerNameFields) {
    if ([textField isFirstResponder]) {
      return textField;
    }
  }
  return nil;
}

-(IBAction)startGameTapped:(id)sender {
  [self.delegate presentMatchViewController];
}


-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)updateText {
  
  switch (self.minimumLettersControl.selectedSegmentIndex) {
    case 0:
      self.minimumLettersLabel.text = @"Words three letters and up\nlose the game.";
      break;
    case 1:
      self.minimumLettersLabel.text = @"Words four letters and up\nlose the game.";
      break;
  }
  
  switch (self.rulesControl.selectedSegmentIndex) {
    case 0:
      self.rulesLabel.numberOfLines = 1;
      self.rulesLabel.text = @"New letter is placed at end.";
      break;
    case 1:
      self.rulesLabel.numberOfLines = 2;
      self.rulesLabel.text = @"New letter can be placed\nat beginning or end.";
      break;
    case 2:
      self.rulesLabel.numberOfLines = 3;
      self.rulesLabel.text = @"New letter can be placed\nat beginning or end.\nOrder can be reversed.";
      break;
  }
  [self adjustRulesDescriptionLabel];
}

-(void)adjustRulesDescriptionLabel {

  CGFloat margin = _myWidth * 0.05;
  
  switch (self.rulesLabel.numberOfLines) {
    case 1:
      self.rulesLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, (kIsIPhone ? 25 : 50));
      break;
    case 2:
      self.rulesLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, (kIsIPhone ? 50 : 100));
      break;
    case 3:
      self.rulesLabel.frame = CGRectMake(0, 0, _myWidth - margin * 2, (kIsIPhone ? 75 : 150));
      break;
  }
  self.rulesLabel.center = CGPointMake(_myWidth / 2, self.rulesControl.center.y + self.rulesControl.frame.size.height / 2 + self.rulesLabel.frame.size.height / 2);
}

@end
