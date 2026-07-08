# ForexAnalyzer

A desktop forex charting and strategy-backtesting application built with **C++17** and **Qt 6 (Quick/QML)**. It streams live price data over WebSocket, loads historical data from CSV or a REST API, and runs a multi-stage technical-analysis pipeline (support/resistance detection, trend strength, entry/stop-loss/take-profit calculation) — all without blocking the UI.

This project was built as a hands-on exercise in applying real-world concurrency, networking, and software-architecture patterns in a C++/Qt codebase, rather than as a production trading tool.

## Highlights

- **Live market data over WebSocket** — a persistent `QWebSocket` connection streams real-time price ticks, which are aggregated client-side into OHLC candles as they arrive.
- **REST API integration** — historical candle snapshots are fetched asynchronously via `QNetworkAccessManager`, with in-flight requests tracked and cancelable.
- **Multithreaded pipeline** — CSV parsing and the strategy-calculation chain (entry → stop-loss → take-profit → position) each run on dedicated `QThread`s, communicating with the UI thread exclusively through queued Qt signals/slots.
- **Parallel data-crunching** — local price-level (support/resistance) detection uses `QtConcurrent::blockingMap` to scan candle windows across multiple cores.
- **Reactive, signal-driven architecture** — ~15 cooperating QObjects (workers, calculators, models) are wired together through Qt's signal/slot system, forming an event-driven pipeline with no manual polling.
- **QML front end** — the entire UI (candlestick chart, trend gauges, position tables, strategy configuration) is implemented in QML, backed by C++ models exposed via `QAbstractListModel`/context properties.
- **Unit tests** — Qt Test (`QTest`) based tests for core data-loading logic.

Each stage is a `QObject` connected to the next purely through **queued signal/slot connections**, so the calculation chain runs entirely off the GUI thread while results flow back to the UI models safely across the thread boundary — no manual mutex juggling required in application code, no frozen UI during heavy computation.

## Tech Stack

- **Language:** C++17
- **Framework:** Qt 6.8+ — Quick, QuickControls2, Charts, Concurrent, Network, WebSockets
- **UI:** QML
- **Build system:** CMake
- **Testing:** Qt Test / CTest
- **External API:** [Twelve Data](https://twelvedata.com/) (REST + WebSocket streaming quotes)

## Building

```bash
git clone https://github.com/farhadLB/ForexAnalyzer.git
cd ForexAnalyzer
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

Requires Qt 6.8+ with the Quick, QuickControls2, Charts, Concurrent, Network, and WebSockets modules installed.

## Usage

1. Launch the app.
2. Load historical data either from a local CSV file or by entering a [Twelve Data](https://twelvedata.com/) API key to fetch and stream live candles.
3. Choose a currency pair, timeframe, and strategy parameters (level lookback, entry threshold, stop-loss/take-profit lookback, reward-to-risk ratio).
4. Run the calculation to generate a table of historical entry/stop/target levels, visualized directly on the candlestick chart.

## Notes

This is a personal/portfolio project focused on demonstrating C++/Qt engineering practices — multithreading, asynchronous networking, WebSocket protocol handling, and a decoupled signal-driven architecture — rather than on providing validated trading advice. Nothing here constitutes financial guidance.
