//
//  MGPDFPagesView.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/19.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFPagesView.h"

@interface MGPDFPagesView ()

@property (nonatomic, strong) UIImageView *blurImgView; //毛玻璃视图
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;

@end

@implementation MGPDFPagesView

- (instancetype)init{
    self = [super init];
    if (self) {
       [self initSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
    
    //页码标签
    CGRect viewRect = self.bounds;
    viewRect.origin.x = 5;
    viewRect.size.width -= 10;
    _pageLabel = [[UILabel alloc] initWithFrame:viewRect];
    _pageLabel.font = [UIFont boldSystemFontOfSize:13];
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_pageLabel];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _pageLabel.frame = self.bounds;
}


/**
 颜色转图片
 */
- (UIImage*)createImageWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
