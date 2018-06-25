//
//  MGPDFReaderView.m
//  MGPDFReader
//
//  Created by mige on 2018/5/21.
//  Copyright © 2018年 mige.com. All rights reserved.
//

#import "MGPDFReaderView.h"
#import "MGPDFZoomView.h"
#import "MGPDFDocumentManager.h"
#import "MGPDFContentView.h"
#import "MGPDFPagesView.h"

#define M_PageInterval 15 //页面间距
#define M_PagesViewHeight 22 //页码视图高度

@interface MGPDFReaderView () <UIScrollViewDelegate, MGPDFContentViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView; //滑动视图
@property (nonatomic, strong) MGPDFZoomView *zoomView; //缩放视图
@property (nonatomic, strong) MGPDFPagesView *pagesView; //页码视图

@property (nonatomic, assign) CGRect viewRect; //视图Rect，用于记录当前视图真实frame

@property (nonatomic, assign) CGSize pageSize; //页码大小
@property (nonatomic, strong) NSMutableDictionary *visibleViewsDict; //可见视图字典

@end

@implementation MGPDFReaderView

@synthesize currentPage = _currentPage;

- (instancetype)initWithFrame:(CGRect)frame PDFDocument:(MGPDFDocument *)document{
    self = [self initWithFrame:frame];
    if (self) {
        _viewRect = self.frame;
        _document = document;
        _visibleViewsDict = [NSMutableDictionary dictionaryWithCapacity:0];
        _currentPage = 1;
        
        //初始化视图
        [self initView];
    }
    return self;
}

#pragma mark - override

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.autoresizesSubviews = NO;
        self.clipsToBounds = YES;
        self.contentMode = UIViewContentModeRedraw;
        self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    //更新视图frame
    [self updateFrame];
    
    if (CGRectEqualToRect(_viewRect, self.frame) == false) {
        _viewRect = self.frame;
        
        //滑动到当前页
        [self scrollToPage:_currentPage];
    }
}

#pragma mark - 初始化视图
/**
 初始化视图
 */
- (void)initView{
    //创建滑动视图
    [self createScrollView];
    
    //创建页码视图
    [self createPagesView];
    
    //更新内容视图size
    [self updateContentViewSize];
    
}

/**
 创建滑动视图
 */
- (void)createScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self updateScrollContentSize];
    
    //添加缩放控制
    _zoomView = [[MGPDFZoomView alloc] initWithFrame:self.bounds];
    _zoomView.contentView = _scrollView;
    _zoomView.backgroundColor = [UIColor clearColor];
    [_zoomView addSubview:_scrollView];
    [self addSubview:_zoomView];
}

/**
 创建页码视图
 */
- (void)createPagesView{
    _pagesView = [[MGPDFPagesView alloc] init];
    [self addSubview:_pagesView];
}

#pragma mark - PDF浏览
/**
 显示PDF指定页码
 */
- (void)showPDFDocumentAtPage:(NSInteger)page{
    if (page < 1 || page > _document.pageCount) return;
    
    if (page != _currentPage) {
        _currentPage = page;
        
        //滑动到指定页码
        [self scrollToPage:page];
    }
}

/**
 上一页
 */
- (void)incrementPDFDocumentPage{
    NSInteger page = _currentPage + 1;
    if (page >= 1 && page <= _document.pageCount) {
        [self showPDFDocumentAtPage:page];
    }
}

/**
 下一页
 */
- (void)decrementPDFDocumentPage{
    NSInteger page = _currentPage - 1;
    if (page >= 1 && page <= _document.pageCount) {
        [self showPDFDocumentAtPage:page];
    }
}

/**
 滑动到指定页码
 */
- (void)scrollToPage:(NSInteger)page{
    CGFloat pageWidth = [self getPageViewWidth];
    CGFloat offsetX = (page - 1) * pageWidth;
    CGPoint contentOffset = CGPointMake(offsetX, 0);
    [self.scrollView setContentOffset:contentOffset animated:NO];
    
    //更新内容布局
    [self layoutContentViews:self.scrollView];
    
    //设置页码
    [self configPagesData];
}

