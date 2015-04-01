/**
 * PhotosToMovie - main file.
 * 
 * This is a quick command-line program written by Brett Hutley <brett@hutley.net> 
 * to create a Quicktime movie from a bunch of JPG photos. I used to use the 
 * "convert" program from ImageMagick to do this, but it now appears to be 
 * broken on the Mac as far as creating movies from images goes.
 */
#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import <QuartzCore/CoreImage.h>
#import <dirent.h>

static const char *appname;

void
usage()
{
    printf("USAGE: %s [-o movie.mp4] [-p <pause>] <dirname>\n", appname);
    printf("\n");
    printf("  This program takes all the JPG files in the directory\n");
    printf("  and writes a Quicktime movie. Each image in the movie\n");
    printf("  is presented for <pause> tenths of a second (defaulting\n");
    printf("  to 10, or a one second pause between photos).\n");
    printf("\n");
    printf("Optional Arguments:\n");
    printf("  -o <movie.mp4>   : the name of the movie file to create\n");
    printf("  -p <pause>       : the pause in tenths of a second.\n");
    printf("                   :  (defaults to 10)\n");
    printf("\n");
}

int
main(int argc, char **argv)
{
    appname = argv[0];
    
    const char *moviefile = "movie.mp4";
    char c;
    int tenthSeconds = 10;
    while ((c = getopt(argc, argv, "o:p:")) != -1) {
        switch (c) {
            case 'o':
                moviefile = optarg;
                break;

            case 'p':
                tenthSeconds = atoi(optarg);
                break;
                
            case '?':
            default:
                if (optopt == 't')
                    fprintf (stderr, "Option -%c requires the title as an argument.\n", optopt);
                else
                    fprintf (stderr, "Unknown option `-%c'.\n", optopt);
                usage();
                return 1;
        }
    }

    if (argc - optind < 1) {
        usage();
        exit(1);
    }
    
    const char *dirname = argv[optind];
    
    QTMovie *movie = [[QTMovie alloc] initToWritableFile:[NSString stringWithUTF8String:moviefile] error:NULL];

    NSMutableArray *fileList = [NSMutableArray arrayWithCapacity:50];
    DIR *dirp = opendir(dirname);
    if (dirp == NULL) {
        printf("ERROR: Couldn't open directory %s\n", dirname);
        return 2;
    }

    struct dirent *dp;
    while ((dp = readdir(dirp)) != NULL) {
        if (dp->d_namlen > 4) {
            if (!strcasecmp(dp->d_name+dp->d_namlen-4, ".jpg")) {
                char filebuf[4096];
                snprintf(filebuf, 4096, "file://%s", dirname);
                if (filebuf[strlen(filebuf)-1] != '/') {
                    strcat(filebuf, "/");
                }
                strcat(filebuf, dp->d_name);
                [fileList addObject:[NSString stringWithUTF8String:filebuf]];
            }
        }
        
    }
    
    closedir(dirp);

    for (NSString *imagePath in fileList) {
        NSURL *url = [NSURL URLWithString:imagePath];
        CIImage *ciimage = [CIImage imageWithContentsOfURL:url];
        if (ciimage == nil) {
            printf("ERROR: loading image file %s\n", [imagePath UTF8String]);
            continue;
        }
        
        NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:ciimage];
        NSImage *image = [[NSImage alloc] initWithSize:[imageRep size]];
        [image addRepresentation:imageRep];
        [movie addImage:image forDuration:QTMakeTime(tenthSeconds, 10) withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:@"jpeg", QTAddImageCodecType, nil]];
        [movie setCurrentTime:[movie duration]];
        [movie updateMovieFile];
    }

    return 0;
}
