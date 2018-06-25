//
//  MGPDFDocument.h
//  PDFBrowserDemo
//
//  Created by mige on 2017/8/15.
//  Copyright © 2017年 mige. All rights reserved.
//
/**
 *  PDF文件 Model
 *
 *  @author mige
 */
#import <Foundation/Foundation.h>

@interface MGPDFDocument : NSObject

@property (nonatomic, strong, readonly) NSString *fileName; //文件名
@property (nonatomic, strong, readonly) NSString *filePath; //文件路径
@property (nonatomic, strong, readonly) NSURL *fileURL; //文件路径
@property (nonatomic, strong, readonly) NSString *password; //密码
@property (nonatomic, assign, readonly) NSInteger fileSize; //文件大小
@property (nonatomic, strong, readonly) NSDate *fileDate; //文件日期
@property (nonatomic, assign, readonly) NSInteger pageCount; //文件页数

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)password;

@end
