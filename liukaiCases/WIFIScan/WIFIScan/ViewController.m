//
//  ViewController.m
//  WIFIScan
//
//  Created by liukai on 14-11-11.
//  Copyright (c) 2014年 yhc. All rights reserved.
//

#import "ViewController.h"
#import "Apple80211.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)toucheScanWifi:(id)sender {
    [[[Apple80211 alloc] init] scanWifi];
}

@end
