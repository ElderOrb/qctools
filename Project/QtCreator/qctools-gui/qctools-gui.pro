QT       += core gui network

QMAKEFEATURES = C:/Users/ai/Projects/qctools/qctools/Source/ThirdParty/QtAV/mkspecs/features
message("!!! QMAKEFEATURES = " $$QMAKEFEATURES)

#QT += avwidgets

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets printsupport qml

TARGET = QCTools
TEMPLATE = app

CONFIG += c++11 qt no_keywords

include(../brew.pri)
message("PWD = " $$PWD)

include(../libqtmdk/libqtmdk.pri)

# link against libqctools
win32:CONFIG(release, debug|release): LIBS += -L$$OUT_PWD/../qctools-lib/release/ -lqctools
else:win32:CONFIG(debug, debug|release): LIBS += -L$$OUT_PWD/../qctools-lib/debug/ -lqctools
else:unix: LIBS += -L$$OUT_PWD/../qctools-lib/ -lqctools

INCLUDEPATH += $$PWD/../qctools-lib $$PWD/../libqtmdk
DEPENDPATH += $$PWD/../qctools-lib $$PWD/../libqtmdk

if(equals(MAKEFILE_GENERATOR, MSVC.NET)|equals(MAKEFILE_GENERATOR, MSBUILD)) {
  TRY_COPY = $$QMAKE_COPY
} else {
  TRY_COPY = -$$QMAKE_COPY #makefile. or -\$\(COPY_FILE\)
}

message('TRY_COPY: ' $$TRY_COPY)

