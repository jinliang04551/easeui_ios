//
//  EaseCreateOrderMessageViewController.h
//  EaseIMKit
//
//  Created by liu001 on 2022/11/3.
//

#import <UIKit/UIKit.h>
#import "EaseChatViewModel.h"
#import "EMRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EaseCreateOrderChatMessageViewController : UIViewController


@property (nonatomic, strong) NSString *navTitle;

- (instancetype)initWithDataArray:(NSMutableArray *)dataArray withViewModel:(EaseChatViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
