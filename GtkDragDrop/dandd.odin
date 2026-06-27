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



// 1. Prepare data when the drag begins
//GdkContentProvider*
DragPrepareCB :: proc "c" (source :^gtk.DragSource,
                           x :f64, y :f64,
                           cbData :glib.pointer) -> ^gtk.ContentProvider {
  // Return the string wrapped in a GValue content provider
  value :gobj.Value // = G_VALUE_INIT;
  gobj.value_init(&value, gobj.TYPE_STRING)
  gobj.value_set_string(&value, "Hello from the Drag Source!")

  provider := gtk.gdk_content_provider_new_for_value(&value)
  gobj.value_unset(&value)

  return provider
}

// 2. Handle data when it is dropped on the target
DropCB :: proc "c" (target :^gtk.DropTarget, value :^gobj.Value,
                    x :f64, y :f64,
                    cbData :glib.pointer) -> glib.boolean {
  destination_button := cast(^gtk.Widget)cbData
    
  // Extract the text data from the GValue
  text := gobj.value_get_string(value)
    
  // Update the destination widget's label
  gtk.button_set_label(cast(^gtk.Button)destination_button, text)
    
  // Return TRUE to signal the drop was successfully handled
  return true
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "GTK 4 Drag and Drop")
  gtk.window_set_default_size(appwin, 300, 200)

  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)

  // Create layout container
  vbox := gtk.box_new(gtk.Orientation.VERTICAL, spacing=20)
  gtk.widget_set_margin_top(vbox, 40)
  gtk.widget_set_margin_bottom(vbox, 40)
  gtk.window_set_child(appwin, vbox)

  // --- SETUP SOURCE WIDGET ---
  source_label := gtk.label_new("Drag me!")
  gtk.box_append(cast(^gtk.Box)vbox, source_label)

  // Initialize the Drag Source controller
  //GtkDragSource*
  drag_source := gtk.drag_source_new()
  // Restrict operation to a copy action
  gtk.drag_source_set_actions(drag_source, gtk.DragAction.ACTION_COPY) 
    
  // Connect the prepare signal to load your payload data
  gobj.signal_connect(drag_source, "prepare",
                     cast(gobj.Callback)DragPrepareCB, nil)
 
  // Attach the controller to the source widget
  gtk.widget_add_controller(source_label, cast(^gtk.EventController)drag_source)

  // --- SETUP DESTINATION WIDGET ---
  dest_button := gtk.button_new_with_label("Drop here")
  gtk.box_append (cast(^gtk.Box)vbox, dest_button)

  // Initialize the Drop Target controller matching the string type
  //GtkDropTarget*
  drop_target := gtk.drop_target_new(gobj.TYPE_STRING,
                                     gtk.DragAction.ACTION_COPY)
    
  // Connect the drop signal to process the payload
  gobj.signal_connect(drop_target, "drop",
                      cast(gobj.Callback)DropCB, dest_button)

  // Attach the controller to the destination widget
  gtk.widget_add_controller(dest_button, cast(^gtk.EventController)drop_target)

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.dnd",
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
