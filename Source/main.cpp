
// Qt
#include <QGuiApplication>
#include <QQmlContext>
#include <QDir>
#include <QQuickView>
#include <QQmlEngine>
#include <QSortFilterProxyModel>

// Project
#include "QtCoreHelper.h"
#include "MetadataListModel.h"
#include "SortFilterProxyModel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<SortFilterProxyModel>("App.CSKMetadataViewer", 1, 0, "SortFilterProxyModel");

    QQuickView viewer;

    // The following are needed to make examples run without having to install the module
    // in desktop environments.
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif

    qDebug("Application path : %s", QGuiApplication::applicationDirPath().toStdString().c_str());

    QUrl attributesXmlUrl = QUrl::fromLocalFile(QFileInfo(QGuiApplication::applicationDirPath() + "/attributes.xml").absoluteFilePath());

    viewer.engine()->rootContext()->setContextProperty("attributesXmlUrl", attributesXmlUrl);

    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                                       QString::fromLatin1("qml")));

    viewer.setSource(QUrl("qrc:/main.qml"));

    viewer.setTitle(QStringLiteral("Cosmo-Skymed Metadata Viewer"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    viewer.setColor(Qt::black);

    // load some useful Qt classes
    QtCoreHelper helper;
    viewer.engine()->rootContext()->setContextProperty("QtCoreHelper", &helper);
    // load metadata list model
    MetadataListModel model;
    viewer.engine()->rootContext()->setContextProperty("metadataModel", &model);

    QSortFilterProxyModel proxyModel;
    viewer.engine()->rootContext()->setContextProperty("FilterProxyModel", &proxyModel);

    viewer.show();

    return app.exec();
}

