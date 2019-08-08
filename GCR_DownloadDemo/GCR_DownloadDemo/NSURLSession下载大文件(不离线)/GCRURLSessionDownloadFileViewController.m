//
//  GCRURLSessionDownloadFileViewController.m
//  GCR_DownloadDemo
//
//  Created by gcr on 2019/8/1.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "GCRURLSessionDownloadFileViewController.h"

@interface GCRURLSessionDownloadFileViewController ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) UIProgressView *progreeView;
@property (nonatomic, strong) UILabel * progressLabel;

@end

@implementation GCRURLSessionDownloadFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark -- 使用NSURLSession的block方法下载文件
- (void)downloadWithNSURLSessionBlock{
    
    // 创建下载路径
    NSURL *url = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1877784-b4777f945878a0b9.jpg"];
    // 创建NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    // 创建下载任务,其中location为下载的临时文件路径
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //文件将要移动到的指定目录
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        //新文件路径
        NSString *newFilePath = [documentsPath stringByAppendingPathComponent:@"sdfd.jop.dmg"];
        //移动文件到新路径
        [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:newFilePath error:nil];
        
        //回到主线程 刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImageView *imageView = [[UIImageView alloc]init];
            imageView.image = [UIImage imageWithContentsOfFile:newFilePath];
            
        });
        
        
    }];
    
    [downloadTask resume];
    
}


#pragma mark--使用NSURLSession的delegate方法下载文件
- (void)downloadWithNSURLSessionDelegate{
    // 创建下载路径
    NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //创建任务
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    //开始任务
    [downloadTask resume];
    
}

#pragma mark --NSURLSessionDownloadDelegate
/**
 *  文件下载完毕时调用
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    // 文件将要移动到的指定目录
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    // 新文件路径
    NSString *newFilePath = [documentsPath stringByAppendingPathComponent:@"sdf.dmg"];
    // 移动文件到新路径
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:newFilePath error:nil];
    
}


/**
 *  每次写入数据到临时文件时，就会调用一次这个方法。可在这里获得下载进度
 *
 *  @param bytesWritten              这次写入的文件大小
 *  @param totalBytesWritten         已经写入沙盒的文件大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
 
    self.progreeView.progress = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0*totalBytesWritten/totalBytesExpectedToWrite];
    
    
}

/**
 *  恢复下载后调用
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
