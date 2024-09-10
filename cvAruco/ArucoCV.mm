//
//  ArucoCV.m
//  cvAruco
//
//  Created by Dan Park on 3/26/19.
//  Copyright © 2019 Dan Park. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <opencv2/core.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/imgproc.hpp>
#include "opencv2/aruco.hpp"
#include "opencv2/aruco/dictionary.hpp"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import "ArucoCV.h"

@implementation ArucoCV

static void detect(std::vector<std::vector<cv::Point2f> > &corners, std::vector<int> &ids, CVPixelBufferRef pixelBuffer) {
    cv::Ptr<cv::aruco::Dictionary> dictionary = cv::aruco::getPredefinedDictionary(cv::aruco::DICT_4X4_250);

    // Convert pixel buffer to grayscale
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *baseaddress = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    CGFloat width = CVPixelBufferGetWidth(pixelBuffer);
    CGFloat height = CVPixelBufferGetHeight(pixelBuffer);
    cv::Mat mat(height, width, CV_8UC1, baseaddress, 0); //CV_8UC1
    
    // Detect ArUco markers
    cv::aruco::detectMarkers(mat, dictionary, corners, ids);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
}

+(NSMutableArray *) estimatePose:(CVPixelBufferRef)pixelBuffer withIntrinsics:(matrix_float3x3)intrinsics andMarkerSize:(Float64)markerSize {
    
    std::vector<int> ids;
    std::vector<std::vector<cv::Point2f>> corners;
    detect(corners, ids, pixelBuffer);
    
    NSMutableArray *arrayMatrix = [NSMutableArray new];
    if(ids.size() == 0) {
        return arrayMatrix;
    }
    
    // Intrinsic parameters matrix
    cv::Mat intrinMat(3,3,CV_64F);
    intrinMat.at<Float64>(0,0) = intrinsics.columns[0][0];
    intrinMat.at<Float64>(0,1) = intrinsics.columns[1][0];
    intrinMat.at<Float64>(0,2) = intrinsics.columns[2][0];
    intrinMat.at<Float64>(1,0) = intrinsics.columns[0][1];
    intrinMat.at<Float64>(1,1) = intrinsics.columns[1][1];
    intrinMat.at<Float64>(1,2) = intrinsics.columns[2][1];
    intrinMat.at<Float64>(2,0) = intrinsics.columns[0][2];
    intrinMat.at<Float64>(2,1) = intrinsics.columns[1][2];
    intrinMat.at<Float64>(2,2) = intrinsics.columns[2][2];
    
    // Distortion coefficients
    cv::Mat distCoeffs = cv::Mat::zeros(8, 1, CV_64F);
    
    // Pose estimation for each marker
    std::vector<cv::Vec3d> rvecs, tvecs;
    cv::aruco::estimatePoseSingleMarkers(corners, markerSize, intrinMat, distCoeffs, rvecs, tvecs);
    
    for (int i = 0; i < tvecs.size(); i++) {
        // Calculate the Euclidean distance to the marker
        double distance = sqrt(tvecs[i][0] * tvecs[i][0] + tvecs[i][1] * tvecs[i][1] + tvecs[i][2] * tvecs[i][2]);
        NSLog(@"Marker ID: %d, Distance: %f meters", ids[i], distance);
        
        // Store the marker ID and distance in the array
        NSDictionary *markerData = @{@"id": @(ids[i]), @"distance": @(distance)};
        [arrayMatrix addObject:markerData];
    }
    
    return arrayMatrix;
}

@end
