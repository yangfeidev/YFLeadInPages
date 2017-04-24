//
//  YFSearchViewController.m
//  YFLeadInPages
//
//  Created by YangFei on 2017/2/7.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import "YFSearchViewController.h"
#import "YFHotSearchCell.h"




#define YFUserDefaults   [NSUserDefaults standardUserDefaults]
static NSString * const  searchRecordArrayKey = @"searchRecordArrayKey";

@interface YFSearchViewController () <UISearchBarDelegate,
                                      UITableViewDelegate,
                                      UITableViewDataSource,
                                      UIScrollViewDelegate, YFHotSearchCellDelegate>
/** 搜搜框 */
@property (nonatomic, strong) UISearchBar *searchBar;
/** 点击搜索的背景 tableView */
@property (nonatomic, strong) UITableView *backgroundTableView;
/** 搜索结果显示的 tableView */
@property (nonatomic, strong) UITableView *resultTableView;

/** 保存 搜索记录的数组 */
@property (nonatomic, strong) NSMutableArray *searchRecordArray;

/** 保存 搜索结果的数组 */
@property (nonatomic, strong) NSMutableArray *searchResultArray;
/** 保存 造数据 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/** 存放热门搜索的数组 */
@property (nonatomic, strong) NSArray *hotSearchsArray;


@property (nonatomic, assign) CGFloat cellHeight;



@end

@implementation YFSearchViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.searchRecordArray = [NSMutableArray array];
    self.dataArray = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.hidesBackButton = YES;

    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitle:@"取消"];
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
                         setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}
                                       forState:UIControlStateNormal];
    
    
#pragma clang diagnostic pop
    [_searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar becomeFirstResponder];
    
    self.searchRecordArray = [NSMutableArray arrayWithArray:[YFUserDefaults objectForKey:searchRecordArrayKey]];
    
    [self.resultTableView reloadData];
    
    // 造点虚假数据
    for (int i= 0; i < 100; ++i) {
        [self.dataArray addObject:[NSString stringWithFormat:@"我是第%d行",i]];
    }
    
    self.hotSearchsArray = @[@"KobeBryant",@"LebronJames",@"Poul",@"YangFeiBestMan",@"HLBestWomenInWorld",@"HLBestWomenInTheWorld",@"LuVV",@"XiaoYuZai",@"LebronJames",@"Poul",@"KobeBryant",@"LebronJames",@"Poul",@"YangFeiBestManHaHa"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - /**************** lazy load ****************/
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索商品关键字";
        
        // 把默认灰色背景浮层给去掉
        self.searchBar.backgroundColor = [UIColor clearColor];
        self.searchBar.backgroundImage = [UIImage new];
        UITextField *searBarTextField = [self.searchBar valueForKey:@"_searchField"];
        if (searBarTextField) {
            searBarTextField.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
            searBarTextField.borderStyle = UITextBorderStyleRoundedRect;
            searBarTextField.layer.cornerRadius = 5.0f;
        }
        else {
            // 通过颜色画一个Image出来
            UIImage *image = [self imageWithColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1] size:CGSizeMake(28, 28)];
            [self.searchBar setSearchFieldBackgroundImage:image forState:UIControlStateNormal];
        }
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (UIView *)backgroundTableView {
    if (_backgroundTableView == nil) {
        CGRect backgroundTableViewFrame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64);
        _backgroundTableView = [[UITableView alloc] initWithFrame:backgroundTableViewFrame style:UITableViewStylePlain];
        _backgroundTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIButton *footerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        footerBtn.frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
        [footerBtn setTitle:@"删除所有记录" forState:UIControlStateNormal];
        footerBtn.backgroundColor = [UIColor lightGrayColor];
        [footerBtn addTarget:self action:@selector(clearSearchRecord) forControlEvents:UIControlEventTouchUpInside];
        _backgroundTableView.tableFooterView = footerBtn;
        
        _backgroundTableView.delegate = self;
        _backgroundTableView.dataSource = self;
    }
    return _backgroundTableView;
}



- (void)clearSearchRecord {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示"
                                                                     message:@"确定删除所有吗?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        self.searchRecordArray = [NSMutableArray array];
        [YFUserDefaults setObject:self.searchRecordArray forKey:searchRecordArrayKey];
                                                       
        [self.backgroundTableView reloadData];
    }];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertVC addAction:actionDone];
    [alertVC addAction:actionCancel];
    
    [self presentViewController:alertVC animated:YES completion:nil];

}

