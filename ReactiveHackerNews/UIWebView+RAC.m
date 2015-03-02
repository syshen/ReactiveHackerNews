//
//  UIWebView+RAC.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/26/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "UIWebView+RAC.h"
#import <objc/runtime.h>

@interface WebViewProxyDelegate : NSObject <UIWebViewDelegate>
@property (nonatomic, weak) id<UIWebViewDelegate> webViewProxyDelegate;
@end
@implementation WebViewProxyDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [_webViewProxyDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [_webViewProxyDelegate webViewDidFinishLoad:webView];
    }
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    if ([_webViewProxyDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [_webViewProxyDelegate webViewDidStartLoad:webView];
    }
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([_webViewProxyDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [_webViewProxyDelegate webView:webView didFailLoadWithError:error];
    }
}
@end

@interface UIWebView () <UIWebViewDelegate>
@property (nonatomic, strong) WebViewProxyDelegate *delegateObject;
@end

@implementation UIWebView (RAC)

- (id) delegateObject {
    id obj = objc_getAssociatedObject(self, _cmd);
    if (obj) return obj;
    obj = [[WebViewProxyDelegate alloc] init];
    self.delegate = obj;
    objc_setAssociatedObject(self, _cmd, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return obj;
}

- (void) setProxyDelegate:(id<UIWebViewDelegate>)proxyDelegate {
    self.delegateObject.webViewProxyDelegate = proxyDelegate;
}

- (id) proxyDelegate {
    return self.delegateObject.webViewProxyDelegate;
}

- (RACSignal*) rac_didStartLoad {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) return signal;
    signal = [self.delegateObject rac_signalForSelector:@selector(webViewDidStartLoad:) fromProtocol:@protocol(UIWebViewDelegate)];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal*) rac_didFinishLoad {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    
    if (signal) return signal;
    signal = [self.delegateObject rac_signalForSelector:@selector(webViewDidFinishLoad:) fromProtocol:@protocol(UIWebViewDelegate)];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *) rac_canGoBack {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) return signal;
    
    @weakify(self);
    
    // disable canGoBack by default
    RACSignal *falseSignal = [RACSignal return:@(NO)];
    RACSignal *triggerSignal = [[RACSignal combineLatest:@[[self rac_didStartLoad], [self rac_didFinishLoad]]] map:^id(id value) {
        @strongify(self);
        return @(self.canGoBack);
    }];
    signal = [RACSignal merge:@[falseSignal, triggerSignal]];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *) rac_canGoForward {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) return signal;
    
    @weakify(self);
    // disable canGoForward by default
    RACSignal *falseSignal = [RACSignal return:@(NO)];
    RACSignal *triggerSignal = [[RACSignal combineLatest:@[[self rac_didStartLoad], [self rac_didFinishLoad]]] map:^id(id value) {
        @strongify(self);
        return @(self.canGoForward);
    }];
    signal = [RACSignal merge:@[falseSignal, triggerSignal]];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}

- (RACSignal *) rac_error {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal) return signal;
    
    signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return [[self.delegateObject rac_signalForSelector:@selector(webView:didFailLoadWithError:) fromProtocol:@protocol(UIWebViewDelegate)] subscribeNext:^(RACTuple *tuple) {
//            UIWebView *webView = tuple.first;
            NSError *error = tuple.second;
            [subscriber sendError:error];
        }];
    }];
    
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
    
}
@end
