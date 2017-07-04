package com.github.jknack.antlr4ide.generator;

import java.io.File;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;

/**
 * ANTLR Tool options.
 *
 * @Statefull
 * @NotThreadSafe
 */
public class ToolOptions {

	public static final String BUILD_LISTENER = "antlr4.listener";

	public static final String BUILD_VISITOR = "antlr4.visitor";

	public static final String BUILD_TOOL_PATH = "antlr4.antlrToolPath";

	public static final String BUILD_ANTLR_TOOLS = "antlr4.antlrRegisteredTools";

	public static final String BUILD_ENCODING = "antlr4.encoding";

	public static final String BUILD_LIBDIRECTORY = "antlr4.libdirectory";

	public static final String VM_ARGS = "antlr4.vmArgs";
	
	private String antlrTool;

	private String outputDirectory;

	private boolean listener = true;

	private boolean visitor;

	private boolean derived = true;

	private String encoding = "UTF-8";

	private String messageFormat;
	
	private boolean atn;

	private String libDirectory;

	private String packageName;

	private Set<String> extras = new LinkedHashSet<String>();

	private String vmArgs;
	
	private boolean packageInsideAction = false;
	
	private boolean cleanUpDerivedResources = true;

	private boolean outputSet = false;
	
	/**
	 * Produces output options like absolute, workspace relative output
	 * directory and package name.
	 * It tries to detect/guess a package's name for files under
	 * <code>src/main/antlr4</code>,
	 * <code>src/main/java</code> or <code>src</code>. Any sub-directory under
	 * those paths will be
	 * append them to the package's name and output folder. This more ore less
	 * mimics what the
	 * antlr4-maven-plugin does Java.
	 *
	 * @return Absolute, workspace relative output folders and package's name
	 *         for file.
	 */
	public OutputOption output(final IFile file) {
		final IProject project = file.getProject();
		final IPath projectPath = project.getLocation();
		
		// device = null is required on Windows, see
		// https://github.com/jknack/antlr4ide/issues/1
		final IPath prefix = file.getLocation().setDevice(null)
				.removeFirstSegments(projectPath.segmentCount());
		IPath pkgDir = this.getPkgForOutputSet(prefix);
		
		final File dir = new File(this.outputDirectory);
		
		if (pkgDir == prefix) {
			pkgDir = pkgDir.removeFirstSegments(prefix.segmentCount());
		}
		
		// if output was set by user, over
		if (dir.isAbsolute() || dir.exists()) {
			return new OutputOption(
					Path.fromOSString(this.outputDirectory).append(pkgDir),
					Path.fromOSString(this.outputDirectory).append(pkgDir)
							.makeRelative(),
					pkgDir.toString().replace("/", "."));
		}
		String output = this.outputDirectory;
		if (!output.startsWith("/")) {
			output = "/" + output;
		}
		final String candidate = output.replace(projectPath.toOSString(), "");
		if (candidate != output) {
			return new OutputOption(Path.fromOSString(output).append(pkgDir),
					Path.fromOSString(candidate).append(pkgDir).makeRelative(),
					pkgDir.toString().replace("/", "."));
		}
		
		// make it project relative
		return new OutputOption(
				Path.fromPortableString(projectPath.toOSString()).append(output)
						.append(pkgDir),
				Path.fromPortableString(output).append(pkgDir),
				pkgDir.toString().replace("/", "."));
	}
	
	private IPath getPkgForOutputSet(final IPath prefix) {
		if (this.outputSet) {
			// Output folder was set by user, just follow what user say and
			// don't find a
			// default package see: https://github.com/jknack/antlr4ide/issues/5
			return Path.fromPortableString("");
		} else if (this.packageName != null) {
			return Path.fromPortableString(this.packageName.replace(".", "/"));
		} else {
			final IPath tmp1 = this.removeSegment(prefix, "src", "main",
					"antlr4");
			final IPath tmp2 = this.removeSegment(tmp1, "src", "main", "java");
			final IPath tmp3 = this.removeSegment(tmp2, "src", "main",
					"resources");
			final IPath tmp4 = this.removeSegment(tmp3, "antlr-src");
			final IPath tmp5 = this.removeSegment(tmp4, "antlr-source");
			final IPath result = this.removeSegment(tmp5, "src");
			return result;
		}
	}
	
