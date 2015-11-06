# iOS Render UIImage to PDF and merging PDF files

![alt tag](https://raw.github.com/maximbilan/iOS-UIImage-render-to-PDF/master/img/img1.png)

Some code samples for working with PDF. Let’s try to generate 1000 images and render to PDF file. For this we need method for generating random color and method for creating UIImage from UIColor.

Random color:

<pre>
</pre>

And UIImage from UIColor:

<pre>
</pre>

And now we can render random images to PDF file.

<pre>
</pre>

Attention! Necessarily use @autoreleasepool, otherwise you will have memory leaks.

Also I would like to provide some sample for generating PDF files and merging these files. It’s also simple.

<pre>
</pre>

And of course, implementation of combinePDFURLs method, see below:

<pre>
</pre>

And result:

![alt tag](https://raw.github.com/maximbilan/iOS-UIImage-render-to-PDF/master/img/img2.png)

Happy coding!
