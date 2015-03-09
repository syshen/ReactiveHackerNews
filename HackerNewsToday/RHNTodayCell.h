//
//  RHNTodayCell.h
//  ReactiveHackerNews
//
//  Created by syshen on 3/8/15.
//  Copyright (c) 2015 Intelligent Gadget. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RHNTodayCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@end
