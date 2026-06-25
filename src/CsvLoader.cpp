#include "CsvLoader.h"

CsvLoader::CsvLoader(QObject *parent) : QObject(parent)
{
    m_thread = new QThread(this);
    m_worker = new CsvWorker;          // no parent — lives on worker thread
    m_worker->moveToThread(m_thread);

    // worker → loader (cross-thread, queued automatically)
    connect(m_worker, &CsvWorker::progressChanged, this, [this](int p) {
        setProgress(p);
    });
    connect(m_worker, &CsvWorker::fileLoaded, this, [this](int count) {
        setIsLoading(false);
        emit fileLoaded(count);
    });
    connect(m_worker, &CsvWorker::candlesReady,  this, &CsvLoader::candlesReady);
    connect(m_worker, &CsvWorker::axisRangeReady, this, &CsvLoader::axisRangeReady);
    connect(m_worker, &CsvWorker::error, this, [this](const QString &msg) {
        setIsLoading(false);
        emit error(msg);
    });

    // loader → worker (triggers work on the worker thread)
    connect(this, &CsvLoader::startWorker, m_worker, &CsvWorker::loadFile);

    connect(m_worker, &CsvWorker::candlesReady, this, [this](const QVariantList &list) {
        m_candles = list;          // cache it
        emit candlesReady(list);   // forward to QML
    });

    m_thread->start();
}

CsvLoader::~CsvLoader()
{
    m_thread->quit();
    m_thread->wait();
    delete m_worker;
}

void CsvLoader::loadFile(const QString &filePath)
{
    if (m_isLoading) return;   // ignore if already running
    setProgress(0);
    setIsLoading(true);
    emit startWorker(filePath); // safe cross-thread signal
}

void CsvLoader::cancelLoad()
{
    if (m_worker) m_worker->requestCancel();
}

void CsvLoader::setIsLoading(bool v)
{
    if (m_isLoading == v) return;
    m_isLoading = v;
    emit isLoadingChanged();
}

void CsvLoader::setProgress(int v)
{
    if (m_progress == v) return;
    m_progress = v;
    emit progressChanged();
}
