//
//  YOPhoto.h
//  photoBrowser
//
//  Created by liukai on 14-10-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOPhotoProtocol.h"

@interface YOPhoto : NSObject
<YOPhotoProtocol>{
    UIImage *_underlyingImage;
}
//图片信息
@property (nonatomic, strong, readonly) UIImage *underlyingImage;

// Class
+ (YOPhoto *)photoWithImage:(UIImage *)image;
+ (YOPhoto *)photoWithFilePath:(NSString *)path;
+ (YOPhoto *)photoWithURL:(NSURL *)url;

// Init
- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;

//Load Async
- (void)loadImageFromFileAsync:(NSString *)path;
- (void)loadImageFromURLAsync:(NSURL *)url;
- (void)unloadImage;
- (void)reloadImage;
@end
