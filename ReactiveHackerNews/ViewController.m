//
//  ViewController.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "ViewController.h"
#import "HNClient.h"
#import "CardView.h"
#import "UIView+Nib.h"
#import "ViewModel.h"
#import "StoryViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ZLSwipeableView/ZLSwipeableView.h>
#import <PureLayout/PureLayout.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>
@property (nonatomic, weak) IBOutlet ZLSwipeableView *swipeableView;
@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *topStories;
@property (nonatomic, weak) IBOutlet UIButton *refreshButton;
@property (nonatomic, weak) IBOutlet UIButton *aboutButton;
@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[ViewModel alloc] init];
    self.swipeableView.delegate = self;


    [[self.viewModel.refreshCommand.executing deliverOnMainThread] subscribeNext:^(id executing) {
        if ([executing boolValue]) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
    
    [[self.viewModel.refreshCommand.errors deliverOnMainThread] subscribeNext:^(NSError *error) {
        [SVProgressHUD dismiss];
        [SVProgressHUD showErrorWithStatus:@"Something wrong >_<"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        NSLog(@"error: %@", error);
    }];
    
    @weakify(self);
    [[[self.viewModel.refreshCommand.executionSignals flatten] deliverOnMainThread]
     subscribeNext:^(NSArray *response) {
         @strongify(self);
         
         NSMutableArray *result = [NSMutableArray array];
         for (NSNumber *storyId in response) {
             StoryViewModel *story = [[StoryViewModel alloc] initWithIdentity:storyId.integerValue];
             [result addObject:story];
         }
         
         self.topStories = result;
         
         [self reload];
    }];
    
    [self.viewModel.refreshCommand execute:nil];
    
    self.refreshButton.rac_command = self.viewModel.refreshCommand;
    [[self.aboutButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         @strongify(self);
         [self performSegueWithIdentifier:@"about" sender:nil];
    }];
    
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (NSUInteger) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.swipeableView.dataSource = self;

}

- (void) reload {
    [self.swipeableView discardAllSwipeableViews];
    [self.swipeableView loadNextSwipeableViewsIfNeeded];
}

- (UIView*)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    UIView *view = [[UIView alloc] initWithFrame:self.swipeableView.bounds];

    CardView *card = [CardView viewFromNib];
    card.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:card];
    [card autoPinEdgeToSuperviewMargin:ALEdgeLeft];
    [card autoPinEdgeToSuperviewMargin:ALEdgeRight];
    [card autoPinEdgeToSuperviewMargin:ALEdgeTop];
    [card autoPinEdgeToSuperviewMargin:ALEdgeBottom];

    StoryViewModel *story = self.topStories[0];
    [self.topStories removeObjectAtIndex:0];
    [card bindViewModel:story];
    
    return view;
}


- (void) swipeableView:(ZLSwipeableView *)swipeableView didSwipeRight:(UIView *)view {
    view.alpha = 0.8f;
}

- (void) swipeableView:(ZLSwipeableView *)swipeableView didSwipeLeft:(UIView *)view {
    view.alpha = 0.8f;
}

- (void) swipeableView:(ZLSwipeableView *)swipeableView didEndSwipingView:(UIView *)view atLocation:(CGPoint)location {
}

- (void) swipeableView:(ZLSwipeableView *)swipeableView didStartSwipingView:(UIView *)view atLocation:(CGPoint)location {
}

- (void) swipeableView:(ZLSwipeableView *)swipeableView swipingView:(UIView *)view atLocation:(CGPoint)location translation:(CGPoint)translation {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
