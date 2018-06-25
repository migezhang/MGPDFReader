//
//  MGPDFZoomView.h
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/9/5.
//  Copyright © 2017年 mige. All rights reserved.
//
/**
 *  缩放视图
 *
 *  @author mige
 */
#import <UIKit/UIKit.h>

@interface MGPDFZoomView : UIScrollView

@property (nonatomic, strong) UIView *contentView; //实际缩放的视图

/**
 更新视图
 */
- (void)updateZoomView;

@end
