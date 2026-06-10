#Create database 
CREATE DATABASE casino_analytics;
USE casino_analytics;
SHOW Tables;

#Verify data
SELECT *
FROM bets
Limit 5;

SELECT *
FROM players 
Limit 5;

SELECT *
FROM sessions
Limit 5;

SELECT *
FROM table_types 
Limit 5;

#ANALYSIS,WHICH GAMES GENERATE THE MOST PROFIT 
 SELECT game_type,
        SUM(total_wager-total_win) AS profit
 FROM sessions
 GROUP BY game_type
 ORDER BY profit DESC;
 
 #player lifetime value
 SELECT player_id,
        SUM(total_wager - total_win) AS lifetime_profit
FROM sessions
GROUP BY player_id
ORDER BY lifetime_profit DESC;
 
 #operational analytics
SELECT 
    EXTRACT(HOUR FROM start_time) AS hour,
    COUNT(*) AS total_sessions,
    SUM(total_wager - total_win) AS profit
FROM sessions
GROUP BY EXTRACT(HOUR FROM start_time)
ORDER BY profit DESC;     

#Risk/Fraud amalysis 
SELECT 
    player_id,
    session_id,
    game_type,
    total_wager,
    total_win,
    (total_win - total_wager) AS net_result,
    (total_win / NULLIF(total_wager, 0)) AS win_ratio
FROM sessions;

#define risk flags 
SELECT 
    player_id,
    COUNT(*) AS sessions,
    SUM(CASE WHEN total_win > total_wager * 1.08 THEN 1 ELSE 0 END) AS high_payout_sessions,
    AVG(total_win - total_wager) AS avg_profit,
    MAX(total_win - total_wager) AS max_win,
    STDDEV(total_win - total_wager) AS volatility
FROM sessions
GROUP BY player_id;

#build fraud risk score 
SELECT 
    player_id,
    
    COUNT(*) AS sessions,
    SUM(CASE WHEN total_win > total_wager * 1.08 THEN 1 ELSE 0 END) AS high_payout_sessions,
    
    AVG(total_win - total_wager) AS avg_profit,
    
    STDDEV(total_win - total_wager) AS volatility,
    
    (
        SUM(CASE WHEN total_win > total_wager * 1.08 THEN 1 ELSE 0 END) * 2
        + STDDEV(total_win - total_wager) * 0.5
        + GREATEST(AVG(total_win - total_wager), 0) * 1.5
    ) AS risk_score

FROM sessions
GROUP BY player_id
ORDER BY risk_score DESC;