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

typedef enum gameEndedReason {
  kGameNotEnded,
  kGameEndedResign,
  kGameChallengedPlayerWon,
  kGameChallengedPlayerLost,
  kGameChallengedWordIsAlreadyWord
} GameEndedReason;

@interface MatchViewController () <LogicDelegate, TurnEngineDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) TurnEngine *turnEngine;
@property (strong, nonatomic) LogicEngine *logicEngine;

@property (weak, nonatomic) IBOutlet UIButton *mainMenuButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (weak, nonatomic) IBOutlet UIButton *undoButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseButton;
@property (weak, nonatomic) IBOutlet UIButton *challengeButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *resignButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) WordField *wordField;
@property (strong, nonatomic) TileField *tileField;
@property (strong, nonatomic) Field *gameOverField;

@property (strong, nonatomic) NSMutableArray *wordArray;

  // pointers
@property (strong, nonatomic) LetterTile *touchedTile;
@property (strong, nonatomic) LetterTile *recentTile;
@property (strong, nonatomic) NSUserDefaults *defaults;

  // bools
@property (nonatomic) GameEndedReason gameEndedReason;

@end

@implementation MatchViewController

-(void)viewDidLoad {
  
  [super viewDidLoad];
  if (!self.wordArray) {
    self.wordArray = [NSMutableArray new];
    self.defaults = [NSUserDefaults standardUserDefaults];
  }
  [self loadViews];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveGame) name:UIApplicationDidEnterBackgroundNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveGame) name:UIApplicationWillTerminateNotification object:nil];
}

-(void)preLoadModel {
  
  if (!self.turnEngine) {
    self.turnEngine = [TurnEngine new];
    self.turnEngine.delegate = self;
  }
  
  if (!self.logicEngine) {
    self.logicEngine = [[LogicEngine alloc] init];
    self.logicEngine.delegate = self;
    [self.logicEngine generateWordLists];
  }
}

-(void)loadViews {
  
  CGRect rackRect = CGRectMake(0, self.view.bounds.size.height - kTileFieldHeight - kWordFieldHeight, self.view.bounds.size.width, kWordFieldHeight);
  self.wordField = [[WordField alloc] initWithFrame:rackRect];
  self.wordField.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.wordField];
  
  CGRect fieldRect = CGRectMake(0, self.view.bounds.size.height - kTileFieldHeight - kWordFieldHeight, self.view.bounds.size.width, kTileFieldHeight + kWordFieldHeight); // hard coded for now
  self.tileField = [[TileField alloc] initWithFrame:fieldRect];
  self.tileField.backgroundColor = [UIColor blueColor];
  [self.view addSubview:self.tileField];
  
  self.gameOverField = [[Field alloc] initWithFrame:fieldRect];
  self.gameOverField.backgroundColor = [UIColor purpleColor];
  self.gameOverField.hidden = YES;
  [self.view addSubview:self.gameOverField];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.turnEngine handleWhetherToStartOrContinueGame];
  self.gameEndedReason = kGameNotEnded;
  
  [self updateButtons];
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  [self.wordArray removeAllObjects];
  
  for (LetterTile *tile in self.tileField.subviews) {
    [tile removeFromSuperview];
  }
  
  [self.turnEngine saveTurnData];
}

-(void)setupNewKeyboard {
  for (int i = 0; i < 26; i++) {
    [self addNewLetterTileForChar:'a' + i];
  }
}

-(void)setupWordFieldForSavedGame {
  [self.wordArray removeAllObjects];
  for (int i = 0; i < self.turnEngine.currentWord.length; i++) {
    unichar myChar = [self.turnEngine.currentWord characterAtIndex:i];
    LetterTile *tile = [self addNewLetterTileForChar:myChar];
    [tile finalise];
    [self.wordArray addObject:tile];
  }
  [self repositionWordArrayTiles];
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
    
      // touched tile moved to wordField
    if ([self touchedTileIsInWordField]) {
      if (self.recentTile && self.touchedTile != self.recentTile) {
        [self sendTileHome:self.recentTile];
        self.recentTile = nil;
      }
      [self addToWordArrayTile:self.touchedTile];
      
      // touched tile out of wordField
    } else {
      [self removeFromWordArrayTile:self.touchedTile];
    }
  }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.touchedTile) {
    
    [self.touchedTile endTouch];
    if ([self touchedTileIsInWordField] && self.wordArray.count <= 28) {
      
      self.recentTile = self.touchedTile;
      
      [self addToWordArrayTile:self.recentTile];
      [self sendTileToWordField:self.recentTile];
      
    } else {
      if (self.wordArray.count > 28) {
        [self removeFromWordArrayTile:self.touchedTile];
      }
      [self sendTileHome:self.touchedTile];
    }
    self.touchedTile = nil;
  }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}

