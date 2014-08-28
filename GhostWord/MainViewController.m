//
//  MatchViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MainViewController.h"
#import "StartNewGameViewController.h"
#import "HelpViewController.h"
#import "WonGameViewController.h"
#import "MatchViewController.h"
#import "Constants.h"

@interface MainViewController () <MatchDelegate, StartNewGameDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *startNewGameButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (strong, nonatomic) StartNewGameViewController *startNewGameVC;
@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) WonGameViewController *wonGameVC;

@property (strong, nonatomic) MatchViewController *matchVC;
@property (strong, nonatomic) UIViewController *childVC;

@property (weak, nonatomic) IBOutlet UILabel *titleLogo;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIButton *darkOverlay;
@property (nonatomic) BOOL overlayEnabled;
@property (nonatomic) BOOL vcIsAnimating;

@end

@implementation MainViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = kColourSlateBlue;
  
  self.titleLogo.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 72 : 144)];
  self.titleLogo.textColor = kColourLightTan;
  [self.titleLogo sizeToFit];
  self.titleLogo.center = CGPointMake(self.view.bounds.size.width / 2,
                                      self.titleLogo.frame.size.height);
  
  self.subtitleLabel = [[UILabel alloc] init];
  self.subtitleLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 24 : 48)];
  self.subtitleLabel.textColor = [kColourLightTan colorWithAlphaComponent:0.7f];
  self.subtitleLabel.text = @"classic word game";
  [self.subtitleLabel sizeToFit];
  CGPoint subtitleCenter = self.titleLogo.center;
  subtitleCenter.y = self.titleLogo.frame.size.height + self.subtitleLabel.frame.size.height * 1.5;
  self.subtitleLabel.center = subtitleCenter;
  [self.view addSubview:self.subtitleLabel];
  
  self.startNewGameButton.titleLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 48 : 96)];
  [self.startNewGameButton sizeToFit];
  self.startNewGameButton.center = CGPointMake(self.view.bounds.size.width / 2,
                                               self.view.bounds.size.height / 2 -
                                               self.startNewGameButton.frame.size.height / 2);
  
  
  self.helpButton.titleLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 36 : 72)];
  [self.helpButton sizeToFit];
  self.helpButton.center = CGPointMake(self.view.bounds.size.width / 2,
                                       self.view.bounds.size.height / 2 +
                                       self.helpButton.frame.size.height / 2);
  
  UILabel *copyrightLabel = [[UILabel alloc] init];
  copyrightLabel = [[UILabel alloc] init];
  copyrightLabel.font = [UIFont fontWithName:kFontModern size:(kIsIPhone ? 20 : 40)];
  copyrightLabel.textColor = [kColourLightTan colorWithAlphaComponent:0.7f];
  copyrightLabel.text = @"\u00A92014 Dogies Almondine";
  [copyrightLabel sizeToFit];

  copyrightLabel.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height - copyrightLabel.frame.size.height);
  [self.view addSubview:copyrightLabel];
  
  
  self.matchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"matchVC"];
  self.matchVC.delegate = self;
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"helpVC"];
  CGFloat helpHeight = self.view.bounds.size.height * kHelpHeightFactor;
  if (helpHeight < 568 * kHelpHeightFactor) {
    helpHeight = 568 * kHelpHeightFactor;
  }
  
  self.helpVC.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width * kHelpWidthFactor, helpHeight);
  self.helpVC.view.backgroundColor = kColourLightTan;
  
  self.startNewGameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
  
  CGFloat startGameHeight = self.view.bounds.size.height * kStartGameHeightFactor;
  if (startGameHeight < 568 * kStartGameHeightFactor) {
    startGameHeight = 568 * kStartGameHeightFactor;
  }
  
  self.startNewGameVC.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width * kStartGameWidthFactor, startGameHeight);
  self.startNewGameVC.view.backgroundColor = kColourSolidBlue;
  self.startNewGameVC.delegate = self;
  
  CGFloat wonGameHeight = self.view.bounds.size.height * kWonGameHeightFactor;
  if (wonGameHeight < 568 * kWonGameHeightFactor) {
    wonGameHeight = 568 * kWonGameHeightFactor;
  }
  
  self.wonGameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"wonGameVC"];
  self.wonGameVC.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width * kWonGameWidthFactor, wonGameHeight);
  self.wonGameVC.view.backgroundColor = kColourDarkTan;
  
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
  [self.darkOverlay addTarget:self action:@selector(fromDarkOverlayBackToMain) forControlEvents:UIControlEventTouchDown];
  
  self.vcIsAnimating = NO;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decideToPresentMatchVC) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeChildVCWithoutAnimation) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)decideToPresentMatchVC {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:@"word"]) {
    [self presentMatchViewController];
  }
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.matchVC preLoadModel];
  self.overlayEnabled = YES;
}

