//
//  BookParse.h
//  DMKit
//
//  Created by iMac-03 on 2019/12/16.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DMDefine.h"

#import "BookChapterModel.h"

@interface BookParse : NSObject

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
                            error:(void (^)(NSError *error))errorBlock;

@end


