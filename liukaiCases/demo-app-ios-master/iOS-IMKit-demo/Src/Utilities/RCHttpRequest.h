//
//  RCHttpRequest.h
//  iOS-IMLib
//
//  Created by Heq.Shinoda on 14-6-9.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCHttpRequest;

@protocol HttpConnectionDelegate<NSObject>
- (void)responseHttpConnectionSuccess:(RCHttpRequest *)request;
- (void)responseHttpConnectionFailed:(RCHttpRequest *)request didFailWithError:(NSError *)error;
@end


@interface RCHttpRequest : NSObject
@property(nonatomic, strong)NSURLConnection* connection;
@property(nonatomic,strong) NSMutableData* responseData;
@property(nonatomic,strong) NSHTTPURLResponse* response;
@property(nonatomic,assign) NSInteger tag;
@property(nonatomic, assign) id<HttpConnectionDelegate> httpDelegate;

-(id)init;
+(RCHttpRequest*)defaultHttpRequest;
//----Http comunication----//
-(void)httpConnectionWithURL:(NSString*)strURL bodyData:(NSData*)data delegate:(id<HttpConnectionDelegate>)delegate;
@end
