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
  gtk.window_set_title(appwin, "HeaderBar Example")
  gtk.window_set_default_size(appwin, 500, 150)

  header_bar := gtk.action_bar_new()
//  gtk.window_set_child(appwin, header_bar)
  gtk.window_set_titlebar(appwin, header_bar)

  button := gtk.button_new_with_label("Button")
  gtk.action_bar_pack_start(cast(^gtk.ActionBar)header_bar, button)

  icon_button := gtk.button_new_from_icon_name(icon_name="oapen-menu-symbolic")
  gtk.action_bar_pack_end(cast(^gtk.ActionBar)header_bar, icon_button)

  gtk.window_present(appwin)
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