mac: {
    mdklibs.pattern = $$absolute_path($$PWD/../mdk-sdk/lib/*.framework)
    message('mdklibs.pattern: ' $$mdklibs.pattern)

    mdklibs.files = $$files($$mdklibs.pattern)
    message('mdklibs.files: ' $$mdklibs.files)

    mdklibs.path = $$absolute_path($$OUT_PWD$${BUILD_DIR}/$${TARGET}.app/Contents/Frameworks)
    message('mdklibs.path: ' $$mdklibs.path)

    mdklibs.commands += $$escape_expand(\\n\\t)$$sprintf($$QMAKE_MKDIR_CMD, $$shell_path($$mdklibs.path))

    for(f, mdklibs.files) {
      message('***: ' $$escape_expand(\\n\\t)$$QMAKE_COPY_DIR $$shell_path($$f) $$shell_path($$mdklibs.path))
      mdklibs.commands += $$escape_expand(\\n\\t)$$QMAKE_COPY_DIR $$shell_path($$f) $$shell_path($$mdklibs.path)
    }

    isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK = $$mdklibs.commands
    else: QMAKE_POST_LINK = $${QMAKE_POST_LINK}$$escape_expand(\\n\\t)$$mdklibs.commands

    message('QMAKE_POST_LINK: ' $${QMAKE_POST_LINK})

} else {

    LIBRARY_SUBFOLDER=
    win32: {
        CONFIG(debug, debug|release) {
            BUILD_SUFFIX=d
            BUILD_DIR=/debug
        } else:CONFIG(release, debug|release) {
            BUILD_SUFFIX=
            BUILD_DIR=/release
        }
        MDKLIBNAME = mdk
	LIBRARY_SUBFOLDER = /x64
    } else {
        MDKLIBNAME = mdk
    }
    message('MDKLIBNAME: ' $${MDKLIBNAME})

    MDKLIBS += -L$$absolute_path($$PWD/../mdk-sdk/bin$${LIBRARY_SUBFOLDER}) -l$${MDKLIBNAME}
    mdklibs.pattern = $$absolute_path($$PWD/../mdk-sdk/bin$${LIBRARY_SUBFOLDER}/*.$$QMAKE_EXTENSION_SHLIB)
    message('mdklibs.pattern: ' $$mdklibs.pattern)

    mdklibs.files = $$files($$mdklibs.pattern)
    message('mdklibs.files: ' $$mdklibs.files)

    mdklibs.path = $$absolute_path($$OUT_PWD$${BUILD_DIR})
    for(f, mdklibs.files) {
      message('***: ' $$escape_expand(\\n\\t)$$TRY_COPY $$shell_path($$f) $$shell_path($$mdklibs.path))
      mdklibs.commands += $$escape_expand(\\n\\t)$$TRY_COPY $$shell_path($$f) $$shell_path($$mdklibs.path)
    }

    isEmpty(QMAKE_POST_LINK): QMAKE_POST_LINK = $$mdklibs.commands
    else: QMAKE_POST_LINK = $${QMAKE_POST_LINK}$$escape_expand(\\n\\t)$$mdklibs.commands

    message('QMAKE_POST_LINK: ' $${QMAKE_POST_LINK})
}

win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../qctools-lib/release/libqctools.a
else:win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../qctools-lib/debug/libqctools.a
else:win32:!win32-g++:CONFIG(release, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../qctools-lib/release/qctools.lib
else:win32:!win32-g++:CONFIG(debug, debug|release): PRE_TARGETDEPS += $$OUT_PWD/../qctools-lib/debug/qctools.lib
else:unix: PRE_TARGETDEPS += $$OUT_PWD/../qctools-lib/libqctools.a

SOURCES_PATH = $$absolute_path($$PWD/../../../Source)
message("qctools: SOURCES_PATH = " $$SOURCES_PATH)

THIRD_PARTY_PATH = $$absolute_path($$SOURCES_PATH/../..)
message("qctools: THIRD_PARTY_PATH = " $$THIRD_PARTY_PATH)

INCLUDEPATH += $$SOURCES_PATH/GUI

HEADERS += \
    $$SOURCES_PATH/GUI/FilesList.h \
    $$SOURCES_PATH/GUI/Help.h \
    $$SOURCES_PATH/GUI/Info.h \
    $$SOURCES_PATH/GUI/mainwindow.h \
    $$SOURCES_PATH/GUI/preferences.h \
    $$SOURCES_PATH/GUI/Comments.h \
    $$SOURCES_PATH/GUI/CommentsEditor.h \
    $$SOURCES_PATH/GUI/Plot.h \
    $$SOURCES_PATH/GUI/Plots.h \
    $$SOURCES_PATH/GUI/PlotLegend.h \
    $$SOURCES_PATH/GUI/PlotScaleWidget.h \
    $$SOURCES_PATH/GUI/TinyDisplay.h \
    $$SOURCES_PATH/GUI/SelectionArea.h \
    $$SOURCES_PATH/GUI/config.h \
    $$SOURCES_PATH/GUI/draggablechildrenbehaviour.h \
    $$SOURCES_PATH/ThirdParty/cqmarkdown/CMarkdown.h \
    $$SOURCES_PATH/GUI/barchartconditioneditor.h \
    $$SOURCES_PATH/GUI/barchartconditioninput.h \
    $$SOURCES_PATH/GUI/managebarchartconditions.h \
    $$SOURCES_PATH/GUI/barchartprofilesmodel.h \
    $$SOURCES_PATH/GUI/player.h \
    $$SOURCES_PATH/GUI/doublespinboxwithslider.h \
    $$SOURCES_PATH/GUI/filters.h \
    $$SOURCES_PATH/GUI/filterselector.h \
    $$SOURCES_PATH/GUI/playercontrol.h

SOURCES += \
    $$SOURCES_PATH/GUI/FilesList.cpp \
    $$SOURCES_PATH/GUI/Help.cpp \
    $$SOURCES_PATH/GUI/Info.cpp \
    $$SOURCES_PATH/GUI/main.cpp \
    $$SOURCES_PATH/GUI/mainwindow.cpp \
    $$SOURCES_PATH/GUI/mainwindow_Callbacks.cpp \
    $$SOURCES_PATH/GUI/mainwindow_More.cpp \
    $$SOURCES_PATH/GUI/mainwindow_Ui.cpp \
    $$SOURCES_PATH/GUI/Comments.cpp \
    $$SOURCES_PATH/GUI/CommentsEditor.cpp \
    $$SOURCES_PATH/GUI/Plot.cpp \
    $$SOURCES_PATH/GUI/Plots.cpp \
    $$SOURCES_PATH/GUI/PlotLegend.cpp \
    $$SOURCES_PATH/GUI/PlotScaleWidget.cpp \
    $$SOURCES_PATH/GUI/preferences.cpp \
    $$SOURCES_PATH/GUI/TinyDisplay.cpp \
    $$SOURCES_PATH/GUI/SelectionArea.cpp \
    $$SOURCES_PATH/GUI/config.cpp \
    $$SOURCES_PATH/GUI/draggablechildrenbehaviour.cpp \
    $$SOURCES_PATH/ThirdParty/cqmarkdown/CMarkdown.cpp \
    $$SOURCES_PATH/GUI/barchartconditioneditor.cpp \
    $$SOURCES_PATH/GUI/barchartconditioninput.cpp \
    $$SOURCES_PATH/GUI/managebarchartconditions.cpp \
    $$SOURCES_PATH/GUI/barchartprofilesmodel.cpp \
    $$SOURCES_PATH/GUI/player.cpp \
    $$SOURCES_PATH/GUI/doublespinboxwithslider.cpp \
    $$SOURCES_PATH/GUI/filters.cpp \
    $$SOURCES_PATH/GUI/filterselector.cpp \
    $$SOURCES_PATH/GUI/playercontrol.cpp

include(../zlib.pri)

FORMS += \
    $$SOURCES_PATH/GUI/mainwindow.ui \
    $$SOURCES_PATH/GUI/preferences.ui \
    $$SOURCES_PATH/GUI/CommentsEditor.ui \
    $$SOURCES_PATH/GUI/player.ui \
    $$SOURCES_PATH/GUI/barchartconditioneditor.ui \
    $$SOURCES_PATH/GUI/barchartconditioninput.ui \
    $$SOURCES_PATH/GUI/managebarchartconditions.ui \
    $$SOURCES_PATH/GUI/playercontrol.ui

RESOURCES += \
    $$SOURCES_PATH/Resource/Resources.qrc

help_images_dir="$$SOURCES_PATH/../docs/media"
help_images.files = $$files($$help_images_dir/*, true)
help_images.prefix = "/Help"
help_images.alias = "./"

DRESOURCES += help_images

# http://www.w3.org/TR/xml/#syntax
defineReplace(xml_escape) {
    1 ~= s,&,&amp;,
    1 ~= s,\',&apos;,
    1 ~= s,\",&quot;,
    1 ~= s,<,&lt;,
    1 ~= s,>,&gt;,
    return($$1)
}

for(resource, DRESOURCES) {

    # Regular case of user qrc file
    contains(resource, ".*\.qrc$"): \
        next()

    # Fallback for stand-alone files/directories
    !defined($${resource}.files, var) {
        !equals(resource, qmake_immediate) {
            !exists($$absolute_path($$resource, $$_PRO_FILE_PWD_)): \
                warning("Failure to find: $$resource")
            qmake_immediate.files += $$resource
        }
        RESOURCES -= $$resource
        next()
    }

    resource_alias = $$eval($${resource}.alias)
    resource_file = $$RCC_DIR/qmake_$${resource}.qrc

    !debug_and_release|build_pass {
        # Collection of files, generate qrc file
        prefix = $$eval($${resource}.prefix)
        isEmpty(prefix): \
            prefix = "/"

        resource_file_content = \
            "<!DOCTYPE RCC><RCC version=\"1.0\">" \
            "<qresource prefix=\"$$xml_escape($$prefix)\">"

        abs_base = $$absolute_path($$eval($${resource}.base), $$_PRO_FILE_PWD_)

        for(file, $${resource}.files) {
            abs_path = $$absolute_path($$file, $$_PRO_FILE_PWD_)

            isEqual(resource_alias, "") {
                alias = $$relative_path($$abs_path, $$abs_base)
            } else {
                alias = $$resource_alias$$basename(file)
            }

            #message("alias: " $$alias)

            resource_file_content += \
                "<file alias=\"$$xml_escape($$alias)\">$$xml_escape($$abs_path)</file>"
        }

        resource_file_content += \
            "</qresource>" \
            "</RCC>"

        !write_file($$OUT_PWD/$$resource_file, resource_file_content): \
            error("Aborting.")
    }

    RESOURCES -= $$resource
    RESOURCES += $$OUT_PWD/$$resource_file
}

macx:contains(DEFINES, USE_BREW) {
    message("use qwt from brew")
} else {
    QWT_ROOT = $$absolute_path($$THIRD_PARTY_PATH/qwt)
    message("use external qwt: QWT_ROOT = " $$QWT_ROOT)

    include( $${QWT_ROOT}/qwtconfig.pri )
    !win32 {
        include( $${QWT_ROOT}/qwtbuild.pri )
    }
    include( $${QWT_ROOT}/qwtfunctions.pri )

    macx {
        macx:LIBS       += -F$${QWT_ROOT}/lib -framework qwt
    }

    win32-msvc* {
        DEFINES += QWT_DLL
    }

    !macx: {
        win32:CONFIG(release, debug|release): LIBS += -L$${QWT_ROOT}/lib -lqwt
        else:win32:CONFIG(debug, debug|release): LIBS += -L$${QWT_ROOT}/lib -lqwtd
        else: LIBS += -L$${QWT_ROOT}/lib -lqwt
    }

    INCLUDEPATH += $$QWT_ROOT/src
}

INCLUDEPATH += $$SOURCES_PATH
INCLUDEPATH += $$SOURCES_PATH/ThirdParty/cqmarkdown
include(../ffmpeg.pri)

# this is required for building against manually compiled ffmpeg
!win32 {
    LIBS += -lbz2
}

win32-g++* {
    LIBS += -lbcrypt -lwsock32 -lws2_32
}

macx:ICON = $$SOURCES_PATH/Resource/Logo.icns
macx:LIBS += -liconv \
             -framework CoreFoundation \
             -framework Foundation \
             -framework AppKit \
             -framework AudioToolBox \
             -framework QuartzCore \
             -framework CoreGraphics \
             -framework CoreAudio \
             -framework CoreVideo \
             -framework VideoDecodeAcceleration
