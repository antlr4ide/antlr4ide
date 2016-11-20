package com.github.jknack.antlr4ide.ui.builder;

import java.util.List;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import org.eclipse.xtext.builder.IXtextBuilderParticipant.IBuildContext;
import org.eclipse.emf.ecore.resource.Resource;
import com.github.jknack.antlr4ide.lang.Grammar;
import com.github.jknack.antlr4ide.lang.GrammarType;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

public class Antlr4BuilderParticipant extends org.eclipse.xtext.builder.BuilderParticipant {
	
	@Override
	protected List<org.eclipse.xtext.resource.IResourceDescription.Delta> 
	          getRelevantDeltas(org.eclipse.xtext.builder.IXtextBuilderParticipant.IBuildContext context) 
	{
		List<org.eclipse.xtext.resource.IResourceDescription.Delta> result = super.getRelevantDeltas(context);
		
		List<org.eclipse.xtext.resource.IResourceDescription.Delta> resultLexers = new ArrayList(); 
		List<org.eclipse.xtext.resource.IResourceDescription.Delta> resultOthers = new ArrayList();

		List<org.eclipse.xtext.resource.IResourceDescription.Delta> resultFinal  = new ArrayList();
		
		int i=0;
		for (org.eclipse.xtext.resource.IResourceDescription.Delta delta : result) {
			Resource resource = context.getResourceSet().getResource(delta.getUri(), true);
			Grammar grammar = grammarFromResource(resource);
			System.out.println(">>> Antlr4BuilderParticipant getRelevantDeltas ["+i+"]>"+delta.getUri()+"< type>"+grammar.getType()+"<");
				
			if (grammar.getType()==GrammarType.LEXER)
				resultLexers.add(delta);
			else
				resultOthers.add(delta);
				
			i++;
		}
		
		
		Collections.sort(resultLexers,new CompareUri());
		Collections.sort(resultOthers,new CompareUri());
		
		resultFinal.addAll(resultLexers);
		resultFinal.addAll(resultOthers);
		
		i=0;
		for (org.eclipse.xtext.resource.IResourceDescription.Delta delta : resultFinal) {
			System.out.println("++> Antlr4BuilderParticipant getRelevantDeltas ["+i+"]>"+delta.getUri()+"<");
			i++;
		}
		
		return resultFinal;
	}
	
	
	private Grammar grammarFromResource(Resource _resourceFrom) {
// from com.github.jknack.antlr4ide.ui.services.DefaultGrammarResource;
	    EList<EObject> _contents = _resourceFrom.getContents();
	    EObject _head = IterableExtensions.<EObject>head(_contents);
	    return ((Grammar) _head);
	}
	
	
	private class CompareUri implements Comparator<org.eclipse.xtext.resource.IResourceDescription.Delta> {
	    public int compare(org.eclipse.xtext.resource.IResourceDescription.Delta delta1
			             , org.eclipse.xtext.resource.IResourceDescription.Delta delta2)
	    {
	    	return delta1.getUri().toString().compareTo(delta2.getUri().toString());
	    }
	}
	
}

/*
 * Ideas for build dependency strategy
 * ===
 * 
 * - If a grammar is used as IMPORT in other grammars, figure out if it should be built 
 * - Build sequence
 * - - Lexer grammars
 * - - Parser grammars
 * - - Combined grammars
 * 
 * - When rebuilding look for tool options 
 * - - For the grammar itself
 * - - For the project
 * - - For the workspace
 * - - Tool defaults
 * 
 * import org.eclipse.emf.ecore.resource.Resource;
 * Resource resource = context.getResourceSet().getResource(delta.getUri(), true);
 * 
 * import org.eclipse.core.resources.IFile;
 * IFile _fileFrom = ToolRunner.this.grammarResource.fileFrom(resource);
 * 
 * import com.github.jknack.antlr4ide.lang.Grammar;
 * final Grammar grammar = ToolRunner.this.grammarResource.grammarFrom(file);
 * 
 * class org.eclipse.xtext.resource.impl.DefaultResourceDescriptionDelta
 */


/* 
 * from antlr4ide.core/com.github.jknack.antlr4ide.generator.ToolRunner.xtend
    // set -lib when is empty
    val lib = options.libDirectory
    if (lib == null || lib.empty) {
      val grammar = grammarResource.grammarFrom(file)
      val libs = grammar.imports.map[
        grammarResource.fileFrom(it.importURI).parent
      ].toSet
      if (libs.size > 0) {
        options.libDirectory = libs.iterator.next.location.toOSString
      }
    }
 * which in java is
 * 
    import com.github.jknack.antlr4ide.lang.Grammar;
    import com.github.jknack.antlr4ide.lang.Import;
    import com.github.jknack.antlr4ide.services.GrammarResource;
    import com.github.jknack.antlr4ide.services.ModelExtensions;
    
    final Grammar grammar = this.grammarResource.grammarFrom(file);
        Set<Import> _imports = ModelExtensions.imports(grammar);
        final Function1<Import, IContainer> _function = new Function1<Import, IContainer>() {
          @Override
          public IContainer apply(final Import it) {
            Grammar _importURI = it.getImportURI();
            IFile _fileFrom = ToolRunner.this.grammarResource.fileFrom(_importURI);
            return _fileFrom.getParent();
          }
        };
        Iterable<IContainer> _map = IterableExtensions.<Import, IContainer>map(_imports, _function);
        final Set<IContainer> libs = IterableExtensions.<IContainer>toSet(_map);
        int _size = libs.size();
        boolean _greaterThan = (_size > 0);
        if (_greaterThan) {
          Iterator<IContainer> _iterator = libs.iterator();
          IContainer _next = _iterator.next();
          IPath _location_1 = _next.getLocation();
          String _oSString_1 = _location_1.toOSString();
          options.setLibDirectory(_oSString_1);
        }
      }
 *
 *     See also the Grammar and GrammarType in package com.github.jknack.antlr4ide.lang
 */

