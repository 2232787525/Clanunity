//
//  PLClearCacheTool.m
//  PlamLive
//
//  Created by Mac on 16/11/30.
//  Copyright © 2016年 wangyadong. All rights reserved.
//

#import "PLClearCacheTool.h"


#define fileManager [NSFileManager defaultManager]

@implementation PLClearCacheTool

//获取path路径下文件夹大小
+ (NSString *)getCacheSizeWithFilePath:(NSString *)path path2:(NSString *)path2
{
    //调试
    //#ifdef DEBUG
#if 0
    //如果文件夹不存在或者不是一个文件夹那么就抛出一个异常
    //抛出异常会导致程序闪退，所以只在调试阶段抛出，发布阶段不要再抛了,不然极度影响用户体验
    BOOL isDirectory = NO;
    BOOL isExist = [fileManager fileExistsAtPath:path isDirectory:&isDirectory];
    if (!isExist || !isDirectory)
    {
        NSException *exception = [NSException exceptionWithName:@"fileError" reason:@"please check your filePath!" userInfo:nil];
        [exception raise];
        
    }
    NSLog(@"debug");
    //发布
#else
    NSLog(@"post");
#endif
    
    //获取“path”文件夹下面的所有文件
    NSArray *subpathArray= [fileManager subpathsAtPath:path];
    
    NSString *filePath = nil;
    NSInteger totleSize=0;
    
    for (NSString *subpath in subpathArray)
    {
        //拼接每一个文件的全路径
        filePath =[path stringByAppendingPathComponent:subpath];
        
        
        
        //isDirectory，是否是文件夹，默认不是
        BOOL isDirectory = NO;
        
        //isExist，判断文件是否存在
        BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        //判断文件是否存在，不存在的话过滤
        //如果存在的话，那么是否是文件夹，是的话也过滤
        //如果文件既存在又不是文件夹，那么判断它是不是隐藏文件，是的话也过滤
        //过滤以上三个情况后，就是一个文件夹里面真实的文件的总大小
        //以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]) continue;
        //指定路径，获取这个路径的属性
        //attributesOfItemAtPath:需要传文件夹路径
        //但是attributesOfItemAtPath 只可以获得文件属性，不可以获得文件夹属性，这个也就是需要for-in遍历文件夹里面每一个文件的原因
        NSDictionary *dict=   [fileManager attributesOfItemAtPath:filePath error:nil];
        
        NSInteger size=[dict[@"NSFileSize"] integerValue];
        totleSize+=size;
    }
    
    
    
    //获取“path”文件夹下面的所有文件
    NSArray *subpathArray2= [fileManager subpathsAtPath:path2];
    
    for (NSString *subpath in subpathArray2)
    {
        //拼接每一个文件的全路径
        filePath =[path2 stringByAppendingPathComponent:subpath];
        
        //isDirectory，是否是文件夹，默认不是
        BOOL isDirectory = NO;
        
        //isExist，判断文件是否存在
        BOOL isExist = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
        
        //判断文件是否存在，不存在的话过滤
        //如果存在的话，那么是否是文件夹，是的话也过滤
        //如果文件既存在又不是文件夹，那么判断它是不是隐藏文件，是的话也过滤
        //过滤以上三个情况后，就是一个文件夹里面真实的文件的总大小
        //以上判断目的是忽略不需要计算的文件
        if (!isExist || isDirectory || [filePath containsString:@".DS"]) continue;
        //指定路径，获取这个路径的属性
        //attributesOfItemAtPath:需要传文件夹路径
        //但是attributesOfItemAtPath 只可以获得文件属性，不可以获得文件夹属性，这个也就是需要for-in遍历文件夹里面每一个文件的原因
        NSDictionary *dict=   [fileManager attributesOfItemAtPath:filePath error:nil];
        
        NSInteger size=[dict[@"NSFileSize"] integerValue];
        totleSize+=size;
    }
    
    
    //将文件夹大小转换为 M/KB/B
    NSString *totleStr = nil;
    totleStr = [NSString stringWithFormat:@"%.1fM",totleSize / 1000.0f /1000.0f];
    return totleStr;
}

/**
 *  清理缓存
 */
+(void)cleanCache:(cleanCacheBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //文件路径
        NSString *directoryPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        
        NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
        
        for (NSString *subPath in subpaths) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        //拍摄（压缩）时的临时文件夹
        NSString *tmp = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
        [[NSFileManager defaultManager] removeItemAtPath:tmp error:nil];
        
        //清除sdWebimage的缓存
        [[SDImageCache sharedImageCache]clearDiskOnCompletion:nil];
        [[SDImageCache sharedImageCache]clearMemory];
        
        //也清除一下webView的缓存
        NSString *filePath2= [NSHomeDirectory() stringByAppendingString:@"/Library/WebKit"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath2 error:nil];
        
        //返回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
}



@end
