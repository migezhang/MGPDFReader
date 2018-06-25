//
//  MGPDFDocument.m
//  PDFBrowserDemo
//
//  Created by mige on 2017/8/15.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFDocument.h"
#import "MGPDFDocumentManager.h"

@implementation MGPDFDocument

- (instancetype)initWithFilePath:(NSString *)filePath password:(NSString *)password{
    self = [super init];
    if (self) {
        _filePath = filePath;
        if (filePath != nil) {
            _fileURL = [NSURL fileURLWithPath:filePath];
        }
        _password = password;
        _fileName = [_filePath lastPathComponent];
        
        MGPDFDocumentManager *manager = [MGPDFDocumentManager PDFDocumentManager];
        CGPDFDocumentRef thePDFDocRef = [manager openWithPDFDocument:self error:nil];
        if (thePDFDocRef != NULL) {
            _pageCount = CGPDFDocumentGetNumberOfPages(thePDFDocRef);
            [manager closePDFDocumentWithDocumentRef:thePDFDocRef];
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:_filePath error:NULL];
        _fileDate = [fileAttributes objectForKey:NSFileModificationDate];
        _fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];
    }
    return self;
}



@end
