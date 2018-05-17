//
//  YMShowImageView.m
//  WFCoretext
//
//  Created by 阿虎 on 14/11/3.
//  Copyright (c) 2014年 tigerwf. All rights reserved.
//

#import "YMShowImageView.h"
#import "UIImage+Utilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SDWaitingView.h"


@interface YMShowImageView ()<UIGestureRecognizerDelegate,UIActionSheetDelegate>{
    
    UIScrollView *_scrollView;
    CGRect self_Frame;
    NSInteger page;
    BOOL doubleClick;
    UIImageView *_longTapImageView;
    ImageURlAlterRule _tempRule;
    
}


@end

@implementation YMShowImageView


- (id)initWithFrame:(CGRect)frame byClick:(NSInteger)clickTag appendArray:(NSArray *)appendArray ImageType:(ImageURlAlterRule)rule{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.viewController setNeedsStatusBarAppearanceUpdate];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        _tempRule =rule;
        self_Frame = [UIScreen mainScreen].bounds;
        self.alpha = 0.0f;
        page = 0;
        doubleClick = YES;
        
        [self configScrollViewWith:clickTag andAppendArray:appendArray ImageType:(ImageURlAlterRule)rule];
        UITapGestureRecognizer *tapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(disappear)];
        tapGser.numberOfTouchesRequired = 1;
        tapGser.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGser];
        
        UITapGestureRecognizer *doubleTapGser = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeBig:)];
        doubleTapGser.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGser];
        [tapGser requireGestureRecognizerToFail:doubleTapGser];
        
//        UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImageToPhotoAlbum:)];
//        [self addGestureRecognizer:longTap];
//        [tapGser requireGestureRecognizerToFail:longTap];
        
    }
    return self;
    
    
}

- (void)configScrollViewWith:(NSInteger)clickTag andAppendArray:(NSArray *)appendArray ImageType:(ImageURlAlterRule)rule{
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self_Frame];
    _scrollView.backgroundColor = [UIColor blackColor];
    _scrollView.pagingEnabled = true;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(KScreenWidth * appendArray.count, 0);
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    float W = self.frame.size.width;
    for (int i = 0; i < appendArray.count; i ++) {
        UIScrollView *imageScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(KScreenWidth * i, 0, KScreenWidth, KScreenHeight)];
        imageScrollView.backgroundColor =[UIColor blackColor];
        imageScrollView.contentSize = CGSizeMake(KScreenWidth, KScreenHeight);
        imageScrollView.delegate = self;
        imageScrollView.maximumZoomScale = 4;
        imageScrollView.minimumZoomScale = 1;
        //大图imgView
        __block UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];

        if ([appendArray[i] isKindOfClass:[NSString class]]) {
            NSString *imgStr = [NSString stringWithFormat:@"%@",[appendArray objectAtIndex:i]];
            NSURL *urlStr = nil;

            urlStr = [NSURL URLWithString:imgStr];

            __block SDWaitingView *pv;
            __block UIImageView *waitImage;

            [imageView sd_setImageWithURL:urlStr placeholderImage:[UIImage imageNamed:[ImageDefault imagePlace]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!pv) {
                        waitImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 225, 240)];
                        waitImage.center = imageView.center;
                        [imageView addSubview:waitImage];
                        [waitImage sd_setImageWithURL:urlStr];
                        pv = [[SDWaitingView alloc]initWithFrame:CGRectMake(0 , 0, 100, 100)];
                        pv.center  =waitImage.center;
                        [imageView addSubview:pv];
                    }
                    float showProgress = (float)receivedSize/(float)expectedSize;
                    [pv setProgress:showProgress];
                });
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image) {
                    UIImage *eimage = [image normalizedImage];
                    imageView.image      = eimage;
                    pv.hidden = YES;
                    [pv removeFromSuperview];
                    waitImage.hidden = YES;
                    [waitImage removeFromSuperview];
                    waitImage   = nil;
                    pv = nil;
                }
                
            }];
            

        }else if([appendArray[i] isKindOfClass:[UIImage class]]){
            imageView.image =appendArray[i];
        }else{
            imageView.image  = [UIImage imageWithData:appendArray[i]];
        }
        imageView.contentMode=UIViewContentModeScaleAspectFit;
        imageView.clipsToBounds=YES;
        [imageScrollView addSubview:imageView];
        [_scrollView addSubview:imageScrollView];
        imageScrollView.tag = 100 + i ;
        imageView.tag = 1000 + i;
        
        imageView.userInteractionEnabled = YES;
        UILongPressGestureRecognizer * longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(saveImageToPhotoAlbum:)];
        [imageView addGestureRecognizer:longTap];
    }
    [_scrollView setContentOffset:CGPointMake(W * (clickTag), 0) animated:YES];
    page = clickTag;
}


