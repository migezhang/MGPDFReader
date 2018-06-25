//
//  MGPDFDocumentManager.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/18.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFDocumentManager.h"

@implementation MGPDFDocumentManager

+ (instancetype)PDFDocumentManager{
    MGPDFDocumentManager *manager = [[MGPDFDocumentManager alloc] init];
    return manager;
}

/**
 校验PDF文件是否加密
 */
- (BOOL)checkPDFDocumentIsEncryptedWithFilePath:(NSString *)filePath{
    BOOL isEncrypted = NO;
    if (filePath.length > 0) {
        CFURLRef docURLRef = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath];
        CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(docURLRef);
        if (thePDFDocRef != NULL) {
            if (CGPDFDocumentIsEncrypted(thePDFDocRef) == TRUE) {
                //空密码代表不加密
                if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE) {
                    isEncrypted = YES;
                }
            }
            CGPDFDocumentRelease(thePDFDocRef);
        }
    }
    return isEncrypted;
}

/**
 打开PDF文件
 */
- (CGPDFDocumentRef)openWithPDFDocument:(MGPDFDocument *)document error:(NSError **)error{
    CGPDFDocumentRef thePDFDocRef = NULL;
    NSString *password = document.password;
    NSURL *fileURL = document.fileURL;
    NSError *err = nil;
    if (fileURL != nil) {
        //创建PDF文件内容索引
        CFURLRef docURLRef = (__bridge CFURLRef)fileURL;
        thePDFDocRef = CGPDFDocumentCreateWithURL(docURLRef);
        if (thePDFDocRef != NULL) {
            //判断是否加密
            bool isEncrypted = CGPDFDocumentIsEncrypted(thePDFDocRef);
            if (isEncrypted == TRUE) {
                //解密
                if (CGPDFDocumentUnlockWithPassword(thePDFDocRef, "") == FALSE) {
                    if ((password != nil) && (password.length > 0)) {
                        char text[128];
                        [password getCString:text maxLength:126 encoding:NSUTF8StringEncoding];
                        bool isUnlock = CGPDFDocumentUnlockWithPassword(thePDFDocRef, text);
                        if (isUnlock == FALSE) {
                            err = [NSError errorWithDomain:@"文件打开失败，解密失败" code:-1 userInfo:nil];
                        }
                    } else {
                        err = [NSError errorWithDomain:@"文件打开失败，密码为空" code:-1 userInfo:nil];
                    }
                }
                
                //解密失败，则释放内容索引
                if (CGPDFDocumentIsUnlocked(thePDFDocRef) == FALSE) {
                    CGPDFDocumentRelease(thePDFDocRef);
                    thePDFDocRef = NULL;
                }
            }
        }
    } else {
        err = [NSError errorWithDomain:@"文件路径为空" code:-1 userInfo:nil];
    }
    
    if (error != NULL) {
        *error = err;
    }
    return thePDFDocRef;
}


/**
 关闭PDF文件
 */
- (void)closePDFDocumentWithDocumentRef:(CGPDFDocumentRef)pdfDocumentRef{
    CGPDFDocumentRelease(pdfDocumentRef);
    pdfDocumentRef = NULL;
}

/**
 获取指定页面的大小
 */
- (CGSize)getPDFContentSizeWithDocument:(MGPDFDocument *)document page:(NSUInteger)page error:(NSError **)error{
    CGSize pageSize = CGSizeZero;
    CGPDFDocumentRef pdfDocumentRef = [self openWithPDFDocument:document error:error];
    if (pdfDocumentRef != NULL) {
        //打开指定页面
        NSInteger pageCount = document.pageCount;
        if (page < 1) page = 1;
        if (page > pageCount) page = pageCount;
        CGPDFPageRef pdfPageRef = CGPDFDocumentGetPage(pdfDocumentRef, page);
        
        //获取页面大小
        if (pdfPageRef != NULL) {
            CGPDFPageRetain(pdfPageRef);
            CGRect cropBoxRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFCropBox);
            CGRect mediaBoxRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFMediaBox);
            CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
            int pageAngle = CGPDFPageGetRotationAngle(pdfPageRef);
            NSInteger pageWidth = 0;
            NSInteger pageHeight = 0;
            switch (pageAngle) {
                default:
                    // 0 and 180 degrees
                case 0: case 180:
                {
                    pageWidth = effectiveRect.size.width;
                    pageHeight = effectiveRect.size.height;
                    break;
                }
                    // 90 and 270 degrees
                case 90: case 270:
                {
                    pageWidth = effectiveRect.size.height;
                    pageHeight = effectiveRect.size.width;
                    break;
                }
            }
            if (pageWidth % 2) pageWidth--; if (pageHeight % 2) pageHeight--; // Even
            pageSize = CGSizeMake(pageWidth, pageHeight);
            
            //释放引用
            CGPDFPageRelease(pdfPageRef); pdfPageRef = NULL;
            CGPDFDocumentRelease(pdfDocumentRef); pdfDocumentRef = NULL;
        }
    }
    return pageSize;
}

/**
 按比例生成PDF内容页面的大小
 */
- (CGSize)generatePDFContentPageSizeWithDocument:(MGPDFDocument *)document page:(NSUInteger)page targetSize:(CGSize)targetSize error:(NSError **)error{
    CGSize pageSize = CGSizeZero;
    CGSize contentSize = [self getPDFContentSizeWithDocument:document page:page error:error];
    CGFloat contentW = contentSize.width;
    CGFloat contentH = contentSize.height;
    CGFloat targetW = targetSize.width;
    CGFloat targetH = targetSize.height;
    CGFloat pageW = pageSize.width;
    CGFloat pageH = pageSize.height;
    if (contentH > contentW) {
        pageW = contentW / (contentH / targetH);
        pageH = targetH;
        if (pageW > targetW) {
            pageH = targetH / (pageW / targetW);
            pageW = targetW;
        }
    } else {
        pageW = targetW;
        pageH = contentH / (contentW / targetW);
        if (pageH > targetH) {
            pageW = targetW / (pageH / targetH);
            pageH = targetH;
        }
    }
    pageSize = CGSizeMake(pageW, pageH);
    return pageSize;
}

@end
