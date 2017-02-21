//
//  YHSSearchViewController.m
//  YHSSearchExample
//
//  Created by YANGHAISHENG on 2016/12/7.
//  Copyright © 2016年 YANGHAISHENG. All rights reserved.
//

#import "YHSSearchViewController.h"
#import "YHSSearchConst.h"
#import "YHSSearchSuggestionViewController.h"


#define YHSRectangleTagMaxCol 3 // 矩阵标签时，最多列数
#define YHSSearchHistoriesCountMax 20 // 搜索历史记录缓存数量
#define YHSTextColor YHSSearchColor(113, 113, 113)  // 文本字体颜色
#define YHSColorPolRandomColor self.colorPol[arc4random_uniform((uint32_t)self.colorPol.count)] // 随机选取颜色池中的颜色


@interface YHSSearchViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, YHSSearchSuggestionViewDataSource>

/** 头部内容view */
@property (nonatomic, weak) UIView *headerContentView;

/** 搜索历史 */
@property (nonatomic, strong) NSMutableArray *searchHistories;

/** 键盘正在移动 */
@property (nonatomic, assign) BOOL keyboardshowing;
/** 记录键盘高度 */
@property (nonatomic, assign) CGFloat keyboardHeight;

/** 搜索建议（推荐）控制器 */
@property (nonatomic, weak) YHSSearchSuggestionViewController *searchSuggestionVC;

/** 热门标签容器 */
@property (nonatomic, weak) UIView *hotSearchTagsContentView;

/** 排名标签(第几名) */
@property (nonatomic, copy) NSArray<UILabel *> *rankTags;
/** 排名内容 */
@property (nonatomic, copy) NSArray<UILabel *> *rankTextLabels;
/** 排名整体标签（包含第几名和内容） */
@property (nonatomic, copy) NSArray<UIView *> *rankViews;

/** 搜索历史标签容器，只有在YHSSearchHistoryStyle值为YHSSearchHistoryStyleXXXTag才有值 */
@property (nonatomic, weak) UIView *searchHistoryTagsContentView;
/** 搜索历史标签的清空按钮 */
@property (nonatomic, weak) UIButton *emptyButton;

/** 基本搜索TableView(显示历史搜索和搜索记录) */
@property (nonatomic, strong) UITableView *baseSearchTableView;
/** 记录是否点击搜索建议 */
@property (nonatomic, assign) BOOL didClickSuggestionCell;

@end


@implementation YHSSearchViewController


- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}


