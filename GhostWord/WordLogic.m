//
//  WordLogic.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "WordLogic.h"
#import "LetterNode.h"

@interface WordLogic ()

//@property (nonatomic) WordStatus tempWordStatus;
@property (strong, nonatomic) NSArray *wordListArray;

@end

@implementation WordLogic

-(id)init {
  self = [super init];
  if (self) {
    self.pickerIndex = -1;
  }
  
  return self;
}

#pragma mark - array word check methods

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord {

  for (NSString *listWord in self.wordListArray) {
    
      // if it's a complete word, return immediately
    if ([listWord isEqualToString:userWord]) {
//      self.tempWordStatus = kCompleteWord;
      self.pickerIndex = [self.wordListArray indexOfObject:listWord];
      [self.delegate establishWordStatus:kCompleteWord];
      return listWord;
    }
  }

//  self.tempWordStatus = kNoPossibleWord;

    // without computer player, no possible word just means it's not a complete word
  [self.delegate establishWordStatus:kNoPossibleWord];
  return nil;
}

/*
#pragma mark - trie word check methods

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord {
  
    // somewhere in this recursive method, word status is established and stored in instance variable
  NSString *suggestedWord = [self matchString:userWord withParentNode:self.trieRootNode];
  [self.delegate establishWordStatus:self.tempWordStatus];
  self.tempWordStatus = kNeutralStatus;
  return suggestedWord;
}

-(NSString *)matchString:(NSString *)string withParentNode:(LetterNode *)parentNode {
  
    // no more string, so now it's either a legitimate word or not
  if (string.length == 0) {
    
    if (parentNode.lastLetterPickerIndex != -1) {
        // if it's already been established that it's an incomplete word, do not change it
      self.tempWordStatus = (self.tempWordStatus != kIncompleteWord) ? kCompleteWord : kIncompleteWord;
      self.pickerIndex = parentNode.lastLetterPickerIndex;
      return [NSString stringWithFormat:@"\n"];
      
    } else {
      self.tempWordStatus = kIncompleteWord;
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
    self.tempWordStatus = kNoPossibleWord;
    return nil;
  }
}
 */

#pragma mark - generate word list methods

-(void)generateWordLists {
  self.trieRootNode = [[LetterNode alloc] initWithLetter:'\n'];
  [self loadWordListData];
}

-(void)loadWordListData {
    // generate both the word list for the picker view and the word trie
  NSError *error;
  NSString *wordListPath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"txt"];
  NSString *wordListString = [NSString stringWithContentsOfFile:wordListPath encoding:NSUTF8StringEncoding error:&error];
  if (!error) {
//    [self generateWordTrieFromWordListString:wordListString];
    [self generateWordListArray:wordListString];
    [self.delegate populatePickerWordListArrayWithString:wordListString];
  } else {
    NSLog(@"Error: %@", error.localizedDescription);
  }
}

-(void)generateWordListArray:(NSString *)wordListString {
  self.wordListArray = [wordListString componentsSeparatedByString:@"\n"];
}

/*
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

#pragma mark - helper methods

-(NSString *)addChar:(unichar)myChar beforeString:(NSString *)myString {
  NSString *charString = [NSString stringWithFormat:@"%c", myChar];
  return [charString stringByAppendingString:myString];
}

-(NSString *)addChar:(unichar)myChar afterString:(NSString *)myString {
  NSString *charString = [NSString stringWithFormat:@"%c", myChar];
  return [myString stringByAppendingString:charString];
}
 */

@end
