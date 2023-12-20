//
//  HorizontalTableViewCell.m
//  BWHorizontalTableView Demo
//
//  Created by wangruicheng on 1/1/16.
//  Copyright © 2016 burrowswang. All rights reserved.
//

#import "HorizontalTableViewCell.h"

@interface HorizontalTableViewCell ()



@end

@implementation HorizontalTableViewCell

- (void)dealloc {
    NSLog(@"%@", @"One HorizontalTableViewCell deallocated!");
}
- (UIImage *)imageWithColor:(UIColor *)color andBounds:(CGRect)imgBounds {
    UIGraphicsBeginImageContextWithOptions(imgBounds.size, NO, 0);
    [color setFill];
    UIRectFill(imgBounds);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        NSLog(@"%@", @"One HorizontalTableViewCell created!");
        
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(10, 10, 64, 64);
        iconView.layer.cornerRadius = 20.0f;
        iconView.layer.borderWidth = 0;
        iconView.layer.masksToBounds = YES;
        
        [self addSubview:iconView];
        self.planetImageView = iconView;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(14, 22, 55, 40);
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:14.0f weight:UIFontWeightBold];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 2;
        label.textColor = [UIColor darkTextColor];
        [self addSubview:label];
        self.planetNameLabel = label;
        
        
    }
    
    return self;
}

- (void)showPlanet:(NSString *)planet {
    self.planetImageView.image = [[UIImage alloc] init];

    self.planetNameLabel.text = planet;
}

@end
