#import <UIKit/UIKit.h>

@interface YTPlayerView : UIView
@end

%hook YTPlayerView

static UIButton *flipperButton = nil;

// Hook vào phương thức initWithFrame để thêm nút
- (id)initWithFrame:(CGRect)frame {
    id orig = %orig; // Gọi phương thức gốc

    // Tạo nút Flipper với text "Flip"
    if (!flipperButton) {
        flipperButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [flipperButton setTitle:@"Flip" forState:UIControlStateNormal];
        [flipperButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        flipperButton.titleLabel.font = [UIFont systemFontOfSize:14];
        flipperButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
        flipperButton.layer.cornerRadius = 5;
        flipperButton.frame = CGRectMake(0, 0, 50, 30);
        [flipperButton addTarget:self action:@selector(flipperButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flipperButton];
    }

    return orig;
}

// Hook vào layoutSubviews để định vị nút
- (void)layoutSubviews {
    %orig; // Gọi phương thức gốc

    // Tìm nút full màn hình (có thể cần kiểm tra tên chính xác)
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.frame.size.width == 40 && subview.frame.size.height == 40) {
            // Giả sử đây là nút full màn hình (kiểm tra kích thước)
            CGRect fullscreenFrame = subview.frame;
            flipperButton.frame = CGRectMake(
                fullscreenFrame.origin.x - 60,
                fullscreenFrame.origin.y + (fullscreenFrame.size.height - 30) / 2,
                50,
                30
            );
            break;
        }
    }
}

// Phương thức xử lý khi nhấn nút
%new
- (void)flipperButtonTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"YTFlipper"
                                                                 message:@"Flip button tapped!"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:alert animated:YES completion:nil];
}

%end