

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kMsgWindowDidDismiss            @"msgWindowHide"

typedef enum iToastGravity {
	iToastGravityTop = 1000001,
	iToastGravityBottom,
	iToastGravityCenter
}iToastGravity;


typedef enum iToastDelay{
	iToastDelayLong   = 1000,
    iToastDelayNormal = 300,
	iToastDelayShort  = 100,
    iToastDelayNone   = 0
}iToastDelay;

typedef enum iToastDuration{
	iToastDurationLong = 10000,
    iToastDurationNormal = 3000,
	iToastDurationShort = 1000
}iToastDuration;

typedef enum iToastType {
	iToastTypeInfo = -100000,
	iToastTypeNotice,
	iToastTypeWarning,
	iToastTypeError,
    iToastTypeCustom,
    iToastTypeCustom1,
    iToastTypeCustom2
}iToastType;


@class iToastSettings;

@interface iToast : NSObject {
	iToastSettings  *_settings;
	NSInteger       _offsetLeft;
	NSInteger       _offsetTop;
	
	UIView          *_view;
    NSString        *_title;
	NSString        *_text;
    
    UIImage         *_img;
    CGSize          _imgSz;

}

@property (nonatomic, strong) iToastSettings *settings;
@property (nonatomic, strong) NSString       *title;
@property (nonatomic, strong) NSString       *group;

- (void) show;

- (iToast *) setDelay:(CGFloat) delay;
- (iToast *) setDuration:(CGFloat) duration;
- (iToast *) setGravity:(iToastGravity) gravity 
			 offsetLeft:(CGFloat) left
			 offsetTop:(CGFloat) top;
- (iToast *) setGravity:(iToastGravity) gravity;
- (iToast *) setPostion:(CGPoint) position;
- (iToast *) setToastType:(iToastType) type;

+ (iToast *) makeText:(NSString *)text;
+ (iToast *) makeText:(NSString *)text group:(NSString*)group;
+ (iToast *) makeText:(NSString *)text title:(NSString*)title;
+ (void) cancelGroup:(NSString*)group;

+ (iToast *) makeImage:(UIImage *)img;
+ (iToast *) makeImage:(UIImage *)img forSize:(CGSize)sz;

@end



@interface iToastSettings : NSObject<NSCopying>{
    CGFloat             _delay;
	CGFloat             _duration;
	iToastGravity       _gravity;
	CGPoint             _postition;
	iToastType          _toastType;
	
	NSDictionary        *_images;
	
	BOOL                _positionIsSet;
}

@property(nonatomic, assign) CGFloat           _delay;
@property(nonatomic, assign) CGFloat           _duration;
@property(nonatomic, assign) iToastGravity     _gravity;
@property(nonatomic, assign) iToastType        _toastType;
@property(nonatomic, assign) CGPoint           _postition;
@property(nonatomic, readonly) NSDictionary    *_images;


- (void) setImage:(UIImage *)img forType:(iToastType) type;
+ (iToastSettings *) getSharedSettings;
						  
@end