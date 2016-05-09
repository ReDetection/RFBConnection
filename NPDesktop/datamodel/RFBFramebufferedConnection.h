//
//  RFBFramebufferedConnection.h
//  heroesrfbclient
//
//  Created by sbuglakov on 02/05/16.
//  Copyright © 2016 redetection. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class RFBFrameBuffer;
@class RFBServerData;


@interface RFBFramebufferedConnection : NSObject

@property (nonatomic, readonly) RFBFrameBuffer *framebuffer;
@property (nonatomic, readonly) NSString *remoteDesktopName;
@property (nonatomic, copy) void (^didUpdatedFrame)();
@property (nonatomic, copy) void (^didUpdatedRect)(CGRect rect);
@property (nonatomic, copy) void (^didErrorOccurred)(NSError *error);

- (instancetype)initWithServerData:(RFBServerData *)serverData;
- (BOOL)connect;
- (void)requestScreenUpdate:(BOOL)incremental;
- (void)sendMouseEvent:(UInt8)event atPoint:(CGPoint)point;
- (void)close;

@end
