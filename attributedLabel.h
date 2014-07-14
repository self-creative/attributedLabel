//
//  attributedLabel.h
//  easyAttributedLabel
//
//  Created by xwd on 14-7-14.
//  Copyright (c) 2014年 xwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVAttributesLabel.h"

@interface attributedLabel :UILabel

@property (nonatomic, assign) BOOL shouldTruncate;
@property (nonatomic, assign) NSInteger lineGap;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont *textFront;

- (void)setStytleWithLeading:(NSInteger)leading textcolor:(UIColor *)textcolor textfrot:(UIFont *)textfont truncate: (BOOL)shouldtruncate;

@end
