//
//  EaseChatViewController+ChatToolBarIncident.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/13.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "EaseChatViewController+ChatToolBarIncident.h"
#import <objc/runtime.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EaseLocationViewController.h"
#import "EaseAlertController.h"
#import "EaseAlertView.h"
#import "UIViewController+HUD.h"
#import "JHOrderContainerViewController.h"
#import "JHOrderViewModel.h"
#import "EaseLocationViewController.h"
#import "EaseHeaders.h"


#define kVideoMaxDuration 30

#define kVideoSizeLimit 100 * 1024 * 1024
/**
    媒体库
 */
static const void *imagePickerKey = &imagePickerKey;
@implementation EaseChatViewController (ChatToolBarMeida)

@dynamic imagePicker;

- (void)chatToolBarComponentIncidentAction:(EMChatToolBarComponentType)componentType
{
    [self.view endEditing:YES];
    [self setterImagePicker];

    if (componentType == EMChatToolBarCamera) {
        #if TARGET_IPHONE_SIMULATOR
            [EaseKitUtil showHint:EaseLocalizableString(@"simUnsupportCamera", nil)];
        #elif TARGET_OS_IPHONE
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
                [EaseKitUtil showHint:EaseLocalizableString(@"cameraPermissionDisabled", nil)];
                return;
            }
            __weak typeof(self) weakself = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakself.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        weakself.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
                        [weakself.imagePicker setVideoMaximumDuration:kVideoMaxDuration];

                        [weakself presentViewController:self.imagePicker animated:YES completion:nil];
                    });
                }
            }];
        #endif
        
        return;
    }
    PHAuthorizationStatus permissions = -1;
    if (@available(iOS 14, *)) {
        permissions = PHAuthorizationStatusLimited;
    }
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == permissions) {
                //limit权限
                [self openMutiImageOrVideo];

            }
            if (status == PHAuthorizationStatusAuthorized) {
                //已获取权限
                [self openMutiImageOrVideo];
                
            }
            if (status == PHAuthorizationStatusDenied) {
                //用户已经明确否认了这一照片数据的应用程序访问
                [EaseKitUtil showHint:EaseLocalizableString(@"photoPermissionDisabled", nil)];

            }
            if (status == PHAuthorizationStatusRestricted) {
                //此应用程序没有被授权访问的照片数据。可能是家长控制权限
                [EaseKitUtil showHint:EaseLocalizableString(@"fetchPhotoPermissionFail", nil)];
            }
        });
    }];
}

- (void)openImagePicker {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];

    [self presentViewController:self.imagePicker animated:YES completion:^{

    }];
}

- (void)openMutiImageOrVideo {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowPickingMultipleVideo = YES;
    imagePickerVc.showSelectedIndex = YES;
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowTakeVideo = NO;
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        for (int i = 0; i< assets.count; ++i) {
            PHAsset *asset = assets[i];
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [self parseImageWithAsset:asset];
            }
            
            if (asset.mediaType == PHAssetMediaTypeVideo) {
                [self parseVideoWithAsset:asset];
            }

        }
        
    }];
    
    imagePickerVc.didFinishPickingVideoHandle = ^(UIImage *coverImage, PHAsset *asset) {

        
    };
    
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)parseImageWithAsset:(PHAsset *)asset {
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
         float imageSize = imageData.length; //convert to MB
         imageSize = imageSize/(1024*1024.0);
         NSLog(@"%f",imageSize);
        
        [self _sendImageDataAction:imageData];
     }];
}


- (void)parseVideoWithAsset:(PHAsset *)asset {
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([asset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)asset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            NSLog(@"======size is %fM",[size floatValue]/(1024.0*1024.0)); //size is 43.703005

            NSURL *videoURL = urlAsset.URL;
            
//            NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
//            NSFileManager *fileman = [NSFileManager defaultManager];
//            if ([fileman fileExistsAtPath:videoURL.path]) {
//                NSError *error = nil;
//                [fileman removeItemAtURL:videoURL error:&error];
//                if (error) {
//                    NSLog(@"failed to remove file, error:%@.", error);
//                }
//            }
            [self _sendVideoAction:videoURL];
        }

    }];
}


