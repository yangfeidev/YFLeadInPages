//
//  YFHotSearchCell.m
//  YFLeadInPages
//
//  Created by YangFei on 2017/2/9.
//  Copyright © 2017年 JiuBianLi. All rights reserved.
//

#import "YFHotSearchCell.h"
#import "UICollectionViewLeftAlignedLayout.h"


#define kScreenWidth    ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight   ([UIScreen mainScreen].bounds.size.height)
#define titleLabel_Tag  (111)
static NSString * const cellId = @"cellID";

@interface YFHotSearchCell () <UICollectionViewDelegate,
                               UICollectionViewDataSource>

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *yf_collectionView;

@property (nonatomic, strong) UICollectionViewLeftAlignedLayout *yf_flowLayout;

@property (nonatomic, strong) NSMutableArray *sizeArray;
@end

@implementation YFHotSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.yf_collectionView];
    }
    return self;
}


+ (instancetype)cellWithTableView:(UITableView *)tableView {
    return [[self alloc] initCellWithTableView:tableView];
}

- (instancetype)initCellWithTableView:(UITableView *)tableView {
    static NSString * const cellID = @"cellID";
    YFHotSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[YFHotSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    return cell;
}


- (void)setHotSearchs:(NSArray *)hotSearchs {
    _hotSearchs = hotSearchs;
    [self configArray];
}

- (void)configArray {
    self.sizeArray = [NSMutableArray array];
    for (NSString *string in self.hotSearchs) {
        CGFloat stringWidth = [self text:string sizeForFont:[UIFont systemFontOfSize:14] size:CGSizeMake(HUGE, 40) mode:NSLineBreakByWordWrapping].width+10;
        CGSize size = CGSizeMake(stringWidth, 30);
        [self.sizeArray addObject:[NSValue valueWithCGSize:size]];
    }
}

- (UICollectionView *)yf_collectionView {
    if (_yf_collectionView == nil) {
        CGRect frame = CGRectMake(0, 20, kScreenWidth, kScreenHeight);
        _yf_collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:self.yf_flowLayout];
        _yf_collectionView.backgroundColor = [UIColor whiteColor];
        _yf_collectionView.dataSource = self;
        _yf_collectionView.delegate = self;
        [_yf_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellId];
    }
    return _yf_collectionView;
}
- (UICollectionViewLeftAlignedLayout *)yf_flowLayout {
    if (_yf_flowLayout == nil) {
        _yf_flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init]; // 自定义的布局对象
        _yf_flowLayout.minimumInteritemSpacing = 10;
        _yf_flowLayout.minimumLineSpacing = 10;
        _yf_flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return _yf_flowLayout;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sizeArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    CGFloat contentSizeHeight = self.yf_collectionView.contentSize.height;
    self.yf_collectionView.frame = CGRectMake(0, 0, kScreenWidth, contentSizeHeight+10);
    
    if ([self.delegate respondsToSelector:@selector(refreshCellHeight:)]) {
        [self.delegate refreshCellHeight:contentSizeHeight];
    }
    
    UILabel *titleLabel = [cell.contentView viewWithTag:titleLabel_Tag];
    if (titleLabel == nil) {
        titleLabel = [UILabel new];
        titleLabel.frame = cell.bounds;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor darkGrayColor];
        titleLabel.tag = titleLabel_Tag;
        [cell.contentView addSubview:titleLabel];
    }
    
    titleLabel.text = self.hotSearchs[indexPath.row];
    cell.layer.cornerRadius = 5;
    cell.layer.masksToBounds = YES;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    NSLog(@"didSelectItemAtIndexPath: %ld", (long)indexPath.row);

    if ([self.delegate respondsToSelector:@selector(hotSearchDidClicked:)]) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath   ];
        UILabel *titleLabel = [cell.contentView viewWithTag:titleLabel_Tag];
        [self.delegate hotSearchDidClicked:titleLabel.text];
    }
}

#pragma mark ---- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSValue *value = self.sizeArray[indexPath.row];
    CGSize size = value.CGSizeValue;
    return size;
    
//    return  CGSizeMake((kScreenWidth-40)/3, 40);
}


- (CGSize)text:(NSString *)textString sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [textString boundingRectWithSize:size
                                               options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [textString sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

@end
