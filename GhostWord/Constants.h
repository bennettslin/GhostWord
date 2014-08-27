//
//  Constants.h
//  GhostWord
//
//  Created by Bennett Lin on 8/25/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#ifndef GhostWord_Constants_h
#define GhostWord_Constants_h

#define kFontModern @"FilmotypeModern"

#define kTileWidth 40
#define kTileHeight 50
#define kTouchScaleFactor 1.5

#define kTileFieldHeight (kTileHeight * 1.1 * 4)
#define kWordFieldHeight (kTileFieldHeight / 2)

#define kAnimationTime 0.2f

#define kTileNormalColour [UIColor cyanColor]
#define kTileTouchedColour [UIColor yellowColor]

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

#endif
