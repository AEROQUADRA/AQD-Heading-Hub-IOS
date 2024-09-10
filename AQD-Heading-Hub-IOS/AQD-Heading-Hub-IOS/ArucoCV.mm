// ArucoCV.mm

#import "ArucoCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/aruco.hpp>

@implementation ArucoCV

+ (NSMutableArray *)detectMarkersInFrame:(CVPixelBufferRef)pixelBuffer {
    // Lock the pixel buffer
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    // Get base address and width/height
    void *baseAddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    // Create cv::Mat from pixel buffer
    cv::Mat imageMat((int)height, (int)width, CV_8UC1, baseAddress);
    
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    // Create ArUco dictionary and detector parameters
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_50);
    std::vector<int> markerIds;
    std::vector<std::vector<cv::Point2f>> markerCorners;
    
    // Detect markers
    cv::aruco::detectMarkers(imageMat, dictionary, markerCorners, markerIds);
    
    // Create NSMutableArray to store detected marker IDs
    NSMutableArray *detectedMarkers = [NSMutableArray array];
    
    // If markers are detected, return their IDs
    if (markerIds.size() > 0) {
        for (int i = 0; i < markerIds.size(); i++) {
            [detectedMarkers addObject:@(markerIds[i])];
        }
    }
    
    return detectedMarkers;
}

@end
