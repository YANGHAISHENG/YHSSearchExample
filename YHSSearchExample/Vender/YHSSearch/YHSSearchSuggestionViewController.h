//
//  YHSSearchSuggestionViewController.h
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//
//  搜索建议控制器

#import <UIKit/UIKit.h>


typedef void(^YHSSearchSuggestionDidSelectCellBlock)(UITableViewCell *selectedCell);


@protocol YHSSearchSuggestionViewDataSource <NSObject, UITableViewDataSource>

@required
/** 返回用户自定义搜索建议Cell */
- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
/** 返回用户自定义搜索建议cell的rows */
- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section;

@optional
/** 返回用户自定义搜索建议Cell的Section */
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView;
/** 返回用户自定义搜索建议Cell高度 */
- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface YHSSearchSuggestionViewController : UITableViewController

/** 搜索建议数据源 */
@property (nonatomic, weak) id<YHSSearchSuggestionViewDataSource> dataSource;
/** 搜索建议 */
@property (nonatomic, copy) NSArray<NSString *> *searchSuggestions;
/** 选中Cell时调用此Block  */
@property (nonatomic, copy) YHSSearchSuggestionDidSelectCellBlock didSelectCellBlock;


+ (instancetype)searchSuggestionViewControllerWithDidSelectCellBlock:(YHSSearchSuggestionDidSelectCellBlock)didSelectCellBlock;


@end




