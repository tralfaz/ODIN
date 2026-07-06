package main

import "core:fmt"

import glib "../gtk4m/glib"


//
// MAIN
//
main :: proc() {
  timer1 := glib.timer_new()
  fmt.printf("timer1: %v [%T]\n", timer1, timer1)  

  glib.timer_destroy(timer1)


  timer2 := glib.timer_new()
  fmt.printf("timer2: %v [%T]\n", timer1, timer1)  

  glib.timer_start(timer2)

  array := make([]f64, 100000)
  defer delete(array)
  
  fval :f64 = 1.1
  for &afe in array {
    afe = fval * fval
    fval += 1.1
  }

  usecs :u64 = 0
  elapsed := glib.timer_elapsed(timer2, &usecs)
  fmt.printf("elapsed: %v\n", elapsed)
  fmt.printf("usecs: %v\n", usecs)

  glib.timer_destroy(timer2)

/*
void    g_timer_stop    (GTimer  *timer);

void    g_timer_reset   (GTimer  *timer);
*/
}