
//
//  JHOrderInfoCell.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import "JHOrderInfoCell.h"
#import "JHOrderViewModel.h"
#import "UIColor+EaseUI.h"

@interface JHOrderInfoCell ()
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UILabel* productNameLabel;
@property (nonatomic, strong) UILabel* timeLabel;
@property (nonatomic, strong) UIButton* sendButton;
@property (nonatomic, strong) JHOrderViewModel *orderModel;


@end

@implementation JHOrderInfoCell

- (void)prepare {
    [self.contentView addSubview:self.bgView];
}

- (void)placeSubViews {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 16.0, 8.0, 16.0));
    }];
}

- (void)updateWithObj:(id)obj {
    self.orderModel = (JHOrderViewModel *)obj;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@订单",self.orderModel.orderId];
    self.productNameLabel.text = [NSString stringWithFormat:@"商品名称: %@",self.orderModel.productName];
    self.timeLabel.text = [NSString stringWithFormat:@"下单日期：%@",self.orderModel.orderDate];
    
    NSMutableString *msgInfo = [NSMutableString string];
    [msgInfo appendString:self.nameLabel.text];
    [msgInfo appendString:@"\n"];
    [msgInfo appendString:[NSString stringWithFormat:@"订单类型:%@",self.orderModel.orderType]];
    [msgInfo appendString:@"\n"];
    [msgInfo appendString:self.productNameLabel.text];
    [msgInfo appendString:@"\n"];
    [msgInfo appendString:self.timeLabel.text];
    [msgInfo appendString:@"\n"];
    [self.orderModel displayOrderMessage:msgInfo];
    
}



- (void)sendButtonAction {
    if (self.sendOrderBlock) {
        self.sendOrderBlock(self.orderModel);
    }
}


#pragma mark getter and setter


- (UILabel *)productNameLabel {
    if (_productNameLabel == nil) {
        _productNameLabel = [[UILabel alloc] init];
        _productNameLabel.font = EaseIMKit_NFont(14.0);
        
        _productNameLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        _productNameLabel.textAlignment = NSTextAlignmentLeft;
        _productNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _productNameLabel;
}


- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = EaseIMKit_NFont(14.0);
        _timeLabel.textColor = [UIColor colorWithHexString:@"#B9B9B9"];
        _timeLabel.textAlignment = NSTextAlignmentLeft;
        _timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    }
    return _timeLabel;

}

- (UIButton *)sendButton {
    if (_sendButton == nil) {
        _sendButton = [[UIButton alloc] init];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        _sendButton.layer.cornerRadius = 4.0;
        [_sendButton setTitle:@"发送到服务群" forState:UIControlStateNormal];
        [_sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
    }
    return _sendButton;
}


- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#1C1C1C"];

        self.bottomLine.backgroundColor = [UIColor colorWithHexString:@"#2E2E2E"];
        
        [_bgView addSubview:self.nameLabel];
        [_bgView addSubview:self.bottomLine];
        [_bgView addSubview:self.productNameLabel];
        [_bgView addSubview:self.timeLabel];
        [_bgView addSubview:self.sendButton];

        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgView).offset(14.0);
            make.left.equalTo(_bgView).offset(16.0f);
            make.right.equalTo(_bgView).offset(-16.0);
        }];
        
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.nameLabel.mas_bottom).offset(14.0);
            make.left.equalTo(_bgView).offset(16.0f);
            make.right.equalTo(_bgView).offset(-16.0);
            make.height.equalTo(@(EaseIMKit_ONE_PX));
        }];
        
        
        [self.productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bottomLine.mas_bottom).offset(14.0);
            make.left.equalTo(_bgView).offset(16.0f);
            make.right.equalTo(_bgView).offset(-16.0);
            
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.productNameLabel.mas_bottom).offset(8.0);
            make.left.equalTo(_bgView).offset(16.0f);
            make.right.equalTo(_bgView).offset(-16.0);
            
        }];
        
        [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(22.0);
            make.centerX.equalTo(_bgView);
            make.width.equalTo(@(116.0));
            make.height.equalTo(@(32.0));
        }];
        
    }
    return _bgView;
}

@end
