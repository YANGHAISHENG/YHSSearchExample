//
//  YHSSearchExampleController.m
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/8.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import "YHSSearchExampleController.h"
#import "YHSSearchTempViewController.h"


@interface YHSSearchExampleController () <YHSSearchViewControllerDelegate>

@property (nonnull, nonatomic, strong) NSArray *tableSections;

@property (nonnull, nonatomic, strong) NSArray<NSArray *> *tableData;

@end


@implementation YHSSearchExampleController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"YHSSearchExampleController";
    
    
    self.tableSections = @[ @"选择热门搜索风格（搜索历史为默认风格）",
                            @"选择搜索历史风格（热门搜索为默认风格）" ];
    
    
    self.tableData = @[ // 选择热门搜索风格
                       @[ @"YHSHotSearchStyleDefault",
                          @"YHSHotSearchStyleColorfulTag",
                          @"YHSHotSearchStyleBorderTag",
                          @"YHSHotSearchStyleARCBorderTag",
                          @"YHSHotSearchStyleRankTag",
                          @"YHSHotSearchStyleRectangleTag"],
                       // 选择搜索历史风格
                       @[ @"YHSSearchHistoryStyleDefault",
                          @"YHSSearchHistoryStyleNormalTag",
                          @"YHSSearchHistoryStyleColorfulTag",
                          @"YHSSearchHistoryStyleBorderTag",
                          @"YHSSearchHistoryStyleARCBorderTag"] ];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableData.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableData[section].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * reuseIdentifier = @"CellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = self.tableData[indexPath.section][indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.tableSections[section];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建热门搜索
    NSArray *hotSeaches = @[ @"Java",
                             @"Python",
                             @"Objective-C",
                             @"Swift",
                             @"C",
                             @"C++",
                             @"PHP",
                             @"C#",
                             @"Perl",
                             @"Go",
                             @"JavaScript",
                             @"R",
                             @"Ruby",
                             @"MATLAB"];
    
    // 2. 创建控制器
    YHSSearchViewController *searchViewController = [YHSSearchViewController searchViewControllerWithHotSearches:hotSeaches searchBarPlaceholder:@"搜索编程语言" didSearchBlock:^(YHSSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        // 开始搜索执行以下代码
        // 如：跳转到指定控制器
        [searchViewController.navigationController pushViewController:[[YHSSearchTempViewController alloc] init] animated:YES];
    }];
    
    // 3. 设置风格
    if (indexPath.section == 0) {
        // 选择热门搜索
        searchViewController.hotSearchStyle = (NSInteger)indexPath.row; // 热门搜索风格根据选择
        searchViewController.searchHistoryStyle = YHSSearchHistoryStyleDefault; // 搜索历史风格为YHSSearchHistoryStyleDefault
    } else {
        // 选择搜索历史
        searchViewController.hotSearchStyle = YHSHotSearchStyleDefault; // 热门搜索风格为默认
        searchViewController.searchHistoryStyle = (NSInteger)indexPath.row; // 搜索历史风格根据选择
    }
    
    // 4. 设置代理
    searchViewController.delegate = self;
    
    // 5. 跳转到搜索控制器
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:nav  animated:YES completion:nil];
}


#pragma mark - YHSSearchViewControllerDelegate
- (void)searchViewController:(YHSSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText
{
    if (searchText.length) { // 与搜索条件再搜索
        // 根据条件发送查询（这里模拟搜索，延时0.25秒）
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ // 搜素完毕
            // 显示建议搜索结果
            NSMutableArray *searchSuggestionsResult = [NSMutableArray array];
            for (int i = 0; i < arc4random_uniform(5) + 10; i++) {
                NSString *searchSuggestion = [NSString stringWithFormat:@"搜索建议 %d", i];
                [searchSuggestionsResult addObject:searchSuggestion];
            }
            // 返回
            searchViewController.searchSuggestions = searchSuggestionsResult;
        });
    }
}


@end




