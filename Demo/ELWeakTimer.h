//
//  ELWeakTimer.h
//  Demo
//
//  Created by ZCGC on 2019/9/20.
//  Copyright © 2019 getElementByYou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ELTimerHandler)(id userInfo);

@interface ELWeakTimer : NSObject

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats;

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(ELTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
