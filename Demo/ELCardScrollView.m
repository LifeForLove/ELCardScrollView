//
//  ELCardScrollView.m
//  Demo
//
//  Created by ZCGC on 2019/9/16.
//  Copyright © 2019 getElementByYou. All rights reserved.
//

#import "ELCardScrollView.h"
#import "ELWeakTimer.h"
#import <UIImageView+WebCache.h>
#define Tags 100

@class ELCardView;
@protocol ELCardViewDelegate <NSObject>

- (void)cardViewTapGes:(UITapGestureRecognizer *)ges;

- (void)cardViewTouchBegin;

- (void)cardViewTouchChangeWithoffsetX:(CGFloat)offsetX;

- (void)cardViewTouchEndWithoffsetX:(CGFloat)offsetX;

@end

@interface ELCardView : UIImageView <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint firstTouchPoint;

@property (nonatomic, assign) CGFloat imageMargin;

@property (nonatomic, weak) id <ELCardViewDelegate> delegate;

@property (nonatomic, weak) id source;

- (instancetype) initWithFrame:(CGRect)frame imageMargin:(CGFloat)imageMargin source:(id)source;
@end


@interface ELCardScrollView ()<ELCardViewDelegate>

@property (nonatomic, strong) NSArray * pointArray;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) ELCardScrollViewConfigModel * configModel;

@end


@implementation ELCardScrollView

- (instancetype)initWithFrame:(CGRect)frame configModel:(nonnull ELCardScrollViewConfigModel *)configModel
{
    self = [super initWithFrame:frame];
    if (self) {
        self.configModel = configModel;
        [self createView];
        [self createTimer];
    }
    return self;
}

- (void)createTimer {
    if (!self.timer) {
        self.timer = [ELWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timerRun) userInfo:@{} repeats:YES];
    }
}

- (void)timerRun {
    ELCardView * firtstView = [self viewWithTag:Tags];
    [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        firtstView.frame = CGRectMake(- firtstView.frame.size.width * 2, firtstView.frame.origin.y, firtstView.frame.size.width, firtstView.frame.size.height);
        for (int i = 1; i < self.configModel.imageArray.count; i++) {
            ELCardView * view = [self viewWithTag:i + Tags];
            
            CGFloat scale = 1;
            CGFloat x = scale * (self.configModel.imageMargin * 3);
            CGFloat y = scale * self.configModel.imageMargin;
            CGFloat w = scale * self.configModel.imageMargin * 2;
            CGFloat h = scale * self.configModel.imageMargin * 2;
            
            CGRect rect = CGRectFromString(self.pointArray[i]);
            view.frame = CGRectMake(rect.origin.x - x, rect.origin.y - y, rect.size.width + w, rect.size.height + h);
        }
        
    } completion:^(BOOL finished) {
        [self cardViewTouchEndWithoffsetX:self.configModel.imageMargin * 3];
    }];
}


- (void)createView {
    for (int i = 0; i < self.configModel.imageArray.count; i++) {
        id obj = self.configModel.imageArray[i];
        ELCardView * view = [[ELCardView alloc]initWithFrame:CGRectZero imageMargin:self.configModel.imageMargin source:obj];
        view.delegate = self;
        view.tag = i + Tags;
        if (i == 0) {
            [self addSubview:view];
        } else {
            UIView * lastView = [self viewWithTag:i + Tags -1];
            [self insertSubview:view belowSubview:lastView];
        }
        view.userInteractionEnabled = i == 0 ? YES : NO;
    }
    self.clipsToBounds = YES;
}

- (void)cardViewTouchChangeWithoffsetX:(CGFloat)offsetX {
    
    for (int i = 1; i < self.configModel.imageArray.count; i++) {
        ELCardView * view = [self viewWithTag:i + Tags];
        
        CGFloat scale = offsetX/view.bounds.size.width;
        CGFloat x = scale * (self.configModel.imageMargin * 3);
        CGFloat y = scale * self.configModel.imageMargin;
        CGFloat w = scale * self.configModel.imageMargin * 2;
        CGFloat h = scale * self.configModel.imageMargin * 2;

        CGRect rect = CGRectFromString(self.pointArray[i]);
        view.frame = CGRectMake(rect.origin.x - x, rect.origin.y - y, rect.size.width + w, rect.size.height + h);
    }
}

