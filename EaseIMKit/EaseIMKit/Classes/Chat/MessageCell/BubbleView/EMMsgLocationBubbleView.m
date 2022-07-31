//
//  EMMsgLocationBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/2/14.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMsgLocationBubbleView.h"

@implementation EMMsgLocationBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel*)viewModel;
{
    self = [super initWithDirection:aDirection type:aType viewModel:viewModel];
    if (self) {
        if (self.direction == EMMessageDirectionSend) {
            self.iconView.image = [UIImage easeUIImageNamed:@"locationMsg"];
        } else {
            self.iconView.image = [UIImage easeUIImageNamed:@"locationMsg"];
        }
        
        [self.iconView Ease_updateConstraints:^(EaseConstraintMaker *make) {
            make.size.equalTo(@(28.0));
        }];
        
    }
    
    return self;
}

#pragma mark - Setter

- (void)setModel:(EaseMessageModel *)model
{
    EMMessageType type = model.type;
    if (type == EMMessageTypeLocation) {
        EMLocationMessageBody *body = (EMLocationMessageBody *)model.message.body;
        
        self.textLabel.text = body.buildingName;
        self.detailLabel.text = body.address;
    }
}

@end
