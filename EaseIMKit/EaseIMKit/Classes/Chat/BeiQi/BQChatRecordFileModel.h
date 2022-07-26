//
//  BQChatRecordFileModel.h
//  EaseIM
//
//  Created by liu001 on 2022/7/12.
//  Copyright © 2022 liu001. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BQChatRecordFileModel : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImage *avatarImg;

@property (nonatomic, strong) NSString *from;

@property (nonatomic, strong) NSString *filename;

@property (nonatomic, strong) NSString *timestamp;

@property (nonatomic, strong) EMChatMessage *message;

- (instancetype)initWithMessage:(EMChatMessage *)msg time:(NSString *)timestamp;


@end

NS_ASSUME_NONNULL_END
