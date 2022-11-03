//
//  EaseCreateOrderMessageViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/11/3.
//

#import "EaseCreateOrderChatMessageViewController.h"
#import "EaseHeaders.h"
#import "EaseIMKitManager.h"
#import "EaseMessageCell.h"


@interface EaseCreateOrderChatMessageViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) EaseChatViewModel *viewModel;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation EaseCreateOrderChatMessageViewController

- (instancetype)initWithDataArray:(NSMutableArray *)dataArray withViewModel:(EaseChatViewModel *)viewModel {
    self = [super init];
    if(self){
        self.dataArray = dataArray;
        self.viewModel = viewModel;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registeCell];
    [self placeAndLayoutSubviews];
    [self.tableView reloadData];
}


- (void)registeCell {
    
    [self.tableView registerClass:[EaseMessageCell class] forCellReuseIdentifier:NSStringFromClass([EaseMessageCell class])];
}

#pragma mark - Subviews
- (void)placeAndLayoutSubviews
{
    self.titleView = [self customNavWithTitle:self.navTitle rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];
    
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];
    
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
        
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.dataArray objectAtIndex:indexPath.row];

    EaseMessageModel *model = (EaseMessageModel *)obj;

    NSString *identifier = [EaseMessageCell cellIdentifierWithDirection:EMMessageDirectionReceive type:model.type];
    EaseMessageCell *cell = (EaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
   
    // Configure the cell...
    if (cell == nil) {
        cell = [[EaseMessageCell alloc] initWithDirection:EMMessageDirectionReceive chatType:model.message.chatType messageType:model.type viewModel:_viewModel];
        cell.delegate = self;
        cell.isCreateOrderSelectedMode = YES;
    }
    
    if (self.tableView.isEditing) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.model = model;
    if (cell.model.message.body.type == EMMessageTypeVoice) {
        cell.model.weakMessageCell = cell;
    }
    return cell;
}
 
#pragma mark getter and setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 130;
        
    }
    
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end



