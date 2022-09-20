
/***********************************************************
 //  MISImagePickerController.m
 //  Mao Kebing
 //  Created by Edu on 13-7-25.
 //  Copyright (c) 2013 Eduapp. All rights reserved.
 ***********************************************************/

#import "MISImagePickerController.h"
#import "MISImagePickerThumbController.h"
#import "MISImagePickerAlbumsController.h"
#import "MISImagePickerManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIViewController+MISImagePicker.h"





static MISImagePickerController* instance = nil;

@interface MISImagePickerController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) UIViewController* parentController;

@end

@implementation MISImagePickerController

#pragma mark - Lifecycle

- (instancetype)init {
	self = [super init];
	if (self) {
		self.maxImageCount = 9;
		
		//默认缩放
		self.scaleAspectFitSize = CGSizeMake(1280, 1280);
		
		//默认视频时长
		self.videoMaximumDuration = 60;
		
		self.scale = 0.0f;
	}
	return self;
}

- (void)dealloc {
//	MISLogLine;
}

#pragma mark - Public Methods

- (void)presentImagePickerInViewController:(UIViewController *)viewController {
	instance = self;//存活
	
	self.parentController = viewController;
	
	switch (self.sourceType) {
		case MISImagePickerSorceTypeMulti: {
			[self openMultiImagePicker];
		}
			break;
		case MISImagePickerSorceTypeAlbums: {
			[self openAlbumImagePicker];
		}
			break;
		case MISImagePickerSorceTypeCamera: {
			[self openCameraImagePicker];
		}
			break;
		case MISImagePickerSorceTypeVideo: {
			[self openVideoImagePicker];
		}
			break;
		case MISImagePickerSorceTypeAlbumVideo: {
			[self openAlbumVideoPicker];
		}break;
	}
}

/**
 *  打开多选相册
 */
- (void)openMultiImagePicker {
	if (![[self class] isPhotosLibraryAvailable]) {
		return;
	}
    
	/**
	 *  检测相册授权
	 */
	[[MISImagePickerManager defaultManager] albumAuthorizationInViewController:self.parentController availableCompletion:^{
		MISImagePickerAlbumsController* controller = [[MISImagePickerAlbumsController alloc] init];
		controller.selectedFinishBlock             = self.selectedFinishBlock;
		controller.seletedLimitBlock               = self.seletedLimitBlock;
		controller.maxImageCount                   = self.maxImageCount;
		controller.scaleAspectFitSize              = self.scaleAspectFitSize;
		controller.scale                           = self.scale;
		
		UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:controller];
        nav.modalPresentationStyle =  UIModalPresentationFullScreen;

		[self.parentController presentViewController:nav animated:YES completion:nil];
	}];
}

/**
 *  打开系统相册
 */
- (void)openAlbumImagePicker {
	if (![[self class] isPhotosLibraryAvailable]) {
		return;
	}
    
	/**
	 *  检测相册授权
	 */
    [[MISImagePickerManager defaultManager] albumAuthorizationInViewController:self.parentController availableCompletion:^{
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.allowsEditing = self.allowsEditing;
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle =  UIModalPresentationFullScreen;
		[self.parentController presentViewController:picker animated:YES completion:nil];
	}];
}

/**
 *  打开系统相册
 */
- (void)openAlbumVideoPicker {
	if (![[self class] isPhotosLibraryAvailable]) {
		return;
	}
	
	/**
	 *  检测相册授权
	 */
    [[MISImagePickerManager defaultManager] albumAuthorizationInViewController:self.parentController availableCompletion:^{
		//缓存目录设定
		[MISImagePickerManager defaultManager].defaultCachePath = self.defaultCachePath;
		[MISImagePickerManager defaultManager].videoMaximumDuration = self.videoMaximumDuration;
		
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.allowsEditing = self.allowsEditing;
		picker.delegate = self;
		picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		picker.mediaTypes = @[(NSString *)kUTTypeMovie];
        picker.modalPresentationStyle =  UIModalPresentationFullScreen;
		[self.parentController presentViewController:picker animated:YES completion:nil];
	}];
}

/**
 *  打开相机-拍照
 */
- (void)openCameraImagePicker {
	if (![[self class] isCameraAvailable]) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备不支持拍照功能!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self.parentController presentViewController:alertController animated:YES completion:nil];
        return;
	}
	
	/**
	 *  检测相机授权
	 */
	[[MISImagePickerManager defaultManager] cameraAuthorizationInViewController:self.parentController availableCompletion:^{
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
		picker.allowsEditing = self.allowsEditing;
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.delegate = self;
        picker.modalPresentationStyle =  UIModalPresentationFullScreen;
		[self.parentController presentViewController:picker animated:YES completion:nil];
	}];
}

