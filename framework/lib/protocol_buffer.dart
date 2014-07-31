part of uxml;

/**
 * Implements a text (ASCII) representation of a protocol buffer object. It
 * provides a convenient toString() method to serialize the instance to a
 * String. To use just assign primitive fields (Number, Boolean and String),
 * ProtoGroup, Foreign field (another instance of ProtocolBuffer), Array
 * of above fields (repeated fields) and finally, MessageSet (array of
 * ProtocolBuffer objects). For example:
 *
 * ProtocolBuffer proto = new ProtocolBuffer(messageSetType:"message_set_type");
 * proto.setMessageSetType();
 * proto.numField = 1;
 * proto.boolField = 1; // 1 = true, 0 = false
 * proto.strField = "Hello World";
 * proto.arrNumbers = [1, 2, 3];
 * proto.groupField = new ProtoGroup();
 * proto.groupField.boolField = 0;
 * proto.foreignField = new ProtocolBuffer();
 * proto.foreignField.strField = "What's Up?";
 * proto.messageSetField = new MessageSet();
 * proto.messageSetField.push(new ProtocolBuffer());
 *
 * trace(proto.toString()); // serialize to String
 *
 * See:
 *
 * http://wiki.corp.google.com/twiki/bin/view/Main/ProtocolBufferAsciiExamples
 *
 * for examples of protocol buffers supported by this serializer.
 *
 * @author:sanjayc@ (Sanjay Chouksey)
 * @author:ferhat@ (Sanjay Chouksey)
 *
 */
class ProtocolBuffer {

  String _messageSetType;
  Map<String, Object> _values;
  List<String> _keys;

  /**
   * Constructs a new instance of ProtocolBuffer.
   * @param messageSetType A String that represents the type of this protocol
   * buffer when used in MessageSet.
   */
  ProtocolBuffer([String messageSetType = ""]) {
    _messageSetType = messageSetType;
    _values = new Map<String, Object>();
    _keys = <String>[];
  }

  /**
   * Sets the member of protocol buffers. This is put in to temporarily replace
   * the dot notation member assignment to get rid of dart warnings.
   */
  setMember(String key, Object value) {
    _values[key] = value;
    _keys.add(key);
  }

  dynamic operator[](String name) => _values[name];

  operator[]=(String name, dynamic value) {
    _values[name] = value;
    _keys.add(name);
  }

//  noSuchMethod(Invocation invocation) {
//    //String functionName = invocation.memberName;
//    final functionName = MirrorSystem.getName(invocation.memberName);
//    List args = invocation.positionalArguments;
//
//    if (invocation.isSetter) {
//      String key = functionName.substring(0, functionName.length - 1);
//      _values[key] = args[0];
//      _keys.add(key);
//    } else if (invocation.isGetter) {
//      return _values[functionName];
//    } else if (functionName.startsWith("set:")) {
//      // TODO(dgrove): Remove once VM supports isSetter.
//      String key = functionName.substring(4);
//      _values[key] = args[0];
//      _keys.add(key);
//    } else if (functionName.startsWith("get:")) {
//      // TODO(dgrove): Remove once VM supports isGetter.
//      return _values[functionName.substring(4)];
//    } else if (functionName.endsWith("=")) {
//      String key = functionName.substring(0, functionName.length - 1);
//      _values[key] = args[0];
//      _keys.add(key);
//    } else {
//      return _values[functionName];
//    }
//  }


  /**
   * Serializes this object instance to text protocol buffer format.
   */
  String toString() {
    return _serializeObject(this, false, "");
  }

  /**
   * Serializes this object instance to flat text protocol buffer format.
   */
  String toFlatString() {
    return _serializeObject(this, true, "");
  }

  void _sortKeys() {
    _keys.sort((String a, String b) {
        return a.compareTo(b);
      });
  }

