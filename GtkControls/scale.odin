package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


// Callback function to handle the value-changed signal
ScaleValueChangedCB :: proc "c" (range :^gtk.Range, user_data :glib.pointer) {
  context = runtime.default_context()
  label := cast(^gtk.Label)user_data
    
  // Get the current value of the scale
  value := gtk.range_get_value(range)
    
  // Update the label with the current scale value
  text := fmt.aprintf("Value: %.2f", value)
  defer delete(text)
  ctext := strings.clone_to_cstring(text)
  defer delete(ctext)
  gtk.label_set_text(label, ctext)
//  fmt.printf("Value: %.2f\n", value)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Scale Demo")
  gtk.window_set_default_size(appwin, 300, 200)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=10)
  gtk.widget_set_halign(vbox, gtk.Align.CENTER)
  gtk.widget_set_valign(vbox, gtk.Align.CENTER)
  gtk.window_set_child(appwin, vbox)

  // Create a horizontal scale (slider)
  // Parameters: Orientation, min, max, step_increment
  scale := gtk.scale_new_with_range(gtk.Orientation.HORIZONTAL,
                                    0.0, 100.0, 1.0)
  gtk.scale_set_draw_value (cast(^gtk.Scale)scale, true)
  gtk.widget_set_size_request(scale, 200, -1)
  gtk.box_append(cast(^gtk.Box)vbox, scale)

  // Create a label to display the selected value
  label := gtk.label_new("Value: 0.00")
  gtk.box_append(cast(^gtk.Box)vbox, label)

  // Connect the scale's value-changed signal to our callback
  // (Notice signal is on the parent GtkRange class)
  gobj.signal_connect(scale, "value-changed",
                      cast(gobj.Callback)ScaleValueChangedCB,
                      cast(glib.pointer)label)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {
  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.scale",
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
