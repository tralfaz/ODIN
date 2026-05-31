package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "NotedBook Example")
  gtk.window_set_default_size(appwin, 500, 150)

  notebook := gtk.notebook_new()
  gtk.window_set_child(appwin, notebook)

  page1 := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=0)
  lbl1 := gtk.label_new("Default Page!")
  gtk.box_append(cast(^gtk.Box)page1, lbl1)
  gtk.notebook_append_page(cast(^gtk.Notebook)notebook, page1,
                           gtk.label_new("Plain Title"))

  page2 := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=0)
  lbl2 := gtk.label_new("A page with an image for a Title.")
  gtk.box_append(cast(^gtk.Box)page2, lbl2)
  gtk.notebook_append_page(cast(^gtk.Notebook)notebook, page2,
                           gtk.image_new_from_icon_name("help-about"))

  gtk.window_present(appwin)
  fmt.printf("Button1ClickedCB: appwin %p [%T]\n", appwin, appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.FontDialog",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB,
                      cast(glib.pointer)&cbArg)

  argv := make([]cstring, len(os.args))
  for &arg, idx in argv {
    arg = strings.clone_to_cstring(os.args[idx])
  }
  defer delete(argv)
  defer for arg in argv do delete(arg)
  argc := i32(len(argv))

  sts := gio.application_run(
             gobj.type_cast(gio.Application, app, gio.TYPE_APPLICATION()),
             argc, raw_data(argv))      
  gobj.object_unref(app)

  if sts != 0 {
    os.exit(int(sts))
  }
}      
