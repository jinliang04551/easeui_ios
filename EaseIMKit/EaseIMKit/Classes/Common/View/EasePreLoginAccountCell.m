//
//  EasePreLoginAccountCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/10.
//

#import "EasePreLoginAccountCell.h"
#import "UserInfoStore.h"
#import "EaseHeaders.h"

@interface EasePreLoginAccountCell()

@property (nonatomic, strong) NSDictionary *selectedDic;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, strong) UIImageView *checkImageView;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;

@end

@implementation EasePreLoginAccountCell

- (void)prepare {
    
    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.contentView.backgroundColor = EaseIMKit_ViewBgBlackColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
    }else {
        self.contentView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        self.nameLabel.textColor = [UIColor colorWithHexString:@"#171717"];
    }
    
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.checkImageView];
    [self.contentView addGestureRecognizer:self.tapGesture];
}


- (void)placeSubViews {
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(16.0f);

    }];
    
    [self.checkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-16.0f);
        make.size.equalTo(@(14.0));
    }];

}



- (void)updateWithObj:(id)obj {
    
}

- (void)updateWithObj:(id)obj isChecked:(BOOL)isChecked {
    NSDictionary *dic = (NSDictionary *)obj;
    NSString *username = dic[@"accountKey"];
    
    self.selectedDic  = dic;
    self.isChecked = isChecked;
    self.nameLabel.text = username;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setIsChecked:(BOOL)isChecked
{
    if (_isChecked != isChecked) {
        _isChecked = isChecked;
        if (isChecked) {
            
            [self.checkImageView setImage:[UIImage easeUIImageNamed:@"ease_user_selected"]];
        } else {
            [self.checkImageView setImage:[UIImage easeUIImageNamed:@"ease_user_unSelected"]];
        }
    }
}


- (void)tapGestureEvent {
    if (self.checkBlcok) {
        self.checkBlcok(self.selectedDic, self.isChecked);
    }
}


- (UIImageView *)checkImageView {
    if (_checkImageView == nil) {
        _checkImageView = UIImageView.new;
        [_checkImageView setImage:[UIImage easeUIImageNamed:@"ease_user_unSelected"]];
    }
    return _checkImageView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (_tapGesture == nil) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureEvent)];
        
    }
    return _tapGesture;
}

@end
