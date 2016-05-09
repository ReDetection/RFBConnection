//
//  RFBFramebufferedConnection.m
//  heroesrfbclient
//
//  Created by sbuglakov on 02/05/16.
//  Copyright © 2016 redetection. All rights reserved.
//

#import "RFBFramebufferedConnection.h"
#import "RFBConnection.h"
#import "RFBFrameBuffer.h"

@interface RFBFramebufferedConnection () <RFBConnectionDelegate>
@property (nonatomic, strong) RFBConnection *server;
@property (nonatomic, strong, readwrite) RFBFrameBuffer *framebuffer;
@property (nonatomic, strong, readwrite) NSString *remoteDesktopName;
@end

@implementation RFBFramebufferedConnection

- (instancetype)initWithServerData:(RFBServerData *)serverData {
    self = [super init];
    if (self) {
        self.server = [[RFBConnection alloc] initWithServerData:serverData];
        self.server.delegate = self;
    }
    return self;
}

- (BOOL)connect {
    return [self.server connect];
}

- (void)requestScreenUpdate:(BOOL)incremental {
    [self.server sendFrameBufferUpdateRequest:CGRectMake(0.f, 0.f, self.framebuffer.size.width, self.framebuffer.size.height) incremental:incremental];
}

- (void)close {
    [self.server close];
}

- (void)sendMouseEvent:(UInt8)event atPoint:(CGPoint)point {
    [self.server sendPointerEvent:(CARD8)event position:point];
}

#pragma mark - connection delegate

- (void)connection:(RFBConnection *)conn didReceiveServerInit:(rfbServerInitMsg)msg {
    CGSize size = CGSizeMake(msg.framebufferWidth, msg.framebufferHeight);
    self.framebuffer = [[RFBFrameBuffer alloc] initWithSize:size pixelFormat:msg.format];
    
    if (![conn compareLocalFormatWithRemote:msg.format]) {
        [conn sendSetPixelFormat:self.framebuffer.pixelFormat];
    }
    self.framebuffer.pixelFormat = conn.pixelFormat;
    
    [conn sendSetEncodings];
    [conn sendFrameBufferUpdateRequest:CGRectMake(0.f, 0.f, size.width, size.height) incremental:NO];
}

- (void)connection:(RFBConnection *)conn didReceiveDesktopName:(NSString *)name {
    self.remoteDesktopName = name;
}

- (void)connection:(RFBConnection *)conn didReceiveFramebufferUpdate:(rfbFramebufferUpdateMsg)msg {
    
}

- (void)connection:(RFBConnection *)conn didReceiveDataForRect:(RFBRect *)aRect {
    if (aRect.encoding == rfbEncodingRaw) {
        [self.framebuffer fillRect:aRect.rect withData:aRect.data];
    } else if (aRect.encoding == rfbEncodingTight) {
        if (aRect.filter == rfbTightFilterCopy) {
            [self.framebuffer fillRect:aRect.rect withTightData:aRect.data];
        } else if (aRect.filter == rfbTightFilterGradient) {
            [self.framebuffer fillRect:aRect.rect withGradient:aRect.data];
        }
    }
}

- (void)connection:(RFBConnection *)conn didReceiveFillColor:(NSData *)cData forRect:(rfbRectangle)rect {
    CARD8 *color = (CARD8 *)[cData bytes];
    [self.framebuffer fillRect:CGRectMake(rect.x, rect.y, rect.w, rect.h) withColor:color];
}

- (void)connection:(RFBConnection *)conn didReceiveDataForRect:(RFBRect *)aRect withPalette:(NSData *)palette {
    [self.framebuffer fillRect:aRect.rect withPalette:palette data:aRect.data];
}

- (void)connection:(RFBConnection *)conn didReceiveCopyRect:(rfbCopyRect)origin forRect:(rfbRectangle)rect {
    [self.framebuffer copyRect:CGRectMake(rect.x, rect.y, rect.w, rect.h)
                        source:CGPointMake(origin.srcX, origin.srcY)];

}

- (void)connection:(RFBConnection *)conn shouldInvalidateRect:(CGRect)rect {
    if (self.didUpdatedRect != nil) {
        self.didUpdatedRect(rect);
    }
    
}

- (void)connection:(RFBConnection *)conn didCompleteFramebufferUpdate:(int)nRects {
    if (self.didUpdatedFrame != nil) {
        self.didUpdatedFrame();
    }
}

- (void)connection:(RFBConnection *)conn shouldCloseWithError:(NSError *)error {
//    if (self.didErrorOccurred != nil) {
//        self.didErrorOccurred(error);
//    }
}

- (void)connection:(RFBConnection *)conn didCloseWithError:(NSError *)error {
    if (self.didErrorOccurred != nil) {
        self.didErrorOccurred(error);
    }
    
}


@end
