package main

import "core:fmt"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {
  // Replacement strdup function. Copies the original strings contents to
  // newly allocated memory, and returns a pointer to it.
  //  gchar* g_strdup    (const gchar *str);
  strcpy := glib.strdup("COPY ME")
  fmt.printf("glib.strdup: %v [%T]\n", strcpy, strcpy)

  // I recommend using this for all error messages. It's much nicer, and more portable than perror() or others. The output is usually of the form:
  // gchar* g_strerror  (gint errnum);
  errstr := glib.strerror(1)
  fmt.printf("glib.strerror(1): %v [%T]\n", errstr, errstr)
  errstr = glib.strerror(2)
  fmt.printf("glib.strerror(2): %v [%T]\n", errstr, errstr)
  errstr = glib.strerror(3)
  fmt.printf("glib.strerror(3): %v [%T]\n", errstr, errstr)

  // Here's an example of one such call used in our hello_world program:
  // program name:function that failed:file or further description:strerror
  fname :cstring = "filename"
  glib.print("hello_world:open:%s:%s\n", fname, glib.strerror(42))

  // Prints an error message. The format is just like printf, but it prepends
  // "** ERROR **: " to your message, and exits the program. Use only for
  // fatal errors.
  //  void g_error   (gchar *format, ...);
  glib.printerr("A glib.error message %d\n", 123)

  // Same as above, but prepends "** WARNING **: ", and does not exit the
  //  program.
  // void g_warning (gchar *format, ...);
  glib.warn_message("a domain name", "a file name", 42, "a func name", "a warnexpr")

  // Prints "message: " prepended to the string you pass in.
  // void g_message (gchar *format, ...);
  glib.test_message("test message %f\n", 3.141)

  // Replacement for printf().
  // void g_print   (gchar *format, ...);
  amsg :cstring = "a message from glib.print"
  glib.print("glib.print: %s\n", amsg)

  // Prints out the name of the Unix system signal given the signal number.
  // Useful in generic signal handling functions.
  //  gchar* g_strsignal (gint signum);
  fmt.printf("glib.strsignal(12): %s\n:", glib.strsignal(12))
}
