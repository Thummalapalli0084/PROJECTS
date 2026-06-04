# 🎬 Sentiment Analysis Using RNN / Deep RNN (LSTM)

[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/Thummalapalli0084/PROJECTS/blob/main/Sentiment_Analysis_RNN.ipynb)
![Python](https://img.shields.io/badge/Python-3.10-blue)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.x-orange)
![Status](https://img.shields.io/badge/Status-Completed-green)

---

## 📌 Project Overview

This project builds a **Sentiment Analysis** model using **Recurrent Neural Networks (RNN)** and **Deep RNN (Stacked LSTM / BiLSTM)** architectures to classify IMDb movie reviews as **Positive** or **Negative**.

The model learns sequential dependencies in text to accurately predict the emotional tone of a review — a core task in Natural Language Processing (NLP) with wide business applications including customer feedback analysis, product reviews, and social media monitoring.

---

## 🎯 Problem Statement

Given a movie review (text), predict whether the sentiment is:
- **1 → Positive** 😊
- **0 → Negative** 😞

---

## 📂 Dataset

| Property | Details |
|---|---|
| Source | IMDb Movie Reviews (`keras.datasets.imdb`) |
| Size | 50,000 reviews (25K train + 25K test) |
| Labels | Binary — Positive (1) / Negative (0) |
| Vocabulary | Top 10,000 most frequent words |
| Max Sequence Length | 200 tokens |

---

## 🛠️ Tech Stack

| Category | Tools |
|---|---|
| Language | Python 3.10 |
| Deep Learning | TensorFlow 2.x, Keras |
| Data Processing | NumPy, Pandas |
| Visualization | Matplotlib, Seaborn |
| Environment | Google Colab (GPU — T4) |

---

## 🏗️ Project Pipeline

```
Raw Text Reviews
      ↓
Data Preprocessing
(Tokenization → Padding → Label Encoding)
      ↓
Word Embedding Layer
      ↓
┌─────────────────────────────────────┐
│  Model 1: Simple RNN (Baseline)     │
│  Model 2: Deep LSTM (Stacked)       │
│  Model 3: Bidirectional LSTM (Best) │
└─────────────────────────────────────┘
      ↓
Evaluation
(Accuracy, Loss, Confusion Matrix, F1-Score)
      ↓
Manual Testing on Custom Sentences
```

---

## 🧠 Model Architectures

### Model 1 — Simple RNN (Baseline)
```
Embedding(10000, 64) → SimpleRNN(64) → Dropout(0.3) → Dense(32) → Dense(1, sigmoid)
```

### Model 2 — Deep LSTM (Stacked)
```
Embedding(10000, 64) → LSTM(128) → Dropout(0.3) → LSTM(64) → Dropout(0.3) → Dense(64) → Dense(1, sigmoid)
```

### Model 3 — Bidirectional LSTM ⭐ Best
```
Embedding(10000, 64) → BiLSTM(64) → Dropout(0.3) → BiLSTM(32) → Dropout(0.3) → Dense(64) → Dense(1, sigmoid)
```

---

## 📊 Results

| Model | Architecture | Test Accuracy |
|---|---|---|
| Simple RNN | Baseline | ~85% |
| Deep LSTM | Stacked LSTM | ~88% |
| **BiLSTM** ⭐ | **Bidirectional LSTM** | **~89–90%** |

- **Loss Function:** Binary Cross-Entropy  
- **Optimizer:** Adam  
- **Regularization:** Dropout + EarlyStopping  

---

## 📈 Evaluation Metrics

- ✅ Accuracy & Loss Curves (Train vs Validation)
- ✅ Confusion Matrix
- ✅ Precision, Recall, F1-Score (Classification Report)
- ✅ Manual Testing on 5 custom sentences

---

## 🔍 Sample Predictions

| Review | Prediction | Confidence |
|---|---|---|
| "Absolutely fantastic movie! Superb acting." | POSITIVE 😊 | 0.97 |
| "Terrible film. Boring and a waste of time." | NEGATIVE 😞 | 0.03 |
| "It was okay, not great but not terrible." | NEGATIVE 😞 | 0.42 |

---

## 🚀 How to Run

### Option 1: Google Colab (Recommended)
1. Click the **Open in Colab** badge above
2. Go to **Runtime → Change runtime type → GPU (T4)**
3. Click **Run All**

### Option 2: Local (Jupyter Notebook)
```bash
# Clone the repository
git clone https://github.com/Thummalapalli0084/PROJECTS.git
cd PROJECTS

# Install dependencies
pip install tensorflow numpy pandas matplotlib seaborn scikit-learn

# Launch notebook
jupyter notebook Sentiment_Analysis_RNN.ipynb
```

---

## 📁 File Structure

```
Sentiment_Analysis_RNN/
│
├── Sentiment_Analysis_RNN.ipynb   # Main Colab notebook
├── README.md                      # Project documentation
└── sentiment_bilstm_model.h5      # Saved best model (generated after training)
```

---

## 🔑 Key Learnings

- Deep RNN (stacked LSTM) significantly outperforms Simple RNN on sequential text
- Bidirectional LSTM captures context from both directions, improving accuracy
- Padding sequences to a fixed length is critical for batch training
- Dropout layers and EarlyStopping prevent overfitting effectively
- Word Embedding layers learn semantic word representations during training

---

## 🔮 Future Improvements

- [ ] Add GloVe / Word2Vec pretrained embeddings
- [ ] Extend to 3-class classification (Positive / Negative / Neutral)
- [ ] Deploy as a Flask / Streamlit web app
- [ ] Experiment with Transformer-based models (BERT)

---

## 👤 Author

**Dinesh Naidu Thummalapalli**  
B.Tech EEE | Data Analytics Enthusiast  
📧 dineshnaiduthummalapalli@gmail.com  
🔗 [LinkedIn](https://linkedin.com/in/dineshnaiduprofile/)  
💻 [GitHub](https://github.com/Thummalapalli0084/PROJECTS)

---

*⭐ If you found this project useful, please consider starring the repository!*
