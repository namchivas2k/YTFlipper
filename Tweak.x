#import <UIKit/UIKit.h>

%hook YTMainAppVideoPlayerOverlayView

static UIButton *flipperButton = nil;

// Hook vào phương thức initWithFrame để thêm nút
- (id)initWithFrame:(CGRect)frame {
    id orig = %orig; // Gọi phương thức gốc

    // Tạo nút Flipper với text "Flip"
    if (!flipperButton) {
        flipperButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [flipperButton setTitle:@"Flip" forState:UIControlStateNormal];
        [flipperButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        flipperButton.titleLabel.font = [UIFont systemFontOfSize:14]; // Kích thước chữ
        flipperButton.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7]; // Nền tối để dễ nhìn
        flipperButton.layer.cornerRadius = 5; // Bo góc
        flipperButton.frame = CGRectMake(0, 0, 50, 30); // Kích thước nút
        [flipperButton addTarget:self action:@selector(flipperButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:flipperButton];
    }

    return orig;
}

// Hook vào layoutSubviews để định vị nút
- (void)layoutSubviews {
    %orig; // Gọi phương thức gốc

    // Lấy vị trí nút full màn hình để đặt nút Flipper gần đó
    UIView *fullscreenButton = [self valueForKey:@"_fullscreenButton"]; // Có thể cần kiểm tra tên chính xác
    if (fullscreenButton) {
        CGRect fullscreenFrame = fullscreenButton.frame;
        // Đặt nút Flipper ngay bên trái nút full màn hình
        flipperButton.frame = CGRectMake(
            fullscreenFrame.origin.x - 60, // Cách nút full màn hình 10px
            fullscreenFrame.origin.y + (fullscreenFrame.size.height - 30) / 2, // Căn giữa theo chiều dọc
            50,
            30
        );
    }
}

// Phương thức xử lý khi nhấn nút
%new
- (void)flipperButtonTapped {
    // Thêm hành động tùy chỉnh tại đây
    // Ví dụ: Hiển thị thông báo
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