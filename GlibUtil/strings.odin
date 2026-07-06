package main

import "core:fmt"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {
  // GString* g_string_new       (gchar   *init);
  newgstr := glib.string_new("duplicated")
  fmt.printf("glib.string_new: %v [%T]\n", newgstr, newgstr)

  // void g_string_free      (GString *string, gint free_segment);
  glib.string_free(newgstr, true)
  fmt.printf("glib.string_free(newgstr, true)\n")

  // GString* g_string_assign    (GString *lval, gchar *rval);
  lval := glib.string_new(nil)
  rval := glib.string_new("assigned value")
  ares := glib.string_assign(lval, "assigned value")
  fmt.printf("glib.string_assign: lval=%v ares=%v &lval=%p &ares=%p\n",
             lval, ares, lval, ares)

  // GString* g_string_truncate  (GString *string, gint len);
  truncme := glib.string_new("truncate this: XXXXXXX")
  fmt.printf("before:: truncme=%v\n", truncme.str)
  trunced := glib.string_truncate(truncme, 15)
  fmt.printf("after:: truncme=%v trunced=%v\n", truncme.str, trunced.str)

  // GString* g_string_append(GString *string, gchar *val);
  accum := glib.string_new("BEGIN")
  fmt.printf("before append: accum=%s\n", accum.str)
  glib.string_append(accum, "ONE")
  fmt.printf("after append ONE: accum=%s\n", accum.str)
  glib.string_append(accum, "TWO")
  fmt.printf("after append TWO: accum=%s\n", accum.str)
  glib.string_append(accum, "THREE")
  fmt.printf("after append THREE: accum=%s\n", accum.str)

  // GString* g_string_append_c(GString *string, gchar c);
  accumc := glib.string_new("begin")
  fmt.printf("before append_c: accumc=%s\n", accumc.str)
  glib.string_append_c(accumc, 'X')
  fmt.printf("after append_c X: accumc=%s\n", accumc.str)
  glib.string_append_c(accumc, 'Y')
  fmt.printf("after append_c Y: accumc=%s\n", accumc.str)
  glib.string_append_c(accumc, 'Z')
  fmt.printf("after append_c Z: accumc=%s\n", accumc.str)
}
/*
        
GString* g_string_prepend   (GString *string,
                             gchar   *val);
                             
GString* g_string_prepend_c (GString *string,
                             gchar    c);
        
void     g_string_sprintf   (GString *string,
                             gchar   *fmt,
                             ...);
        
void     g_string_sprintfa  (GString *string,
                             gchar   *fmt,
                             ...);
*/