+ (YHSSearchViewController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                                            searchBarPlaceholder:(NSString *)placeholder
{
    YHSSearchViewController *searchVC = [[YHSSearchViewController alloc] init];
    searchVC.hotSearches = hotSearches;
    searchVC.searchBar.placeholder = placeholder;
    return searchVC;
}


+ (YHSSearchViewController *)searchViewControllerWithHotSearches:(NSArray<NSString *> *)hotSearches
                                            searchBarPlaceholder:(NSString *)placeholder
                                                  didSearchBlock:(YHSDidSearchBlock)block
{
    YHSSearchViewController *searchVC = [[self class] searchViewControllerWithHotSearches:hotSearches searchBarPlaceholder:placeholder];
    searchVC.didSearchBlock = [block copy];
    return searchVC;
}


#pragma mark - 懒加载
- (UITableView *)baseSearchTableView
{
    if (!_baseSearchTableView) {
        UITableView *baseSearchTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        baseSearchTableView.backgroundColor = [UIColor clearColor];
        baseSearchTableView.delegate = self;
        baseSearchTableView.dataSource = self;
        [self.view addSubview:baseSearchTableView];
        _baseSearchTableView = baseSearchTableView;
    }
    return _baseSearchTableView;
}


- (YHSSearchSuggestionViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        YHSSearchSuggestionViewController *searchSuggestionVC = [[YHSSearchSuggestionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        __weak __typeof(&*self)_weakSelf = self;
        searchSuggestionVC.didSelectCellBlock = ^(UITableViewCell *didSelectCell) {
            // 设置搜索信息
            _weakSelf.searchBar.text = didSelectCell.textLabel.text;
            // 如果实现搜索建议代理方法则searchBarSearchButtonClicked失效
            if ([_weakSelf.delegate respondsToSelector:@selector(searchViewController:didSelectSearchSuggestionAtIndex:searchText:)]) {
                // 获取下标
                NSIndexPath *indexPath = [_weakSelf.searchSuggestionVC.tableView indexPathForCell:didSelectCell];
                [_weakSelf.delegate searchViewController:_weakSelf didSelectSearchSuggestionAtIndex:indexPath.row searchText:_weakSelf.searchBar.text];
            } else {
                // 点击搜索
                [_weakSelf searchBarSearchButtonClicked:_weakSelf.searchBar];
            }
        };
        searchSuggestionVC.view.frame = CGRectMake(0, YHS_SEARCH_STATUS_NAVIGATION_BAR_HEIGHT, self.view.yhs_width, self.view.yhs_height);
        searchSuggestionVC.tableView.contentInset = UIEdgeInsetsMake(-30, 0, self.keyboardHeight + 30, 0);
        searchSuggestionVC.view.backgroundColor = self.baseSearchTableView.backgroundColor;
        searchSuggestionVC.view.hidden = YES;
        // 设置数据源
        searchSuggestionVC.dataSource = self;
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}

- (UIButton *)emptyButton
{
    if (!_emptyButton) {
        // 添加清空按钮
        UIButton *emptyButton = [[UIButton alloc] init];
        emptyButton.titleLabel.font = self.searchHistoryHeader.font;
        [emptyButton setTitleColor:YHSTextColor forState:UIControlStateNormal];
        [emptyButton setTitle:@"清空" forState:UIControlStateNormal];
        [emptyButton setImage:YHSSearchEmptyImage forState:UIControlStateNormal];
        [emptyButton addTarget:self action:@selector(emptySearchHistoryDidClick) forControlEvents:UIControlEventTouchUpInside];
        [emptyButton sizeToFit];
        emptyButton.yhs_width += YHSSearchMargin;
        emptyButton.yhs_height += YHSSearchMargin;
        emptyButton.yhs_centerY = self.searchHistoryHeader.yhs_centerY;
        emptyButton.yhs_x = self.headerContentView.yhs_width - emptyButton.yhs_width;
        [self.headerContentView addSubview:emptyButton];
        _emptyButton = emptyButton;
    }
    return _emptyButton;
}

- (UIView *)searchHistoryTagsContentView
{
    if (!_searchHistoryTagsContentView) {
        UIView *searchHistoryTagsContentView = [[UIView alloc] init];
        searchHistoryTagsContentView.yhs_width = YHSScreenWidth - YHSSearchMargin * 2;
        searchHistoryTagsContentView.yhs_y = CGRectGetMaxY(self.hotSearchTagsContentView.frame) + YHSSearchMargin;
        [self.headerContentView addSubview:searchHistoryTagsContentView];
        _searchHistoryTagsContentView = searchHistoryTagsContentView;
    }
    return _searchHistoryTagsContentView;
}

- (UILabel *)searchHistoryHeader
{
    if (!_searchHistoryHeader) {
        UILabel *titleLabel = [self setupTitleLabel:YHSSearchHistoryText];
        [self.headerContentView addSubview:titleLabel];
        _searchHistoryHeader = titleLabel;
    }
    return _searchHistoryHeader;
}

- (NSMutableArray *)searchHistories
{
    if (!_searchHistories) {
        _searchHistories = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:self.searchHistoriesCachePath]];
    }
    return _searchHistories;
}

- (NSMutableArray *)colorPol
{
    if (!_colorPol) {
        NSArray *colorStrPol = @[@"009999", @"0099CC", @"0099FF", @"00CC99", @"00CCCC", @"336699", @"3366CC", @"3366FF", @"339966", @"666666", @"666699", @"6666CC", @"6666FF", @"996666", @"996699", @"999900", @"999933", @"99CC00", @"99CC33", @"660066", @"669933", @"990066", @"CC9900", @"CC6600" , @"CC3300", @"CC3366", @"CC6666", @"CC6699", @"CC0066", @"CC0033", @"FFCC00", @"FFCC33", @"FF9900", @"FF9933", @"FF6600", @"FF6633", @"FF6666", @"FF6699", @"FF3366", @"FF3333"];
        NSMutableArray *colorPolM = [NSMutableArray array];
        for (NSString *colorStr in colorStrPol) {
            UIColor *color = [UIColor colorFromHexString:colorStr];
            [colorPolM addObject:color];
        }
        _colorPol = colorPolM;
    }
    return _colorPol;
}

#pragma mark  包装cancelButton
- (UIBarButtonItem *)cancelButton
{
    return self.navigationItem.rightBarButtonItem;
}

/** 视图完全显示 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}

/** 视图即将消失 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 回收键盘
    [self.searchBar resignFirstResponder];
}

/** 控制器销毁 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/** 初始化 */
- (void)setup
{
    // 设置背景颜色为白色
    self.view.backgroundColor = [UIColor whiteColor];
    self.baseSearchTableView.showsVerticalScrollIndicator = NO;
    self.baseSearchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(cancelDidClick)];
    
    /**
     * 设置一些默认设置
     */
    // 热门搜索风格设置
    self.hotSearchStyle = YHSHotSearchStyleDefault;
    // 设置搜索历史风格
    self.searchHistoryStyle = YHSHotSearchStyleDefault;
    // 设置搜索结果显示模式
    self.searchResultShowMode = YHSSearchResultShowModeDefault;
    // 显示搜索建议
    self.searchSuggestionHidden = NO;
    // 搜索历史缓存路径
    self.searchHistoriesCachePath = YHSSearchHistoriesPath;
    // 搜索历史缓存最多条数
    self.searchHistoriesCount = YHSSearchHistoriesCountMax;
    
    
    // 创建搜索框
    UIView *titleView = [[UIView alloc] init];
    titleView.yhs_x = YHSSearchMargin * 0.5;
    titleView.yhs_y = (YHS_SEARCH_NAVIGATION_BAR_HEIGHT-YHS_SEARCH_SEARCH_BAR_HEIGHT)/2.0;
    titleView.yhs_width = self.view.yhs_width - 64 - titleView.yhs_x * 2;
    titleView.yhs_height = YHS_SEARCH_SEARCH_BAR_HEIGHT;
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:titleView.bounds];
    searchBar.yhs_width -= YHSSearchMargin * 1.0;
    searchBar.placeholder = YHSSearchPlaceholderText;
    searchBar.backgroundImage = YHSSearchBarImage;
    searchBar.delegate = self;
    [titleView addSubview:searchBar];
    self.searchBar = searchBar;
    self.navigationItem.titleView = titleView;

    
    // 设置头部（热门搜索）
    UIView *tableHeaderView = [[UIView alloc] init];
    // 热门搜索 - 主容器
    UIView *contentView = [[UIView alloc] init];
    contentView.yhs_y = YHSSearchMargin * 2;
    contentView.yhs_x = YHSSearchMargin * 1.5;
    contentView.yhs_width = YHSScreenWidth - contentView.yhs_x * 2;
    [tableHeaderView addSubview:contentView];
    // 热门搜索 - 标题
    UILabel *titleLabel = [self setupTitleLabel:YHSHotSearchText];
    [contentView addSubview:titleLabel];
    // 热门搜索 - 标签容器
    UIView *hotSearchTagsContentView = [[UIView alloc] init];
    hotSearchTagsContentView.yhs_width = contentView.yhs_width;
    hotSearchTagsContentView.yhs_y = CGRectGetMaxY(titleLabel.frame) + YHSSearchMargin;
    [contentView addSubview:hotSearchTagsContentView];
    self.headerContentView = contentView;
    self.hotSearchHeader = titleLabel;
    self.hotSearchTagsContentView = hotSearchTagsContentView;
    self.baseSearchTableView.tableHeaderView = tableHeaderView;
    
    
    // 设置底部(清除历史搜索)
    UIView *footerView = [[UIView alloc] init];
    footerView.yhs_width = YHSScreenWidth;
    UILabel *emptySearchHistoryLabel = [[UILabel alloc] init];
    emptySearchHistoryLabel.textColor = [UIColor darkGrayColor];
    emptySearchHistoryLabel.font = [UIFont systemFontOfSize:13];
    emptySearchHistoryLabel.userInteractionEnabled = YES;
    emptySearchHistoryLabel.text = YHSClearSearchHistoryText;
    emptySearchHistoryLabel.textAlignment = NSTextAlignmentCenter;
    emptySearchHistoryLabel.yhs_height = 30;
    [emptySearchHistoryLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(emptySearchHistoryDidClick)]];
    emptySearchHistoryLabel.yhs_width = YHSScreenWidth;
    [footerView addSubview:emptySearchHistoryLabel];
    footerView.yhs_height = 30;
    self.baseSearchTableView.tableFooterView = footerView;
    
    
    // 默认没有热门搜索
    self.hotSearches = nil;
}