-(BOOL)touchedTileIsInWordField {
  return (self.touchedTile.center.y > 0 && self.touchedTile.center.y < kWordFieldHeight);
}

#pragma mark - word array methods

-(void)removeFromWordArrayTile:(LetterTile *)tile {
  if ([self.wordArray containsObject:tile]) {
    [self.wordArray removeObject:tile];
    [self repositionWordArrayTiles];
  }
  
  [self updateButtons];
}

-(void)addToWordArrayTile:(LetterTile *)tile {
    
    // add to front
  if (tile.center.x < (self.view.bounds.size.width / 2) &&
      [self.defaults integerForKey:@"rules"] != kRulesGhost) {
    
      // if last object, first remove
    if (tile == [self.wordArray lastObject]) {
      [self.wordArray removeObject:tile];
    }
    
    if (![self.wordArray containsObject:tile]) {
      [self.wordArray insertObject:tile atIndex:0];
    }
    
      // add to back
  } else {
    
      // if first object, first remove
    if (tile == [self.wordArray firstObject]) {
      [self.wordArray removeObject:tile];
    }
    
    if (![self.wordArray containsObject:tile]) {
      [self.wordArray addObject:tile];
    }
  }
  
  [self repositionWordArrayTiles];
  [self updateButtons];
}

-(NSString *)wordFromWordArray {
  NSString *string = @"";
  for (int i = 0; i < self.wordArray.count; i++) {
    LetterTile *tile = self.wordArray[i];
    if (tile != self.recentTile) {
      string = [string stringByAppendingString:tile.text];
    }
  }
  return string;
}

#pragma mark - tile movement and placement methods

-(LetterTile *)addNewLetterTileForChar:(unichar)myChar {
  int i = myChar - 'a';
  LetterTile *tile = [[LetterTile alloc] initWithChar:myChar];
  tile.homeCenter = CGPointMake((self.view.bounds.size.width - (kTileWidth * 1.1 * 7)) / 2 + ((i % 7) + (i < 21 ? 0.5 : 1.5)) * (kTileWidth * 1.1), ((i / 7) + 0.5) * (kTileHeight * 1.1) + kWordFieldHeight);
  CGRect bounds = tile.bounds;
  tile.bounds = CGRectZero;
  tile.center = tile.homeCenter;
  [self.tileField addSubview:tile];
  [UIView animateWithDuration:kAnimationTime animations:^{
    tile.bounds = bounds;
  }];
  return tile;
}

-(void)sendTileToWordField:(LetterTile *)tile {
  
  if (tile == self.touchedTile) {
    self.touchedTile = nil;
  }
  
//     should be positioned naturally by repositionMethod
  [UIView animateWithDuration:kAnimationTime animations:^{
    tile.center = tile.wordFieldCenter;
  }];
  
  if (tile == self.recentTile && self.turnEngine.challengeMode) {
    [self.recentTile finalise];
    [self addNewLetterTileForChar:self.recentTile.myChar];
    self.recentTile = nil;
    [self repositionWordArrayTiles];
  }
}

-(void)sendTileHome:(LetterTile *)tile {
  [tile resetFrameAndFont];
  
  if (tile == self.recentTile) {
    [self removeFromWordArrayTile:self.recentTile];
    self.recentTile = nil;
  }
  
  if (tile == self.touchedTile) {
    self.touchedTile = nil;
    [self updateButtons];
  }
  
  [UIView animateWithDuration:kAnimationTime animations:^{
    tile.center = tile.homeCenter;
  }];
}

