# iOS Render UIImage to PDF and merging PDF files

![alt tag](https://raw.github.com/maximbilan/iOS-UIImage-render-to-PDF/master/img/img1.png)

Some code samples for working with <i>PDF</i>. Let’s try to generate 1000 images and render to <i>PDF</i> file. For this we need method for generating random color and method for creating <i>UIImage</i> from <i>UIColor</i>.

Random color:

<pre>
- (UIColor *)randomColor
{
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0 ) + 0.5;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}
</pre>

And <i>UIImage</i> from <i>UIColor</i>:

<pre>
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
</pre>

And now we can render random images to <i>PDF</i> file.

<pre>
UIGraphicsBeginPDFContextToFile(filename, CGRectMake(0, 0, 1024, 1024), nil);

for (NSInteger i = 0; i < 1000; ++i) {
    UIImage *image = [self imageFromColor:[self randomColor]];

    @autoreleasepool {
        UIGraphicsBeginPDFPage();
        [image drawAtPoint:CGPointZero];
    }
}

UIGraphicsEndPDFContext();
</pre>

<b>Attention!</b> Necessarily use <i>@autoreleasepool</i>, otherwise you will have memory leaks.

Also I would like to provide some sample for generating <i>PDF</i> files and merging these files. It’s also simple.

<pre>
NSMutableArray *pdfURLs = [NSMutableArray array];

for (NSInteger i = 0; i < 1000; ++i) {
    NSString *pdfFile = [NSString stringWithFormat:@”%@_%@”, filename, @(i)];
    UIImage *imageToRender = [self imageFromColor:[self randomColor]];
  
    @autoreleasepool {
        UIGraphicsBeginPDFContextToFile(pdfFile, CGRectMake(0, 0, 1024, 1024), nil);
        UIGraphicsBeginPDFPage();
        [imageToRender drawAtPoint:CGPointZero];
        UIGraphicsEndPDFContext();
    }

    [pdfURLs addObject:[NSURL fileURLWithPath:pdfFile]];
}

[self combinePDFURLs:pdfURLs writeToURL:[NSURL fileURLWithPath:filename]];

for (NSURL *pdfUrl in pdfURLs) {
    [[NSFileManager defaultManager] removeItemAtURL:pdfUrl error:nil];
}
</pre>

And of course, implementation of <i>combinePDFURLs</i> method, see below:

<pre>
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
</pre>

And result:

![alt tag](https://raw.github.com/maximbilan/iOS-UIImage-render-to-PDF/master/img/img2.png)

Happy coding!
