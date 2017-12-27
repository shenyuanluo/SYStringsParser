//
//  CSVParser.h
//  SYParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSVParserDelegate <NSObject>

@optional

/**
 CSV 文件解析进度代理回调
 
 @param progress 解析进度
 */
- (void)csvParseProgress:(CGFloat)progress;

@end


@interface CSVParser : NSObject

@property (nonatomic, weak) id<CSVParserDelegate>delegate;

+ (instancetype)shareCSVParse;


/**
 解析 CSV 文件
 
 @param openPath 需要解析的 CSV 文件路径
 @param savePath 解析结果 strings 文件保存目录
 */
- (void)parseWithPath:(NSURL *)openPath
                 save:(NSURL *)savePath;

@end
