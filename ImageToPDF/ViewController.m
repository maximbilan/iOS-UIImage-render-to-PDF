//
//  ViewController.m
//  ImageToPDF
//
//  Created by Maxim on 11/5/15.
//  Copyright © 2015 Maxim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *aFilename = @"test.pdf";
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	NSString *documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
	
	NSLog(@"%@", documentDirectory);
	
	NSMutableArray *pdfURLs = [NSMutableArray array];
	
	for (NSInteger i = 0; i < 1000; ++i) {
		CGFloat hue = ( arc4random() % 256 / 256.0 );
		CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;
		CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;
		UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
		UIImage *imageToRender = [self imageFromColor:color];
		NSString *pdfFile = [NSString stringWithFormat:@"%@_%@.%@", documentDirectoryFilename.stringByDeletingPathExtension, @(i), documentDirectoryFilename.pathExtension];
		
//		UIGraphicsBeginPDFContextToFile(pdfFile, CGRectMake(0, 0, 1024, 1024), nil);
//		UIGraphicsBeginPDFPage();
//		[imageToRender drawAtPoint:CGPointZero];
//		UIGraphicsEndPDFContext();
		
		NSURL *url = [NSURL fileURLWithPath:pdfFile];
		CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)url, NULL, NULL);
		
		CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)url);
		
		CGRect mediaBox = CGRectMake(0, 0, 1024, 1024);
		
		CGContextBeginPage(context, &mediaBox);
		CGContextDrawImage(context, mediaBox, imageToRender.CGImage);
		CGContextEndPage(context);
		
		CGPDFDocumentRelease(document);
		
		CGPDFContextClose(context);
		CGContextRelease(context);
		
		[pdfURLs addObject:[NSURL fileURLWithPath:pdfFile]];
	}
	
	[self combinePDFURLs:pdfURLs writeToURL:[NSURL fileURLWithPath:documentDirectoryFilename]];
	
}

- (void)combinePDFURLs:(NSArray *)PDFURLs writeToURL:(NSURL *)URL
{
	CGContextRef context = CGPDFContextCreateWithURL((__bridge CFURLRef)URL, NULL, NULL);
	
	for (NSURL *PDFURL in PDFURLs) {
		CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)PDFURL);
		size_t numberOfPages = CGPDFDocumentGetNumberOfPages(document);
		
		for (size_t pageNumber = 1; pageNumber <= numberOfPages; ++pageNumber) {
			CGPDFPageRef page = CGPDFDocumentGetPage(document, pageNumber);
			CGRect mediaBox = CGPDFPageGetBoxRect(page, kCGPDFMediaBox);
			
			CGContextBeginPage(context, &mediaBox);
			CGContextDrawPDFPage(context, page);
			CGContextEndPage(context);
		}
		
		CGPDFDocumentRelease(document);
	}
	
	CGPDFContextClose(context);
	CGContextRelease(context);
}

- (UIImage *)imageFromColor:(UIColor *)color
{
	CGRect rect = CGRectMake(0, 0, 1024, 1024);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [color CGColor]);
	CGContextFillRect(context, rect);
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

@end
