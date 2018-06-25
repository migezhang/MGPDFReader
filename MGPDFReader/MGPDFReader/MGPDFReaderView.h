//
//  MGPDFReaderView.h
//  MGPDFReader
//
//  Created by mige on 2018/5/21.
//  Copyright © 2018年 mige.com. All rights reserved.
//
/**
 *  PDF阅读器
 *
 *  @author mige
 */
#import <UIKit/UIKit.h>
#import "MGPDFDocument.h"

@protocol MGPDFReaderViewDelegate;

@interface MGPDFReaderView : UIView

@property (nonatomic, weak) id<MGPDFReaderViewDelegate> delegate;

//PDF文件
@property (nonatomic, strong, readonly) MGPDFDocument *document;

//当前页码
@property (nonatomic, assign, readonly) NSUInteger currentPage;

/**
 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame PDFDocument:(MGPDFDocument *)document;

/**
 显示PDF指定页码
 */
- (void)showPDFDocumentAtPage:(NSInteger)page;

/**
 上一页
 */
- (void)incrementPDFDocumentPage;

/**
 下一页
 */
- (void)decrementPDFDocumentPage;

/**
 更新文档
 */
- (void)updateDocument:(MGPDFDocument *)document;

@end

/**
 PDF阅读器代理
 */
@protocol MGPDFReaderViewDelegate <NSObject>

@optional
//点击页面
- (void)PDFReaderView:(MGPDFReaderView *)pdfReaderView didPDFContentClickAtPage:(NSInteger)page;

//滑动页面
- (void)PDFReaderView:(MGPDFReaderView *)pdfReaderView didScrollPage:(UIScrollView *)scrollView;

@end