/**
 更新文档
 */
- (void)updateDocument:(MGPDFDocument *)document{
    _document = document;
    _currentPage = 1;
    
    //移除全部视图
    for (UIView *contentView in _visibleViewsDict.allValues) {
        [contentView removeFromSuperview];
    }
    [_visibleViewsDict removeAllObjects];
    
    //更新内容视图size
    [self updateContentViewSize];
    
    //更新滑动视图contentSize
    [self updateScrollContentSize];
    
    //滑动到页面
    [self scrollToPage:_currentPage];
}

#pragma mark - PDF内容视图
/**
 布局内容视图
 */
- (void)layoutContentViews:(UIScrollView *)scrollView{
    CGFloat viewWidth = scrollView.bounds.size.width;
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat pageWidth = [self getPageViewWidth];
    
    NSInteger minPage = floorf(offsetX / pageWidth) - 1;
    NSInteger maxPage = ceil((offsetX + viewWidth) / pageWidth) + 1;
    
    if (minPage < 1) {
        minPage = 1;
    }
    
    if (maxPage > self.document.pageCount) {
        maxPage = self.document.pageCount;
    }
    
//    NSLog(@"--->>> allKeys = %@", self.visibleViewsDict.allKeys);
    
    for (NSNumber *key in self.visibleViewsDict.allKeys) {
        NSInteger page = [key integerValue];
        UIView *contentView = [self.visibleViewsDict objectForKey:key];
        if (page < minPage || page > maxPage) {
            [contentView removeFromSuperview];
            [self.visibleViewsDict removeObjectForKey:key];
        }
    }
    
    for (NSInteger page = minPage; page <= maxPage; page++) {
        if ([self.visibleViewsDict.allKeys containsObject:@(page)] == NO) {
            [self addContentViewWithPage:page];
        }
    }
}

/**
 添加PDF内容视图
 */
- (void)addContentViewWithPage:(NSInteger)page{
    CGRect frame = [self getContentViewFrameWithPage:page];
    MGPDFContentView *contentView = [[MGPDFContentView alloc] initWithFrame:frame PDFDocument:self.document atPage:page];
    contentView.delegate = self;
    [self.scrollView addSubview:contentView];
    [self.visibleViewsDict setObject:contentView forKey:[NSNumber numberWithInteger:page]];
}

/**
 获取PDF内容视图的frame
 */
- (CGRect)getContentViewFrameWithPage:(NSInteger)page{
    CGRect viewRect = CGRectZero;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGFloat interval = M_PageInterval;
    
    //大小
    viewRect.size = self.pageSize;
    
    //位置
    CGFloat xPoint = interval + ((viewRect.size.width + interval) * (page - 1));
    CGFloat yPoint = (scrollViewSize.height - viewRect.size.height) / 2;
    viewRect.origin = CGPointMake(xPoint, yPoint);
    
    return viewRect;
}

/**
 获取页码实际宽度
 */
- (CGFloat)getPageViewWidth{
    CGFloat pageWidth = self.pageSize.width + M_PageInterval;
    return pageWidth;
}

#pragma mark - 页码
/**
 设置页码数据
 */
- (void)configPagesData{
    NSUInteger page = [self getCurrentPage];
    NSString *pageStr = [NSString stringWithFormat:@"%ld/%ld", page, _document.pageCount];
    _pagesView.pageLabel.text = pageStr;
    [self updatePagesViewFrame];
}

/**
 获取当前页码
 */
- (NSUInteger)getCurrentPage{
    CGFloat viewWidth = self.scrollView.bounds.size.width;
    CGFloat offsetX = self.scrollView.contentOffset.x;
    CGFloat pageWidth = [self getPageViewWidth];
    NSInteger page = (offsetX + viewWidth) / pageWidth;
    if (page < 1 || offsetX == 0) page = 1;
    if (page > self.document.pageCount) page = self.document.pageCount;
    return page;
}