- (void)cardViewTouchBegin {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)cardViewTouchEndWithoffsetX:(CGFloat)offsetX {
    
    if (offsetX < self.configModel.imageMargin * 3) {
        [self createTimer];
        return;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof ELCardView * _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:[ELCardView class]]) {
            if (view.tag == Tags) {
                view.tag = self.configModel.imageArray.count - 1 + Tags;
            } else {
                view.tag = view.tag - 1;
            }
        }
    }];

    UIView * lastView;
    for (int i = 0; i < self.configModel.imageArray.count; i++) {
        ELCardView * view = [self viewWithTag:i + Tags];
        if (i == 0) {
            lastView = view;
        } else {
            [self insertSubview:view belowSubview:lastView];
            lastView = view;
        }
        
        view.userInteractionEnabled = i == 0 ? YES : NO;

        //第一张放到最后面
        [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
            NSString * rect = self.pointArray[i];
            view.frame = CGRectFromString(rect);
        } completion:^(BOOL finished) {
            [self createTimer];
        }];
    }
}

- (void)cardViewTapGes:(UITapGestureRecognizer *)ges {
    if (self.configModel.SelectBlock) {
        ELCardView * cardView = (ELCardView *)ges.view;
        id source = cardView.source;
        NSInteger index = [self.configModel.imageArray indexOfObject:source];
        self.configModel.SelectBlock(index);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.pointArray.count > 0) {
        return;
    }
    NSMutableArray * pointArr = [NSMutableArray array];
    CGFloat origin_w = self.bounds.size.width;
    CGFloat origin_h = self.bounds.size.height;
    CGFloat margin = self.configModel.imageMargin;
    for (int a = 0; a < self.configModel.imageArray.count; a++) {
        CGFloat item_w = origin_w - (a + 1) * margin * 2 - (self.configModel.imageArray.count - 1) * margin;
        CGFloat item_h = origin_h - (a + 1) * margin * 2;
        CGFloat item_x = margin * (a + 1) + (a) * margin * 2;
        CGFloat item_y = margin * (a + 1);
        CGRect rect = CGRectMake(item_x, item_y, item_w, item_h);
        [pointArr addObject:NSStringFromCGRect(rect)];
        
        UIView * view = [self viewWithTag:a + Tags];
        view.frame = rect;
    }
    self.pointArray = pointArr;
}

@end


@implementation ELCardView

- (instancetype) initWithFrame:(CGRect)frame imageMargin:(CGFloat)imageMargin source:(id)source
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageMargin = imageMargin;
        self.source = source;
        
        if ([source isKindOfClass:[NSString class]] && [source hasPrefix:@"http"]) {
            [self sd_setImageWithURL:[NSURL URLWithString:source]];
        } else if ([source isKindOfClass:[UIImage class]]) {
            self.image = source;
        }
        //图片
        self.backgroundColor = [UIColor whiteColor];
        //添加滑动手势
        UIPanGestureRecognizer *panGestue = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGes:)];
        panGestue.delegate = self;
        [self addGestureRecognizer:panGestue];
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGes:)];
        [self addGestureRecognizer:tapGes];
    }
    return self;
}

- (void)tapGes:(UITapGestureRecognizer *)ges {
    [self.delegate cardViewTapGes:ges];
}

-  (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer  {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint translation = [gestureRecognizer velocityInView:gestureRecognizer.view];
        if (translation.x > 0) {
            //右滑
            return NO;
        }else {
            //左滑
            return YES;
        }
    } else {
        return YES;
    }
}

- (void)panGes:(UIPanGestureRecognizer *)ges {
    CGPoint trnaslation = [ges translationInView:ges.view];
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.firstTouchPoint = trnaslation;
            [self.delegate cardViewTouchBegin];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat offset_x = trnaslation.x - self.firstTouchPoint.x;
            if (offset_x > self.imageMargin) {
                break;
            }
            self.frame = CGRectMake(offset_x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
            [self.delegate cardViewTouchChangeWithoffsetX:abs((int)offset_x)];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat offset_x = trnaslation.x - self.firstTouchPoint.x;
            [UIView animateWithDuration:0.2 animations:^{
                if (offset_x < -self.imageMargin * 3) {
                    self.frame = CGRectMake(-self.frame.size.width * 2, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                } else {
                    self.frame = CGRectMake(self.imageMargin, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
                }
            } completion:^(BOOL finished) {
            }];
            
            [self.delegate cardViewTouchEndWithoffsetX:abs((int)offset_x)];
        }
            break;
        default:
            break;
    }
}

@end

@implementation ELCardScrollViewConfigModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageMargin = 10;
    }
    return self;
}

@end
