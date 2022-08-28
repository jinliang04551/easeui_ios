//
//  EaseLocationViewController.m
//  EaseIMKit
//
//  Created by liu001 on 2022/8/26.
//

#import "EaseLocationViewController.h"
#import "EaseHeaders.h"
#import "EaseAlertController.h"
#import "EaseAlertView.h"
#import "EaseLocationSearchResultTableView.h"
#import "EaseLocationResultModel.h"


@interface EaseLocationViewController ()<MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) BOOL canSend;

@property (nonatomic) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *buildingName;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKPointAnnotation *annotation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *sendLocationBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) EaseLocationSearchResultTableView *searchResultTableView;
@property (nonatomic, strong) NSMutableArray *searchDataArray;


@property (nonatomic, strong) MKUserLocation *currentUserLocation;

@property (nonatomic, strong) NSString *searchKey;
@property (nonatomic, strong) EaseLocationResultModel *currentLocationModel;

@property (nonatomic) BOOL hasLocationed;

@end

@implementation EaseLocationViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canSend = YES;
    }
    
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)aLocationCoordinate
{
    self = [super init];
    if (self) {
        _canSend = NO;
        _locationCoordinate = aLocationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchKey = @"大厦";
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self _setupSubviews];
    
    if (self.canSend) {
        self.mapView.showsUserLocation = YES;//显示当前位置
        [self _startLocation];
    } else {
        [self _moveToLocation:self.locationCoordinate];
    }
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    /*
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage easeUIImageNamed:@"navbar_white"] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage easeUIImageNamed:@"close_gray"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(closeAction)];
    if (self.canSend) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EaseLocalizableString(@"send", nil) style:UIBarButtonItemStylePlain target:self action:@selector(sendAction)];
    }
    self.title = @"地理位置";*/
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.sendLocationBtn];
    [self.view addSubview:self.cancelBtn];
    
    
    [self.sendLocationBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.width.equalTo(@58);
        make.height.equalTo(@28);
        make.top.equalTo(self.view).offset(55);
        make.right.equalTo(self.view).offset(-16.0);
    }];
    
    [self.cancelBtn Ease_makeConstraints:^(EaseConstraintMaker *make) {
        make.width.equalTo(@(38.0));
        make.height.equalTo(@(40.0));
        make.centerY.equalTo(self.sendLocationBtn);
        make.left.equalTo(self.view).offset(12.0);
    }];

    
    if (!self.canSend) {
        self.sendLocationBtn.hidden = YES;
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];

    }else {
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, EaseIMKit_ScreenHeight * 0.5, 0));
        }];

        
        [self.view addSubview:self.searchResultTableView];
        [self.searchResultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
//            make.top.equalTo(self.view.mas_centerY);
            make.top.equalTo(self.mapView.mas_bottom);
        }];
    }
    
    self.annotation = [[MKPointAnnotation alloc] init];

}

#pragma mark - Private

- (void)_startLocation
{
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 20;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//kCLLocationAccuracyBest;
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
}


- (void)_moveToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self hideHud];
    
    self.locationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(self.locationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    [self.mapView removeAnnotation:self.annotation];
    self.annotation.coordinate = locationCoordinate;
    [self.mapView addAnnotation:self.annotation];
}


- (void)fetchNearbyInfoWithLocation:(CLLocation *)location KeyStr:(NSString *)keyStr{
    
    MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location.coordinate, 1000 ,1000);
    
    MKLocalSearchRequest *requst = [[MKLocalSearchRequest alloc] init];
    requst.region = region;
    requst.naturalLanguageQuery = keyStr; //想要的信息
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:requst];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        if (!error) {
            [self loadCurrentArroundPosition:response];
        }else{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取附近地理位置信息失败，请手动输入。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//
//            [alert show];
        }
    }];
    
}

- (void)loadCurrentArroundPosition:(MKLocalSearchResponse *)response {
    NSLog(@"%s",__func__);
    NSMutableArray *tArray = [NSMutableArray array];
    
    for (int i = 0; i < response.mapItems.count; ++i) {
        MKMapItem *mapItem = response.mapItems[i];

        EaseLocationResultModel *model = [[EaseLocationResultModel alloc] init];
        model.mapItem = mapItem;
        if (i == 0) {
            self.currentLocationModel = model;
            model.isSelected = YES;
            [self saveLocationInfoWithPlacemark:model.mapItem.placemark];
        }
        if (model) {
            [tArray addObject:model];
        }
    }
    self.searchDataArray = [tArray mutableCopy];
    self.hasLocationed = YES;
    
    [self.searchResultTableView updateWithSearchResultArray:self.searchDataArray];
}


#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
}


- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self hideHud];
    if (error.code == 0) {
        EaseAlertView *alertView = [[EaseAlertView alloc]initWithTitle:nil message:[error.userInfo objectForKey:NSLocalizedRecoverySuggestionErrorKey]];
        [alertView show];
    }
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    NSLog(@"%s",__func__);

    MKUserLocation *location = mapView.userLocation;
    self.currentUserLocation = location;

    if (self.hasLocationed) {
        return;
    }
    
    [self fetchNearbyInfoWithLocation:location.location KeyStr:self.searchKey];

}

#pragma mark - KeyBoard
- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    CGFloat offset = 0;
    CGFloat searchBarBottomY = EaseIMKit_ScreenHeight * 0.5 +48;
    
    if (EaseIMKit_ScreenHeight - keyBoardHeight <= searchBarBottomY) {
        offset = searchBarBottomY - (EaseIMKit_ScreenHeight - keyBoardHeight);
    } else {
        return;
    }

    void (^animation)(void) = ^void(void) {
        [self.searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mapView.mas_bottom).offset(-offset);
        }];
    };
    
    [self keyBoardWillShow:note animations:animation completion:nil];
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    void (^animation)(void) = ^void(void) {
        [self.searchResultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mapView.mas_bottom);
        }];
    };
    [self keyBoardWillHide:note animations:animation completion:nil];
}


#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *loc = [locations firstObject];

    //根据获取的地理位置，获取位置信息
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:[locations objectAtIndex:0] completionHandler:^(NSArray *array, NSError *error) {
        //成功
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            NSLog(@"dic ---- %@", [placemark addressDictionary]);//具体代表什么，看输出就知道了
        //失败
        }else if (error == nil && array.count == 0){
            NSLog(@"无返回信息");
        }else if (error != nil){
            NSLog(@"error occurred = %@", error);
        }
    }];
    
    CLLocation *location = locations[0];
    [self _moveToLocation:location.coordinate];
    
    [self.locationManager stopUpdatingLocation];

}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [self.locationManager requestWhenInUseAuthorization];
            }
            break;
        case kCLAuthorizationStatusDenied:
            break;
        default:
            break;
    }
}


#pragma mark - Action

- (void)closeAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.sendCompletion) {
            self.sendCompletion(self.locationCoordinate, self.address, self.buildingName?self.buildingName:@"");
        }
    }];
}

#pragma mark - Getter

- (UIButton *)sendLocationBtn
{
    if (_sendLocationBtn == nil) {
        _sendLocationBtn = [[UIButton alloc]init];
        [_sendLocationBtn setTitle:EaseLocalizableString(@"send", nil) forState:UIControlStateNormal];
        _sendLocationBtn.layer.cornerRadius = 4;
        _sendLocationBtn.backgroundColor = [UIColor colorWithHexString:@"#4798CB"];
        [_sendLocationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendLocationBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
        [_sendLocationBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendLocationBtn;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil) {
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setImage:[UIImage easeUIImageNamed:@"ease_location_cancel"] forState:UIControlStateNormal];
        
        [_cancelBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (MKMapView *)mapView {
    if (_mapView == nil) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.zoomEnabled = YES;
        _mapView.userTrackingMode = MKUserTrackingModeFollow;
        
    }
    return _mapView;
}


- (EaseLocationSearchResultTableView *)searchResultTableView {
    if (_searchResultTableView == nil) {
        _searchResultTableView = [[EaseLocationSearchResultTableView alloc] init];
        EaseIMKit_WS
        
        _searchResultTableView.selectedBlock = ^(EaseLocationResultModel * _Nonnull model) {
            [weakSelf updateLocationInfoWithModel:model];
            
        };
        
        _searchResultTableView.searchLocationBlock = ^(NSString * _Nonnull searchLocation) {
            weakSelf.searchKey = searchLocation;
            [weakSelf fetchNearbyInfoWithLocation:weakSelf.currentUserLocation.location KeyStr:searchLocation];

        };
    }
    return _searchResultTableView;
}

- (NSMutableArray *)searchDataArray {
    if (_searchDataArray == nil) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}


- (void)updateSearchResultData {
    for (EaseLocationResultModel *model in self.searchDataArray) {
        if (self.currentLocationModel == model) {
            model.isSelected = YES;
        }else {
            model.isSelected = NO;
        }
    }
    
    [self.searchResultTableView updateWithSearchResultArray:self.searchDataArray];
}

- (void)updateLocationInfoWithModel:(EaseLocationResultModel *)model {
    self.currentLocationModel = model;
    
    MKPlacemark *placemark = model.mapItem.placemark;
    [self saveLocationInfoWithPlacemark:placemark];
    [self _moveToLocation:self.locationCoordinate];
    
    [self updateSearchResultData];
}

- (void)saveLocationInfoWithPlacemark:(MKPlacemark *)placemark {
    self.locationCoordinate = placemark.coordinate;
    self.address = placemark.thoroughfare;
    self.buildingName = placemark.name;
}

@end

