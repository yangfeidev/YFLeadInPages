//
//  UIImageView+YFAdd.m
//  IOSMall
//
//  Created by YangFei on 2017/2/10.
//  Copyright © 2017年 Social. All rights reserved.
//

#import "UIImageView+YFAdd.h"

@implementation UIImageView (YFAdd)


+ (instancetype)yf_imageViewWithImageName:(NSString *)imageName cornerRadius:(CGFloat)cornerRadius frame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    UIImage *anotherImage = [UIImage imageNamed:imageName];
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds
                                cornerRadius:cornerRadius] addClip];
    [anotherImage drawInRect:imageView.bounds];
    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageView;
}


@end
