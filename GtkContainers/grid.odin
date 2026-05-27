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
  gtk.window_set_default_size(appwin, 500, 500)

  button1 := gtk.button_new_with_label("Button 1")
  button2 := gtk.button_new_with_label("Button 2")
  button3 := gtk.button_new_with_label("Button 3")
  button4 := gtk.button_new_with_label("Button 4")
  button5 := gtk.button_new_with_label("Button 5")
  button6 := gtk.button_new_with_label("Button 6")

  grid := gtk.grid_new()
  gtk.grid_attach(cast(^gtk.Grid)grid, button1, 0, 0, 1, 1)
  gtk.grid_attach(cast(^gtk.Grid)grid, button2, 1, 0, 2, 1)
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, button3, button1,
                          gtk.PositionType.POS_BOTTOM, 1, 2)
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, button4, button3,
                         gtk.PositionType.POS_RIGHT, 2, 1)
  gtk.grid_attach(cast(^gtk.Grid)grid, button5, 1, 2, 1, 1)
  gtk.grid_attach_next_to(cast(^gtk.Grid)grid, button6, button5,
                          gtk.PositionType.POS_RIGHT, 1, 1)

  gtk.window_set_child(appwin, grid)

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
