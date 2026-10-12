SELECT
    us_state,
    argMax(cat_id, transactions_v2_summary.max_amount) AS cat_id,
    max(transactions_v2_summary.max_amount) AS max_amount
FROM transactions_v2_summary
GROUP BY us_state
ORDER BY us_state;
