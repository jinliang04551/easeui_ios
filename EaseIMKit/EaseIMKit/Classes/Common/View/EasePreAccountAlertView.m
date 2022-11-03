//
//  EasePreLoginAccountView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/10/10.
//

#import "EasePreAccountAlertView.h"
#import <Masonry/Masonry.h>
#import "EasePreLoginAccountCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "EaseHeaders.h"


@interface EasePreLoginAccountContentView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,copy)void (^cancelBlock)(void);
@property (nonatomic,copy)void (^confirmBlock)(NSDictionary *selectedDic);

@property (nonatomic,strong) UIView *alphaView;
@property (nonatomic,strong) UIView *contentView;
@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UIView  *lineView;
@property (nonatomic,strong) UIButton *confirmButton;
@property (nonatomic,strong) UITableView *table;

@property (nonatomic,strong) NSDictionary *selectedAccountDic;

@property (nonatomic,copy) NSString *title;
@property (nonatomic, strong) NSMutableArray* preAccountArray;
@property (nonatomic, strong) UIView *contentFooterView;
@property (nonatomic, strong) UIButton *hideButton;

@end

@implementation EasePreLoginAccountContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutAllSubviews];
        self.preAccountArray  = [EaseIMKitOptions sharedOptions].preAccountArray;
        
        [self.table reloadData];

    }
    return self;
}
 
- (void)layoutAllSubviews {
    
    [self addSubview:self.alphaView];
    [self addSubview:self.contentView];
    
    [self.alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(22.0);
        make.right.equalTo(self).offset(-22.0);
        make.centerY.equalTo(self);
//        make.height.equalTo(@500.0);
    }];

}
  
#pragma mark - tableview delegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.preAccountArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EasePreLoginAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(EasePreLoginAccountCell.class)];
    
    NSDictionary *accDic = self.preAccountArray[indexPath.row];
    BOOL isChecked = [self accountIsSelected:accDic];
    [cell updateWithObj:accDic isChecked:isChecked];
    
    EaseIMKit_WS
    cell.checkBlcok = ^(NSDictionary * _Nonnull selectedDic, BOOL isChecked) {
        weakSelf.selectedAccountDic = selectedDic;
        [weakSelf.table reloadData];
    };
    return cell;
}

#pragma mark private method
- (BOOL)accountIsSelected:(NSDictionary *)accountDic {
    NSString *selectAcc = self.selectedAccountDic[kPreAccountKey];
    NSString *currentAcc = accountDic[kPreAccountKey];
    return [selectAcc isEqualToString:currentAcc];
}

- (void)hideButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

#pragma mark getter and setter
- (UIView *)alphaView {
    if (_alphaView == nil) {
        _alphaView = UIView.new;
        _alphaView.alpha = 0.5;
        _alphaView.backgroundColor = [UIColor blackColor];
    }
    return _alphaView;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = UIView.new;
        _contentView.backgroundColor = UIColor.whiteColor;
        _contentView.layer.cornerRadius = 10.0f;
        _contentView.clipsToBounds = YES;
        
        [_contentView addSubview:self.titleLabel];
        [_contentView addSubview:self.hideButton];
        [_contentView addSubview:self.lineView];
        [_contentView addSubview:self.table];
        [_contentView addSubview:self.contentFooterView];

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentView).offset(20.0);
            make.left.equalTo(_contentView).offset(20.0);
            make.height.equalTo(@16.0);
        }];
        
        [self.hideButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleLabel);
            make.right.equalTo(_contentView).offset(-20.0);
            make.size.equalTo(@(20.0));
        }];
        
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(20.0);
            make.left.equalTo(_contentView).offset(20.0);
            make.right.equalTo(_contentView).offset(-20.0);
            make.height.mas_equalTo(EaseIMKit_ONE_PX);
        }];
        
        [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lineView.mas_bottom).offset(0.0);
            make.left.equalTo(_contentView);
            make.right.equalTo(_contentView);
            make.height.equalTo(@(48.0 * 5));
        }];
        
        [self.contentFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.table.mas_bottom);
            make.left.right.equalTo(_contentView);
            make.height.mas_equalTo(58.0);
            make.bottom.equalTo(_contentView);
        }];
    }
    return _contentView;;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = UILabel.new;
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16.0f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = EaseIMKit_COLOR_HEX(0x333333);
        _titleLabel.text = @"账号信息";
    }
    return _titleLabel;
}

- (UIButton *)hideButton {
    if (_hideButton == nil) {
        _hideButton = [[UIButton alloc] init];
        [_hideButton setImage:[UIImage easeUIImageNamed:@"ease_alert_hide"] forState:UIControlStateNormal];
        
        [_hideButton addTarget:self action:@selector(accessButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _hideButton;
}

- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = UIView.new;
        _lineView.backgroundColor = EaseIMKit_COLOR_HEX(0xCFCFCF);
    }
    return _lineView;
}


- (UIButton *)confirmButton {
    if (_confirmButton == nil) {
        _confirmButton = UIButton.new;
//        UIImage *originImage = IMAGE_BUNDLE_NAME(@"MISUserModule", @"user_login");
//        [_confirmButton setBackgroundImage:originImage forState:UIControlStateNormal];

          NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:@"确认选择"];
        [attributedText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:15.0f], NSForegroundColorAttributeName:UIColor.whiteColor} range:NSMakeRange(0, attributedText.length)];
        [_confirmButton setAttributedTitle:attributedText forState:UIControlStateNormal];
        
        [_confirmButton addTarget:self action:@selector(confirmButtonEvent) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _confirmButton;
}

