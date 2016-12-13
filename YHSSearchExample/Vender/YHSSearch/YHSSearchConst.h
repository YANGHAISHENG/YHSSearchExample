//
//  YHSSearchConst.h
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//
//  用于存储常量、宏定义的头文件

#import <Foundation/Foundation.h>
#import "UIView+YHSExtension.h"
#import "UIColor+YHSExtension.h"


#define YHSMargin 10 // 默认边距
#define YHSBackgroundColor YHSColor(255, 255, 255) // TableView背景颜色

// 日志输出
#ifdef DEBUG
#define YHSSearchLog(format, ...) printf("[LINE] %s [第%d行] %s \n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define YHSSearchLog(__FORMAT__, ...)
#endif

// 颜色
#define YHSColor(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define YHSRandomColor  YHSColor(arc4random_uniform(256),arc4random_uniform(256),arc4random_uniform(256))


// 屏幕宽高
// 屏幕宽高(注意：由于不同iOS系统下，设备横竖屏时屏幕的高度和宽度有的是变化的有的是不变的)
#define YHSRealyScreenW [UIScreen mainScreen].bounds.size.width
#define YHSRealyScreenH [UIScreen mainScreen].bounds.size.height
// 屏幕宽高（这里获取的是正常竖屏的屏幕宽高（宽永远小于高度））
#define YHSScreenW (YHSRealyScreenW < YHSRealyScreenH ? YHSRealyScreenW : YHSRealyScreenH)
#define YHSScreenH (YHSRealyScreenW > YHSRealyScreenH ? YHSRealyScreenW : YHSRealyScreenH)
#define YHSScreenSize CGSizeMake(YHSScreenW, YHSScreenH)


#define YHSSearchHistoryImage [UIImage imageNamed:@"YHSSearch.bundle/search_history"] // 搜索历史Cell的图片
#define YHSSearchSuggestionImage [UIImage imageNamed:@"YHSSearch.bundle/search"] // 搜索建议时，Cell的图片
#define YHSSearchHistoriesPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YHSSearchhistories.plist"] // 搜索历史存储路径


@interface YHSSearchConst : NSObject


UIKIT_EXTERN CGFloat const STATUS_NAVIGATION_BAR_HEIGHT;    // 状态栏+导航条高度(系统默认高度为64)
UIKIT_EXTERN CGFloat const STATUS_BAR_HEIGHT;               // 状态栏高度(系统默认高度为20)
UIKIT_EXTERN CGFloat const NAVIGATION_BAR_HEIGHT;           // 导航条高度(系统默认高度为44)


UIKIT_EXTERN NSString *const YHSSearchPlaceholderText;      // 搜索框的占位符（默认为 @"搜索内容"）
UIKIT_EXTERN NSString *const YHSHotSearchText;              // 热门搜索文本（默认为 @"热门搜索"）
UIKIT_EXTERN NSString *const YHSSearchHistoryText;          // 搜索历史文本（默认为 @"搜索历史"）
UIKIT_EXTERN NSString *const YHSEmptySearchHistoryText;     // 清空搜索历史文本（默认为 @"清空搜索历史"）


@end






