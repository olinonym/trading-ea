# 📈 Modular Algorithmic Trading Engine (MQL5)

A modular suite of Expert Advisors (EAs) built with **MQL5** for MetaTrader 5, engineered to automate market structure analysis, trend classification, and Price Action signal detection on **XAUUSD (Gold)**. 

Rather than building a monolithic script, this project separates trading logic into decoupled, reusable filter modules to ensure maintainability, isolated backtesting, and strict risk control.

---

## 🏗️ System Architecture

The system follows a strict **Top-Down Multi-Timeframe (MTF) pipeline**, filtering macro market structure and key liquidity zones on higher timeframes (`H4`/`H1`) before evaluating lower-timeframe (`M15`) Price Action triggers and calculating position risk.

```mermaid
graph LR
    A[New Bar Trigger] --> B[1. Higher TF Trend Filter<br/>H4 / H1]
    B -- Sideway --> Z[Skip / Wait]
    B -- Bullish / Bearish --> C[2. Key Zones Filter<br/>Demand/Supply & S&R]
    C -- Outside Zone --> Z
    C -- Price in Zone --> D[3. Lower TF Price Action<br/>Engulfing on M15]
    D -- No Pattern --> Z
    D -- Valid Signal --> E[4. Risk & Lot Sizing<br/>0.5% - 1.0% Risk]
    E --> F[5. Order Execution]
