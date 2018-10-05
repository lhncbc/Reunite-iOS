//
// FaceRectView.m
// ReUnite + TriagePic
//


#import "FaceRectView.h"
#define faceRectColorMannual [UIColor redColor]
#define faceRectColorAuto [UIColor greenColor]
#define faceRectwidth 3
#define faceRoundCorner 3
@implementation FaceRectView{
    CGPoint offset;
    CGRect tempRect;
    UIColor* lineColor;
    
    BOOL isScaling;
    BOOL isAutomatic;
    BOOL isEditable;
    
    CGFloat _borderWidth;
}

- (id) initWithFrame:(CGRect)frame borderwitdh:(CGFloat)borderWidth automatic:(BOOL) automatic editable:(BOOL)editable{
    self = [super initWithFrame:frame];
    if (self){
        //Initialization code
        isAutomatic = automatic;

        self.layer.borderColor = isAutomatic? faceRectColorAuto.CGColor: faceRectColorMannual.CGColor;
        lineColor = isAutomatic? faceRectColorAuto: faceRectColorMannual;
        _borderWidth = borderWidth;
        
        self.layer.borderWidth = _borderWidth;
        self.layer.cornerRadius = faceRoundCorner;
        self.layer.shadowRadius = 4;
        self.layer.shadowOpacity = .8;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        //self.backgroundColor = [UIColor whiteColor];
        //self.userInteractionEnabled = YES;
        
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self addGestureRecognizer:pinchGestureRecognizer];
        tempRect = frame;
        
        isEditable = editable;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


//Only override drawRect: if you perform custom drawing.
//An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    //UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    //[bezierPath moveToPoint: CGPointMake(self.frame.size.width, self.frame.size.height)];
    //[bezierPath addLineToPoint: CGPointMake(self.frame.size.width * 3/4, self.frame.size.height)];
    //[bezierPath addLineToPoint: CGPointMake(self.frame.size.width , self.frame.size.height * 3/4)];
    if (!isEditable){
        return;
    }
    
    int padding = 20;
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(self.frame.size.width * 9/12, self.frame.size.height - self.frame.size.height/padding)];
    [bezierPath addLineToPoint: CGPointMake(self.frame.size.width - self.frame.size.width/padding, self.frame.size.height * 9/12)];
    [bezierPath moveToPoint: CGPointMake(self.frame.size.width * 10/12, self.frame.size.height - self.frame.size.height/padding)];
    [bezierPath addLineToPoint: CGPointMake(self.frame.size.width - self.frame.size.width/padding, self.frame.size.height * 10/12)];
    [bezierPath moveToPoint: CGPointMake(self.frame.size.width * 11/12, self.frame.size.height - self.frame.size.height/padding)];
    [bezierPath addLineToPoint: CGPointMake(self.frame.size.width - self.frame.size.width/padding, self.frame.size.height * 11/12)];
    [lineColor setStroke];
    bezierPath.lineWidth = _borderWidth;
    [bezierPath stroke];    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *aTouch = [touches anyObject];
    if (isScaling){
        CGPoint location = [aTouch locationInView:self];
        [UIView beginAnimations:@"scaling" context:nil];
        float width = tempRect.size.width * location.x / offset.x;
        float height = tempRect.size.height * location.y / offset.y;

        width = width<100? 100: width;
        height = height<100? 100: height;
        
        UIView *view = [self superview];
        width = tempRect.origin.x + width > view.bounds.size.width? view.bounds.size.width - tempRect.origin.x:width;
        height = tempRect.origin.y + height > view.bounds.size.height? view.bounds.size.height - tempRect.origin.y:height;
        
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y ,width, height);
        //float distance = sqrt((pow(location.x / offset.x, 2) + pow(location.y / offset.y, 2))/2);
        //self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y ,tempRect.size.width * distance, tempRect.size.height * distance);
        [UIView commitAnimations];
        [self setNeedsDisplay];
    }else{
        CGPoint location = [aTouch locationInView:self.superview];
        [UIView beginAnimations:@"Dragging A DraggableView" context:nil];
        float x = location.x-offset.x; 
        float y = location.y - offset.y; 
        x = x>0? x:0;
        y = y>0? y:0;
        UIView *view = [self superview];
        x = x+self.frame.size.width > view.bounds.size.width? view.bounds.size.width-self.frame.size.width:x;
        y = y+self.frame.size.height > view.bounds.size.height? view.bounds.size.height-self.frame.size.height:y;

        self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
        tempRect = self.frame;
        [UIView commitAnimations];
    }
}
/*
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    DLog(@"sdsd");
    return nil;
}*/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *aTouch = [touches anyObject];
    offset = [aTouch locationInView: self];
    if ((self.bounds.size.width - offset.x) + (self.bounds.size.height - offset.y) > (self.bounds.size.height*3/8)){
        isScaling = NO;
    }else{
        isScaling = YES;
    }
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.frame, point);
}

- (void)pinch:(UIPinchGestureRecognizer *)sender{
    //float scale = sender.scale;
    
    float width = tempRect.size.width * sender.scale;
    float height = tempRect.size.height * sender.scale;
    width = width<100? 100: width;
    height = height<100? 100: height;
    float x = tempRect.origin.x -  offset.x * (sender.scale - 1);
    float y = tempRect.origin.y - offset.y * (sender.scale - 1);
    
    float xOffset = 0;
    float yOffset = 0;
    
    CGSize superviewSize = [self superview].bounds.size;
    
    //x
    if (x<0){
        xOffset = -x;
        if (x+width > superviewSize.width){
            width = superviewSize.width;
        }else{
        }
    }else{
        if (x+width > superviewSize.width){
            xOffset = superviewSize.width -x-width;
        }else{
        }
    }
    if (width> superviewSize.width){
        xOffset = 0;
        x = 0;
        width = superviewSize.width;
    }
    
    //y
    if (y<0){
        yOffset = -y;
        if (y+height > superviewSize.height){
            height = superviewSize.height;
        }else{
        }
    }else{
        if (y+height > superviewSize.height){
            yOffset = superviewSize.height -y-height;
        }else{
        }
    }
    if (height > superviewSize.height){
        yOffset = 0;
        y = 0;
        height = superviewSize.height;
    }

    self.frame = CGRectMake(x, y, width, height);
    self.frame = CGRectOffset(self.frame, xOffset, yOffset);
    
    [self setNeedsDisplay];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    tempRect = self.frame;
}

- (void)setSelect{
    self.layer.borderColor = [[UIColor blueColor] CGColor];
    lineColor = [UIColor blueColor];
    [self setNeedsDisplay];
}

- (void)setDeselect{
    self.layer.borderColor = isAutomatic? faceRectColorAuto.CGColor: faceRectColorMannual.CGColor;
    lineColor = isAutomatic? faceRectColorAuto: faceRectColorMannual;
    [self setNeedsDisplay];
}

@end
