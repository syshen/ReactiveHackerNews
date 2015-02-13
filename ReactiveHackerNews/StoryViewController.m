//
//  StoryViewController.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/11/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "StoryViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <TUSafariActivity/TUSafariActivity.h>
#import <NJKWebViewProgress/NJKWebViewProgress.h>
#import <NJKWebViewProgress/NJKWebViewProgressView.h>

@interface StoryViewController () <NJKWebViewProgressDelegate, UIWebViewDelegate>
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
@property (nonatomic, strong) NJKWebViewProgressView *progressView;
@property (nonatomic, strong) NSString *title;
@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.leftBarButtonItem.title = @"Dismiss";
    @weakify(self);
    self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] init];
    left.image = [UIImage imageNamed:@"left"];
    RACSignal *canGoBack = RACObserve(self.webView, canGoBack);
    left.rac_command = [[RACCommand alloc] initWithEnabled:canGoBack
                                               signalBlock:^RACSignal *(id input) {
                                                   @strongify(self);
                                                   [self.webView goBack];
                                                   return [RACSignal empty];
                                               }];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] init];
    right.image = [UIImage imageNamed:@"right"];
    RACSignal *canGoForward = RACObserve(self.webView, canGoForward);
    right.rac_command = [[RACCommand alloc] initWithEnabled:canGoForward
                                                signalBlock:^RACSignal *(id input) {
                                                    @strongify(self);
                                                    [self.webView goForward];
                                                    return [RACSignal empty];
                                                }];
    
    UIBarButtonItem *share = [[UIBarButtonItem alloc] init];
    share.image = [UIImage imageNamed:@"share"];
    share.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);

        NSMutableArray *items = [NSMutableArray array];
        NSURL *url = self.webView.request.URL;
        [items addObject:url];
        if (self.title)
            [items addObject:self.title];
        TUSafariActivity *safari = [[TUSafariActivity alloc] init];
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:@[safari]];
        
        [self presentViewController:activity animated:YES completion:nil];
        return [RACSignal empty];
    }];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 60.0f;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = @[left, space, right, flexibleSpace, share];
    self.toolBar.items = items;
    self.toolBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:1.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:1.0/255.0 alpha:1.0];
    
    self.progressProxy = [[NJKWebViewProgress alloc] init]; // instance variable
    self.webView.delegate = self.progressProxy;
    self.progressProxy.webViewProxyDelegate = self;
    self.progressProxy.progressDelegate = self;

    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.backgroundColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:1.0/255.0 alpha:1.0];

}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.progressView.progress = 0;
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.presentingURLString]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:YES];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