- (UITableView *)resultTableView {
    if (_resultTableView == nil) {
        _resultTableView = [[UITableView alloc] initWithFrame:self.backgroundTableView.bounds style:UITableViewStylePlain];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
    }
    return _resultTableView;
}

#pragma mark - /**************** searchBarDelegate ****************/

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    
    [self.view addSubview:self.backgroundTableView];
    
    [self.backgroundTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    self.searchBar.text = nil;
    
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"%@",searchText);
    
    /** 通过谓词修饰的方式来查找包含我们搜索关键字的数据 */
    self.searchResultArray = [NSMutableArray array];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"self contains[cd] %@",searchBar.text];
    self.searchResultArray = [NSMutableArray arrayWithArray:[self.dataArray filteredArrayUsingPredicate:resultPredicate]];
    [self.resultTableView reloadData];
    
    
    if ([searchText isEqualToString:@""]) {
        [self.resultTableView removeFromSuperview];
    } else {
        [self.backgroundTableView addSubview:self.resultTableView];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    if (!searchBar.text.length) return;
    
    NSLog(@"searchBtnClicked: %@",searchBar.text);

    self.searchRecordArray = [NSMutableArray arrayWithArray:[YFUserDefaults objectForKey:searchRecordArrayKey]];
    
    [self.searchRecordArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:searchBar.text]) {
            [self.searchRecordArray removeObject:obj];
        }
    }];
 
    [self.searchRecordArray insertObject:searchBar.text atIndex:0];
    [YFUserDefaults setObject:self.searchRecordArray forKey:searchRecordArrayKey];
    [YFUserDefaults synchronize];
    
    [self.backgroundTableView reloadData];
}



#pragma mark - /**************** tableView deletate ****************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.backgroundTableView) {
        return 1 + self.searchRecordArray.count;
    } else {
        return self.searchResultArray.count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (tableView == self.resultTableView) {
        static NSString * const resultCellID = @"resultCellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resultCellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resultCellID];
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%@", self.searchResultArray[indexPath.row]];
        return cell;
    }
    
    else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"firstID" tableView:tableView];
            cell.textLabel.text = @"热门搜索";
            return cell;
        } else if (indexPath.row == 1) {
            YFHotSearchCell *cell = [YFHotSearchCell cellWithTableView:tableView];
            cell.delegate = self;
            cell.hotSearchs = self.hotSearchsArray;
            
            return cell;
        } else if (indexPath.row == 2) {
            UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"secondID" tableView:tableView];
            cell.textLabel.text = @"历史记录";
            return cell;
        }
        
        else {
            UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:@"recordCellID" tableView:tableView];
            cell.imageView.image = [UIImage imageNamed:@"history"];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", self.searchRecordArray[indexPath.row-2]];
            return cell;
        }
    }
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier tableView:(UITableView *)tableView {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView == self.backgroundTableView) ? UITableViewCellEditingStyleDelete:UITableViewCellEditingStyleNone;
}
// 先要设Cell可编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (tableView == self.backgroundTableView && indexPath.row != 0);
}
// 进入编辑模式，按下出现的编辑按钮后
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.searchRecordArray = [NSMutableArray arrayWithArray:[YFUserDefaults objectForKey:searchRecordArrayKey]];
    [self.searchRecordArray removeObjectAtIndex:indexPath.row-1];
    
    [YFUserDefaults setObject:self.searchRecordArray forKey:searchRecordArrayKey];
    [YFUserDefaults synchronize];
    if (self.searchRecordArray.count == 0) {
        [self.backgroundTableView reloadData];
        return;
    }

    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.backgroundTableView && indexPath.row == 1) {
        return MAX(self.cellHeight, 44); //self.hotSearchsArray.count/4 * 40 + 40;
    }
    return 44;
}

#pragma mark - /**************** scrollView delegate ****************/
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
    // 如果不写这俩句, 输入搜索内容, 拖动tableView, 再次点击 `取消` 不会进入`searchBarCancelButtonClicked`, 会进入 `searchBarTextDidBeginEditing`
    UIButton *cancelBtn = [self.searchBar valueForKeyPath:@"cancelButton"]; //首先取出cancelBtn
    cancelBtn.enabled = YES;
}

- (void)hotSearchDidClicked:(NSString *)buttonTitle {
    self.searchBar.text = buttonTitle;
    [self searchBarSearchButtonClicked:self.searchBar];
}

- (void)refreshCellHeight:(CGFloat)cellHeght {
    self.cellHeight = cellHeght;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.backgroundTableView reloadData];
    });
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end



































