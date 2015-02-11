//
//  StoryViewController.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/11/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "StoryViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface StoryViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBar;
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
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.presentingURLString]]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
