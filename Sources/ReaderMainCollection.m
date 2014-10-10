//
//  ReaderMainCollection.m
//  Reader
//
//  Created by Heberti Almeida on 09/10/14.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights to
//	use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//	of the Software, and to permit persons to whom the Software is furnished to
//	do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all
//	copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReaderMainCollection.h"
#import "ReaderCollectionCell.h"
#import "ReaderDocument.h"
#import "ReaderThumbView.h"
#import "ReaderThumbCache.h"
#import "ReaderThumbRequest.h"


@implementation ReaderMainCollection {
    ReaderDocument *document;
    ReaderThumbView *pageThumbView;
}

#pragma mark - Constants

#define CELL_IDENTIFIER @"CELL"


#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout document:(ReaderDocument *)object
{
    assert(object != nil); // Must have a valid ReaderDocument
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self registerClass:[ReaderCollectionCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
        self.dataSource = self;
        
        
        document = object;
    }
    return self;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [document.pageCount integerValue];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReaderCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    NSInteger page = indexPath.row+1;

    if (![cell.contentView viewWithTag:123]) {
        cell.thumbView = [[UIImageView alloc] initWithFrame:cell.bounds];
        cell.thumbView.tag = 123;
        [cell.contentView addSubview:cell.thumbView];
    }
    
    cell.thumbView.image = [self updatePageThumbView:page frame:cell.contentView.frame];

    return cell;
}

- (UIImage *)updatePageThumbView:(NSInteger)page frame:(CGRect)frame
{
    if (pageThumbView == nil) {
        pageThumbView = [[ReaderThumbView alloc] initWithFrame:frame]; // Create the thumb view
    }
    
    pageThumbView.tag = page;
    
    UIImage *thumb;
    NSURL *fileURL = document.fileURL;
    NSString *guid = document.guid;
    NSString *phrase = document.password;
    
    ReaderThumbRequest *request = [ReaderThumbRequest newForView:pageThumbView fileURL:fileURL password:phrase guid:guid page:page size:frame.size];
    UIImage *image = [[ReaderThumbCache sharedInstance] thumbRequest:request priority:YES]; // Request the thumb
    
    if ([image isKindOfClass:[UIImage class]]) {
        thumb = image;
    } else {
        return [self updatePageThumbView:page frame:frame];
    }
    
    return thumb;
}

#pragma mark - UICollectionView Delegate

- (void)hidePagebar
{
    if (self.hidden == NO) // Only if visible
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             self.hidden = YES;
         }
         ];
    }
}

- (void)showPagebar
{
    if (self.hidden == YES) // Only if hidden
    {
        [UIView animateWithDuration:0.25 delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^(void)
         {
             self.hidden = NO;
             self.alpha = 1.0f;
         }
                         completion:NULL
         ];
    }
}

@end
