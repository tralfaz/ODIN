package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

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

}
// Handles 'clicked' event of button_start.
StartButtonClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  StartTimer()
  fmt.printf("StartButtonClickedCB:\n")
}

// Handles 'clicked' event of button_stop."""
StopButtonClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  StopTimer("Stopped from button")
  fmt.printf("StopButtonClickedCB:\n")
}

//    def on_window_destroy(self, _widget):
//        """Handles unrealize event of main window."""
//        # Ensure the timeout function is stopped
//        if self.timeout_id:
//            GLib.source_remove(self.timeout_id)
//            self.timeout_id = None

// A timeout function.
// Return True to stop it.
// This is not a precise timer since next timeout is recalculated based on the
// current time.
//
TimeoutCB :: proc "c" (cbArg :glib.pointer) -> glib.boolean {
  context = runtime.default_context()
  fmt.printf("TimeoutCB: counter=%d\n", V_counter)
  V_counter -= 1
  if V_counter <= 0 {
    StopTimer("Reached time out")
    return false
  }
  lblstr := fmt.aprintf("Remaining: %d!", V_counter / 4)
  lbltxt := strings.clone_to_cstring(lblstr)
  defer delete(lbltxt)
  gtk.label_set_text(cast(^gtk.Label)V_label, lbltxt)
  return true
}

// Start the timer.
StartTimer :: proc () {
  context = runtime.default_context()
  gtk.widget_set_sensitive(V_start_btn, false)
  gtk.widget_set_sensitive(V_stop_btn, true)
  // time out will check every 250 milliseconds (1/4 of a second)
  entbuf := gtk.entry_get_buffer(cast(^gtk.Entry)V_entry)
  enttxt := gtk.entry_buffer_get_text(entbuf)
    ival, ok := strconv.parse_int(string(enttxt))
  if ok {
    V_counter = i32(4 * ival)
  } else {
    return
  }
  fmt.printf("StartTimer: %v [%T]\n", enttxt, enttxt)
  lblstr := fmt.aprintf("Remaining: %d",  V_counter / 4)
  lbltxt := strings.clone_to_cstring(lblstr)
  defer delete(lbltxt)
  gtk.label_set_text(cast(^gtk.Label)V_label, lbltxt)
  gtk.spinner_start(cast(^gtk.Spinner)V_spinner)
  V_timeout_id = glib.timeout_add(250, TimeoutCB, nil)
  fmt.printf("StartTimer: enttxt='%s'\n", enttxt)  
}

// Stop the timer.
StopTimer :: proc (label_text :cstring) {
  if V_timeout_id != 0 {
    glib.source_remove(V_timeout_id)
    V_timeout_id = 0
  }
  gtk.spinner_stop(cast(^gtk.Spinner)V_spinner)
  gtk.widget_set_sensitive(V_start_btn, true)
  gtk.widget_set_sensitive(V_stop_btn, false)
  gtk.label_set_text(cast(^gtk.Label)V_label, label_text)
}

V_start_btn :^gtk.Widget = nil
V_stop_btn :^gtk.Widget = nil
V_entry :^gtk.Widget = nil
V_label :^gtk.Widget = nil
V_spinner :^gtk.Widget = nil
V_timeout_id :u32 = 0
V_counter :i32 = 0

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Spinner Extra Example")
//  gtk.window_set_default_size(appwin, 500, 150)

  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=6)
  gtk.window_set_child(appwin, vbox)

  V_spinner = gtk.spinner_new()
  gtk.box_append(cast(^gtk.Box)vbox, V_spinner)

  V_label = gtk.label_new("")
  gtk.box_append(cast(^gtk.Box)vbox, V_label)

  entbuf := gtk.entry_buffer_new("", 0)
  gtk.entry_buffer_set_text(entbuf, "10", 2)
  V_entry = gtk.entry_new_with_buffer(entbuf)
  gtk.box_append(cast(^gtk.Box)vbox, V_entry)

  V_start_btn = gtk.button_new_with_label("Start timer")
  gobj.signal_connect(V_start_btn, "clicked",
                      cast(gobj.Callback)StartButtonClickedCB, nil)
  gtk.box_append(cast(^gtk.Box)vbox, V_start_btn)

  V_stop_btn = gtk.button_new_with_label("Stop timer")
  gtk.widget_set_sensitive(V_stop_btn, false)
  gobj.signal_connect(V_stop_btn, "clicked",
                      cast(gobj.Callback)StopButtonClickedCB, nil)
  gtk.box_append(cast(^gtk.Box)vbox, V_stop_btn)

  V_timeout_id = 0

//  gobj.signal_connect(appwgt, "unrealize", self.on_window_destroy)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.spinnerext",
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
