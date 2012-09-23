//
//  PhotoStackView.h
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import <UIKit/UIKit.h>

@class PhotoStackView;

@protocol PhotoStackViewDataSource <NSObject>

    @required
    - (NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack;
    - (UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index;

    @optional
    - (CGSize)photoStackView:(PhotoStackView *)photoStack photoSizeForIndex:(NSUInteger)index;

@end


@protocol PhotoStackViewDelegate <NSObject>

    @optional
    -(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index;
    -(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
    -(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index;
    -(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index;

@end


@interface PhotoStackView : UIControl <UIGestureRecognizerDelegate>

    @property (weak, nonatomic) id <PhotoStackViewDataSource> dataSource;
    @property (weak, nonatomic) id <PhotoStackViewDelegate> delegate;

    // The image to use for the border (default is white rounded corner)
    @property (nonatomic, strong) UIImage *borderImage;

    // When set to YES a white border will appear around photos (default is YES)
    @property (nonatomic) BOOL showBorder;

    // Inset width used for the border image (Default is 5.0)
    @property (nonatomic) CGFloat borderWidth;

    // How many degrees each photo in the stack could be rotated (Default is 4.0)
    // eg. 5.0 will randomly rotate each photo from -5 to +5 degrees
    @property (nonatomic) CGFloat rotationOffset;

    // The overlay colour that appears when the user taps on a photo
    // (default is black at 0.15 alpha)
    @property (nonatomic, strong) UIColor *highlightColor;

    -(NSUInteger)indexOfTopPhoto;
    -(void)goToPhotoAtIndex:(NSUInteger)index;
    -(void)flipToNextPhoto;
    -(void)reloadData;

@end
