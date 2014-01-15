ANTLR 4 IDE
=========

![ANTLR 4 IDE](https://raw.github.com/jknack/antlr4ide/master/site/screenshots/full.png)


Features
=========

* ANTLR 4.x
* Advanced Syntax Highlighting ([even for target language](https://raw.github.com/jknack/antlr4ide/master/site/screenshots/target-language-highlighting.png))
* Automatic Code Generation (on save)
* Manual Code Generation (through External Tools menu)
* Code Formatter (Ctrl+Shift+F)
* [Syntax Diagrams as HTML](http://jknack.github.io/antlr4ide/Java/Javav4.g4.html)
* Advanced Rule Navigation between files (F3 or Ctrl+Click over a rule)
* Quick fixes


Welcome
=========

This is brand new version of the **old** [ANTLR IDE](http://antlrv3ide.sourceforge.net/). The new IDE supports ANTLR 4.x and it was created to run on Eclipse 4.x

The **old** [ANTLR IDE](http://antlrv3ide.sourceforge.net/) isn't supported anymore. When I wrote it, I was young and didn't know what was doing ;)

Don't get it me wrong, the old version did a very good work from  user point of view, it just I'm not proud of the code base because is kind of complex and had a poor quality.

The main reason of complexity of the old IDE was in Dynamic Language ToolKit (DLTK) dependency. The DLTK project didn't evolve so much over the last few years and doing something in DLTK is very very complex and require a lot of work.

Now, the **new** IDE was built on [XText](http://www.eclipse.org/Xtext). [XText](http://www.eclipse.org/Xtext) is great for building DLS with Eclipse IDE support, so if you are not familiar with [XText](http://www.eclipse.org/Xtext) go and see it.

Requirements
=========
* Eclipse 4.3 (Kepler)
* XText 2.5

Installation
=========
ANTLR 4 IDE **isn't** available in the Eclipse Market Place yet, so you MUST installed in the old way. Please follow these instructions:

* Open Eclipse Kepler (4.3)
* Go to: ```Help > Install New Software...```
* You need to Install XText 2.5
* Copy and paste this url: http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/ in the **Work with** text field
* Hit Enter
* Choose **XText 2.5.0**. NOTE: DON'T confuse with Xtend, you must choose Xtext
* Now, copy and paste this url: https://github.com/jknack/antlr4ide/raw/master/site/0.1.0/ in the **Work with** text field
* Choose: **ANTLR 4 SDK IDE**. NOTE: If you don't see it, please unmark the **Group items by category** option
* Click: Next and follow the normal Eclipse installation procedure

Usage
=========
The new IDE is very simple to use all the files with a ```*.g4``` extension will be opened by the ANTLR 4 Editor. So, just open a ```*.g4``` file and play with it

Code Generation
=========
Code is automatically generated on save if the grammar is valid. You can turn off this feature by going to: ```Window > Preferences > ANTLR 4 > Tool``` and uncheck the "Tool is activated" option. From there you can configure a couple more of options.

You can find the generated code in the ```target/generated-sources/antlr4``` (same directory as antlr4-maven-plugin)

Manual Code Generation
=========
You can fire a code generation action by selecting a ```*.g4``` file from the Package Explorer, right click: ```Run As > ANTLR 4```.

A default ANTLR 4 launch configuration will be created. You can modify the generated launch configuration by going to: ```Run > External Tools > External Tools Configurations...``` from there you will see the launch configuration and how to set or override code generation options

Syntax Diagrams
=========
To open the Syntax Diagram view go to: ```Window > Show View > Other``` search and select: **Syntax Diagram**

Want to contribute?
=========
* Fork the project on Github.
* Wandering what to work on? See task/bug list and pick up something you would like to work on.
* Create an issue or fix one from [issues list](https://github.com/jknack/antlr4ide/issues).
* If you know the answer to a question posted to our [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply.
* Share your ideas or ask questions on [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply - that helps us improve javadocs/FAQ.
* If you miss a particular feature - browse or ask on the [mailing list](https://groups.google.com/forum/#!forum/antlr4ide) - don't hesitate to write a reply, show us a sample code and describe the problem.
* Write a blog post about how you use or extend handlebars.java.
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
