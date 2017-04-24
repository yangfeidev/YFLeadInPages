//
//  UIImageView+YFAdd.h
//  IOSMall
//
//  Created by YangFei on 2017/2/10.
//  Copyright © 2017年 Social. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (YFAdd)

+ (instancetype)yf_imageViewWithImageName:(NSString *)imageName cornerRadius:(CGFloat)cornerRadius frame:(CGRect)frame;

@end
