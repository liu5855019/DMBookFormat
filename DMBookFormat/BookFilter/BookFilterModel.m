//
//  BookFilterModel.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/24.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "BookFilterModel.h"

#import "NSArray+DMTools.h"

static NSString * const kBookFilterModel = @"kBookFilterModel";

@implementation BookFilterModel

+ (instancetype)shareFilter
{
    static BookFilterModel *filter;
    if (filter) {
        return filter;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *filePath = [self filePathInDocuntsWithFile:kBookFilterModel];
        
        filter = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        if (!filter) {
            filter = [[self alloc] init];
        }
    });
    
    return filter;
}

/** 给出文件名获得其在doc中的路径 */
+(NSString *)filePathInDocuntsWithFile:(NSString *)file
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:file];
}

- (void)saveDatas
{
    NSString *filePath = [[self class] filePathInDocuntsWithFile:kBookFilterModel];
    
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

- (void)removeDatas
{
    //删除归档的文件
    NSString *filePath = [[self class] filePathInDocuntsWithFile:kBookFilterModel];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

#pragma mark - NSCoding

//  解档协议方法
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.filePath = [coder decodeObjectForKey:@"filePath"];
    }
    return self;
}

//  归档协议方法
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
}

#pragma mark - Filters

- (void)setFilePath:(NSString *)filePath
{
    NSString *filterStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    
    if (filterStr) {
        _filePath = filePath;
        _filters = [filterStr componentsSeparatedByString:@"\n"];
    }
}

- (void)sortAndSave
{
    _filters = _filters.deleteRepeatString;
    _filters = [_filters sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        if (obj1.length > obj2.length) {
            return NSOrderedAscending;
        }
        if (obj1.length == obj2.length) {
            return NSOrderedSame;
        }
        return NSOrderedDescending;
    }];
    NSString *filterStr = [_filters componentsJoinedByString:@"\n"];
    [filterStr writeToFile:_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (void)addString:(NSString *)str
{
    if (str.length) {
        NSMutableArray *muarray = [NSMutableArray arrayWithArray:_filters];
        
        NSArray *arr = [str componentsSeparatedByString:@"\n"];
        
        [muarray addObjectsFromArray:arr];
        
        _filters = [muarray copy];
        
        [self sortAndSave];
    }
}


@end
