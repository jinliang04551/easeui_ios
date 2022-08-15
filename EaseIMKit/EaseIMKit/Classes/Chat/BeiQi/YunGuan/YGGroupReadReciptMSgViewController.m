//
//  YGGroupReadReciptMSgViewController.m
//  EaseIM
//
//  Created by liu001 on 2022/7/25.
//  Copyright © 2022 liu001. All rights reserved.
//

#import "YGGroupReadReciptMSgViewController.h"
#import "MISScrollPage.h"

#import "EMChatRecordViewController.h"
#import "BQChatRecordFileViewController.h"
#import "BQChatRecordImageVideoViewController.h"
#import "EMChatViewController.h"
#import "BQChatRecordFilePreviewViewController.h"
#import "YGGroupMsgReadController.h"
#import "EaseHeaders.h"


#define kViewTopPadding  200.0f
#define kSegmentViewHeight 64.0

@interface YGGroupReadReciptMSgViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate>

@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic,strong) YGGroupMsgReadController *msgReadVC;

@property (nonatomic,strong) YGGroupMsgReadController *msgUnReadVC;


@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;
@property (nonatomic, strong) EMChatMessage *message;
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) NSMutableArray *memberIdArray;
@property (nonatomic, strong) NSMutableArray *readMsgArray;
@property (nonatomic, strong) NSMutableArray *unReadMsgArray;
@property (nonatomic, strong) UIView *titleView;


@end

@implementation YGGroupReadReciptMSgViewController
- (instancetype)initWithMessage:(EMChatMessage *)message
                        groupId:(NSString *)groupId {
    self = [super init];
    if(self){
        self.message = message;
        self.groupId = groupId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息详情";

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }
    
    [self fetchGroupInfo];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)placeAndLayoutSubviews {
    
    self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(EaseIMKit_StatusBarHeight);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(44.0));
    }];

    
    [self.view addSubview:self.segView];
    [self.view addSubview:self.contentView];
    
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(kSegmentViewHeight));
    }];
    
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segView.mas_bottom);
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


- (void)fetchGroupInfo {
    [self showHudInView:self.view hint:@"加载中"];
    
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId fetchMembers:YES completion:^(EMGroup * _Nullable aGroup, EMError * _Nullable aError) {
        if (aError == nil) {
            self.group = aGroup;
            NSMutableArray *tArray = [NSMutableArray array];
            [tArray addObject:self.group.owner];
            if (self.group.adminList.count > 0) {
                [tArray addObjectsFromArray:self.group.adminList];
            }
            if (self.group.memberList.count > 0) {
                [tArray addObjectsFromArray:self.group.memberList];
            }
            self.memberIdArray = tArray;
            [self fetchMessageReadAck];
        }else {
            [self hideHud];
            
            [EaseAlertController showErrorAlert:aError.errorDescription
            ];
        }
        
    }];
}

- (void)fetchMessageReadAck {
    
    [[EMClient sharedClient].chatManager asyncFetchGroupMessageAcksFromServer:self.message.messageId groupId:self.groupId startGroupAckId:@"" pageSize:20 completion:^(EMCursorResult<EMGroupMessageAck *> * _Nullable aResult, EMError * _Nullable error, int totalCount) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
        });
        
        if (error == nil) {
            NSMutableArray *tArray = [NSMutableArray array];
            for (int i = 0; i < aResult.list.count; ++i) {
                EMGroupMessageAck *msgAck = aResult.list[i];
                if ([msgAck.messageId isEqualToString:self.message.messageId]) {
                    [tArray addObject:msgAck.from];
                }
            }
            self.readMsgArray = tArray;
            [self.memberIdArray removeObjectsInArray:self.readMsgArray];
            self.unReadMsgArray = self.memberIdArray;

            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUI];
            });
        }else {
            [EaseAlertController showErrorAlert:error.errorDescription
            ];
        }
    }];
    
}

- (void)updateUI {
    [self setTitleAndContentVC];
    [self placeAndLayoutSubviews];
    [self.pageController reloadData];
}

