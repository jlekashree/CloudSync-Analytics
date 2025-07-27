# CloudSync Customer Churn & Feature Usage Analysis

## 1. Project Overview

This project analyzes customer data for CloudSync, a B2B collaboration platform, to understand the key drivers of customer churn and feature usage. The primary business objective is to address an elevated monthly churn rate of 8.5% and a Net Revenue Retention (NRR) of 95%, which are below industry benchmarks.

The analysis uses a telecom dataset reinterpreted to model CloudSync's product suite and customer base. The goal is to derive actionable business strategies to improve customer retention, satisfaction, and lifetime value (LTV).

This repository contains the Python script used for the analysis, which includes data preparation, exploratory data analysis (EDA), and predictive modeling.

## 2. Analytical Approach

The analysis was conducted in three main stages:

1.  **Data Preparation**: The initial dataset of 7,043 customers was loaded and cleaned. This involved converting the `TotalCharges` column to a numeric type and handling missing values by imputing them with the column's median. The `customerID` was dropped as it is not a predictive feature, and the `Churn` column was encoded into a binary format (1 for 'Yes', 0 for 'No') for modeling.

2.  **Exploratory Data Analysis (EDA)**: A series of visualizations were created to uncover patterns in the data:
    * A **correlation heatmap** to understand relationships between numerical features like `tenure`, `MonthlyCharges`, and `Churn`.
    * Bar charts showing **churn rates by key add-on services** (e.g., `OnlineSecurity`, `TechSupport`) to identify features that strongly impact retention.
    * A count plot illustrating **churn by contract type** to highlight the importance of contract duration.
    * A bar chart comparing **churn rates across different demographic groups** (gender, senior citizens, dependents) against the overall average churn.
    * A **feature usage pie chart** to see the adoption rates of various services.

3.  **Predictive Modeling**: A simple Logistic Regression model was built to predict customer churn. The model was trained on a preprocessed dataset where numerical features were scaled and categorical features were one-hot encoded. Its performance was evaluated using an accuracy score, a confusion matrix, and a classification report.

## 3. Key Assumptions

* **Proxy Dataset**: The analysis assumes that the publicly available telecom dataset is a representative proxy for CloudSync's B2B SaaS customer behavior. Features like `InternetService` have been reinterpreted to represent CloudSync's user segments (e.g., 'Fiber optic' as advanced/high-bandwidth users).
* **Data Cleaning**: It is assumed that imputing missing `TotalCharges` with the median value is an appropriate method that does not significantly distort the underlying data distribution.
* **Feature Importance**: The features included in the dataset are assumed to be the most relevant ones for predicting churn. No external data was incorporated.

## 4. Instructions for Running the Code

To replicate this analysis, you can run the provided Jupyter Notebook.

### Prerequisites

You will need Python 3.12 and pip installed on your system.

### Installation

1.  Clone the repository to your local machine.
2.  Install all the required libraries by running the following command in your terminal from the project's root directory:
    ```bash
    pip install -r requirements.txt
    ```

### Execution

1.  Ensure you have the Jupyter Notebook file (`python_analysis.ipynb`) in your project directory.
2.  Run the following command in your terminal to start the Jupyter Notebook server:
    ```bash
    jupyter notebook
    ```
3.  Once the server is running, it will open a new tab in your web browser. Navigate to and open the `python_analysis.ipynb` file.
4.  Run the cells within the notebook sequentially to see the analysis and visualizations.

## 5. Challenges Encountered

* **Data Quality Issues**: The `TotalCharges` column contained empty spaces for some customers, causing it to be read as a non-numeric data type.
    * **Solution**: This was addressed by coercing the column to a numeric type, which converted the problematic entries to `NaN` (Not a Number). These `NaN` values were then filled with the median of the column to maintain data integrity.

* **Dataset Imbalance**: The dataset is imbalanced, with significantly more non-churning customers than churning ones.
    * **Solution**: This imbalance was noted during the EDA phase. While the predictive model still performs reasonably well, its ability to predict the minority class ('Churn' = Yes) is weaker. For a future iteration, techniques like SMOTE (Synthetic Minority Over-sampling Technique) or using different model evaluation metrics (like F1-score or AUC-ROC) could be employed to better handle this imbalance.
