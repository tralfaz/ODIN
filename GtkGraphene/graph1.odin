package main

import "base:runtime"
import "core:fmt"
import "core:os"
import "core:strings"

import cairo "../gtk4m/cairo"
import gio  "../gtk4m/gio"
import glib "../gtk4m/glib"
import gobj "../gtk4m/gobject"
import grph "../gtk4m/graphene"
import gtk  "../gtk4m/gtk"


/* Callback for the drawing area: draws a triangle using Graphene math */
draw_func :: proc "c" (area :^gtk.DrawingArea,
                       cr: ^cairo.context_t,
                       width  :i32,
                       height :i32,
                       user_data :glib.pointer)
{
  /* 1. Initialize ourvectors using Graphene */
  p1 := grph.point3d_t{ x =   0.0, y = -50.0, z = 0.0 }
  p2 := grph.point3d_t{ x = -50.0, y =  50.0, z = 0.0 }
  p3 := grph.point3d_t{ x =  50.0, y =  50.0, z = 0.0 }

  /* 2. Create a Graphene Matrix for rotation */
  matrix1 :grph.matrix_t
  grph.matrix_init_rotate(&matrix1, 45.0, grph.vec3_z_axis())

  /* 3. Transform the points using the matrix */
  grph.matrix_transform_point3d(&matrix1, &p1, &p1)
  grph.matrix_transform_point3d(&matrix1, &p2, &p2)
  grph.matrix_transform_point3d(&matrix1, &p3, &p3)

  /* 4. Set up the Cairo context to draw the transformed points */
  cairo.set_source_rgb(cr, 0.2, 0.6, 0.8) // Blue
  cairo.set_line_width(cr, 3.0)

  /* Center the drawing space */
  cairo.translate(cr, f64(width) / 2.0, f64(height) / 2.0)

  /* Draw the triangle */
  cairo.move_to(cr, f64(p1.x), f64(p1.y))
  cairo.line_to(cr, f64(p2.x), f64(p2.y))
  cairo.line_to(cr, f64(p3.x), f64(p3.y))
  cairo.close_path(cr)

  cairo.stroke(cr)
}


AppActivateCB :: proc "c" (app :^gtk.Application, user_data :glib.pointer) {
  window := gtk.application_window_new(app)
  gtk.window_set_title(cast(^gtk.Window)window, "GTK 4 Graphene Example")
  gtk.window_set_default_size(cast(^gtk.Window)window, 400, 400)

  drawing_area := gtk.drawing_area_new()
  gtk.drawing_area_set_draw_func(cast(^gtk.DrawingArea)drawing_area,
                                 draw_func, nil, nil)

  gtk.window_set_child (cast(^gtk.Window)window, drawing_area)
  gtk.window_present(cast(^gtk.Window)window)
}

//
// MAIN
//
main :: proc () {
  cbArg :cstring = "CB Arg"
  app := gtk.application_new("org.gtk.graphene1.example",
                             gio.ApplicationFlags.APPLICATION_DEFAULT_FLAGS)
  gobj.signal_connect(app, "activate",
                      cast(gobj.Callback)AppActivateCB,
                      cast(glib.pointer)cbArg)

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
