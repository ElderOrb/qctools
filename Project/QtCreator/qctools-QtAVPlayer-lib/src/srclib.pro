TEMPLATE = subdirs

include($$OUT_PWD/QtAVPlayer/qtQtAVPlayer-config.pri)
QT_FOR_CONFIG += aplayer-private

sub_src.file = QtAVPlayer/QtAVPlayerLib.pro
SUBDIRS += sub_src
