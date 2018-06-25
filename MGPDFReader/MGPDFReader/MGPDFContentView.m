//
//  MGPDFContentView.m
//  MGPDFBrowserDemo
//
//  Created by mige on 2017/8/17.
//  Copyright © 2017年 mige. All rights reserved.
//

#import "MGPDFContentView.h"
#import "MGPDFContentPage.h"
#import "MGPDFDocumentManager.h"

#define ZOOM_FACTOR 2.0f
#define ZOOM_MAXIMUM 16.0f

@interface MGPDFContentView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView; //容器视图
@property (nonatomic, strong) MGPDFContentPage *contentPage; //pdf绘制层
@property (nonatomic, assign) NSUInteger currentPage; //当前页码
@property (nonatomic, strong) MGPDFDocument *document; //pdf文件

@end

@implementation MGPDFContentView

- (instancetype)initWithFrame:(CGRect)frame PDFDocument:(MGPDFDocument *)document atPage:(NSUInteger)page{
    self = [self initWithFrame:frame];
    if (self && document != nil) {
        _document = document;
        _currentPage = page;
        
        //设置视图
        [self setupView];
    }
    return self;
}

#pragma mark - override

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = NO;
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //更新视图frame
    [self updateFrames];
}

#pragma mark - 初始化视图
/**
 设置视图
 */
- (void)setupView{
    //创建容器视图
    [self createContainerView];
    
    //内容绘制
    [self addPDFContentPage];
}

/**
 创建容器视图
 */
- (void)createContainerView{
    _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    _containerView.autoresizesSubviews = NO;
    _containerView.userInteractionEnabled = YES;
    _containerView.contentMode = UIViewContentModeRedraw;
    _containerView.autoresizingMask = UIViewAutoresizingNone;
    _containerView.backgroundColor = [UIColor whiteColor];
    _containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _containerView.layer.shadowRadius = 4.0f;
    _containerView.layer.shadowOpacity = 1.0f;
    _containerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_containerView.bounds].CGPath;
    [self addSubview:_containerView];
    
    //添加点击手势事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onContentPageClickAction:)];
    [_containerView addGestureRecognizer:tap];
}

/**
 加载pdf绘制层
 */
- (void)addPDFContentPage{
    _contentPage = [[MGPDFContentPage alloc] initWithPDFDocument:_document atPage:_currentPage];
    [_containerView addSubview:_contentPage];
}

#pragma mark - Action
/**
 点击视图
 */
- (void)onContentPageClickAction:(UITapGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(PDFContentView:didClickContentAtPage:)]) {
            [self.delegate PDFContentView:self didClickContentAtPage:_currentPage];
        }
    }
}

#pragma mark - 视图更新
/**
 计算并更新容器视图frame
 */
- (void)updateFrames{
    MGPDFDocumentManager *manager = [MGPDFDocumentManager PDFDocumentManager];
    CGSize contentSize = [manager generatePDFContentPageSizeWithDocument:_document page:_currentPage targetSize:self.bounds.size error:nil];
    CGRect contentRect = CGRectMake((self.bounds.size.width - contentSize.width)/2, (self.bounds.size.height - contentSize.height)/2, contentSize.width, contentSize.height);
    _containerView.frame = contentRect;
    _contentPage.frame = _containerView.bounds;
}

@end
