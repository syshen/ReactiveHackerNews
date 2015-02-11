//
//  CellViewModel.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface StoryViewModel : NSObject

- (instancetype) initWithIdentity:(NSInteger)identity;

@property (nonatomic, readonly) RACCommand *loadStoryCommand;
@property (nonatomic, readonly) RACCommand *loadContentCommand;

@property (nonatomic, assign) NSInteger itemIdentity;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *author;
@property (nonatomic, readonly) NSString *date;
@property (nonatomic, readonly) NSInteger score;
@property (nonatomic, readonly) NSInteger commentCount;
@property (nonatomic, readonly) NSString *content;
@property (nonatomic, readonly) NSString *url;

@end
