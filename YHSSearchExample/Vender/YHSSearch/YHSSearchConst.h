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


// 日志输出
#ifdef DEBUG
#define YHSSearchLog(format, ...) printf("[LINE] %s [第%d行] %s \n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String])
#else
#define YHSSearchLog(__FORMAT__, ...)
#endif


#define YHSSearchMargin 10 // 默认边距
#define YHSSearchBackgroundColor YHSSearchColor(255, 255, 255) // TableView背景颜色


// 颜色
#define YHSSearchColor(r,g,b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define YHSRandomColor  YHSSearchColor(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))


// 屏幕宽高（注意：设备横竖屏时屏幕的高度和宽度有的是变化的有的是不变的）
#define YHSRealyScreenWidth [UIScreen mainScreen].bounds.size.width
#define YHSRealyScreenHeight [UIScreen mainScreen].bounds.size.height
// 屏幕宽高（获取屏幕的实际高度或正常高度）
#define YHSScreenWidthHeightRealy 1
#ifdef YHSScreenWidthHeightRealy
// 屏幕宽高（获取的是实际屏幕宽高）
#define YHSScreenWidth YHSRealyScreenWidth
#define YHSScreenHeight YHSRealyScreenHeight
#define YHSScreenSize CGSizeMake(YHSScreenWidth, YHSScreenHeight)
#else
// 屏幕宽高（获取的是正常竖屏的屏幕宽高，宽永远小于高度）
#define YHSScreenWidth (YHSRealyScreenWidth < YHSRealyScreenHeight ? YHSRealyScreenWidth : YHSRealyScreenHeight)
#define YHSScreenHeight (YHSRealyScreenWidth > YHSRealyScreenHeight ? YHSRealyScreenWidth : YHSRealyScreenHeight)
#define YHSScreenSize CGSizeMake(YHSScreenWidth, YHSScreenHeight)
#endif


#define YHSSearchHistoriesPath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"YHSSearchHistories.plist"] // 搜索历史存储路径


#define YHSSearchBarImage [UIImage imageNamed:@"YHSSearch.bundle/clearImage"] // 搜索条UISearchBar清除图片
#define YHSSearchHistoryImage [UIImage imageNamed:@"YHSSearch.bundle/search_history"] // 搜索历史Cell的图片
#define YHSSearchSuggestionImage [UIImage imageNamed:@"YHSSearch.bundle/search"] // 搜索建议时，Cell的图片
#define YHSSearchCloseImage [UIImage imageNamed:@"YHSSearch.bundle/close"] // 搜索Cell关闭按钮
#define YHSSearchEmptyImage [UIImage imageNamed:@"YHSSearch.bundle/empty"] // 搜索历史清空按钮
#define YHSSearchSeparatorLineVerticalImage [UIImage imageNamed:@"YHSSearch.bundle/cell-content-line-vertical"] // 竖直分割线图片
#define YHSSearchSeparatorLineHorizontalImage [UIImage imageNamed:@"YHSSearch.bundle/cell-content-line-horizontal"] // 水平分割线图片


@interface YHSSearchConst : NSObject


UIKIT_EXTERN CGFloat const YHS_SEARCH_STATUS_NAVIGATION_BAR_HEIGHT;      // 状态栏+导航条高度(系统默认高度为64)
UIKIT_EXTERN CGFloat const YHS_SEARCH_STATUS_BAR_HEIGHT;                 // 状态栏高度(系统默认高度为20)
UIKIT_EXTERN CGFloat const YHS_SEARCH_NAVIGATION_BAR_HEIGHT;             // 导航条高度(系统默认高度为44)
UIKIT_EXTERN CGFloat const YHS_SEARCH_SEARCH_BAR_HEIGHT;                 // 搜索框UISearchBar高度为30
UIKIT_EXTERN CGFloat const YHS_SEARCH_TABLE_VIEW_CELL_HEIGHT_DEFAULT;    // 表格默认高度为44
UIKIT_EXTERN CGFloat const YHS_SEARCH_SEPARATOR_LINE_HEIGHT_DEFAULT;     // 表格分割线高度为0.5


UIKIT_EXTERN NSString *const YHSSearchPlaceholderText;      // 搜索框的占位符（默认为 @"搜索内容"）
UIKIT_EXTERN NSString *const YHSHotSearchText;              // 热门搜索文本（默认为 @"热门搜索"）
UIKIT_EXTERN NSString *const YHSSearchHistoryText;          // 搜索历史文本（默认为 @"搜索历史"）
UIKIT_EXTERN NSString *const YHSClearSearchHistoryText;     // 清空搜索历史文本（默认为 @"清空搜索历史"）


@end