	public String resolvePath(final IFile file, final String inPath) {
		// assume path is relative to project path
		final IProject project = file.getProject();
		final IPath projectPath = project.getLocation();

		final IPath chkPath = new Path(inPath);

		// Check if path is absolute
		if (chkPath.isAbsolute()) {
			return chkPath.toOSString();
		} else {
			return projectPath.append(chkPath).toOSString();
		}
	}

	public List<String> defaults() {
		String listener = "-listener";
		if (!this.listener) {
			listener = "-no-listener";
		}
		String visitor = "-no-visitor";
		if (this.visitor) {
			visitor = "-visitor";
		}
		final List<String> options = new ArrayList<String>();
		options.add(listener);
		options.add(visitor);
		
		// encoding
		if (this.encoding != null) {
			options.add("-encoding");
			options.add(this.encoding);
		}
		return options;
	}

	/**
	 * See
	 * https://theantlrguy.atlassian.net/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
	 *
	 * @param file
	 *            A *.g4 file. Can't be null.
	 * @return ANTLR Tool commands.
	 */
	public List<String> command(final IFile file) {
		if (file == null) {
			throw new NullPointerException();
		}

		String listener = "-listener";
		if (!this.listener) {
			listener = "-no-listener";
		}
		String visitor = "-no-visitor";
		if (this.visitor) {
			visitor = "-visitor";
		}
		final OutputOption out = this.output(file);
		final List<String> options = new ArrayList<String>();
		options.add("-o");
		options.add(out.getAbsolute().toOSString());
		options.add(listener);
		options.add(visitor);

		// libDirectory
		if ((this.libDirectory != null)
				&& !this.libDirectory.trim().equals("")) {
			options.add("-lib");
			options.add(this.resolvePath(file, this.libDirectory));
		}

		// package
		if (!this.packageInsideAction) {
			if (this.packageName != null) {
				options.add("-package");
				options.add(this.packageName);
			} else if (out.getPackageName().length() > 0) {
				options.add("-package");
				options.add(out.getPackageName());
			}
		}

		// message-format
		if (this.messageFormat != null) {
			options.add("-message-format");
			options.add(this.messageFormat);
		}

		// atn
		if (this.atn) {
			options.add("-atn");
		}

		// encoding
		if (this.encoding != null) {
			options.add("-encoding");
			options.add(this.encoding);
		}

		// extras
		final Iterator<String> it = this.extras.iterator();
		while (it.hasNext()) {
			final String option = it.next();
			options.add(option);
		}
		return options;
	}
	
	/**
	 * Parse arguments and creates a new ToolOptions instance.
	 * See
	 * https://theantlrguy.atlassian.net/wiki/display/ANTLR4/ANTLR+Tool+Command+Line+Options
	 */
	public static ToolOptions parse(final String args,
			final Procedure1<String> err) {
		final String[] options = args.split("\\s+");
		final Set<String> optionsWithValue = new HashSet<String>();
		optionsWithValue.add("-o");
		optionsWithValue.add("-lib");
		optionsWithValue.add("-encoding");
		optionsWithValue.add("-message-format");
		optionsWithValue.add("-package");
		final ToolOptions defaults = new ToolOptions();

		for (int i = 0; i < options.length; i++) {
			final String option = options[i];
			String value = null;
			if (optionsWithValue.contains(option)) {
				if ((i + 1) < options.length) {
					i++;
					value = options[i];
					//i++;
				}
			}

			// set options
			if ("-o".equals(option)) {
				if (value != null) {
					defaults.outputSet = true;
					defaults.outputDirectory = value;
				} else {
					err.apply("Bad command-line option: '" + option + "'");
				}
			} else if ("-lib".equals(option)) {
				if (value != null) {
					defaults.libDirectory = value;
				} else {
					err.apply("Bad command-line option: '" + option + "'");
				}
			} else if ("-encoding".equals(option)) {
				if (value != null) {
					defaults.encoding = value;
				} else {
					err.apply("Bad command-line option: '" + option + "'");
				}
			} else if ("-message-format".equals(option)) {
				if (value != null) {
					defaults.messageFormat = value;
				} else {
					err.apply("Bad command-line option: '" + option + "'");
				}
			} else if ("-package".equals(option)) {
				if (value != null) {
					defaults.packageName = value;
				} else {
					err.apply("Bad command-line option: '" + option + "'");
				}
			} else if ("-atn".equals(option)) {
				defaults.atn = true;
			} else if ("-depend".equals(option)) {
				err.apply("Unsupported command-line option: '" + option + "'");
			} else if ("-listener".equals(option)) {
				defaults.listener = true;
			} else if ("-no-listener".equals(option)) {
				defaults.listener = false;
			} else if ("-visitor".equals(option)) {
				defaults.visitor = true;
			} else if ("-no-visitor".equals(option)) {
				defaults.visitor = false;
			} else if ("-Werror".equals(option)) {
				defaults.getExtras().add(option);
			} else if ("-Xsave-lexer".equals(option)) {
				defaults.getExtras().add(option);
			} else if ("-XdbgST".equals(option)) {
				defaults.getExtras().add(option);
			} else if ("-Xforce-atn".equals(option)) {
				defaults.getExtras().add(option);
			} else if ("-Xlog".equals(option)) {
				defaults.getExtras().add(option);
			} else if ("-XdbgSTWait".equals(option)) {
				defaults.getExtras().add(option);
			} else if (option.startsWith("-D")) {
				defaults.getExtras().add(option);
			} else {
				err.apply("Unknown command-line option: '" + option + "'");
			}
		}
		return defaults;

	}

