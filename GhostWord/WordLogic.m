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

@property (strong, nonatomic) NSSet *wordListSet;

@end

@implementation WordLogic

-(id)init {
  self = [super init];
  if (self) {

  }
  
  return self;
}

#pragma mark - array word check methods

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord {

  for (NSString *listWord in self.wordListSet) {
    
      // if it's a complete word, return immediately
    if ([listWord isEqualToString:userWord]) {
      return listWord;
    }
  }

  return nil;
}

#pragma mark - generate word list methods

-(void)generateWordLists {
  
  NSError *error;
  NSString *wordListPath = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"txt"];
  NSString *wordListString = [NSString stringWithContentsOfFile:wordListPath encoding:NSUTF8StringEncoding error:&error];
  if (!error) {
    [self generateWordListArray:wordListString];
    [self.delegate populatePicker];
  } else {
    NSLog(@"Error: %@", error.localizedDescription);
  }
}

-(void)generateWordListArray:(NSString *)wordListString {
  self.wordListArray = [wordListString componentsSeparatedByString:@"\n"];
  self.wordListSet = [NSSet setWithArray:self.wordListArray];
}

@end
