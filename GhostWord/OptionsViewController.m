//
//  OptionsViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "OptionsViewController.h"
#import "Constants.h"

typedef enum gameRules {
  kRulesGhost,
  kRulesSuper,
  kRulesDuper
} GameRules;

@interface OptionsViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *player1NameField;
@property (weak, nonatomic) IBOutlet UITextField *player2NameField;

@property (strong, nonatomic) NSArray *playerKeys;
@property (strong, nonatomic) NSArray *placeholderNames;
@property (strong, nonatomic) NSArray *playerNameFields;

@property (weak, nonatomic) IBOutlet UILabel *minimumLettersLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *minimumLettersControl;

@property (weak, nonatomic) IBOutlet UILabel *rulesLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *rulesControl;

@property (weak, nonatomic) IBOutlet UIButton *startGameButton;

@property (strong, nonatomic) NSUserDefaults *defaults;


@end

@implementation OptionsViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.playerKeys = @[kPlayer1Key, kPlayer2Key];
  self.placeholderNames = @[kPlaceholder1Name, kPlaceholder2Name];
  self.playerNameFields = @[self.player1NameField, self.player2NameField];
  
  for (UITextField *textField in self.playerNameFields) {
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    NSUInteger index = [self.playerNameFields indexOfObject:textField];
    textField.placeholder = self.placeholderNames[index];
  }
  
  self.minimumLettersLabel.text = @"Minimum letters\nto challenge";
  
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
}

-(IBAction)segmentedControlValueChanged:(UISegmentedControl *)sender {
  
  if (sender == self.minimumLettersControl) {
    [self.defaults setInteger:sender.selectedSegmentIndex forKey:@"minimumLetters"];
  } else if (sender == self.rulesControl) {
    [self.defaults setInteger:sender.selectedSegmentIndex forKey:@"rules"];
  }
  [self.defaults synchronize];
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
    NSLog(@"newPlayerName is '%@'", [self.defaults objectForKey:playerKey]);
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


@end
