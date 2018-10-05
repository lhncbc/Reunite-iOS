//
//  ScannerController.m
//  ReUnite + TriagePic
//


#import "ScannerController.h"
@import AVFoundation;
@interface ScannerController () <AVCaptureMetadataOutputObjectsDelegate>

@end

@implementation ScannerController
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;
    
    UIView *_highlightView;
    NSString *_detectedString;
    BOOL _alertIsShown;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   // [self setTitle:@"Scan Barcode"];
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        DLog(@"Error: %@", error);
    }
    
    // Locks the configuration
    BOOL success = [_device lockForConfiguration:nil];
    if (success) {
        if ([_device isAutoFocusRangeRestrictionSupported]) {
            
            // Restricts the autofocus to near range (new in iOS 7)
            [_device setAutoFocusRangeRestriction:AVCaptureAutoFocusRangeRestrictionNear];
        }
    }
    // unlocks the configuration
    [_device unlockForConfiguration];
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    //[self.view bringSubviewToFront:_highlightView];
    //[self.view bringSubviewToFront:_label];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

    if (![_session isRunning])
    {
        [_session startRunning];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
   // NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        /*for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }*/
        barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
        highlightViewRect = barCodeObject.bounds;
        NSString *detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];

        if (detectionString != nil && !_alertIsShown) {
            //DLog(@"Found This matching%@", metadata.type);
            _alertIsShown = YES;
            _detectedString = detectionString;
           // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Is this correct?" message:_detectedString delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
           // [alertView show];
            [_session stopRunning];
            break;
        }
    }
    
    _highlightView.frame = highlightViewRect;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _alertIsShown = NO;
    switch (buttonIndex) {
        case 0: // NO
            [_session startRunning];
            break;
        case 1: // YES
            [self.navigationController popViewControllerAnimated:YES];
            [_delegate successScanWithString:_detectedString];
            break;
        default:
            break;
    }
}


@end
