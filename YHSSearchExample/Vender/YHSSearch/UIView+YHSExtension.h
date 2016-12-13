//
//  UIView+YHSExtension.h
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YHSExtension)

@property (nonatomic, assign) CGFloat yhs_x;
@property (nonatomic, assign) CGFloat yhs_y;
@property (nonatomic, assign) CGFloat yhs_width;
@property (nonatomic, assign) CGFloat yhs_height;
@property (nonatomic, assign) CGPoint yhs_origin;
@property (nonatomic, assign) CGSize  yhs_size;
@property (nonatomic, assign) CGFloat yhs_centerX;
@property (nonatomic, assign) CGFloat yhs_centerY;


/** 设置锚点 */
- (CGPoint)yhs_setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view;


/** 根据手势触摸点修改相应的锚点，就是沿着触摸点对self做相应的手势操作 */
- (CGPoint)yhs_setAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;


@end



