//
//  ViewController.m
//  EnergySavvySpellcheckChallenge
//
//  Created by Bennett Lin on 5/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MatchViewController.h"
#import "Constants.h"
#import "LogicEngine.h"
#import "Field.h"
#import "TileField.h"
#import "WordField.h"
#import "LetterTile.h"
#import "TurnEngine.h"

@interface MatchViewController () <LogicDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIPickerView *wordListPicker;

@property (strong, nonatomic) TurnEngine *turnEngine;
@property (strong, nonatomic) LogicEngine *logicEngine;
//@property (nonatomic) WordStatus myWordStatus;

@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *resignButton;

@property (strong, nonatomic) WordField *wordField;
@property (strong, nonatomic) TileField *tileField;
@property (strong, nonatomic) Field *gameOverField;

@property (strong, nonatomic) NSMutableArray *wordArray;

  // pointers
@property (strong, nonatomic) LetterTile *touchedTile;
@property (strong, nonatomic) LetterTile *recentTile;

  // bools
@property (nonatomic) BOOL challengeMode;

@end

@implementation MatchViewController

-(void)viewDidLoad {
  
  [super viewDidLoad];
  self.wordArray = [NSMutableArray new];
  [self loadViews];
}

-(void)preLoadModel {
  
  self.turnEngine = [TurnEngine new];
  
  self.logicEngine = [[LogicEngine alloc] init];
  self.logicEngine.delegate = self;
  [self.logicEngine generateWordLists];
  
  self.inputField.delegate = self;
  self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
  
  self.wordListPicker.delegate = self;
  self.wordListPicker.dataSource = self;
}

#pragma mark - load view methods

-(void)loadViews {
  
  CGRect rackRect = CGRectMake(0, self.view.bounds.size.height - kTileFieldHeight - kWordFieldHeight, self.view.bounds.size.width, kWordFieldHeight);
  self.wordField = [[WordField alloc] initWithFrame:rackRect];
  self.wordField.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.wordField];
  
  CGRect fieldRect = CGRectMake(0, self.view.bounds.size.height - kTileFieldHeight, self.view.bounds.size.width, kTileFieldHeight); // hard coded for now
  self.tileField = [[TileField alloc] initWithFrame:fieldRect];
  self.tileField.backgroundColor = [UIColor blueColor];
  [self.view addSubview:self.tileField];
  
  self.gameOverField = [[Field alloc] initWithFrame:fieldRect];
  self.gameOverField.backgroundColor = [UIColor purpleColor];
  self.gameOverField.hidden = YES;
  [self.view addSubview:self.gameOverField];
  
  for (int i = 0; i < 26; i++) {
    LetterTile *tile = [[LetterTile alloc] initWithChar:('a' + i)];
    [self.tileField addSubview:tile];
  }
}

#pragma mark - touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
  if (!self.touchedTile) {
    CGPoint locationPoint = [[touches anyObject] locationInView:self.view];
    UIView *touchedView = [self.view hitTest:locationPoint withEvent:event];

    if ([touchedView isKindOfClass:LetterTile.class]) {
      LetterTile *tile = (LetterTile *)touchedView;
      [tile beginTouch];
      CGPoint locationInField = [[touches anyObject] locationInView:self.tileField];
      tile.center = locationInField;
      [self.tileField addSubview:tile];
      self.touchedTile = tile;
    }
  }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.touchedTile) {
    CGPoint locationInField = [[touches anyObject] locationInView:self.tileField];
    self.touchedTile.center = locationInField;
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.touchedTile) {
    
      // in correct position in rack
    BOOL tileIsInWordField = (self.touchedTile.center.y < 0 &&
                              self.touchedTile.center.y > -kWordFieldHeight);
    if (tileIsInWordField) {
      
    } else {
      [self.touchedTile endTouch];
      [UIView animateWithDuration:kAnimationTime animations:^{
        self.touchedTile.center = self.touchedTile.homeCenter;
      }];
    }
    self.touchedTile = nil;
  }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

#pragma mark - text field delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField {
  NSLog(@"textField text is '%@'", textField.text);
  NSString *suggestedWord = [self.logicEngine suggestCorrectWordForUserWord:textField.text];
  [self showWordInPicker:suggestedWord];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.inputField resignFirstResponder];
  return YES;
}

#pragma mark - picker methods

-(void)showWordInPicker:(NSString *)suggestedWord {

  [self.wordListPicker selectRow:(suggestedWord ? [self.logicEngine.wordListArray indexOfObject:suggestedWord] : self.logicEngine.wordListArray.count) inComponent:0 animated:YES];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.logicEngine.wordListArray.count + 1;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return (row == self.logicEngine.wordListArray.count) ? @"(no suggestion)" : self.logicEngine.wordListArray[row];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 32.f;
}

#pragma mark - word logic delegate methods

-(void)populatePicker {
  [self.wordListPicker reloadAllComponents];
}

#pragma mark - button methods

-(IBAction)buttonPressed:(id)sender {
  if (sender == self.mainMenuButton) {
    [self.delegate backToMainMenu];
  } else if (sender == self.helpButton) {
    [self.delegate helpButtonPressed];
  } else if (sender == self.challengeButton) {
    
  } else if (sender == self.reverseButton) {
    
  } else if (sender == self.resignButton) {
  
  } else if (sender == self.doneButton) {
    
  }
}

@end