/** 创建并设置标题 */
- (UILabel *)setupTitleLabel:(NSString *)title
{
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.tag = 1;
    titleLabel.textColor = YHSTextColor;
    [titleLabel sizeToFit];
    titleLabel.yhs_x = 0;
    titleLabel.yhs_y = 0;
    return titleLabel;
}


/** 设置热门搜索矩形标签 YHSHotSearchStyleRectangleTag */
- (void)setupHotSearchRectangleTags
{
    // 获取标签容器
    UIView *contentView = self.hotSearchTagsContentView;
    // 调整容器布局
    contentView.yhs_width = YHSScreenWidth;
    contentView.yhs_x = -YHSSearchMargin * 1.5;
    contentView.yhs_y += 2;
    contentView.backgroundColor = [UIColor whiteColor];
    // 设置TableView背景颜色
    self.baseSearchTableView.backgroundColor = [UIColor colorFromHexString:@"#EFEFEF"];
    // 清空标签容器的子控件
    [self.hotSearchTagsContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加热门搜索矩形标签
    CGFloat rectangleTagH = 40; // 矩形框高度
    for (int i = 0; i < self.hotSearches.count; i++) {
        // 创建标签
        UILabel *rectangleTagLabel = [[UILabel alloc] init];
        // 设置属性
        rectangleTagLabel.userInteractionEnabled = YES;
        rectangleTagLabel.font = [UIFont systemFontOfSize:14];
        rectangleTagLabel.textColor = YHSTextColor;
        rectangleTagLabel.backgroundColor = [UIColor clearColor];
        rectangleTagLabel.text = self.hotSearches[i];
        rectangleTagLabel.yhs_width = contentView.yhs_width / YHSRectangleTagMaxCol;
        rectangleTagLabel.yhs_height = rectangleTagH;
        rectangleTagLabel.textAlignment = NSTextAlignmentCenter;
        [rectangleTagLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        // 计算布局
        rectangleTagLabel.yhs_x = rectangleTagLabel.yhs_width * (i % YHSRectangleTagMaxCol);
        rectangleTagLabel.yhs_y = rectangleTagLabel.yhs_height * (i / YHSRectangleTagMaxCol);
        // 添加标签
        [contentView addSubview:rectangleTagLabel];
    }
    
    // 设置标签容器高度
    contentView.yhs_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    // 设置TableHeaderView高度
    self.baseSearchTableView.tableHeaderView.yhs_height = self.headerContentView.yhs_height = CGRectGetMaxY(contentView.frame) + YHSSearchMargin * 2;
    // 添加分割线
    for (int i = 0; i < YHSRectangleTagMaxCol - 1; i++) { // 添加垂直分割线
        UIImageView *verticalLine = [[UIImageView alloc] initWithImage:YHSSearchSeparatorLineVerticalImage];
        verticalLine.yhs_height = contentView.yhs_height;
        verticalLine.alpha = 0.7;
        verticalLine.yhs_x = contentView.yhs_width / YHSRectangleTagMaxCol * (i + 1);
        verticalLine.yhs_width = 0.5;
        [contentView addSubview:verticalLine];
    }
    for (int i = 0; i < ceil(((double)self.hotSearches.count / YHSRectangleTagMaxCol)) - 1; i++) { // 添加水平分割线, ceil():向上取整函数
        UIImageView *horizontalLine = [[UIImageView alloc] initWithImage:YHSSearchSeparatorLineHorizontalImage];
        horizontalLine.yhs_height = 0.5;
        horizontalLine.alpha = 0.7;
        horizontalLine.yhs_y = rectangleTagH * (i + 1);
        horizontalLine.yhs_width = contentView.yhs_width;
        [contentView addSubview:horizontalLine];
    }
    // 重新赋值，注意：当操作系统为iOS 9.x系列的TableHeaderView高度设置失效，需要重新设置tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
}


/** 设置热门搜索标签（带有排名）YHSHotSearchStyleRankTag */
- (void)setupHotSearchRankTags
{
    // 获取标签容器
    UIView *contentView = self.hotSearchTagsContentView;
    // 清空标签容器的子控件
    [self.hotSearchTagsContentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加热门搜索标签
    NSMutableArray *rankTextLabelsM = [NSMutableArray array];
    NSMutableArray *rankTagM = [NSMutableArray array];
    NSMutableArray *rankViewM = [NSMutableArray array];
    for (int i = 0; i < self.hotSearches.count; i++) {
        // 整体标签
        UIView *rankView = [[UIView alloc] init];
        rankView.yhs_height = 40;
        rankView.yhs_width = (YHSScreenWidth - YHSSearchMargin * 3) * 0.5;
        [contentView addSubview:rankView];
        // 排名
        UILabel *rankTag = [[UILabel alloc] init];
        rankTag.textAlignment = NSTextAlignmentCenter;
        rankTag.font = [UIFont systemFontOfSize:10];
        rankTag.layer.cornerRadius = 3;
        rankTag.clipsToBounds = YES;
        rankTag.text = [NSString stringWithFormat:@"%d", i + 1];
        [rankTag sizeToFit];
        rankTag.yhs_width = rankTag.yhs_height += YHSSearchMargin * 0.5;
        rankTag.yhs_y = (rankView.yhs_height - rankTag.yhs_height) * 0.5;
        [rankView addSubview:rankTag];
        [rankTagM addObject:rankTag];
        // 内容
        UILabel *rankTextLabel = [[UILabel alloc] init];
        rankTextLabel.text = self.hotSearches[i];
        rankTextLabel.userInteractionEnabled = YES;
        [rankTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        rankTextLabel.textAlignment = NSTextAlignmentLeft;
        rankTextLabel.backgroundColor = [UIColor clearColor];
        rankTextLabel.textColor = YHSTextColor;
        rankTextLabel.font = [UIFont systemFontOfSize:14];
        rankTextLabel.yhs_x = CGRectGetMaxX(rankTag.frame) + YHSSearchMargin;
        rankTextLabel.yhs_width = (YHSScreenWidth - YHSSearchMargin * 3) * 0.5 - rankTextLabel.yhs_x;
        rankTextLabel.yhs_height = rankView.yhs_height;
        [rankTextLabelsM addObject:rankTextLabel];
        [rankView addSubview:rankTextLabel];
        // 添加分割线
        UIImageView *line = [[UIImageView alloc] initWithImage:YHSSearchSeparatorLineHorizontalImage];
        line.yhs_height = 0.5;
        line.alpha = 0.7;
        line.yhs_x = -YHSScreenWidth * 0.5;
        line.yhs_y = rankView.yhs_height - 1;
        line.yhs_width = YHSScreenWidth;
        [rankView addSubview:line];
        [rankViewM addObject:rankView];
        
        // 设置排名标签的背景色和字体颜色
        switch (i) {
            case 0: // 第一名
                rankTag.backgroundColor = [UIColor colorFromHexString:self.rankTagBackgroundColorHexStrings[0]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            case 1: // 第二名
                rankTag.backgroundColor = [UIColor colorFromHexString:self.rankTagBackgroundColorHexStrings[1]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            case 2: // 第三名
                rankTag.backgroundColor = [UIColor colorFromHexString:self.rankTagBackgroundColorHexStrings[2]];
                rankTag.textColor = [UIColor whiteColor];
                break;
            default: // 其他
                rankTag.backgroundColor = [UIColor colorFromHexString:self.rankTagBackgroundColorHexStrings[3]];
                rankTag.textColor = YHSTextColor;
                break;
        }
    }
    self.rankTextLabels = rankTextLabelsM;
    self.rankTags = rankTagM;
    self.rankViews = rankViewM;
    
    // 计算位置
    for (int i = 0; i < self.rankViews.count; i++) { // 每行两个
        UIView *rankView = self.rankViews[i];
        rankView.yhs_x = (YHSSearchMargin + rankView.yhs_width) * (i % 2);
        rankView.yhs_y = rankView.yhs_height * (i / 2);
    }
    // 设置标签容器高度
    contentView.yhs_height = CGRectGetMaxY(self.rankViews.lastObject.frame);
    // 设置tableHeaderView高度
    self.baseSearchTableView.tableHeaderView.yhs_height  = self.headerContentView.yhs_height = CGRectGetMaxY(contentView.frame) + YHSSearchMargin * 2;
    // 重新赋值，注意：当操作系统为iOS 9.x系列的TableHeaderView高度设置失效，需要重新设置tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
}


/**
 * 设置热门搜索标签(不带排名)
 * YHSHotSearchStyleNormalTag || YHSHotSearchStyleColorfulTag ||
 * YHSHotSearchStyleBorderTag || YHSHotSearchStyleARCBorderTag
 */
- (void)setupHotSearchNormalTags
{
    // 添加和布局标签
    self.hotSearchTags = [self addAndLayoutTagsWithTagsContentView:self.hotSearchTagsContentView tagTexts:self.hotSearches];
    // 根据hotSearchStyle设置标签样式
    [self setHotSearchStyle:self.hotSearchStyle];
}


/**
 * 设置搜索历史标签
 * YHSSearchHistoryStyleTag
 */
- (void)setupSearchHistoryTags
{
    // 隐藏尾部清除按钮
    self.baseSearchTableView.tableFooterView = nil;
    // 添加搜索历史头部
    self.searchHistoryHeader.yhs_y = self.hotSearches.count > 0 ? CGRectGetMaxY(self.hotSearchTagsContentView.frame) + YHSSearchMargin * 1.5 : 0;
    self.emptyButton.yhs_y = self.searchHistoryHeader.yhs_y - YHSSearchMargin * 0.5;
    self.searchHistoryTagsContentView.yhs_y = CGRectGetMaxY(self.emptyButton.frame) + YHSSearchMargin;
    // 添加和布局标签
    self.searchHistoryTags = [self addAndLayoutTagsWithTagsContentView:self.searchHistoryTagsContentView tagTexts:[self.searchHistories copy]];
}


/**  添加和布局标签 */
- (NSArray *)addAndLayoutTagsWithTagsContentView:(UIView *)contentView tagTexts:(NSArray<NSString *> *)tagTexts;
{
    // 清空标签容器的子控件
    [contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 添加热门搜索标签
    NSMutableArray *tagsM = [NSMutableArray array];
    for (int i = 0; i < tagTexts.count; i++) {
        UILabel *label = [self labelWithTitle:tagTexts[i]];
        [label addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagDidCLick:)]];
        [contentView addSubview:label];
        [tagsM addObject:label];
    }
    
    // 计算位置
    CGFloat currentX = 0;
    CGFloat currentY = 0;
    CGFloat countRow = 0;
    CGFloat countCol = 0;
    
    // 调整布局
    for (int i = 0; i < contentView.subviews.count; i++) {
        UILabel *subView = contentView.subviews[i];
        // 当搜索字数过多，宽度为contentView的宽度
        if (subView.yhs_width > contentView.yhs_width) {
            subView.yhs_width = contentView.yhs_width;
        }
        if (currentX + subView.yhs_width + YHSSearchMargin * countRow > contentView.yhs_width) { // 得换行
            subView.yhs_x = 0;
            subView.yhs_y = (currentY += subView.yhs_height) + YHSSearchMargin * ++countCol;
            currentX = subView.yhs_width;
            countRow = 1;
        } else { // 不换行
            subView.yhs_x = (currentX += subView.yhs_width) - subView.yhs_width + YHSSearchMargin * countRow;
            subView.yhs_y = currentY + YHSSearchMargin * countCol;
            countRow ++;
        }
    }
    // 设置contentView高度
    contentView.yhs_height = CGRectGetMaxY(contentView.subviews.lastObject.frame);
    // 设置头部高度
    self.baseSearchTableView.tableHeaderView.yhs_height = self.headerContentView.yhs_height = CGRectGetMaxY(contentView.frame) + YHSSearchMargin * 2;
    // 取消隐藏
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    // 重新赋值, 注意：当操作系统为iOS 9.x系列的TableHeaderView高度设置失效，需要重新设置tableHeaderView
    [self.baseSearchTableView setTableHeaderView:self.baseSearchTableView.tableHeaderView];
    return [tagsM copy];
}


#pragma mark - 事件处理
/** 点击取消 */
- (void)cancelDidClick
{
    [self.searchBar resignFirstResponder];
    
    // dismiss ViewController
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // 调用代理方法
    if ([self.delegate respondsToSelector:@selector(didClickCancel:)]) {
        [self.delegate didClickCancel:self];
    }
}


/** 键盘显示完成（弹出） */
- (void)keyboardDidShow:(NSNotification *)noti
{
    // 取出键盘高度
    NSDictionary *info = noti.userInfo;
    self.keyboardHeight = [info[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.keyboardshowing = YES;
}


/** 点击清空历史按钮 */
- (void)emptySearchHistoryDidClick
{
    // 移除所有历史搜索
    [self.searchHistories removeAllObjects];
    // 移除数据缓存
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    if (self.searchHistoryStyle == YHSSearchHistoryStyleCell) {
        // 刷新cell
        [self.baseSearchTableView reloadData];
    } else {
        // 更新
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
    YHSSearchLog(@"清空历史记录");
}


/** 选中标签 */
- (void)tagDidCLick:(UITapGestureRecognizer *)gr
{
    UILabel *label = (UILabel *)gr.view;
    self.searchBar.text = label.text;
    
    if (label.tag == 1) { // 热门搜索标签
        // 取出下标
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectHotSearchAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectHotSearchAtIndex:[self.hotSearchTags indexOfObject:label] searchText:label.text];
        } else {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    } else { // 搜索历史标签
        if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) {
            [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:[self.searchHistoryTags indexOfObject:label] searchText:label.text];
        } else {
            [self searchBarSearchButtonClicked:self.searchBar];
        }
    }
    YHSSearchLog(@"搜索 %@", label.text);
}


/** 添加标签 */
- (UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.userInteractionEnabled = YES;
    label.font = [UIFont systemFontOfSize:12];
    label.text = title;
    label.textColor = [UIColor grayColor];
    label.backgroundColor = [UIColor colorFromHexString:@"#FAFAFA"];
    label.layer.cornerRadius = 3;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.yhs_width += 20;
    label.yhs_height += 14;
    return label;
}


#pragma mark - Setter
- (void)setCancelButton:(UIBarButtonItem *)cancelButton
{
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)setSearchHistoriesCachePath:(NSString *)searchHistoriesCachePath
{
    _searchHistoriesCachePath = [searchHistoriesCachePath copy];
    // 刷新
    self.searchHistories = nil;
    if (self.searchHistoryStyle == YHSSearchHistoryStyleCell) { // 搜索历史为cell类型
        [self.baseSearchTableView reloadData];
    } else { // 搜索历史为标签类型
        [self setSearchHistoryStyle:self.searchHistoryStyle];
    }
}


- (void)setHotSearchTags:(NSArray<UILabel *> *)hotSearchTags
{
    // 设置热门搜索时(标签tag为1，搜索历史为0)
    for (UILabel *tagLabel in hotSearchTags) {
        tagLabel.tag = 1;
    }
    _hotSearchTags = hotSearchTags;
}


- (void)setSearchBarBackgroundColor:(UIColor *)searchBarBackgroundColor
{
    _searchBarBackgroundColor = searchBarBackgroundColor;
    
    // 取出搜索栏的textField设置其背景色
    for (UIView *subView in [[self.searchBar.subviews lastObject] subviews]) {
        if ([[subView class] isSubclassOfClass:[UITextField class]]) { // 是UItextField
            // 设置UItextField的背景色
            UITextField *textField = (UITextField *)subView;
            textField.backgroundColor = searchBarBackgroundColor;
            // 退出循环
            break;
        }
    }
}


- (void)setSearchSuggestions:(NSArray<NSString *> *)searchSuggestions
{
    if (self.searchSuggestionHidden) return; // 如果隐藏，直接返回，避免刷新操作
    
    _searchSuggestions = [searchSuggestions copy];
    // 赋值给搜索建议控制器
    self.searchSuggestionVC.searchSuggestions = [searchSuggestions copy];
}


- (void)setRankTagBackgroundColorHexStrings:(NSArray<NSString *> *)rankTagBackgroundColorHexStrings
{
    if (rankTagBackgroundColorHexStrings.count < 4) { // 不符合要求，使用基本设置
        NSArray *colorStrings = @[@"#f14230", @"#ff8000", @"#ffcc01", @"#ebebeb"];
        _rankTagBackgroundColorHexStrings = colorStrings;
    } else { // 取前四个
        _rankTagBackgroundColorHexStrings = @[rankTagBackgroundColorHexStrings[0], rankTagBackgroundColorHexStrings[1], rankTagBackgroundColorHexStrings[2], rankTagBackgroundColorHexStrings[3]];
    }
    
    // 刷新
    self.hotSearches = self.hotSearches;
}


- (void)setHotSearches:(NSArray *)hotSearches
{
    _hotSearches = hotSearches;
    // 没有热门搜索,隐藏相关控件，直接返回
    if (hotSearches.count == 0) {
        self.baseSearchTableView.tableHeaderView.hidden = YES;
        self.hotSearchHeader.hidden = YES;
        return;
    };
    // 有热门搜索，取消相关隐藏
    self.baseSearchTableView.tableHeaderView.hidden = NO;
    self.hotSearchHeader.hidden = NO;
    // 根据hotSearchStyle设置标签
    if (self.hotSearchStyle == YHSHotSearchStyleDefault
        || self.hotSearchStyle == YHSHotSearchStyleColorfulTag
        || self.hotSearchStyle == YHSHotSearchStyleBorderTag
        || self.hotSearchStyle == YHSHotSearchStyleARCBorderTag) { // 不带排名的标签
        [self setupHotSearchNormalTags];
    } else if (self.hotSearchStyle == YHSHotSearchStyleRankTag) { // 带有排名的标签
        [self setupHotSearchRankTags];
    } else if (self.hotSearchStyle == YHSHotSearchStyleRectangleTag) { // 矩阵标签
        [self setupHotSearchRectangleTags];
    }
    // 刷新搜索历史布局
    [self setSearchHistoryStyle:self.searchHistoryStyle];
}


- (void)setSearchHistoryStyle:(YHSSearchHistoryStyle)searchHistoryStyle
{
    _searchHistoryStyle = searchHistoryStyle;
    
    // 默认cell，直接返回
    if (searchHistoryStyle == UISearchBarStyleDefault) return;
    // 创建、初始化默认标签
    [self setupSearchHistoryTags];
    // 根据标签风格设置标签
    switch (searchHistoryStyle) {
        case YHSSearchHistoryStyleColorfulTag: // 彩色标签
            for (UILabel *tag in self.searchHistoryTags) {
                // 设置字体颜色为白色
                tag.textColor = [UIColor whiteColor];
                // 取消边框
                tag.layer.borderColor = nil;
                tag.layer.borderWidth = 0.0;
                tag.backgroundColor = YHSColorPolRandomColor;
            }
            break;
        case YHSSearchHistoryStyleBorderTag: // 边框标签
            for (UILabel *tag in self.searchHistoryTags) {
                // 设置背景色为clearColor
                tag.backgroundColor = [UIColor clearColor];
                // 设置边框颜色
                tag.layer.borderColor = YHSSearchColor(223, 223, 223).CGColor;
                // 设置边框宽度
                tag.layer.borderWidth = 0.5;
            }
            break;
        case YHSSearchHistoryStyleARCBorderTag: // 圆弧边框标签
            for (UILabel *tag in self.searchHistoryTags) {
                // 设置背景色为clearColor
                tag.backgroundColor = [UIColor clearColor];
                // 设置边框颜色
                tag.layer.borderColor = YHSSearchColor(223, 223, 223).CGColor;
                // 设置边框宽度
                tag.layer.borderWidth = 0.5;
                // 设置边框弧度为圆弧
                tag.layer.cornerRadius = tag.yhs_height * 0.5;
            }
            break;
            
        default:
            break;
    }
}

- (void)setHotSearchStyle:(YHSHotSearchStyle)hotSearchStyle
{
    _hotSearchStyle = hotSearchStyle;
    switch (hotSearchStyle) {
        case YHSHotSearchStyleColorfulTag: // 彩色标签
            for (UILabel *tag in self.hotSearchTags) {
                // 设置字体颜色为白色
                tag.textColor = [UIColor whiteColor];
                // 取消边框
                tag.layer.borderColor = nil;
                tag.layer.borderWidth = 0.0;
                tag.backgroundColor = YHSColorPolRandomColor;
            }
            break;
        case YHSHotSearchStyleBorderTag: // 边框标签
            for (UILabel *tag in self.hotSearchTags) {
                // 设置背景色为clearColor
                tag.backgroundColor = [UIColor clearColor];
                // 设置边框颜色
                tag.layer.borderColor = YHSSearchColor(223, 223, 223).CGColor;
                // 设置边框宽度
                tag.layer.borderWidth = 0.5;
            }
            break;
        case YHSHotSearchStyleARCBorderTag: // 圆弧边框标签
            for (UILabel *tag in self.hotSearchTags) {
                // 设置背景色为clearColor
                tag.backgroundColor = [UIColor clearColor];
                // 设置边框颜色
                tag.layer.borderColor = YHSSearchColor(223, 223, 223).CGColor;
                // 设置边框宽度
                tag.layer.borderWidth = 0.5;
                // 设置边框弧度为圆弧
                tag.layer.cornerRadius = tag.yhs_height * 0.5;
            }
            break;
        case YHSHotSearchStyleRectangleTag: // 九宫格标签
            self.hotSearches = self.hotSearches;
            break;
        case YHSHotSearchStyleRankTag: // 排名标签
            self.rankTagBackgroundColorHexStrings = nil;
            break;
            
        default:
            break;
    }
}


#pragma mark - YHSSearchSuggestionViewDataSource
- (NSInteger)numberOfSectionsInSearchSuggestionView:(UITableView *)searchSuggestionView
{
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInSearchSuggestionView:)]) {
        return [self.dataSource numberOfSectionsInSearchSuggestionView:searchSuggestionView];
    }
    return 1;
}

- (NSInteger)searchSuggestionView:(UITableView *)searchSuggestionView numberOfRowsInSection:(NSInteger)section
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:numberOfRowsInSection:)]) {
        return [self.dataSource searchSuggestionView:searchSuggestionView numberOfRowsInSection:section];
    }
    return self.searchSuggestions.count;
}

