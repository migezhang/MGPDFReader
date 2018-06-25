//
//  MGPDFContentPage.h
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/17.
//  Copyright © 2017年 mige. All rights reserved.
//
/**
 *  PDF内容绘制层
 *
 *  @author mige
 */
#import <UIKit/UIKit.h>
#import "MGPDFDocument.h"

@interface MGPDFContentPage : UIView

/**
 初始化

 @param document PDF文件对象
 @param page 绘制的页码
 */
- (instancetype)initWithPDFDocument:(MGPDFDocument *)document atPage:(NSUInteger)page;

@end
