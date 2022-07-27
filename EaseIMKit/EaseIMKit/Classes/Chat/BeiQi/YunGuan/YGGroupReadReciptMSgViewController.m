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

@property (nonatomic, strong) NSMutableArray *readMsgArray;
@property (nonatomic, strong) NSMutableArray *unReadMsgArray;


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

    [self addPopBackLeftItemWithTarget:self action:@selector(backItemAction)];
    
    [self setTitleAndContentVC];
    [self placeAndLayoutSubviews];
    [self.pageController reloadData];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)placeAndLayoutSubviews {
    [self.view addSubview:self.segView];
    [self.view addSubview:self.contentView];
    
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@(50.0));
    }];
    
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.segView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
}


- (void)fetchGroupMembers {
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
        }else {
            [EaseAlertController showErrorAlert:aError.debugDescription];
        }
    }];
    
}



#pragma mark private method
- (void)setTitleAndContentVC {
    self.navTitleArray = [
        @[@"2人已读",@"2人未读"] mutableCopy];
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
}else {

        style.showCover = NO;
        style.coverBackgroundColor = EaseIMKit_COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = EaseIMKit_COLOR_HEX(0x999999);
        style.selectedTitleColor = EaseIMKit_COLOR_HEX(0x000000);
        style.scrollLineColor = EaseIMKit_COLOR_HEXA(0x000000, 0.5);
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
        _segView = [self.pageController segmentViewWithFrame:CGRectMake(0, 0, EaseIMKit_ScreenWidth, 50)];
        
    }
    return _segView;
}


- (MISScrollPageContentView*)contentView {
    if(!_contentView){
        _contentView = [self.pageController contentViewWithFrame:CGRectMake(0, 50, EaseIMKit_ScreenWidth, EaseIMKit_ScreenHeight-EaseIMKit_NavBarAndStatusBarHeight - 50.0)];
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
        
    }
    return _msgReadVC;
}

- (YGGroupMsgReadController *)msgUnReadVC {
    if (_msgUnReadVC == nil) {
        _msgUnReadVC = [[YGGroupMsgReadController alloc] init];
    }
    return _msgUnReadVC;
}



@end

#undef kViewTopPadding
