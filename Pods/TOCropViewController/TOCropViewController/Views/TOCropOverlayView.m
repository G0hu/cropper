//
//  TOCropOverlayView.m
//
//  Copyright 2015-2017 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOCropOverlayView.h"

static const CGFloat kTOCropOverLayerCornerWidth = 20.0f;

@interface TOCropOverlayView ()

@property (nonatomic, strong) NSArray *horizontalGridLines;
@property (nonatomic, strong) NSArray *verticalGridLines;

@property (nonatomic, strong) NSArray *outerLineViews;   //top, right, bottom, left

@property (nonatomic, strong) NSArray *topLeftLineViews; //vertical, horizontal
@property (nonatomic, strong) NSArray *bottomLeftLineViews;
@property (nonatomic, strong) NSArray *bottomRightLineViews;
@property (nonatomic, strong) NSArray *topRightLineViews;

@property (nonatomic, strong) UIButton *stampButton;
@property (nonatomic, strong) UIImageView *stamp;
@property BOOL showStampButton;
@property CGFloat stampRatio;
@property BOOL showStamp;

- (void)setup;
- (void)layoutLines;

@end

@implementation TOCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    UIView *(^newLineView)(void) = ^UIView *(void){
        return [self createNewLineView];
    };
    
    _outerLineViews     = @[newLineView(), newLineView(), newLineView(), newLineView()];
    
    _topLeftLineViews   = @[newLineView(), newLineView()];
    _bottomLeftLineViews = @[newLineView(), newLineView()];
    _topRightLineViews  = @[newLineView(), newLineView()];
    _bottomRightLineViews = @[newLineView(), newLineView()];
    
    UIImage *stampImg = [UIImage imageNamed:@"stamp.png"];
    _stamp = [[UIImageView alloc] initWithImage: stampImg];
    _stampRatio = stampImg.size.height / stampImg.size.width;
    [_stamp setContentMode: UIViewContentModeScaleAspectFit];
    [_stamp setClipsToBounds: YES];
    [self addSubview: _stamp];
    
    _stampButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [_stampButton setImage:[UIImage imageNamed:@"remove_stamp.png"] forState:UIControlStateNormal];
    [_stampButton setBackgroundColor:UIColor.whiteColor];
    _stampButton.layer.cornerRadius = 5;
    [self addSubview: _stampButton];
    
    self.displayHorizontalGridLines = YES;
    self.displayVerticalGridLines = YES;
    self.showStampButton = YES;
    self.showStamp = YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    if (_outerLineViews)
    {
        [self setGridHidden:YES animated:NO];
        [self layoutLines];
        [self setGridHidden:NO animated:NO];
    }
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    if (_outerLineViews)
        [self layoutLines];
}

