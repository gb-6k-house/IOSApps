//
//  YOPhotoBrowser.m
//  photoBrowser
//
//  Created by liukai on 14-10-16.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "YOPhotoBrowser.h"
#define OS_Version  ([[UIDevice currentDevice].systemVersion floatValue])
#define PADDING                 10

@interface YOPhotoBrowser ()<UIScrollViewDelegate>{
    id <YOPhotoBrowserDataSource> _dataSource;
    id <YOPhotoBrowserDelegate> _delegate;
    UIStatusBarStyle _previousStatusBarStyle;

    // Views
    UIScrollView *_pagingScrollView; //container
    
    NSMutableArray *_photos;

}
@property (nonatomic) BOOL supportReload;

@end

@implementation YOPhotoBrowser

- (id)init
{
    self = [super init];
    if (self)
    {
        if (OS_Version <7.0) {
            self.wantsFullScreenLayout = YES;
        }
        _photoCount = NSNotFound;
        _currentPageIndex = 0;
        _photos = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleYOPhotoImageDidStartLoad:)
                                                     name:NFYOPhotoImageDidStartLoad
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleYOPhotoImageDidFinishLoad:)
                                                     name:NFYOPhotoImageDidFinishLoad
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleYOPhotoImageDidFailLoadWithError:)
                                                     name:NFYOPhotoImageDidFailLoadWithError
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleYOPhotoImageDidStartReload:)
                                                     name:NFYOPhotoImageDidStartReload
                                                   object:nil];
    }
    return self;
}

- (id)initWithDataSource:(id <YOPhotoBrowserDataSource>)dataSource  delegate:(id <YOPhotoBrowserDelegate>)delegate{
    self = [self init];
    if (self) {
        _dataSource = dataSource;
        _delegate = delegate;

    }
    
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
   

    // Setup paging scrolling view
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
    _pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _pagingScrollView.pagingEnabled = YES;
    _pagingScrollView.delegate = self;
    _pagingScrollView.showsHorizontalScrollIndicator = NO;
    _pagingScrollView.showsVerticalScrollIndicator = NO;
    _pagingScrollView.backgroundColor = [UIColor blackColor];
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
}
- (CGRect)frameForPagingScrollView
{
    CGRect frame = self.view.bounds;// [[UIScreen mainScreen] bounds];
    frame.origin.x -= PADDING;
    frame.size.width += (2 * PADDING);
    return frame;
}
- (CGSize)contentSizeForPagingScrollView
{
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}
- (NSUInteger)numberOfPhotos
{
    if (_photoCount == NSNotFound) {
        if ([_dataSource respondsToSelector:@selector(numberOfPhotosInPhotoBrowser:)]) {
            _photoCount = [_dataSource numberOfPhotosInPhotoBrowser:self];
        }
    }
    if (_photoCount == NSNotFound) _photoCount = 0;
    return _photoCount;
}


- (void)viewWillAppear:(BOOL)animated{
    // 状态栏不显示
    _previousStatusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    if(OS_Version <7.0){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
        
    }else{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:animated];
        
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data
- (void)reloadData {
    
    // Reset
    _photoCount = NSNotFound;
    
    if ([_delegate respondsToSelector:@selector(supportReload)])
    {
        _supportReload = [_delegate supportReload];
    }
    // Get data
    NSUInteger numberOfPhotos = [self numberOfPhotos];
    [self unloadAllUnderlyingPhotos];
    [_photos removeAllObjects];
    for (int i = 0; i < numberOfPhotos; i++) [_photos addObject:[NSNull null]];
    
    // Update
    [self performLayout];
    
    // Layout
    [self.view setNeedsLayout];
    
}

- (id<YOPhotoProtocol>)photoAtIndex:(NSUInteger)index
{
    id <YOPhotoProtocol> photo = nil;
    if (index < _photos.count) {
        if ([_photos objectAtIndex:index] == [NSNull null]) {
            if ([_dataSource respondsToSelector:@selector(photoBrowser:photoAtIndex:)]) {
                photo = [_dataSource photoBrowser:self photoAtIndex:index];
            }
            if (photo) [_photos replaceObjectAtIndex:index withObject:photo];
        } else {
            photo = [_photos objectAtIndex:index];
        }
    }
    return photo;
}

- (void)unloadAllUnderlyingPhotos
{
    for (id p in _photos) { if (p != [NSNull null]) [p unloadUnderlyingImage]; }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
