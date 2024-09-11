#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CameraCalibration : NSObject

// Function to calibrate the camera with a given set of captured images
+ (bool)calibrateCameraWithImages:(NSArray<UIImage *> *)images imageSize:(CGSize)imageSize;

@end
