TEMPLATE = subdirs
CONFIG -= ordered

message('QMAKE_COPY: ' $$QMAKE_COPY)
message('QMAKE_COPY_FILE: ' $$QMAKE_COPY_FILE)
message('QMAKE_MKDIR_CMD: ' $$QMAKE_MKDIR_CMD)

FFMPEG = $$(FFMPEG)
isEmpty(FFMPEG) {
    FFMPEG=$$absolute_path(../../../ffmpeg)
}
message('FFMPEG: ' $$FFMPEG)

exists($$FFMPEG/include) {
    FFMPEG_INCLUDE=$$absolute_path($$FFMPEG/include)
} else {
    FFMPEG_INCLUDE=$$FFMPEG
}

exists($$FFMPEG/lib) {
    FFMPEG_AVDEVICE=$$absolute_path($$FFMPEG/lib)
    FFMPEG_AVCODEC=$$absolute_path($$FFMPEG/lib)
    FFMPEG_AVFILTER=$$absolute_path($$FFMPEG/lib)
    FFMPEG_AVFORMAT=$$absolute_path($$FFMPEG/lib)
    FFMPEG_POSTPROC=$$absolute_path($$FFMPEG/lib)
    FFMPEG_SWRESAMPLE=$$absolute_path($$FFMPEG/lib)
    FFMPEG_SWSCALE=$$absolute_path($$FFMPEG/lib)
    FFMPEG_AVUTIL=$$absolute_path($$FFMPEG/lib)

    win32: {
        FFMPEG_LIBS += \
                     -L$$absolute_path($$FFMPEG/lib)
    } else {
        FFMPEG_LIBS += \
                     -L$$absolute_path($$FFMPEG/lib) -lavdevice -lavcodec -lavfilter -lavformat -lpostproc -lswresample -lswscale -lavutil
    }

} else {
    FFMPEG_AVDEVICE=$$absolute_path($$FFMPEG/libavdevice)
    FFMPEG_AVCODEC=$$absolute_path($$FFMPEG/libavcodec)
    FFMPEG_AVFILTER=$$absolute_path($$FFMPEG/libavfilter)
    FFMPEG_AVFORMAT=$$absolute_path($$FFMPEG/libavformat)
    FFMPEG_POSTPROC=$$absolute_path($$FFMPEG/libpostproc)
    FFMPEG_SWRESAMPLE=$$absolute_path($$FFMPEG/libswresample)
    FFMPEG_SWSCALE=$$absolute_path($$FFMPEG/libswscale)
    FFMPEG_AVUTIL=$$absolute_path($$FFMPEG/libavutil)

    win32: {
        FFMPEG_LIBS += \
                     -L$$FFMPEG_AVDEVICE \
                     -L$$FFMPEG_AVCODEC \
                     -L$$FFMPEG_AVFILTER \
                     -L$$FFMPEG_AVFORMAT \
                     -L$$FFMPEG_POSTPROC \
                     -L$$FFMPEG_SWRESAMPLE \
                     -L$$FFMPEG_SWSCALE \
                     -L$$FFMPEG_AVUTIL

    } else {
        FFMPEG_LIBS += \
                     -L$$FFMPEG_AVDEVICE -lavdevice \
                     -L$$FFMPEG_AVCODEC -lavcodec \
                     -L$$FFMPEG_AVFILTER -lavfilter \
                     -L$$FFMPEG_AVFORMAT -lavformat \
                     -L$$FFMPEG_POSTPROC -lpostproc \
                     -L$$FFMPEG_SWRESAMPLE -lswresample \
                     -L$$FFMPEG_SWSCALE -lswscale \
                     -L$$FFMPEG_AVUTIL -lavutil
    }
}

FFMPEG_INCLUDES += $$FFMPEG_INCLUDE

SUBDIRS = \
        qctools-lib \
        qctools-cli \
        qctools-gui

libqtmdk.subdir = libqtmdk
qctools-lib.subdir = qctools-lib
qctools-cli.subdir = qctools-cli
qctools-gui.subdir = qctools-gui

qctools-cli.depends = qctools-lib
qctools-gui.depends = qctools-lib
