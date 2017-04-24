//
//  YFLeadPageView.h
//  YFLeadPage
//
//  Created by YangFei on 2017/1/24.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFLeadPageView : UIView

/**
    初始化方法
    每个版本只会显示一次
 @param imageNames 滚动显示的图片名称数组
 */
+ (void)leadPageViewWithImageNames:(NSArray *)imageNames;


@end
