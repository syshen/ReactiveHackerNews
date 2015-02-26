//
//  UIWebView+RAC.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/26/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface UIWebView (RAC)
@property (nonatomic, weak) id<UIWebViewDelegate> proxyDelegate;
@property (nonatomic, readonly, retain) RACSignal *rac_canGoBack;
@property (nonatomic, readonly, retain) RACSignal *rac_canGoForward;
@property (nonatomic, readonly, retain) RACSignal *rac_didStartLoad;
@property (nonatomic, readonly, retain) RACSignal *rac_didFinishLoad;
@property (nonatomic, readonly, retain) RACSignal *rac_error;

@end
