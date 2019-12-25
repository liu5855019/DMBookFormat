//
//  FixEncodingVC.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/24.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "FixEncodingVC.h"

@interface FixEncodingVC ()

@property (weak) IBOutlet NSTextField *inputTF;
@property (weak) IBOutlet NSTextField *outputTF;
@property (weak) IBOutlet NSTextField *descTF;

@end

@implementation FixEncodingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
}

- (IBAction)clickInputBtn:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.prompt = @"Select";
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.allowedFileTypes = @[@"txt"];
    
    openDlg.allowsMultipleSelection = NO;

    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSURL *fileURL = [openDlg URL];
        _inputTF.stringValue = fileURL.path;
    }
}

- (IBAction)clickOutputBtn:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.prompt = @"Select";
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = YES;
    openDlg.allowedFileTypes = @[@"txt"];
    
    openDlg.allowsMultipleSelection = NO;

    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSURL *fileURL = [openDlg URL];
        _outputTF.stringValue = fileURL.path;
    }
}

- (IBAction)clickStartBtn:(NSButton *)sender
{
    [self.view resignFirstResponder];
    
    NSString *inputPath = _inputTF.stringValue;
    NSString *outputPath = _outputTF.stringValue;

    if (inputPath.length == 0 || outputPath.length == 0) {
        _descTF.stringValue = @"请检查 path";
        return;
    }

    NSData *data = [NSData dataWithContentsOfFile:inputPath];
    
    if (data == nil || data.length == 0) {
        _descTF.stringValue = @"请检查输入文件";
        return;
    }
    
    sender.enabled = NO;
    _descTF.stringValue = @"转换中...";
    
    NSString *str = [self getStringWithFilePath:inputPath data:data];
    if (str == nil) {
        _descTF.stringValue = @"输入文件解码失败!";
        sender.enabled = YES;
        return;
    }
    
    BOOL result = [str writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    _descTF.stringValue = result ? @"完成" : @"失败!";
    
    sender.enabled = YES;
}

- (NSString *)getStringWithFilePath:(NSString *)filePath data:(NSData *)data
{
    NSStringEncoding encoding;
    NSError *error = nil;
    NSString *encodingString = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:&encoding error:&error];

    if (!error) {
        return encodingString;
    }
    
    //kCFStringEncodingGBK_95
    encodingString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95)];
    if (encodingString) {
        return encodingString;
    }
    
    //kCFStringEncodingGB_2312_80
    encodingString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80)];
    if (encodingString) {
        return encodingString;
    }
    
    //kCFStringEncodingGB_18030_2000
    encodingString = [[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (encodingString) {
        return encodingString;
    }

    return nil;
}


@end
