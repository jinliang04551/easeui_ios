//
//  EMMessageBubbleView.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/25.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "EMMessageBubbleView.h"

@implementation EMMessageBubbleView

- (instancetype)initWithDirection:(EMMessageDirection)aDirection
                             type:(EMMessageType)aType
                        viewModel:(EaseChatViewModel *)viewModel
{
    self = [super init];
    if (self) {
        _direction = aDirection;
        _type = aType;
        _viewModel = viewModel;
    }
    
    return self;
}

- (void)setupBubbleBackgroundImage
{
    if (self.direction == EMMessageDirectionSend) {
        UIImage *originImage = _viewModel.sendBubbleBgPicture;
        
        UIImage *denImage = [originImage stretchableImageWithLeftCapWidth:8 topCapHeight:originImage.size.height * 0.8];
        [self  setImage:denImage];
    } else {
        UIImage *originImage = _viewModel.receiveBubbleBgPicture;
        UIImage *denImage = [originImage stretchableImageWithLeftCapWidth:8 topCapHeight:originImage.size.height * 0.8];
        [self  setImage:denImage];
        
    }
}


@end
