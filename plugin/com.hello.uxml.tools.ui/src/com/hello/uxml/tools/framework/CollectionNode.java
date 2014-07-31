package com.hello.uxml.tools.framework;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Marks a property as a collection node.
 *
 * <p>The marked item represents a preallocated collection of elements.
 * The MarkupCompiler will generate code to populate the collection with child
 * elements.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
@Retention(RetentionPolicy.RUNTIME)
public @interface CollectionNode {
  boolean isPreAllocated() default true;
}
