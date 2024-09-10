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
    
    // Default camera calibration parameters (adjust if you have actual calibration data)
    cv::Mat cameraMatrix = (cv::Mat_<double>(3, 3) <<
                            1000, 0, width / 2.0,
                            0, 1000, height / 2.0,
                            0, 0, 1); // Focal length of 1000 is a guess
    cv::Mat distCoeffs = cv::Mat::zeros(5, 1, CV_64F); // Assuming no lens distortion

    // Define the marker size (e.g., in meters or centimeters, based on your setup)
    float markerLength = 0.05; // 5cm marker size
    
    // If markers are detected, estimate pose and return their IDs and distances
    if (markerIds.size() > 0) {
        std::vector<cv::Vec3d> rvecs, tvecs;
        cv::aruco::estimatePoseSingleMarkers(markerCorners, markerLength, cameraMatrix, distCoeffs, rvecs, tvecs);
        
        for (int i = 0; i < markerIds.size(); i++) {
            // Calculate the distance to the marker (Euclidean distance from the camera to the marker)
            double distance = sqrt(tvecs[i][0] * tvecs[i][0] +
                                   tvecs[i][1] * tvecs[i][1] +
                                   tvecs[i][2] * tvecs[i][2]);
            
            // Store marker ID and distance
            NSDictionary *markerInfo = @{@"id": @(markerIds[i]), @"distance": @(distance)};
            [detectedMarkers addObject:markerInfo];
        }
    }
    
    return detectedMarkers;
}

@end
