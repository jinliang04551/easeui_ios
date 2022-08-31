//
//  YGGroupSearchTypeTableView.m
//  EaseIM
//
//  Created by liu001 on 2022/7/20.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupSearchTypeTableView.h"
#import "EaseHeaders.h"

#define kSearchTypeKey @"kSearchTypeKey"
#define kSearchTypeValue @"kSearchTypeValue"


@interface YGGroupSearchTypeTableView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) YGSearchGroupType searchGroupType;

@property (nonatomic, strong) UIView *contentView;


@end

@implementation YGGroupSearchTypeTableView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.searchGroupType = YGSearchGroupTypeGroupName;
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
    [self.dataArray addObject:@{kSearchTypeKey:@"群名称",kSearchTypeValue:@(YGSearchGroupTypeGroupName)}];
    [self.dataArray addObject:@{kSearchTypeKey:@"订单号",kSearchTypeValue:@(YGSearchGroupTypeOrderId)}];
    [self.dataArray addObject:@{kSearchTypeKey:@"客户手机号",kSearchTypeValue:@(YGSearchGroupTypePhone)}];
    
    [self.dataArray addObject:@{kSearchTypeKey:@"VIN码",kSearchTypeValue:@(YGSearchGroupTypeVINCode)}];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.dataArray count];
}

static NSString *CellIdentifier = @"YGAvatarTitleAccessCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#171717"];
        cell.textLabel.font = EaseIMKit_NFont(14.0);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        if (cell.isHighlighted) {
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#ECF5FF"];
            
        }
        
        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
        view_bg.backgroundColor = [UIColor colorWithHexString:@"#ECF5FF"];;
        cell.selectedBackgroundView = view_bg;
    }
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    cell.textLabel.text = dic[kSearchTypeKey];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.dataArray[indexPath.row];
    if (self.selectedBlock) {
        self.selectedBlock(dic[kSearchTypeKey], [dic[kSearchTypeValue] integerValue]);
        self.searchGroupType = [dic[kSearchTypeValue] integerValue];
    }
    
}

#pragma mark getter and setter
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 36.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = EaseIMKit_ViewBgWhiteColor;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.scrollEnabled = NO;
        
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


@end


#undef kSearchTypeKey
#undef kSearchTypeValue
