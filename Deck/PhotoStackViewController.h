//
//  PhotoStackViewController.h
//
//  Created by Tom Longo on 16/08/12.
//  - Twitter: @tomlongo
//  - GitHub:  github.com/tomlongo
//

#import <UIKit/UIKit.h>
#import "PhotoStackView.h"

@interface PhotoStackViewController : UIViewController <PhotoStackViewDataSource, PhotoStackViewDelegate>

@property (nonatomic, strong) PhotoStackView *photoStack;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
