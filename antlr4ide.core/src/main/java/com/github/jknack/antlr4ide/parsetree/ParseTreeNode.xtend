package com.github.jknack.antlr4ide.parsetree

import com.github.jknack.antlr4ide.lang.Rule
import com.github.jknack.antlr4ide.lang.Terminal
import static com.google.common.base.Preconditions.*

/**
 * Parse tree information.
 */
class ParseTreeNode {

  /** The source element. */
  val Object element

  /**
   * Creates a new ParseTreeNode from a source element.
   *
   * @param element The source element.
   */
  new (Object element) {
    this.element = checkNotNull(element, "A source element is required.")
  }

  /**
   * @return The source element.
   */
  def getElement() {
    element
  }

  /**
   * @return A text representation of the source element.
   */
  def getText() {
    switch (element) {
      Rule: element.name
      Terminal: element.literal
      default: element.toString
    }
  }

  override toString() {
    text
  }

}
