//
//  JHOrderContainerViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/7/29.
//

#import "JHOrderContainerViewController.h"
#import "MISScrollPage.h"

#import "EaseHeaders.h"
#import "JHOrderViewController.h"


#define kViewTopPadding  200.0f

@interface JHOrderContainerViewController ()<MISScrollPageControllerDataSource,
MISScrollPageControllerDelegate>

@property (nonatomic, strong) MISScrollPageController *pageController;
@property (nonatomic, strong) MISScrollPageSegmentView *segView;
@property (nonatomic, strong) MISScrollPageContentView *contentView;
@property (nonatomic, assign) NSInteger currentPageIndex;

@property (nonatomic,strong) JHOrderViewController *order1VC;
@property (nonatomic,strong) JHOrderViewController *order2VC;
@property (nonatomic,strong) JHOrderViewController *order3VC;
@property (nonatomic,strong) JHOrderViewController *order4VC;

@property (nonatomic, strong) NSMutableArray *navTitleArray;
@property (nonatomic, strong) NSMutableArray *contentVCArray;

@property (nonatomic, strong) EMConversation *conversation;

@property (nonatomic, strong) UIView *titleView;

@end

@implementation JHOrderContainerViewController
- (instancetype)initWithCoversationModel:(EMConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        [self setTitleAndContentVC];
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"订单信息";

    if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//        self.view.backgroundColor = EaseIMKit_ViewBgBlackColor;
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }else {
        self.view.backgroundColor = EaseIMKit_ViewBgWhiteColor;
    }
    
    [self setTitleAndContentVC];
    [self placeAndLayoutSubviews];
    [self.pageController reloadData];
}

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)placeAndLayoutSubviews {
    
    self.titleView = [self customNavWithTitle:self.title rightBarIconName:@"" rightBarTitle:@"" rightBarAction:nil];

    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@(EaseIMKit_NavBarAndStatusBarHeight));
    }];


    [self.view addSubview:self.segView];
    [self.view addSubview:self.contentView];
    
    [self.segView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark private method
- (BOOL)isGroupChat {
    BOOL _groupChat = self.conversation.type == EMConversationTypeGroupChat ? YES : NO;
    return _groupChat;
}


- (void)setTitleAndContentVC {
    
    self.navTitleArray = [
        @[@"维保订单",@"取送订单",@"精品订单",@"服务订单"] mutableCopy];
    self.contentVCArray = [@[self.order1VC,self.order2VC,self.order3VC,self.order4VC] mutableCopy];
    
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
        style.showSegmentViewSeparatorLine = NO;

if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
        style.showCover = NO;
        style.coverBackgroundColor = EaseIMKit_COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = EaseIMKit_COLOR_HEX(0x7E7E7E);
        style.selectedTitleColor = EaseIMKit_COLOR_HEX(0xB9B9B9);
        style.scrollLineColor = EaseIMKit_Default_BgBlue_Color;
        style.segmentViewBackgroundColor = EaseIMKit_ViewBgBlackColor;
}else {

        style.showCover = NO;
        style.coverBackgroundColor = EaseIMKit_COLOR_HEX(0xD8D8D8);
        style.gradualChangeTitleColor = YES;
        style.normalTitleColor = EaseIMKit_COLOR_HEX(0x999999);
        style.selectedTitleColor = EaseIMKit_COLOR_HEX(0x000000);
        style.scrollLineColor = EaseIMKit_Default_BgBlue_Color;
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


- (JHOrderViewController *)order1VC {
    if (_order1VC == nil) {
        _order1VC = [[JHOrderViewController alloc] initWithOrderType:1];
        EaseIMKit_WS
        _order1VC.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
            if (weakSelf.sendOrderBlock) {
                weakSelf.sendOrderBlock(orderModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        };
    }
    return _order1VC;
}

- (JHOrderViewController *)order2VC {
    if (_order2VC == nil) {
        _order2VC = [[JHOrderViewController alloc] initWithOrderType:2];
        EaseIMKit_WS
        _order2VC.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
            if (weakSelf.sendOrderBlock) {
                weakSelf.sendOrderBlock(orderModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];

            }
        };
    }
    return _order2VC;
}

- (JHOrderViewController *)order3VC {
    if (_order3VC == nil) {
        _order3VC = [[JHOrderViewController alloc] initWithOrderType:3];
        EaseIMKit_WS
        _order3VC.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
            if (weakSelf.sendOrderBlock) {
                weakSelf.sendOrderBlock(orderModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];

            }
            
        };
    }
    return _order3VC;
}


- (JHOrderViewController *)order4VC {
    if (_order4VC == nil) {
        _order4VC = [[JHOrderViewController alloc] initWithOrderType:4];
        EaseIMKit_WS
        _order4VC.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
            if (weakSelf.sendOrderBlock) {
                weakSelf.sendOrderBlock(orderModel);
                [weakSelf.navigationController popViewControllerAnimated:YES];

            }
        };
    }
    return _order4VC;
}



@end

#undef kViewTopPadding

