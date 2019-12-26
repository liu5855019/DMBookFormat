//
//  BookParse.m
//  DMKit
//
//  Created by iMac-03 on 2019/12/16.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import "BookParse.h"

#import "DMTools.h"
#import "DMDefine.h"

#import "BookFileTools.h"


/**
 
 1. 智能断章
 2. 删除广告 , 无效行 , 替换字符
 3. 章节排序 , 删除无效章节
 4. 拼接章节

 */

#define kResultPath1 @"result1"     // 断章后的结果文件夹
#define kResultPath2 @"result2"     // 删除广告后的结果文件夹



@interface BookParse ()

@property (nonatomic , copy) NSString *filePath;
@property (nonatomic , copy , readonly) NSString *fileName;
@property (nonatomic , copy , readonly) NSString *resultPath1;
@property (nonatomic , copy , readonly) NSString *resultPath2;
@property (nonatomic , copy , readonly) NSString *resultFilePath;  // @"./result_xiaoshuo.txt"


@property (nonatomic , assign) BOOL isFilter;       ///< 是否过滤广告
@property (nonatomic , assign) BOOL isRepeat;       ///< 是否章节去重
@property (nonatomic , assign) double minSameValue;

@property (nonatomic , copy) void (^progressChapter)(unsigned long long readLength,
                                                    unsigned long long totalLength,
                                                    BookChapterModel *chapter);
@property (nonatomic , copy) void (^progressFilter)(NSInteger index,
                                                    NSInteger total,
                                                    BookChapterModel *chapter);
@property (nonatomic , copy) void (^progressRepeat)(NSInteger index,
                                                    NSInteger total,
                                                    BookChapterModel *chapter);
@property (nonatomic , copy) void (^findRepeat)(BookChapterModel *chapter1,
                                                BookChapterModel *chapter2,
                                                double same);
@property (nonatomic , copy) void (^progressWrite)(NSInteger index,
                                                    NSInteger total,
                                                    BookChapterModel *chapter);
@property (nonatomic , copy) void (^successBlock)(void);
@property (nonatomic , copy) void (^errorBlock)(NSError *error);




@property (nonatomic , strong) NSMutableArray *chapters;

@property (nonatomic , strong) BookFileTools *bookTool;

@property (nonatomic , strong) NSFileHandle *handle;

@end

@implementation BookParse


+ (instancetype)parseWithFilePath:(NSString *)filePath
                         isFilter:(BOOL)isFilter
                         isRepeat:(BOOL)isRepeat
                     minSameValue:(double)minSameValue
                  progressChapter:(void (^)(unsigned long long readLength ,
                                              unsigned long long totalLength ,
                                              BookChapterModel *chapter))progressChapter
                     progressFilter:(void (^)(NSInteger index,
                                              NSInteger total,
                                              BookChapterModel *chapter))progressFilter
                     progressRepeat:(void (^)(NSInteger index,
                                              NSInteger total,
                                              BookChapterModel *chapter))progressRepeat
                         findRepeat:(void (^)(BookChapterModel *chapter1,
                                              BookChapterModel *chapter2,
                                              double same))findRepeat
                      progressWrite:(void (^)(NSInteger index,
                                              NSInteger total,
                                              BookChapterModel *chapter))progressWrite
                            success:(void (^)(void))successBlock
                              error:(void (^)(NSError *error))errorBlock
{
    BookParse *parse = [[self alloc] init];
    parse.isFilter = isFilter;
    parse.isRepeat = isRepeat;
    parse.minSameValue = minSameValue;
    parse.progressChapter = progressChapter;
    parse.progressFilter = progressFilter;
    parse.progressRepeat = progressRepeat;
    parse.findRepeat = findRepeat;
    parse.progressWrite = progressWrite;
    parse.successBlock = successBlock;
    parse.errorBlock = errorBlock;
    
    BACK(^{
        [parse beginWithFilePath:filePath];
    });
    
    return parse;
}

#pragma mark - Path

