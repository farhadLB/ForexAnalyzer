#include "CsvLoader.h"

CsvLoader::CsvLoader(QObject *parent) : QObject(parent)
{
    m_thread = new QThread(this);
    m_worker = new CsvWorker;
    m_worker->moveToThread(m_thread);

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

    connect(this, &CsvLoader::startWorker, m_worker, &CsvWorker::loadFile);

    connect(m_worker, &CsvWorker::candlesReady, this, [this](const QVariantList &list) {
        m_candles = list;
        emit candlesReady(list);
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
    if (m_isLoading) return;
    setProgress(0);
    setIsLoading(true);
    emit startWorker(filePath);
}

void CsvLoader::cancelLoad()
{
    if (m_worker) m_worker->requestCancel();
}

bool CsvLoader::candlesLoaded()
{
    return !m_candles.isEmpty();
}

void CsvLoader::closeFile()
{
    emit closeCsvFile();
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
