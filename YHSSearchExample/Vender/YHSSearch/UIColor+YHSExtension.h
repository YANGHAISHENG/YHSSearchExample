//
//  UIColor+YHSExtension.h
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (YHSExtension)

/*
 * Returns a color based on the hex code string.
 *
 * @param hexString The hex string.
 * @returns A hex color.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString;

/*
 * Returns a color based on the hex code string plus an alpha value.
 *
 * @param hexString The hex string.
 * @param alpha The alpha value of the color.
 * @returns A hex color.
 */
+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;

/*
 * Returns a the hex string equivalent to a color.
 *
 * @returns A hex string.
 */
- (NSString *)hexStringFromColor;


@end
