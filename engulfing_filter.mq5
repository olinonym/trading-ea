//+------------------------------------------------------------------+
//|                                              engulfing_filter.mq5|
//|                                  Copyright 2026, Chitapann C.    |
//|                                  Modular Price Action Filter     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Chitapann C."
#property version   "1.00"
#property strict

//--- Input Parameters (กำหนดค่ากลางสำหรับ Public Repository)
input double InpMaxWickRatio = 0.50; // Max allowed wick-to-body ratio (Default: 50%)

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("[System] Engulfing Filter Module Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("[System] Engulfing Filter Module Stopped. Reason: ", reason);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Execute signal evaluation strictly on new bar open (Idempotent per bar)
   if(IsNewBar())
     {
      bool signal_buy  = CheckBullishEngulfing(_Symbol, _Period, InpMaxWickRatio);
      bool signal_sell = CheckBearishEngulfing(_Symbol, _Period, InpMaxWickRatio);
      
      if(signal_buy)
        {
         Print("[Signal] Bullish Engulfing detected on ", _Symbol);
         // Hook: Trigger Order Execution Module (Buy)
        }
        
      if(signal_sell)
        {
         Print("[Signal] Bearish Engulfing detected on ", _Symbol);
         // Hook: Trigger Order Execution Module (Sell)
        }
     }
  }

//+------------------------------------------------------------------+
//| Bar State Synchronization (Prevent duplicate tick execution)     |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime last_time = 0;
   datetime current_time = iTime(_Symbol, _Period, 0);
   
   if(current_time != last_time)
     {
      last_time = current_time;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Validate Bullish Engulfing Price Action Pattern                  |
//+------------------------------------------------------------------+
bool CheckBullishEngulfing(string symbol, ENUM_TIMEFRAMES timeframe, double max_wick_ratio = 0.50)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(symbol, timeframe, 1, 2, rates) < 2) return false;
   
   bool isPrevBearish = rates[1].close < rates[1].open;
   bool isCurrBullish = rates[0].close > rates[0].open;
   if(!isPrevBearish || !isCurrBullish) return false;
   
   double body_prev = MathAbs(rates[1].close - rates[1].open);
   double body_curr = MathAbs(rates[0].close - rates[0].open);
   if(body_curr == 0) return false;
   
   bool isEngulfing = (rates[0].close >= rates[1].open) && 
                      (rates[0].open <= rates[1].close) && 
                      (body_curr > body_prev);
   if(!isEngulfing) return false;
   
   // Validate candle momentum via wick-to-body ratio
   double total_size  = rates[0].high - rates[0].low;
   double total_wicks = total_size - body_curr;
   double wick_ratio  = total_wicks / body_curr;
   
   return (wick_ratio <= max_wick_ratio);
  }

//+------------------------------------------------------------------+
//| Validate Bearish Engulfing Price Action Pattern                  |
//+------------------------------------------------------------------+
bool CheckBearishEngulfing(string symbol, ENUM_TIMEFRAMES timeframe, double max_wick_ratio = 0.50)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(symbol, timeframe, 1, 2, rates) < 2) return false;
   
   bool isPrevBullish = rates[1].close > rates[1].open;
   bool isCurrBearish = rates[0].close < rates[0].open;
   if(!isPrevBullish || !isCurrBearish) return false;
   
   double body_prev = MathAbs(rates[1].close - rates[1].open);
   double body_curr = MathAbs(rates[0].close - rates[0].open);
   if(body_curr == 0) return false;
   
   bool isEngulfing = (rates[0].close <= rates[1].open) && 
                      (rates[0].open >= rates[1].close) && 
                      (body_curr > body_prev);
   if(!isEngulfing) return false;
   
   // Validate candle momentum via wick-to-body ratio
   double total_size  = rates[0].high - rates[0].low;
   double total_wicks = total_size - body_curr;
   double wick_ratio  = total_wicks / body_curr;
   
   return (wick_ratio <= max_wick_ratio);
  }
//+------------------------------------------------------------------+