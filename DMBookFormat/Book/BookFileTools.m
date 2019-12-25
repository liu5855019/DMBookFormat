//
//  BookFileTools.m
//  DMKit
//
//  Created by iMac-03 on 2019/12/13.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import "BookFileTools.h"

#import "NSArray+DMTools.h"
#import "DMDefine.h"


@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;

@end

@implementation NSData (DDAdditions)

- (NSRange)rangeOfData_dd:(NSData *)dataToFind {
    
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

@end










@interface BookFileTools ()

@property (nonatomic , strong) NSFileHandle * fileHandle;


@property (nonatomic , copy) NSString *lineDelimiter; //行标识符 "\n"
@property (nonatomic , assign) NSUInteger chunkSize;


@property (nonatomic , strong) NSArray *filterDatas;

@end



@implementation BookFileTools


- (id)initWithFilePath:(NSString *)aPath
{
    if (self = [super init]) {
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (self.fileHandle == nil) {
            return nil;
        }
        
        _lineDelimiter = @"\n";
        _chunkSize = 10;
        self.currentOffset = 0ULL; // ???
        [self.fileHandle seekToEndOfFile];
        self.totalFileLength = [self.fileHandle offsetInFile];
        self.stringEncoding = [self getContentEncodingWithFilePath:aPath];
        
        _filterDatas = [BookFilterModel shareFilter].filters;
    }
    return self;
}

- (NSString *)readLine
{
    if (self.currentOffset >= self.totalFileLength) { return nil; }
    
    NSData * newLineData = [_lineDelimiter dataUsingEncoding:self.stringEncoding];
    [self.fileHandle seekToFileOffset:self.currentOffset];
    
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;
    @autoreleasepool {
        
        while (shouldReadMore) {
            if (self.currentOffset >= self.totalFileLength) {
                break;
            }
            NSData * chunk = [self.fileHandle readDataOfLength:_chunkSize];
            
            NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
            if (newLineRange.location != NSNotFound) {
                
                //include the length so we can include the delimiter in the string
                chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
                shouldReadMore = NO;
            }
            [currentData appendData:chunk];
            self.currentOffset += [chunk length];
        }
    }
    
    NSString * line = [[NSString alloc] initWithData:currentData encoding:self.stringEncoding];
    return line;
}

- (NSString *)readTrimmedLine
{
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/// 读取内容
- (NSString *)readContentFromIndex:(unsigned long long)fromIndex toIndex:(unsigned long long)toIndex
{
    if (toIndex <= fromIndex || fromIndex >= self.totalFileLength) {
        return @"";
    }
    unsigned long long oldIndex = self.currentOffset;
    [self.fileHandle seekToFileOffset:fromIndex];
    NSData *data = [self.fileHandle readDataOfLength:(NSUInteger)(toIndex-fromIndex)];
    [self.fileHandle seekToFileOffset:oldIndex];
    if (!data || data.length <= 0) {
        return @"";
    }
    NSString *str = [[NSString alloc] initWithData:data encoding:self.stringEncoding];
    return str;
}

/// 过滤掉无用的内容
- (NSString *)filterContent:(NSString *)content
{
    NSString *tmpStr = content;
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    for (NSString *filter in _filterDatas) {
        @autoreleasepool {
            tmpStr = [tmpStr stringByReplacingOccurrencesOfString:filter withString:@""];
        }
    }
    return tmpStr;
}

///章节内容是否有意义
- (BOOL)valuableTitle:(NSString *)title content:(NSString *)content
{
    NSString *tmpStr = content;
    
    tmpStr = [tmpStr stringByReplacingOccurrencesOfString:title withString:@""];
    
    tmpStr = [tmpStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (tmpStr.length >= 30) {
        return YES;
    }
    
    return NO;
}

/// 获取相似度
- (double)sameOfContent1:(NSString *)content1 content2:(NSString *)content2
{
    _sameFuncCount++;
    
    NSMutableArray *muarr;
    NSInteger repeatCount = 0;
    @autoreleasepool {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"。\n"];
        
        NSArray *arr1 = [content1 componentsSeparatedByCharactersInSet:set];
        NSArray *arr2 = [content2 componentsSeparatedByCharactersInSet:set];
        arr1 = [arr1 deleteRepeatString];
        arr2 = [arr2 deleteRepeatString];
        
        muarr = [NSMutableArray arrayWithArray:arr1];
        for (NSString *str in arr2) {
            if ([muarr hasString:str]) {
                repeatCount++;
            } else {
                [muarr addObject:str];
            }
        }
    }

    return (double)repeatCount / muarr.count;
}

/// 获取相似度
- (double)sameOfChapter1:(BookChapterModel *)chapter1 chapter2:(BookChapterModel *)chapter2
{
    _sameFuncCount++;
    
    NSMutableArray *muarr;
    NSInteger repeatCount = 0;
    @autoreleasepool {
        NSArray *arr1 = chapter1.contents;
        NSArray *arr2 = chapter2.contents;
//        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"，。\n"];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"。\n"];
        
        if (arr1 == nil) {
            NSString *str1 = [NSString stringWithContentsOfFile:chapter1.filePath encoding:NSUTF8StringEncoding error:nil];
            arr1 = [str1 componentsSeparatedByCharactersInSet:set];
            arr1 = [arr1 deleteRepeatString];
            chapter1.contents = arr1;
        }
        if (arr2 == nil) {
            NSString *str2 = [NSString stringWithContentsOfFile:chapter2.filePath encoding:NSUTF8StringEncoding error:nil];
            arr2 = [str2 componentsSeparatedByCharactersInSet:set];
            arr2 = [arr2 deleteRepeatString];
            chapter2.contents = arr2;
        }
        
        muarr = [NSMutableArray arrayWithArray:arr1];
        for (NSString *str in arr2) {
            if ([muarr hasString:str]) {
                repeatCount++;
            } else {
                [muarr addObject:str];
            }
        }
    }

    return (double)repeatCount / muarr.count;
}





///判断截取的章节内容是否有意义
- (BOOL)valuableDataFromIndex:(unsigned long long)fromIndex toIndex:(unsigned long long)toIndex
{
    if (toIndex <= fromIndex || fromIndex >= self.totalFileLength) {
        return NO;
    }
    unsigned long long tmpIndex = self.currentOffset;
    [self.fileHandle seekToFileOffset:fromIndex];
    NSData *data = [self.fileHandle readDataOfLength:(NSUInteger)(toIndex-fromIndex)];
    [self.fileHandle seekToFileOffset:tmpIndex];
    if (!data || data.length <= 0) {
        return NO;
    }
    NSString *tmpString = [[NSString alloc] initWithData:data encoding:self.stringEncoding];
    if (!tmpString || [[tmpString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return NO;
    }
    if ([self hasChapterTitleLineData:tmpString]) {
        return NO;
    }
    return YES;
}

///判断字符是否是相同章节名称
- (BOOL)hasTheSameChapterName:(NSString *)oneChapterName withAnotherChapterName:(NSString *)anotherChapterName
{
    if (!oneChapterName || !anotherChapterName) {
        return NO;
    }
    NSString *tmpOne = [oneChapterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *tmpTwo = [anotherChapterName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([tmpOne isEqualToString:tmpTwo]) {
        return YES;
    }
    NSRange oneRange = [tmpOne rangeOfString:kChapterNameIndexRegular options:NSRegularExpressionSearch];
    NSRange anotherRange = [tmpTwo rangeOfString:kChapterNameIndexRegular options:NSRegularExpressionSearch];
    if (oneRange.location != NSNotFound && anotherRange.location != NSNotFound) {
        if ([[tmpOne substringWithRange:oneRange] isEqualToString:[tmpTwo substringWithRange:anotherRange]]) {
            return YES;
        }
    }
    return NO;
}

///判断该行是否是章节标题
- (BOOL)hasChapterTitleLineData:(NSString*)lineString
{
    NSRange range = [lineString rangeOfString:kChapterNameRegular options:NSRegularExpressionSearch];
    return range.length > 2;
}

- (void)enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
    NSString * line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLine])) {
        block(line, &stop);
    }
}


#pragma mark - Encode

- (NSStringEncoding)getContentEncodingWithFilePath:(NSString*)path
{
    [self.fileHandle seekToFileOffset:0];
    NSData *data = [self.fileHandle readDataOfLength:(NSUInteger)(10 < _totalFileLength ? 10 : _totalFileLength)];
    if (data) {
        return [self getCharEncodingWithFilePath:path data:data];
    }
    return NSUTF8StringEncoding;
}

- (NSStringEncoding)getCharEncodingWithFilePath:(NSString *)filePath data:(NSData *)data
{
    NSStringEncoding encoding;
    NSError *error = nil;
    NSString *encodingString = [[NSString alloc] initWithContentsOfFile:filePath usedEncoding:&encoding error:&error];
    encodingString = nil;
    
    if (!error) {
        return encoding;
    }
    
    if ([[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95)]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGBK_95);
    }
    
    if ([[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80)]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
    }
    
    if ([[NSString alloc] initWithData:data encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]) {
        return CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    
    return NSUTF8StringEncoding;
}

- (void)dealloc
{
    MyLog(@" Game Over ... ");
    
    [self.fileHandle closeFile];
}


@end
