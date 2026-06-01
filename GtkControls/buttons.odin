package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


ClickMeClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("[Click me] button was clicked\n")
}

OpenClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  fmt.printf("[Open] button was clicked\n")
}

CloseClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("Closing application\n")
  gtk.window_close(appwin)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Horizontal Box Example")
  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.window_set_child(appwin, hbox)

  button := gtk.button_new_with_label("Click Me")
  gobj.signal_connect(button, "clicked",
                     cast(gobj.Callback)ClickMeClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button)

  button = gtk.button_new_with_mnemonic("_Open")
  gobj.signal_connect(button, "clicked",
                     cast(gobj.Callback)OpenClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button)

  button = gtk.button_new_with_mnemonic("_Close")
  gobj.signal_connect(button, "clicked",
                     cast(gobj.Callback)CloseClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button)

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
