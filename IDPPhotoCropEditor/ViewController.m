//
//  ViewController.m
//  IDPPhotoCropEditor
//
//  Created by 能登 要 on 2016/10/17.
//  Copyright © 2016年 Kaname Noto. All rights reserved.
//

#import "ViewController.h"
#import "IDPCropViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *adjustAngleButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (strong,nonatomic) UIImage* originalImage;
@property (strong,nonatomic) NSDictionary* cropData;
@property (assign,nonatomic) CGFloat cropAspectRatio;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(0);
//    NSLog(@"transform=%@",[NSValue valueWithCGAffineTransform:transform] );
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButton.enabled = !!self.imageView.image;
    self.adjustAngleButton.enabled = !!self.imageView.image;
}

- (void)viewDidUnload
{
    self.editButton = nil;
    self.imageView = nil;
    self.cameraButton = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -

- (void)cropViewController:(IDPCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage cropData:(NSDictionary*)cropData
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    
    if( controller.editMode == IDPCropViewEditModeCrop ){
//        NSLog(@"cropData=%@", cropData );
        self.cropData = cropData;
        self.cropAspectRatio = controller.cropAspectRatio;
    }
    
    self.imageView.image = croppedImage;
}

- (void)cropViewControllerDidCancel:(IDPCropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark -

- (IBAction)openEditor:(id)sender
{
    id viewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"cropViewController"];
    UINavigationController *navigationController = [viewcontroller isKindOfClass:[UINavigationController class]] ? viewcontroller : nil;
    
    IDPCropViewController* controller = [navigationController.topViewController isKindOfClass:[IDPCropViewController class]] ? (IDPCropViewController *)navigationController.topViewController : nil;
    
    controller.delegate = self;
    controller.image = self.originalImage;
    controller.cropData = self.cropData;
    controller.edgeInsets = UIEdgeInsetsMake(19.0f, 9.0f, 19.0f, 9.0f);
    
    //    controller.toolBarHidden = YES;
    
    double ratio = _cropAspectRatio != .0f ? _cropAspectRatio : /*controller.image.size.width / controller.image.size.height*/ 1 /*1 / 1.0f*/ /*1.52597*/; /* 縦横比確保 */
    controller.cropAspectRatio = ratio;
    controller.keepingCropAspectRatio = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
  
}

- (IBAction)adjustAngle:(id)sender
{
    IDPCropViewController *controller = [[IDPCropViewController alloc] init];
    controller.delegate = self;
    controller.image = _imageView.image;
    controller.cropData = nil;
    
    double ratio = _cropAspectRatio != .0f ? _cropAspectRatio : /*controller.image.size.width / controller.image.size.height*/ 1 /*1 / 1.0f*/ /*1.52597*/; /* 縦横比確保 */
    controller.cropAspectRatio = ratio;
    controller.keepingCropAspectRatio = YES;
    controller.editMode = IDPCropViewEditModeAngleAdjustment;
    
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
    
}

- (IBAction)cameraButtonAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Photo Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:controller animated:YES completion:NULL];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIImagePickerController *controller = [[UIImagePickerController alloc] init];
        controller.delegate = self;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:controller animated:YES completion:^{
           
        }];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        
    }]];

    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}

#pragma mark -

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.originalImage = image;
    self.imageView.image = image;
    self.cropData = nil;

    [picker dismissViewControllerAnimated:YES completion:^{
        [self openEditor:nil];
    }];

}

@end
