-- Finding null values percentage in critical fields 
-- no null value present
SELECT 
  'tenure' AS column_name,
  COUNT(*) AS total_records,
  SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) AS missing_count,
  ROUND(SUM(CASE WHEN tenure IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS missing_pct
FROM churn_analysis

UNION ALL

SELECT 
  'Churn',
  COUNT(*),
  SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'MonthlyCharges',
  COUNT(*),
  SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN MonthlyCharges IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'TotalCharges',
  COUNT(*),
  SUM(CASE WHEN TotalCharges IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN TotalCharges IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'Contract',
  COUNT(*),
  SUM(CASE WHEN Contract IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Contract IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'InternetService',
  COUNT(*),
  SUM(CASE WHEN InternetService IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN InternetService IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'TechSupport',
  COUNT(*),
  SUM(CASE WHEN TechSupport IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN TechSupport IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'StreamingTV',
  COUNT(*),
  SUM(CASE WHEN StreamingTV IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN StreamingTV IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis

UNION ALL

SELECT 
  'StreamingMovies',
  COUNT(*),
  SUM(CASE WHEN StreamingMovies IS NULL  THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN StreamingMovies IS NULL  THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis;

-----------------------------------------------------------------------------------------------------------

--checking data consistency 

SELECT DISTINCT InternetService FROM churn_analysis;
SELECT DISTINCT PaymentMethod FROM churn_analysis;
SELECT DISTINCT TechSupport FROM churn_analysis;
SELECT DISTINCT Contract FROM churn_analysis;
SELECT DISTINCT Churn FROM churn_analysis;
SELECT DISTINCT TechSupport FROM churn_analysis;
SELECT DISTINCT PhoneService FROM churn_analysis;
SELECT DISTINCT MultipleLines FROM churn_analysis;
SELECT DISTINCT OnlineSecurity FROM churn_analysis;
SELECT DISTINCT OnlineSecurity FROM churn_analysis;
SELECT DISTINCT StreamingMovies FROM churn_analysis;

-- Rounding the numerical columns to two decimals for data consistency

UPDATE churn_analysis SET TotalCharges = ROUND(TotalCharges, 2);
UPDATE churn_analysis SET MonthlyCharges = ROUND(MonthlyCharges, 2);

-- updating the column values to No for data consistency

UPDATE churn_analysis SET TechSupport = 'No' WHERE TechSupport = 'No internet service';
UPDATE churn_analysis SET MultipleLines = 'No' WHERE MultipleLines = 'No phone service';
UPDATE churn_analysis SET OnlineSecurity = 'No' WHERE OnlineSecurity = 'No internet service';
UPDATE churn_analysis SET StreamingMovies = 'No' WHERE StreamingMovies = 'No internet service';
UPDATE churn_analysis SET OnlineBackup = 'No' WHERE OnlineBackup = 'No internet service';
UPDATE churn_analysis SET DeviceProtection = 'No' WHERE DeviceProtection = 'No internet service';
UPDATE churn_analysis SET StreamingTV = 'No' WHERE StreamingTV = 'No internet service';

-------------------------------------------------------

--checking Logical inconsistency
-- Customers with 0 months of usage but still charged — invalid

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE tenure = 0 AND TotalCharges > 0 AND MonthlyCharges = 0;

-- Churned customers with 0 months usage, data error

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE tenure = 0  AND Churn = 'Yes';

--  Active customers paying monthly but total charges is 0 — mismatch in billing

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE MonthlyCharges > 0 AND tenure > 0 AND TotalCharges = 0;

-- Contract is NULL but customer has payments or usage — contract assignment missing

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE Contract IS NULL AND (
    MonthlyCharges > 0 
    OR TotalCharges > 0 
    OR tenure > 0 
    OR Churn = 'Yes'
);

--No monthly charges but advanced services enabled — billing issue

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE MonthlyCharges = 0 
AND (InternetService = 'Yes' OR StreamingTV = 'Yes' OR TechSupport = 'Yes');

-- Negative charges — invalid financial records

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE MonthlyCharges < 0 OR TotalCharges < 0;

-- Churned customers with no usage and no payments — likely signed up and cancelled instantly

SELECT COUNT(*) as cnt
FROM churn_analysis
WHERE Churn = 'Yes'
  AND tenure = 0
  AND MonthlyCharges = 0
  AND TotalCharges = 0;

-- No monthly fee but using chargeable features — missing billing

SELECT COUNT(*) AS cnt
FROM churn_analysis
WHERE MonthlyCharges = 0
  AND (
    StreamingTV = 'Yes' OR
    TechSupport = 'Yes' OR
    MultipleLines = 'Yes'
  );

-- Monthly fee exists but customer has no service active — likely service assignment failure

SELECT COUNT(*) AS RecordCount
FROM churn_analysis
WHERE MonthlyCharges > 0
  AND InternetService = 'No' 
  AND StreamingTV = 'No' 
  AND TechSupport = 'No' 
  AND OnlineSecurity = 'No' 
  AND PhoneService = 'No';

-- No monthly revenue but active — customer may be getting services for free

SELECT COUNT(*) AS RecordCount
FROM churn_analysis
WHERE MonthlyCharges = 0
  AND (InternetService = 'Yes' OR StreamingTV = 'Yes' OR TechSupport = 'Yes' OR OnlineSecurity = 'Yes' OR PhoneService = 'Yes' );

-- Positive total despite no monthly revenue

SELECT COUNT(*) AS cnt
FROM churn_analysis
WHERE MonthlyCharges = 0 AND  TotalCharges > 0;

--Update NULL TotalCharges to 0.00 for active new customers with non-zero billing under yearly contracts.
UPDATE churn_analysis
SET TotalCharges = 0.00
WHERE Tenure = 0
  AND MonthlyCharges > 0
  AND TotalCharges IS NULL
  AND Contract IN ('One year', 'Two year')
  AND Churn = 'No';
---------------------------------------------------------

--duplicates
SELECT CustomerID, COUNT(*) AS cnt
FROM churn_analysis
GROUP BY CustomerID
HAVING COUNT(*) > 1;

-----------------------------------------------------
-- Find outliers in MonthlyCharges or TotalCharges
SELECT *
FROM churn_analysis
WHERE MonthlyCharges > 150
   OR TotalCharges > 10000;

-----------------------------------------------------------
-- Customer cohort retention analysis based on tenure
WITH customer_cohorts AS (
  SELECT
    CustomerID,
    CASE
      WHEN tenure <= 12 THEN '0-12 months'
      WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
      ELSE '25+ months'
    END AS tenure_cohort,
    CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END AS churned
  FROM churn_analysis
)
SELECT
  tenure_cohort,
  COUNT(*) AS total_customers,
  SUM(churned) AS churned_customers,
  ROUND(SUM(churned) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM customer_cohorts
GROUP BY tenure_cohort;
----------------------------------------------------------------------------
-- Churn rate by various feature usages
-- Customers who lack support or security features are more likely to churn
SELECT 
  'InternetService' AS feature,
  InternetService AS feature_value,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM churn_analysis
GROUP BY InternetService

UNION ALL

SELECT 
  'PhoneService',
  PhoneService,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY PhoneService

UNION ALL

SELECT 
  'MultipleLines',
  MultipleLines,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY MultipleLines

UNION ALL

SELECT 
  'OnlineSecurity',
  OnlineSecurity,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY OnlineSecurity

UNION ALL

SELECT 
  'TechSupport',
  TechSupport,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY TechSupport

UNION ALL

SELECT 
  'StreamingTV',
  StreamingTV,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY StreamingTV

UNION ALL

SELECT 
  'StreamingMovies',
  StreamingMovies,
  COUNT(*),
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM churn_analysis
GROUP BY StreamingMovies;

---------------------------------------------------------------------------------------

-- Feature Usage Analysis Across Multiple Features
-- support and security services, which are also correlated with lower churn rates.

SELECT 
  'InternetService' AS feature,
  InternetService AS feature_value,
  (SELECT COUNT(*) FROM churn_analysis)AS total_customers,
  CASE WHEN InternetService IN ('DSL', 'Fiber optic','No') THEN COUNT(*) ELSE 0 END AS users,
  CASE WHEN InternetService IN ('DSL', 'Fiber optic','No') 
       THEN ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
       ELSE 0
  END AS usage_pct
FROM churn_analysis
GROUP BY InternetService

UNION ALL

SELECT 
  'PhoneService',
  PhoneService,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN PhoneService = 'Yes'or PhoneService = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN PhoneService = 'Yes'or PhoneService = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY PhoneService

UNION ALL

SELECT 
  'MultipleLines',
  MultipleLines,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN MultipleLines = 'Yes' or  MultipleLines = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN MultipleLines = 'Yes' or  MultipleLines = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY MultipleLines

UNION ALL

SELECT 
  'OnlineSecurity',
  OnlineSecurity,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN OnlineSecurity = 'Yes'or OnlineSecurity = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN OnlineSecurity = 'Yes'or OnlineSecurity = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY OnlineSecurity

UNION ALL

SELECT 
  'TechSupport',
  TechSupport,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN TechSupport = 'Yes' or  TechSupport = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN TechSupport = 'Yes'or TechSupport = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY TechSupport

UNION ALL

SELECT 
  'StreamingTV',
  StreamingTV,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN StreamingTV = 'Yes'or StreamingTV = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN StreamingTV = 'Yes'or StreamingTV = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY StreamingTV

UNION ALL

SELECT 
  'StreamingMovies',
  StreamingMovies,
  (SELECT COUNT(*) FROM churn_analysis),
  SUM(CASE WHEN StreamingMovies = 'Yes'or StreamingMovies = 'No' THEN 1 ELSE 0 END),
  ROUND(SUM(CASE WHEN StreamingMovies = 'Yes'or StreamingMovies = 'No' THEN 1 ELSE 0 END) * 100.0 / (SELECT COUNT(*) FROM churn_analysis), 2)
FROM churn_analysis
GROUP BY StreamingMovies;


--------------------------------------------------

-- Churn rate by subscription type
--Longer contracts (1 or 2 years) have much lower churn

SELECT 
  Contract,
  COUNT(*) AS total_customers,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct
FROM churn_analysis
GROUP BY Contract;

--------------------------------------------------------------------
--churning rate of users based on features
-- Offering bundled packages with support, phone, and streaming may reduce churn, even for customers without internet.

SELECT 
  CASE WHEN InternetService = 'Yes' THEN 'HasInternet' ELSE 'NoInternet' END AS InternetUsage,
  CASE WHEN TechSupport = 'Yes' OR OnlineSecurity = 'Yes' THEN 'HasSupport' ELSE 'NoSupport' END AS SupportTier,
  CASE WHEN StreamingTV = 'Yes' OR StreamingMovies = 'Yes' THEN 'HasStreaming' ELSE 'NoStreaming' END AS MediaUsage,
  CASE WHEN PhoneService = 'Yes' THEN 'HasPhone' ELSE 'NoPhone' END AS PhoneLine,
  CASE WHEN MultipleLines = 'Yes' THEN 'MultiLineUser' ELSE 'SingleLineOrNone' END AS LineType,
  
  COUNT(*) AS total_customers,
  SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned_customers,
  ROUND(SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS churn_rate_pct

FROM churn_analysis
GROUP BY 
  CASE WHEN InternetService = 'Yes' THEN 'HasInternet' ELSE 'NoInternet' END,
  CASE WHEN TechSupport = 'Yes' OR OnlineSecurity = 'Yes' THEN 'HasSupport' ELSE 'NoSupport' END,
  CASE WHEN StreamingTV = 'Yes' OR StreamingMovies = 'Yes' THEN 'HasStreaming' ELSE 'NoStreaming' END,
  CASE WHEN PhoneService = 'Yes' THEN 'HasPhone' ELSE 'NoPhone' END,
  CASE WHEN MultipleLines = 'Yes' THEN 'MultiLineUser' ELSE 'SingleLineOrNone' END

ORDER BY churn_rate_pct DESC;

