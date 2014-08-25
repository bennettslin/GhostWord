//
//  LetterNode.h
//  EnergySavvySpellcheckChallenge
//
//  Created by Bennett Lin on 5/14/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LetterNode : NSObject

@property unichar myLetter;
@property (strong, nonatomic) NSMutableArray *nextLetterChildNodes;
@property NSUInteger lastLetterPickerIndex;

-(id)initWithLetter:(unichar)myLetter;
-(BOOL)hasNextLetter:(unichar)thisLetter;
-(LetterNode *)addChildNodeForNextLetter:(unichar)nextLetter;
-(LetterNode *)findChildNodeForNextLetter:(unichar)nextLetter;

@end
