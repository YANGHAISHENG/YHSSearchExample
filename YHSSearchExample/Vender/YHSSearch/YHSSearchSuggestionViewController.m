//
//  YHSSearchSuggestionViewController.m
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import "YHSSearchSuggestionViewController.h"
#import "YHSSearchConst.h"


@interface YHSSearchSuggestionViewController ()

/** 记录消失前的contentInset */
@property (nonatomic, assign) UIEdgeInsets originalContentInset;

@end


@implementation YHSSearchSuggestionViewController


+ (instancetype)searchSuggestionViewControllerWithDidSelectCellBlock:(YHSSearchSuggestionDidSelectCellBlock)didSelectCellBlock
{
    YHSSearchSuggestionViewController *searchSuggestionVC = [[YHSSearchSuggestionViewController alloc] init];
    searchSuggestionVC.didSelectCellBlock = didSelectCellBlock;
    searchSuggestionVC.automaticallyAdjustsScrollViewInsets = NO;
    return searchSuggestionVC;
}


#pragma mark - LifeCycle
/** 视图加载完毕 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 表格设置
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboradFrameDidChange:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
}


/** 控制器销毁 */
- (void)dealloc
{
    // 移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/** 视图即将消失 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 记录消失前的tableView.contentInset
    self.originalContentInset = self.tableView.contentInset;
}


/** 键盘frame改变 */
- (void)keyboradFrameDidChange:(NSNotification *)notification
{
    // 刷新
    [self setSearchSuggestions:_searchSuggestions];
}


#pragma mark - Setter
- (void)setSearchSuggestions:(NSArray<NSString *> *)searchSuggestions
{
    _searchSuggestions = [searchSuggestions copy];
    
    // 刷新数据
    [self.tableView reloadData];
    
    // 还原contentInset
    if (!UIEdgeInsetsEqualToEdgeInsets(self.originalContentInset, UIEdgeInsetsZero)) { // originalContentInset非零
        self.tableView.contentInset =  self.originalContentInset;
    }
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInSearchSuggestionView:)]) {
        return [self.dataSource numberOfSectionsInSearchSuggestionView:tableView];
    }
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:numberOfRowsInSection:)]) {
        return [self.dataSource searchSuggestionView:tableView numberOfRowsInSection:section];
    }
    return self.searchSuggestions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
        UITableViewCell *cell= [self.dataSource searchSuggestionView:tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }
    }
    
    // 使用默认的搜索建议Cell
    static NSString *cellID = @"YHSSearchSuggestionCellIdentifier";
    // 创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        // 添加分割线
        UIImageView *line = [[UIImageView alloc] initWithImage:YHSSearchSeparatorLineHorizontalImage];
        line.alpha = 0.7;
        line.yhs_x = YHSSearchMargin;
        line.yhs_y = YHS_SEARCH_TABLE_VIEW_CELL_HEIGHT_DEFAULT-YHS_SEARCH_SEPARATOR_LINE_HEIGHT_DEFAULT;
        line.yhs_width = YHSScreenWidth;
        line.yhs_height = YHS_SEARCH_SEPARATOR_LINE_HEIGHT_DEFAULT;
        [cell.contentView addSubview:line];
    }
    // 设置数据
    cell.imageView.image = YHSSearchSuggestionImage;
    cell.textLabel.text = self.searchSuggestions[indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:heightForRowAtIndexPath:)]) {
        return [self.dataSource searchSuggestionView:tableView heightForRowAtIndexPath:indexPath];
    }
    return YHS_SEARCH_TABLE_VIEW_CELL_HEIGHT_DEFAULT;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 执行块Block
    if (self.didSelectCellBlock) {
        self.didSelectCellBlock([tableView cellForRowAtIndexPath:indexPath]);
    }
}


@end



