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
	
	NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
	NSString *documentDirectory = [documentDirectories objectAtIndex:0];
	
	NSString *aFilename = @"test.pdf";
	NSString *documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
	
	NSLog(@"%@", documentDirectory);
	
	// Render 1000 UIImage objects to PDF file
	
	UIGraphicsBeginPDFContextToFile(documentDirectoryFilename, CGRectMake(0, 0, 1024, 1024), nil);
	
	for (NSInteger i = 0; i < 1000; ++i) {
		UIImage *image = [self imageFromColor:[self randomColor]];
		
		@autoreleasepool {
			UIGraphicsBeginPDFPage();
			[image drawAtPoint:CGPointZero];
		}
	}
	
	UIGraphicsEndPDFContext();
	
	aFilename = @"test_merge.pdf";
	documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
	
	// Render image to PDF file and merging 1000 pdf files to one PDF File
	
	NSMutableArray *pdfURLs = [NSMutableArray array];
	for (NSInteger i = 0; i < 1000; ++i) {
	
		NSString *pdfFile = [NSString stringWithFormat:@"%@_%@.%@", documentDirectoryFilename.stringByDeletingPathExtension, @(i), documentDirectoryFilename.pathExtension];
		UIImage *imageToRender = [self imageFromColor:[self randomColor]];
		
		@autoreleasepool {
			UIGraphicsBeginPDFContextToFile(pdfFile, CGRectMake(0, 0, 1024, 1024), nil);
			UIGraphicsBeginPDFPage();
			[imageToRender drawAtPoint:CGPointZero];
			UIGraphicsEndPDFContext();
		}
		
		[pdfURLs addObject:[NSURL fileURLWithPath:pdfFile]];
	}
	
	[self combinePDFURLs:pdfURLs writeToURL:[NSURL fileURLWithPath:documentDirectoryFilename]];
	
	for (NSURL *pdfUrl in pdfURLs) {
		[[NSFileManager defaultManager] removeItemAtURL:pdfUrl error:nil];
	}
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

- (UIColor *)randomColor
{
	CGFloat hue = (arc4random() % 256 / 256.0);
	CGFloat saturation = (arc4random() % 128 / 256.0 ) + 0.5;
	CGFloat brightness = (arc4random() % 128 / 256.0 ) + 0.5;
	return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
