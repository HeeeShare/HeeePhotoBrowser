//
//  ViewController.m
//  HeeePhotoBrowser-demo
//
//  Created by hgy on 2018/10/17.
//  Copyright © 2018年 hgy. All rights reserved.
//

#define kUIScreen_width [[UIScreen mainScreen] bounds].size.width

#import "ViewController.h"
#import "UIImageView+WebCache.h"
#import "HeeePhotoBrowser.h"
#import "DetailViewController.h"

@interface ViewController ()
@property (nonatomic,strong) NSMutableArray *IVArr;
@property (nonatomic,strong) NSArray *urlArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"ViewController";
    self.view.backgroundColor = [UIColor whiteColor];
    _IVArr = [NSMutableArray array];
    _urlArr = @[
                @"http://t7.baidu.com/it/u=3204887199,3790688592&fm=79&app=86&f=JPEG?w=4610&h=2968",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461180197&di=a23a9834a7b431c9c576f1b35bdb2298&imgtype=jpg&src=http%3A%2F%2Fimg0.imgtn.bdimg.com%2Fit%2Fu%3D3564877025%2C796183547%26fm%3D214%26gp%3D0.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461301631&di=fc9f49499318ba398a469f4be601b516&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2Fa%2F55f8c18720263.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525461151728&di=2460be17ebf7d1ea7526ef25e00c6b76&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F5%2F532931489604e.jpg",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1525606577982&di=2cba09247182622852d3d92e888b64d9&imgtype=0&src=http%3A%2F%2Fp8.qhimg.com%2Ft016ff4d49031ff3653.png",
                @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1539781470113&di=2d4e9600e7580773870ebb6b063b7173&imgtype=0&src=http%3A%2F%2Fimg2.ddove.com%2Fupload%2F20120906%2F060740261074.jpg"
                ];
    
    CGFloat w = (kUIScreen_width - 2*10 - 2*5)/3;
    CGFloat h = w*3/4;
    
    for (int i = 0; i < 3; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(10 + (w + 5)*(i%3), 100 + (h + 5)*(i/3), w, h)];
        [_IVArr addObject:iv];
        iv.clipsToBounds = YES;
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.userInteractionEnabled = YES;
        if (i == 2) {
            iv.layer.cornerRadius = h/2;
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [iv addGestureRecognizer:tap];
        [iv sd_setImageWithURL:[NSURL URLWithString:_urlArr[i]] placeholderImage:[UIImage imageNamed:@"H_默认图片加载.png"]];
        [self.view addSubview:iv];
    }
    
    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    nextBtn.frame = CGRectMake(kUIScreen_width - w - 10, w + h + 50, w, 40);
    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    [nextBtn setTitle:@"图片详情>>" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:nextBtn];
}

- (void)imageClick:(UIGestureRecognizer *)gestureRecognizer {
    NSUInteger currentIndex = [_IVArr indexOfObject:gestureRecognizer.view];
    [HeeePhotoBrowser showPhotoBrowserWithImageViews:_IVArr currentIndex:currentIndex highQualityImageArray:_urlArr andPreLoadImageNumber:2];
}

- (void)nextBtnClick {
    [self.navigationController pushViewController:[DetailViewController new] animated:YES];
}

@end
