# Research Project: The Impact of Global Macro Risks on Vietnam Stock Market

## 📌 Introduction
This project analyzes the simultaneous impact of three global macroeconomic risk factors on the VN-Index (2015-2024):
- 🌐 **Geopolitical Risk (GPR)**
- 📉 **Economic Policy Uncertainty (EPU)**
- 💸 **Financial Stress Index (FSI)**

## 👥 Team Members
| Name            | Student ID   | Contribution |
|-----------------|-------------|--------------|
| Le Phuc Chi     | K224141652  | 100%         |
| Pham Minh Tuan  | K224141704  | 100%         |
| Le Nam Tuyen    | K224141705  | 100%         |

## 🔍 Research Methodology
```r
# Main regression model
return_t = α + β₁GPR_t + β₂EPU_t + β₃FS_t + β₄RE_t + β₅rfvn_t + ε_t
```
**Techniques used:**
- OLS regression with Newey-West HAC standard errors
- ADF test for stationarity
- Outlier removal (|z-score| ≤ 3)

## 📊 Key Results
| Factor | Coefficient | p-value   | Impact                |
|--------|-------------|-----------|-----------------------|
| GPR    | -0.000419   | 0.0238*   | Decreases return      |
| EPU    | -0.000134   | 0.0110*   | Decreases return      |
| FSI    | -0.021576   | <0.001*** | Strongest negative    |
| FX     | -1.8542     | 0.0028**  | Most significant      |

## 💡 Recommendations
**For Investors:**
- Diversify into government bonds
- Monitor GPR/EPU indices monthly

**For Fund Managers:**
```python
# Example stress-test function
def stress_test(GPR, EPU, FSI):
    return 0.0838 - 0.0004*GPR - 0.0001*EPU - 0.0216*FSI
```
**For Policymakers:**
- Increase policy transparency
- Implement early warning systems when FSI > 5

## 📂 Data Structure
```
data/
├── raw/               # Raw data
│   └── stock_data.xlsx
├── processed/         # Cleaned data
│   └── clean_data.csv
scripts/
├── analysis.R         # Main analysis script
└── visualization.py   # Visualization script
```

## 🛠 Installation
```bash
# Clone repository
$ git clone https://github.com/yourrepo/vn-stock-analysis.git
$ cd vn-stock-analysis

# Install R packages
$ R -e "install.packages(c('tidyverse','lmtest','sandwich'))"
```

## 📚 References
- Caldara & Iacoviello (2022) - GPR Index
- Baker et al. (2016) - EPU Index
- Bernanke (1983) - Real Options Theory

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

## ⚙️ Technical Description

This project employs a robust quantitative methodology to analyze the relationship between macroeconomic risk factors and the Vietnamese stock market. Key technical aspects include:

-   **Econometric Models**:
    -   **Ordinary Least Squares (OLS) Regression**: Used to model the linear relationship between the VN-Index returns and selected macroeconomic variables.
    -   **Newey-West HAC (Heteroskedasticity and Autocorrelation Consistent) Standard Errors**: Applied to ensure the robustness of regression coefficients by correcting for potential heteroskedasticity and autocorrelation in the residuals, which are common in financial time series data.
-   **Time Series Analysis**:
    -   **Augmented Dickey-Fuller (ADF) Test**: Utilized to test for unit roots in time series data, ensuring stationarity for regression analysis. Non-stationary variables are differenced to achieve stationarity.
-   **Data Preprocessing**:
    -   **Outlier Detection and Removal**: Outliers are identified and filtered using the z-score method (keeping observations with |z-score| ≤ 3) to prevent undue influence on regression results.
    -   **Descriptive Statistics and Correlation Analysis**: Initial data exploration involves calculating descriptive statistics and correlation matrices to understand data distributions and relationships between variables.

## 💻 Technologies and Libraries Used

The project leverages a combination of R and Python for data handling, analysis, and visualization:

-   **Python**:
    -   `pandas`: For powerful data manipulation and analysis, especially in handling time series and large datasets (e.g., calculating market capitalization, merging dataframes).
    -   `numpy`: For numerical operations and mathematical functions.
    -   `vnstock`: A specialized Python library used for efficient and comprehensive data acquisition from the Vietnamese stock market, including historical prices, company information, and market indices from various sources (VCI, TCBS).
-   **R**:
    -   `dplyr`: For data wrangling and transformation.
    -   `readxl`: For reading Excel files.
    -   `urca`: For unit root tests (e.g., ADF test).
    -   `lmtest`: For various regression diagnostic tests (e.g., Breusch-Pagan, Breusch-Godfrey).
    -   `sandwich`: For robust covariance matrix estimation (e.g., Newey-West).
    -   `zoo`: For handling irregular time series and rolling calculations.

## 📊 Data Collection and Processing Workflow

The data workflow involves several stages, combining Python for data acquisition and index construction, and R for econometric analysis:

1.  **Data Acquisition (Python - `1_vietnam_stock_vnstock3.py`)**:
    -   Utilizes the `vnstock` library to retrieve historical stock prices (e.g., banking stocks, VN-Index), company fundamental data, trading statistics, and macroeconomic indicators.
    -   Data is collected from various reputable sources like VCI and TCBS via the `vnstock` API.
2.  **Banking Index Construction (Python - `banking_return_handle.ipynb`)**:
    -   **Raw Data Input**: Reads quarterly closing prices of banking stocks and their outstanding shares from CSV/Excel files.
    -   **Data Cleaning & Standardization**: Standardizes ticker names and converts date columns to datetime objects. Cleans `shares_raw` by removing delimiters and converting to float.
    -   **Market Capitalization Calculation**: Merges price data with outstanding shares (using `pd.merge_asof` for time-sensitive merges) to compute the market capitalization for each bank at each period.
    -   **Total Market Cap & Divisor Calculation**: Pivots the data to a wide format for easier summation of total market capitalization across all banks. Calculates the divisor to maintain index continuity when stocks are added or removed, using a base index value (e.g., 100).
    -   **Banking Index & Log-Return**: Computes the Bank Index by dividing total market capitalization by the calculated divisor. Derives the log-return of the Banking Index for use in econometric models.
    -   **Output**: Exports the constructed Banking Index and its returns to an Excel file (`banking_return.xlsx`).
3.  **Econometric Analysis (R - `NCKH.r`)**:
    -   **Data Loading**: Imports the pre-processed data, including VN-Index returns, Banking Index returns, and macroeconomic variables.
    -   **Descriptive Analysis**: Performs descriptive statistics and correlation analysis on the loaded dataset.
    -   **Outlier Treatment**: Applies z-score based outlier removal to numerical columns.
    -   **Stationarity Testing & Differencing**: Conducts ADF tests on key time series variables (`return`, `GPR`, `rfvn`, `EPU`, `RE`, `FS`) to check for stationarity. Non-stationary variables are differenced (e.g., `rfvn_diff`, `FS_diff`) to ensure valid regression assumptions.
    -   **OLS Regression & Robust Standard Errors**: Estimates the primary regression model, incorporating macroeconomic factors and other control variables. Newey-West HAC standard errors are used to address potential heteroskedasticity and autocorrelation.
    -   **Diagnostic Tests**: Performs a series of post-estimation tests:
        -   **Breusch-Pagan Test**: Checks for heteroskedasticity.
        -   **Breusch-Godfrey Test**: Checks for autocorrelation in residuals.
        -   **Ramsey RESET Test**: Assesses model specification and linearity.
        -   **Variance Inflation Factor (VIF)**: Detects multicollinearity among independent variables.
        -   **Shapiro-Wilk Test**: Examines the normality of regression residuals.

---
