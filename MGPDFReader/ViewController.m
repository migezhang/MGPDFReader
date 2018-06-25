//
//  ViewController.m
//  MGPDFReader
//
//  Created by mige on 2018/5/18.
//  Copyright © 2018年 mige.com. All rights reserved.
//

#import "ViewController.h"
#import "MGPDFReaderVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)onReusableViewAction:(id)sender {
    MGPDFReaderVC *vc = [[MGPDFReaderVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
