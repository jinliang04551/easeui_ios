//
//  BQMemberAvatarTitleRoleCell.h
//  EaseIMKit
//
//  Created by liu001 on 2022/10/18.
//

#import "BQCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface BQMemberAvatarTitleRoleCell : BQCustomCell

- (void)updateWithObj:(id)obj isOwner:(BOOL)isOwner role:(NSString *)role;

@end

NS_ASSUME_NONNULL_END
