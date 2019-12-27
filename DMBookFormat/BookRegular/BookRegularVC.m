//
//  BookRegularVC.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/26.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "BookRegularVC.h"

#import "NSArray+DMTools.h"

@interface BookRegularVC ()

@property (weak) IBOutlet NSTextField *pathTF;
@property (weak) IBOutlet NSTextField *regularTF;
@property (unsafe_unretained) IBOutlet NSTextView *descTV;

@property (nonatomic , copy) NSString *fileContent;

@end

@implementation BookRegularVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pathTF.editable = NO;
    _descTV.editable = NO;
}


- (IBAction)clickSelectBtn:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.prompt = @"Select";
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.allowedFileTypes = @[@"txt",@"h",@"m",@"md"];
    
    openDlg.allowsMultipleSelection = NO;

    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSURL *fileURL = [openDlg URL];
        
        
        NSString *str = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:nil];
        
        if (str.length) {
            _pathTF.stringValue = fileURL.path;
            _fileContent = str;
        }
    }
}

- (IBAction)clickStartBtn:(id)sender
{
    if (!_pathTF.stringValue.length) {
        _descTV.string = @"请选择文件";
        return;
    }
    
    if (!_regularTF.stringValue.length) {
        _descTV.string = @"请输入正则表达式";
        return;
    }
    
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:_regularTF.stringValue options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators error:&error];
    
    if (error) {
        _descTV.string = error.domain;
        return;
    }
    
    _descTV.string = @"正在查找...";
    
    NSArray<NSTextCheckingResult *> *results =
        [regular matchesInString:_fileContent
                         options:NSMatchingReportCompletion
                           range:NSMakeRange(0, _fileContent.length)];
    
    NSMutableArray *muarr = [NSMutableArray array];
    for (NSTextCheckingResult *result in results) {
        @autoreleasepool {
            NSString *str = [_fileContent substringWithRange:result.range];
            
            [muarr addObject:str];
        }
    }
    
    muarr = [[muarr deleteRepeatString] mutableCopy];
    
    if (muarr.count) {
        _descTV.string = [muarr componentsJoinedByString:@"\n\n"];
    } else {
        _descTV.string = @"没有找到匹配内容";
    }
}

+ (NSArray<NSString *> *)arrayOfCheckStringWithRegularExpression:(NSString *)regex checkString:(NSString *)checkString
{
    if (!checkString) {
        return nil;
    }
    NSError *error = NULL;
    NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                       options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                         error:&error];
    NSTextCheckingResult *result =
    [regularExpression firstMatchInString:checkString options:NSMatchingReportProgress range:NSMakeRange(0, [checkString length])];
    
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger i = 1; i < [result numberOfRanges]; i++) {
        NSString *matchString;
        
        NSRange range = [result rangeAtIndex:i];
        
        if (range.location != NSNotFound) {
            matchString = [checkString substringWithRange:[result rangeAtIndex:i]];
        } else {
            matchString = @"";
        }
        [arr addObject:matchString];
    }
    
    return [arr copy];
}





@end
