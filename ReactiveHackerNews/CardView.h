//
//  CardView.h
//  ReactiveHackerNews
//
//  Created by syshen on 2/10/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryViewModel.h"
@interface CardView : UIView

- (void) bindViewModel:(StoryViewModel*)viewModel;
@property (nonatomic, readonly) StoryViewModel *viewModel;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
//@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *authorLabel;
@property (nonatomic, weak) IBOutlet UITextView *contextTextView;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *urlLabel;
@end
