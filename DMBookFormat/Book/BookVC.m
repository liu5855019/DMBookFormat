//
//  BookVC.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/24.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "BookVC.h"

#import "BookParse.h"
#import "BookFilterModel.h"

@interface BookVC ()

@property (nonatomic , strong) BookParse *parse;
@property (weak) IBOutlet NSTextField *pathTF;
@property (weak) IBOutlet NSButton *selectFilterBtn;
@property (weak) IBOutlet NSButton *selectRepeatBtn;
@property (weak) IBOutlet NSSliderCell *sameSlider;
@property (weak) IBOutlet NSTextField *sameLab;
@property (weak) IBOutlet NSButton *startBtn;

@property (weak) IBOutlet NSProgressIndicator *progressChapter;
@property (weak) IBOutlet NSProgressIndicator *progressFilter;
@property (weak) IBOutlet NSProgressIndicator *progressRepeat;
@property (weak) IBOutlet NSProgressIndicator *progressWrite;
@property (unsafe_unretained) IBOutlet NSTextView *descTextView;


@property (nonatomic , strong) NSMutableArray *repeats;

@end

@implementation BookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pathTF.editable = NO;
    
}

- (IBAction)sameValueChanged:(NSSliderCell *)sender
{
    _sameLab.stringValue = [NSString stringWithFormat:@"%.2f%%",sender.doubleValue];
}

- (IBAction)clickSelectBtn:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.prompt = @"Select";
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    openDlg.allowedFileTypes = @[@"txt"];
    
    openDlg.allowsMultipleSelection = NO;

    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSURL *fileURL = [openDlg URL];
        _pathTF.stringValue = fileURL.path;
    }
}

- (IBAction)clickStartBtn:(id)sender
{
    NSString *filePath = _pathTF.stringValue;
    
    if (filePath.length == 0) {
        _descTextView.string = @"请选择小说";
        return;
    }
    
    if (_selectFilterBtn.state == NSControlStateValueOn &&
        [BookFilterModel shareFilter].filters.count == 0) {
        _descTextView.string = @"请选择过滤文件";
        return;
    }
    
    _startBtn.enabled = NO;
    
    [self actionWithFilePath:filePath
                    isFilter:_selectFilterBtn.state == NSControlStateValueOn
                    isRepeat:_selectRepeatBtn.state == NSControlStateValueOn
                minSameValue:_sameSlider.doubleValue / 100.0];
}

- (void)actionWithFilePath:(NSString *)filePath
                  isFilter:(BOOL)isFilter
                  isRepeat:(BOOL)isRepeat
              minSameValue:(double)minSameValue
{
    _repeats = [NSMutableArray array];
    
    WeakObj(self);
    _parse =
    [BookParse parseWithFilePath:filePath
                        isFilter:isFilter
                        isRepeat:isRepeat
                    minSameValue:minSameValue
                 progressChapter:^(unsigned long long readLength, unsigned long long totalLength, BookChapterModel *chapter) {
        
        double value = (double)readLength / (double)totalLength * 100;
        
        selfWeak.progressChapter.doubleValue = value;
        selfWeak.descTextView.string = [NSString stringWithFormat:@"%ld - %@",chapter.index,chapter.name];

    } progressFilter:^(NSInteger index, NSInteger total, BookChapterModel *chapter) {
        
        double value = (double)index / (double)total * 100;
        
        selfWeak.progressFilter.doubleValue = value;
        selfWeak.descTextView.string = [NSString stringWithFormat:@"filter: %ld - %@",chapter.index,chapter.name];
        
    } progressRepeat:^(NSInteger index, NSInteger total, BookChapterModel *chapter) {
        
        double value = (double)index / (double)total * 100;
        
        selfWeak.progressRepeat.doubleValue = value;
        selfWeak.descTextView.string = [NSString stringWithFormat:@"repeat:%.2f%% - %ld - %@",value,chapter.index,chapter.name];
        
    } findRepeat:^(BookChapterModel *chapter1, BookChapterModel *chapter2, double same) {

        NSString *str = [NSString stringWithFormat:@"重复章节: %.2f%% - %ld - %ld - %@ - %@",same*100, chapter1.index, chapter2.index, chapter1.name, chapter2.name];
        [selfWeak.repeats addObject:str];
        selfWeak.descTextView.string = [NSString stringWithFormat:@"%@\n%@",selfWeak.descTextView.string,str];

    } progressWrite:^(NSInteger index, NSInteger total, BookChapterModel *chapter) {
        double value = (double)index / (double)total * 100;
        
        selfWeak.progressWrite.doubleValue = value;
        selfWeak.descTextView.string = [NSString stringWithFormat:@"write: %ld - %@",chapter.index,chapter.name];
    } success:^{
        NSLog(@"完成!");
        if (isRepeat) {
            NSString *str = [NSString stringWithFormat:@"%@\n",[NSDate date]];
            str = [str stringByAppendingString:@"完成!\n"];
            str = [str stringByAppendingFormat:@"共发现 %ld 重复章节\n",(long)selfWeak.repeats.count];
            str = [str stringByAppendingString:[selfWeak.repeats componentsJoinedByString:@"\n"]];
            selfWeak.descTextView.string = str;
        } else {
            selfWeak.descTextView.string = [NSString stringWithFormat:@"%@ 完成!",[NSDate date]];
        }
        selfWeak.startBtn.enabled = YES;
    } error:^(NSError *error) {
        selfWeak.descTextView.string = [NSString stringWithFormat:@"error: %@",error.userInfo[@"msg"]];
        selfWeak.startBtn.enabled = YES;
    }];
}

- (void)dealloc
{
    MyLog(@" Game Over ... ");
}

@end
