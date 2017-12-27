//
//  StringsParser.h
//  SYParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol StringsParserDelegate <NSObject>

@optional

/**
 解析 strings 文件进度代理回调
 
 @param parsingUrl 正在解析中的 strings 文件路径
 @param curProgress 正在解析中的进度
 @param totalProgress 总的解析进度
 */
- (void)stringsParsingPath:(NSURL *)parsingUrl
               curProgress:(CGFloat)curProgress
             totalProgress:(CGFloat)totalProgress;

@end


@interface StringsParser : NSObject

@property (nonatomic, weak) id<StringsParserDelegate>delegate;

+ (instancetype)shareStringsParser;


/**
 解析 strings 文件
 
 @param openPath 需要解析的 strings 文件路径
 @param savePath 解析结果 CSV 文件保存路径
 */
- (void)parseWithPath:(NSArray <NSURL*>*)openPath
                 save:(NSURL *)savePath;

@end
