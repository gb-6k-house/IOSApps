//
//  YOPhotoBrowser.h
//  photoBrowser
//
//  Created by liukai on 14-10-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YOPhotoProtocol.h"
@protocol YOPhotoBrowserDataSource;
@protocol YOPhotoBrowserDelegate;

@interface YOPhotoBrowser : UIViewController{
    
}
@property (nonatomic, readonly) NSUInteger photoCount;
@property (nonatomic, readonly) NSUInteger currentPageIndex;

- (id)initWithDataSource:(id <YOPhotoBrowserDataSource>)dataSource  delegate:(id <YOPhotoBrowserDelegate>)delegate;
// Reloads the photo browser and refetches data
- (void)reloadData;


@end

@protocol YOPhotoBrowserDataSource<NSObject>
@required
/**
 @param photoBrower The current photobrowser to present.
 
 @return number of photos.
 */
- (NSUInteger)numberOfPhotosInPhotoBrowser:(YOPhotoBrowser *)photoBrowser;

/**
 @param photoBrower The current photobrowser to present.
 @param index
 
 @return YOPhoto for showing.
 */
-(id <YOPhotoProtocol>)photoBrowser:(YOPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@end

@protocol YOPhotoBrowserDelegate <NSObject>

@optional

/**
 @param photoBrower The current photobrowser to present.
 @param index The current showing index in photoBrowser.
 */
- (void)photoBrowser:(YOPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index;

/**
 @param photoBrower The current photobrowser to present.
 @param index The current showing index in photoBrowser.
 @param status
 */
//- (void)photoBrowser:(CXPhotoBrowser *)photoBrowser currentPhotoAtIndex:(NSUInteger)index didFinishedLoadingWithStatus:(CXPhotoLoadingStatus)status;

/**
 
 
 @return supportReload.
 */
- (BOOL)supportReload;
@end
