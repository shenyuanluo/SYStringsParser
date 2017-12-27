//
//  BaseViewController.m
//  SYStringsParser
//
//  Created by shenyuanluo on 2017/12/27.
//  Copyright © 2017年 http://blog.shenyuanluo.com/ All rights reserved.
//

#import "BaseViewController.h"
#import "SYParser.h"


typedef NS_ENUM(NSUInteger, ParserType) {
    ParserCsv               = 0x00,
    ParserStrings           = 0x01,
};

@interface BaseViewController() <
                                SYParserDelegate
                            >

@property (weak) IBOutlet NSPopUpButton *popUpBtn;
@property (unsafe_unretained) IBOutlet NSTextView *openPathTextView;
@property (unsafe_unretained) IBOutlet NSTextView *savePathTextView;
@property (weak) IBOutlet NSTextField *parsingFileNameLabel;
@property (weak) IBOutlet NSTextField *parseResultLabel;
@property (weak) IBOutlet NSProgressIndicator *parsingProgress;
@property (weak) IBOutlet NSProgressIndicator *totalProgress;
@property (weak) IBOutlet NSTextField *curProgressTF;
@property (weak) IBOutlet NSTextField *totalProgressTF;
@property (weak) IBOutlet NSTextField *parsingTipLabel;
@property (weak) IBOutlet NSTextField *curProgressTipLabel;
@property (weak) IBOutlet NSTextField *totalProgressTipLabel;

@property (nonatomic, strong) NSArray *popTitleArray;
@property (nonatomic, strong) NSArray *csvFileTypes;
@property (nonatomic, strong) NSArray *stringsFileTypes;
@property (nonatomic, strong) NSArray <NSURL *>*openFilePath;
@property (nonatomic, strong) NSURL *saveFilePath;
@property (nonatomic, strong) NSURL *openDefaultUrl;
@property (nonatomic, assign) ParserType parserType;

@property (nonatomic, strong) SYParser *syParser;

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initParam];
    
    [self configUI];
}


- (void)viewWillAppear
{
    [super viewWillAppear];
    
    [self configCurUIHidden:YES];
    [self configTotalUIHidden:YES];
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
}


- (void)configUI
{
    [self.popUpBtn removeAllItems];
    [self.popUpBtn addItemsWithTitles:self.popTitleArray];
}


- (void)initParam
{
    self.parserType        = ParserCsv;
    self.syParser          = [SYParser shareParser];
    self.syParser.delegate = self;
}


#pragma mark - 懒加载
- (NSArray *)popTitleArray
{
    if (!_popTitleArray)
    {
        _popTitleArray = @[@"CSV解析", @"String解析"];
    }
    return _popTitleArray;
}

- (NSArray *)csvFileTypes
{
    if (!_csvFileTypes)
    {
        _csvFileTypes = @[@"csv", @"CSV"];
    }
    return _csvFileTypes;
}


- (NSArray *)stringsFileTypes
{
    if (!_stringsFileTypes)
    {
        _stringsFileTypes = @[@"strings"];
    }
    return _stringsFileTypes;
}


- (NSURL *)openDefaultUrl
{
    if (!_openDefaultUrl)
    {
        _openDefaultUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"]];
    }
    return _openDefaultUrl;
}


#pragma mark -- 隐藏 UI
- (void)configCurUIHidden:(BOOL)isHidden
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        strongSelf.parsingFileNameLabel.hidden  = isHidden;
        strongSelf.parsingProgress.hidden       = isHidden;
        strongSelf.curProgressTF.hidden         = isHidden;
        strongSelf.curProgressTipLabel.hidden   = isHidden;
        strongSelf.parsingTipLabel.hidden       = isHidden;
    });
}


- (void)configTotalUIHidden:(BOOL)isHidden
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        strongSelf.parseResultLabel.hidden      = isHidden;
        strongSelf.totalProgress.hidden         = isHidden;
        strongSelf.totalProgressTF.hidden       = isHidden;
        strongSelf.totalProgressTipLabel.hidden = isHidden;
    });
}


