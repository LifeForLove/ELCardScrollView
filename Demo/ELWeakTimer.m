//
//  ELWeakTimer.m
//  Demo
//
//  Created by ZCGC on 2019/9/20.
//  Copyright © 2019 getElementByYou. All rights reserved.
//

#import "ELWeakTimer.h"

@interface ELWeakTimerTarget : NSObject

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer* timer;

@end

@implementation ELWeakTimerTarget

- (void) fire:(NSTimer *)timer {
    if(self.target) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.selector withObject:timer.userInfo afterDelay:0.0f];
#pragma clang diagnostic pop
    } else {
        [self.timer invalidate];
    }
}

@end

@implementation ELWeakTimer

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats {
    ELWeakTimerTarget* timerTarget = [[ELWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:timerTarget
                                                       selector:@selector(fire:)
                                                       userInfo:userInfo
                                                        repeats:repeats];
    return timerTarget.timer;
}

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(ELTimerHandler)block
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats {
    NSMutableArray *userInfoArray = [NSMutableArray arrayWithObject:[block copy]];
    if (userInfo != nil) {
        [userInfoArray addObject:userInfo];
    }
    return [self scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(_timerBlockInvoke:)
                                       userInfo:[userInfoArray copy]
                                        repeats:repeats];
}

+ (void)_timerBlockInvoke:(NSArray*)userInfo {
    ELTimerHandler block = userInfo[0];
    id info = nil;
    if (userInfo.count == 2) {
        info = userInfo[1];
    }
    // or `!block ?: block();` @sunnyxx
    if (block) {
        block(info);
    }
}

@end
