//
//  SYParser.h
//  SYParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SYParserDelegate <NSObject>

@optional

/**
 CSV 文件解析进度代理回调
 
 @param progress 解析进度
 */
- (void)parseCSVProgress:(CGFloat)progress;


/**
 解析 strings 文件进度代理回调
 
 @param parsingUrl 正在解析中的 strings 文件路径
 @param curProgress 正在解析中的进度
 @param totalProgress 总的解析进度
 */
- (void)parsingStringsPath:(NSURL *)parsingUrl
               curProgress:(CGFloat)curProgress
             totalProgress:(CGFloat)totalProgress;

@end


@interface SYParser : NSObject

@property (nonatomic, weak) id<SYParserDelegate>delegate;

+ (instancetype)shareParser;


/**
 解析 CSV 文件
 
 @param openPath 需要解析的 CSV 文件路径
 @param savePath 解析结果 strings 文件保存目录
 */
- (void)parseCSVWithPath:(NSURL *)openPath
                    save:(NSURL *)savePath;


/**
 解析 strings 文件
 
 @param openPath 需要解析的 strings 文件路径
 @param savePath 解析结果 CSV 文件保存路径
 */
- (void)parseStringsWithPath:(NSArray <NSURL*>*)openPath
                        save:(NSURL *)savePath;

@end
