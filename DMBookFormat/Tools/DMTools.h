//
//  DMTools.h
//  DMKit
//
//  Created by 西安旺豆电子信息有限公司 on 17/8/31.
//  Copyright © 2017年 呆木出品. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMTools : NSObject


#pragma mark - << Documents >>
/*
 1、Documents 目录：您应该将所有de应用程序数据文件写入到这个目录下。这个目录用于存储用户数据或其它应该定期备份的信息。
 
 2、AppName.app 目录：这是应用程序的程序包目录，包含应用程序的本身。由于应用程序必须经过签名，所以您在运行时不能对这个目录中的内容进行修改，否则可能会使应用程序无法启动。
 
 3、Library 目录：这个目录下有两个子目录：Caches 和 Preferences
 Preferences 目录：包含应用程序的偏好设置文件。您不应该直接创建偏好设置文件，而是应该使用NSUserDefaults类来取得和设置应用程序的偏好.
 Caches 目录：用于存放应用程序专用的支持文件，保存应用程序再次启动过程中需要的信息。
 
 4、tmp 目录：这个目录用于存放临时文件，保存应用程序再次启动过程中不需要的信息。
 */

/** 给出文件名获得其在doc中的路径 */
+(NSString *)filePathInDocuntsWithFile:(NSString *)file;

/** 给出文件名获得其在Cache中的路径 */
+(NSString *)filePathInCachesWithFile:(NSString *)file;

/** 给出文件名获得其在Tmp中的路径 */
+(NSString *)filePathInTmpWithFile:(NSString *)file;

#pragma mark - << FileManager >>

/** 文件是否存在 */
+ (BOOL)fileExist:(NSString*)path;

/** 目录是否存在 */
+ (BOOL)directoryExist:(NSString*)dirPath;

/** 创建目录 */
+ (BOOL)createDirectory:(NSString*)dirPath;

/** 删除指定路径文件 */
+ (BOOL)deleteFileAtPath:(NSString *)filePath;

/** 删除指定目录 */
+ (BOOL)deleteDirectoryAtPath:(NSString *)dirPath;

/** 修正文件乱码 */
+ (void)fixTextFile:(NSString *)oFile toFile:(NSString *)toFile;

#pragma mark - << String >>

/** 字符串是否是空 */
+ (BOOL)stringIsNull:(NSString *)string;

/** 判断字符串是否全为空格 */
+ (BOOL)stringIsAllWithSpace:(NSString *)string;

/** 判断当前字符串跟数组里的字符串是否有相同的 */
+ (BOOL) stringIsInArray:(NSArray *)array WithString:(NSString *)string;

/** MD5 */
+ (NSString *)MD5:(NSString *)string;

/** 字符串转拼音 (没试过)*/
+ (NSString *)stringToPinyinWithString:(NSString *)string;

/** 比较版本号大小 : 3.2.1 > 3.2.0    4 > 3.02.1  只有大于才会yes  其他no */
+ (BOOL)version1:(NSString *)str1 greatThanVersion2:(NSString *)str2;




@end