-(void)repositionWordArrayTiles {
    // gets called whenever wordArray is changed

  if (self.wordArray.count > 0) {
    
    BOOL needsToShrink = kTileWidth * 1.1 * self.wordArray.count + (self.recentTile ? 1 : 2) > self.view.bounds.size.width - kTileWidth * 1.1;
    
    for (int i = 0; i < self.wordArray.count; i++) {
      LetterTile *tile = self.wordArray[i];

      if (needsToShrink) {
        CGFloat tileWidth = ((self.view.bounds.size.width - kTileWidth) / self.wordArray.count);
        if (tile != self.touchedTile && tile != self.recentTile) {
          CGRect newFrame = tile.frame;
          newFrame.size.width = tileWidth * 1.1;
          tile.frame = newFrame;
          tile.font = [UIFont fontWithName:kFontModern size:(tileWidth + kTileWidth) / 2];
          tile.layer.cornerRadius = tileWidth / 4;
          tile.wordFieldCenter = CGPointMake(((i + 0.5) * tileWidth) + kTileWidth / 2, kWordFieldHeight / 2);
          
            // tile is recentTile
        } else {
          if (tile == [self.wordArray firstObject]) {
          tile.wordFieldCenter = CGPointMake(((i + 0.5) * tileWidth) + kTileWidth / 2 - (kTileWidth - tileWidth) / 2, kWordFieldHeight / 2);
          } else if (tile == [self.wordArray lastObject]) {
          tile.wordFieldCenter = CGPointMake(((i + 0.5) * tileWidth) + kTileWidth / 2 + (kTileWidth - tileWidth) / 2, kWordFieldHeight / 2);
          }
        }
        
      } else {
        if (tile != self.touchedTile && tile != self.recentTile) {
          CGRect newFrame = tile.frame;
          newFrame.size.width = kTileWidth;
          tile.frame = newFrame;
          tile.font = [UIFont fontWithName:kFontModern size:kTileWidth];
          tile.layer.cornerRadius = kTileWidth / 4;
        }
        tile.wordFieldCenter = CGPointMake(((self.view.bounds.size.width - kTileWidth * 1.1) - (kTileWidth * 1.1 * self.wordArray.count)) / 2 + ((i + 1) * kTileWidth * 1.1), kWordFieldHeight / 2);
      }
      
      if (tile != self.touchedTile && !CGPointEqualToPoint(tile.center, tile.wordFieldCenter)) {
        [self sendTileToWordField:tile];
      }
    }
  }
}

-(void)handleWordReverse {
  if (self.wordArray.count > 0) {
    NSUInteger frontIndex = 0;
    NSUInteger backIndex = self.wordArray.count - 1;
    while (frontIndex < backIndex) {
      [self.wordArray exchangeObjectAtIndex:frontIndex withObjectAtIndex:backIndex];
      frontIndex++;
      backIndex--;
    }
    [self repositionWordArrayTiles];
  }
}

-(void)handleUndo {
  for (LetterTile *tile in self.wordArray) {
    [tile removeFromSuperview];
  }
  
  [self setupWordFieldForSavedGame];
}

#pragma mark - turn methods

-(void)handleWordAlreadyCompleteChallenge {
  if ([self.logicEngine suggestCorrectWordForUserWord:[self wordFromWordArray]]) {
    self.gameEndedReason = kGameChallengedWordIsAlreadyWord;
    [self handleWonGame];
  } else {
    [self.turnEngine handleCompletionOfTurn];
  }
}

-(void)handleTurnDone {
  
  [self.recentTile finalise];
  [self addNewLetterTileForChar:self.recentTile.myChar];
  if (self.recentTile) {
    self.recentTile = nil;
  }
  
  [self.turnEngine handleCompletionOfTurn];
  [self repositionWordArrayTiles];
}

-(void)handleChallengeTurnDone {
  
    // might not be necessary in challenge mode
  [self.recentTile finalise];
  [self addNewLetterTileForChar:self.recentTile.myChar];
  if (self.recentTile) {
    self.recentTile = nil;
  }
  
  if ([self.logicEngine suggestCorrectWordForUserWord:[self wordFromWordArray]]) {
    self.gameEndedReason = kGameChallengedPlayerWon;
  } else {
    self.gameEndedReason = kGameChallengedPlayerLost;
  }
  
  [self handleWonGame];
}

-(void)updateMessageLabel {
  NSString *playerName = (self.turnEngine.currentPlayer == kPlayer1) ?
      [self.defaults objectForKey:kPlayer1Key] : [self.defaults objectForKey:kPlayer2Key];
  self.messageLabel.text = !self.turnEngine.challengeMode ?
  [NSString stringWithFormat:@"%@, it's your turn!", playerName] :
  [NSString stringWithFormat:@"%@, you've been challenged!", playerName];
}

