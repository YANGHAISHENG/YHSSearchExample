//
//  YHSSearchViewController.h
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//
//  搜索控制器

#import <UIKit/UIKit.h>
@class YHSSearchViewController, YHSSearchSuggestionViewController;


// 开始搜索时调用的block
typedef void(^YHSDidSearchBlock)(YHSSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText);


// 热门搜索标签风格
typedef NS_ENUM(NSInteger, YHSHotSearchStyle)  {
    YHSHotSearchStyleNormalTag,      // 普通标签(不带边框)
    YHSHotSearchStyleColorfulTag,    // 彩色标签（不带边框，背景色为随机彩色）
    YHSHotSearchStyleBorderTag,      // 带有边框的标签，此时标签背景色为clearColor
    YHSHotSearchStyleARCBorderTag,   // 带有圆弧边框的标签，此时标签背景色为clearColor
    YHSHotSearchStyleRankTag,        // 带有排名标签
    YHSHotSearchStyleRectangleTag,   // 矩形标签，此时标签背景色为clearColor
    YHSHotSearchStyleDefault = YHSHotSearchStyleNormalTag // 默认为普通标签
};


// 搜索历史风格
typedef NS_ENUM(NSInteger, YHSSearchHistoryStyle) {
    YHSSearchHistoryStyleCell,           // UITableViewCell 风格
    YHSSearchHistoryStyleNormalTag,      // YHSHotSearchStyleNormalTag 标签风格
    YHSSearchHistoryStyleColorfulTag,    // 彩色标签（不带边框，背景色为随机彩色）
    YHSSearchHistoryStyleBorderTag,      // 带有边框的标签，此时标签背景色为clearColor
    YHSSearchHistoryStyleARCBorderTag,   // 带有圆弧边框的标签，此时标签背景色为clearColor
    YHSSearchHistoryStyleDefault = YHSSearchHistoryStyleCell // 默认为 YHSSearchHistoryStyleCell
};


// 搜索结果显示方式
typedef NS_ENUM(NSInteger, YHSSearchResultShowMode) {
    YHSSearchResultShowModeCustom,   // 通过自定义显示
    YHSSearchResultShowModePush,     // 通过Push控制器显示
    YHSSearchResultShowModeEmbed,    // 通过内嵌控制器View显示
    YHSSearchResultShowModeDefault = YHSSearchResultShowModeCustom // 默认为用户自定义（自己处理）
};


@protocol YHSSearchViewControllerDataSource <NSObject, UITableViewDataSource>

@optional
/**
 *  自定义搜索建议Cell的数据源方法
 */
/** 返回用户自定义搜索建议Cell */
- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/** 返回用户自定义搜索建议Cell的Rows */
- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section;
/** 返回用户自定义搜索建议Cell的Section */
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView;
/** 返回用户自定义搜索建议Cell高度 */
- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;


/**
 *  自定义搜索结果Cell的数据源方法
 */
/** 返回用户自定义搜索结果Cell */
- (UITableViewCell *)searchResultView:(UITableView *)searchResultView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/** 返回用户自定义搜索结果Cell的Rows */
- (NSInteger)searchResultView:(UITableView *)searchResultView numberOfRowsInSection:(NSInteger)section;
/** 返回用户自定义搜索结果Cell的Section */
- (NSInteger)numberOfSectionsInSearchSearchResultView:(UITableView *)searchSuggestionView;
/** 返回用户自定义搜索结果Cell高度 */
- (CGFloat)searchResultView:(UITableView *)searchResultView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol YHSSearchViewControllerDelegate <NSObject, UITableViewDelegate>

@optional

