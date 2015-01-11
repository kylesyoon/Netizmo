//
//  AddProfileImageViewController.m
//  Metwork
//
//  Created by Kyle Yoon on 11/14/14.
//  Copyright (c) 2014 yoonapps. All rights reserved.
//

#import "SetUpProfilePictureViewController.h"
#import "MWUser.h"

@interface SetUpProfilePictureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation SetUpProfilePictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    self.imageView.clipsToBounds = YES;
    self.imageView.image = [UIImage imageNamed:@"defaultProfile"];
}

- (IBAction)onChangeTapped:(id)sender {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add your profile picture" message:@"Choose a photo that others can easily identify you by." preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertController *noCameraAlert = [UIAlertController alertControllerWithTitle:@"No camera detected" message:@"You can only choose this option with a device that has a camera." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [noCameraAlert dismissViewControllerAnimated:YES completion:nil];
            }];
            [noCameraAlert addAction:okayAction];
            [self presentViewController:noCameraAlert animated:YES completion:nil];
        } else {
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:self.imagePicker animated:YES completion:nil];
            [alertController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    UIAlertAction *choosePhotoFromLibrary = [UIAlertAction actionWithTitle:@"Choose photo from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:takePhotoAction];
    [alertController addAction:choosePhotoFromLibrary];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *selectedImage = info[UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImageJPEGRepresentation(selectedImage, 0.1f);
    PFFile *imageFile = [PFFile fileWithName:@"profile" data:imageData];
    [MWUser currentUser].profileImageFile = imageFile;
    [[MWUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Image saving error: %@", error);
        } else {
            NSLog(@"Successful save of profile picture");
        }
    }];
    self.imageView.image = selectedImage;
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

@end
