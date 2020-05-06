//
//  ELCardScrollView.h
//  Demo
//
//  Created by ZCGC on 2019/9/16.
//  Copyright © 2019 getElementByYou. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELCardScrollViewConfigModel : NSObject

@property (nonatomic, strong) NSArray * imageArray;

/**
 图片间距 默认10
 */
@property (nonatomic, assign) CGFloat imageMargin;

@property (nonatomic, copy) void (^SelectBlock) (NSInteger index);

@end

@interface ELCardScrollView : UIView

- (instancetype)initWithFrame:(CGRect)frame configModel:(ELCardScrollViewConfigModel *)configModel;

@end

NS_ASSUME_NONNULL_END