#pragma mark - view controller methods

-(void)fromDarkOverlayBackToMain {
  
  if (self.overlayEnabled) {
    [self removeChildVCWithoutAnimation];

  } else if (self.childVC == self.startNewGameVC) {
    [self.startNewGameVC resignTextField:nil];
  }
}

-(void)removeChildVCWithoutAnimation {
  if (self.childVC) {
    [self removeChildViewController:self.childVC];
    self.childVC = nil;
  }
  
  self.darkOverlay.superview ? [self.darkOverlay removeFromSuperview] : nil;
}

-(void)presentChildViewController:(UIViewController *)childVC {
  
  (self.childVC && self.childVC != childVC) ? [self removeChildViewController:self.childVC] : nil;
  self.childVC = childVC;
  
  if (![self.darkOverlay superview]) {
    [self fadeOverlayIn:YES];
  }
  
//  CGFloat viewWidth = self.view.bounds.size.width * 4 / 5;
//  CGFloat viewHeight = self.view.bounds.size.height * 4 / 5;
//  
//  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  childVC.view.layer.cornerRadius = kIsIPhone ? 20.f : 40.f;
  childVC.view.layer.masksToBounds = YES;
  
  [self.view addSubview:childVC.view];
  [self animatePresentVC:childVC];
}

-(void)animatePresentVC:(UIViewController *)childVC {
  self.vcIsAnimating = YES;
  childVC.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height);
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    childVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
    self.vcIsAnimating = NO;
  }];
}

-(void)removeChildViewController:(UIViewController *)childVC {
  
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    childVC.view.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height);
  } completion:^(BOOL finished) {
    [childVC.view removeFromSuperview];
  }];
  
  if (childVC == self.wonGameVC) {
    [self backToMainMenu];
  }
}

-(void)presentMatchViewController {
  
  if (self.childVC) {
    [self removeChildViewController:self.childVC];
    self.childVC = nil;
    [self fadeOverlayIn:NO];
  }
  
  self.vcIsAnimating = YES;
  self.matchVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.size.height);
  [self.view addSubview:self.matchVC.view];
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.matchVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
//    [self presentChildViewController:self.matchVC];
//    [self.matchVC didMoveToParentViewController:self];
    self.vcIsAnimating = NO;
  }];
}

#pragma mark - button methods

-(IBAction)buttonPressed:(id)sender {
  
  UIViewController *presentedVC;
  if (sender == self.startNewGameButton) {
    presentedVC = self.startNewGameVC;
  } else if (sender == self.helpButton) {
    presentedVC = self.helpVC;
  }

  [self presentChildViewController:presentedVC];
}

#pragma mark - match delegate methods

-(void)helpButtonPressed {
  [self presentChildViewController:self.helpVC];
}

-(void)showWonGameVCWithString:(NSString *)string numberOfLines:(NSUInteger)numberOfLines {
  [self.wonGameVC wonMessageLabelText:string numberOfLines:numberOfLines];
  [self presentChildViewController:self.wonGameVC];
}

-(void)backToMainMenu {
  self.vcIsAnimating = YES;
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.matchVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.size.height);
  } completion:^(BOOL finished) {
    [self.matchVC.view removeFromSuperview];
//    [self removeChildViewController:self.matchVC];
//    [self.matchVC removeFromParentViewController];
    self.vcIsAnimating = NO;
  }];
}

#pragma mark - overlay methods

-(void)fadeOverlayIn:(BOOL)fadeIn {
  
  if (fadeIn) {
    CGFloat overlayAlpha = 0.7f;
    self.darkOverlay.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.darkOverlay];
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:overlayAlpha];
    } completion:^(BOOL finished) {
    }];
  } else {
    [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.darkOverlay.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
      [self.darkOverlay removeFromSuperview];
    }];
  }
}

-(void)enableOverlay:(BOOL)enable {
  self.overlayEnabled = enable;
}

#pragma mark - action sheet methods

-(void)showResignActionSheet {
  UIActionSheet *resignActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to resign?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Resign" otherButtonTitles:nil, nil];
  [resignActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 0) {
    self.matchVC.gameEndedReason = kGameEndedResign;
    [self.matchVC handleWonGame];
  }
}

#pragma mark - system methods

-(BOOL)prefersStatusBarHidden {
  return YES;
}

@end
