//
//  YFHotSearchCell.h
//  YFLeadInPages
//
//  Created by YangFei on 2017/2/9.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YFHotSearchCellDelegate <NSObject>

- (void)hotSearchDidClicked:(NSString *)buttonTitle;

- (void)refreshCellHeight:(CGFloat)cellHeght;

@end


@interface YFHotSearchCell : UITableViewCell

/** 保存热门搜索的数组 */
@property (nonatomic, strong) NSArray *hotSearchs;
@property (nonatomic, weak) id <YFHotSearchCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
