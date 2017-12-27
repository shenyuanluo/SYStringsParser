//
//  AboutViewController.m
//  SYStringsParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@property (weak) IBOutlet NSTextField *appNameTF;
@property (weak) IBOutlet NSTextField *appVersionTF;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    [self configAboutInfo];
}


- (void)configAboutInfo
{
    NSDictionary *infoDict   = [[NSBundle mainBundle] infoDictionary];
    // 获取名称
    NSString *executableFile =  [infoDict objectForKey:(NSString *)kCFBundleExecutableKey];
    // 获取 version
    NSString *versionStr     = [infoDict objectForKey:@"CFBundleShortVersionString"];
    // 获取 build 
    NSString *buildStr       = [infoDict objectForKey:@"CFBundleVersion"];
    
    self.appNameTF.stringValue    = executableFile;
    self.appVersionTF.stringValue = [NSString stringWithFormat:@"%@ (%@)", versionStr, buildStr];
}

@end
