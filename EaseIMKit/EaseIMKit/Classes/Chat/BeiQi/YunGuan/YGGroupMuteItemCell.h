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

@property (nonatomic) BOOL isChecked;

- (void)updateWithObj:(id)obj;

@end

NS_ASSUME_NONNULL_END
