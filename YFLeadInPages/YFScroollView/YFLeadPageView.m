//
//  YFLeadPageView.m
//  YFLeadPage
//
//  Created by YangFei on 2017/1/24.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import "YFLeadPageView.h"

#define kScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight   ([UIScreen mainScreen].bounds.size.height)


@interface YFLeadPageView () <UIScrollViewDelegate>

/** 滚动图片的`ScrollView` */
@property (nonatomic, strong) UIScrollView *mainScrollView;
/** 底部 `pageControl` */
@property (nonatomic, strong) UIPageControl *pageControl;
/** `跳过` 按钮 */
@property (nonatomic, strong) UIButton *skipBtn;
/** 存放图片名称是数组 */
@property (nonatomic, strong) NSMutableArray <NSString *> *imageNames;
/** 存放images数组 */
@property (nonatomic, strong) NSMutableArray <UIImage *> *images;
/** 立即体验 按钮 */
@property (nonatomic, strong) UIButton *entryBtn;

@end

@implementation YFLeadPageView


- (instancetype)initWithFrame:(CGRect)frame imageNames:(NSArray *)imageNames {

    NSAssert(imageNames, @"imageNames can not be nil.");
    
    if (self = [super initWithFrame:frame]) {
        self.imageNames = [NSMutableArray arrayWithArray:imageNames];
        /** 处理传进来的imageNames */
        [self checkImageNames];

        [self addSubview:self.mainScrollView];
        /** 跳过按钮 */
        [self addSubview:self.skipBtn];
        
        [self addSubview:self.pageControl];
        [self configScrollViewImages];
    }
    return self;
}

/**
  检查传入imageNames, 如果通过名称找不到图片, 移除.
 */
- (void)checkImageNames {
    self.images = [NSMutableArray array];
    for (NSString *imageName in self.imageNames) {
        UIImage *image = [UIImage imageNamed:imageName];
        if (image) {
            [self.images addObject:image];
        }
    }
}

/** 传入图片名称数组 */
+ (void)leadPageViewWithImageNames:(NSArray *)imageNames {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    /* 当前app版本 */
    NSString *currentVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    /* 本地app版本 */
    NSString *localVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentVersion"];
    if (![currentVersion isEqualToString:localVersion]) {
        YFLeadPageView *leadPage = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds imageNames:imageNames];
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:leadPage];
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"currentVersion"];
    }
}


- (void)configScrollViewImages {
    
    NSAssert(self.images.count, @"self.images is empty, check imageNames.");
    
    _mainScrollView.contentSize = CGSizeMake(self.images.count * self.width, self.height);
    for (int i = 0; i < self.images.count; ++i) {
        UIImage *image = self.images[i];
        UIImageView *imageV = [[UIImageView alloc] initWithImage:image];
        imageV.frame = CGRectMake(i * self.width, 0, self.width, self.height);
        [self.mainScrollView addSubview:imageV];
    }
    /** 立即体验 */
    [self.mainScrollView addSubview:self.entryBtn];
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (CGFloat)width {
    return self.frame.size.width;
}

#pragma mark - /**************** scrollView delegate ****************/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentIndex = scrollView.contentOffset.x / kScreenWidth;
    BOOL isHidden = (self.images.count-1 == currentIndex);
    self.entryBtn.hidden = !isHidden;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentIndex = (offsetX + kScreenWidth/2) / kScreenWidth;
    self.pageControl.currentPage = currentIndex;
    /** scrollView 向左拖动大于100, 进入首页 */
    if (scrollView.contentOffset.x > kScreenWidth * (self.images.count-1)+100) {
        [self disMissLeadPage];
    }
}


#pragma mark - /**************** lazy load ****************/
- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _mainScrollView.contentInset = UIEdgeInsetsZero;
        _mainScrollView.delegate = self;
        _mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mainScrollView.backgroundColor = [UIColor cyanColor];
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.pagingEnabled = YES;
        //_mainScrollView.bounces = NO;
    }
    return _mainScrollView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake((kScreenWidth-100)/2, kScreenHeight-100, 100, 20);
        _pageControl.numberOfPages = self.images.count;
        _pageControl.currentPage = 0;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:253.0f/255 green:208.0f/255 blue:0 alpha:1.0f];
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
    }
    return _pageControl;
}

- (UIButton *)skipBtn {
    if (_skipBtn == nil) {
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _skipBtn.frame = CGRectMake(kScreenWidth-100, kScreenHeight-120, 60, 30);
        _skipBtn.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.8f];
        _skipBtn.layer.cornerRadius = 15;
        _skipBtn.layer.masksToBounds = YES;
        [_skipBtn setTitle:@"跳过" forState:UIControlStateNormal];
        _skipBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_skipBtn addTarget:self action:@selector(disMissLeadPage) forControlEvents:UIControlEventTouchUpInside];
    }
    return _skipBtn;
}

- (UIButton *)entryBtn {
    if (_entryBtn == nil) {
        _entryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _entryBtn.frame = CGRectMake(kScreenWidth/2-60 + (self.images.count-1) * self.width, kScreenHeight-150, 120, 36);
        [_entryBtn setTitle:@"立即体验" forState:UIControlStateNormal];
        _entryBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _entryBtn.backgroundColor = [UIColor orangeColor];
        _entryBtn.layer.cornerRadius = 18;
        _entryBtn.layer.masksToBounds = YES;
        _entryBtn.layer.borderWidth = 1.0f;
        _entryBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
        _entryBtn.hidden = !(self.images.count == 1);
        [_entryBtn addTarget:self action:@selector(disMissLeadPage) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _entryBtn;
}

/** 点击跳过后执行方法 */
- (void)disMissLeadPage {
    [UIView animateWithDuration:1.3f animations:^{
        self.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end







