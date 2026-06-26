package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


DropCB :: proc "c" (target :^gtk.DropTarget, value :^gobj.Value,
                    x :f64, y :f64, cbData :glib.pointer) -> glib.boolean {
  context = runtime.default_context()

  label := cast(^gtk.Widget)cbData

  // Extract the dropped data
  if gobj.type_check_value_holds(value, gobj.TYPE_STRING)  {
    str := gobj.value_get_string(value)
    lbl := cast(^gtk.Label)cbData
    gtk.label_set_text(cast(^gtk.Label)lbl, str)
    return true // Drop successfully handled
  }

  return false // Drop rejected
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Drop Text Example")
  gtk.window_set_default_size(appwin, 300, 200)

  // Create a label to act as our drop target
  label := gtk.label_new("Drop text here")
  gtk.window_set_child(appwin, label)

  // Create the Drop Target
  // Accept only string (text) types and allow COPY operations
  target := gtk.drop_target_new(gobj.TYPE_STRING, gtk.DragAction.ACTION_COPY)
    
  // Connect the drop signal
  gobj.signal_connect(target, "drop",
                     cast(gobj.Callback)DropCB, label)

  // Attach the drop target to the label
  gtk.widget_add_controller(label, cast(^gtk.EventController)target)

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
