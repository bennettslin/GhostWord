//
//  WordLogic.h
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LetterNode;

typedef enum wordStatus {
  kCompleteWord,
  kIncompleteWord,
  kNoPossibleWord,
  kNeutralStatus
} WordStatus;

@protocol WordLogicDelegate;

@interface WordLogic : NSObject

@property (strong, nonatomic) LetterNode *trieRootNode;
@property (weak, nonatomic) id<WordLogicDelegate> delegate;

  // while populating trie, this variable is used to increment...
  // afterwards, when searching through trie, this variable holds the picker view index
@property (nonatomic) NSInteger pickerIndex;

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord;
-(void)generateWordLists;

@end

@protocol WordLogicDelegate <NSObject>

-(void)populatePickerWordListArrayWithString:(NSString *)string;
-(void)establishWordStatus:(WordStatus)wordStatus;


@end