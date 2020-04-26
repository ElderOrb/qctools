#ifndef LOGGING_H
#define LOGGING_H

// 4/22/2019 AI: this is require include to install custom QtMessageHandler
// (redirect log messages to our logging if LOGGING=1 or just silence Qt logging otherwise)
#include <QtGlobal>

#if defined(LOGGING) || defined(SQTDEBUG)
    #include <QDebug>
    #include <QLoggingCategory>
    #include <QElapsedTimer>
#endif

class Logging
{
public:
    Logging();
    ~Logging();

private:
    QtMessageHandler prevMessageHandler;
};

#if defined(LOGGING) || defined(SQTDEBUG)
    #define SQTDebug_(...) { \
            { auto _ = qDebug(); __VA_ARGS__; } \
    }
    #define SQTInfo_(...) { \
            { auto _ = qInfo(); __VA_ARGS__; } \
    }
    #define SQTCritical_(...) { \
            { auto _ = qCritical(); __VA_ARGS__; } \
    }
    #define SQTDebug(...) { \
            { qDebug() << __VA_ARGS__; } \
    }
    #define SQTInfo(...) { \
            { qInfo() << __VA_ARGS__; } \
    }
    #define SQTCritical(...) { \
            { qCritical() << __VA_ARGS__; } \
    }
    #define SQCDebug(cat, ...) { \
            { qCDebug(cat) << __VA_ARGS__; } \
    }
    #define SQCWarning(cat, ...) { \
            { qCWarning(cat) << __VA_ARGS__; } \
    }
    #define SQCCritical(cat, ...) { \
            { qCCritical(cat) << __VA_ARGS__; } \
    }
    #define SQTimeCounter(code, label) { \
            { qInfo() << "executing operation: " << label; QElapsedTimer timer; timer.start(); \
              code; \
              qInfo() << label << " took " << timer.elapsed() << " ms"; } \
    }
#else // !LOGGING
    #define SQTDebug_(...) {}
    #define SQTInfo_(...) {}
    #define SQTCritical_(...) {}
    #define SQTDebug(...) {}
    #define SQTInfo(...) {}
    #define SQTCritical(...) {}
    #define SQCDebug(cat, ...) {}
    #define SQCWarning(cat, ...) {}
    #define SQCCritical(cat, ...) {}
    #define SQTimeCounter(code, label) { \
        code; \
    }
#endif // !LOGGING

#endif // LOGGING_H
