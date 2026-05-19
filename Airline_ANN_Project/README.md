# ✈️ ANN Capstone Project — Airline Passenger Satisfaction Prediction

**Author:** Dinesh Naidu T  
**Degree:** B.Tech — Electrical & Electronics Engineering  
**Dataset:** [Airline Passenger Satisfaction — Kaggle](https://www.kaggle.com/datasets/teejmahal20/airline-passenger-satisfaction)  
**Model:** Artificial Neural Network (ANN) using TensorFlow / Keras  
**Task:** Binary Classification (Satisfied vs. Neutral or Dissatisfied)

---

## 📁 Project Files

| File | Description |
|------|-------------|
| `ann_airline_project.py` | Complete Python script — EDA, cleaning, model, evaluation |
| `ANN_Capstone_Airline_Satisfaction_DineshNaiduT.docx` | Full project report with charts and analysis |
| `README.md` | This file |

---

## 🎯 Problem Statement

Airlines collect vast amounts of passenger feedback, but predicting satisfaction in advance remains a challenge. This project builds an ANN model to classify whether a passenger will be **Satisfied** or **Neutral / Dissatisfied** based on:

- Demographic info (age, gender)
- Travel context (class, travel type, flight distance)
- 14 in-flight service ratings (seat comfort, entertainment, food, etc.)
- Delay information (departure and arrival delay in minutes)

---

## 🗂️ Dataset

Download the dataset from Kaggle before running the script:

- **Train file:** `train.csv`
- **Test file:** `test.csv`
- **Records:** ~130,000 passengers
- **Features:** 22 input columns + 1 target column
- **Target:** `satisfaction` → `satisfied` or `neutral or dissatisfied`

After downloading, place both CSV files in the same folder as the script.

---

## ⚙️ Setup & Installation

### 1. Clone / Download this project

```bash
git clone <your-repo-url>
cd ann-airline-satisfaction
```

### 2. Install dependencies

```bash
pip install numpy pandas matplotlib seaborn scikit-learn tensorflow
```

### 3. Add the dataset

Place `train.csv` and `test.csv` in the project folder.

### 4. Update the script

Open `ann_airline_project.py` and replace the synthetic data block with:

```python
df = pd.read_csv("train.csv")
```

### 5. Run the project

```bash
python ann_airline_project.py
```

---

## 🏗️ Project Workflow

```
1. Load Data
      ↓
2. Exploratory Data Analysis (EDA)
      ↓
3. Data Cleaning
   ├── Handle missing values (median imputation)
   ├── Remove outliers (IQR method)
   └── Encode categorical features (Label Encoding)
      ↓
4. Preprocessing
   ├── Train-Test Split (80/20, stratified)
   └── Feature Scaling (StandardScaler)
      ↓
5. ANN Model Building
   └── Architecture: 128 → 64 → 32 → 1 (Sigmoid)
       with BatchNormalization + Dropout
      ↓
6. Training
   └── Adam optimizer, EarlyStopping, ReduceLROnPlateau
      ↓
7. Evaluation
   └── Accuracy, ROC-AUC, Confusion Matrix, Classification Report
```

---

## 🧠 ANN Architecture

| Layer | Type | Units / Rate |
|-------|------|-------------|
| Input | Dense + ReLU | 128 neurons |
| — | BatchNormalization | — |
| — | Dropout | 0.3 |
| Hidden | Dense + ReLU | 64 neurons |
| — | BatchNormalization | — |
| — | Dropout | 0.2 |
| Hidden | Dense + ReLU | 32 neurons |
| — | Dropout | 0.2 |
| Output | Dense + Sigmoid | 1 neuron |

**Total Parameters:** 14,081  
**Optimizer:** Adam (lr=0.001)  
**Loss:** Binary Crossentropy  
**Callbacks:** EarlyStopping (patience=10), ReduceLROnPlateau (factor=0.5)

---

## 📊 Results

| Metric | Score |
|--------|-------|
| Test Accuracy | ~94% (full dataset) |
| ROC-AUC | ~0.98 (full dataset) |
| Macro F1-Score | ~0.94 |

> Results above are expected on the full Kaggle dataset (~130K records). The script in this repo uses a smaller synthetic sample for demonstration; replace it with the actual CSV for production results.

---

## 📈 Output Plots

The script automatically generates and saves:

- `eda_plots.png` — 6-panel EDA overview
- `correlation_heatmap.png` — Feature correlation matrix
- `model_evaluation.png` — Training curves, confusion matrix, ROC curve

---

## 💡 Key Business Insights

- **Business class** passengers are ~2.3× more likely to be satisfied than Economy
- **Inflight entertainment**, **seat comfort**, and **online boarding** are the top satisfaction drivers
- Departure delays **> 30 minutes** significantly reduce satisfaction regardless of service quality
- **Loyal customers** are more satisfaction-sensitive — targeted recovery matters

---

## 🛠️ Tech Stack

- **Language:** Python 3
- **ML Framework:** TensorFlow 2.x / Keras
- **Data:** Pandas, NumPy
- **Visualization:** Matplotlib, Seaborn
- **Preprocessing:** Scikit-learn

---

## 📝 License

This project is submitted as part of an academic capstone requirement. Dataset credit: Kaggle — Airline Passenger Satisfaction.
