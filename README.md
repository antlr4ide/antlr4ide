[![Build Status](https://travis-ci.org/antlr4ide/antlr4ide.png?branch=master)](https://travis-ci.org/antlr4ide/antlr4ide)
[ ![Download](https://api.bintray.com/packages/jknack/antlr4ide/antlr4ide/images/download.png) ](https://bintray.com/jknack/antlr4ide/antlr4ide/_latestVersion)

ANTLR 4 IDE
=========

![ANTLR 4 IDE](https://raw.github.com/jknack/antlr4ide/master/updates/screenshots/full.png)


Features
=========

* ANTLR 4.x
* Advanced Syntax Highlighting ([even for target language](https://raw.github.com/jknack/antlr4ide/master/updates/screenshots/target-language-highlighting.png))
* Automatic Code Generation (on save)
* Manual Code Generation (through External Tools menu)
* Code Formatter (Ctrl+Shift+F)
* [Syntax Diagrams as HTML](http://jknack.github.io/antlr4ide/Java/Javav4.g4.html)
* Live Parse Tree evaluation
* Advanced Rule Navigation between files (F3 or Ctrl+Click over a rule)
* Quick fixes


Welcome
=========

This is brand new version of the **old** [ANTLR IDE](http://antlrv3ide.sourceforge.net/). The new IDE supports ANTLR 4.x and it was created to run on Eclipse 4.x

The **old** [ANTLR IDE](http://antlrv3ide.sourceforge.net/) isn't supported anymore. When I wrote it, I was young and didn't know what was doing ;)

Don't get me wrong, the old version did a very good work from  user point of view, it just I'm not proud of the code base because is kind of complex and had a poor quality.

The main reason of complexity of the old IDE was in Dynamic Language ToolKit (DLTK) dependency. The DLTK project didn't evolve so much over the last few years and doing something in DLTK is very very complex and require a lot of work.

Now, the **new** IDE was built on [XText](http://www.eclipse.org/Xtext). [XText](http://www.eclipse.org/Xtext) is great for building DSL with Eclipse IDE support, so if you are not familiar with [XText](http://www.eclipse.org/Xtext) go and see it.

Eclipse Installation
=========

Prerequisites
---------

* Eclipse 4.4 Luna Xtext Complete SDK(Needs to be version 2.7.3)
* Eclipse Faceted Project Framework (Tested with 3.4.0) Eclipse Faceted
* Project Framework JDT Enablement(Tested with 3.4.0) ANTLR 4 SDK A
* A copy of the antlr-4.x-complete.jar (4.5 at the time of writing)

Installation
---------

1. Install Eclipse (4.4 Luna)
	1. Download it from https://www.eclipse.org/downloads/
2. Install XText 2.7.3
	1. Go to ```Help > Install New Software...```
	2. Enter ```http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/``` in the ```Work With``` textbox
	3. Hit Enter and wait for the list to load (this will take a few moments)
	4. Expand the ```Xtext``` node and check ```Xtext Complete SDK``` (ensure the version is 2.7.3x)
	5. Click ```Next```, agree to the EULA, and click finish
	6. Let the installer finish and restart Eclipse
3. Install Faceted Project Framework
	1. Go to ```Help > Install New Software...```
	2. Enter ```http://download.eclipse.org/releases/luna``` in the ```Work With``` textbox
	3. Hit Enter and wait for the list to load (this will take a few moments)
	4. In the filter text box enter ```Facet```
	5. Select ```Eclipse Faceted Project Framework``` and ```Eclipse Faceted Project Framework JDT Enablement```
	6. Click ```Next```, agree to the EULA, and click finish
	7. Let the installer finish and restart Eclipse
4. Install ANTLR 4 IDE
	1. Go to ```Help > Eclipse Marketplace...```
	2. Search for ```antlr```
	3. Choose ```ANTLR 4 IDE``` (make sure it's ANTLR 4 IDE not ANTLR IDE)
	4. Click Install
	5. Let the installer finish clicking ok if it prompts and restart Eclipse
5. Obtain a copy of antlr-4.x-complete.jar
	1. Download the file from [here](http://www.antlr.org/download.html)
	2. Save it somewhere you'll remember

Creating a project in Eclipse
---------
1. Go to ```File > New Project > Project```
2. Expand the ```General Tab``` and select ```ANTLR 4 Project``` (if you don't see this see step 4 of setup)
3. Click ```Next```, give the project a name and click ```Finish```
4. Once the project is complete right click the project and click ```Properties```
5. Go to ```Project Facets``` and click ```Convert to faceted form...``` (if you don't see this see step 3 of setup)
6. Check the ```Java``` project facet and click ```Apply``` (if you don't see this see step 3 of setup)
7. Click ```OK```, let the solution rebuild, open the properties again
8. Go to ```Java Build Path```, click the ```Source``` tab
9. Click ```Add Folder...``` and check ```Project > target > generated-sources > antlr4```, click ```OK```
10. Click the ```Libraries``` tab
11. ```Add External JARs...```, find your copy of ```antlr-4.x-complete.jar```, click ```Open```
12. Go to ```ANTLR 4 > Tool```, click ```Apply``` if a pop-up appears
13. Check ```Enable project specific settings```
14. Click ```Add```, find your copy of ```antlr-4.x-complete.jar```, click ```Open```
15. Check ```4.x```
16. Click ```Apply```, click ```Yes``` to rebuild, click ```OK``` to exit the properties

Usage
=========
The new IDE is very simple to use all the files with a ```*.g4``` extension will be opened by the ANTLR 4 Editor. So, just open a ```*.g4``` file and play with it

Code Generation
---------
Code is automatically generated on save if the grammar is valid. You can turn off this feature by going to: ```Window > Preferences > ANTLR 4 > Tool``` and uncheck the "Tool is activated" option. From there you can configure a couple more of options.

You can find the generated code in the ```target/generated-sources/antlr4``` (same directory as antlr4-maven-plugin)

Manual Code Generation
---------
You can fire a code generation action by selecting a ```*.g4``` file from the Package Explorer, right click: ```Run As > ANTLR 4```.

A default ANTLR 4 launch configuration will be created. You can modify the generated launch configuration by going to: ```Run > External Tools > External Tools Configurations...``` from there you will see the launch configuration and how to set or override code generation options

Syntax Diagrams
---------
To open the Syntax Diagram view go to: ```Window > Show View > Other``` search and select: **Syntax Diagram**

Eclipse Example
---------
1. Create a new ANTLR Project following the steps above
2. Create a new class with the code below 
3. Run
4. In the console write `Hello there` and Ctrl + z to send EOF to the input stream

```
    import org.antlr.v4.runtime.*;
    import org.antlr.v4.runtime.tree.*;
    public class HelloRunner 
    {
    	public static void main( String[] args) throws Exception 
    	{
    
    		ANTLRInputStream input = new ANTLRInputStream( System.in);
    
    		HelloLexer lexer = new HelloLexer(input);
    
    		CommonTokenStream tokens = new CommonTokenStream(lexer);
    
    		HelloParser parser = new HelloParser(tokens);
    		ParseTree tree = parser.r(); // begin parsing at rule 'r'
    		System.out.println(tree.toStringTree(parser)); // print LISP-style tree
    	}
```

Building ANLTR 4 IDE
=========

1. Build with Maven 3.x
  1. Fork and clone the repository from github
  2. Download and install [Maven 3.x](http://maven.apache.org/)
  3. Open a shell console and type: ```cd antlr4ide```
  4. Build the project with: ```mvn clean package```
  5. It takes a while to download and configure Eclipse dependencies, so be patient
  6. Wait for a: ```BUILD SUCCESS``` message
2. Setup Eclipse
  1. Open Eclipse Luna (4.4)
  2. Install Xtext 2.7.3
  3. Copy and paste this url: http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/ in the **Work with** text field
  4. Hit Enter
  5. Choose **XText 2.7.3**. NOTE: DON'T confuse with Xtend, you must choose Xtext
  6. Restart Eclipse after installing Xtext
  7. Import the project into Eclipse
  8. Go to: ```File > Import...``` then ```General > Existing Projects into Workspace```
  9. Choose project root ```antlr4ide```
  10. Enabled: ```Search for nested projects```
  11. Finish

You don't need any extra Eclipse plugin (like m2e or similar). Project metadata is on git so all you need to do is: ```mvn clean package``` and then import the projects into Eclipse.


Want to contribute?
=========
* Fork the project on Github.
* Wondering what to work on? See task/bug list and pick up something you would like to work on.
* Create an issue or fix one from [issues list](https://github.com/jknack/antlr4ide/issues).
* If you know the answer to a question posted to our [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply.
* Share your ideas or ask questions on [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply - that helps us improve javadocs/FAQ.
* If you miss a particular feature - browse or ask on the [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply, show us a sample code and describe the problem.
* Write a blog post about how you use or extend ANTLR 4 IDE.
* Please suggest changes to javadoc/exception messages when you find something unclear.
* If you have problems with documentation, find it non intuitive or hard to follow - let us know about it, we'll try to make it better according to your suggestions. Any constructive critique is greatly appreciated. Don't forget that this is an open source project developed and documented in spare time.

Help and Support
=========
  [Help and discussion](https://groups.google.com/forum/#!forum/antlr4ide)

  [Bugs, Issues and Features](https://github.com/jknack/antlr4ide/issues)

Author
=========
 [Edgar Espina] (https://twitter.com/edgarespina)

License
=========
[EPL](http://www.eclipse.org/legal/epl-v10.html)
