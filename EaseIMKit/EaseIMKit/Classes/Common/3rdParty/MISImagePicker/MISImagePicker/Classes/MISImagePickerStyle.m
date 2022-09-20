/***********************************************************
 //  MISImagePickerStyle.m
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import "MISImagePickerStyle.h"

#define IMAGE_PICKER_IMAGE_NAME(__NAME) ([UIImage imageNamed:(__NAME) inBundle:[NSBundle bundleWithPath:[NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"Frameworks/MISImagePicker.framework/MISImagePicker.bundle"]] compatibleWithTraitCollection:nil])

@implementation MISImagePickerStyle

/**
 *  定制选中图片正常
 *
 *  @return UIImage
 */
+ (UIImage *)checkBtnImage {
    return IMAGE_PICKER_IMAGE_NAME(@"mis_photo_thumb_check");
}

/**
 *  定制选中图片选中
 *
 *  @return UIImage
 */
+ (UIImage *)checkBtnHLImage {
    return IMAGE_PICKER_IMAGE_NAME(@"mis_photo_thumb_check_hl");
}


/**
 *  预览界面返回按钮
 *
 *  @return UIImage
 */
+ (UIImage *)previewNavigationBackBtnImage {
    return IMAGE_PICKER_IMAGE_NAME(@"mis_image_picker_button_back");
}


/**
 *  选中数徽标颜色
 *
 *  @return UIColor
 */
+ (UIColor *)badgeLabelColor {
    return [UIColor colorWithRed:0x32/255.0f green:0x89/255.0f blue:0xE4/255.0f alpha:1.0];
}

/**
 *  预览接钮字颜色
 *
 *  @return UIColor
 */
+ (UIColor *)previewBtnColor {
	return [UIColor blackColor];
}

/**
 *  预览接钮字不可用时的颜色
 *
 *  @return UIColor
 */
+ (UIColor *)previewBtnDisableColor {
	return [UIColor lightGrayColor];
}

/**
 *  完成接钮字颜色
 *
 *  @return UIColor
 */
+ (UIColor *)finishBtnColor {
    return [UIColor colorWithRed:0x32/255.0f green:0x89/255.0f blue:0xE4/255.0f alpha:1.0];
}

@end

#undef IMAGE_PICKER_IMAGE_NAME

