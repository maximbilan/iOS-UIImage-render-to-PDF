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
	
	UIImage *image1 = [UIImage imageNamed:@"image1.png"];
	UIImage *image2 = [UIImage imageNamed:@"image2.png"];
	UIImage *image3 = [UIImage imageNamed:@"image3.png"];
	
	NSArray *images = @[image1, image2, image3];
	NSMutableArray *pdfURLs = [NSMutableArray array];
	
	for (NSInteger i = 0; i < 1000; ++i) {
		UIImage *imageToRender = image1;
		NSString *pdfFile = [NSString stringWithFormat:@"%@_%@.%@", documentDirectoryFilename.stringByDeletingPathExtension, @(i), documentDirectoryFilename.pathExtension];
		
		UIGraphicsBeginPDFContextToFile(pdfFile, CGRectMake(0, 0, 1024, 1024), nil);
		UIGraphicsBeginPDFPage();
		[imageToRender drawAtPoint:CGPointZero];
		UIGraphicsEndPDFContext();
		
		[pdfURLs addObject:[NSURL fileURLWithPath:pdfFile]];
	}
	
	[self combinePDFURLs:pdfURLs writeToURL:[NSURL fileURLWithPath:documentDirectoryFilename]];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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

@end
