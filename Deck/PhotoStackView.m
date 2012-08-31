//
//  PhotoStackView.m
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import <QuartzCore/QuartzCore.h>
#import "PhotoStackView.h"

static BOOL const BorderVisibilityDefault = YES;
static CGFloat const BorderWidthDefault = 5.0f;
static CGFloat const PhotoRotationOffsetDefault = 4.0f;

@interface PhotoStackView()

    @property (nonatomic, strong) NSArray *photoViews;

@end

@implementation PhotoStackView

@synthesize borderImage = _borderImage;
@synthesize borderWidth = _borderWidth;

#pragma mark -
#pragma mark Getters and Setters

-(void)setDataSource:(id<PhotoStackViewDataSource>)dataSource {
    if(dataSource != _dataSource) {
        _dataSource = dataSource;
        [self reloadData];
    }
}

-(void)setPhotoViews:(NSArray *)photoViews {
    
    // Remove current photo views, ready to be replaced with the fresh batch
    
    for(UIView *view in self.photoViews) {
        [view removeFromSuperview];
    }

    
    for (UIView *view in photoViews) {

        // If there is already a view at this index position, use that photo's transform
        // rather than setting a new random rotation (this is to stop the stack from shifting
        // when new photos are added after the fact)
        
        if([photoViews indexOfObject:view] < [_photoViews count]) {
            UIView *existingViewAtIndex = [_photoViews objectAtIndex:[photoViews indexOfObject:view]];
            view.transform = existingViewAtIndex.transform;
        } else {
            [self makeCrooked:view animated:NO];
        }
        
        [self insertSubview:view atIndex:0];
        
    }
    
    _photoViews = photoViews;
}

-(UIImage *)borderImage {
    if(!_borderImage) {
        _borderImage = [UIImage imageNamed:@"PhotoBorder"];
    }
    
    return _borderImage;
}

-(void)setBorderImage:(UIImage *)borderImage {
    if(borderImage != _borderImage) {
        _borderImage = borderImage;
        [self reloadData];
    }
}

-(void)setShowBorder:(BOOL)showBorder {
    if(showBorder != _showBorder) {
        _showBorder = showBorder;
        [self reloadData];
    }
}

-(CGFloat)borderWidth {
    return (self.showBorder) ? _borderWidth : 0;
}

-(void)setBorderWidth:(CGFloat)borderWidth {
    if(borderWidth != _borderWidth) {
        _borderWidth = borderWidth;
        [self reloadData];
    }
}

-(void)setRotationOffset:(CGFloat)rotationOffset {
    if(rotationOffset != _rotationOffset) {
        _rotationOffset = rotationOffset;
        [self reloadData];
    }
}

-(UIColor *)highlightColor {
    if(!_highlightColor) {
        _highlightColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.15];
    }
    return _highlightColor;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    UIImageView *topPhoto = [[self topPhoto].subviews lastObject];
    
    if(highlighted) {
        
        UIView *view = [[UIView alloc] initWithFrame:topPhoto.bounds];
        view.backgroundColor = self.highlightColor;
        [topPhoto addSubview:view];
        [topPhoto bringSubviewToFront:view];
    } else {
        [[topPhoto.subviews lastObject] removeFromSuperview];
    }
    
}



#pragma mark -
#pragma mark Animation

-(void)returnToCenter:(UIView *)photo {
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         photo.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
                     }];
}