/**
 返回当前页码
 */
- (NSUInteger)currentPage{
    return [self getCurrentPage];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = self.scrollView.contentOffset.x;
    if (offsetX >= 0 && offsetX <= scrollView.contentSize.width) {
        //更新内容布局
        [self layoutContentViews:scrollView];
        
        //设置页码
        [self configPagesData];
        
        //设置代理
        if (self.delegate && [self.delegate respondsToSelector:@selector(PDFReaderView:didScrollPage:)]) {
            [self.delegate PDFReaderView:self didScrollPage:scrollView];
        }
    }
}

#pragma mark - MGPDFContentViewDelegate
- (void)PDFContentView:(MGPDFContentView *)contentView didClickContentAtPage:(NSUInteger)page{
    if (self.delegate && [self.delegate respondsToSelector:@selector(PDFReaderView:didPDFContentClickAtPage:)]) {
        [self.delegate PDFReaderView:self didPDFContentClickAtPage:page];
    }
}

#pragma mark - 更新frame
/**
 更新frame
 */
- (void)updateFrame{
    //更新内容视图frame
    _scrollView.frame = self.bounds;
    [self updateContentViewsFrame];
    
    _zoomView.frame = self.bounds;
    [_zoomView updateZoomView];
    
    //更新内容视图size
    [self updateContentViewSize];
    
    //更新滑动视图contentSize
    [self updateScrollContentSize];
    
    //更新页码视图
    [self updatePagesViewFrame];
}

/**
 更新内容视图size
 */
- (void)updateContentViewSize{
    CGSize viewSize = CGSizeZero;
    CGSize scrollSize = self.scrollView.bounds.size;
    CGFloat interval = M_PageInterval;
    CGSize targetSize = CGSizeMake(scrollSize.width - interval * 2, scrollSize.height - interval * 2);
    if (self.document.pageCount == 1) {
        viewSize = targetSize;
    } else {
        MGPDFDocumentManager *manager = [MGPDFDocumentManager PDFDocumentManager];
        CGSize pageSize = [manager generatePDFContentPageSizeWithDocument:self.document page:1 targetSize:targetSize error:nil];
        viewSize = pageSize;
    }
    self.pageSize = viewSize;
}

/**
 更新滑动视图contentSize
 */
- (void)updateScrollContentSize{
    CGFloat contentWidth = 0;
    CGFloat pageWidth = [self getPageViewWidth];
    for (NSInteger page = 1; page <= self.document.pageCount; page++) {
        contentWidth += pageWidth;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth + M_PageInterval, self.scrollView.frame.size.height);
}

/**
 更新内容视图frame
 */
- (void)updateContentViewsFrame{
    for (NSNumber *key in self.visibleViewsDict.allKeys) {
        NSInteger page = [key integerValue];
        UIView *contentView = [self.visibleViewsDict objectForKey:key];
        CGRect frame = [self getContentViewFrameWithPage:page];
        contentView.frame = frame;
        [contentView setNeedsLayout];
    }
}

/**
 更新页码视图布局
 */
- (void)updatePagesViewFrame{
    CGSize viewSize = self.bounds.size;
    CGSize maxPageSize = CGSizeMake(viewSize.width - M_PageInterval * 2, M_PagesViewHeight);
    NSString *pageStr = _pagesView.pageLabel.text;
    CGSize textSize = [pageStr boundingRectWithSize:maxPageSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_pagesView.pageLabel.font} context:nil].size;
    CGFloat pagesWidth = textSize.width + 10;
    if (pagesWidth < 45) {
        pagesWidth = 45;
    } else if (pagesWidth > maxPageSize.width) {
        pagesWidth = maxPageSize.width;
    }
    _pagesView.frame = CGRectMake((viewSize.width - pagesWidth)/2, viewSize.height - 40, pagesWidth, M_PagesViewHeight);
}

@end
