//+------------------------------------------------------------------+
//|                                                 trend_filter.mq5 |
//|                                  Copyright 2026, Chitapann C.    |
//|                                  Modular Market Regime Filter    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Chitapann C."
#property version   "1.00"
#property strict

//--- Input Parameters (กำหนดค่ากลางสำหรับ Public Repository)
input int InpFastEMAPeriod = 20; // Fast EMA Period (Default: 20)
input int InpSlowEMAPeriod = 50; // Slow EMA Period (Default: 50)

//--- State Machine Enumeration
enum ENUM_TREND_STATE
  {
   UPTREND,
   DOWNTREND,
   SIDEWAY
  };

//--- Indicator Handles
int handle_fast_ema;
int handle_slow_ema;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize Indicator Handles
   handle_fast_ema = iMA(_Symbol, _Period, InpFastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   handle_slow_ema = iMA(_Symbol, _Period, InpSlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   
   if(handle_fast_ema == INVALID_HANDLE || handle_slow_ema == INVALID_HANDLE)
     {
      Print("[Error] Failed to initialize EMA indicator handles.");
      return(INIT_FAILED);
     }
     
   Print("[System] Trend Filter Module Initialized.");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Resource Cleanup & Memory Release
   IndicatorRelease(handle_fast_ema);
   IndicatorRelease(handle_slow_ema);
   ObjectDelete(0, "TrendStatusLabel");
   Print("[System] Trend Filter Module Stopped. Reason: ", reason);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Evaluate trend state strictly on confirmed bar close
   if(IsNewBar())
     {
      ENUM_TREND_STATE currentTrend = GetTrendStatus();
      UpdateChartLabel(currentTrend);
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
//| Classify Market Trend Regime (Evaluated on closed bar Index 1)   |
//+------------------------------------------------------------------+
ENUM_TREND_STATE GetTrendStatus()
  {
   double fast_ema[], slow_ema[], close_price[];
   
   // Fetch indicator buffers and closing price for the last closed candle
   if(CopyBuffer(handle_fast_ema, 0, 1, 1, fast_ema) <= 0) return SIDEWAY;
   if(CopyBuffer(handle_slow_ema, 0, 1, 1, slow_ema) <= 0) return SIDEWAY;
   if(CopyClose(_Symbol, _Period, 1, 1, close_price) <= 0) return SIDEWAY;

   double current_fast  = fast_ema[0];
   double current_slow  = slow_ema[0];
   double current_close = close_price[0];

   // Bullish Regime Condition
   if(current_fast > current_slow && current_close > current_fast)
     {
      return UPTREND;
     }
   // Bearish Regime Condition
   else if(current_fast < current_slow && current_close < current_fast)
     {
      return DOWNTREND;
     }
   // Consolidation / Sideway Regime
   else
     {
      return SIDEWAY;
     }
  }

//+------------------------------------------------------------------+
//| Render Real-Time Trend State Overlay on Chart UI                 |
//+------------------------------------------------------------------+
void UpdateChartLabel(ENUM_TREND_STATE trend)
  {
   string text_to_show = "";
   color text_color = clrWhite;

   switch(trend)
     {
      case UPTREND:
         text_to_show = "TREND: UPTREND";
         text_color   = clrLime;
         break;
      case DOWNTREND:
         text_to_show = "TREND: DOWNTREND";
         text_color   = clrRed;
         break;
      case SIDEWAY:
         text_to_show = "TREND: SIDEWAY";
         text_color   = clrYellow;
         break;
     }

   string obj_name = "TrendStatusLabel";

   if(ObjectFind(0, obj_name) < 0)
     {
      ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, 20);
      ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, 30);
      ObjectSetString(0, obj_name, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 14);
      ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
     }

   ObjectSetString(0, obj_name, OBJPROP_TEXT, text_to_show);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, text_color);
   
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+