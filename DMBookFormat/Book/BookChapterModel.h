//
//  BookChapterModel.h
//  DMKit
//
//  Created by iMac-03 on 2019/12/16.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookChapterModel : NSObject

@property (nonatomic , assign) NSInteger index;
@property (nonatomic , copy) NSString *name;        ///< 章节标题
@property (nonatomic , copy) NSString *filePath;    ///< 章节文件路径
@property (nonatomic , copy) NSString *filePath2;
@property (nonatomic , assign) unsigned long long startIndex;   ///< 总文件读取的开始index
@property (nonatomic , assign) unsigned long long endIndex;     ///< 总文件读取的结束index
@property (nonatomic , assign) BOOL valuable;   ///< 是否有意义

@property (nonatomic , strong) NSArray *contents;   ///< 存储章节内容(特征) , 且行去重 , 用来判断相似度

@end