- (BOOL)isAssetCanBeSelected:(PHAsset *)asset {
    __block BOOL isCanSelected = YES;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

       dispatch_queue_t queue = dispatch_queue_create("task", DISPATCH_QUEUE_CONCURRENT);
       dispatch_async(queue, ^{
           NSLog(@"1===task===%@", [NSThread currentThread]);

           if (asset.mediaType == PHAssetMediaTypeVideo) {
               PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
               options.version = PHVideoRequestOptionsVersionOriginal;

               [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                   if ([asset isKindOfClass:[AVURLAsset class]]) {
                       AVURLAsset* urlAsset = (AVURLAsset*)asset;
                       NSNumber *size;
                       [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                       
                       if ([size floatValue] > kVideoSizeLimit) {
                           dispatch_async(dispatch_get_main_queue(), ^{
                            [self showHint:@"视频文件不能超过100M"];
                           });

                           isCanSelected = NO;
                       }
                   }

                   dispatch_semaphore_signal(semaphore);

                }];
           }else {
               dispatch_semaphore_signal(semaphore);
           }
       });

       dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
       dispatch_async(queue, ^{
       });
    
    return isCanSelected;
        
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        
        NSLog(@"%s didFinishPickingMediaWithInfo",__func__);

        NSLog(@"%@",[NSString stringWithFormat:@"%f s", [EaseKitUtil getVideoLength:videoURL]]);
         NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [EaseKitUtil getFileSize:[videoURL path]]]);

        
        // we will convert it to mp4 format
        NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self _sendVideoAction:mp4];
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _sendImageDataAction:data];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                if(result.count == 0){
                    [EaseKitUtil showHint:@"无权访问该相册"];
                }else{
                    for (PHAsset *asset in result) {
                        NSArray <PHAssetResource *>*resources = [PHAssetResource assetResourcesForAsset:asset];
                        if (resources.count > 0) {
                            if ([resources.firstObject.uniformTypeIdentifier isEqualToString:@"public.png"]) {
                                NSMutableData *imgData = [[NSMutableData alloc]init];
                                [PHAssetResourceManager.defaultManager requestDataForAssetResource:resources.firstObject options:nil dataReceivedHandler:^(NSData * _Nonnull data) {
                                    if (data.length > 0) {
                                        [imgData appendData:data];
                                    }
                                } completionHandler:^(NSError * _Nullable error) {
                                    if (error) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [EaseKitUtil showHint:[error localizedDescription]];
                                        });
                                    } else {
                                        [self _sendImageDataAction:[imgData copy]];
                                    }
                                }];
                            } else {
                                [PHImageManager.defaultManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                                    if (imageData != nil) {
                                        [self _sendImageDataAction:imageData];
                                    } else {
                                        [EaseKitUtil showHint:EaseLocalizableString(@"imageTooLarge", nil)];
                                    }
                                }];
                            }
                        }
                    }
                }
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte *buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData *fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self _sendImageDataAction:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    //    self.isViewDidAppear = YES;
    //    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self getAudioOrVideoPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"%s convertCompSize",__func__);
                    NSLog(@"%@",[NSString stringWithFormat:@"%f s", [EaseKitUtil getVideoLength:mp4Url]]);
                     NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [EaseKitUtil getFileSize:[mp4Url path]]]);
                    
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (NSString *)getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"EMDemoRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return path;
}

#pragma mark - Action

- (void)_sendImageDataAction:(NSData *)aImageData
{
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithData:aImageData displayName:@"image"];
//    body.compressionRatio = 1;
    [self sendMessageWithBody:body ext:nil];
}

- (void)_sendVideoAction:(NSURL *)aUrl
{
    /*
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:aUrl options:nil];
    int second = urlAsset.duration.value / urlAsset.duration.timescale;*/
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithLocalPath:[aUrl path] displayName:@"video.mp4"];
    //body.duration = second;
    [self sendMessageWithBody:body ext:nil];
}