-(void)handleWonGame {
  [self.turnEngine handleEndOfGame];
  
  NSString *playerName;
  NSString *messageString = @"";
  switch (self.gameEndedReason) {
    case kGameEndedResign:
      playerName = (self.turnEngine.currentPlayer == kPlayer1) ?
      [self.defaults objectForKey:kPlayer2Key] : [self.defaults objectForKey:kPlayer1Key];
      messageString = [NSString stringWithFormat:@"%@ won!", playerName];
      break;
    case kGameChallengedPlayerWon:
      playerName = (self.turnEngine.currentPlayer == kPlayer1) ?
      [self.defaults objectForKey:kPlayer1Key] : [self.defaults objectForKey:kPlayer2Key];
      messageString = [NSString stringWithFormat:@"%@ won!\n'%@' is a word.", playerName, [self wordFromWordArray]];
      break;
    case kGameChallengedPlayerLost:
      playerName = (self.turnEngine.currentPlayer == kPlayer1) ?
      [self.defaults objectForKey:kPlayer2Key] : [self.defaults objectForKey:kPlayer1Key];
      messageString = [NSString stringWithFormat:@"%@ won!\n'%@' is not a word.", playerName, [self wordFromWordArray]];
      break;
    case kGameChallengedWordIsAlreadyWord:
      playerName = (self.turnEngine.currentPlayer == kPlayer1) ?
      [self.defaults objectForKey:kPlayer1Key] : [self.defaults objectForKey:kPlayer2Key];
      messageString = [NSString stringWithFormat:@"%@ won!\n'%@' is a word.", playerName, [self wordFromWordArray]];
      break;
    default:
      break;
  }
  
  [self.delegate showWonGameVCWithString:messageString];
}

#pragma mark - button methods

-(IBAction)buttonPressed:(id)sender {
  if (sender == self.mainMenuButton) {
      // this will eventually be disabled
    [self.turnEngine saveTurnData];
    [self.delegate backToMainMenu];
  } else if (sender == self.helpButton) {
    [self.delegate helpButtonPressed];
  } else if (sender == self.challengeButton) {
    if (!self.recentTile) {
      self.turnEngine.challengeMode = YES;
      [self handleWordAlreadyCompleteChallenge];
    }
  } else if (sender == self.reverseButton) {
    [self handleWordReverse];
  } else if (sender == self.resignButton) {
    [self showResignActionSheet];
  } else if (sender == self.undoButton) {
    [self handleUndo];
  } else if (sender == self.doneButton) {
    if (self.turnEngine.challengeMode) {
      [self handleChallengeTurnDone];
    }
    
    if (self.recentTile) {
      [self handleTurnDone];
    }
    
  } else if (sender == self.testButton) {
    [self testButtonPressed];
  }
}

-(void)updateButtons {
  
  self.mainMenuButton.hidden = YES;
  self.mainMenuButton.enabled = NO;
  
  NSUInteger minimumChallenge = [self.defaults integerForKey:@"minimumLetters"] + 3;
  self.challengeButton.enabled = !self.turnEngine.challengeMode &&
      !self.recentTile && !self.touchedTile && self.wordArray.count >= minimumChallenge;
  self.challengeButton.hidden = self.turnEngine.challengeMode;
  
  self.doneButton.enabled = self.recentTile || self.turnEngine.challengeMode;
  
  self.reverseButton.hidden = [self.defaults integerForKey:@"rules"] != kRulesDuper;
  self.reverseButton.enabled = [self.defaults integerForKey:@"rules"] == kRulesDuper && self.wordArray.count > 1;
  
  self.undoButton.enabled = self.turnEngine.challengeMode;
  self.undoButton.hidden = !self.turnEngine.challengeMode;
}

#pragma mark - actionSheet methods

-(void)showResignActionSheet {
  UIActionSheet *resignActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to resign?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Resign" otherButtonTitles:nil, nil];
  [resignActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    self.gameEndedReason = kGameEndedResign;
    [self handleWonGame];
  }
}

-(void)testButtonPressed {
  NSLog(@"string is %@", [self wordFromWordArray]);
}

#pragma mark - system methods

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  [self saveGame];
}

-(void)saveGame {
  [self.turnEngine saveTurnData];
}

-(BOOL)prefersStatusBarHidden {
  return YES;
}

@end
