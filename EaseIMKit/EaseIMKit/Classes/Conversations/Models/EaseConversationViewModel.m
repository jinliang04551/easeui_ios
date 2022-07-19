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
    
//    _nameLabelFont = [UIFont systemFontOfSize:16];
//    _nameLabelColor = [UIColor colorWithHexString:@"#333333"];
//    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//
//    _detailLabelFont = [UIFont systemFontOfSize:14];
//    _detailLabelColor = [UIColor colorWithHexString:@"#A3A3A3"];;
//    _detailLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//
//    _timeLabelFont = [UIFont systemFontOfSize:12];
//    _timeLabelColor = [UIColor colorWithHexString:@"#A3A3A3"];;
//    _timeLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
  
#if EaseIMKit_JiHuApp
    _nameLabelFont = [UIFont systemFontOfSize:14.0];
    _nameLabelColor = [UIColor colorWithHexString:@"#B9B9B9"];
    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _detailLabelFont = [UIFont systemFontOfSize:12.0];
    _detailLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _detailLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _timeLabelFont = [UIFont systemFontOfSize:12.0];
    _timeLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _timeLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);


    _badgeLabelFont = [UIFont systemFontOfSize:12];
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
    
#else
    _nameLabelFont = [UIFont systemFontOfSize:14.0];
    _nameLabelColor = [UIColor colorWithHexString:@"#B9B9B9"];
    _nameLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _detailLabelFont = [UIFont systemFontOfSize:12.0];
    _detailLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _detailLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);

    _timeLabelFont = [UIFont systemFontOfSize:12.0];
    _timeLabelColor = [UIColor colorWithHexString:@"#7F7F7F"];;
    _timeLabelEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);


    _badgeLabelFont = [UIFont systemFontOfSize:12];
    _badgeLabelHeight = 14;
//    _badgeLabelBgColor = UIColor.redColor;
    _badgeLabelBgColor = [UIColor colorWithHexString:@"#AF2A25"];
    _badgeLabelTitleColor = UIColor.whiteColor;
    _badgeLabelPosition = EMCellRight;
    _badgeLabelCenterVector = CGVectorMake(0, 0);
    _badgeMaxNum = 99;

    _topBgColor = [UIColor colorWithHexString:@"#f2f2f2"];
    _cellBgColor = [UIColor colorWithHexString:@"#FFFFFF"];
//    _cellBgColor = [UIColor colorWithHexString:@"#171717"];

    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];

    _cellSeparatorInset = UIEdgeInsetsMake(1, 77, 0, 0);
    _cellSeparatorColor = [UIColor colorWithHexString:@"#F3F3F3"];

#endif

    _bgView = [self defaultBgView];
    
//    _defaultAvatarImage = [UIImage easeUIImageNamed:@"defaultAvatar"];
    _defaultAvatarImage = [UIImage easeUIImageNamed:@"jh_user_icon"];
    _defaultJhGroupAvatarImage = [UIImage easeUIImageNamed:@"jh_group_icon"];
    
}

- (UIView *)defaultBgView {
    UIView *defaultBgView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"tableViewBgImg"]];
    UILabel *txtLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    txtLabel.font = [UIFont systemFontOfSize:14];
    txtLabel.textColor = [UIColor colorWithHexString:@"#999999"];
    [view addSubview:imageView];
    [view addSubview:txtLabel];
    [defaultBgView addSubview:view];

    txtLabel.text = EaseLocalizableString(@"noMessag", nil);

    [imageView Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.centerX.equalTo(view);
        make.top.equalTo(view);
        make.width.Ease_equalTo(138);
        make.height.Ease_equalTo(106);
    }];

    [txtLabel Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.centerX.equalTo(view.ease_centerX);
        make.top.equalTo(imageView.ease_bottom).offset(19);
        make.height.Ease_equalTo(20);
    }];

    [view Ease_updateConstraints:^(EaseConstraintMaker *make) {
        make.center.equalTo(defaultBgView);
        make.top.equalTo(imageView);
        make.left.equalTo(imageView);
        make.right.equalTo(imageView);
        make.bottom.equalTo(txtLabel.ease_bottom);
    }];

    return defaultBgView;
}


- (EaseNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = EaseNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:[UIImage easeUIImageNamed:@"ji_search_nodata"]];
        _noDataPromptView.prompt.text = @"您当前未加入任何专属服务群";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}




@end
