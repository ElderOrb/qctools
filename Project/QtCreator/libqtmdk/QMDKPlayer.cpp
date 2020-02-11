/*
 * Copyright (c) 2018-2019 WangBin <wbsecg1 at gmail.com>
 * MDK SDK with QOpenGLWindow example
 */
#include "QMDKPlayer.h"
#include <QCoreApplication>
#include <QStringList>
#include <QString>
#include <QtDebug>
#include <QRegion>
#include <QTimer>
#include "mdk/Player.h"

Q_DECLARE_METATYPE(QMDKPlayer::State);

using namespace MDK_NS;
QMDKPlayer::QMDKPlayer(QObject *parent)
    : QObject(parent)
    , player_(new Player())
{
    setLogHandler([](LogLevel level, const char* msg){
        if (level >= std::underlying_type<LogLevel>::type(LogLevel::Info)) {
            qDebug() << msg;
        } else if (level >= std::underlying_type<LogLevel>::type(LogLevel::Warning)) {
            qWarning() << msg;
        }
    });

    player_->setRenderCallback([](void* vo_opaque){
        auto vo = reinterpret_cast<QObject*>(vo_opaque);
        if (!vo->isWidgetType()) { // isWidgetType() is fastest, and no need to include <QWidget>
            if (vo->isWindowType())
                QCoreApplication::instance()->postEvent(vo, new QEvent(QEvent::UpdateRequest));
            return;
        }
        class QUpdateLaterEvent final : public QEvent {   
        public:
            explicit QUpdateLaterEvent(const QRegion& paintRegion)
                : QEvent(UpdateLater), m_region(paintRegion)
            {} 
            ~QUpdateLaterEvent() {}
            inline const QRegion &region() const { return m_region; }
        protected:
            QRegion m_region;
        };
        QCoreApplication::instance()->postEvent(vo, new QUpdateLaterEvent(QRegion(0, 0, vo->property("width").toInt(), vo->property("height").toInt())));
    });

    m_positionTracker.setInterval(20);

    player_->onStateChanged([this](::State s){
        Q_EMIT stateChanged((State) s);
    });

    qDebug() << "subscribing for state changed...";
    connect(this, &QMDKPlayer::stateChanged, this, [&](State state) {
        qDebug() << "state changed: " << state;

        if(state == State::Playing) {
            m_position = position();

            qDebug() << "starting position tracker...";
            m_positionTracker.start();
        } else {

            qDebug() << "stopping position tracker...";
            m_positionTracker.stop();
        }
    }, Qt::QueuedConnection);

    connect(&m_positionTracker, &QTimer::timeout, [&]() {
        if(m_position != position()) {
            Q_EMIT positionChanged(position());
            m_position = position();
        }
    });
}

QMDKPlayer::~QMDKPlayer() {
    setLogHandler({});
};

void QMDKPlayer::setDecoders(const QStringList &dec)
{
    std::vector<std::string> v;
    for(QString d : dec) {
        v.push_back(d.toStdString());
    }
    player_->setVideoDecoders(v);
}

void QMDKPlayer::setMedia(const QString &url)
{
    player_->setMedia(url.toUtf8().constData());
}

QString QMDKPlayer::media() const
{
    return QString(player_->url());
}

void QMDKPlayer::prepare(qint64 ms)
{
    QEventLoop loop;
    QTimer::singleShot(0, [this, &loop, ms]() {
        player_->prepare(ms, [this, &loop, ms](int64_t t, bool* b) {
            qDebug() << "preparing: ms = " << ms << ", t = " << t << ", b = " << b;
            loop.quit();
            return true;
        }, SeekFlag::FromStart);
    });
    loop.exec(QEventLoop::ExcludeUserInputEvents);
}

void QMDKPlayer::play()
{
    if(player_->state() != ::State::Playing) {
        player_->setState(::State::Playing);
        player_->waitFor(::State::Playing);
    }
}

void QMDKPlayer::pause()
{
    if(player_->state() != ::State::Paused) {
        player_->setState(::State::Paused);
        player_->waitFor(::State::Paused);
    }
}

void QMDKPlayer::stop()
{
    if(player_->state() != ::State::Stopped) {
        player_->setState(::State::Stopped);
        player_->waitFor(::State::Stopped);
    }
}

bool QMDKPlayer::isPaused() const
{
    return player_->state() == ::State::Paused;
}

void QMDKPlayer::seek(qint64 ms, bool waitForCompletion)
{
    waitForCompletion = true;

    if(waitForCompletion) {
        qDebug() << "entering seeking: " << ms;

        QEventLoop loop;
        QTimer::singleShot(0, [this, &loop, ms]() {
            if(!player_->seek(ms, SeekFlag::FromStart, [&loop, ms](int64_t seekPos) {
                qDebug() << "seeking " << ms << " done: " << seekPos;
                loop.quit();
            })) {
                qDebug() << "seek failed";
            };
        });
        loop.exec(QEventLoop::ExcludeUserInputEvents);

        qDebug() << "exiting seeking";
    } else {
        qDebug() << "entering seeking without waiting: " << ms;

        if(!player_->seek(ms, SeekFlag::FromStart)) {
            qDebug() << "seek failed";
        } else {
            qDebug() << "seeking " << ms << " done without waiting..";
        }

        qDebug() << "exiting without waiting";
    }
}

qint64 QMDKPlayer::position() const
{
    return player_->position();
}

qint64 QMDKPlayer::duration() const
{
    return player_->mediaInfo().duration;
}

QSize QMDKPlayer::videoFrameSize() const
{
    auto mediaStatus = player_->mediaStatus();
    auto mediaInfo = player_->mediaInfo();

    return (mediaStatus & MediaStatus::Loaded) ? QSize(mediaInfo.video[0].codec.width, mediaInfo.video[0].codec.height) : QSize(0, 0);
}

void QMDKPlayer::addRenderer(QObject* vo, int w, int h)
{
    if (w <= 0)
        w = vo->property("width").toInt();
    if (h <= 0)
        h = vo->property("height").toInt();
    player_->setVideoSurfaceSize(w, h, vo); // call update cb
    connect(vo, &QObject::destroyed, this, [this](QObject* obj){
        player_->setVideoSurfaceSize(-1, -1, obj); // remove vo
    }, Qt::DirectConnection);
}

void QMDKPlayer::renderVideo(QObject* vo)
{
    player_->renderVideo(vo);
}

void QMDKPlayer::setProperty(const std::string &key, const std::string &value)
{
    player_->setProperty(key, value);
}
