//
//  BookChapterModel.m
//  DMKit
//
//  Created by iMac-03 on 2019/12/16.
//  Copyright © 2019 呆木出品. All rights reserved.
//

#import "BookChapterModel.h"

@implementation BookChapterModel

- (void)setValuable:(BOOL)valuable
{
    _valuable = valuable;
    
    if (!_valuable) {
        _contents = nil;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"index:%ld,name:%@,startIndex:%lld,endIndex:%lld",(long)self.index,self.name,self.startIndex,self.endIndex];
}

@end
