package main

import "core:fmt"
import "core:os"
import "core:strings"

import glib "../gtk4m/glib"
import gio  "../gtk4m/gio"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


// Callback triggered when the button is clicked
ButtonClickedCB :: proc "c" (button :^gtk.Button, user_data :glib.pointer) {
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Horizontal CenterBox Example")
  gtk.window_set_default_size(appwin, 500, 150)

  hctrbox := gtk.center_box_new()
  gtk.window_set_child(appwin, hctrbox)
    
  start := gtk.button_new_with_label("Start")
  gtk.center_box_set_start_widget(cast(^gtk.CenterBox)hctrbox, start)
    
  center := gtk.button_new_with_label("Center")
  gtk.center_box_set_center_widget(cast(^gtk.CenterBox)hctrbox, center)
//    gobj.signal_connect(button, "clicked",
//                       cast(gobj.Callback)on_button_clicked, appwin)
  gtk.widget_set_hexpand(center, true)

  end := gtk.button_new_with_label("End")
  gtk.center_box_set_end_widget(cast(^gtk.CenterBox)hctrbox, end)

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
                      cast(gobj.Callback)AppActivateCB, cast(glib.pointer)&cbArg)

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
