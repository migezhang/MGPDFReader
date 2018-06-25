//
//  MGPDFContentView.h
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/17.
//  Copyright © 2017年 mige. All rights reserved.
//
/**
 *  PDF内容视图
 *
 *  @author mige
 */
#import <UIKit/UIKit.h>
#import "MGPDFDocument.h"

@protocol MGPDFContentViewDelegate;

@interface MGPDFContentView : UIView

@property (nonatomic, weak) id<MGPDFContentViewDelegate> delegate;

/**
 初始化

 @param frame frame
 @param document PDF文件对象
 @param page 绘制的页码
 */
- (instancetype)initWithFrame:(CGRect)frame PDFDocument:(MGPDFDocument *)document atPage:(NSUInteger)page;

@end

@protocol MGPDFContentViewDelegate <NSObject>

@optional
- (void)PDFContentView:(MGPDFContentView *)contentView didClickContentAtPage:(NSUInteger)page;

@end
