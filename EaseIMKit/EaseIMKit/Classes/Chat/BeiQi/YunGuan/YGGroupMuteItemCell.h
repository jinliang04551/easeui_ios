//
//  YGGroupMuteItemCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/26.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YGGroupMuteItemCell : BQCustomCell
@property (nonatomic, strong) void (^checkBlcok)(NSString *userId,BOOL isChecked);

- (void)updateWithObj:(id)obj isChecked:(BOOL)isChecked;


@end

NS_ASSUME_NONNULL_END