- (void)clearTextview
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        strongSelf.savePathTextView.string = @"";
        strongSelf.openPathTextView.string = @"";
    });
}


#pragma mark - 文件路径选择
#pragma mark -- 选择解析文件
- (void)openFiles
{
    NSArray *fileTypes;
    BOOL allowMultipSelect;
    NSString *panelTitle;
    switch (self.parserType)
    {
        case ParserCsv:
            fileTypes         = self.csvFileTypes;
            allowMultipSelect = NO;
            panelTitle        = @"请先选择 CSV 文件";
            break;
            
        case ParserStrings:
            fileTypes         = self.stringsFileTypes;
            allowMultipSelect = YES;
            panelTitle        = @"请先选择 strings 文件";
            break;
            
        default:
            fileTypes         = self.csvFileTypes;
            allowMultipSelect = NO;
            panelTitle        = @"请先选择 CSV 文件";
            break;
    }
    NSOpenPanel* openPanel            = [NSOpenPanel openPanel];
    openPanel.floatingPanel           = YES;
    openPanel.canChooseFiles          = YES;
    openPanel.canChooseDirectories    = NO;
    openPanel.allowsMultipleSelection = allowMultipSelect;
    openPanel.allowedFileTypes        = fileTypes;
    openPanel.message                 = panelTitle;
    openPanel.directoryURL            = self.openDefaultUrl;
    
    __weak typeof(self)weakSelf = self;
    [openPanel beginSheetModalForWindow:[NSApp mainWindow]
                      completionHandler:^(NSInteger result) {
                          
                          __strong typeof(weakSelf)strongSelf = weakSelf;
                          if (!strongSelf)
                          {
                              return ;
                          }
                          if (NSFileHandlingPanelOKButton == result)
                          {
                              strongSelf.openFilePath = [openPanel URLs];
                              NSString *string = [strongSelf.openFilePath[0] path];
                              for (NSInteger i = 1; i < strongSelf.openFilePath.count; i++)
                              {
                                  string = [NSString stringWithFormat:@"%@\n%@", string, [strongSelf.openFilePath[i] path]];
                              }
                              strongSelf.openPathTextView.string = string;
                          }
                      }];
}


#pragma mark -- 选择保存 strings 文件路径
- (void)saveStringsFile
{
    NSOpenPanel* openPanel            = [NSOpenPanel openPanel];
    openPanel.canChooseFiles          = NO;
    openPanel.canChooseDirectories    = YES;
    openPanel.allowsMultipleSelection = NO;
    openPanel.title                   = @"保存文件";
    openPanel.message                 = @"选择文件保存地址";
    openPanel.directoryURL            = self.openDefaultUrl;
    
    __weak typeof(self)weakSelf = self;
    [openPanel beginSheetModalForWindow:[NSApp mainWindow]
                      completionHandler:^(NSInteger result) {
                          
                          __strong typeof(weakSelf)strongSelf = weakSelf;
                          if (!strongSelf)
                          {
                              return ;
                          }
                          if (NSFileHandlingPanelOKButton == result)
                          {
                              NSArray *urls = [openPanel URLs];
                              strongSelf.saveFilePath = urls[0];
                              strongSelf.savePathTextView.string = [strongSelf.saveFilePath path];
                          }
                      }];
}


#pragma mark -- 选择保存 CSV 文件路径
- (void)saveCSVFile
{
    NSSavePanel *savePanel         = [NSSavePanel savePanel];
    savePanel.title                = @"保存文件";
    savePanel.message              = @"选择文件保存地址";
    savePanel.nameFieldStringValue = @"translate";
    savePanel.allowsOtherFileTypes = NO;
    savePanel.extensionHidden      = NO;
    savePanel.canCreateDirectories = YES;
    savePanel.allowedFileTypes     = self.csvFileTypes;
    savePanel.directoryURL         = self.openDefaultUrl;
    
    __weak typeof(self)weakSelf = self;
    [savePanel beginSheetModalForWindow:[NSApp mainWindow]
                      completionHandler:^(NSInteger result){
                          
                          __strong typeof(weakSelf)strongSelf = weakSelf;
                          if (!strongSelf)
                          {
                              return ;
                          }
                          if (result == NSModalResponseOK)
                          {
                              strongSelf.saveFilePath = [savePanel URL];
                              NSImage *image = [NSImage imageNamed:@"image.png"];
                              NSData *data = [image TIFFRepresentation];
                              [data writeToURL:strongSelf.saveFilePath atomically:YES];
                              strongSelf.savePathTextView.string = [strongSelf.saveFilePath path];
                          }
                      }];
}


