//
//  Apple80211.m
//  WIFIScan
//
//  Created by liukai on 14-11-11.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "Apple80211.h"
#import <dlfcn.h>
typedef int     (*Apple80211Open)(void *);
typedef int     (*Apple80211BindToInterface)(void *, NSString *);
typedef int     (*Apple80211Close)(void *);
typedef int     (*Apple80211Info)(void *, NSDictionary**);
typedef int     (*Apple80211Associate)(void *, NSDictionary*, void *);
typedef int     (*Apple80211Scan)(void *, NSArray **, void *);
@interface Apple80211(){
    Apple80211Open open;
    Apple80211BindToInterface bind;
    Apple80211Close close;
    Apple80211Info info;
    Apple80211Associate associate;
    Apple80211Scan scan;
    void * libHandle;
    void *airportHandle;
    NSMutableDictionary *networks;
    BOOL scanning;
}

@end
@implementation Apple80211
-(id)init{
    self = [super init];
    networks = [NSMutableDictionary  dictionary];
    libHandle = dlopen("/System/Library/SystemConfiguration/WiFiManager.bundle/WiFiManager", RTLD_LAZY);
    if(libHandle){
        open = dlsym(libHandle, "Apple80211Open");
        bind = dlsym(libHandle, "Apple80211BindToInterface");
        close = dlsym(libHandle, "Apple80211Close");
        scan = dlsym(libHandle, "Apple80211Scan");
        info = dlsym(libHandle, "Apple80211Info");
        open(&airportHandle);
        bind(airportHandle, @"en0");
        
    }
    return self;
}

-(void)scanWifi{
    NSLog(@"Scanning...");
    if (!libHandle) {
        return;
    }
    scanning = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startedScanning" object:self];
    NSArray *scan_networks;
    NSDictionary *parameters = [[NSDictionary alloc] init];
    scan(airportHandle, &scan_networks, (__bridge void *)(parameters));
    int i;
    bool changed = false;
    for (i = 0; i < [scan_networks count]; i++) {
        if([networks objectForKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]] != nil && ![[networks objectForKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]] isEqualToDictionary:[scan_networks objectAtIndex: i]])
            changed = true;
        [networks setObject:[scan_networks objectAtIndex: i] forKey:[[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]];
        NSLog(@"scan BSSID %@...", [[scan_networks objectAtIndex: i] objectForKey:@"BSSID"]);
    }
    if(changed) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworksUpdated" object:self];
    }
    scanning = false;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stoppedScanning" object:self];
    NSLog(@"Scan Finished...");
}
@end
