# HeeePhotoBrowser
---现在支持设置预加载图片的个数，大量图片浏览也没问题。修复了小问题，提升体验。---

用法很简单，仅一行代码：

[HeeePhotoBrowser showPhotoBrowserWithImageViews:_IVArr currentIndex:currentIndex highQualityImageArray:_urlArr andPreLoadImageNumber:2];

提示：在HeeePhotoBrowser里添加提示框时，因为UIAlertController是显示在基础window上的，级别没有HeeePhotoBrowser用的那个window高，会显示在背后，所以这里建议用UIAlertView或者自定义的弹出框。

![图1](https://github.com/HeeeShare/HeeePhotoBrowser/blob/master/images/IMG_5845.PNG)         ![图2](https://github.com/HeeeShare/HeeePhotoBrowser/blob/master/images/IMG_5846.PNG)         ![图3](https://github.com/HeeeShare/HeeePhotoBrowser/blob/master/images/IMG_5847.PNG)
