//
//  StringsParser.m
//  SYParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "StringsParser.h"

@interface StringsParser ()

/** 将要写的文件内容 */
@property (nonatomic, copy) NSString *writeFileContents;

/** 需要解析 strings 文件的 URL */
@property (nonatomic, strong) NSArray <NSURL *>*openPath;

/** 正在解析哪一个 strings 文件 */
@property (nonatomic, assign) NSInteger parsingIndex;

/** 需要解析的 strings 文件总数 */
@property (nonatomic, assign) NSInteger parseCount;

/** 当前 strings 文件进度 */
@property (nonatomic, assign) CGFloat curProgress;

/** 全部需要解析的 strings 文件进度 */
@property (nonatomic, assign) CGFloat totalProgress;

@end


@implementation StringsParser

+ (instancetype)shareStringsParser
{
    static StringsParser *g_csvExport = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if (!g_csvExport)
        {
            g_csvExport = [[StringsParser alloc] init];
        }
    });
    return g_csvExport;
}


- (instancetype)init
{
    if (self = [super init])
    {
        self.writeFileContents = @"";
        self.parsingIndex      = 0;
        self.parseCount        = 0;
        
    }
    return self;
}


#pragma mark - 解析
- (void)parseWithPath:(NSArray <NSURL*>*)openPath
                 save:(NSURL *)savePath
{
    if (!openPath || 0 >= openPath.count
        || !savePath || 0 >= [savePath path].length)
    {
        NSLog(@"参数不合法，无法解析 strings 文件！");
        return;
    }
    self.openPath      = nil;
    self.openPath      = [NSArray arrayWithArray:openPath];
    self.parseCount    = openPath.count;
    self.curProgress   = 0;
    self.totalProgress = 0;
    for (self.parsingIndex = 0; self.parsingIndex < self.parseCount; self.parsingIndex++)
    {
        NSURL *filePath = [openPath objectAtIndex:self.parsingIndex];
        [self parestFileWithPath:[filePath path]
                   currentColumn:self.parsingIndex + 1
                        savePath:savePath];
    }
}
#pragma mark -- 解析 strings 文件
- (void)parestFileWithPath:(NSString *)filePath
             currentColumn:(NSUInteger)currentColumn
                  savePath:(NSURL *)savePath
{
    if (!filePath || 0 >= filePath.length
        || 0 >= currentColumn)
    {
        return;
    }
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    NSArray <NSString *> *strArray = [fileContents componentsSeparatedByString:@"\n"];
    fileContents = nil;
    
    NSString *rowStr   = nil;
    NSString *firstStr = nil;
    NSString *lastStr  = nil;
    NSString *keyStr   = nil;
    NSString *valueStr = nil;
    self.curProgress   = 0;
    NSMutableArray <NSString *> *keyValueArray = nil;
    for (int i = 0; i < strArray.count; i++)
    {
        // 通知进度
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(stringsParsingPath:curProgress:totalProgress:)])
        {
            self.curProgress   = (CGFloat)((CGFloat)(i + 1) / (CGFloat)strArray.count);
            self.totalProgress = self.curProgress * (CGFloat)((CGFloat)(1.0f) / (CGFloat)self.parseCount) + (CGFloat)((CGFloat)(self.parsingIndex) / (CGFloat)self.parseCount);
            if (strArray.count == i + 1)
            {
                self.curProgress = 1.0f;
                if (self.parsingIndex + 1 == self.parseCount)
                {
                    self.totalProgress = 1.0f;
                }
            }
            NSURL *parsingPath;
            if (self.parsingIndex < self.parseCount)
            {
                parsingPath = [self.openPath objectAtIndex:self.parsingIndex];
            }
            [self.delegate stringsParsingPath:parsingPath
                                  curProgress:self.curProgress
                                totalProgress:self.totalProgress];
        }
        @autoreleasepool
        {
            // 清空缓存
            rowStr   = nil;
            firstStr = nil;
            lastStr  = nil;
            keyStr   = nil;
            valueStr = nil;
            if (keyValueArray)
            {
                [keyValueArray removeAllObjects];
                keyValueArray = nil;
            }
            
            rowStr   = strArray[i];
            rowStr   = [rowStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];  // 去掉空格
            if (6 >= rowStr.length)                  // 长度不符合
            {
                continue;
            }
            firstStr = [rowStr substringToIndex:1];
            lastStr  = [rowStr substringWithRange:NSMakeRange(rowStr.length - 1, 1)];
            if (![rowStr containsString:@"="]    // 如果没有等号
                || ![firstStr isEqualToString:@"\""]             // 如果不是‘"’ 开始
                || ![lastStr isEqualToString:@";"])  // 如果不是‘;’ 结尾
            {
                continue;
            }
            
            keyValueArray = [NSMutableArray arrayWithArray:[rowStr componentsSeparatedByString:@"="]];
            if (0 >= keyValueArray.count || 2 < keyValueArray.count)    // 不符合 keh-value 语法
            {
                continue;
            }
            
            keyStr = [keyValueArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            valueStr = [keyValueArray[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (2 >= keyStr.length || 3 >= valueStr.length // keyStr: 【""】  ----  valueStr: 【"";】
                || ![@"\"" isEqualToString:[keyStr substringToIndex:1]]     // keyStr 【"】开头
                || ![@"\"" isEqualToString:[keyStr substringWithRange:NSMakeRange(keyStr.length - 1, 1)]] // keyStr 【"】结尾
                || ![@"\"" isEqualToString:[valueStr substringToIndex:1]]   // keyStr 【"】开头
                || ![@"\";" isEqualToString:[valueStr substringWithRange:NSMakeRange(valueStr.length - 2, 2)]])  // keyStr 【";】开头
            {
                continue;
            }
            keyStr = [keyStr substringWithRange:NSMakeRange(1, keyStr.length - 2)];
            valueStr = [valueStr substringWithRange:NSMakeRange(1, valueStr.length - 3)];
            if ([keyStr containsString:@","])
            {
                keyStr = [keyStr stringByReplacingOccurrencesOfString:@","      // 替换 ‘,’ 逗号
                                                           withString:@"`"];
                
            }
            if ([valueStr containsString:@","])
            {
                valueStr = [valueStr stringByReplacingOccurrencesOfString:@","  // 替换 ‘,’  逗号
                                                               withString:@"`"];
            }
            //            printf("【%d】 keyStr = %s, valueStr = %s\r\n", i, [keyStr cStringUsingEncoding:NSUTF8StringEncoding], [valueStr cStringUsingEncoding:NSUTF8StringEncoding]);
            //            fflush(stdout);
            [self addKeyStr:keyStr
                   valueStr:valueStr
              currentColumn:currentColumn];
        }
    }
    
    // 写到 EXcel 文件
    if (self.writeFileContents && 0 < self.writeFileContents.length)
    {
        [self.writeFileContents writeToURL:savePath
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:nil];
    }
    
    // 清空缓存
    strArray      = nil;
    rowStr        = nil;
    firstStr      = nil;
    lastStr       = nil;
    keyStr        = nil;
    valueStr      = nil;
    if (keyValueArray)
    {
        [keyValueArray removeAllObjects];
        keyValueArray = nil;
    }
}


#pragma mark -- 添加 ’key-value‘
- (void)addKeyStr:(NSString *)dstKeyStr
         valueStr:(NSString *)dstValueStr
    currentColumn:(NSInteger)currentColumn
{
    if (!dstKeyStr || 0 >= dstKeyStr.length
        || !dstValueStr || 0 >= dstValueStr.length)
    {
        return ;
    }
    BOOL isAddValueStr = NO;
    NSArray <NSString *> *strArray = [self.writeFileContents componentsSeparatedByString:@"\n"];
    
    NSString *rowStr      = nil;
    NSString *srcKeyStr   = nil;
    NSString *newRowStr   = nil;
    NSString *preRowsStr  = nil;
    NSString *nextRowsStr = nil;
    NSString *newFileStr  = nil;
    NSMutableArray <NSString *> *keyValuesArray = nil;
    for (NSInteger i = 0; i < strArray.count; i++)
    {
        // 清空缓存
        rowStr      = nil;
        srcKeyStr   = nil;
        newRowStr   = nil;
        preRowsStr  = nil;
        nextRowsStr = nil;
        newFileStr  = nil;
        if (keyValuesArray)
        {
            [keyValuesArray removeAllObjects];
            keyValuesArray = nil;
        }
        
        rowStr = strArray[i];
        rowStr = [rowStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];  // 去掉空格
        if (0 >= rowStr.length || ![rowStr containsString:@","])  // 不含 CSV 分割号 ‘,’
        {
            continue;
        }
        keyValuesArray = [NSMutableArray arrayWithArray:[rowStr componentsSeparatedByString:@","]];
        if (1 >= keyValuesArray.count )    // 不符合 keh-value 语法
        {
            continue;
        }
        srcKeyStr = [keyValuesArray[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![dstKeyStr isEqualToString:srcKeyStr])  // keyStr 不存在
        {
            continue;
        }
        
        // 追加
        newRowStr = [self formatOldRowStr:rowStr
                                 valueStr:dstValueStr
                            currentColumn:currentColumn];
        preRowsStr = @"";
        for (NSInteger j = 0; j < i; j++)
        {
            preRowsStr = [NSString stringWithFormat:@"%@%@", preRowsStr, [self formatRowString:strArray[j]
                                                                                 currentColumn:currentColumn]];
        }
        preRowsStr = [NSString stringWithFormat:@"%@%@", preRowsStr, newRowStr];
        nextRowsStr = @"";
        for (NSInteger k = i + 1; k < strArray.count; k++)
        {
            nextRowsStr = [NSString stringWithFormat:@"%@%@", nextRowsStr, [self formatRowString:strArray[k]
                                                                                   currentColumn:currentColumn]];
        }
        newFileStr = [NSString stringWithFormat:@"%@%@", preRowsStr, nextRowsStr];
        
        self.writeFileContents = newFileStr;
        
        isAddValueStr = YES;
        break ;
    }
    if (NO == isAddValueStr)
    {
        // 新添加
        // 清空缓存
        newRowStr   = nil;
        newFileStr  = nil;
        
        NSString *emptyStr = @"";
        for (NSInteger i = 0; i < currentColumn; i++)
        {
            emptyStr = [NSString stringWithFormat:@"%@,", emptyStr];
        }
        newRowStr = [NSString stringWithFormat:@"%@%@%@\n", dstKeyStr, emptyStr, dstValueStr];
        newFileStr = [NSString stringWithFormat:@"%@%@", self.writeFileContents, newRowStr];
        
        self.writeFileContents = newFileStr;
    }
    
    // 清空缓存
    rowStr      = nil;
    srcKeyStr   = nil;
    newRowStr   = nil;
    preRowsStr  = nil;
    nextRowsStr = nil;
    newFileStr  = nil;
    if (keyValuesArray)
    {
        [keyValuesArray removeAllObjects];
        keyValuesArray = nil;
    }
}


#pragma mark -- 根据列数格式化 newRowStr
- (NSString *)formatOldRowStr:(NSString *)oldRowStr
                     valueStr:(NSString *)valueStr
                currentColumn:(NSInteger)currentColumn
{
    if (!oldRowStr || !valueStr || 1 > currentColumn)
    {
        return @"";
    }
    NSString *newRowStr = @"";
    NSArray *strArray = [oldRowStr componentsSeparatedByString:@","];
    if (currentColumn == strArray.count)  // 刚好缺一列
    {
        newRowStr = [NSString stringWithFormat:@"%@,%@\n", oldRowStr, valueStr];
    }
    else  if (currentColumn > strArray.count) // 空列数不足
    {
        for (NSInteger i = 0; i < currentColumn - (strArray.count - 1) - 1; i++)
        {
            newRowStr = [NSString stringWithFormat:@"%@%@", oldRowStr, @","];
        }
        newRowStr = [NSString stringWithFormat:@"%@,%@\n", newRowStr, valueStr];
    }
    else    // 列数多余，需去除
    {
        for (NSInteger i = 0; i < currentColumn; i++)
        {
            if (0 == i)
            {
                newRowStr = [NSString stringWithFormat:@"%@", strArray[i]];
            }
            else
            {
                newRowStr = [NSString stringWithFormat:@"%@,%@", newRowStr, strArray[i]];
            }
        }
        newRowStr = [NSString stringWithFormat:@"%@,%@\n", newRowStr, valueStr];
    }
    
    // 清空缓存
    strArray = nil;
    
    return newRowStr;
}


#pragma mark -- 根据列数格式化 rowStr
- (NSString *)formatRowString:(NSString *)rowStr
                currentColumn:(NSInteger)currentColumn
{
    if (!rowStr || 0 >= rowStr.length || 1 > currentColumn)
    {
        return @"";
    }
    NSArray *strArray = [rowStr componentsSeparatedByString:@","];
    if (1 >= strArray.count)
    {
        return [NSString stringWithFormat:@"%@\n", rowStr];
    }
    if (currentColumn >= strArray.count)
    {
        for (NSInteger i = 0; i < currentColumn - (strArray.count - 1); i++)
        {
            rowStr = [NSString stringWithFormat:@"%@%@", rowStr, @","];
        }
    }
    // 清空缓存
    strArray = nil;
    
    return [NSString stringWithFormat:@"%@\n", rowStr];
}

@end
