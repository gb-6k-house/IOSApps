//
//  YOPhotoProtocol.h
//  photoBrowser
//
//  Created by liukai on 14-10-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define NFYOPhotoImageDidStartLoad @"NFYOPhotoImageDidStartLoad"
#define NFYOPhotoImageDidFinishLoad @"NFYOPhotoImageDidFinishLoad"
#define NFYOPhotoImageDidFailLoadWithError @"NFYOPhotoImageDidFailLoadWithError"
#define NFYOPhotoImageDidStartReload @"NFYOPhotoImageDidStartReload"

@protocol YOPhotoProtocol <NSObject>
@required

- (UIImage *)underlyingImage;
- (void)loadUnderlyingImageAndNotify;
- (void)unloadUnderlyingImage;

@optional
//图片加载中的视图
- (UIView *)photoLoadingView;
//Notify
- (void)notifyImageDidStartLoad;
- (void)notifyImageDidFinishLoad;
- (void)notifyImageDidFailLoadWithError:(NSError *)error;
- (void)notifyImageDidStartReload;


@end
