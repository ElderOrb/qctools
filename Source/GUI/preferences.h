#ifndef PREFERENCES_DIALOG_H
#define PREFERENCES_DIALOG_H

#include "Core/Preferences.h"

#include <QDialog>
#include <QList>
#include <QSet>
#include <QMap>
#include <QUrl>
#include <tuple>

namespace Ui {
class Preferences;
}

class SignalServerConnectionChecker;
class PreferencesDialog : public QDialog
{
    Q_OBJECT

public:
    explicit PreferencesDialog(Preferences* preferences, SignalServerConnectionChecker* connectionChecker, QWidget *parent = 0);
    ~PreferencesDialog();

    //Preferences
    activefilters ActiveFilters;
    activealltracks ActiveAllTracks;
    QMap<QString, QString> ActivePanels;

    QList<std::tuple<size_t, size_t>> loadFilterSelectorsOrder();
    void saveFilterSelectorsOrder(const QList<std::tuple<size_t, size_t>>& order);

    bool isSignalServerEnabled() const;
    bool isSignalServerAutoUploadEnabled() const;

    QString signalServerUrlString() const;
    QString signalServerLogin() const;
    QString signalServerPassword() const;

Q_SIGNALS:
    void saved();

private:
    Ui::Preferences *ui;
    SignalServerConnectionChecker* connectionChecker;

    void Load();
    void Save();

    Preferences* preferences;

private Q_SLOTS:
    void on_testConnection_pushButton_clicked();
    void OnAccepted();
    void OnRejected();
    void on_signalServerUrl_lineEdit_editingFinished();
};

#endif // PREFERENCES_DIALOG_H
