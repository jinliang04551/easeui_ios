//
//  EaseSearchPlaceView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/12.
//

#import "EaseSearchView.h"
#import "EaseHeaders.h"
#import "EMSearchBar.h"

@interface EaseSearchView ()
@property (nonatomic, strong) UIControl *control;
@property (nonatomic, strong) EMSearchBar *searchBar;


@end

@implementation EaseSearchView
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
    
    [self addSubview:self.control];
    [self addSubview:self.searchBar];
    
    [self.control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(36);
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self).offset(-16);
    }];

    [self.control mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.control);
    }];
    
    
}


- (void)searchButtonAction {
    self.control.hidden = YES;
    self.searchBar.hidden = NO;
}



#pragma mark getter and setter
- (UIControl *)control {
    if (_control == nil) {
        _control = [[UIControl alloc] initWithFrame:CGRectZero];
        _control.clipsToBounds = YES;
        _control.layer.cornerRadius = 18;
        _control.backgroundColor = [UIColor colorWithHexString:@"#252525"];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchButtonAction)];
        [_control addGestureRecognizer:tap];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage easeUIImageNamed:@"jh_search_leftIcon"]];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:14.0];
        label.text = @"搜索";
        label.textColor = [UIColor colorWithHexString:@"#7E7E7F"];
        [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        UIView *subView = [[UIView alloc] init];
        [subView addSubview:imageView];
        [subView addSubview:label];
        [_control addSubview:subView];

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
            make.center.equalTo(_control);
        }];
        
    }
    return _control;
}


- (EMSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.hidden = YES;
    }
    return _searchBar;
}


@end
