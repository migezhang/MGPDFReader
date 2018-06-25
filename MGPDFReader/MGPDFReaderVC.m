//
//  MGPDFReaderVC.m
//  MGPDFReader
//
//  Created by mige on 2018/5/21.
//  Copyright © 2018年 mige.com. All rights reserved.
//

#import "MGPDFReaderVC.h"
#import "MGPDFReaderView.h"

@interface MGPDFReaderVC () <MGPDFReaderViewDelegate>

@property (nonatomic, strong) MGPDFReaderView *pdfReaderView;

@property (nonatomic, strong) NSArray *documentArr;

@end

@implementation MGPDFReaderVC

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.pdfReaderView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initDocuments];
    
    [self careatePDFReaderView];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换文档" style:UIBarButtonItemStylePlain target:self action:@selector(didDocumentChange:)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)careatePDFReaderView{
    MGPDFDocument *document = [self.documentArr firstObject];
    self.pdfReaderView = [[MGPDFReaderView alloc] initWithFrame:self.view.bounds PDFDocument:document];
    self.pdfReaderView.delegate = self;
    [self.view addSubview:self.pdfReaderView];
    
    [self.pdfReaderView showPDFDocumentAtPage:385];
}

- (void)initDocuments{
    NSMutableArray *documentArr = [NSMutableArray arrayWithCapacity:0];
    NSArray *fileNameArr = @[@"高性能iOS-应用开发-中文版", @"compoundSealAutoPdf", @"STA20180522101641440"];
    for (NSString *fileName in fileNameArr) {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@".pdf"];
        MGPDFDocument *document = [[MGPDFDocument alloc] initWithFilePath:filePath password:nil];
        [documentArr addObject:document];
    }
    self.documentArr = documentArr;
}

- (void)didDocumentChange:(UIBarButtonItem *)barButtonItem{
    int index = arc4random() % self.documentArr.count;
    MGPDFDocument *document = self.documentArr[index];
    [self.pdfReaderView updateDocument:document];
}

#pragma mark - MGPDFReaderViewDelegate
//点击页面
- (void)PDFReaderView:(MGPDFReaderView *)pdfReaderView didPDFContentClickAtPage:(NSInteger)page{
    NSLog(@"******>>> ClickAtPage %ld", page);
}

//滑动页面
- (void)PDFReaderView:(MGPDFReaderView *)pdfReaderView didScrollPage:(UIScrollView *)scrollView{
    NSLog(@"******>>> didScrollPage %g", scrollView.contentOffset.x);
}

@end
