//
//  ViewController.m
//  EnergySavvySpellcheckChallenge
//
//  Created by Bennett Lin on 5/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ViewController.h"
#import "WordLogic.h"

@interface ViewController () <WordLogicDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIPickerView *wordListPicker;

@property (strong, nonatomic) NSArray *wordListArray;
@property (strong, nonatomic) WordLogic *logicEngine;
@property (nonatomic) WordStatus myWordStatus;

@end

@implementation ViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.logicEngine = [[WordLogic alloc] init];
  self.logicEngine.delegate = self;
  [self.logicEngine generateWordLists];
  
  self.inputField.delegate = self;
  self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;

  self.wordListPicker.delegate = self;
  self.wordListPicker.dataSource = self;
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

  [self.wordListPicker selectRow:(suggestedWord ? self.logicEngine.pickerIndex : 0) inComponent:0 animated:YES];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.wordListArray.count + 1;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return (row == 0) ? @"(no suggestion)" : self.wordListArray[row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 32.f;
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
