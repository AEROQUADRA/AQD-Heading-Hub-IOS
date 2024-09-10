// ArucoCV.h

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArucoCV : NSObject

+ (NSMutableArray *)detectMarkersInFrame:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
