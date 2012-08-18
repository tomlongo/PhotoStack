//
//  PhotoStackViewController.m
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import "PhotoStackViewController.h"

@interface PhotoStackViewController ()
    @property (nonatomic, strong) NSArray *photos;
    -(void)setup;
@end

@implementation PhotoStackViewController

@synthesize photoStack = _photoStack,
            pageControl = _pageControl;



#pragma mark -
#pragma mark Getters

-(NSArray *)photos {
    if(!_photos) {

        _photos = [NSArray arrayWithObjects:
                   [UIImage imageNamed:@"photo1.jpg"],
                   [UIImage imageNamed:@"photo2.jpg"],
                   [UIImage imageNamed:@"photo3.jpg"],
                   [UIImage imageNamed:@"photo4.jpg"],
                   [UIImage imageNamed:@"photo5.jpg"],
                   nil];
        
    }
    return _photos;
}

-(PhotoStackView *)photoStack {
    if(!_photoStack) {        
        _photoStack = [[PhotoStackView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
        _photoStack.center = CGPointMake(self.view.center.x, 170);
        _photoStack.dataSource = self;
        _photoStack.delegate = self;
    }
    
    return _photoStack;
}



#pragma mark -
#pragma mark Deck DataSource Protocol Methods

-(NSUInteger)numberOfPhotosInPhotoStackView:(PhotoStackView *)photoStack {
    return [self.photos count];
}

-(UIImage *)photoStackView:(PhotoStackView *)photoStack photoForIndex:(NSUInteger)index {
    return [self.photos objectAtIndex:index];
}



#pragma mark -
#pragma mark Deck Delegate Protocol Methods

-(void)photoStackView:(PhotoStackView *)photoStackView willStartMovingPhotoAtIndex:(NSUInteger)index {
    // User started moving a photo
}

-(void)photoStackView:(PhotoStackView *)photoStackView willFlickAwayPhotoAtIndex:(NSUInteger)index {
    // User flicked the photo away, revealing the next one in the stack
}

-(void)photoStackView:(PhotoStackView *)photoStackView didRevealPhotoAtIndex:(NSUInteger)index {
    self.pageControl.currentPage = index;
}

-(void)photoStackView:(PhotoStackView *)photoStackView didSelectPhotoAtIndex:(NSUInteger)index {
    NSLog(@"selected %d", index);
}




#pragma mark -
#pragma mark Actions

- (IBAction)tappedInsertAnotherPhoto:(id)sender {
    NSMutableArray *photosMutable = [self.photos mutableCopy];
    [photosMutable addObject:[UIImage imageNamed:@"photo6.jpg"]];
    self.photos = photosMutable;
    [self.photoStack reloadData];
    self.pageControl.numberOfPages = [self.photos count];
}



#pragma mark -
#pragma mark Setup

-(void)setup {
    [self.view addSubview:self.photoStack];
    self.pageControl.numberOfPages = [self.photos count];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidUnload {
    [self setPageControl:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
