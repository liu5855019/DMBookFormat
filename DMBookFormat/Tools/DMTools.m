//
//  DMTools.m
//  DMKit
//
//  Created by 西安旺豆电子信息有限公司 on 17/8/31.
//  Copyright © 2017年 呆木出品. All rights reserved.
//

#import "DMTools.h"

#include <objc/runtime.h>

#import <sys/utsname.h>

#import <CommonCrypto/CommonDigest.h>   //md5 用到

#import "NSArray+DMTools.h"


@implementation DMTools


#pragma mark - << Documents >>

/** 给出文件名获得其在doc中的路径 */
+(NSString *)filePathInDocuntsWithFile:(NSString *)file
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:file];
}

/** 给出文件名获得其在Cache中的路径 */
+(NSString *)filePathInCachesWithFile:(NSString *)file
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    return [path stringByAppendingPathComponent:file];
}

/** 给出文件名获得其在Tmp中的路径 */
+(NSString *)filePathInTmpWithFile:(NSString *)file
{
    NSString *path = NSTemporaryDirectory();
    return [path stringByAppendingPathComponent:file];
}

#pragma mark - << FileManager >>

/** 文件是否存在 */
+ (BOOL)fileExist:(NSString*)path
{
    if ([self stringIsNull:path]) {
        return NO;
    }
    BOOL isDir;
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
    if (!result) {
        return NO;
    }
    if (isDir) {
        return NO;
    }
    return YES;
    
}

/** 目录是否存在 */
+ (BOOL)directoryExist:(NSString*)dirPath
{
    if ([self stringIsNull:dirPath]) {
        return NO;
    }
    BOOL isDir = YES;
    BOOL result = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if (!result) {
        return NO;
    }
    if (!isDir) {
        return NO;
    }
    return YES;
}

/** 创建目录 */
+ (BOOL)createDirectory:(NSString*)dirPath
{
    if ([self stringIsNull:dirPath]) {
        return NO;
    }
    if ([self directoryExist:dirPath]) {
        return YES;
    }
    return [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
}

/** 删除指定路径文件 */
+ (BOOL)deleteFileAtPath:(NSString *)filePath
{
    if ([self stringIsNull:filePath]) {
        return NO;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}

/** 删除指定目录 */
+ (BOOL)deleteDirectoryAtPath:(NSString *)dirPath
{
    if ([self stringIsNull:dirPath]) {
        return NO;
    }
    return [[NSFileManager defaultManager] removeItemAtPath:dirPath error:nil];
}

/** 修正文件乱码 */
+ (void)fixTextFile:(NSString *)oFile toFile:(NSString *)toFile
{
    NSData *data = [NSData dataWithContentsOfFile:oFile];
    
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSString *str = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:encoding];
    
    [str writeToFile:toFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - << String >>

/** 字符串是否是空 */
+ (BOOL)stringIsNull:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (!string || [string isKindOfClass:[NSNull class]] || string.length == 0 || [string isEqualToString:@""]) {
        return YES;
    }else{
        return NO;
    }
}

/** 判断字符串是否全为空格 */
+ (BOOL)stringIsAllWithSpace:(NSString *)string
{
    if ([self stringIsNull:string]) {
        return YES;
    }else{
        NSString *trimString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (trimString.length > 0) {
            return NO;
        }else{
            return YES;
        }
    }
}

/** 判断当前字符串跟数组里的字符串是否有相同的 */
+ (BOOL) stringIsInArray:(NSArray *)array WithString:(NSString *)string
{
    for (NSString *string1 in array) {
        if ([string isEqualToString:string1]) {
            return YES;
        }
    }
    return NO;
}



/** MD5 */
+ (NSString *)MD5:(NSString *)string
{
    const char* aString = [string UTF8String];
    unsigned char result[16];
    CC_MD5(aString, (unsigned int)strlen(aString), result);
    NSString* hash = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    
    return [hash lowercaseString];
}

/** 字符串转拼音 */
+ (NSString *)stringToPinyinWithString:(NSString *)string
{
    NSMutableString *str = [string mutableCopy];
    CFStringTransform(( CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(( CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

/** 比较版本号大小 : 3.2.1 > 3.2.0    4 > 3.02.1  只有大于才会yes  其他no */
+ (BOOL)version1:(NSString *)str1 greatThanVersion2:(NSString *)str2
{
    NSArray *arr1 = [str1 componentsSeparatedByString:@"."];
    NSArray *arr2 = [str2 componentsSeparatedByString:@"."];
    
    NSUInteger maxCount = arr1.count > arr2.count ? arr1.count : arr2.count;
    
    for (int i = 0; i < maxCount; i++) {
        NSString *intStr1 = [arr1 dm_objectAtIndex:i];
        NSString *intStr2 = [arr2 dm_objectAtIndex:i];
        NSUInteger int1 = [intStr1 integerValue];
        NSUInteger int2 = [intStr2 integerValue];
        if (int1 > int2) {
            return YES;
        }
        if (int2 > int1) {
            return NO;
        }
    }
    return  arr1.count > arr2.count ? YES : NO;
}


@end
