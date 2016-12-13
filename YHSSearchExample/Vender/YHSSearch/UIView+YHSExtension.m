//
//  UIView+YHSExtension.m
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import "UIView+YHSExtension.h"

@implementation UIView (YHSExtension)

- (void)setYhs_x:(CGFloat)yhs_x
{
    CGRect frame = self.frame;
    frame.origin.x = yhs_x;
    self.frame = frame;
}

- (CGFloat)yhs_x
{
    return self.yhs_origin.x;
}

- (void)setYhs_centerX:(CGFloat)yhs_centerX
{
    CGPoint center = self.center;
    center.x = yhs_centerX;
    self.center = center;
}

- (CGFloat)yhs_centerX
{
    return self.center.x;
}

-(void)setYhs_centerY:(CGFloat)yhs_centerY
{
    CGPoint center = self.center;
    center.y = yhs_centerY;
    self.center = center;
}

- (CGFloat)yhs_centerY
{
    return self.center.y;
}

- (void)setYhs_y:(CGFloat)yhs_y
{
    CGRect frame = self.frame;
    frame.origin.y = yhs_y;
    self.frame = frame;
}

- (CGFloat)yhs_y
{
    return self.frame.origin.y;
}

- (void)setYhs_size:(CGSize)yhs_size
{
    CGRect frame = self.frame;
    frame.size = yhs_size;
    self.frame = frame;
}

- (CGSize)yhs_size
{
    return self.frame.size;
}

- (void)setYhs_height:(CGFloat)Yhs_height
{
    CGRect frame = self.frame;
    frame.size.height = Yhs_height;
    self.frame = frame;
}

- (CGFloat)yhs_height
{
    return self.frame.size.height;
}

- (void)setYhs_width:(CGFloat)yhs_width
{
    CGRect frame = self.frame;
    frame.size.width = yhs_width;
    self.frame = frame;
    
}
- (CGFloat)yhs_width
{
    return self.frame.size.width;
}

- (void)setYhs_origin:(CGPoint)yhs_origin
{
    CGRect frame = self.frame;
    frame.origin = yhs_origin;
    self.frame = frame;
}

- (CGPoint)yhs_origin
{
    return self.frame.origin;
}

/** 设置锚点 */
- (CGPoint)yhs_setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint oldOrigin = view.frame.origin;
    view.layer.anchorPoint = anchorPoint;
    CGPoint newOrigin = view.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    
    view.center = CGPointMake (view.center.x - transition.x, view.center.y - transition.y);
    return self.layer.anchorPoint;
}


/** 根据手势触摸点修改相应的锚点，就是沿着触摸点做相应的手势操作 */
- (CGPoint)yhs_setAnchorPointBaseOnGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    // 手势为空 直接返回
    if (!gestureRecognizer) {
        return CGPointMake(0.5, 0.5);
    }
    
    // 创建锚点
    CGPoint anchorPoint;
    // 捏合手势
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        if (gestureRecognizer.numberOfTouches == 2) {
            // 当触摸开始时，获取两个触摸点
            CGPoint point1 = [gestureRecognizer locationOfTouch:0 inView:gestureRecognizer.view];
            CGPoint point2 = [gestureRecognizer locationOfTouch:1 inView:gestureRecognizer.view];
            anchorPoint.x = (point1.x + point2.x) / 2 / gestureRecognizer.view.yhs_width;
            anchorPoint.y = (point1.y + point2.y) / 2 / gestureRecognizer.view.yhs_height;
        }
    }
    // 点击手势
    else if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        // 获取触摸点
        CGPoint point = [gestureRecognizer locationOfTouch:0 inView:gestureRecognizer.view];
        CGFloat angle = acosf(gestureRecognizer.view.transform.a);
        if (ABS(asinf(gestureRecognizer.view.transform.b) + M_PI_2) < 0.01) angle += M_PI;
        CGFloat width = gestureRecognizer.view.yhs_width;
        CGFloat height = gestureRecognizer.view.yhs_height;
        if (ABS(angle - M_PI_2) <= 0.01 || ABS(angle - M_PI_2 * 3) <= 0.01) { // 旋转角为90°
            // width 和 height 对换
            width = gestureRecognizer.view.yhs_height;
            height = gestureRecognizer.view.yhs_width;
        }
        // 如果旋转了
        anchorPoint.x = point.x / width;
        anchorPoint.y = point.y / height;
    };
    return [self yhs_setAnchorPoint:anchorPoint forView:self];
}


@end