- (void)setFilePath:(NSString *)filePath
{
    _filePath = filePath;
    
    if (!filePath) {
        return;
    }
    
    _fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
    
    NSString *dirPath = [filePath stringByDeletingLastPathComponent];
    
    _resultPath1 = [NSString stringWithFormat:@"%@/%@_%@",dirPath,kResultPath1,_fileName];
    _resultPath2 = [NSString stringWithFormat:@"%@/%@_%@",dirPath,kResultPath2,_fileName];
    _resultFilePath = [NSString stringWithFormat:@"%@/result_%@.txt",dirPath,_fileName];
    
    
    NSLog(@"%@",_resultPath1);
    if (![DMTools directoryExist:_resultPath1]) {
        [DMTools createDirectory:_resultPath1];
    }
    
    if (![DMTools directoryExist:_resultPath2]) {
        [DMTools createDirectory:_resultPath2];
    }
    
    [@"" writeToFile:_resultFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    _handle = [NSFileHandle fileHandleForWritingAtPath:_resultFilePath];
}

#pragma mark - report
- (void)reportError:(NSString *)error
{
    if (_errorBlock) {
        WeakObj(self);
        MAIN(^{
            selfWeak.errorBlock([NSError errorWithDomain:@"" code:0 userInfo:@{@"msg":error}]);
        });
    }
}

#pragma mark - begin

- (void)beginWithFilePath:(NSString *)filePath
{
    if (!filePath ||![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [self reportError:@"指定的书籍不存在"];
        return;
    }
    
    self.filePath = filePath;
    
    _bookTool = [[BookFileTools alloc] initWithFilePath:_filePath];
    
    if (!_bookTool || _bookTool.totalFileLength <= 0) {
        [self reportError:@"书籍无内容"];
        return;
    }
    
    _chapters = [NSMutableArray array];
  
    [self smartChapter];
    
    [self filterChapter];
    
    if (_isRepeat) {
        [self checkRepeat1];
        NSLog(@"sameFuncCount : %ld",_bookTool.sameFuncCount);
    }
    
    [self writeToFile];
    
    WeakObj(self);
    if (_successBlock) {
        MAIN(^{
            selfWeak.successBlock();
        });
    }
}

/// 智能断章
- (void)smartChapter
{
    // 新建书本同名章节 /第一章
    BookChapterModel *firstChapter = [[BookChapterModel alloc] init];
    firstChapter.index = 1;
    firstChapter.name = _fileName;
    firstChapter.filePath = [NSString stringWithFormat:@"%@/%ld_%@.txt",_resultPath1,firstChapter.index,_fileName];
    firstChapter.filePath2 = [NSString stringWithFormat:@"%@/%ld_%@.txt",_resultPath2,firstChapter.index,_fileName];
    firstChapter.startIndex = 0;
    [_chapters addObject:firstChapter];
    
    WeakObj(self);
    while (_bookTool.currentOffset < _bookTool.totalFileLength) {
        @autoreleasepool {
            //读取行数据
            unsigned long long lineStartIndex = _bookTool.currentOffset;
            NSString *lineStr = [_bookTool readLine];
            
            //如果该行含有标题
            if ([_bookTool hasChapterTitleLineData:lineStr]) {
                //取出上一章
                BookChapterModel *lastChapter = _chapters.lastObject;
                lastChapter.endIndex = lineStartIndex;
                NSString *lastStr = [_bookTool readContentFromIndex:lastChapter.startIndex toIndex:lastChapter.endIndex];
                BOOL isWrite = [lastStr writeToFile:lastChapter.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                if (_progressChapter) {
                    MAIN(^{
                       selfWeak.progressChapter(lastChapter.endIndex,
                                                selfWeak.bookTool.totalFileLength,
                                                lastChapter);
                    });
                }
                
                //新建章节
                BookChapterModel *newChapter = [[BookChapterModel alloc] init];
                newChapter.index = lastChapter.index+1;
                NSString *title = lineStr;
                title = [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                newChapter.name = title;
                newChapter.filePath = [NSString stringWithFormat:@"%@/%ld_%@.txt",_resultPath1,newChapter.index,_fileName];
                newChapter.filePath2 = [NSString stringWithFormat:@"%@/%ld_%@.txt",_resultPath2,newChapter.index,_fileName];
                newChapter.startIndex = lineStartIndex;
                [_chapters addObject:newChapter];
            }
        }
    }
    
    //最后一章
    BookChapterModel *lastChapter = _chapters.lastObject;
    lastChapter.endIndex = _bookTool.totalFileLength;
    NSString *lastStr = [_bookTool readContentFromIndex:lastChapter.startIndex toIndex:lastChapter.endIndex];
    [lastStr writeToFile:lastChapter.filePath atomically:YES encoding:YES error:nil];
    if (_progressChapter) {
        MAIN(^{
            selfWeak.progressChapter(lastChapter.endIndex,
                                     selfWeak.bookTool.totalFileLength,
                                     lastChapter);
        });
    }
}

/// 过滤章节
- (void)filterChapter
{
    WeakObj(self);
    for (BookChapterModel *chapter in _chapters) {
        @autoreleasepool {
            NSString *content = [NSString stringWithContentsOfFile:chapter.filePath encoding:NSUTF8StringEncoding error:nil];
            if (_isFilter) {    // 是否过滤广告
                content = [_bookTool filterContent:content];
            }
    
            chapter.valuable = [_bookTool valuableTitle:chapter.name content:content];
            if (chapter.valuable) { //过滤掉无用章节
                BOOL isWrite = [content writeToFile:chapter.filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }

            
            if (_progressFilter) {
                MAIN(^{
                    selfWeak.progressFilter(chapter.index, selfWeak.chapters.count, chapter);
                });
            }
        }
    }
}

#pragma mark - repeat

//61174799
- (void)checkRepeat1
{
    WeakObj(self);
    for (int i = 0; i < _chapters.count - 1; i++) {
        @autoreleasepool {
            BookChapterModel *chapter1 = _chapters[i];
            
            if (_progressRepeat) {
                MAIN(^{
                    selfWeak.progressRepeat(chapter1.index, selfWeak.chapters.count, chapter1);
                });
            }
            
            if (chapter1.valuable == NO) {
                continue;
            }
        
            for (int j = i+1; j < _chapters.count; j++) {
                BookChapterModel *chapter2 = _chapters[j];
                if (chapter2.valuable == NO) {
                    continue;
                }
    
                double sameValue = [_bookTool sameOfChapter1:chapter1 chapter2:chapter2];
                
                if (sameValue >= _minSameValue) {
                    chapter2.valuable = NO;
                    if (_findRepeat) {
                        MAIN(^{
                            selfWeak.findRepeat(chapter1, chapter2, sameValue);
                        });
                    }
                }
            }
        }
    }
}

- (BOOL)chapters:(NSArray *)chapters hasChapter:(BookChapterModel *)chapter
{
    for (BookChapterModel *tmpChapter in chapters) {
        @autoreleasepool {
            double sameValue = [_bookTool sameOfChapter1:chapter chapter2:tmpChapter];
            if (sameValue >= _minSameValue) {
                return YES;
            }
        }
    }
    return NO;
}

//61057514
- (void)checkRepeat
{
    NSMutableArray *muarr = [NSMutableArray array];
    
    for (BookChapterModel *chapter in _chapters) {
        //NSLog(@"%ld - %@",chapter.index,chapter.name);
        @autoreleasepool {
            if (chapter.valuable == NO) {
                continue;
            }

            if ([self chapters:muarr hasChapter:chapter]) {
                NSLog(@"删除章节: %ld - %@ - %ld",chapter.index,chapter.name,_bookTool.sameFuncCount);
            } else {
                [muarr addObject:chapter];
                NSLog(@"加入章节: %ld - %@",chapter.index,chapter.name);
            }
        }
    }

    _chapters = muarr;
}

- (void)writeToFile
{
    WeakObj(self);
    for (BookChapterModel *chapter in _chapters) {
        @autoreleasepool {
            if (chapter.valuable == NO) {
                continue;
            }
            
            NSString *content = [NSString stringWithContentsOfFile:chapter.filePath encoding:NSUTF8StringEncoding error:nil];
            
            [content writeToFile:chapter.filePath2 atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            [_handle seekToEndOfFile];
            [_handle writeData:[content dataUsingEncoding:NSUTF8StringEncoding]];

            if (_progressWrite) {
                MAIN(^{
                   selfWeak.progressWrite(chapter.index, selfWeak.chapters.count, chapter);
                });
            }
        }
    }
}

- (void)dealloc
{
    MyLog(@" Game Over ... ");
}

@end
