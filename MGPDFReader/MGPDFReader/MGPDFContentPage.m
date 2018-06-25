//
//  MGPDFContentPage.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/17.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFContentPage.h"
#import "MGPDFDocumentManager.h"
#import "MGPDFContentTile.h"

@implementation MGPDFContentPage {
    CGPDFDocumentRef _PDFDocRef;
    CGPDFPageRef _PDFPageRef;
    CGRect _viewRect;
}

- (instancetype)initWithPDFDocument:(MGPDFDocument *)document atPage:(NSUInteger)page{
    CGRect viewRect = CGRectZero;
    if (document != nil) {
        //打开PDF文件
        MGPDFDocumentManager *manager = [MGPDFDocumentManager PDFDocumentManager];
        _PDFDocRef = [manager openWithPDFDocument:document error:nil];
        
        if (_PDFDocRef != NULL) {
            //加载指定PDF页面
            NSInteger pageCount = document.pageCount;
            if (page < 1) page = 1;
            if (page > pageCount) page = pageCount;
            _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page);
            CGPDFPageRetain(_PDFPageRef);
            
            //页面大小
            viewRect.size = [manager getPDFContentSizeWithDocument:document page:page error:nil];
        }
    }
    MGPDFContentPage *contentPage = [self initWithFrame:viewRect];
    return contentPage;
}

#pragma mark - override
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = NO;
        self.userInteractionEnabled = NO;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = UIViewAutoresizingNone;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc{
    CGPDFPageRelease(_PDFPageRef);
    _PDFPageRef = NULL;
    
    CGPDFDocumentRelease(_PDFDocRef);
    _PDFDocRef = NULL;
}

- (void)removeFromSuperview{
    self.layer.delegate = nil;
    
    [super removeFromSuperview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _viewRect = self.bounds;
}

/**
 设置后、占用内存变少
 */
+ (Class)layerClass{
    return [MGPDFContentTile class];
}

#pragma mark - CATiledLayerDelegate
- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context{
    MGPDFContentPage *contentPage = self; // Retain self

    //页面底色
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));

    //Quartz坐标系和UIView坐标系不一样所致，调整坐标系
    CGContextTranslateCTM(context, 0.0f, _viewRect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(_PDFPageRef, kCGPDFCropBox, _viewRect, 0, true));

    //绘制
    CGContextDrawPDFPage(context, _PDFPageRef);

    if (contentPage != nil) contentPage = nil; // Release self
}

@end
