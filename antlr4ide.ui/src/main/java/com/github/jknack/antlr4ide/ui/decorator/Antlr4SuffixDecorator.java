package com.github.jknack.antlr4ide.ui.decorator;

import org.eclipse.jface.viewers.ILightweightLabelDecorator;
import org.eclipse.jface.viewers.IDecoration;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Antlr4SuffixDecorator implements ILightweightLabelDecorator
{
   // read first line from file
   // the ANTLR4 generated java files has first line indicating origin
   //    >// Generated from testissue.g4 by ANTLR 4.5.1<
   // the tokens files have no indication of origin except for the filename of course.

   public void decorate(Object element, IDecoration decoration) {
	   // Note the plugin.xml specify which types are passed to this decorator
	   IResource resource=(IResource)element;
	   String resourceName = resource.getName();
	   
//	   System.out.println(" Antlr4SuffixDecorator decorate Object>"+element.getClass()+"<"
//	   		+ ">"+resource.getName()+"<"
//	   	    + ">"+resource.getFullPath()+"<" // relative to workspace root
//	   	    + ">"+resource.getRawLocation()+"<" // full file system path
//	   		);
	   
	   if(resource.getType()!=IResource.FILE) return;
	   if(!resource.isDerived()) return;
	   
	   if(resourceName.endsWith("Lexer.tokens")) decoration.addSuffix(" ["+resourceName.substring(0,resourceName.length()-12)+".g4]");
	   else 
       if(resourceName.endsWith("Parser.tokens")) decoration.addSuffix(" ["+resourceName.substring(0,resourceName.length()-13)+".g4]");
	   else 
	   if(resourceName.endsWith(".tokens")) decoration.addSuffix(" ["+resourceName.substring(0,resourceName.length()-7)+".g4]");
	   else 
	   if(resourceName.endsWith(".java")) { // what about other target types?
		   // read first line
		    BufferedReader in=null;
			try {
				in = new BufferedReader(new InputStreamReader(((IFile)resource).getContents()));
 			    String text = in.readLine();
 			    if (text.startsWith("// Generated from ")) {
 				 String[] strArray = text.split(" ");
 			     decoration.addSuffix(" ["+strArray[3]+"]");  
 			    }
			} catch (Exception e) {
				e.printStackTrace();
			}
			try {
				if(in!=null) in.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
	   }
   }
   
   /*
    * invoked by eclipse when selecting decorator in preferences or by start
    */
   public void addListener(ILabelProviderListener listener) { 
   }
   
   /*
    * invoked before dispose, when unselecting the decorator in preferences
    */
   public void removeListener(ILabelProviderListener listener) { 
   }
   
   /*
    * invoked after removeListener, when unselecting the decorator in preferences
    */
   public void dispose() { 
//	   System.out.println(" Antlr4SuffixDecorator dispose"); 
   }
   
   public boolean isLabelProperty(Object element, String property) { 
//	   System.out.println(" Antlr4SuffixDecorator isLabelProperty>"+element.getClass()+"<>"+property+"<");
	   return false; 
   }
   
   
}
