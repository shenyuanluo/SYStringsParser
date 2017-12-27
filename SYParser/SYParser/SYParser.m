//
//  SYParser.m
//  SYParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "SYParser.h"
#import "CSVParser.h"
#import "StringsParser.h"


@interface SYParser() <
                        CSVParserDelegate,
                        StringsParserDelegate
                      >
@property (nonatomic, strong) CSVParser *csvParser;
@property (nonatomic, strong) StringsParser *stringsParser;

@end


@implementation SYParser

+ (instancetype)shareParser
{
    static SYParser *g_parser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!g_parser)
        {
            g_parser = [[SYParser alloc] init];
        }
    });
    return g_parser;
}


- (instancetype)init
{
    if (self = [super init])
    {
        self.csvParser              = [CSVParser shareCSVParse];
        self.csvParser.delegate     = self;
        self.stringsParser          = [StringsParser shareStringsParser];
        self.stringsParser.delegate = self;
    }
    return self;
}


#pragma mark -- 解析 csv 文件
- (void)parseCSVWithPath:(NSURL *)openPath
                    save:(NSURL *)savePath
{
    if (!openPath || 0 >= openPath.path.length
        || !savePath || 0 >= savePath.path.length)
    {
        NSLog(@"参数不合法，无法解析 CSV 文件！");
        return;
    }
    [self.csvParser parseWithPath:openPath
                             save:savePath];
}



#pragma mark -- 解析 strings 文件
- (void)parseStringsWithPath:(NSArray <NSURL*>*)openPath
                        save:(NSURL *)savePath
{
    if (!openPath || 0 >= openPath.count
        || !savePath || 0 >= [savePath path].length)
    {
        NSLog(@"参数不合法，无法解析 strings 文件！");
        return;
    }
    [self.stringsParser parseWithPath:openPath
                                 save:savePath];
}


#pragma mark - CSVParserDelegate
- (void)csvParseProgress:(CGFloat)progress
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(parseCSVProgress:)])
    {
        [self.delegate parseCSVProgress:progress];
    }
}


#pragma mark - StringsParserDelegate
- (void)stringsParsingPath:(NSURL *)parsingUrl
               curProgress:(CGFloat)curProgress
             totalProgress:(CGFloat)totalProgress
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(parsingStringsPath:curProgress:totalProgress:)])
    {
        [self.delegate parsingStringsPath:parsingUrl
                              curProgress:curProgress
                            totalProgress:totalProgress];
    }
}

@end