	public String[] vmArguments() {
		if ((this.vmArgs == null) || (this.vmArgs.length() == 0)) {
			return new String[0];
		} else {
			return this.vmArgs.split("\\s+");
		}
	}
	
	private IPath removeSegment(final IPath path, final String... names) {
		IPath result = path;
		int count = 0;
		if (result.segmentCount() > 0) {
			for (int i = 0; i < names.length; i++) {
				final String name = names[i];
				final String[] segments = result.segments();

				if (name.equals(segments[0])) {
					result = result.removeFirstSegments(1);
					count = count + 1;
				}
			}
		}
		if (count == names.length) {
			return result.removeLastSegments(1);
		} else {
			return path;
		}
	}

	public String getAntlrTool() {
		return this.antlrTool;
	}
	
	public void setAntlrTool(final String antlrTool) {
		this.antlrTool = antlrTool;
	}

	public String getOutputDirectory() {
		return this.outputDirectory;
	}
	
	public void setOutputDirectory(final String outputDirectory) {
		this.outputDirectory = outputDirectory;
	}
	
	public boolean isListener() {
		return this.listener;
	}
	
	public void setListener(final boolean listener) {
		this.listener = listener;
	}
	
	public boolean isVisitor() {
		return this.visitor;
	}
	
	public void setVisitor(final boolean visitor) {
		this.visitor = visitor;
	}
	
	public boolean isDerived() {
		return this.derived;
	}
	
	public void setDerived(final boolean derived) {
		this.derived = derived;
	}
	
	public String getEncoding() {
		return this.encoding;
	}
	
	public void setEncoding(final String encoding) {
		this.encoding = encoding;
	}
	
	public String getMessageFormat() {
		return this.messageFormat;
	}
	
	public void setMessageFormat(final String messageFormat) {
		this.messageFormat = messageFormat;
	}

	public boolean isAtn() {
		return this.atn;
	}

	public void setAtn(final boolean atn) {
		this.atn = atn;
	}

	public String getLibDirectory() {
		return this.libDirectory;
	}

	public void setLibDirectory(final String libDirectory) {
		this.libDirectory = libDirectory;
	}

	public String getPackageName() {
		return this.packageName;
	}

	public void setPackageName(final String packageName) {
		this.packageName = packageName;
	}

	public Set<String> getExtras() {
		return this.extras;
	}

	public void setExtras(final Set<String> extras) {
		this.extras = extras;
	}
	
	public String getVmArgs() {
		return this.vmArgs;
	}
	
	public void setVmArgs(final String vmArgs) {
		this.vmArgs = vmArgs;
	}

	public boolean isPackageInsideAction() {
		return this.packageInsideAction;
	}

	public void setPackageInsideAction(final boolean packageInsideAction) {
		this.packageInsideAction = packageInsideAction;
	}

	public boolean isCleanUpDerivedResources() {
		return this.cleanUpDerivedResources;
	}

	public void setCleanUpDerivedResources(
			final boolean cleanUpDerivedResources) {
		this.cleanUpDerivedResources = cleanUpDerivedResources;
	}

}
