package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import gtk  "../gtk4m/gtk"


ValueChangedCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()

  spinbtn := cast(^gtk.SpinButton)sender
  fmt.printf("ValueChangedCB: %v\n", gtk.spin_button_get_value_as_int(spinbtn))
}

IfValidToggledCB :: proc "c" (sender :^gtk.Widget, cbData :glib.pointer) {
  context = runtime.default_context()

  tglbtn := cast(^gtk.CheckButton)sender
  policy := gtk.SpinButtonUpdatePolicy.UPDATE_ALWAYS
  if gtk.check_button_get_active(tglbtn) {
    policy = gtk.SpinButtonUpdatePolicy.UPDATE_IF_VALID
  }
//  spinbutton.props.update_policy = policy
  spnbtn := cast(^gtk.SpinButton)cbData
  gtk.spin_button_set_update_policy(spnbtn, policy)
  fmt.printf("IfValidToggledCB: %v\n", policy)
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Spin Button Example")
//  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  gtk.window_set_child(appwin, hbox)

//  adjustment := gtk.adjustment_new(value=f64(50.0),
//                                   lower=f64(0), upper=f64(100.0),
//                                   step_increment=f64(1.0),
//                                   page_size=f64(100), page_increment=f64(10.0))
  adjustment := gtk.adjustment_new(50.0, 0.0, 100.0, 1.0, 5.0, 0.0)
//adjustment_new(value: f64, lower: f64, upper: f64, step_increment: f64, page_increment: f64, page_size: f64) -> ^Adjustment ---

//  spinbutton := gtk.spin_button_new(adjustment=adjustment,
//                                    climb_rate=f64(1), digits=4)
  spinbutton := gtk.spin_button_new(adjustment, 1.0, 0.0)
//spin_button_new(adjustment: ^Adjustment, climb_rate: f64, digits: glib.uint_) -> ^Widget
  gobj.signal_connect(spinbutton, "value-changed",
                      cast(gobj.Callback)ValueChangedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, spinbutton)

  check_numeric := gtk.check_button_new_with_label("Numeric")
//  check_numeric.bind_property("active", self.spinbutton, "numeric", 0)
  gtk.box_append(cast(^gtk.Box)hbox, check_numeric)

  check_ifvalid := gtk.check_button_new_with_label("If Valid")
  gobj.signal_connect(check_ifvalid, "toggled",
                     cast(gobj.Callback)IfValidToggledCB, spinbutton)
  gtk.box_append(cast(^gtk.Box)hbox, check_ifvalid)

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
