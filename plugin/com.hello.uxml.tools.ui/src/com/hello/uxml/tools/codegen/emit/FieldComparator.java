package com.hello.uxml.tools.codegen.emit;

import java.util.Comparator;

/**
 * Compares the order of fields to create style compliant code output.
 *
 * @author ferhat
 */
public class FieldComparator implements Comparator<FieldBuilder> {
  @Override
  public int compare(FieldBuilder field1, FieldBuilder field2) {
    boolean isConst1 = field1.getAttributes().contains(FieldAttributes.Const);
    boolean isConst2 = field2.getAttributes().contains(FieldAttributes.Const);
    if (isConst1 != isConst2) {
      if (isConst1) {
        return -1;
      } else {
        return 1;
      }
    }

    boolean isStatic1 = field1.getAttributes().contains(FieldAttributes.Static);
    boolean isStatic2 = field2.getAttributes().contains(FieldAttributes.Static);
    if (isStatic1 != isStatic2) {
      if (isStatic1) {
        return -1;
      } else {
        return 1;
      }
    }

    // both are static or instance , so let's sort accessors from most visible
    // to private.s
    int accessorRank1 = 0;
    int accessorRank2 = 0;

    if (field1.getAttributes().contains(FieldAttributes.Public)) {
      accessorRank1 += 10;
    }
    if (field2.getAttributes().contains(FieldAttributes.Public)) {
      accessorRank2 += 10;
    }
    if (field1.getAttributes().contains(FieldAttributes.Internal)) {
      accessorRank1 += 50;
    }
    if (field2.getAttributes().contains(FieldAttributes.Internal)) {
      accessorRank2 += 50;
    }
    if (field1.getAttributes().contains(FieldAttributes.Protected)) {
      accessorRank1 += 100;
    }
    if (field2.getAttributes().contains(FieldAttributes.Protected)) {
      accessorRank2 += 100;
    }
    if (field1.getAttributes().contains(FieldAttributes.Private)) {
      accessorRank1 += 1000;
    }
    if (field2.getAttributes().contains(FieldAttributes.Private)) {
      accessorRank2 += 1000;
    }
    if (accessorRank1 != accessorRank2) {
      return accessorRank1 - accessorRank2;
    }
    // sort by name
    return field1.getName().compareTo(field2.getName());
  }
}