//
//  Constants.h
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#ifndef GhostWord_Constants_h
#define GhostWord_Constants_h

#define kIsIPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define kFontModern @"FilmotypeModern"

#define kHelpWidthFactor 0.8f
#define kHelpHeightFactor (kIsIPhone ? 0.7f : 0.65f)
#define kStartGameWidthFactor 0.8f
#define kStartGameHeightFactor 0.8f
#define kWonGameWidthFactor 0.8f
#define kWonGameHeightFactor 0.5f

#define kTileWidth (kIsIPhone ? 40.f : 72.f)
#define kTileHeight (kIsIPhone ? 50.f : 90.f)
#define kTouchScaleFactor 1.5

#define kTileFieldHeight (kTileHeight * 1.1 * 4 + kTileHeight * 1.1)
#define kWordFieldHeight (kTileFieldHeight / 2)

#define kAnimationTime 0.2f

#define kColourSolidBlue [UIColor colorWithRed:19/255.f green:94/255.f blue:204/255.f alpha:1]
#define kColourLightBlue [UIColor colorWithRed:49/255.f green:191/255.f blue:255/255.f alpha:1]
#define kColourSlateBlue [UIColor colorWithRed:90/255.f green:100/255.f blue:153/255.f alpha:1]
#define kColourLightTan [UIColor colorWithRed:255/255.f green:169/255.f blue:113/255.f alpha:1]
#define kColourDarkTan [UIColor colorWithRed:204/255.f green:65/255.f blue:19/255.f alpha:1]
#define kColourMatchDarkTan [UIColor colorWithRed:77/255.f green:53/255.f blue:38/255.f alpha:1]

#define kTileNormalColour kColourLightBlue
#define kTileTouchedColour kColourSlateBlue

#define kPlaceholder1Name @"Player 1"
#define kPlaceholder2Name @"Player 2"

#define kPlayer1Key @"player1Name"
#define kPlayer2Key @"player2Name"

typedef enum gameRules {
  kRulesGhost,
  kRulesSuper,
  kRulesDuper
} GameRules;

typedef enum player {
  kPlayer1,
  kPlayer2
} Player;

typedef enum gameEndedReason {
  kGameNotEnded,
  kGameEndedResign,
  kGameChallengedPlayerWon,
  kGameChallengedPlayerLost,
  kGameChallengedWordIsAlreadyWord
} GameEndedReason;

#endif
