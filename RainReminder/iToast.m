\
#import "iToast.h"
#import <QuartzCore/QuartzCore.h>

#define TEXT_MARGIN  20
#define TITLE_MARGIN  8

#define TEXT_MAX_SIZE CGSizeMake(200, 100)

static iToastSettings       *_sharedSettings = nil;
static UIWindow             *_sharedToastWindow = nil;

static NSMutableArray       *_iToastQueue = nil;
static NSString             *_lockForQueue = @"";

@implementation iToast

@synthesize title = _title;
@synthesize group = _group;

+ (UIWindow*)sharedToastWindow{
    if (_sharedToastWindow == nil){
        _sharedToastWindow = [[UIWindow alloc] init];
        _sharedToastWindow.userInteractionEnabled = NO;
        _sharedToastWindow.windowLevel = UIWindowLevelAlert+100;
    }
    return _sharedToastWindow;
}

- (id) initWithText:(NSString *) tex{
	if (self = [super init]) {
		_text = [tex copy];
	}
	
	return self;
}

- (void)dealloc
{
    self.settings = nil;
}

- (iToastSettings *)settings
{
	if (!_settings) {
		_settings = [[iToastSettings getSharedSettings] copy];
	}
    return _settings;
}

- (void)setSettings:(iToastSettings *)settings
{
    if (_settings != settings){
        _settings = settings;
    }
}

- (void)realShow
{
    // set content text
	UIFont *font = [UIFont systemFontOfSize:16];
	CGSize textSize = [_text sizeWithFont:font constrainedToSize:CGSizeMake(200, 100)];
	
    CGRect rcText = CGRectMake(0, 0, textSize.width, textSize.height);
	UILabel *label = [[UILabel alloc] initWithFrame:rcText];
    label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.font = font;
	label.text = _text;
	label.numberOfLines = 0;
	label.shadowColor = [UIColor darkGrayColor];
//	label.shadowOffset = CGSizeMake(1, 1);
	
    // set title
    UILabel *titleLabel = nil;
    if (_title){
        UIFont *font = [UIFont systemFontOfSize:19];
        CGSize titleTextSize = [_title sizeWithFont:font constrainedToSize:TEXT_MAX_SIZE];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, TITLE_MARGIN, textSize.width, titleTextSize.height)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = font;
        titleLabel.text = _title;
        titleLabel.numberOfLines = 1;
        titleLabel.shadowColor = [UIColor darkGrayColor];
//        titleLabel.shadowOffset = CGSizeMake(1, 1);
        titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    CGRect rcContent = CGRectMake(0, 0, rcText.size.width, rcText.size.height);
    if (titleLabel){
        rcContent.size.height += TEXT_MARGIN + titleLabel.frame.size.height + TITLE_MARGIN;
    }else{
        rcContent.size.height += TEXT_MARGIN*2;
    }
    UIView *contentView = [[UIView alloc] initWithFrame:rcContent];
    CGPoint center = contentView.center;
    if (titleLabel){
        center.y += TITLE_MARGIN;
        [contentView addSubview:titleLabel];
    }
    label.center = center;
    [contentView addSubview:label];
    
    UIImageView * imgView = nil;
    if (_img) {
        imgView = [[UIImageView alloc] initWithImage:_img];
    }
    if (imgView) {
        if (!CGSizeEqualToSize(_imgSz, CGSizeZero)) {
            imgView.bounds = CGRectMake(0, 0, _imgSz.width, _imgSz.height);
        }
        imgView.center = CGPointMake(contentView.bounds.size.width/2.0, contentView.bounds.size.height/2.0);
        [contentView addSubview:imgView];
    }
    
    CGRect rcButton = CGRectMake(0, 0, contentView.frame.size.width + TEXT_MARGIN*2, contentView.frame.size.height);
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = rcButton;
    contentView.center = CGPointMake(button.frame.size.width / 2, button.frame.size.height / 2);
	[button addSubview:contentView];
    
    if (nil == imgView) {
        button.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.5];
    } else {
        button.backgroundColor = [UIColor clearColor];
    }
	button.layer.cornerRadius = 5;
	
	UIWindow *window = [iToast sharedToastWindow];
    CGRect rcScreen = [[UIScreen mainScreen] bounds];
    CGRect rcWindow = window.frame;
    rcWindow.size = button.frame.size;
    window.frame = rcWindow;
    window.center = CGPointMake(CGRectGetMidX(rcScreen), CGRectGetMidY(rcScreen));
    window.hidden = NO;
    
	CGPoint point;
	
	if (self.settings._gravity == iToastGravityTop) {
		point = CGPointMake(window.frame.size.width / 2, 45);
	}else if (self.settings._gravity == iToastGravityBottom) {
		point = CGPointMake(window.frame.size.width / 2, window.frame.size.height - 45);
	}else if (self.settings._gravity == iToastGravityCenter) {
		point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
	}else{
		point = self.settings._postition;
	}
	
	point = CGPointMake(point.x + _offsetLeft, point.y + _offsetTop);
	button.center = point;
	
	NSTimer *timer1 = [NSTimer timerWithTimeInterval:((float)self.settings._delay+self.settings._duration)/1000 
                                              target:self selector:@selector(hideToast:) 
                                            userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer1 forMode:NSDefaultRunLoopMode];
	
	[window addSubview:button];
	
	_view = button;
    
    _view.alpha = 0;
    [UIView animateWithDuration:self.settings._delay/1000.0f animations:^{
        _view.alpha=1;
    }];
    // Rotate each iteration by 1% of PI
    CGFloat angle;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    // Choose the transform
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        angle = 150.0f * (M_PI / 100.0f);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        angle = 50.0f * (M_PI / 100.0f);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        angle = 100.0f * (M_PI / 100.0f);
    } else {
        angle = 0.0f * (M_PI / 100.0f);
    }    
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    
    
    // For fun, scale by the absolute value of the cosine
    float degree = 1.0;
	// Create add scaling to the rotation transform
    CGAffineTransform scaled = CGAffineTransformScale(transform, degree, degree);
	
    // Apply the affine transform
    [_view setTransform:scaled];
}

