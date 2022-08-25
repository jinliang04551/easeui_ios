//
//  EaseLocationResultModel.h
//  EaseIMKit
//
//  Created by liu001 on 2022/8/25.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EaseLocationResultModel : NSObject

@property (nonatomic, strong) MKMapItem *mapItem;
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
