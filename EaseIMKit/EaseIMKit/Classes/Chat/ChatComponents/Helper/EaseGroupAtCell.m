//
//  EaseGroupAtCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/13.
//  Copyright © 2022 djp. All rights reserved.
//

#import "EaseGroupAtCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <HyphenateChat/HyphenateChat.h>>
#import "EaseHeaders.h"

@interface EaseGroupAtCell ()

@end


@implementation EaseGroupAtCell

- (void)prepare {
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.nameLabel];
     
}


- (void)placeSubViews {
    
    [self.iconImageView Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);
        make.size.equalTo(@(38.0));
    }];
    
    [self.nameLabel Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.iconImageView.ease_right).offset(8.0);
        make.width.lessThanOrEqualTo(@(200.0));
        make.height.equalTo(@(10));
    }];

}

- (void)updateWithObj:(id)obj {
    NSString *aUid = (NSString *)obj;
    
    [[EMClient sharedClient].userInfoManager fetchUserInfoById:@[aUid] completion:^(NSDictionary * _Nullable aUserDatas, EMError * _Nullable aError) {

        EMUserInfo* userInfo = [aUserDatas objectForKey:aUid];
        
        if(userInfo) {
            if(userInfo.avatarUrl.length > 0) {
                NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
                if(url) {
                    [self.iconImageView sd_setImageWithURL:url completed:nil];
                }
            }else {
                [self.iconImageView setImage:[UIImage easeUIImageNamed:@"jh_user_icon"]];
            }
                 
            self.nameLabel.text = userInfo.nickname.length > 0 ? userInfo.nickname: userInfo.userId;
            
        }
    }];

}



@end
