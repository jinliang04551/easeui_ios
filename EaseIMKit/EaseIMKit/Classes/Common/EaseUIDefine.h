//
//  EaseUIDefine.h
//  Pods
//
//  Created by liu001 on 2022/7/13.
//

#ifndef EaseUIDefine_h
#define EaseUIDefine_h

#import "UIImage+EaseUI.h"


#define EaseIMKit_IsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#define EaseIMKit_VIEWTOPMARGIN (EaseIMKit_IsBangsScreen ? 34.f : 0.f)

#define EaseIMKit_ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define EaseIMKit_ScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define EaseIMKit_Is_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define EaseIMKit_Is_iPhoneX EaseIMKit_ScreenWidth >=375.0f && EaseIMKit_ScreenHeight >=812.0f&& EaseIMKit_Is_iphone
 
#define EaseIMKit_StatusBarHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(44.0):(20.0))
#define EaseIMKit_NavBarHeight (44)

#define EaseIMKit_NavBarAndStatusBarHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(88.0):(64.0))

#define EaseIMKit_TabBarHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(49.0 + 34.0):(49.0))

#define EaseIMKit_TopBarSafeHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(44.0):(0))

#define EaseIMKit_BottomSafeHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(34.0):(0))

#define EaseIMKit_TopBarDifHeight (CGFloat)(EaseIMKit_Is_iPhoneX?(24.0):(0))

#define EaseIMKitNavAndTabHeight (EaseIMKit_NavBarAndStatusBarHeight + EaseIMKit_TabBarHeight)


#define EaseIMKit_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// rgb颜色转换（16进制->10进制）
#define EaseIMKit_COLOR_HEXA(__RGB,__ALPHA) [UIColor colorWithRed:((float)((__RGB & 0xFF0000) >> 16))/255.0 green:((float)((__RGB & 0xFF00) >> 8))/255.0 blue:((float)(__RGB & 0xFF))/255.0 alpha:__ALPHA]

#define EaseIMKit_COLOR_HEX(__RGB) EaseIMKit_COLOR_HEXA(__RGB,1.0f)

//weak & strong self
#define EaseIMKit_WS                  __weak __typeof(&*self)weakSelf = self;
#define EaseIMKit_SS(WKSELF)          __strong __typeof(&*self)strongSelf = WKSELF;

#define EaseIMKit_ONE_PX  (1.0f / [UIScreen mainScreen].scale)


#define EaseIMKit_AvatarHeight 38.0f
#define EaseIMKit_ContactAvatarHeight 40.0f
#define EaseIMKit_SearchBarHeight 32.0
#define EaseIMKit_Padding 10.0


//fonts
#define EaseIMKit_NFont(__SIZE) [UIFont systemFontOfSize:__SIZE] //system font with size
#define EaseIMKit_IFont(__SIZE) [UIFont italicSystemFontOfSize:__SIZE] //system font with size
#define EaseIMKit_BFont(__SIZE) [UIFont boldSystemFontOfSize:__SIZE]//system bold font with size
#define EaseIMKit_Font(__NAME, __SIZE) [UIFont fontWithName:__NAME size:__SIZE] //font with name and size



#define EaseIMKit_InputGrayColor  EaseIMKit_COLOR_HEX(0x3D3D3D)

#define EaseIMKit_ViewBgBlackColor  EaseIMKit_COLOR_HEX(0x171717)

#define EaseIMKit_ViewCellBgBlackColor   EaseIMKit_COLOR_HEX(0x1C1C1C)

#define EaseIMKit_ViewBgWhiteColor  EaseIMKit_COLOR_HEX(0xF5F5F5)

#define EaseIMKit_ViewCellBgWhiteColor   EaseIMKit_COLOR_HEX(0xFFFFFF) 

#define EaseIMKit_TitleBlueColor  EaseIMKit_COLOR_HEX(0x4798CB)


#define EaseIMKit_Color_textViewGray [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0]

#define EaseIMKit_Color_LightGray [UIColor colorWithRed:245 / 255.0 green:245 / 255.0 blue:245 / 255.0 alpha:1.0]

#define EaseIMKit_Color_Gray [UIColor colorWithRed:229 / 255.0 green:229 / 255.0 blue:229 / 255.0 alpha:1.0]

#define EaseIMKit_Color_Blue [UIColor colorWithRed:45 / 255.0 green:116 / 255.0 blue:215 / 255.0 alpha:1.0]


#endif /* EaseUIDefine_h */