-(void)flickAway:(UIView *)photo withVelocity:(CGPoint)velocity {
    
    if ([self.delegate respondsToSelector:@selector(photoStackView:willFlickAwayPhotoFromIndex:toIndex:)]) {
        NSUInteger fromIndex = [self indexOfTopPhoto];
        NSUInteger toIndex = [self indexOfTopPhoto]+1;
        NSUInteger numberOfPhotos = [self.dataSource numberOfPhotosInPhotoStackView:self];
        if (toIndex >= numberOfPhotos) {
            toIndex = 0;
        }
        [self.delegate photoStackView:self willFlickAwayPhotoFromIndex:fromIndex toIndex:toIndex];
    }

    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat xPos = (velocity.x < 0) ? CGRectGetMidX(self.bounds)-width : CGRectGetMidY(self.bounds)+width;
    
    [UIView animateWithDuration:0.1
                     animations:^{
                         photo.center = CGPointMake(xPos, CGRectGetMidY(self.bounds));
                     }
                     completion:^(BOOL finished){
                         
                         [self makeCrooked:photo animated:YES];
                         [self sendSubviewToBack:photo];
                         [self makeStraight:[self topPhoto] animated:YES];
                         [self returnToCenter:photo];
                         
                         if ([self.delegate respondsToSelector:@selector(photoStackView:didRevealPhotoAtIndex:)]) {
                             [self.delegate photoStackView:self didRevealPhotoAtIndex:[self indexOfTopPhoto]];
                         }
                     }];
    
}

-(void)rotatePhoto:(UIView *)photo degrees:(NSInteger)degrees animated:(BOOL)animated {
    
    CGFloat radians = M_PI * degrees / 180.0;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(radians);

    if(animated) {

        [UIView animateWithDuration:0.2
                         animations:^{
                             photo.transform = transform;
                         }];

    } else {
        photo.transform = transform;
    }
    
}

-(void)makeCrooked:(UIView *)photo animated:(BOOL)animated {
    
    NSInteger min = -(self.rotationOffset);
    NSInteger max = self.rotationOffset;
    
    NSInteger degrees = (arc4random_uniform(max-min+1)) + min;
    [self rotatePhoto:photo degrees:degrees animated:animated];
    
}

-(void)makeStraight:(UIView *)photo animated:(BOOL)animated {
    [self rotatePhoto:photo degrees:0 animated:animated];
}



#pragma mark -
#pragma mark Gesture Handlers

-(void)photoPanned:(UIPanGestureRecognizer *)gesture {
    
    UIView *topPhoto = [self topPhoto];
    CGPoint velocity = [gesture velocityInView:self];
    CGPoint translation = [gesture translationInView:self];
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
        
        if ([self.delegate respondsToSelector:@selector(photoStackView:willStartMovingPhotoAtIndex:)]) {
            [self.delegate photoStackView:self willStartMovingPhotoAtIndex:[self indexOfTopPhoto]];
        }
        
    }
    
    if(gesture.state == UIGestureRecognizerStateChanged) {
        
        CGFloat xPos = topPhoto.center.x + translation.x;
        CGFloat yPos = topPhoto.center.y + translation.y;
        
        topPhoto.center = CGPointMake(xPos, yPos);
        [gesture setTranslation:CGPointMake(0, 0) inView:self];
        
        
    } else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        
        if(abs(velocity.x) > 200) {
            [self flickAway:topPhoto withVelocity:velocity];
            
        } else {
            [self returnToCenter:topPhoto];
        }
        
    }
    
}

-(void)photoTapped:(UITapGestureRecognizer *)gesture {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    if ([self.delegate respondsToSelector:@selector(photoStackView:didSelectPhotoAtIndex:)]) {
        [self.delegate photoStackView:self didSelectPhotoAtIndex:[self indexOfTopPhoto]];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(photoStackView:didSelectPhotoAtIndex:)]) {
        // No need to highlight the photo if delegate does not implement a
        // selection handler (ie. nothing happens when they tap it)
        [self sendActionsForControlEvents:UIControlStateHighlighted];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchDragInside];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}


#pragma mark -
#pragma mark Other Methods

-(void)flipToNextPhoto{
    [self flickAway:[self topPhoto] withVelocity:CGPointMake(-400, 0)];
}

-(void)goToPhotoAtIndex:(NSUInteger)index {
    for (UIView *view in self.photoViews) {
        if([self.photoViews indexOfObject:view] < index) {
            [self sendSubviewToBack:view];
        }
    }
    [self makeStraight:[self topPhoto] animated:NO];
}

-(NSUInteger)indexOfTopPhoto {
    return (self.photoViews) ? [self.photoViews indexOfObject:[self topPhoto]] : 0;
}

