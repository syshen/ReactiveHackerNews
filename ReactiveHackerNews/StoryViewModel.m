//
//  CellViewModel.m
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "StoryViewModel.h"
#import "HNClient.h"
#import "ReadabilityClient.h"
#import <NSString-HTML/NSString+HTML.h>

@interface StoryViewModel ()
@property (nonatomic, strong) RACCommand *loadStoryCommand;
@property (nonatomic, strong) RACCommand *loadContentCommand;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger commentCount;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *url;

@end

@implementation StoryViewModel

- (instancetype) initWithIdentity:(NSInteger)identity {
    self = [super init];
    self.itemIdentity = identity;
    
    @weakify(self);
    [RACObserve(self, url) subscribeNext:^(id x) {
        @strongify(self);
        [self.loadContentCommand execute:nil];
    }];
    
    return self;
}

- (RACCommand*) loadStoryCommand {
    if (_loadStoryCommand)
        return _loadStoryCommand;
    
    @weakify(self);
    _loadStoryCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        return [[[HNClient sharedClient] itemWithIdentity:self.itemIdentity] map:^id(NSDictionary* response) {
            @strongify(self);

            self.title = response[@"title"];
            NSInteger timestamp = [response[@"time"] integerValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
            self.date = [NSString  stringWithFormat:@"%@", [[self dateFormatter] stringFromDate:date]];
            self.commentCount = [response[@"kids"] count];
            self.score = [response[@"score"] integerValue];
            self.author = [NSString stringWithFormat:@"by %@ at %@",response[@"by"], self.date];
            self.url = response[@"url"];
            
            return [RACSignal empty];
        }];
    }];
    return _loadStoryCommand;
}

- (RACCommand*) loadContentCommand {
    if (_loadContentCommand)
        return _loadContentCommand;
    
    @weakify(self);
    _loadContentCommand = [[RACCommand alloc] initWithEnabled:[self urlAvailable]
                                                  signalBlock:^RACSignal *(id input) {
                  
                                                      @strongify(self);
                                                      if (self.url == nil)
                                                          NSLog(@"nil url");
                                                      return [[[ReadabilityClient sharedClient] contentForUrl:self.url] map:^id(NSDictionary *response) {
                                                          
                                                          @strongify(self);
                                                          self.content = [[response[@"excerpt"] kv_decodeHTMLCharacterEntities]
                                                                               stringByReplacingOccurrencesOfString:@"&hellip;" withString:@"..."];
                                                          
                                                          return [RACSignal empty];
                                                          
                                                      }];
                                                      
                                                  }];
    return _loadContentCommand;
}

- (RACSignal *) urlAvailable {
    return [RACObserve(self, url) map:^id(NSURL *url) {
        return @(url!=nil);
    }];
}
- (NSDateFormatter*)dateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm MM/dd";
    });
    return formatter;
}

@end
