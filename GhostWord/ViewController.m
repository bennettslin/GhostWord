//
//  ViewController.m
//  EnergySavvySpellcheck
//
//  Created by Bennett Lin on 5/12/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "ViewController.h"
#import "LetterNode.h"

typedef enum wordStatus {
  kCompleteWord,
  kIncompleteWord,
  kNoPossibleWord,
  kNeutralStatus
} WordStatus;

@interface ViewController () <NSURLSessionDataDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *wordListArray;
@property (strong, nonatomic) LetterNode *trieRootNode;
@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UIPickerView *wordListPicker;

  // while populating trie, this variable is used to increment
  // when searching through trie, this variable holds the picker view index
@property (nonatomic) NSInteger pickerIndex;
@property (nonatomic) WordStatus wordStatus;

@end

@implementation ViewController

-(void)viewDidLoad {
  [super viewDidLoad];

  self.trieRootNode = [[LetterNode alloc] initWithLetter:'\n'];

    // get word list data from AteBits text file
  [self loadWordListData];
  
  self.pickerIndex = -1;
  
  self.inputField.delegate = self;
  self.inputField.clearButtonMode = UITextFieldViewModeWhileEditing;

  self.wordListPicker.delegate = self;
  self.wordListPicker.dataSource = self;
}

#pragma mark - word check methods

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord {
  NSString *suggestedWord = [self matchString:userWord withParentNode:self.trieRootNode];
  [self handleWordStatus];
  return suggestedWord;
}

-(NSString *)matchString:(NSString *)string withParentNode:(LetterNode *)parentNode {
  
    // no more string, so now it's either a legitimate word or not
  if (string.length == 0) {
    
    if (parentNode.lastLetterPickerIndex != -1) {
        // if it's already been established that it's an incomplete word, do not change it
      self.wordStatus = (self.wordStatus != kIncompleteWord) ? kCompleteWord : kIncompleteWord;
      self.pickerIndex = parentNode.lastLetterPickerIndex;
      return [NSString stringWithFormat:@"\n"];

    } else {
      self.wordStatus = kIncompleteWord;
      self.pickerIndex = -1;
      NSUInteger randomIndex = arc4random() % parentNode.nextLetterChildNodes.count;
      LetterNode *nextNode = [parentNode.nextLetterChildNodes objectAtIndex:randomIndex];
      string = [self addChar:nextNode.myLetter afterString:string];
    }
  }
  
  NSString *returnedSubstring;
  
    // first priority is that letter matches exactly
  returnedSubstring = [self matchFirstLetterOfString:string withParentNode:parentNode];
  return returnedSubstring; // may be nil
}

-(NSString *)matchFirstLetterOfString:(NSString *)string withParentNode:(LetterNode *)parentNode {
  
  unichar baseChar = [string characterAtIndex:0];
  unichar nextChar = baseChar;
  
  if ([parentNode hasNextLetter:nextChar]) {
    LetterNode *childNode = [parentNode findChildNodeForNextLetter:nextChar];
    NSString *returnedSubstring = [self matchString:[string substringFromIndex:1] withParentNode:childNode];
    return returnedSubstring ? [self addChar:nextChar beforeString:returnedSubstring] : nil;
  } else {
    self.wordStatus = kNoPossibleWord;
    return nil;
  }
}

-(void)handleWordStatus {
  NSLog(@"word status is %i", self.wordStatus);
  
    // reset word status
  self.wordStatus = kNeutralStatus;
}


#pragma mark - word list and trie methods

-(void)loadWordListData {
    // generate both the word list for the picker view and the word trie
  NSError *error;
  NSString *wordListPath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"txt"];
  NSString *wordListString = [NSString stringWithContentsOfFile:wordListPath encoding:NSUTF8StringEncoding error:&error];
  if (!error) {
    [self generateWordTrieFromWordListString:wordListString];
    self.wordListArray = [wordListString componentsSeparatedByString:@"\n"];
    [self.wordListPicker reloadAllComponents];
  } else {
    NSLog(@"Error: %@", error.localizedDescription);
  }
}

-(void)generateWordTrieFromWordListString:(NSString *)wordListString {

  int i = 0;
  unichar myCurrentChar;
  LetterNode *myCurrentNode;
  
  while (i < wordListString.length) {
  
    myCurrentChar = [wordListString characterAtIndex:i];
    
        // if it's the word's first letter, start back at trie root node
    if (!myCurrentNode) {
      myCurrentNode = [self.trieRootNode addChildNodeForNextLetter:myCurrentChar];
      
        // if it's a subsequent letter, add letterNode to currentNode
        // and make that the new currentNode
    } else if (myCurrentNode && myCurrentChar != '\n') {
      myCurrentNode = [myCurrentNode addChildNodeForNextLetter:myCurrentChar];
    
        // if sentinel is reached, word is finished and currentNode is reset
    } else {
      self.pickerIndex++;
      myCurrentNode.lastLetterPickerIndex = self.pickerIndex;
      myCurrentNode = nil;
    }

    i++;
  }
}

#pragma mark - text field delegate methods

-(void)textFieldDidEndEditing:(UITextField *)textField {
  NSString *suggestedWord = [self suggestCorrectWordForUserWord:textField.text];
  [self showWordInPicker:suggestedWord];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
  [self.inputField resignFirstResponder];
  return YES;
}

#pragma mark - picker methods

-(void)showWordInPicker:(NSString *)suggestedWord {

  [self.wordListPicker selectRow:(suggestedWord ? self.pickerIndex : 0) inComponent:0 animated:YES];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
  return self.wordListArray.count + 1;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
  return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
  return (row == 0) ? @"(no suggestion)" : self.wordListArray[row - 1];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
  return 32.f;
}

#pragma mark - helper methods

-(NSString *)addChar:(unichar)myChar beforeString:(NSString *)myString {
  NSString *charString = [NSString stringWithFormat:@"%c", myChar];
  return [charString stringByAppendingString:myString];
}

-(NSString *)addChar:(unichar)myChar afterString:(NSString *)myString {
  NSString *charString = [NSString stringWithFormat:@"%c", myChar];
  return [myString stringByAppendingString:charString];
}

@end
