//
//  BookFileTools.h
//  DMKit
//
//  Created by iMac-03 on 2019/12/13.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BookChapterModel.h"
#import "BookFilterModel.h"



#define kChapterNameRegular @"^\\s*[\\S]{0,10}\\s*第\\s*[0-9零一二三四五六七八九十百千万]+\\s*[篇书首集卷回章节部]{1,2}\\s*[\\S]{0,20}\\s*$"
//#define kChapterNameRegular @"[\\S]{0,10}第\\s*[0-9零一二三四五六七八九十百千万]+\\s*[篇书首集卷回章部]{1}[\\S]{0,30}"
#define kChapterNameIndexRegular @"第\\s*[0-9零一二三四五六七八九十百千万]+\\s*[篇书首集卷回章部]{1}"


@interface BookFileTools : NSObject

@property (nonatomic , copy) NSString *filePath;

@property (nonatomic , assign) unsigned long long totalFileLength;
@property (nonatomic , assign) unsigned long long currentOffset;
@property (nonatomic , assign) NSStringEncoding stringEncoding;

@property (nonatomic , assign) NSInteger sameFuncCount; 



- (id)initWithFilePath:(NSString *)aPath;

- (NSString *)readLine;

/// 读取内容
- (NSString *)readContentFromIndex:(unsigned long long)fromIndex toIndex:(unsigned long long)toIndex;

/// 过滤掉无用的内容
- (NSString *)filterContent:(NSString *)content;

///章节内容是否有意义
- (BOOL)valuableTitle:(NSString *)title content:(NSString *)content;

/// 获取相似度
- (double)sameOfContent1:(NSString *)content1 content2:(NSString *)content2;

/// 获取相似度
- (double)sameOfChapter1:(BookChapterModel *)chapter1 chapter2:(BookChapterModel *)chapter2;

///判断字符是否是相同章节名称
- (BOOL)hasTheSameChapterName:(NSString*)oneChapterName withAnotherChapterName:(NSString*)anotherChapterName;

///判断该行是否是章节标题
- (BOOL)hasChapterTitleLineData:(NSString*)lineString;


- (void)enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;


@end


