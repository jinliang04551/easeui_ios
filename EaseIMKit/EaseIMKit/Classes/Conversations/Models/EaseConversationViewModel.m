//
//  EaseConversationViewModel.m
//  EaseIMKit
//
//  Created by 娜塔莎 on 2020/11/12.
//

#import "EaseConversationViewModel.h"
#import "EaseHeaders.h"
#import "UIImage+EaseUI.h"
#import "Easeonry.h"
#import "EaseDefines.h"
#import "EaseNoDataPlaceHolderView.h"
#import "EaseIMKitManager.h"

@interface EaseConversationViewModel ()
@property (nonatomic, strong) EaseNoDataPlaceHolderView *noDataPromptView;

@end

@implementation EaseConversationViewModel
@synthesize bgView = _bgView;
@synthesize cellBgColor = _cellBgColor;
@synthesize topBgColor = _topBgColor;
@synthesize cellSeparatorInset = _cellSeparatorInset;
@synthesize cellSeparatorColor = _cellSeparatorColor;
@synthesize canRefresh = _canRefresh;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupPropertyDefault];
    }
    
    return self;
}


- (void)_setupPropertyDefault {
    
    _canRefresh = NO;
    
    _avatarType = RoundedCorner;
    _avatarSize = CGSizeMake(48, 48);
    _avatarEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
if (EaseIMKitManager.shared.isJiHuApp){
    _nameLabelFont = [UIFont systemFontOfSize:14.0];
    _nameLabelColor = [UIColor colorWithHexString:@"#B9B9B9"];
    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _detailLabelFont = [UIFont systemFontOfSize:12.0];
    _detailLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _detailLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _timeLabelFont = [UIFont systemFontOfSize:12.0];
    _timeLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];
    _timeLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);


    _badgeLabelFont = [UIFont systemFontOfSize:10.0];
    _badgeLabelHeight = 14;
//    _badgeLabelBgColor = UIColor.redColor;
    _badgeLabelBgColor = [UIColor colorWithHexString:@"#AF2A25"];
    _badgeLabelTitleColor = UIColor.whiteColor;
    _badgeLabelPosition = EMCellRight;
    _badgeLabelCenterVector = CGVectorMake(0, 0);
    _badgeMaxNum = 99;

    _topBgColor = [UIColor colorWithHexString:@"#f2f2f2"];
//    _cellBgColor = [UIColor colorWithHexString:@"#FFFFFF"];
    _cellBgColor = [UIColor colorWithHexString:@"#171717"];

    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];

//    _cellSeparatorInset = UIEdgeInsetsMake(1, 77, 0, 0);
//    _cellSeparatorColor = [UIColor colorWithHexString:@"#F3F3F3"];
    
}else {
    _nameLabelFont = EaseIMKit_BFont(16.0);
    _nameLabelColor = [UIColor colorWithHexString:@"#171717"];
    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _detailLabelFont = [UIFont systemFontOfSize:14.0];
    _detailLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];
    _detailLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _timeLabelFont = [UIFont systemFontOfSize:12.0];
    _timeLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _timeLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);


    _badgeLabelFont = [UIFont systemFontOfSize:10.0];
    _badgeLabelHeight = 14;
//    _badgeLabelBgColor = UIColor.redColor;
    _badgeLabelBgColor = [UIColor colorWithHexString:@"#FF4D4F"];
    _badgeLabelTitleColor = UIColor.whiteColor;
    _badgeLabelPosition = EMCellRight;
    _badgeLabelCenterVector = CGVectorMake(0, 0);
    _badgeMaxNum = 99;

    _topBgColor = [UIColor colorWithHexString:@"#f2f2f2"];
    _cellBgColor = [UIColor colorWithHexString:@"#FFFFFF"];

    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];

    _cellSeparatorInset = UIEdgeInsetsMake(1, 77, 0, 0);
    _cellSeparatorColor = [UIColor colorWithHexString:@"#F3F3F3"];

}
    _bgView = [self noDataPromptView];
    
//    _defaultAvatarImage = [UIImage easeUIImageNamed:@"jh_user_icon"];
    _defaultAvatarImage = [UIImage easeUIImageNamed:@"jh_user_icon"];
    _defaultJhGroupAvatarImage = [UIImage easeUIImageNamed:@"jh_group_icon"];
    
}


- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"ji_search_nodata"]];
        if (![EaseIMKitOptions sharedOptions].isJiHuApp) {
            _noDataPromptView.prompt.text = @"您当前未加入任何专属服务群";
        }else {
            _noDataPromptView.prompt.text = @"暂无消息";
        }
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}




@end