-(void)saveImageToPhotoAlbum:(UILongPressGestureRecognizer*)longTap{
    
    if (longTap.state == UIGestureRecognizerStateBegan) {
        _longTapImageView = (UIImageView*)longTap.view;
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到手机", nil];
        [actionSheet showInView:self.viewController.view];
    }
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
            [self createAlbumInPhoneAlbum];
            
//        });
    }
}


#pragma mark - 在手机相册中创建相册
- (void)createAlbumInPhoneAlbum
{
    
    [self saveToAlbumWithMetadata:nil imageData:UIImagePNGRepresentation(_longTapImageView.image) customAlbumName:@"相机胶卷" completionBlock:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
          
             
         });
         
         //这里可以创建添加成功的方法
         
     }
        failureBlock:^(NSError *error)
     {
         //处理添加失败的方法显示alert让它回到主线程执行，不然那个框框死活不肯弹出来
         dispatch_async(dispatch_get_main_queue(), ^{

         });
     }];
}

- (void)saveToAlbumWithMetadata:(NSDictionary *)metadata
                      imageData:(NSData *)imageData
                customAlbumName:(NSString *)customAlbumName
                completionBlock:(void (^)(void))completionBlock
                   failureBlock:(void (^)(NSError *error))failureBlock
{
    
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    void (^AddAsset)(ALAssetsLibrary *, NSURL *) = ^(ALAssetsLibrary *assetsLibrary, NSURL *assetURL) {
        [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:customAlbumName]) {
                    [group addAsset:asset];
                    if (completionBlock) {
                        completionBlock();
                    }
                }
            } failureBlock:^(NSError *error) {
                if (failureBlock) {
                    failureBlock(error);
                }
            }];
        } failureBlock:^(NSError *error) {
            if (failureBlock) {
                failureBlock(error);
            }
        }];
    };
    
    __weak  ALAssetsLibrary *weakAs =  assetsLibrary;
    
    [weakAs writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
        if (customAlbumName) {
            [weakAs addAssetsGroupAlbumWithName:customAlbumName resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    [ weakAs assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        [group addAsset:asset];
                        if (completionBlock) {
                            completionBlock();
                        }
                    } failureBlock:^(NSError *error) {
                        if (failureBlock) {
                            failureBlock(error);
                        }
                    }];
                } else {
                    AddAsset(assetsLibrary, assetURL);
                }
            } failureBlock:^(NSError *error) {
                AddAsset(assetsLibrary, assetURL);
            }];
        } else {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}


- (void)disappear{
    
    
    _removeImg();
    
}


- (void)changeBig:(UITapGestureRecognizer *)tapGes{
    
    CGFloat newscale = 1.9;
    UIScrollView *currentScrollView = (UIScrollView *)[self viewWithTag:page + 100];
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[tapGes locationInView:tapGes.view] andScrollView:currentScrollView];
    
    if (doubleClick == YES)  {
        
        [currentScrollView zoomToRect:zoomRect animated:YES];
        
    }else {
        
        [currentScrollView zoomToRect:currentScrollView.frame animated:YES];
    }
    
    doubleClick = !doubleClick;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    UIImageView *imageView = (UIImageView *)[self viewWithTag:scrollView.tag + 900];
    return imageView;
    
}

- (CGRect)zoomRectForScale:(CGFloat)newscale withCenter:(CGPoint)center andScrollView:(UIScrollView *)scrollV{
    
    CGRect zoomRect = CGRectZero;
    zoomRect.size.height = scrollV.frame.size.height / newscale;
    zoomRect.size.width = scrollV.frame.size.width  / newscale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    // MyLog(@" === %f",zoomRect.origin.x);
    return zoomRect;
    
}

- (void)show:(UIView *)bgView didFinish:(didRemoveImage)tempBlock{
    
    [bgView addSubview:self];
    
    _removeImg = tempBlock;
    
    [UIView animateWithDuration:.4f animations:^(){
        
        self.alpha = 1.0f;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}


#pragma mark - ScorllViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    CGPoint offset = _scrollView.contentOffset;
    page = offset.x / self.frame.size.width ;
    
    
    UIScrollView *scrollV_next = (UIScrollView *)[self viewWithTag:page+100+1]; //前一页
    
    if (scrollV_next.zoomScale != 1.0){
        
        scrollV_next.zoomScale = 1.0;
    }
    
    UIScrollView *scollV_pre = (UIScrollView *)[self viewWithTag:page+100-1]; //后一页
    if (scollV_pre.zoomScale != 1.0){
        scollV_pre.zoomScale = 1.0;
    }
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    
}



@end
