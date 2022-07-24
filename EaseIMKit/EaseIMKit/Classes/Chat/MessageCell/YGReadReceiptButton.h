//
//  YGReadReceiptButton.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YGReadReceiptButton : UIButton

- (void)updateStateWithCount:(NSInteger)readCount
                   isReadAll:(BOOL)isReadAll;

@end

NS_ASSUME_NONNULL_END