  /**
   * Serializes an object (non-primitive) field.
   */
  static String _serializeObject(ProtocolBuffer proto,
                                 bool flat,
                                 String indent) {
    StringBuffer ret = new StringBuffer();

    // iterate through all dynamic fields of the object into an array
    int len = proto._keys.length;
    proto._sortKeys();
    for (int i = 0; i < len; i++) {
      String name = proto._keys[i];
        Object value = proto._values[name];
      if (value is MessageSet) {
        MessageSet mSet = value;
        // skip it if it has zero messages.
        int count = mSet.length;
        if (count == 0) {
          continue;
        }
        ret.write(flat ? "" : indent);
        ret.write("$name <${flat ? " " : "\n"}");
        for (int m = 0; m < count; m++) {
          ProtocolBuffer mProto = mSet[m];
          ret.write(flat ? "" : "  ");
          ret.write(indent);
          ret.write("[${mProto._messageSetType}]");
          ret.write(" <${flat ? " " : "\n"}");
          ret.write(_serializeObject(mProto, flat, "$indent    "));
          ret.write(flat ? "> " : "$indent  >\n$indent");
        }
        ret.write(flat ? ">" : "$indent>");
      } else if (value is ProtoGroup) {
        ret.write(flat ? "" : indent);
        ret.write(name);
        ret.write(" {");
        ret.write(flat ? " " : "\n");
        ret.write(_serializeObject(value, flat, "$indent  "));
        ret.write(flat ? "}" : "$indent}");
      } else if (value is ProtocolBuffer) {
        ret.write(flat ? "" : indent);
        ret.write(name);
        ret.write(" <");
        ret.write(flat ? " " : "\n");
        ret.write(_serializeObject(value, flat, "$indent  "));
        ret.write(">");
      } else if (value is List) {
        ret.write(indent);
        ret.write(_serializeArray(value, name, flat, indent));
        // serializeArray adds the whitespace, so just continue here
        continue;
      } else if (value is ProtoEnum) {
        ProtoEnum en = value;
        ret.write(flat ? "" : indent);
        ret.write("$name:${en.value}");
      } else if (value is ProtoLong) {
        ProtoLong l = value;
        ret.write(flat ? "" : indent);
        ret.write("$name:${l.toString()}");
      } else {
        // serialize name and primitive.
        ret.write(flat ? "" : indent);
        ret.write("$name:${_serializePrimitive(value)}");
      }
      ret.write(flat ? " " : "\n");
    }
    return ret.toString();
  }

  /** Serializes primitive fields (number, boolean and string). */
  static String _serializePrimitive(Object value) {
    String ret = "";
    if (value is bool) {
      bool boolVal = value;
      return boolVal ? "1" : "0";
    } else if (value is num) {
      num numVal = value;
      return numVal.toString();
    } else if (value is String) {
      String str = value;
      // if the value contains embedded quote char, escape it
      if (str.indexOf("\"", 0) >= 0) {
        str = str.replaceAll(new RegExp("\""), "\\\"");
      }
      return "\"$str\"";
    } else {
      Application.current.warn("value is non primitive type");
      return "";
    }
  }

  /** Serializes repeated (Array) fields. */
  static String _serializeArray(List<Object> arr,
                                String name,
                                bool flat,
                                String indent) {
    StringBuffer ret = new StringBuffer();
    int len = arr.length;
    for (int i = 0; i < len; i++) {
      Object value = arr[i];
      ret.write(flat ? "" : indent);
      if (value is ProtocolBuffer) {
        ret.write("$name <");
        ret.write(flat ? " " : "\n");
        ret.write(_serializeObject(value, flat, "$indent  "));
        ret.write(">");
      } else if (value is ProtoGroup) {
        ret.write("$name {");
        ret.write(flat ? " " : "\n");
        ret.write(_serializeObject(value, flat, "$indent  "));
        ret.write("}");
      } else if (value is ProtoEnum) {
        ProtoEnum en = value;
        ret.write("$name:${en.value}");
      } else {
        ret.write("$name:${_serializePrimitive(value)}");
      }
      ret.write(flat ? " " : "\n");
    }
    return ret.toString();
  }
}

/**
 * Provides protocolbuffer object with a message type when serializing groups.
 */
class ProtoGroup extends ProtocolBuffer {
  ProtoGroup() : super() {
    _messageSetType = "GROUP";
  }
}

/**
 * Represents an Enum field in a ProtocolBuffer.
 *
 * @author:sanjayc@ (Sanjay Chouksey)
 */
class ProtoEnum {
  /** The value of the Enum field. */
  String value;

  ProtoEnum(this.value);
}

/**
 * Represents a MessageSet that holds multiple ProtocolBuffer objects.
 *
 * @author:sanjayc@ (Sanjay Chouksey)
 *
 */
class MessageSet {

  List<ProtocolBuffer> _list;

  MessageSet() : super() {
    _list = <ProtocolBuffer>[];
  }

  int get length => _list.length;

  ProtocolBuffer operator[](int index) => _list[index];

  void add(ProtocolBuffer proto) {
    _list.add(proto);
  }
}

/**
 * Holds a 64 bit integer internally in string format. This is a workaround
 * to limitation of 64 bit integer support in flash. This class just provides
 * a class type to represent a "big" number in string format. It does not
 * implement any arithmetic on 64 bit numbers.
 *
 * @author sanjayc@ (Sanjay Chouksey)
 */
class ProtoLong {
  String value;

  ProtoLong(this.value);

  /** Returns internal string representation. */
  String toString() {
    return value;
  }
}
