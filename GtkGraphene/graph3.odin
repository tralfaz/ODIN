package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import cairo "../gtk4m/cairo"
import gio   "../gtk4m/gio"
import glib  "../gtk4m/glib"
import gobj  "../gtk4m/gobject"
import gtk   "../gtk4m/gtk"


/* Surface to store current scribbles */
surface :^cairo.surface_t = nil
clear_surface :: proc "c" () {
  cr := cairo.create(surface) //^cairo.context_t
  cairo.set_source_rgb(cr, 1, 1, 1)
  cairo.paint(cr)
  cairo.destroy(cr)
}

/* Create a new surface of the appropriate size to store our scribbles */
resize_cb :: proc "c" (widget :^gtk.Widget,
                       width  :i32,
                       height :i32,
                       data   :glib.pointer)
{
  if surface != nil {
    cairo.surface_destroy(surface)
    surface = nil
  }
  if gtk.native_get_surface(gtk.widget_get_native(widget)) != nil {
    native_wgt := gtk.widget_get_native(widget)
    wgt_surface := gtk.native_get_surface(native_wgt)
    surface = gtk.gdk_surface_create_similar_surface(wgt_surface,
                                                 cairo.content_t.COLOR,
                                                 gtk.widget_get_width(widget),
                                                 gtk.widget_get_height(widget))
    /* Initialize the surface to white */
    clear_surface()
  }
}

/* Redraw the screen from the surface. Note that the draw
 * callback receives a ready-to-be-used cairo_t that is already
 * clipped to only draw the exposed areas of the widget
 */
draw_cb :: proc "c" (drawing_area :^gtk.DrawingArea,
                     cr           :^cairo.context_t,
                     width        :i32,
                     height       :i32,
                     data         :glib.pointer) {
  cairo.set_source_surface(cr, surface, 0, 0)
  cairo.paint(cr)
}

/* Draw a rectangle on the surface at the given position */
draw_brush :: proc "c" (widget :^gtk.Widget,
                     x      :f64,
                     y      :f64) {
  /* Paint to the surface, where we store our state */
  cr := cairo.create(surface)
  cairo.rectangle(cr, x - 3.0, y - 3.0, 6, 6)
  cairo.fill(cr)
  cairo.destroy(cr)

  /* Now invalidate the drawing area. */
  gtk.widget_queue_draw(widget)
}

start_x :f64 = 0.0
start_y :f64 = 0.0
drag_begin :: proc "c" (gesture :^gtk.GestureDrag,
                        x       :f64,
                        y       :f64,
                        area    :^gtk.Widget) {
  start_x = x
  start_y = y
  draw_brush(area, x, y)
}

drag_update :: proc "c" (gesture :^gtk.GestureDrag,
                         x       :f64,
                         y       :f64,
                         area    :^gtk.Widget) {
  draw_brush(area, start_x + x, start_y + y)
}

drag_end :: proc "c" (gesture :^gtk.GestureDrag,
                      x       :f64,
                      y       :f64,
                      area    :^gtk.Widget) {
  draw_brush(area, start_x + x, start_y + y)
}

pressed :: proc "c" (gesture :^gtk.GestureClick,
                     n_press :i32,
                     x       :f64,
                     y       :f64,
                     area    :^gtk.Widget) {
  clear_surface()
  gtk.widget_queue_draw(area)
}

close_window :: proc "c" () {
  if surface != nil {
    cairo.surface_destroy(surface)
  }
}

AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  context = runtime.default_context()

  appwgt := gtk.application_window_new(app)
  appwin := cast(^gtk.Window)appwgt
  gtk.window_set_title(appwin, "Drawing Area")
  gtk.window_set_default_size(appwin, 500, 500)

  gobj.signal_connect(appwgt, "destroy",
                     cast(gobj.Callback)close_window, nil)


  drawing_area := gtk.drawing_area_new()

  /* set a minimum size */
  gtk.widget_set_size_request(drawing_area, 500, 500);
  gtk.window_set_child(appwin, drawing_area)

  gtk.drawing_area_set_draw_func(cast(^gtk.DrawingArea)drawing_area,
                                 draw_cb, nil, nil)
  //g_signal_connect_after (drawing_area, "resize", G_CALLBACK (resize_cb), NULL);
  gobj.signal_connect_after(drawing_area, "resize",
                     cast(gobj.Callback)resize_cb, nil)

  drag := gtk.gesture_drag_new()
  gtk.gesture_single_set_button(cast(^gtk.GestureSingle)drag, 1)//gtk.BUTTON_PRIMARY)
  gtk.widget_add_controller(drawing_area, cast(^gtk.EventController)drag)
  gobj.signal_connect(drag, "drag-begin",
                      cast(gobj.Callback)drag_begin, drawing_area)
  gobj.signal_connect(drag, "drag-update",
                      cast(gobj.Callback)drag_update, drawing_area)
  gobj.signal_connect(drag, "drag-end",
                      cast(gobj.Callback)drag_end, drawing_area)

  press := gtk.gesture_click_new()
  gtk.gesture_single_set_button(cast(^gtk.GestureSingle)press, 3)//gtk.BUTTON_SECONDARY)
  gtk.widget_add_controller(drawing_area, cast(^gtk.EventController)press)
  gobj.signal_connect(press, "pressed",
                      cast(gobj.Callback)pressed, drawing_area)

//  gtk.widget_show(appwgt)
  gtk.window_present(appwin)
}


//
// MAIN
//
main :: proc() {

  cbArg :cstring = "CB Arg"
  app := gtk.application_new("org.gtk.example",
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