- (void)layoutLines
{
    CGSize boundsSize = self.bounds.size;
    
    //border lines
    for (NSInteger i = 0; i < 4; i++) {
        UIView *lineView = self.outerLineViews[i];
        
        CGRect frame = CGRectZero;
        switch (i) {
            case 0: frame = (CGRect){0,-1.0f,boundsSize.width+2.0f, 1.0f}; break; //top
            case 1: frame = (CGRect){boundsSize.width,0.0f,1.0f,boundsSize.height}; break; //right
            case 2: frame = (CGRect){-1.0f,boundsSize.height,boundsSize.width+2.0f,1.0f}; break; //bottom
            case 3: frame = (CGRect){-1.0f,0,1.0f,boundsSize.height+1.0f}; break; //left
        }
        
        lineView.frame = frame;
    }
    
    //corner liness
    NSArray *cornerLines = @[self.topLeftLineViews, self.topRightLineViews, self.bottomRightLineViews, self.bottomLeftLineViews];
    for (NSInteger i = 0; i < 4; i++) {
        NSArray *cornerLine = cornerLines[i];
        
        CGRect verticalFrame = CGRectZero, horizontalFrame = CGRectZero;
        switch (i) {
            case 0: //top left
                verticalFrame = (CGRect){-3.0f,-3.0f,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){0,-3.0f,kTOCropOverLayerCornerWidth,3.0f};
                break;
            case 1: //top right
                verticalFrame = (CGRect){boundsSize.width,-3.0f,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,-3.0f,kTOCropOverLayerCornerWidth,3.0f};
                
                if (_showStamp && _ratio.width < _ratio.height) {
                    [_stamp setFrame: [self computeStampFrame:verticalFrame horizontal:horizontalFrame bounds:self.bounds]];
                    _stamp.transform = CGAffineTransformMakeRotation(-M_PI/2);
                    if (_stampButton) {
                        [_stampButton setFrame: [self computeStampButtonFrame:_stamp.frame]];
                    }
                }
                break;
            case 2: //bottom right
                verticalFrame = (CGRect){boundsSize.width,boundsSize.height-kTOCropOverLayerCornerWidth,3.0f,kTOCropOverLayerCornerWidth+3.0f};
                horizontalFrame = (CGRect){boundsSize.width-kTOCropOverLayerCornerWidth,boundsSize.height,kTOCropOverLayerCornerWidth,3.0f};
                
                if (_showStamp && _ratio.height < _ratio.width) {
                    [_stamp setFrame: [self computeStampFrame:verticalFrame horizontal:horizontalFrame bounds:self.bounds]];
                    _stamp.transform = CGAffineTransformMakeRotation(0);
                    if (_stampButton) {
                        [_stampButton setFrame: [self computeStampButtonFrame:_stamp.frame]];
                    }
                }
                break;
            case 3: //bottom left
                verticalFrame = (CGRect){-3.0f,boundsSize.height-kTOCropOverLayerCornerWidth,3.0f,
                    kTOCropOverLayerCornerWidth};
                horizontalFrame = (CGRect){-3.0f,boundsSize.height,kTOCropOverLayerCornerWidth+3.0f,3.0f};
                break;
        }
        
        [cornerLine[0] setFrame:verticalFrame];
        [cornerLine[1] setFrame:horizontalFrame];
    }
    
    //grid lines - horizontal
    CGFloat thickness = 2.0f / [[UIScreen mainScreen] scale];
    NSInteger numberOfHLines = self.horizontalGridLines.count;
    CGFloat paddingH = (CGRectGetHeight(self.bounds) - (thickness*numberOfHLines)) / (numberOfHLines + 1);
    for (NSInteger i = 0; i < numberOfHLines; i++) {
        UIView *lineView = self.horizontalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.height = thickness;
        frame.size.width = CGRectGetWidth(self.bounds);
        frame.origin.y = (paddingH * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
    
    //grid lines - vertical
    NSInteger numberOfVLines = self.verticalGridLines.count;
    CGFloat paddingV = (CGRectGetWidth(self.bounds) - (thickness*numberOfVLines)) / (numberOfVLines + 1);
    for (NSInteger i = 0; i < numberOfVLines; i++) {
        UIView *lineView = self.verticalGridLines[i];
        CGRect frame = CGRectZero;
        frame.size.width = thickness;
        frame.size.height = CGRectGetHeight(self.bounds);
        frame.origin.x = (paddingV * (i+1)) + (thickness * i);
        lineView.frame = frame;
    }
}

- (void)setGridHidden:(BOOL)hidden animated:(BOOL)animated
{
    _gridHidden = hidden;
    
    if (animated == NO) {
        for (UIView *lineView in self.horizontalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        for (UIView *lineView in self.verticalGridLines) {
            lineView.alpha = hidden ? 0.0f : 1.0f;
        }
        
        return;
    }
    
    [UIView animateWithDuration:hidden?0.35f:0.2f animations:^{
        for (UIView *lineView in self.horizontalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
        
        for (UIView *lineView in self.verticalGridLines)
            lineView.alpha = hidden ? 0.0f : 1.0f;
    }];
}

#pragma mark - Property methods

- (void)setDisplayHorizontalGridLines:(BOOL)displayHorizontalGridLines {
    _displayHorizontalGridLines = displayHorizontalGridLines;
    
    [self.horizontalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    NSArray *lines;
    switch ((NSInteger) self.ratio.height) {
        case 2:
            lines = @[[self createNewLineView]];
            break;
        case 3:
            lines = @[[self createNewLineView], [self createNewLineView]];
            break;
        case 4:
            lines = @[[self createNewLineView], [self createNewLineView], [self createNewLineView]];
            break;
        case 5:
            lines = @[[self createNewLineView], [self createNewLineView], [self createNewLineView], [self createNewLineView]];
            break;
        default:
            lines = @[];
            break;
    }
    
    if (_displayHorizontalGridLines) {
        self.horizontalGridLines = lines;
    } else {
        self.horizontalGridLines = @[];
    }
    
    [self setNeedsDisplay];
}

- (void)setDisplayVerticalGridLines:(BOOL)displayVerticalGridLines {
    _displayVerticalGridLines = displayVerticalGridLines;
    
    [self.verticalGridLines enumerateObjectsUsingBlock:^(UIView *__nonnull lineView, NSUInteger idx, BOOL * __nonnull stop) {
        [lineView removeFromSuperview];
    }];
    
    NSArray *lines;
    switch ((NSInteger) self.ratio.width) {
        case 2:
            lines = @[[self createNewLineView]];
            break;
        case 3:
            lines = @[[self createNewLineView], [self createNewLineView]];
            break;
        case 4:
            lines = @[[self createNewLineView], [self createNewLineView], [self createNewLineView]];
            break;
        case 5:
            lines = @[[self createNewLineView], [self createNewLineView], [self createNewLineView], [self createNewLineView]];
            break;
        default:
            lines = @[];
            break;
    }
    
    if (_displayVerticalGridLines) {
        self.verticalGridLines = lines;
    } else {
        self.verticalGridLines = @[];
    }
    
    [self setNeedsDisplay];
}

- (void)setGridHidden:(BOOL)gridHidden
{
    [self setGridHidden:gridHidden animated:NO];
}

- (void)setRatio:(CGSize)ratio
{
    _ratio = ratio;
    [self setDisplayVerticalGridLines:_displayVerticalGridLines];
    [self setDisplayHorizontalGridLines:_displayHorizontalGridLines];
}

- (void)setStampButtonTarget:(id)target action:(SEL)action
{
    [_stampButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeStamp:(BOOL)removeStamp removeButton:(BOOL)removeButton
{
    _showStampButton = !removeButton;
    _showStamp = !removeStamp;
    
    if (removeButton) {
        _stampButton.hidden = YES;
    } else {
        _stampButton.hidden = NO;
    }
    
    if (removeStamp) {
        _stamp.hidden = YES;
    } else {
        _stamp.hidden = NO;
    }
}

- (BOOL)stampIsDisplayed
{
    return _showStamp;
}

- (CGRect)computeStampFrame:(CGRect)verticalFrame horizontal:(CGRect)horizontalFrame bounds:(CGRect)bounds
{
    CGRect stampFrame = CGRectZero;

    if (_ratio.height < _ratio.width) {
        CGFloat stampWidth = CGRectGetWidth(bounds) / (4.0 * _ratio.width);
        stampFrame.size = CGSizeMake(stampWidth, stampWidth * _stampRatio);
        stampFrame.origin = CGPointMake(CGRectGetMinX(verticalFrame) - CGRectGetWidth(stampFrame) - 3,
                                        CGRectGetMinY(horizontalFrame) - CGRectGetHeight(stampFrame) - 3);
    } else {
        CGFloat stampHeight = CGRectGetHeight(bounds) / (4.0 * _ratio.height);
        stampFrame.size = CGSizeMake(stampHeight * _stampRatio, stampHeight);
        stampFrame.origin = CGPointMake(CGRectGetMinX(verticalFrame) - CGRectGetWidth(stampFrame) - 3,
                                        CGRectGetMaxY(horizontalFrame) + 3);
    }
    
    return stampFrame;
}

- (CGRect)computeStampButtonFrame:(CGRect)stampFrame
{
    CGRect stampButtonFrame = CGRectZero;
    stampButtonFrame.size = CGSizeMake(10, 10);
    
    if (_ratio.height < _ratio.width) {
        stampButtonFrame.origin = CGPointMake(CGRectGetMinX(stampFrame) - 10, CGRectGetMinY(stampFrame) - 10);
    } else {
        stampButtonFrame.origin = CGPointMake(CGRectGetMinX(stampFrame) - 10, CGRectGetMaxY(stampFrame) + 10);
    }
    
    return stampButtonFrame;
}

#pragma mark - Private methods

- (nonnull UIView *)createNewLineView {
    UIView *newLine = [[UIView alloc] initWithFrame:CGRectZero];
    newLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:newLine];
    return newLine;
}

@end
