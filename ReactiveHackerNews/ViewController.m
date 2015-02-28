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
#import "StoryViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/UIAlertView+RACSignalSupport.h>
#import <ZLSwipeableView/ZLSwipeableView.h>
#import <PureLayout/PureLayout.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <POP/POP.h>

@interface ViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>
@property (nonatomic, weak) IBOutlet ZLSwipeableView *swipeableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) ViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *topStories;
@property (nonatomic, weak) IBOutlet UIButton *refreshButton;
@property (nonatomic, weak) IBOutlet UIButton *aboutButton;
@property (nonatomic, strong) NSString *selectedUrlString;
@property (nonatomic, weak) IBOutlet UILabel *doneLabel;
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
    
    @weakify(self);
    [[self.viewModel.refreshCommand.errors deliverOnMainThread] subscribeNext:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Something wrong! >_<" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles:nil];
        [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
            @strongify(self);
            [self reload];
        }];
        [alert show];
        NSLog(@"error: %@", error);
    }];
    
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

    self.topConstraint.constant = CGRectGetHeight(self.view.frame) / 7;
    self.bottomConstraint.constant = CGRectGetHeight(self.view.frame) / 7;
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
    [card autoCenterInSuperview];
    
    CGFloat width = CGRectGetWidth(self.swipeableView.frame);
    CGFloat height = CGRectGetHeight(self.swipeableView.frame);
    [card autoSetDimension:ALDimensionHeight toSize:height];
    [card autoSetDimension:ALDimensionWidth toSize:width];
    
    if (self.topStories.count == 0)
        return nil;
    
    StoryViewModel *story = [self.topStories firstObject];
    [self.topStories removeObjectAtIndex:0];
    [card bindViewModel:story];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
    @weakify(self);
    [[tap rac_gestureSignal] subscribeNext:^(UITapGestureRecognizer *gesture) {
        @strongify(self);
        UIView *tapview = gesture.view;
        CardView *cardView = tapview.subviews[0];
        if (cardView.viewModel.url && cardView.viewModel.url.length) {
            self.selectedUrlString = cardView.viewModel.url;
        } else {
            self.selectedUrlString = [NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%d", (int)cardView.viewModel.itemIdentity];
        }
        [self popView:cardView complete:^{
            @strongify(self);
            [self performSegueWithIdentifier:@"story" sender:nil];
        }];
    }];
    [view addGestureRecognizer:tap];
    
    return view;
}

- (void) popView:(UIView*)view  complete:(void (^)(void))completion {
    POPSpringAnimation *spring = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    spring.springBounciness = 12.0f;
    spring.springSpeed = 5.0f;
    spring.fromValue = [NSValue valueWithCGSize:CGSizeMake(0.95, 0.95)];
    spring.toValue = [NSValue valueWithCGSize:CGSizeMake(1.0, 1.0)];
    spring.completionBlock = ^(POPAnimation *animation, BOOL success) {
        if (completion)
            completion();
    };
    [view.layer pop_addAnimation:spring forKey:@"pop"];
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"story"]) {
        StoryViewController *story = (StoryViewController*)((UINavigationController*)segue.destinationViewController).topViewController;
        story.presentingURLString = self.selectedUrlString;
        self.selectedUrlString = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
