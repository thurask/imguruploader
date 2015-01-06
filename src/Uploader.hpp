/*
 * Uploader.hpp
 *
 *  Created on: Jan 5, 2015
 *      Author: Thurask
 */

#ifndef UPLOADER_HPP_
#define UPLOADER_HPP_

#include <QtCore>
#include <QtXml>
#include <QtNetwork>

class Uploader : public QObject
{
    Q_OBJECT
public:
    enum ImageLinks {
        OriginalImage,
        SmallSquare,
        LargeThumbnail,
        ImgurPage,
        DeletePage
    };

public:
    virtual ~Uploader();

    Uploader(QObject *parent = 0);

    Q_INVOKABLE
    void uploadFile(const QString & fileName);

    Q_INVOKABLE
    int fileSize(QString fileName);

    Q_SIGNALS:
    void uploadDone(const QVariantMap&);
    void uploadError(const QString &);
    void uploadProgress(qint64, qint64);

    private Q_SLOTS:
    void requestFinished(QNetworkReply * reply);

    private:
    QNetworkAccessManager * m_manager;
    QString m_apiKey;
};

#endif /* UPLOADER_HPP_ */
