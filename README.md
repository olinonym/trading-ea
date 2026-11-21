# 📈 Modular Algorithmic Trading Engine (MQL5)

A modular suite of Expert Advisors (EAs) built with **MQL5** for MetaTrader 5, engineered to automate market structure analysis, trend classification, and Price Action signal detection on **XAUUSD (Gold)**. 

Rather than building a monolithic script, this project separates trading logic into decoupled, reusable filter modules to ensure maintainability, isolated backtesting, and strict risk control.

---

## 🏗️ System Architecture

The system evaluates market data sequentially on confirmed bar closes (`OnBar` state synchronization) to prevent duplicate tick execution before passing validated signals to the execution engine.

```mermaid
graph LR
    A[Market Tick Data] --> B{IsNewBar?}
    B -- No --> A
    B -- Yes --> C[Trend Filter Module]
    C -- UPTREND / DOWNTREND --> D[Engulfing Filter Module]
    C -- SIDEWAY --> E[Hold / Skip Execution]
    D -- Valid Signal --> F[S&R / Demand-Supply Zones]
    F --> G[Risk & Order Execution]