#pragma mark - Getter

- (void)setterImagePicker
{
    if (self.imagePicker == nil) {
        self.imagePicker = [[UIImagePickerController alloc] init];

        if ([EaseIMKitOptions sharedOptions].isJiHuApp) {
//            self.imagePicker.navigationController.navigationBar.tintColor = EaseIMKit_ViewBgWhiteColor;

            self.imagePicker.navigationController.navigationBar.tintColor = EaseIMKit_ViewBgBlackColor;

        }else {
            self.imagePicker.navigationController.navigationBar.tintColor = EaseIMKit_ViewBgBlackColor;

        }
                
        self.imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.imagePicker.delegate = self;
    }
}

- (UIImagePickerController *)imagePicker
{
    return objc_getAssociatedObject(self, imagePickerKey);
}

- (void)setImagePicker:(UIImagePickerController *)imagePicker
{
    objc_setAssociatedObject(self, imagePickerKey, imagePicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

/**
    位置消息
 */

@implementation EaseChatViewController (ChatToolBarLocation)

- (void)chatToolBarLocationAction
{
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        EaseLocationViewController *controller = [[EaseLocationViewController alloc] init];
        __weak typeof(self) weakself = self;
        [controller setSendCompletion:^(CLLocationCoordinate2D aCoordinate, NSString * _Nonnull aAddress, NSString * _Nonnull aBuildingName) {
            [weakself _sendLocationAction:aCoordinate address:aAddress buildingName:aBuildingName];
        }];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = 0;
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    } else {
        
        [EaseKitUtil showHint:EaseLocalizableString(@"LocationPermissionDisabled", nil)];
    }
}


- (void)_sendLocationAction:(CLLocationCoordinate2D)aCoord
                    address:(NSString *)aAddress
               buildingName:(NSString *)aBuildingName
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithLatitude:aCoord.latitude longitude:aCoord.longitude address:aAddress buildingName:aBuildingName];
        
        [self sendMessageWithBody:body ext:nil];
    } else {
        [EaseKitUtil showHint:EaseLocalizableString(@"getLocaionPermissionFail", nil)];
    }
}

@end


/**
    选择文件
 */

@implementation EaseChatViewController (ChatToolBarFileOpen)

- (void)chatToolBarFileOpenAction
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code", @"public.image", @"public.jpeg", @"public.png", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:urls reName:nil];
        [urls.firstObject stopAccessingSecurityScopedResource];
        return;
    }
    [EaseKitUtil showHint:EaseLocalizableString(@"getPermissionfail", nil)];
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileAuthorized = [url startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:@[url] reName:nil];
        [url stopAccessingSecurityScopedResource];
        return;
    }
    [EaseKitUtil showHint:EaseLocalizableString(@"getPermissionfail", nil)];
}

//icloud
- (void)selectedDocumentAtURLs:(NSArray <NSURL *>*)urls reName:(NSString *)rename
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
    for (NSURL *url in urls) {
        NSError *error;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
            //读取文件
            NSString *fileName = [newURL lastPathComponent];
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                [EaseKitUtil showHint:EaseLocalizableString(@"fileOpenFail", nil)];
                return;
            }
            NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
            EMFileMessageBody *body = [[EMFileMessageBody alloc]initWithData:fileData displayName:fileName];
            [self sendMessageWithBody:body ext:nil];
        }];
    }
}

@end



@implementation EaseChatViewController (EMChatToolBarOrder)

- (void)chatToolBarOrderAction {
    JHOrderContainerViewController *vc = [[JHOrderContainerViewController alloc] init];
    vc.sendOrderBlock = ^(JHOrderViewModel * _Nonnull orderModel) {
        [self sendOrderMessage:orderModel];
        
    };
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)sendOrderMessage:(JHOrderViewModel *)orderModel {
    NSLog(@"%s",__func__);
        
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:orderModel.messageInfo];
    [self sendMessageWithBody:body ext:nil];

}

@end
#undef kVideoSizeLimit
#undef kVideoMaxDuration

