//
//  DisplayLinkTimer.h
//  TestProject
//
//  Created by Zhang Ji on 2019/9/19.
//  Copyright © 2019 Zhang Ji. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DisplayLinkTimer : NSObject

@property(nonatomic) BOOL isPaused;

- (instancetype)initWithTimerHandler:(void (^)(void))timerHandler;
- (void)invalidate;


@end

NS_ASSUME_NONNULL_END