/**
 *  打开相机-录视频
 */
- (void)openVideoImagePicker {
	if (![[self class] isCameraAvailable]) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"该设备不支持摄像功能!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self.parentController presentViewController:alertController animated:YES completion:nil];
		return;
	}
	
	//缓存目录设定
	[MISImagePickerManager defaultManager].defaultCachePath = self.defaultCachePath;
	[MISImagePickerManager defaultManager].videoMaximumDuration = self.videoMaximumDuration;
	
	/**
	 *  检测相机授权
	 */
	[[MISImagePickerManager defaultManager] cameraAuthorizationInViewController:self.parentController availableCompletion:^{
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing            = self.allowsEditing;
        picker.sourceType               = UIImagePickerControllerSourceTypeCamera;
        picker.videoMaximumDuration     = self.videoMaximumDuration;
        picker.videoQuality             = UIImagePickerControllerQualityTypeMedium; //视频质量
        NSArray* availableMedia         = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        picker.mediaTypes               = [NSArray arrayWithObject:availableMedia[1]];//录相
        picker.delegate                 = self;
        picker.modalPresentationStyle =  UIModalPresentationFullScreen;
		[self.parentController presentViewController:picker animated:YES completion:nil];
	}];
}

/**
 *  缩放处理图片
 *
 *  @param image 图片数组
 */
- (void)processImage:(UIImage *)image {
	[self.parentController mis_imgpk_showWait];
	
	[[MISImagePickerManager defaultManager] scaleImage:image
											   maxSize:self.scaleAspectFitSize
												 scale:self.scale
											completion:^(UIImage *scaledImage) {
												[self.parentController mis_imgpk_hideWait];
												if (scaledImage) {
													[self.parentController dismissViewControllerAnimated:YES completion:^{
														if (self.selectedFinishBlock) {
															self.selectedFinishBlock(@[scaledImage]);
														}
													}];
												}
											}];
}

/**
 *  处理视频
 *
 *  @param url 视频 AVAsset NSURL
 */
- (void)processVideoWithURL:(NSURL *)url {
	[self.parentController mis_imgpk_showWait];
	[[MISImagePickerManager defaultManager] encodeVideoWithURL:url completion:^(NSString* filePath, NSInteger fileSize, UIImage* thumbnail, NSInteger duration) {
		[self.parentController mis_imgpk_hideWait];
		
		//编码出错
		if (filePath.length == 0 || fileSize == -1) {
			return ;
		}
		
		NSLog(@"filePath:%@ fileSize:%@ thumbImage:%@ duration:%@", filePath, @(fileSize), thumbnail, @(duration));
		
		//提示框
		NSString* message = [NSString stringWithFormat:@"视频压缩后文件大小为%.2fM, 确定要发送吗？", (float)fileSize / 1024];
		if (fileSize < 1024) {
			message = [NSString stringWithFormat:@"视频压缩后文件大小为%ldK, 确定要发送吗？", (long)fileSize];
		}        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.pickVideoFinishBlock)
                self.pickVideoFinishBlock(filePath, fileSize, thumbnail, duration);
        }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self.parentController presentViewController:alertController animated:YES completion:nil];
	}];
}

#pragma mark - Getter

- (NSString *)defaultCachePath {
	if (!_defaultCachePath) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_defaultCachePath = [paths[0] stringByAppendingPathComponent:@"Cache"];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:_defaultCachePath])
		{
			[[NSFileManager defaultManager] createDirectoryAtPath:_defaultCachePath
									  withIntermediateDirectories:YES
													   attributes:nil
															error:NULL];
		}
	}
	
	return _defaultCachePath;
}

#pragma mark - Class Methods

/**
 *  是否能用相册
 *
 *  @return BOOL
 */
+ (BOOL)isPhotosLibraryAvailable {
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary];
}

/**
 *  是否能用相机
 *
 *  @return BOOL
 */
+ (BOOL)isCameraAvailable {
	return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	//视频URL接收
	if (self.sourceType == MISImagePickerSorceTypeVideo
		||self.sourceType == MISImagePickerSorceTypeAlbumVideo) {
		NSURL* url = info[UIImagePickerControllerMediaURL];
		[self processVideoWithURL:url];
	}else {
		//图片接收
		if (self.selectedFinishBlock) {
			UIImage* image = self.allowsEditing ? info[UIImagePickerControllerEditedImage] : info[UIImagePickerControllerOriginalImage];
			[self processImage:image];
		}
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[self.parentController dismissViewControllerAnimated:YES completion:nil];
}

@end