- (UITableView *)table {
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
        _table.delegate = self;
        _table.dataSource = self;
        _table.estimatedRowHeight = 48.0f;
        _table.rowHeight = UITableViewAutomaticDimension;
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_table registerClass:EasePreLoginAccountCell.class forCellReuseIdentifier:NSStringFromClass(EasePreLoginAccountCell.class)];
    }
    
    return _table;
}

- (UIView *)contentFooterView {
    if (_contentFooterView == nil) {
        _contentFooterView = [[UIView alloc] init];
        
        UIView *widthLine = [[UIView alloc] init];
        widthLine.backgroundColor = EaseIMKit_COLOR_HEX(0xCFCFCF);
        
        UIView *vLine = [[UIView alloc] init];
        vLine.backgroundColor = EaseIMKit_COLOR_HEX(0xCFCFCF);
        
        UIButton *cancelButton = [[UIButton alloc] init];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:EaseIMKit_COLOR_HEX(0x333333) forState:UIControlStateNormal];

        [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *confirmButton = [[UIButton alloc] init];
        [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
        [confirmButton setTitleColor:EaseIMKit_COLOR_HEX(0x4461F2) forState:UIControlStateNormal];
        [confirmButton addTarget:self action:@selector(confirmButtonAction) forControlEvents:UIControlEventTouchUpInside];

        
        [_contentFooterView addSubview:widthLine];
        [_contentFooterView addSubview:vLine];
        [_contentFooterView addSubview:cancelButton];
        [_contentFooterView addSubview:confirmButton];

        
        [widthLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_contentFooterView);
            make.left.right.equalTo(_contentFooterView);
            make.height.equalTo(@(EaseIMKit_ONE_PX));
        }];
        
        [vLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.centerX.equalTo(_contentFooterView);
            make.width.equalTo(@(EaseIMKit_ONE_PX));
            make.bottom.equalTo(_contentFooterView);
        }];
    
        [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.left.equalTo(_contentFooterView);
            make.right.equalTo(vLine.mas_left);
            make.bottom.equalTo(_contentFooterView);
        }];
        
        [confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(widthLine.mas_bottom);
            make.left.equalTo(vLine.mas_right);
            make.right.equalTo(_contentFooterView);
            make.bottom.equalTo(_contentFooterView);
            
        }];
        
    }
    return _contentFooterView;
}

- (void)cancelButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)confirmButtonAction {
    if (self.confirmBlock) {
        self.confirmBlock(self.selectedAccountDic);
    }
}

- (NSMutableArray *)preAccountArray {
    if (_preAccountArray == nil) {
        _preAccountArray = [NSMutableArray array];
    }
    return _preAccountArray;
}


@end


static id g_instance = nil;
@interface EasePreAccountAlertView()
@property (nonatomic, strong) EasePreLoginAccountContentView* chooseUserView;
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIWindow* currentWindow;
@property (nonatomic, weak) UIViewController* controller;
@property (nonatomic, copy) void(^okBlock)(void);

@end

@implementation EasePreAccountAlertView
//- (instancetype)initWithViewModel:(MIS_USRLoginViewModel *_Nullable)viewModel {
//    self = [super init];
//    if (self) {
//        g_instance = self;
//        self.viewModel = viewModel;
//    }
//    return self;
//}

//- (instancetype)init {
//    return [self initWithViewModel:nil];
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        g_instance = self;
    }
    return self;
}


- (EasePreLoginAccountContentView *)chooseUserView {
    if (_chooseUserView == nil) {
        _chooseUserView = [[EasePreLoginAccountContentView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        EaseIMKit_WS
        _chooseUserView.cancelBlock = ^{
            [weakSelf hide];
        };
        _chooseUserView.confirmBlock = ^(NSDictionary *selectedDic) {
            [weakSelf hide];
            if (weakSelf.confirmBlock) {
                weakSelf.confirmBlock(selectedDic);
            }
        };
        
    }
    return _chooseUserView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight)];
        _bgView.backgroundColor = EaseIMKit_COLOR_HEXA(0x000000, 0.5);
    }
    return _bgView;
}


- (UIWindow*)currentWindow {
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }


    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    } else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }

    return nil;
}


- (void)showWithCompletion:(void(^)(void))completion {
    //block
    self.okBlock = completion;
    
    [self show];
}

/*指定 view controller 显示*/
- (void)showinViewController:(UIViewController *)viewController
                  completion:(void(^)(void))completion {
    //block
    self.okBlock = completion;
    self.controller = viewController;
    
    [self showInView:viewController.view];
}

- (void)showInView:(UIView *)view {
    //check to add
    if (self.bgView.superview == nil) {
        [view addSubview:self.bgView];
        [view addSubview:self.chooseUserView];
        [self.chooseUserView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(view);
            make.left.equalTo(view);
            make.right.equalTo(view);
            make.height.equalTo(view);
        }];
    }
    
    //show now
    self.chooseUserView.alpha = 0.0;
    self.bgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 1.0;
        self.bgView.alpha = 1.0;
    }];
}

- (void)show {
    //check to add
    if (self.bgView.superview == nil) {
        [self.currentWindow addSubview:self.bgView];
        [self.currentWindow addSubview:self.chooseUserView];
        [self.chooseUserView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.center.equalTo(self.currentWindow);
             make.left.equalTo(self.currentWindow);
             make.right.equalTo(self.currentWindow);
             make.height.equalTo(self.currentWindow);
         }];
    }
    
    //show now
    self.chooseUserView.alpha = 0.0;
    self.bgView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 1.0;
        self.bgView.alpha = 1.0;
    }];
}

- (void)hide {
    [UIView animateWithDuration:0.25 animations:^{
        self.chooseUserView.alpha = 0.0;
        self.bgView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.bgView removeFromSuperview];
        [self.chooseUserView removeFromSuperview];
        
        g_instance = nil;
    }];
}

@end

