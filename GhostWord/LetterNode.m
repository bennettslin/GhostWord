//
//  LetterNode.m
//  EnergySavvySpellcheckChallenge
//
//  Created by Bennett Lin on 5/14/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "LetterNode.h"

@implementation LetterNode {
  int nextLetters[2];
}

-(id)initWithLetter:(unichar)myLetter {
  self = [super init];
  if (self) {
    
    memset(nextLetters, 0, sizeof(nextLetters));
    self.myLetter = myLetter;
    
      // only last letter has picker index
    self.lastLetterPickerIndex = -1;
    self.nextLetterChildNodes = [[NSArray alloc] init];
  }
  
  return self;
}

-(LetterNode *)addChildNodeForNextLetter:(unichar)nextLetter {
  
  int index = (nextLetter - 'A') / 32;
  int shift = (nextLetter - 'A') % 32;
  
    // if this parent node already has a child node for the next letter
  if (nextLetters[index] & (1 << shift)) {
    
      // then return that child node
    return [self findChildNodeForNextLetter:nextLetter];
    
      // otherwise record it in 32-bit integer
  } else {
    nextLetters[index] |= (1 << shift);
    
      // and create new child node and return it
    LetterNode *nextLetterNode = [[LetterNode alloc] initWithLetter:nextLetter];
    [self addToNextLetterNodes:nextLetterNode];
    return nextLetterNode;
  }

  return nil;
}

-(LetterNode *)findChildNodeForNextLetter:(unichar)nextLetter {
  for (LetterNode *letterNode in self.nextLetterChildNodes) {
    if (letterNode.myLetter == nextLetter) {
      return letterNode;
    }
  }
  
  return nil;
}

-(BOOL)hasNextLetter:(unichar)thisLetter {
  
  int index = (thisLetter - 'A') / 32;
  int shift = (thisLetter - 'A') % 32;
  
  return (nextLetters[index] & (1 << shift));
}

-(void)addToNextLetterNodes:(LetterNode *)nextLetterNode {
  NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.nextLetterChildNodes];
  [tempArray addObject:nextLetterNode];
  self.nextLetterChildNodes = [NSArray arrayWithArray:tempArray];
}

@end
