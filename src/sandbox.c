#include <X11/Xlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **args) {
  // grab display handle
  Display *display = XOpenDisplay(NULL);
  if (display == NULL) {
    printf("failed to init display\n");
    return 0;
  }

  // validate handle
  if (XNoOp(display) == 0) {
    printf("intializing no-op failed\n");
    return 0;
  }

  int screen = XDefaultScreen(display);

  // pull basic info
  int width = XDisplayWidth(display, screen);
  int height = XDisplayHeight(display, screen);
  printf("width=%d, height=%d\n", width, height);

  int screens = XScreenCount(display);
  printf("screens=%d\n", screens);

  unsigned long white = XWhitePixel(display, screen);
  unsigned long black = XBlackPixel(display, screen);
  printf("white=%ld black=%ld\n", white, black);
  Window root = XRootWindow(display, screen);
  Window win = XCreateSimpleWindow(display, // display
                                   root,    // parent
                                   0,       // x
                                   0,       // y
                                   640,     // width
                                   480,     // height
                                   1,       // border_width
                                   white,   // border
                                   black);  // background

  if (XClearWindow(display, win) == 0) {
    printf("failed to clear window\n");
  }

  if (XMapRaised(display, win) == 0) {
    printf("failed to map window\n");
  }

  XFlush(display);
  system("sleep 3");
  // cleanup
  XUnmapWindow(display, win);
  XDestroyWindow(display, win);
  XCloseDisplay(display);
}
