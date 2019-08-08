//
//  GCRURLSessionResumeDownloadFileViewController.m
//  GCR_DownloadDemo
//
//  Created by gcr on 2019/8/1.
//  Copyright © 2019 teamwork. All rights reserved.
//

#import "GCRURLSessionResumeDownloadFileViewController.h"

@interface GCRURLSessionResumeDownloadFileViewController ()<NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSData *resumeData;


@end

@implementation GCRURLSessionResumeDownloadFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"NSURLSession断点下载";
    
    // Do any additional setup after loading the view.
}

- (void)resumeDownloadBtn:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if(nil == self.downloadTask){ // [开始下载/继续下载]
        if(self.resumeData){ // [继续下载]
            self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
            [self.downloadTask resume];
            self.resumeData = nil;
        }else{//[开始下载] 从0开始下载
            NSURL *url = [NSURL URLWithString:@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V5.4.0.dmg"];
            self.downloadTask = [self.session downloadTaskWithURL:url];
            [self.downloadTask resume];
        }
        
        
    }else{//[暂停下载]
        
        __weak typeof(self) weakSelf = self;
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            weakSelf.resumeData = resumeData;
            weakSelf.downloadTask = nil;
        }];
        
    }
    
}





#pragma mark--NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *newFilePath = [documentsPath stringByAppendingPathComponent:@"qq.dmg"];
    
    [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:newFilePath error:nil];
    
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    self.progressView.progress = 1.0*totalBytesWritten/totalBytesExpectedToWrite;
    self.progressLabel.text = [NSString stringWithFormat:@"当前下载进度:%.2f%%",100.0*totalBytesWritten/totalBytesExpectedToWrite];
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

#pragma mark -- setter
- (NSURLSession *)session{
    
    if(!_session){
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

/*
 
 NSURLSession拥有终止下载的方法：- (void)cancelByProducingResumeData:(void (^)(NSData *resumeData))completionHandler;。
 其中的参数resumeData包含了此次下载文件的请求路径，以及下载文件的位置信息。
 而且NSURLSession还有一个方法- (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData;，可以利用上次停止下载的resumeData，开启一个新的任务继续下载。
 因为涉及保存上次下载的resumeData，所以我们要将resumeData保存为全局变量，以便使用。另外还有一些其他类需要保存为全局变量。
 但是使用这样的方法进行断点下载，如果程序被杀死，再重新启动的话，是无法继续下载的。只能重新开始下载。也就是说不支持离线下载。
 NSURLSession断点下载（不支持离线）实现断点下载的步骤如下：
 
 在实现断点下载的[开始/暂停]按钮中添加以下步骤：
 
 设置一个downloadTask、session以及resumeData的全局变量
 如果开始下载，就创建一个新的downloadTask，并启动下载
 如果暂停下载，调用取消下载的函数，并在block中保存本次的resumeData到全局resumeData中。
 如果恢复下载，将上次保存的resumeData加入到任务中，并启动下载。
 
 作者：行走少年郎
 链接：https://www.jianshu.com/p/5a07352e9473
 */



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
