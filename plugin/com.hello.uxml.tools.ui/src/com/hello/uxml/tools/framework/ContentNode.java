package com.hello.uxml.tools.framework;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Marks a function as content node.
 *
 * <p>The marked function can be either a setContent(Object value) or
 * addChild(Object child). The MarkupCompiler will generate a call to this
 * function when child elements are present in hts.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
@Retention(RetentionPolicy.RUNTIME)
public @interface ContentNode {
}
