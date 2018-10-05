//
//  CommentDisplayRowView.h
//  ReUnite + TriagePic
//


#import <UIKit/UIKit.h>
#import "CommentObject.h"

@protocol CommentDisplayRowViewDelegate;

@interface CommentDisplayRowView : UIView <UIScrollViewDelegate, UIActionSheetDelegate>
- (id)initWithCommentObject:(CommentObject *)commentObject size:(CGSize)size;
+ (CGFloat)estimateHeightForCommentObject:(CommentObject *)commentObject width:(CGFloat)width;
@property (strong, nonatomic) CommentObject *commentObject;
@property (nonatomic, weak) id<CommentDisplayRowViewDelegate> delegate;
@end

@protocol CommentDisplayRowViewDelegate <NSObject>
- (void)commentDisplayRowView:(CommentDisplayRowView *)displayView showImage:(UIImage *)image;
@end
