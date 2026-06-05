package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


Button1ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("Button1ClickedCB: appwin %p [%T]\n", appwin, appwin)
}

Button2ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  hbox := cast(^gtk.Box)cbData
  fmt.printf("Button2ClickedCB: hbox %p [%T]\n", hbox, hbox)
}
ShowTextToggledCB :: proc "c" (button :^gtk.CheckButton, cbArg :glib.pointer) {
  context = runtime.default_context()

  show_text := gtk.check_button_get_active(button)
  text :cstring = "SOME TEXT" if show_text else nil
  gtk.progress_bar_set_text(cast(^gtk.ProgressBar)V_progressbar, text)
  gtk.progress_bar_set_show_text(cast(^gtk.ProgressBar)V_progressbar, show_text)
  fmt.printf("ShowTextToggledCB: text='%s'\n", text)
}

ActivityModeToggledCB :: proc "c" (button :^gtk.CheckButton, cbArg :glib.pointer) {
  context = runtime.default_context()
  V_activityMode = gtk.check_button_get_active(button)
  if V_activityMode {
    gtk.progress_bar_pulse(cast(^gtk.ProgressBar)V_progressbar)
  } else {
    gtk.progress_bar_set_fraction(cast(^gtk.ProgressBar)V_progressbar, f64(0.0))
  }
}

RightToLeftToggledCB :: proc "c" (button :^gtk.CheckButton, cbArg :glib.pointer) {
  context = runtime.default_context()
  value := gtk.check_button_get_active(button)
  gtk.progress_bar_set_inverted(cast(^gtk.ProgressBar)V_progressbar, value)
}

TimeoutCB :: proc "c" (cbArg :glib.pointer) -> glib.boolean {
//        """Update value on the progress bar."""
  if V_activityMode {
    gtk.progress_bar_pulse(cast(^gtk.ProgressBar)V_progressbar)
  } else {
    val := gtk.progress_bar_get_fraction(cast(^gtk.ProgressBar)V_progressbar)
    val += 0.1
    if val > 1.0 { 
      val = 0.0
    }
    gtk.progress_bar_set_fraction(cast(^gtk.ProgressBar)V_progressbar, val)
  }

  // As this is a timeout function, return True so that it
  // continues to get called
  return true
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "ProgressBar Example")
//  gtk.window_set_default_size(appwin, 500, 150)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
  gtk.window_set_child(appwin, vbox)

  V_progressbar = gtk.progress_bar_new()
  gtk.box_append(cast(^gtk.Box)vbox, V_progressbar)

  button := gtk.check_button_new_with_label("Show text")
  @static cbArg1 :cstring = "ShowText"
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)ShowTextToggledCB,
                      cast(glib.pointer)&cbArg1)
  gtk.box_append(cast(^gtk.Box)vbox, button)

  button = gtk.check_button_new_with_label("Activity mode")
  @static cbArg2 :cstring = "ActivityMode"
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)ActivityModeToggledCB,
                      cast(glib.pointer)&cbArg2)
  gtk.box_append(cast(^gtk.Box)vbox, button)

  button = gtk.check_button_new_with_label("Right to Left")
  @static cbArg3 :cstring = "RightToLeft"
  gobj.signal_connect(button, "toggled",
                      cast(gobj.Callback)RightToLeftToggledCB,
                      cast(glib.pointer)&cbArg3)
  gtk.box_append(cast(^gtk.Box)vbox, button)

  @static cbArg4 :cstring = "Timeout"
  V_timeout_id = glib.timeout_add(50, TimeoutCB, rawptr(cbArg4))
  V_activityMode = false

  gtk.window_present(appwin)
}


V_timeout_id :u32 = 0
V_activityMode :glib.boolean = false
V_progressbar :^gtk.Widget = nil

//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.progress",
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
