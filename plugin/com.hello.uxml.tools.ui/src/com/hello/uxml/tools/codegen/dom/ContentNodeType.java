package com.hello.uxml.tools.codegen.dom;

/**
 * Enumerates the type of field/collection marked with ContentNode or
 * CollectionNode attributes.
 *
 * @author ferhat@(Ferhat Buyukkokten)
 */
public enum ContentNodeType {
  None, // No member is marked with attribute
  Field, // A Field is marked to be set with content
  CollectionMethod, // An add method (addChild,addStop...) is marked as contentnode
}
