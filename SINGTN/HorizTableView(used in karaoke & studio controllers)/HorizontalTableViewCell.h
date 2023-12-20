//
//  HorizontalTableViewCell.h
//  BWHorizontalTableView Demo
//
//  Created by wangruicheng on 1/1/16.
//  Copyright © 2016 burrowswang. All rights reserved.
//

#import "BWHorizontalTableViewCell.h"

@interface HorizontalTableViewCell : BWHorizontalTableViewCell

- (void)showPlanet:(NSString *)planet;
@property (nonatomic, strong) UIImageView           *planetImageView;
@property (nonatomic, strong) UILabel               *planetNameLabel;
@end
