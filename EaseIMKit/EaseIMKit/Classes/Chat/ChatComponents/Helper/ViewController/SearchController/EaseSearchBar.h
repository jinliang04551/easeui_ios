//
//  EMSearchBar.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/16.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EaseSearchBarDelegate;
@interface EaseSearchBar : UIView

@property (nonatomic, weak) id<EaseSearchBarDelegate> delegate;

@property (nonatomic, strong) UITextField *textField;

@end

@protocol EaseSearchBarDelegate <NSObject>

@optional

- (void)searchBarShouldBeginEditing:(EaseSearchBar *)searchBar;

- (void)searchBarCancelButtonAction:(EaseSearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(NSString *)aString;

- (void)searchTextDidChangeWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
