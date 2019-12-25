//
//  BookFilterVC.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/24.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "BookFilterVC.h"
#import "BookFilterModel.h"

@interface BookFilterVC ()

@property (weak) IBOutlet NSTextField *pathTF;
@property (unsafe_unretained) IBOutlet NSTextView *filterTV;

@property (weak) IBOutlet NSTextField *strTF;
@property (weak) IBOutlet NSTextField *descTF;


@property (nonatomic , strong) BookFilterModel *filter;

@end

@implementation BookFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pathTF.editable = NO;
    
    _filter = [BookFilterModel shareFilter];
    if (_filter.filePath) {
        _pathTF.stringValue = _filter.filePath;
    }
    
    if (_filter.filters) {
        _filterTV.string = [_filter.filters componentsJoinedByString:@"\n\n"];
    }
    
}

- (IBAction)clickSelectPathBtn:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    openDlg.prompt = @"Select";
    openDlg.canChooseFiles = YES;
    openDlg.canChooseDirectories = NO;
    
    openDlg.allowsMultipleSelection = NO;

    if ([openDlg runModal] == NSModalResponseOK)
    {
        NSURL *fileURL = [openDlg URL];
        _pathTF.stringValue = fileURL.path;
        _filter.filePath = fileURL.path;
        
        if (_filter.filters.count) {
            _filterTV.string = [_filter.filters componentsJoinedByString:@"\n\n"];
        }
        
        [_filter saveDatas];
    }
}

- (IBAction)clickSortBtn:(id)sender
{
    if (!_pathTF.stringValue.length) {
        _descTF.stringValue = @"请选择文件";
    } else {
        [_filter sortAndSave];
        
        if (_filter.filters) {
            _filterTV.string = [_filter.filters componentsJoinedByString:@"\n\n"];
            
            _descTF.stringValue = @"排序成功";
        }
    }
}


- (IBAction)clickAddBtn:(id)sender
{
    NSString *str = _strTF.stringValue;
    
    if (!_pathTF.stringValue.length) {
        _descTF.stringValue = @"请选择文件";
    } else if (!str.length) {
        _descTF.stringValue = @"请输入广告字符";
    } else {
        [_filter addString:str];
        
        if (_filter.filters) {
            _filterTV.string = [_filter.filters componentsJoinedByString:@"\n\n"];
            
            _descTF.stringValue = @"添加成功";
        }
    }
    
    _strTF.stringValue = @"";
}

@end
