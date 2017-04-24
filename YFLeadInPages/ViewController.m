//
//  ViewController.m
//  YFLeadInPages
//
//  Created by YangFei on 2017/1/24.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import "ViewController.h"
#import "YFLeadPageView.h"
#import "YFSearchViewController.h"
#import "UIImageView+YFAdd.h"

#import "BlocksKit.h"
#import "UIView+BlocksKit.h"
#import "UIControl+BlocksKit.h"

typedef void(^yfBlock)();

@interface ViewController ()
@property (nonatomic, copy) yfBlock block;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn.backgroundColor = [UIColor redColor];
    btn.frame = CGRectMake(100, 300, 50, 50);
    [btn bk_addEventHandler:^(id  _Nonnull sender) {
        NSLog(@"===>>>%@",@"adafsdfasdfds");
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    NSArray *names = @[@"james",@"kobe",@"poul"];
    [names bk_each:^(id  _Nonnull obj) {
        NSLog(@"===>>>%@",obj);
    }];
    
    
    [self.view bk_whenTapped:^{
        NSLog(@"===>>>%@",@"=======>>>>>");
    }];

    [self.view addSubview:btn];
    
    
    
    self.title = @"主页";
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationController.navigationBar.barTintColor = [UIColor cyanColor];
    
    NSArray *imageNames = @[@"one.jpeg", @"two.jpeg", @"three.jpeg",@"four.jpeg"];
    
    [YFLeadPageView leadPageViewWithImageNames:imageNames];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                          target:self
                                                                          action:@selector(pushToSearchController)];
    self.navigationItem.rightBarButtonItem = item;
    
    
    
    UIImageView *imageView = [UIImageView yf_imageViewWithImageName:@"加拿大花栗鼠2.jpeg"
                                                       cornerRadius:50
                                                              frame:CGRectMake(100, 100, 250, 200)];
    [self.view addSubview:imageView];
    
    
    
    NSLog(@"===>>>%f",[NSDate date].timeIntervalSince1970);
    
    
    /// YF 4.24 test
    
    
   
}

- (void)pushToSearchController {
    YFSearchViewController *searchVC = [YFSearchViewController new];
    [self.navigationController pushViewController:searchVC animated:NO];
}





@end