- (void) show{
    @synchronized(_lockForQueue){
        if (!_iToastQueue){
            _iToastQueue = [[NSMutableArray alloc] initWithCapacity:1];
        }
        if (_img) {
            if ([_iToastQueue containsObject:_img])
                return;
            else
                [_iToastQueue addObject:_img];
        } else if (_text) {
            if ([_iToastQueue containsObject:_text])
                return;
            else
                [_iToastQueue addObject:_text];
        }
     
        if (_iToastQueue.count == 1){
            [self realShow];
        }
    }

}

- (void) hideToast:(NSTimer*)theTimer{
    [UIView animateWithDuration:self.settings._duration/1000.0f animations:^{
        _view.alpha = 0;
        [_view removeFromSuperview];
    } completion:^(BOOL finished) {
        @synchronized(_lockForQueue){
            if (_iToastQueue.count > 0) {
                [_iToastQueue removeObjectAtIndex:0];
            }
            [iToast sharedToastWindow].hidden = YES;
            if (_iToastQueue.count >= 1){
                id text = [_iToastQueue objectAtIndex:0];
                if ([text isKindOfClass:[NSString class]]) {
                    [[iToast makeText:text] realShow];
                } else if ([text isKindOfClass:[UIImage class]]) {
                    [[iToast makeImage:text] realShow];
                }
            }
        }
        
    }];
    
}


+ (iToast *) makeText:(NSString *) text{
    return [iToast makeText:text title:nil];
}

+ (iToast *)makeText:(NSString *)text group:(NSString *)group
{
    iToast *toast = [iToast makeText:text];
    [toast setGroup:group];
    return toast;
}

+ (void)cancelGroup:(NSString *)group
{
    
}

+ (iToast *) makeText:(NSString *)text title:(NSString*)title
{
    if (!text || text.length == 0){
        return nil;
    }
    
    iToast *toast = [[iToast alloc] initWithText:text];
    if (title && title.length > 0){
        [toast setTitle:title];
    }
    return toast;
}

+ (iToast *) makeImage:(UIImage *)img
{
    if (!img){
        return nil;
    }
    
    iToast *toast = [[iToast alloc] init];
    toast->_img = img;
    return toast;
}

+ (iToast *) makeImage:(UIImage *)img forSize:(CGSize)sz
{
    iToast *toast = [iToast makeImage:img];
    toast->_imgSz = sz;
    return toast;
}


- (iToast *)setDelay:(CGFloat)delay
{
    [self settings]._delay = delay;
    return self;
}

- (iToast *) setDuration:(CGFloat) duration{
	[self settings]._duration = duration;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(CGFloat) left
			  offsetTop:(CGFloat) top{
	[self settings]._gravity = gravity;
	_offsetLeft = left;
	_offsetTop = top;
	return self;
}

- (iToast *) setGravity:(iToastGravity) gravity{
	[self settings]._gravity = gravity;
	return self;
}

- (iToast *) setPostion:(CGPoint) _position{
	[self settings]._postition = CGPointMake(_position.x, _position.y);
	return self;
}

- (iToast *) setToastType:(iToastType) type {
    [self settings]._toastType = type;
	return self;
}

@end


@implementation iToastSettings
@synthesize _delay;
@synthesize _duration;
@synthesize _gravity;
@synthesize _postition;
@synthesize _toastType;
@synthesize _images;

- (void) setImage:(UIImage *) img forType:(iToastType) type{
	if (!_images) {
		_images = [[NSMutableDictionary alloc] initWithCapacity:4];
	}
	
	if (img) {
		NSString *key = [NSString stringWithFormat:@"%i", type];
		[_images setValue:img forKey:key];
	}
}


+ (iToastSettings *) getSharedSettings{
	if (!_sharedSettings) {
		_sharedSettings = [iToastSettings new];
		_sharedSettings._gravity = iToastGravityCenter;
		_sharedSettings._duration = iToastDurationShort;
        _sharedSettings._delay    = iToastDelayNormal;
	}
	
	return _sharedSettings;
	
}

- (id) copyWithZone:(NSZone *)zone{
	iToastSettings *copy = [iToastSettings new];
	copy._gravity = self._gravity;
	copy._duration = self._duration;
	copy._postition = self._postition;
    copy._delay     = self._delay;
	
	NSArray *keys = [self._images allKeys];
	
	for (NSString *key in keys){
		[copy setImage:[_images valueForKey:key] forType:[key intValue]];
	}
	
	return copy;
}

@end