#pragma mark private method
- (void)setTitleAndContentVC {
    NSString *readTitle = [NSString stringWithFormat:@"%@人已读",@(self.readMsgArray.count)];
    NSString *unReadTitle = [NSString stringWithFormat:@"%@人未读",@(self.unReadMsgArray.count)];

    self.navTitleArray = [
        @[readTitle,unReadTitle] mutableCopy];
    self.contentVCArray = [@[self.msgReadVC,self.msgUnReadVC] mutableCopy];
}


#pragma mark - scrool pager data source and delegate
- (NSUInteger)numberOfChildViewControllers {
    return self.navTitleArray.count;
}

- (NSArray*)titlesOfSegmentView {
    return self.navTitleArray;
}


- (NSArray*)childViewControllersOfContentView {
    return self.contentVCArray;
}

#pragma mark -
- (void)scrollPageController:(id)pageController childViewController:(id<MISScrollPageControllerContentSubViewControllerDelegate>)childViewController didAppearForIndex:(NSUInteger)index {
    self.currentPageIndex = index;
}


#pragma mark - setter or getter
- (MISScrollPageController*)pageController {
    if(!_pageController){
        MISScrollPageStyle* style = [[MISScrollPageStyle alloc] init];

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        style.showCover = NO;
        style.coverBackgroundColor = EaseIMKit_COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = EaseIMKit_COLOR_HEX(0x7E7E7E);
        style.selectedTitleColor = EaseIMKit_COLOR_HEX(0xB9B9B9);
        style.scrollLineColor = EaseIMKit_COLOR_HEXA(0x000000, 0.5);
        style.segmentViewBackgroundColor = EaseIMKit_ViewBgBlackColor;
        style.showLine = NO;

}else {

        style.showCover = NO;
        style.coverBackgroundColor = EaseIMKit_COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = EaseIMKit_COLOR_HEX(0x999999);
        style.selectedTitleColor = EaseIMKit_COLOR_HEX(0x000000);
        style.scrollLineColor = EaseIMKit_COLOR_HEX(0x4798CB);
        style.showLine = YES;
}
        
        style.scaleTitle = YES;
        style.autoAdjustTitlesWidth = YES;
        style.titleBigScale = 1.05;
        style.titleFont = EaseIMKit_Font(@"PingFang SC",14.0);
        style.showSegmentViewShadow = NO;
        _pageController = [MISScrollPageController scrollPageControllerWithStyle:style dataSource:self delegate:self];

    }
    return _pageController;
}


- (MISScrollPageSegmentView*)segView{
    if(!_segView){
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, kSegmentViewHeight)];
        
    }
    return _segView;
}


- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight-EaseIMKit_NavBarAndStatusBarHeight - kSegmentViewHeight)];
    }
    return _contentView;
}


- (NSMutableArray *)navTitleArray {
    if (_navTitleArray == nil) {
        _navTitleArray = NSMutableArray.new;
    }
    return _navTitleArray;
}

- (NSMutableArray *)contentVCArray {
    if (_contentVCArray == nil) {
        _contentVCArray = NSMutableArray.new;
    }
    return _contentVCArray;
}


- (YGGroupMsgReadController *)msgReadVC {
    if (_msgReadVC == nil) {
        _msgReadVC = [[YGGroupMsgReadController alloc] init];
        _msgReadVC.dataArray = self.readMsgArray;
    }
    return _msgReadVC;
}

- (YGGroupMsgReadController *)msgUnReadVC {
    if (_msgUnReadVC == nil) {
        _msgUnReadVC = [[YGGroupMsgReadController alloc] init];
        _msgUnReadVC.dataArray = self.unReadMsgArray;
    }
    return _msgUnReadVC;
}

- (NSMutableArray *)memberIdArray {
    if (_memberIdArray == nil) {
        _memberIdArray = [NSMutableArray array];
    }
    return _memberIdArray;
}

- (NSMutableArray *)readMsgArray {
    if (_readMsgArray == nil) {
        _readMsgArray = [NSMutableArray array];
    }
    return _readMsgArray;
}

- (NSMutableArray *)unReadMsgArray {
    if (_unReadMsgArray == nil) {
        _unReadMsgArray = [NSMutableArray array];
    }
    return _unReadMsgArray;
}



@end

#undef kViewTopPadding
#undef kSegmentViewHeight

