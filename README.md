# PhotosToVideo

This is a quick command-line program for the Mac that turns a bunch of JPG files into a movie.

It was written by me, Brett Hutley <brett@hutley.net>, as a quick replacement for using the "convert" program from ImageMagick (which seems to be broken on the Mac for this purpose).

You can compile it using the provided Makefile. Just type "make" from the command-line (assuming you have xcode command-line tools installed).

To run it, type:

    ./PhotosToVideo.exe <directory>

All the JPG files in the directory specify will be made into a movie called "movie.mp4".

You can specify the arguments "-o newname.mp4" to name the movie something else. 

You can also specify the argument "-p pauseInTenthSecond" in order to specify the delay between the photos. By default there will be a 1 second delay between photos. 

For example, the following command-line creates a video called "MyVideo.mp4" from the JPG photos contained in the subdirectory "~/Photos", with a 3 second delay between photos.

    ./PhotosToVideo.exe -o MyVideo.mp4 -p 30 ~/Photos

