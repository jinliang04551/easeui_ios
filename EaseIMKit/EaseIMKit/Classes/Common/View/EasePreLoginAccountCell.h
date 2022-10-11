//
//  EasePreLoginAccountCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/10.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface EasePreLoginAccountCell : BQCustomCell
@property (nonatomic, strong) void (^checkBlcok)(NSDictionary *selectedDic,BOOL isChecked);

- (void)updateWithObj:(id)obj isChecked:(BOOL)isChecked;


@end

NS_ASSUME_NONNULL_END
