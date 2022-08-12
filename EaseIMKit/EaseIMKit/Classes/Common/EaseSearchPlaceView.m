//
//  EaseSearchPlaceView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/12.
//

#import "EaseSearchPlaceView.h"
#import "EaseHeaders.h"
#import "EMSearchBar.h"

@interface EaseSearchPlaceView ()
@property (nonatomic, strong) UIButton *operateButton;

@end

@implementation EaseSearchPlaceView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return self;
}


#pragma mark - Subviews
- (void)placeAndLayoutSubviews {
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }else {
        self.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
    control.clipsToBounds = YES;
    control.layer.cornerRadius = 18;
    control.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
    [control addGestureRecognizer:tap];
    [self addSubview:control];


    [control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.left.equalTo(self.mas_left).offset(17);
        make.right.equalTo(self).offset(-16);
    }];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"jh_search_leftIcon"]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"搜索";
    label.textColor = [UIColor colorWithHexString:@"#7E7E7F"];
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIView *subView = [[UIView alloc] init];
    [subView addSubview:imageView];
    [subView addSubview:label];
    [control addSubview:subView];

    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(15);
        make.left.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];

    [label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.mas_right).offset(3);
        make.right.equalTo(subView);
        make.top.equalTo(subView);
        make.bottom.equalTo(subView);
    }];

    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(control);
    }];
    
    
}


- (void)searchButtonAction {
    
}


//- (void)_updateConversationViewTableHeader {
//    self = [[UIView alloc] initWithFrame:CGRectZero];
//    self.backgroundColor = EaseIMKit_ViewBgBlackColor;
//
//    UIControl *control = [[UIControl alloc] initWithFrame:CGRectZero];
//    control.clipsToBounds = YES;
//    control.layer.cornerRadius = 18;
//    control.backgroundColor = [UIColor colorWithHexString:@"#252525"];
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
//    [control addGestureRecognizer:tap];
//
//    [self mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.easeConvsVC.tableView);
//        make.width.equalTo(self.easeConvsVC.tableView);
//        make.top.equalTo(self.easeConvsVC.tableView);
//        make.height.mas_equalTo(52);
//    }];
//
//    [self addSubview:control];
//    [control mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_offset(36);
//        make.top.equalTo(self).offset(8);
//        make.bottom.equalTo(self).offset(-8);
//        make.left.equalTo(self.mas_left).offset(17);
//        make.right.equalTo(self).offset(-16);
//    }];
//
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"jh_search_leftIcon"]];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
//    label.font = [UIFont systemFontOfSize:14.0];
//    label.text = @"搜索";
//    label.textColor = [UIColor colorWithHexString:@"#7E7E7F"];
//    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    UIView *subView = [[UIView alloc] init];
//    [subView addSubview:imageView];
//    [subView addSubview:label];
//    [control addSubview:subView];
//
//    [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.width.height.mas_equalTo(15);
//        make.left.equalTo(subView);
//        make.top.equalTo(subView);
//        make.bottom.equalTo(subView);
//    }];
//
//    [label mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(imageView.mas_right).offset(3);
//        make.right.equalTo(subView);
//        make.top.equalTo(subView);
//        make.bottom.equalTo(subView);
//    }];
//
//    [subView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(control);
//    }];
//}



@end
