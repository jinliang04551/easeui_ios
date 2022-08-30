//
//  EaseNavPopView.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/28.
//

#import "EaseNavPopView.h"
#import "EaseHeaders.h"
#import "YGPopOperationCell.h"

#define kSearchTypeKey @"kSearchTypeKey"
#define kSearchTypeValue @"kSearchTypeValue"


@interface EaseNavPopView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic,copy) NSMutableArray *selectData;
@property (nonatomic,copy) NSMutableArray *imagesData;

@end

@implementation EaseNavPopView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self placeAndLayoutSubviews];
        [self updateUI];
    }
    return self;
}


- (void)placeAndLayoutSubviews {
    
    [self addSubview:self.contentView];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];

}

- (void)updateUI {
    [self buildDatas];
    [self.tableView reloadData];
}



- (void)buildDatas {
    NSArray *titleArray = @[@"消息提醒",@"搜索群聊",@"创建群组",@"群组申请"];
    EaseIMKitOptions *options = [EaseIMKitOptions sharedOptions];
    NSString *msgAlertName = options.isAlertMsg ? @"yg_msg_alert_on": @"yg_msg_alert_off";
    
    NSArray *imageNameArray = @[msgAlertName,@"yg_group_search",@"yg_group_create",@"yg_group_apply"];
    
    self.selectData = [titleArray mutableCopy];
    self.imagesData = [imageNameArray mutableCopy];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.selectData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGPopOperationCell *cell =  [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([YGPopOperationCell class])];
    
    cell.iconImageView.image = [UIImage easeUIImageNamed:self.imagesData[indexPath.row]];
    cell.nameLabel.text = self.selectData[indexPath.row];
    
    if (indexPath.row == self.imagesData.count - 1) {
        if ([EaseIMKitMessageHelper shareMessageHelper].hasJoinGroupApply) {
            [cell showRedPoint:YES];
        }else {
            [cell showRedPoint:NO];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.actionBlock) {
        self.actionBlock(indexPath.row);
    }
    
}

#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;

        [_tableView registerClass:[YGPopOperationCell class] forCellReuseIdentifier:NSStringFromClass([YGPopOperationCell class])];

        
        _tableView.layer.shadowColor = [UIColor colorWithHexString:@"#6C8AB6"].CGColor;
        _tableView.layer.shadowOpacity = 0.1;
        _tableView.layer.shadowRadius = 8.0;
        _tableView.layer.shadowOffset = CGSizeMake(2,2);
        _tableView.layer.cornerRadius = 6;
    }
    return _tableView;
}


- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc]init];
        _contentView.layer.shadowColor = UIColor.blackColor.CGColor;
        _contentView.layer.shadowOpacity = 0.11f;
        _contentView.layer.shadowRadius = 3.f;
        _contentView.layer.shadowOffset = CGSizeMake(0, 0);
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.cornerRadius = 6.0;
        
        [_contentView addSubview:self.tableView];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_contentView);
        }];

    }
    return _contentView;
}

- (NSMutableArray *)selectData {
    if (_selectData == nil) {
        _selectData = [NSMutableArray array];
    }
    return _selectData;
}

- (NSMutableArray *)imagesData {
    if (_imagesData == nil) {
        _imagesData = [NSMutableArray array];
    }
    return _imagesData;
}


@end


#undef kSearchTypeKey
#undef kSearchTypeValue
