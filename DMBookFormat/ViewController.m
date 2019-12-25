//
//  ViewController.m
//  DMBookFormat
//
//  Created by iMac-03 on 2019/12/18.
//  Copyright © 2019 daimu. All rights reserved.
//

#import "ViewController.h"

#import "FixEncodingVC.h"
#import "BookFilterVC.h"
#import "BookVC.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (IBAction)clickFixEncodingBtn:(NSButton *)sender
{
    FixEncodingVC *vc = [[FixEncodingVC alloc] init];
    
    [self presentViewControllerAsModalWindow:vc];
}

- (IBAction)clickEditFilterBtn:(id)sender
{
    BookFilterVC *vc = [[BookFilterVC alloc] init];
    
    [self presentViewControllerAsModalWindow:vc];
}

- (IBAction)clickFixBookBtn:(id)sender
{
    BookVC *vc = [[BookVC alloc] init];
    
    [self presentViewControllerAsModalWindow:vc];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