#pragma mark - 解析
#pragma mark -- 开始解析 CSV 文件
- (void)startParseCSV
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        
        [strongSelf.syParser parseCSVWithPath:strongSelf.openFilePath[0]
                                         save:strongSelf.saveFilePath];
    });
}


#pragma mark -- 开始解析 strings 文件
- (void)startParseStrings
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        [strongSelf.syParser parseStringsWithPath:strongSelf.openFilePath
                                             save:strongSelf.saveFilePath];
    });
}


#pragma mark - 按钮事件中心
#pragma mark -- ’功能选择‘ 按钮事件
- (IBAction)popButtonAction:(id)sender
{
    NSPopUpButton *popBtn = (NSPopUpButton *)sender;
    self.parserType = popBtn.indexOfSelectedItem;
    [self configCurUIHidden:YES];
    [self configTotalUIHidden:YES];
    [self clearTextview];
}


#pragma mark -- ’选择文件‘ 按钮事件
- (IBAction)openFileAction:(id)sender
{
    [self configCurUIHidden:YES];
    [self configTotalUIHidden:YES];
    [self openFiles];
}


#pragma mark -- ’保存文件‘ 按钮事件
- (IBAction)saveFileAction:(id)sender
{
    [self configCurUIHidden:YES];
    [self configTotalUIHidden:YES];
    
    NSArray *fileTypes;
    switch (self.parserType)
    {
        case ParserCsv:
            fileTypes = self.csvFileTypes;
            [self saveStringsFile];
            break;
            
        case ParserStrings:
            fileTypes = self.stringsFileTypes;
            [self saveCSVFile];
            break;
            
        default:
            fileTypes = self.csvFileTypes;
            break;
    }
}


#pragma mark -- ’开始解析‘ 按钮事件
- (IBAction)startParseAction:(id)sender
{
    [self configTotalUIHidden:NO];
    switch (self.parserType)
    {
        case ParserCsv:
            [self configCurUIHidden:YES];
            [self startParseCSV];
            break;
            
        case ParserStrings:
            [self configCurUIHidden:NO];
            [self startParseStrings];
            break;
            
        default:
            break;
    }
}


#pragma mark - SYParserDelegate
#pragma mark -- csv 文件解析进度回调
- (void)parseCSVProgress:(CGFloat)progress
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        strongSelf.totalProgressTF.stringValue = [NSString stringWithFormat:@"%d", (int)(100 * progress)];
        strongSelf.totalProgress.doubleValue   = progress * 100;
        if (1.0 == progress)
        {
            strongSelf.parseResultLabel.stringValue = @"解析完成 ^_^";
        }
    });
}


#pragma mark -- strings 文件解析进度回调
- (void)parsingStringsPath:(NSURL *)parsingUrl
               curProgress:(CGFloat)curProgress
             totalProgress:(CGFloat)totalProgress
{
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongSelf)
        {
            return ;
        }
        strongSelf.curProgressTF.stringValue        = [NSString stringWithFormat:@"%d", (int)(100 * curProgress)] ;
        strongSelf.totalProgressTF.stringValue      = [NSString stringWithFormat:@"%d", (int)(100 * totalProgress)];
        strongSelf.parsingFileNameLabel.stringValue = [parsingUrl path];
        strongSelf.parsingProgress.doubleValue      = curProgress * 100;
        strongSelf.totalProgress.doubleValue        = totalProgress * 100;
        if (1.0 == totalProgress)
        {
            strongSelf.parseResultLabel.stringValue = @"解析完成 ^_^";
        }
    });
}


@end
