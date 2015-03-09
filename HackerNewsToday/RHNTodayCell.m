//
//  RHNTodayCell.m
//  ReactiveHackerNews
//
//  Created by syshen on 3/8/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import "RHNTodayCell.h"

@implementation RHNTodayCell

- (void)awakeFromNib {
    self.titleLabel.highlightedTextColor = [UIColor grayColor];
    self.nameLabel.highlightedTextColor = [UIColor grayColor];
    self.scoreLabel.highlightedTextColor = [UIColor grayColor];
    self.commentLabel.highlightedTextColor = [UIColor grayColor];
    
    CGRect bgframe = self.bounds;
    bgframe.origin.y = 1;
    bgframe.size.height -= 2;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:bgframe];
    self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

//    if (selected) {
//        self.backgroundColor = [UIColor clearColor];
//    } else {
//        self.backgroundColor = [UIColor clearColor];
//    }
}

@end
