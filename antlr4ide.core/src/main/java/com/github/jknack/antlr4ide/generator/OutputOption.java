package com.github.jknack.antlr4ide.generator;

import org.eclipse.core.runtime.IPath;

/**
 * Hold output variables required by ANTLR and/or Eclipse.
 */
public class OutputOption {

	/**
	 * The absolute OS path for the output directory.
	 */
	private final IPath absolute;

	/**
	 * The Eclipse relative path for the output directory.
	 */
	private final IPath relative;

	/**
	 * The package's name.
	 */
	private final String packageName;

	public OutputOption(final IPath absolute, final IPath relative,
			final String packageName) {
		this.absolute = absolute;
		this.relative = relative;
		this.packageName = packageName;
	}
	
	public IPath getAbsolute() {
		return this.absolute;
	}
	
	public IPath getRelative() {
		return this.relative;
	}
	
	public String getPackageName() {
		return this.packageName;
	}
	
	@Override
	public String toString() {
		final StringBuilder builder = new StringBuilder();
		builder.append("[OutputOption [absolute='");
		builder.append(absolute);
		builder.append("',relative='");
		builder.append(relative);
		builder.append("',packageName='");
		builder.append(packageName);
		builder.append("']]");
		return builder.toString();
	}
	
	@Override
	public boolean equals(final Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (!(obj instanceof OutputOption)) {
			return false;
		}
		final OutputOption other = (OutputOption) obj;
		final boolean result = (this.absolute.equals(other.absolute) &&
				this.relative.equals(other.relative) &&
				this.packageName.equals(other.packageName));
		return result;
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((this.absolute== null) ? 0 : this.absolute.hashCode());
		result = prime * result + ((this.relative== null) ? 0 : this.relative.hashCode());
		result = prime * result + ((this.packageName== null) ? 0 : this.packageName.hashCode());
		return result;
	}

}
