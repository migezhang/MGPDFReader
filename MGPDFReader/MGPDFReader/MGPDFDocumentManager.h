//
//  MGPDFDocumentManager.h
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/18.
//  Copyright © 2017年 mige. All rights reserved.
//
/**
 *  PDF文件管理类
 *
 *  @author mige
 */
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MGPDFDocument.h"

@interface MGPDFDocumentManager : NSObject

+ (instancetype)PDFDocumentManager;

/**
 校验PDF文件是否加密
 
 @param filePath PDF文件路径
 @return 是否加密
 */
- (BOOL)checkPDFDocumentIsEncryptedWithFilePath:(NSString *)filePath;

/**
 打开PDF文件

 @param document PDF文件
 @param error 错误
 @return 返回PDF文件内容索引
 */
- (CGPDFDocumentRef)openWithPDFDocument:(MGPDFDocument *)document error:(NSError **)error;

/**
 关闭PDF文件
 
 @param pdfDocumentRef PDF文件内容索引
 */
- (void)closePDFDocumentWithDocumentRef:(CGPDFDocumentRef)pdfDocumentRef;

/**
 获取指定页面的大小

 @param document PDF文件
 @param page 页码
 @param error 错误
 @return 页面大小
 */
- (CGSize)getPDFContentSizeWithDocument:(MGPDFDocument *)document page:(NSUInteger)page error:(NSError **)error;


/**
 按比例生成PDF内容页面的大小

 @param document PDF文件
 @param page 页码
 @param targetSize 目标大小
 @param error 错误
 @return 转换后实际大小
 */
- (CGSize)generatePDFContentPageSizeWithDocument:(MGPDFDocument *)document page:(NSUInteger)page targetSize:(CGSize)targetSize error:(NSError **)error;

@end
