//
//  ViewController.m
//  EnergySavvySpellcheckChallenge
//
//  Created by Bennett Lin on 5/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MainViewController.h"
#import "WordLogic.h"
#import "OptionsViewController.h"
#import "HelpViewController.h"
#import "MatchViewController.h"

@interface MainViewController () <WordLogicDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIPickerView *wordListPicker;

@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *pvpButton;
@property (weak, nonatomic) IBOutlet UIButton *pvcButton;

@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) MatchViewController *matchVC;
@property (strong, nonatomic) UIViewController *childVC;

@property (strong, nonatomic) NSArray *wordListArray;
@property (strong, nonatomic) WordLogic *logicEngine;
@property (nonatomic) WordStatus myWordStatus;

@property (weak, nonatomic) IBOutlet UILabel *titleLogo;

@property (strong, nonatomic) UIButton *darkOverlay;
@property (nonatomic) BOOL overlayEnabled;
@property (nonatomic) BOOL vcIsAnimating;

@end

@implementation MainViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.titleLogo.font = [UIFont fontWithName:kFontModern size:24];
  
  self.matchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"matchVC"];
  self.matchVC.view.backgroundColor = [UIColor lightGrayColor];
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"helpVC"];
  self.helpVC.view.backgroundColor = [UIColor purpleColor];
  
  self.optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
  self.optionsVC.view.backgroundColor = [UIColor blueColor];
  
  self.logicEngine = [[WordLogic alloc] init];
  self.logicEngine.delegate = self;
  [self.logicEngine generateWordLists];
  
  self.inputField.delegate = self;
  self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;

  self.wordListPicker.delegate = self;
  self.wordListPicker.dataSource = self;
  
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
  [self.darkOverlay addTarget:self action:@selector(backToMain) forControlEvents:UIControlEventTouchDown];
  
  self.vcIsAnimating = NO;
}

#pragma mark - text field delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField {
  NSString *suggestedWord = [self.logicEngine suggestCorrectWordForUserWord:textField.text];
  [self showWordInPicker:suggestedWord];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.inputField resignFirstResponder];
  return YES;
}

#pragma mark - picker methods

-(void)showWordInPicker:(NSString *)suggestedWord {

  [self.wordListPicker selectRow:(suggestedWord ? self.logicEngine.pickerIndex : self.wordListArray.count) inComponent:0 animated:YES];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.wordListArray.count + 1;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return (row == self.wordListArray.count) ? @"(no suggestion)" : self.wordListArray[row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 32.f;
}

#pragma mark - view controller methods

-(void)backToMain {
  
  if (self.childVC) {
    [self removeChildViewController:self.childVC];
    self.childVC = nil;
  }
  
  if (self.darkOverlay.superview) {
    [self fadeOverlayIn:NO];
  }
}

-(void)presentChildViewController:(UIViewController *)childVC {
  
  self.vcIsAnimating = YES;
  (self.childVC && self.childVC != childVC) ? [self removeChildViewController:self.childVC] : nil;
  self.childVC = childVC;
  
  if (![self.darkOverlay superview]) {
    [self fadeOverlayIn:YES];
  }
  
  CGFloat viewWidth = self.view.bounds.size.width * 4 / 5;
  CGFloat viewHeight = self.view.bounds.size.height * 3 / 5;
  
  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  childVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.size.height);
  childVC.view.layer.cornerRadius = 20.f;
  childVC.view.layer.masksToBounds = YES;
  
  [self.view addSubview:childVC.view];
  [self animatePresentVC:childVC];
}

-(void)animatePresentVC:(UIViewController *)childVC {
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    childVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
    self.vcIsAnimating = NO;
  }];
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    childVC.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height
                                      );
  } completion:^(BOOL finished) {
    [childVC.view removeFromSuperview];
  }];
}

#pragma mark - button methods

-(IBAction)buttonPressed:(id)sender {
  
  UIViewController *presentedVC;
  if (sender == self.pvpButton) {
    presentedVC = self.matchVC;
  } else if (sender == self.pvcButton) {
    presentedVC = self.matchVC;
  } else if (sender == self.optionsButton) {
    presentedVC = self.optionsVC;
  } else if (sender == self.helpButton) {
    presentedVC = self.helpVC;
  }
  
  [self presentChildViewController:presentedVC];
}

#pragma mark - overlay methods

-(void)fadeOverlayIn:(BOOL)fadeIn {
  
  if (fadeIn) {
    CGFloat overlayAlpha = 0.5f;
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.darkOverlay];
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:overlayAlpha];
    } completion:^(BOOL finished) {
    }];
  } else {
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
      [self.darkOverlay removeFromSuperview];
    }];
  }
}

#pragma  mark - word logic delegate methods

-(void)populatePickerWordListArrayWithString:(NSString *)string {
  self.wordListArray = [string componentsSeparatedByString:@"\n"];
  [self.wordListPicker reloadAllComponents];
}

-(void)establishWordStatus:(WordStatus)wordStatus {
  self.myWordStatus = wordStatus;
}

@end
