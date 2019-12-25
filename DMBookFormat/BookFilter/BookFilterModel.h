//
//  BookFilterModel.h
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/24.
//  Copyright © 2019 daimu. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookFilterModel : NSObject

+ (instancetype)shareFilter;

@property (nonatomic , copy) NSString *filePath;

@property (nonatomic , strong , readonly) NSArray <NSString *>*filters;




- (void)sortAndSave;
- (void)addString:(NSString *)str;

// 写入文件
- (void)saveDatas;
// 删除文件
- (void)removeDatas;

@end


