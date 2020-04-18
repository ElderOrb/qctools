INCLUDEPATH += $$absolute_path($$PWD/../mdk-sdk/include)
message("libqtmdk.pro: INCLUDEPATH: " $$INCLUDEPATH);

static|contains(CONFIG, staticlib) {
  DEFINES += Q_MDK_API
} else {
  DEFINES += Q_MDK_API=Q_DECL_EXPORT
}

macx {
  QMAKE_CXXFLAGS += -F$$PWD/../mdk-sdk/lib
  LIBS += -F$$PWD/../mdk-sdk/lib -framework mdk
}

linux {
  LIBS += -L$$PWD/../mdk-sdk/lib/amd64 -lmdk
}

win32 {
  LIBS += -L$$PWD/../mdk-sdk/lib/x64 -lmdk
}

SOURCES += $$PWD/QMDKRenderer.cpp \
        $$PWD/QMDKPlayer.cpp

HEADERS  += $$PWD/QMDKPlayer.h $$PWD/QMDKRenderer.h

mac {
  RPATHDIR *= @executable_path/Frameworks
  QMAKE_LFLAGS_SONAME = -Wl,-install_name,@rpath/
  isEmpty(QMAKE_LFLAGS_RPATH): QMAKE_LFLAGS_RPATH=-Wl,-rpath,
  for(R,RPATHDIR) {
    QMAKE_LFLAGS *= \'$${QMAKE_LFLAGS_RPATH}$$R\'
  }
}