- (UITableViewCell *)searchSuggestionView:(UITableView *)searchSuggestionView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:cellForRowAtIndexPath:)]) {
        return [self.dataSource searchSuggestionView:searchSuggestionView cellForRowAtIndexPath:indexPath];
    }
    return nil;
}

- (CGFloat)searchSuggestionView:(UITableView *)searchSuggestionView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dataSource respondsToSelector:@selector(searchSuggestionView:heightForRowAtIndexPath:)]) {
        return [self.dataSource searchSuggestionView:searchSuggestionView heightForRowAtIndexPath:indexPath];
    }
    return YHS_SEARCH_TABLE_VIEW_CELL_HEIGHT_DEFAULT;
}


#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 回收键盘
    [searchBar resignFirstResponder];
    // 先移除再刷新
    [self.searchHistories removeObject:searchBar.text];
    [self.searchHistories insertObject:searchBar.text atIndex:0];
    // 刷新数据
    if (self.searchHistoryStyle == YHSSearchHistoryStyleCell) { // 普通风格Cell
        [self.baseSearchTableView reloadData];
    } else { // 搜索历史为标签
        // 更新
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
    // 移除多余的缓存
    if (self.searchHistories.count > self.searchHistoriesCount) {
        // 移除最后一条缓存
        [self.searchHistories removeLastObject];
    }
    // 刷新页面
    if (self.searchHistoryStyle == YHSSearchHistoryStyleCell) { // 搜索历史为标签时，刷新标签
        // 刷新tableView
        [self.baseSearchTableView reloadData];
    } else {
        // 更新
        self.searchHistoryStyle = self.searchHistoryStyle;
    }
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:self.searchHistoriesCachePath];
    // 处理搜索结果
    switch (self.searchResultShowMode) {
        case YHSSearchResultShowModePush: // Push
            self.searchResultController.view.hidden = NO;
            [self.navigationController pushViewController:self.searchResultController animated:YES];
            break;
        case YHSSearchResultShowModeEmbed: // 内嵌
            // 添加搜索结果的视图
            [self.view addSubview:self.searchResultController.view];
            [self addChildViewController:self.searchResultController];
            self.searchResultController.view.hidden = NO;
            self.searchResultController.view.yhs_y = YHS_SEARCH_STATUS_NAVIGATION_BAR_HEIGHT;
            self.searchSuggestionVC.view.hidden = YES;
            break;
        case YHSSearchResultShowModeCustom: // 自定义
            
            break;
        default:
            break;
    }
    // 如果代理实现了代理方法则调用代理方法
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSearchWithsearchBar:searchText:)]) {
        [self.delegate searchViewController:self didSearchWithsearchBar:searchBar searchText:searchBar.text];
        return;
    }
    // 如果有block则调用
    if (self.didSearchBlock) self.didSearchBlock(self, searchBar, searchBar.text);
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 如果有搜索文本且显示搜索建议，则隐藏
    self.baseSearchTableView.hidden = searchText.length && !self.searchSuggestionHidden;
    // 根据输入文本显示建议搜索条件
    self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !searchText.length;
    // 放在最上层
    [self.view bringSubviewToFront:self.searchSuggestionVC.view];
    // 如果代理实现了代理方法则调用代理方法
    if ([self.delegate respondsToSelector:@selector(searchViewController:searchTextDidChange:searchText:)]) {
        [self.delegate searchViewController:self searchTextDidChange:searchBar searchText:searchText];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (self.searchResultShowMode == YHSSearchResultShowModeEmbed) { // 搜索结果为内嵌时
        // 搜索结果隐藏
        self.searchResultController.view.hidden = YES;
        // 根据输入文本显示建议搜索条件
        self.searchSuggestionVC.view.hidden = self.searchSuggestionHidden || !searchBar.text.length; // 如果有搜索文本且显示搜索建议，则隐藏
        self.baseSearchTableView.hidden = searchBar.text.length && !self.searchSuggestionHidden;
    }
    return YES;
}