/** 点击(开始)搜索时调用 */
- (void)searchViewController:(YHSSearchViewController *)searchViewController didSearchWithsearchBar:(UISearchBar *)searchBar searchText:(NSString *)searchText;
/** 点击热门搜索时调用，如果实现该代理方法，则点击热门搜索时searchViewController:didSearchWithsearchBar:searchText:失效 */
- (void)searchViewController:(YHSSearchViewController *)searchViewController didSelectHotSearchAtIndex:(NSInteger)index searchText:(NSString *)searchText;
/** 点击搜索历史时调用，如果实现该代理方法，则搜索历史时searchViewController:didSearchWithsearchBar:searchText:失效 */
- (void)searchViewController:(YHSSearchViewController *)searchViewController didSelectSearchHistoryAtIndex:(NSInteger)index searchText:(NSString *)searchText;
/** 点击搜索建议时调用，如果实现该代理方法，则点击搜索建议时searchViewController:didSearchWithsearchBar:searchText:失效 */
- (void)searchViewController:(YHSSearchViewController *)searchViewController didSelectSearchSuggestionAtIndex:(NSInteger)index searchText:(NSString *)searchText;
/** 搜索框文本变化时，显示的搜索建议通过searchViewController的searchSuggestions赋值即可 */
- (void)searchViewController:(YHSSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText;
/** 点击取消时调用 */
- (void)didClickCancel:(YHSSearchViewController *)searchViewController;

@end



@interface YHSSearchViewController : UIViewController

/**
 * 排名标签背景色对应的16进制字符串（如：@"#FFCC99"）数组(四个颜色)
 * 前三个为分别为1、2、3 第4个为后续所有标签的背景色
 * 该属性只有在设置热门搜索标签风格hotSearchStyle为YHSHotSearchStyleRankTag才生效
 */
@property (nonatomic, strong) NSArray<NSString *> *rankTagBackgroundColorHexStrings;
/**
 * WEB安全色池，存储的是UIColor数组，用于设置标签的背景色
 * 该属性只有在设置热门搜索标签风格hotSearchStyle为YHSHotSearchStyleColorfulTag才生效
 */
@property (nonatomic, strong) NSMutableArray<UIColor *> *colorPol;
/** 热门搜索 */
@property (nonatomic, copy) NSArray<NSString *> *hotSearches;
/** 所有的热门标签 */
@property (nonatomic, copy) NSArray<UILabel *> *hotSearchTags;
/** 热门标签头部 */
@property (nonatomic, weak) UILabel *hotSearchHeader;

/** 所有的搜索历史标签，只有当YHSSearchHistoryStyle != YHSSearchHistoryStyleCell才有值 */
@property (nonatomic, copy) NSArray<UILabel *> *searchHistoryTags;
/** 搜索历史标题，只有当YHSSearchHistoryStyle != YHSSearchHistoryStyleCell才有值 */
@property (nonatomic, weak) UILabel *searchHistoryHeader;
/** 搜索历史缓存保存路径, 默认为YHSSearchHistoriesPath(YHSSearchConst.h文件中的宏定义) */
@property (nonatomic, copy) NSString *searchHistoriesCachePath;
/** 搜索历史记录缓存数量，默认为20 */
@property (nonatomic, assign) NSUInteger searchHistoriesCount;

/** 代理 */
@property (nonatomic, weak) id<YHSSearchViewControllerDelegate> delegate;
/** 数据源 */
@property (nonatomic, weak) id<YHSSearchViewControllerDataSource> dataSource;

/** 热门搜索风格 （默认为：YHSHotSearchStyleDefault）*/
@property (nonatomic, assign) YHSHotSearchStyle hotSearchStyle;
/** 搜索历史风格 （默认为：YHSSearchHistoryStyleDefault）*/
@property (nonatomic, assign) YHSSearchHistoryStyle searchHistoryStyle;
/** 显示搜索结果模式（默认为自定义：YHSSearchResultShowModeDefault） */
@property (nonatomic, assign) YHSSearchResultShowMode searchResultShowMode;
/** 搜索栏 */
@property (nonatomic, weak) UISearchBar *searchBar;
/** 搜索栏的背景色 */
@property (nonatomic, strong) UIColor *searchBarBackgroundColor;
/** 取消按钮 */
@property (nonatomic, weak) UIBarButtonItem *cancelButton;

/** 搜索时调用此Block */
@property (nonatomic, copy) YHSDidSearchBlock didSearchBlock;
/** 搜索建议，注意：给此属性赋值时，确保searchSuggestionHidden值为NO，否则赋值失效 */
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;
/** 搜索建议是否隐藏，默认为：NO */
@property (nonatomic, assign) BOOL searchSuggestionHidden;


/** 搜索结果控制器
 * 当searchResultShowMode == YHSSearchResultShowModePush时，
 * 将目的控制器给该属性赋值，即Push到searchResultController控制器
 * 当searchResultShowMode == YHSSearchResultShowModeEmbed时，
 * 将目的控制器给该属性赋值，即将searchResultController.view添加到self.view
 */
@property (nonatomic, strong) UIViewController *searchResultController;


/**
 * 快速创建YHSSearchViewController对象
 *
 * hotSearches : 热门搜索数组
 * placeholder : searchBar占位文字
 *
 */
+ (YHSSearchViewController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder;


/**
 * 快速创建YHSSearchViewController对象
 *
 * hotSearches : 热门搜索数组
 * placeholder : searchBar占位文字
 * block: 点击（开始）搜索时调用block
 * 注意 : delegate(代理)的优先级大于block(即实现了代理方法则block失效)
 *
 */
+ (YHSSearchViewController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches searchBarPlaceholder:(NSString *)placeholder didSearchBlock:(YHSDidSearchBlock)block;

@end







