#include "logging.h"

#define LOGGING
#ifdef LOGGING
    #include <QDebug>
    #include <QDir>
    #include <QLoggingCategory>
    #include <QProcess>
    #include "spdlog/spdlog.h"
    #include "spdlog/sinks/rotating_file_sink.h"
    #ifdef Q_OS_WIN
        #include "spdlog/sinks/wincolor_sink.h"
    #endif // Q_OS_WIN
    #if defined(Q_OS_LINUX)
        #include "spdlog/sinks/syslog_sink.h"
    #endif // Q_OS_IOS
#endif // LOGGING

void customMessageHandler(QtMsgType type, const QMessageLogContext &context, const QString & msg)
{
#ifdef LOGGING
    auto utf8 = msg.toUtf8();
    auto message = utf8.constData();
    auto isNotDefaultCategory = context.category && strcmp(context.category, QLoggingCategory::defaultCategory()->categoryName()) != 0;

    switch (type)
    {
        case QtDebugMsg:
        {
            isNotDefaultCategory ? spdlog::debug("[{}] {}", context.category, message) : spdlog::debug("{}", message);
            break;
        }
        case QtInfoMsg:
        {
            isNotDefaultCategory ? spdlog::info("[{}] {}", context.category, message) : spdlog::info("{}", message);
            break;
        }
        case QtWarningMsg:
        {
            isNotDefaultCategory ? spdlog::warn("[{}] {}", context.category, message) : spdlog::warn("{}", message);
            break;
        }
        case QtFatalMsg:
        case QtCriticalMsg:
        {
            isNotDefaultCategory ? spdlog::error("[{}] {}", context.category, message) : spdlog::error("{}", message);
            break;
        }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wcovered-switch-default"
        default:
            isNotDefaultCategory ? spdlog::trace("[{}] {}", context.category, message) : spdlog::trace("{}", message);
#pragma GCC diagnostic pop
    }
#endif // LOGGING
}


Logging::Logging() : prevMessageHandler(nullptr)
{
#ifdef LOGGING
    std::vector<spdlog::sink_ptr> sinks;

    // console logging
    // use console sink on WARN level for desktop platforms
    {
        #ifdef Q_OS_WIN
            auto console_sink = std::make_shared<spdlog::sinks::wincolor_stdout_sink_mt>();
        #else //
            auto console_sink = std::make_shared<spdlog::sinks::ansicolor_stdout_sink_mt>();
        #endif //

        console_sink->set_level(spdlog::level::warn);
        console_sink->set_pattern("[%^%l%$] %v");

        sinks.push_back(console_sink);
    }

    // file logging
    // use file sink on debug level for all the platforms besides android
    {
        QDir dir = QDir::current();
        auto logsDir = dir.absolutePath() + "/logs";

        auto logFileName = "log.txt";
        auto maxLogFileSize = 1024*1024*10;
        auto maxLogs = 5;

        qDebug().noquote().nospace() << "Checking for log folder existence: " << dir.absolutePath() << "/" << logsDir;
        if(!dir.exists(logsDir)) {
            qDebug() << "Folder" << dir.absolutePath() << "/" << logsDir << "doesn't exist, creating... ";
            if(!dir.mkdir(logsDir)) {
                qWarning().noquote().nospace() << "Failed to create folder: " << dir.absolutePath() << "/" << logsDir;
            }
        }
        auto absolutePathToLogs = dir.absoluteFilePath(logsDir);
        auto logFiles = QDir(absolutePathToLogs).entryInfoList(QStringList() << logFileName << QString("%1.*").arg(logFileName));
        for (auto logFile : logFiles) {
            auto removed = QFile(logFile.absoluteFilePath()).remove();
            qDebug() << "existing log" << logFile << (removed ? "has been" : "has not been") << "removed";
        }

        auto file_sink = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(QString("%1/%2")
                                                                                .arg(absolutePathToLogs)
                                                                                .arg(logFileName).toUtf8().constData(), maxLogFileSize, maxLogs);
        file_sink->set_level(spdlog::level::debug);
        sinks.push_back(file_sink);
    }

    auto logger = std::make_shared<spdlog::logger>("", sinks.begin(), sinks.end());
    logger->set_level(spdlog::level::debug);

    spdlog::set_default_logger(logger);
    spdlog::flush_every(std::chrono::seconds(1));

    logger->set_pattern("[%Y:%m:%d %H:%M:%S %z] [%^%l%$] [thread %t] %v");
    logger->info("logging initialized");
#endif // !LOGGING

#if defined(LOGGING)
    prevMessageHandler = qInstallMessageHandler(customMessageHandler);
#endif //
}

Logging::~Logging()
{
    if(prevMessageHandler)
        qInstallMessageHandler(prevMessageHandler);
}
