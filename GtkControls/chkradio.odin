package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


CheckToggledCB :: proc "c" (chkbtn :^gtk.CheckButton, cbData :glib.pointer) {
  context = runtime.default_context()

  chkarg := cast(cstring)cbData
  wasact := gtk.check_button_get_active(chkbtn)
  chkwas := "off"
  if !wasact {
    chkwas = "on"
  }
  fmt.printf("Checkbox(%s) was turned %s\n", chkarg, chkwas)
}

RadioToggledCB :: proc "c" (chkbtn :^gtk.CheckButton, cbData :glib.pointer) {
  context = runtime.default_context()

  chkarg := cast(cstring)cbData
  wasact := gtk.check_button_get_active(chkbtn)
  chkwas := "off"
  if !wasact {
    chkwas = "on"
  }
  fmt.printf("Radio[%s] was turned %s\n", chkarg, chkwas)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Check Button Demo")
  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.window_set_child(appwin, hbox)

  check := gtk.check_button_new_with_label("Checkbox")
  cbarg0 :cstring = "Check-0"
  gobj.signal_connect(check, "toggled",
                     cast(gobj.Callback)CheckToggledCB, rawptr(cbarg0))
  gtk.box_append(cast(^gtk.Box)hbox, check)

  radio1 := gtk.check_button_new_with_label("Radio 1")
  gtk.check_button_set_active(cast(^gtk.CheckButton)radio1, true)
  cbarg1 :cstring = "R1"
  gobj.signal_connect(radio1, "toggled",
                      cast(gobj.Callback)RadioToggledCB, rawptr(cbarg1))
  gtk.box_append(cast(^gtk.Box)hbox, radio1)

  radio2 := gtk.check_button_new_with_label("Radio 2")
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio2,
                              group=cast(^gtk.CheckButton)radio1)
  cbarg2 :cstring = "R2"
  gobj.signal_connect(radio2, "toggled",
                      cast(gobj.Callback)RadioToggledCB, rawptr(cbarg2))
  gtk.box_append(cast(^gtk.Box)hbox, radio2)

  radio3 := gtk.check_button_new_with_label("R_adio 3")
  gobj.set_boolean_property(cast(^gobj.Object)radio3, "use-underline", true)
  gtk.check_button_set_group(cast(^gtk.CheckButton)radio3,
                              group=cast(^gtk.CheckButton)radio1)
  cbarg3 :cstring = "R3"
  gobj.signal_connect(radio3, "toggled",
                      cast(gobj.Callback)RadioToggledCB, rawptr(cbarg3))
  gtk.box_append(cast(^gtk.Box)hbox, radio3)

  gtk.window_present(appwin)
}
/*
// Create the first button
GtkWidget *button1 = gtk_check_button_new_with_label("Option 1");
gtk_check_button_set_active(GTK_CHECK_BUTTON(button1), TRUE); // Set as default

// Create the second button and group it with the first
GtkWidget *button2 = gtk_check_button_new_with_label("Option 2");
gtk_check_button_set_group(GTK_CHECK_BUTTON(button2), GTK_CHECK_BUTTON(button1));

// Create the third button and group it with the first
GtkWidget *button3 = gtk_check_button_new_with_label("Option 3");
gtk_check_button_set_group(GTK_CHECK_BUTTON(button3), GTK_CHECK_BUTTON(button1));
*/

//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.check-button",
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




