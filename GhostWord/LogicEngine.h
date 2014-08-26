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
  kNeutralStatus,
  kCompleteWord,
  kNotCompleteWord
} WordStatus;

@protocol LogicDelegate;

@interface LogicEngine : NSObject

@property (weak, nonatomic) id<LogicDelegate> delegate;
@property (strong, nonatomic) NSArray *wordListArray;

-(NSString *)suggestCorrectWordForUserWord:(NSString *)userWord;
-(void)generateWordLists;

@end

@protocol LogicDelegate <NSObject>

@end