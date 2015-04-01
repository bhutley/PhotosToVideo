PhotosToVideo.exe: main.m
	gcc -o $@ -Wall -Wno-deprecated -std=c99 $< -framework Foundation -framework QTKit -framework AppKit -framework QuartzCore -lobjc

ALL: PhotosToVideo.exe
