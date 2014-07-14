//
//  attributedLabel.m
//  easyAttributedLabel
//
//  Created by xwd on 14-7-14.
//  Copyright (c) 2014年 xwd. All rights reserved.
//


#import "attributedLabel.h"
#import <CoreText/CoreText.h>

@interface attributedLabel()
@property (nonatomic, assign) CFMutableAttributedStringRef cfAttributedStringRef;
@property (nonatomic, assign) CTFramesetterRef ctFrameSetter;
@property (nonatomic, assign) CTFrameRef ctFrame;
@end

@implementation attributedLabel

#pragma -mark init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefault];
    }
    return self;
}

#pragma -mark &setProperty
- (void)setDefault {
    self.textFront = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    self.lineGap = 3;
    self.textColor = [UIColor blackColor];
    self.shouldTruncate = YES;
}

- (void)setStytleWithLeading:(NSInteger)leading textcolor:(UIColor *)textcolor textfrot:(UIFont *)textfont truncate: (BOOL)shouldtruncate {
    self.lineGap = leading;
    self.textColor = textcolor;
    self.textFront = textfont;
    self.shouldTruncate = shouldtruncate;
}

#pragma SetAttribute
- (void)builtAttributedString {
    [self setParagraphStytle];
    [self setLineStytle];
}

- (void)setParagraphStytle {
    CGFloat linespace = self.lineGap;
    CTParagraphStyleSetting lineSpaceSetting;
    lineSpaceSetting.spec = kCTParagraphStyleSpecifierLineSpacing;
    lineSpaceSetting.value = &linespace;
    lineSpaceSetting.valueSize = sizeof(float);
    
    CTParagraphStyleSetting settings[] = {lineSpaceSetting};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName];
    
    CFAttributedStringSetAttributes(self.cfAttributedStringRef,CFRangeMake(0, self.text.length) , (__bridge CFDictionaryRef)attributes, NO);
    CFRelease(style);
}

- (void)setLineStytle {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithObject:(id)self.textColor.CGColor forKey:(id)kCTForegroundColorAttributeName];
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.textFront.fontName, self.textFront.pointSize, NULL);
    [attributes setObject:(__bridge id)font forKey:(id)kCTFontAttributeName];
    CFAttributedStringSetAttributes(self.cfAttributedStringRef, CFRangeMake(0, self.text.length), (__bridge CFDictionaryRef)attributes, NO);
    
    CFRelease(font);
}


#pragma -mark Draw
- (void)drawTextInRect:(CGRect)rect {
    if(self.text == nil || self.text.length == 0){
		return;
	}
    
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    self.cfAttributedStringRef = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString(self.cfAttributedStringRef, CFRangeMake(0, 0), (__bridge CFStringRef)self.text);
    [self builtAttributedString];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    self.ctFrameSetter = CTFramesetterCreateWithAttributedString(self.cfAttributedStringRef);
    self.ctFrame= CTFramesetterCreateFrame(self.ctFrameSetter,CFRangeMake(0, 0), path, NULL);
    
    if (self.shouldTruncate) {
        [self drawTextWhenTruncated];
    } else {
        CTFrameDraw(self.ctFrame, context);
    };
    
    CFRelease(path);
    CFRelease(self.ctFrame);
    CFRelease(self.ctFrameSetter);
    CFRelease(self.cfAttributedStringRef);
}

- (void)drawTextWhenTruncated {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CFArrayRef lineArray = CTFrameGetLines(self.ctFrame);
    CFIndex linesNum = CFArrayGetCount(lineArray);
    CGPoint perLineOrigin[linesNum];
    CFRange range = CFRangeMake(0, linesNum);
    
    CTFrameGetLineOrigins(self.ctFrame, range, perLineOrigin);
    for (CFIndex i = 0; i < linesNum-1; i++) {
        CGContextSetTextPosition(context, perLineOrigin[i].x, perLineOrigin[i].y);
        CTLineRef line = CFArrayGetValueAtIndex(lineArray, i);
        CTLineDraw(line, context);
    }
    
    CGPoint lastOrigin = perLineOrigin[linesNum-1];
    CTLineRef lastLine = CFArrayGetValueAtIndex(lineArray, linesNum-1);
    CFDictionaryRef stringAttrs = nil;
    CFAttributedStringRef truncationString = CFAttributedStringCreate(NULL, CFSTR("..."), stringAttrs);
    CTLineRef truncationToken = CTLineCreateWithAttributedString(truncationString);
    CFRange longRange = CFRangeMake(CTLineGetStringRange(lastLine).location, 0);
    longRange.length = CFAttributedStringGetLength(self.cfAttributedStringRef) - longRange.location;
    CFAttributedStringRef longString = CFAttributedStringCreateWithSubstring(NULL, self.cfAttributedStringRef, longRange);
    CTLineRef longLine = CTLineCreateWithAttributedString(longString);
    CTLineRef truncated = CTLineCreateTruncatedLine(longLine, self.frame.size.width, kCTLineTruncationEnd, truncationToken);
    
    CGContextSetTextPosition(context, lastOrigin.x, lastOrigin.y);
    CTLineDraw(truncated, context);
    
    CFRelease(truncationString);
    CFRelease(truncationToken);
    CFRelease(longLine);
    CFRelease(truncated);
    CFRelease(longString);
}

@end

