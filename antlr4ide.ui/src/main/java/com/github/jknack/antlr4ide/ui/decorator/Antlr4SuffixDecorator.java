package com.github.jknack.antlr4ide.ui.decorator;

import org.eclipse.jface.viewers.ILightweightLabelDecorator;
import org.eclipse.jface.viewers.IDecoration;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Antlr4SuffixDecorator implements ILightweightLabelDecorator
{
   // For the ANTLR4 generated java files has first line indicating origin
   //    >// Generated from testissue.g4 by ANTLR 4.5.1<
   // For the generated tokens files use the filename itself as indication of origin.
	
   static final String[] checkSuffixes={"Lexer.tokens","Parser.tokens",".tokens" };
   static final int[]    checkSuffixesLen={checkSuffixes[0].length(),checkSuffixes[1].length(),checkSuffixes[2].length()};

   public void decorate(Object element, IDecoration decoration) {
	   // Note: the plugin.xml specify which types are passed through element to this decorator
	   IResource resource=(IResource)element;
	   
//	   System.out.println(" Antlr4SuffixDecorator decorate Object>"+element.getClass()+"<"
//	   		+ ">"+resource.getName()+"<"
//	   	    + ">"+resource.getFullPath()+"<" // relative to workspace root
//	   	    + ">"+resource.getRawLocation()+"<" // full file system path
//	   		);
	   
	   if(resource.getType()!=IResource.FILE) return;
	   if(!resource.isDerived()) return;

	   String resourceName = resource.getName();

	   if(resourceName.endsWith(".java")) { // what about other target types?
		   // read first line
		    BufferedReader in=null;
			try {
				in = new BufferedReader(new InputStreamReader(((IFile)resource).getContents()));
 			    String text = in.readLine();
 			    in.close();
 			    if (text.startsWith("// Generated from ")) {
 				 String[] strArray = text.split(" ");
 			     decoration.addSuffix(" ["+strArray[3]+"]");  
 			    }
			} catch (Exception e) {
				e.printStackTrace();
			}
	   }
	   else {
		   for (int i=0;i<checkSuffixes.length;i++) {
			   if(resourceName.endsWith(checkSuffixes[i])) { 
				   decoration.addSuffix(asDecoratorSuffix(resourceName,checkSuffixesLen[i],".g4"));
				   break; // stop at first match
			   }
		   }
	   }
   }
   

   private String asDecoratorSuffix(String fileName) {
	   return " ["+fileName+"]";
   }

   private String asDecoratorSuffix(String resourceName, int resourceSuffixLen, String ext) {
	   return asDecoratorSuffix(resourceName.substring(0,resourceName.length()-resourceSuffixLen)+ext);
   }
   
   public void addListener(ILabelProviderListener listener) {  }
   public void removeListener(ILabelProviderListener listener) {  }
   public void dispose() {  }
   public boolean isLabelProperty(Object element, String property) { return false; }
   

}
