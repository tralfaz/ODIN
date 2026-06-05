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


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Labels Demo")
//  gtk.window_set_default_size(appwin, 500, 150)

  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=10)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
  gtk.window_set_child(appwin, hbox)

  lvbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=10)
  gtk.box_set_homogeneous(cast(^gtk.Box)lvbox, true)
  gtk.widget_set_hexpand(lvbox, true)
  rvbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=10)

  gtk.box_append(cast(^gtk.Box)hbox, lvbox)
  gtk.box_append(cast(^gtk.Box)hbox, rvbox)

  label := gtk.label_new("This is a normal label")
  gtk.box_append(cast(^gtk.Box)lvbox, label)

  label = gtk.label_new("This is a normal label with xalign set to 0")
  gtk.label_set_xalign(cast(^gtk.Label)label, f32(0))
  gtk.box_append(cast(^gtk.Box)lvbox, label)

  label = gtk.label_new("This is a left-justified label.\nWith multiple lines.")
  gtk.label_set_justify(cast(^gtk.Label)label, gtk.Justification.JUSTIFY_LEFT)
  gtk.box_append(cast(^gtk.Box)lvbox, label)

  label = gtk.label_new("This is a right-justified label.\nWith multiple lines.")
  gtk.label_set_justify(cast(^gtk.Label)label, gtk.Justification.JUSTIFY_RIGHT)
  gtk.box_append(cast(^gtk.Box)lvbox, label)

  label = gtk.label_new(`This is an example of a line-wrapped label.  It 
should not be taking up the entire             
width allocated to it, but automatically 
wraps the words to fit.\n
     It supports multiple paragraphs correctly, 
and  correctly   adds 
many          extra  spaces. `)
  gtk.label_set_wrap(cast(^gtk.Label)label, true)
  gtk.label_set_max_width_chars(cast(^gtk.Label)label, 32)
  gtk.box_append(cast(^gtk.Box)rvbox, label)

  label = gtk.label_new(`This is an example of a line-wrapped, filled label. "
"It should be taking 
"up the entire              width allocated to it.  
"Here is a sentence to prove 
"my point.  Here is another sentence. 
Here comes the sun, do de do de do.

    This is a new paragraph.

    This is another newer, longer, better 
paragraph.  It is coming to an end, 
unfortunately.`)
  gtk.label_set_wrap(cast(^gtk.Label)label, true)
  gtk.label_set_justify(cast(^gtk.Label)label, gtk.Justification.JUSTIFY_FILL)
  gtk.label_set_max_width_chars(cast(^gtk.Label)label, 32)
  gtk.box_append(cast(^gtk.Box)rvbox, label)

  label = gtk.label_new("XXX")
  gtk.label_set_wrap(cast(^gtk.Label)label, true)
  gtk.label_set_max_width_chars(cast(^gtk.Label)label, 48)
  gtk.label_set_markup(cast(^gtk.Label)label,
                       "Text can be <small>small</small>, <big>big</big>, " +
                       "<b>bold</b>, <i>italic</i> and even point to "      +
                       `somewhere in the <a href="https://www.gtk.org" `    +
                       `title="Click to find out more">internets</a>.`)
  gtk.box_append(cast(^gtk.Box)lvbox, label)

  button := gtk.button_new_with_label("Click at your own risk")
  label = gtk.label_new("_Press Alt + P to select button to the right")
  gobj.set_boolean_property(cast(^gobj.Object)label, "use-underline", true)
  gtk.label_set_selectable(cast(^gtk.Label)label, true)
  gtk.label_set_mnemonic_widget(cast(^gtk.Label)label, button)
  gtk.box_append(cast(^gtk.Box)lvbox, label)
  gtk.box_append(cast(^gtk.Box)rvbox, button)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.labels",
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
