#import "ArucoCV.h"
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
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
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_250);
    std::vector<int> markerIds;
    std::vector<std::vector<cv::Point2f>> markerCorners;
    
    // Detect markers
    cv::aruco::detectMarkers(imageMat, dictionary, markerCorners, markerIds);
    
    // Create NSMutableArray to store detected marker IDs and distances
    NSMutableArray *detectedMarkers = [NSMutableArray array];

    // Fetch calibration data from UserDefaults (if available)
    NSData *cameraMatrixData = [[NSUserDefaults standardUserDefaults] objectForKey:@"cameraMatrix"];
    NSData *distCoeffsData = [[NSUserDefaults standardUserDefaults] objectForKey:@"distCoeffs"];
    
    cv::Mat cameraMatrix, distCoeffs;
    if (cameraMatrixData != nil && distCoeffsData != nil) {
        cameraMatrix = cv::Mat(3, 3, CV_64F, (void *)[cameraMatrixData bytes]);
        distCoeffs = cv::Mat(1, 5, CV_64F, (void *)[distCoeffsData bytes]);
    } else {
        // Fallback calibration values
        cameraMatrix = (cv::Mat_<double>(3, 3) <<
                                1000, 0, width / 2.0,
                                0, 1000, height / 2.0,
                                0, 0, 1);  // Focal length as a guess
        distCoeffs = cv::Mat::zeros(5, 1, CV_64F);  // No lens distortion
    }

    // Define marker size
    float markerLength = 0.05;  // 5cm marker size
    
    // Estimate pose if markers are detected
    if (markerIds.size() > 0) {
        std::vector<cv::Vec3d> rvecs, tvecs;
        cv::aruco::estimatePoseSingleMarkers(markerCorners, markerLength, cameraMatrix, distCoeffs, rvecs, tvecs);
        
        for (int i = 0; i < markerIds.size(); i++) {
            double distance = sqrt(tvecs[i][0] * tvecs[i][0] + tvecs[i][1] * tvecs[i][1] + tvecs[i][2] * tvecs[i][2]);
            NSDictionary *markerInfo = @{@"id": @(markerIds[i]), @"distance": @(distance)};
            [detectedMarkers addObject:markerInfo];
        }
    }
    
    return detectedMarkers;
}

@end
