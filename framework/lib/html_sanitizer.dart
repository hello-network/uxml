part of uxml;

/**
 * Utility class to sanitize HTML to a strict whitelisted set of tags.
 *
 * This code is based on SafeHTML/SimpleHTMLSanitizer used by GWT.
 *
 * @author ferhat@ (Ferhat Buyukkokten)
 */
class HtmlSanitizer {
  static const List<String> TAG_WHITELIST = const ["b", "em", "i",
    "h1", "h2", "h3", "h4", "h5", "h6",
    "hr", "ul", "ol", "li"];
  static Set<String> TAG_WHITELIST_SET = null;
  static final RegExp HTML_ENTITY_REGEX = new RegExp(
      '[a-z]+|#[0-9]+|#x[0-9a-fA-F]+');

  /*
   * Sanitize a string containing simple HTML markup as defined above.
   * The approach is as follows:  We split the string at each occurence of '<'.
   * Each segment thus obtained is inspected to determine if the leading '<'
   * was indeed the start of a whitelisted tag or not. If so, the tag is
   * emitted unescaped, and the remainder of the segment (which cannot contain
   * any additional tags) is emitted in escaped form.  Otherwise, the entire
   * segment is emitted in escaped form.
   *
   * In either case, htmlEscape is used to escape, which escapes HTML
   * but does not double escape existing syntactially valid HTML entities.
   *
   * TODO(ferhat): test suite & security review.
   */
  static String sanitize(String html, {bool useWhiteList: true}) {
    if (html.indexOf("<") == -1) {
      return html;
    }
    if (TAG_WHITELIST_SET == null) {
      TAG_WHITELIST_SET = new Set.from(TAG_WHITELIST);
    }

    StringBuffer sanitized = new StringBuffer();
    List<String> segments = html.split("<");
    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i];
      if (i == 0) {
        // the first segment is never part of a valid tag; note that if the
        // input string starts with a tag, we will get an empty segment at the
        // beginning.
        sanitized.write(_htmlEscapeAllowEntities(segment));
        continue;
      }

      // determine if the current segment is the start of an attribute-free tag
      // or end-tag in our whitelist
      int tagStart = 0; // will be 1 if this turns out to be an end tag.
      int tagEnd = segment.indexOf('>');
      String tag = null;
      bool isValidTag = false;
      if (tagEnd > 0) {
        if (segment[0] == '/') {
          tagStart = 1;
        }
        tag = segment.substring(tagStart, tagEnd);
        if (useWhiteList && TAG_WHITELIST_SET.contains(tag)) {
          isValidTag = true;
        }
      }

      if (isValidTag) {
        // append the tag, not escaping it
        if (tagStart == 0) {
          sanitized.write('<');
        } else {
          // we had seen an end-tag
          sanitized.write("</");
        }
        sanitized.write(tag);
        sanitized.write('>');

        // append the rest of the segment, escaping it
        sanitized.write(_htmlEscapeAllowEntities(segment.substring(tagEnd + 1)));
      } else {
        // just escape the whole segment
        sanitized.write("&lt;");
        sanitized.write(_htmlEscapeAllowEntities(segment));
      }
    }
    return sanitized.toString();
  }

  /**
   * HTML-escapes a string, but does not double-escape HTML-entities already
   * present in the string.
   *
   * @param text the string to be escaped
   * @return the input string, with all occurrences of HTML meta-characters
   * replaced with their corresponding HTML Entity References, with the
   * exception that ampersand characters are not double-escaped if they
   * form the start of an HTML Entity Reference.
   */
  static String _htmlEscapeAllowEntities(String text) {
    StringBuffer escaped = new StringBuffer();

    List<String> segments = text.split("&");
    for (int i = 0; i < segments.length; i++) {
      String segment = segments[i];
      if (i == 0) {
        // The first segment is never part of an entity reference, so we
        // always escape it. Note that if the input starts with an ampersand,
        // we will get an empty segment before that.
        escaped.write(htmlEscape(segment));
        continue;
      }

      int entityEnd = segment.indexOf(';');
      if (entityEnd > 0 && HTML_ENTITY_REGEX.hasMatch(
          segment.substring(0, entityEnd))) {
        // Append the entity without escaping.
        escaped.write("&");
        escaped.write(segment.substring(0, entityEnd + 1));

        // Append the rest of the segment, escaped.
        escaped.write(htmlEscape(segment.substring(entityEnd + 1)));
      } else {
        // The segment did not start with an entity reference, so escape the
        // whole segment.
        escaped.write("&amp;");
        escaped.write(htmlEscape(segment));
      }
    }

    return escaped.toString();
  }
}

/**
 * Escapes HTML-special characters of [text] so that the result can be
 * included verbatim in HTML source code, either in an element body or in an
 * attribute value.
 *
 * Used to be in dart:web library. TODO(ferhat): replace with new package.
 */
String htmlEscape(String text) {
  return text.replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&apos;");
}

