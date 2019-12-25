//
//  DMDefine.h
//  DMKit
//
//  Created by 西安旺豆电子信息有限公司 on 17/8/30.
//  Copyright © 2017年 呆木出品. All rights reserved.
//

#ifndef DMDefine_h
#define DMDefine_h

#ifdef DEBUG
#define MyLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define MyLog(...)
#endif

#pragma mark - << G－C－D >>

//后台线程运行
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
//主线程运行
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)
//selfWeak
#define WeakObj(self) __weak typeof(self) self##Weak = self;




#endif /* DMDefine_h */
