//
//  MatchViewController.m
//  GhostWord
//
//  Created by Bennett Lin on 8/24/14.
//  Copyright (c) 2014 Bennett Lin. All rights reserved.
//

#import "MainViewController.h"
#import "OptionsViewController.h"
#import "HelpViewController.h"
#import "MatchViewController.h"
#import "Constants.h"

@interface MainViewController () <MatchDelegate, OptionsDelegate>

@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;
@property (weak, nonatomic) IBOutlet UIButton *pvpButton;

@property (strong, nonatomic) OptionsViewController *optionsVC;
@property (strong, nonatomic) HelpViewController *helpVC;
@property (strong, nonatomic) MatchViewController *matchVC;
@property (strong, nonatomic) UIViewController *childVC;

@property (weak, nonatomic) IBOutlet UILabel *titleLogo;
@property (strong, nonatomic) UIButton *darkOverlay;
@property (nonatomic) BOOL overlayEnabled;
@property (nonatomic) BOOL vcIsAnimating;

@end

@implementation MainViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor brownColor];

  self.titleLogo.font = [UIFont fontWithName:kFontModern size:24];
  
  self.matchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"matchVC"];
  self.matchVC.delegate = self;
  
  self.helpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"helpVC"];
  self.helpVC.view.backgroundColor = [UIColor purpleColor];
  
  self.optionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"optionsVC"];
  self.optionsVC.view.backgroundColor = [UIColor blueColor];
  self.optionsVC.delegate = self;
  
  self.darkOverlay = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
  [self.darkOverlay addTarget:self action:@selector(backToMain) forControlEvents:UIControlEventTouchDown];
  
  self.vcIsAnimating = NO;
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.matchVC preLoadModel];
  self.overlayEnabled = YES;
}

#pragma mark - view controller methods

-(void)backToMain {
  
  if (self.overlayEnabled) {
    
    if (self.childVC) {
      [self removeChildViewController:self.childVC];
      self.childVC = nil;
    }
    
    self.darkOverlay.superview ? [self fadeOverlayIn:NO] : nil;
  } else if (self.childVC == self.optionsVC) {
    [self.optionsVC resignTextField:nil];
  }
}

-(void)presentChildViewController:(UIViewController *)childVC {
  
  (self.childVC && self.childVC != childVC) ? [self removeChildViewController:self.childVC] : nil;
  self.childVC = childVC;
  
  if (![self.darkOverlay superview]) {
    [self fadeOverlayIn:YES];
  }
  
  CGFloat viewWidth = self.view.bounds.size.width * 4 / 5;
  CGFloat viewHeight = self.view.bounds.size.height * 3 / 5;
  
  childVC.view.frame = CGRectMake(0, 0, viewWidth, viewHeight);
  childVC.view.layer.cornerRadius = 20.f;
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
}

-(void)presentMatchViewController {
  self.vcIsAnimating = YES;
  self.matchVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.size.height);
  [self.view addSubview:self.matchVC.view];
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.matchVC.view.center = self.view.center;
  } completion:^(BOOL finished) {
    self.vcIsAnimating = NO;
  }];
}

#pragma mark - button methods

-(IBAction)buttonPressed:(id)sender {
  
  UIViewController *presentedVC;
  if (sender == self.pvpButton) {
    presentedVC = self.matchVC;
  } else if (sender == self.optionsButton) {
    presentedVC = self.optionsVC;
  } else if (sender == self.helpButton) {
    presentedVC = self.helpVC;
  }
  
  (presentedVC == self.matchVC) ?
  [self presentMatchViewController] : // eventually change this to real segue
  [self presentChildViewController:presentedVC];
}

#pragma mark - match delegate methods

-(void)helpButtonPressed {
  [self presentChildViewController:self.helpVC];
}

-(void)backToMainMenu {
  self.vcIsAnimating = YES;
  [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.matchVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - self.view.bounds.size.height);
  } completion:^(BOOL finished) {
    [self.matchVC.view removeFromSuperview];
    self.vcIsAnimating = NO;
  }];
}

#pragma mark - overlay methods

-(void)fadeOverlayIn:(BOOL)fadeIn {
  
  if (fadeIn) {
    CGFloat overlayAlpha = 0.5f;
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

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
