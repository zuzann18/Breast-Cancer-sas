# Breast-Cancer-sas
### GitHub Repository Description

---

**Title:** Breast Cancer Survival Analysis

**Description:**
This project explores survival analysis for breast cancer patients based on the METABRIC dataset, which contains clinical profiles of 2,509 patients diagnosed with breast cancer. The primary goal is to determine the factors that significantly influence patient survival. 

**Key Features:**
- **Dataset:** Kaggle METABRIC dataset ([Link to Dataset](https://www.kaggle.com/datasets/gunesevitan/breast-cancer-metabric)).
  - **Variables:** 26 independent variables, including age, cancer subtype, menopausal state, and treatment history.
  - Survival data based on `Overall Survival Months` and `Overall Survival Status`.
- **Methodologies Used:**
  - **Non-parametric Models:** Kaplan-Meier method for estimating survival functions and understanding data trends.
  - **Parametric Models:** Analysis with exponential, Weibull, and gamma distributions to model survival time.
  - **Semi-parametric Models:** Cox proportional hazards model to calculate Hazard Ratios and identify time-dependent covariates.

**Analysis Highlights:**
- Kaplan-Meier survival curves and statistical tests reveal trends across menopausal states and cellularity levels.
- Exponential and Weibull models were deemed unsuitable, with the gamma distribution providing the best fit.
- Time-dependent variables include `Age at Diagnosis`, `ER Status`, `Tumor Stage`, and others, impacting survival predictions.

**Key Findings:**
- Significant factors influencing survival include patient age, tumor stage, and chemotherapy history.
- Patients undergoing chemotherapy have a 32.2% higher risk of mortality compared to those who did not.
- The gamma model was identified as the most appropriate parametric approach based on fit statistics.

**Tools & Technologies:**
- **Language:** SAS (Statistical Analysis System) for data processing and modeling.
- **Statistical Methods:** Kaplan-Meier, log-rank test, Wilcoxon test, and parametric modeling.
- **Visualization:** Survival plots, hazard functions, and model diagnostics.

**Repository Contents:**
- **Code:** SAS scripts for data preprocessing and survival modeling.
- **Documentation:** Detailed steps and interpretations of analysis methods.
- **Results:** Summary of survival curves, statistical tests, and model evaluations.

**How to Use:**
1. Load the METABRIC dataset (link provided above).
2. Run the SAS scripts to replicate the survival analysis.
3. Explore the survival functions and model outputs to derive insights.

**Future Work:**
- Extend analysis to include machine learning techniques for survival prediction.
- Explore additional datasets to generalize findings.
