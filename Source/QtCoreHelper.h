#ifndef QTCOREHELPER_H
#define QTCOREHELPER_H

// Qt
#include <QObject>
#include <QUrl>

//****************************************************************************

class QtCoreHelper : public QObject
{
    Q_OBJECT
public:

   Q_INVOKABLE QString absoluteFilePath(const QString &path) const;
   Q_INVOKABLE QString absoluteFilePathFromUrl(const QUrl &url) const;

   Q_INVOKABLE bool clipboardCopy(const QString & data);

protected:


};

//****************************************************************************

#endif // QTCOREHELPER_H
