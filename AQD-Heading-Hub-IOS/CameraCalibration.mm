#import "CameraCalibration.h"
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/aruco.hpp>
#import <opencv2/calib3d.hpp>  // Required for calibration functions
#import <opencv2/imgcodecs/ios.h>  // Required for UIImage to cv::Mat conversion

@implementation CameraCalibration

// Function to convert UIImage to cv::Mat
cv::Mat UIImageToMat(UIImage *image) {
    cv::Mat mat;
    UIImageToMat(image, mat);
    return mat;
}

+ (bool)calibrateCameraWithImages:(NSArray<UIImage *> *)images imageSize:(CGSize)imageSize {
    // Prepare object points (real-world coordinates of the chessboard corners)
    cv::Size patternSize(7, 7);  // Size of the chessboard pattern (adjust as necessary)
    std::vector<cv::Point3f> objectPoints;
    for (int i = 0; i < patternSize.height; i++) {
        for (int j = 0; j < patternSize.width; j++) {
            objectPoints.push_back(cv::Point3f(j, i, 0));
        }
    }
    
    // Storage for all the object points and image points from all images
    std::vector<std::vector<cv::Point3f>> allObjectPoints;
    std::vector<std::vector<cv::Point2f>> allImagePoints;

    // Convert each UIImage to cv::Mat and detect corners
    for (UIImage *image in images) {
        cv::Mat imageMat = UIImageToMat(image);  // Convert UIImage to cv::Mat
        std::vector<cv::Point2f> corners;

        // Detect chessboard corners
        bool found = cv::findChessboardCorners(imageMat, patternSize, corners);
        if (found) {
            allObjectPoints.push_back(objectPoints);
            allImagePoints.push_back(corners);
        } else {
            NSLog(@"Failed to find chessboard corners in one image");
        }
    }

    // Check if we have enough points for calibration
    if (allImagePoints.size() < 10) {
        NSLog(@"Not enough images for calibration");
        return false;
    }

    // Perform the calibration
    cv::Mat cameraMatrix, distCoeffs;
    std::vector<cv::Mat> rvecs, tvecs;
    double error = cv::calibrateCamera(allObjectPoints, allImagePoints, cv::Size(imageSize.width, imageSize.height), cameraMatrix, distCoeffs, rvecs, tvecs);

    NSLog(@"Calibration Error: %f", error);

    // Save the calibration data
    [self saveCalibrationData:cameraMatrix distCoeffs:distCoeffs];

    return true;
}

+ (void)saveCalibrationData:(cv::Mat)cameraMatrix distCoeffs:(cv::Mat)distCoeffs {
    // Convert cv::Mat to NSData
    NSData *cameraMatrixData = [NSData dataWithBytes:cameraMatrix.data length:cameraMatrix.total() * cameraMatrix.elemSize()];
    NSData *distCoeffsData = [NSData dataWithBytes:distCoeffs.data length:distCoeffs.total() * distCoeffs.elemSize()];

    // Save to UserDefaults or file
    [[NSUserDefaults standardUserDefaults] setObject:cameraMatrixData forKey:@"cameraMatrix"];
    [[NSUserDefaults standardUserDefaults] setObject:distCoeffsData forKey:@"distCoeffs"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isCalibrated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
