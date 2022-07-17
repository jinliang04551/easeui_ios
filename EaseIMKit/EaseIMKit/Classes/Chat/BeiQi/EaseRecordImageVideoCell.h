//
//  EaseRecordImageVideoCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/7/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseRecordImageVideoCell : UICollectionViewCell
- (void)updateWithObj:(id)obj;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
