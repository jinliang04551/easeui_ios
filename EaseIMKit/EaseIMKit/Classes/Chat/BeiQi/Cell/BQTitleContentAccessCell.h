//
//  BQTitleValueContentAccessCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/13.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQTitleContentAccessCell : BQCustomCell
@property (nonatomic, strong) UILabel* contentLabel;

+ (CGFloat)heightWithObj:(NSString *)obj;

@end

NS_ASSUME_NONNULL_END
