/*
 * Copyright (c) 2018-2019 WangBin <wbsecg1 at gmail.com>
 * MDK SDK with QOpenGLWidget example
 */
#ifndef QMDKPlayer_H
#define QMDKPlayer_H

#include <QObject>
#include <QTimer>
#include <memory>

namespace mdk {
class Player;
}
#ifndef Q_MDK_API
#define Q_MDK_API Q_DECL_IMPORT
#endif
class Q_MDK_API QMDKPlayer : public QObject
{
    Q_OBJECT
public:
    enum State : int8_t {
        NotRunning,
        Stopped = NotRunning,
        Running,
        Playing = Running, /// start/resume to play
        Paused,
    };

    QMDKPlayer(QObject *parent = nullptr);
    ~QMDKPlayer();
    // decoders: "VideoToolbox", "VAAPI", "VDPAU", "D3D11", "DXVA", "NVDEC", "CUDA", "MMAL"/"AVMMAL"(raspberry pi), "CedarX"(sunxi), "AMediaCodec"("MediaCodec"), "FFmpeg"
    void setDecoders(const QStringList& dec);
    void setMedia(const QString& url);
    QString media() const;

    void prepare(qint64 ms = 0);

    void play();
    void pause();
    void stop();
    bool isPaused() const;
    void seek(qint64 ms, bool waitForCompletion);
    qint64 position() const;
    qint64 duration() const;

    QSize videoFrameSize() const;
    void addRenderer(QObject* vo = nullptr, int w = -1, int h = -1);
    void renderVideo(QObject* vo = nullptr);

    void setProperty(const std::string& key, const std::string& value);

Q_SIGNALS:
    void stateChanged(QMDKPlayer::State state);
    void positionChanged(qint64 ms);

private:
    std::unique_ptr<mdk::Player> player_;
    QTimer m_positionTracker;
    qint64 m_position;
};

#endif // QMDKPlayer_H