- (void)closeDidClick:(UIButton *)sender
{
    // 获取当前Cell
    UITableViewCell *cell = (UITableViewCell *)sender.superview;
    // 移除搜索信息
    [self.searchHistories removeObject:cell.textLabel.text];
    // 保存搜索信息
    [NSKeyedArchiver archiveRootObject:self.searchHistories toFile:YHSSearchHistoriesPath];
    // 刷新
    [self.baseSearchTableView reloadData];
}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 没有搜索记录就隐藏
    self.baseSearchTableView.tableFooterView.hidden = self.searchHistories.count == 0;
    return  self.searchHistoryStyle == YHSSearchHistoryStyleCell ? self.searchHistories.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"YHSSearchHistoryCellID";
    // 创建cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.textLabel.textColor = YHSTextColor;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.backgroundColor = [UIColor clearColor];
        
        // 添加关闭按钮
        UIButton *closetButton = [[UIButton alloc] init];
        // 设置图片容器大小、图片原图居中
        closetButton.yhs_size = CGSizeMake(cell.yhs_height, cell.yhs_height);
        [closetButton setImage:YHSSearchCloseImage forState:UIControlStateNormal];
        UIImageView *closeView = [[UIImageView alloc] initWithImage:YHSSearchCloseImage];
        [closetButton addTarget:self action:@selector(closeDidClick:) forControlEvents:UIControlEventTouchUpInside];
        closeView.contentMode = UIViewContentModeCenter;
        cell.accessoryView = closetButton;
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
    cell.imageView.image = YHSSearchHistoryImage;
    cell.textLabel.text = self.searchHistories[indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.searchHistories.count && self.searchHistoryStyle == YHSSearchHistoryStyleCell ? YHSSearchHistoryText : nil;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取出选中的cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.searchBar.text = cell.textLabel.text;
    
    if ([self.delegate respondsToSelector:@selector(searchViewController:didSelectSearchHistoryAtIndex:searchText:)]) { // 实现代理方法则调用，则搜索历史时searchViewController:didSearchWithsearchBar:searchText:失效
        [self.delegate searchViewController:self didSelectSearchHistoryAtIndex:indexPath.row searchText:cell.textLabel.text];
    } else {
        [self searchBarSearchButtonClicked:self.searchBar];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滚动时，回收键盘
    if (self.keyboardshowing) {
        [self.searchBar resignFirstResponder];
    }
}


@end



