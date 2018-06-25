//
//  MGPDFZoomView.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/9/5.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFZoomView.h"

#define ZOOM_FACTOR 2.0f
#define ZOOM_MAXIMUM 8.0f

@interface MGPDFZoomView () <UIScrollViewDelegate>

@end

@implementation MGPDFZoomView {
    CGFloat realMaximumZoom;
    CGFloat tempMaximumZoom;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        self.clipsToBounds = YES;
        
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delaysContentTouches = NO;
        self.scrollsToTop = NO;
        self.delegate = self;
    }
    return self;
}

- (void)setContentView:(UIView *)contentView{
    _contentView = contentView;
    
    [self updateZoomView];
}

/**
 更新视图
 */
- (void)updateZoomView{
    self.contentSize = _contentView.bounds.size;
    [self centerScrollViewContent];
    
    [self updateMinimumMaximumZoom];
    self.zoomScale = self.minimumZoomScale;
}

#pragma mark - 视图缩放
static inline CGFloat zoomScaleThatFits(CGSize target, CGSize source){
    CGFloat w_scale = (target.width / source.width);
    CGFloat h_scale = (target.height / source.height);
    CGFloat scale = (w_scale < h_scale) ? w_scale : h_scale;
    return scale;
}

- (void)updateMinimumMaximumZoom{
    CGFloat zoomScale = zoomScaleThatFits(self.bounds.size, self.contentView.bounds.size);
    self.minimumZoomScale = zoomScale;
    self.maximumZoomScale = (zoomScale * ZOOM_MAXIMUM);
    realMaximumZoom = self.maximumZoomScale;
    tempMaximumZoom = (realMaximumZoom * ZOOM_FACTOR);
}

- (void)centerScrollViewContent{
    CGFloat iw = 0.0f;
    CGFloat ih = 0.0f;
    CGSize boundsSize = self.bounds.size;
    CGSize contentSize = self.contentSize;
    if (contentSize.width < boundsSize.width) iw = ((boundsSize.width - contentSize.width) * 0.5f);
    if (contentSize.height < boundsSize.height) ih = ((boundsSize.height - contentSize.height) * 0.5f);
    UIEdgeInsets insets = UIEdgeInsetsMake(ih, iw, ih, iw);
    BOOL isInsetsEqual = UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets);
    if (isInsetsEqual == NO) {
      self.contentInset = insets;
    }
}
#pragma mark - UIScrollViewDelegate methods
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (self.zoomScale > realMaximumZoom)  {
        [self setZoomScale:realMaximumZoom animated:YES];
        self.maximumZoomScale = realMaximumZoom;
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self centerScrollViewContent];
}

@end
