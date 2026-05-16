# 📡 Telecom Customer Churn Prediction

A end-to-end Machine Learning project to predict customer churn for a telecom provider using Exploratory Data Analysis and classification algorithms.

---

## 📁 Project Structure

```
telecom-churn-prediction/
│
├── churn_dataset.csv        # Raw dataset (7,043 records)
├── telecom_churn.ipynb      # Main Jupyter Notebook (Sprint 1 + Sprint 2)
└── README.md                # Project documentation
```

---

## 🧾 Problem Statement

> Given various features about a telecom customer (contract type, internet service, tenure, charges, etc.), **predict whether the customer will churn or not.**

- **Domain:** Telecommunication
- **Task Type:** Binary Classification
- **Target Variable:** `Churn` (Yes = 1, No = 0)
- **Evaluation Metric:** Accuracy Score

---

## 📊 Dataset Overview

| Property | Detail |
|---|---|
| Source | Telecom Customer Churn Dataset |
| Records | 7,043 customers |
| Features | 21 columns |
| Target | Churn (Yes / No) |

### Feature Categories

- **Demographics:** gender, SeniorCitizen, Partner, Dependents
- **Services:** PhoneService, MultipleLines, InternetService, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies
- **Account Info:** tenure, Contract, PaymentMethod, PaperlessBilling, MonthlyCharges, TotalCharges

---

## 🔍 Sprint 1 — Exploratory Data Analysis

### Key Insights

| # | Insight |
|---|---|
| 1 | Overall churn rate is **26.6%** — class imbalance present |
| 2 | **Month-to-month** contract customers churn at 42.7% vs 2.8% for 2-year contracts |
| 3 | **Fiber Optic** internet users churn at 41.9% — well above average |
| 4 | **New customers (0–12 months)** are highest risk at 47.7% churn |
| 5 | **Senior citizens** churn at 41.7% vs 23.7% for non-seniors |
| 6 | Higher MonthlyCharges positively correlated with churn |

### Business Recommendations

- **R1:** Incentivize month-to-month customers to switch to annual contracts
- **R2:** Launch 90-day onboarding loyalty program for new customers
- **R3:** Bundle security/support add-ons for Fiber Optic users at discounted rates
- **R4:** Design senior citizen retention packages with simplified billing
- **R5:** Flag customers with high monthly charges + low tenure as high-risk

---

## 🤖 Sprint 2 — Model Building

### Data Preparation

| Step | Action |
|---|---|
| Train/Test Split | 75% Train / 25% Test (stratified) |
| Binary Categorical | Label Encoding |
| Multi-class Categorical | One Hot Encoding |
| Numerical Features | StandardScaler — Fit+Transform on Train, Transform only on Test |

### Model Results

| Algorithm | Accuracy |
|---|---|
| KNN | 76.39% |
| Logistic Regression | **80.60% ✅ Best** |
| SVM | 79.52% |
| Decision Tree | 72.70% |
| Random Forest | 79.01% |

### Conclusion

**Logistic Regression** achieved the highest accuracy of **80.60%** and is the recommended model for production churn prediction. It is interpretable, fast, and well-suited for binary classification on structured tabular data.

---

## ⚙️ How to Run

### 1. Clone / Download the project

```bash
git clone https://github.com/your-username/telecom-churn-prediction.git
cd telecom-churn-prediction
```

### 2. Install dependencies

```bash
pip install pandas numpy matplotlib seaborn scikit-learn
```

### 3. Launch Jupyter Notebook

```bash
jupyter notebook telecom_churn.ipynb
```

> Make sure `churn_dataset.csv` is in the same folder as the notebook.

---

## 🛠️ Tech Stack

| Tool | Purpose |
|---|---|
| Python 3.x | Core language |
| Pandas | Data manipulation |
| NumPy | Numerical operations |
| Matplotlib & Seaborn | Data visualization |
| Scikit-learn | ML model building & evaluation |
| Jupyter Notebook | Interactive development |

---

## 👤 Author

**Dinesh Naidu T**
- 📧 dineshnaiduthummalapalli@gmail.com
- 🔗 [LinkedIn](https://linkedin.com/in/dineshnaiduprofile/)
- 💻 [GitHub](https://github.com/Thummalapalli0084/PROJECTS)