-(UIView *)topPhoto {
    return [self.subviews objectAtIndex:[self.subviews count]-1];
}

-(void)sendActionsForControlEvents:(UIControlEvents)controlEvents {
    [super sendActionsForControlEvents:controlEvents];
    self.highlighted = (controlEvents == UIControlStateHighlighted) ? YES : NO;
}



#pragma mark -
#pragma mark Setup

-(void)reloadData {
    
    if (!self.dataSource) {
        //exit if data source has not been set up yet
        self.photoViews = nil;
        return;
    }
    
    NSInteger numberOfPhotos = [self.dataSource numberOfPhotosInPhotoStackView:self];
    NSInteger topPhotoIndex  = [self indexOfTopPhoto]; // Keeping track of current photo's top index so that it remains on top if new photos are added
    
    if(numberOfPhotos > 0) {

        NSMutableArray *photoViewsMutable   = [[NSMutableArray alloc] initWithCapacity:numberOfPhotos];
        UIImage *borderImage                = [self.borderImage resizableImageWithCapInsets:UIEdgeInsetsMake(self.borderWidth, self.borderWidth, self.borderWidth, self.borderWidth)];
        
        for (NSUInteger index = 0; index < numberOfPhotos; index++) {

            UIImage *image = [self.dataSource photoStackView:self photoForIndex:index];
            CGSize imageSize = image.size;
            if([self.dataSource respondsToSelector:@selector(photoStackView:photoSizeForIndex:)]){
                imageSize = [self.dataSource photoStackView:self photoSizeForIndex:index];
            }
            UIImageView *photoImageView     = [[UIImageView alloc] initWithFrame:(CGRect){CGPointZero, imageSize}];
            photoImageView.image            = image;
            UIView *view                    = [[UIView alloc] initWithFrame:photoImageView.frame];
            view.layer.rasterizationScale   = [[UIScreen mainScreen] scale];            
            view.layer.shouldRasterize      = YES; // rasterize the view for faster drawing and smooth edges

            if (self.showBorder) {
                
                // Add the background image
                if (borderImage) {
                    // If there is a border image, we need to add a background image view, and add some padding around the photo for the border

                    CGRect photoFrame                = photoImageView.frame;
                    photoFrame.origin                = CGPointMake(self.borderWidth, self.borderWidth);
                    photoImageView.frame             = photoFrame;

                    view.frame                       = CGRectMake(0, 0, photoImageView.frame.size.width+(self.borderWidth*2), photoImageView.frame.size.height+(self.borderWidth*2));
                    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:view.frame];
                    backgroundImageView.image        = borderImage;
                    
                    [view addSubview:backgroundImageView];
                } else {
                    // if there is no boarder image draw one with the CALayer
                    view.layer.borderWidth        = self.borderWidth;
                    view.layer.borderColor        = [[UIColor whiteColor] CGColor];
                    view.layer.shadowOffset       = CGSizeMake(0, 0);
                    view.layer.shadowOpacity      = 0.5;
                }
            }

            [view addSubview:photoImageView];

            view.tag    = index;
            view.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

            [photoViewsMutable addObject:view];
            
        }

        // Photo views are added to subview in the photoView setter
        self.photoViews = photoViewsMutable; photoViewsMutable = nil;
        [self goToPhotoAtIndex:topPhotoIndex];
        
    }
    
}

-(void)setup {
    
    //Defaults
    self.showBorder = BorderVisibilityDefault;
    self.borderWidth = BorderWidthDefault;
    self.rotationOffset = PhotoRotationOffsetDefault;
    
    // Add Pan Gesture
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(photoPanned:)];
    [panGesture setMaximumNumberOfTouches:1];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    // Add Tap Gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapped:)];
    [tapGesture setNumberOfTapsRequired:1];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];

    [self reloadData];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

-(void)dealloc {
    [self setPhotoViews:nil];
    [self setBorderImage:nil];
    [self setHighlightColor:nil];
}

@end
