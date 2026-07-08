package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import pango "../gtk4m/pango"
import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import grph "../gtk4m/graphene"
import gtk  "../gtk4m/gtk"


DemoWidget :: struct {
  parent_instance :gtk.Widget 
}


//G_DECLARE_FINAL_TYPE (DemoWidget, demo_widget, DEMO, WIDGET, GtkWidget)
demo_widget_type_id :gobj.Type
demo_widget_get_type :: proc "c" () -> gobj.Type {
  if person_type_id == 0 {
    demo_widget_type_id = gobj.type_register_static_simple(
            gobj.TYPE_OBJECT,
            glib.intern_static_string("DemoWidget"),
            size_of(DemoWidgetClass),
            demo_widget_class_intern_init,
            size_of(Person),
            demo_widget_init,
            .NONE)
  }

  return demo_widget_type_id
}


//G_DEFINE_TYPE(DemoWidget, demo_widget, GTK_TYPE_WIDGET)

demo_widget_init :: proc "c" (self :^DemoWidget) {
}

/* --- THE GSK RENDERING PIPELINE --- */
demo_widget_snapshot :: proc "c" (widget :^gtk.Widget,
                                  snapshot :^gtk.Snapshot) {
  width  := gtk.widget_get_width(widget)
  height := gtk.widget_get_height(widget)

  /* 1. Define bounds & corners for a rounded rectangle */
  bounds := grph.rect_t{ origin.x = 0, origin.y = 0,
                         size.width = width, size.height = height }
  radius :f64 = 20.0
  radii :[4]f64 = { radius, radius, radius, radius }

  /* 2. Push a Rounded Clip node to enforce round corners */
  grrect := gtk.RoundedRect{ bounds = bounds,
                             corner = { {radius,radius},
                                        {radius,radius},
                                        {radius,radius},
                                        {radius,radius} }
                            }
  gtk.snapshot_push_rounded_clip(GskRoundedRectsnapshot, &grrect)

  /* 3. Create a Linear Gradient */
  colors :[2]gtk.RGBA
  gtk.gdk_rgba_parse(&colors[0], "rgba(255,100,100,1)") // Start color
  gtk.gdk_rgba_parse(&colors[1], "rgba(100,100,255,1)"); // End color
  
  gtk.snapshot_append_linear_gradient(snapshot,
                                      &bounds,
    &(grph.point_t){ x = 0, y = 0 },
    &(grph.point_t){ x = width, y = height },
    (gtk.ColorStop[2]){
      { .offset = 0.0, .color = (GdkRGBA){ 1.0, 0.2, 0.2, 1.0 } },  // Red
      { .offset = 1.0, .color = (GdkRGBA){ 0.2, 0.2, 1.0, 1.0 } }   // Blue
    }, 2)

  /* 4. Draw Text using a Pango Layout */
  layout := gtk.widget_create_pango_layout(widget, "GSK + GTK 4")
  font_desc := pango.font_description_from_string("Sans Bold 24")
  pango.layout_set_font_description(layout, font_desc)
  
  /* Append text node to the snapshot */
  textclr :gtk.RGBA{1.0, 1.0, 1.0, 1.0}
  gtk_snapshot_append_layout(snapshot, layout, &textclr)

  /* 5. Clean up nodes */
  gobj.object_unref(layout)
  pango.font_description_free(font_desc)
  gtk.snapshot_pop(snapshot) /* Pop the rounded clip */
}

demo_widget_class_init :: proc "c" (klass :^DemoWidgetClass) {
  widget_class = cast(^gtk.WidgetClass)klass
  widget_class.snapshot = demo_widget_snapshot
}

Button1ClickedCB :: proc "c" (button :^gtk.Button, cbData :glib.pointer) {
  context = runtime.default_context()
  appwin := cast(^gtk.Window)cbData
  fmt.printf("Button1ClickedCB: appwin %p [%T]\n", appwin, appwin)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "GSK Render Node Demo")
  gtk.window_set_default_size(appwin, 300, 200)

/*
  hbox := gtk.box_new(gtk.Orientation.HORIZONTAL, spacing=6)
  //gtk.box_set_spacing(cast(^gtk.Box)hbox, 6)
  //box_set_homogeneous :: proc(box: ^Box, homogeneous: glib.boolean)
  //gtk.box_set_baseline_position(box: ^Box, position: BaselinePosition)
  //gtk.box_set_baseline_child(box: ^Box, child: i32)
  gtk.window_set_child(appwin, hbox)

  button1 := gtk.button_new_with_label("Hello")
  gobj.signal_connect(button1, "clicked",
                     cast(gobj.Callback)Button1ClickedCB, appwin)
  gtk.box_append(cast(^gtk.Box)hbox, button1)
  fmt.printf("AppActivateCB: appwin %p [%T]\n", appwin, appwin)
*/
//////////
  demoWgt := demo_widget_get_type()
  my_widget := gobj.object_new(demoWgt, nil)
  gtk_window_set_child (GTK_WINDOW (window), my_widget);
//////////

  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("com.example.GSKDemo",
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
