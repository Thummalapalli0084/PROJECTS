# 🥦 Vegetable Image Classification using CNN & Transfer Learning

<div align="center">

![Python](https://img.shields.io/badge/Python-3.10-blue?style=for-the-badge&logo=python)
![TensorFlow](https://img.shields.io/badge/TensorFlow-2.x-orange?style=for-the-badge&logo=tensorflow)
![Keras](https://img.shields.io/badge/Keras-Deep%20Learning-red?style=for-the-badge&logo=keras)
![Kaggle](https://img.shields.io/badge/Dataset-Kaggle-20beff?style=for-the-badge&logo=kaggle)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A CNN-based deep learning system that automatically classifies 15 common vegetables from images — built for smart agriculture, automated sorting, and food quality control.**

[📓 Notebook](#notebook) · [📊 Results](#results) · [🗂️ Dataset](#dataset) · [🚀 Getting Started](#getting-started) · [📁 Project Structure](#project-structure)

</div>

---

## 🎯 Problem Statement

Manual identification and sorting of vegetables in agricultural supply chains is **time-consuming, error-prone, and labour-intensive**. Misclassification leads to quality-control failures and economic losses across distribution centres and retail.

This project builds a deep learning model that can **automatically classify images of 15 vegetable types** with high accuracy — enabling:
- Automated sorting on conveyor lines
- Smart retail self-checkout systems
- Agricultural IoT quality monitoring
- Mobile grocery assistance apps

---

## 📋 Project Workflow

| Step | Task |
|------|------|
| 1 | Understand the dataset — structure, classes, sizes |
| 2 | Problem Statement |
| 3 | Data Visualization — distributions, pixel analysis, samples |
| 4 | Data Cleaning — corrupt image detection, duplicate check |
| 5 | Data Manipulation — augmentation strategy |
| 6 | Preprocessing — ImageDataGenerators, normalisation |
| 7A | Custom CNN model from scratch |
| 7B | Transfer Learning with VGG16 (2-phase fine-tuning) |
| 7C | Evaluation & model comparison |

---

## 🗂️ Dataset

**Source:** [Vegetable Image Dataset — Kaggle](https://www.kaggle.com/datasets/misrakahmed/vegetable-image-dataset)

| Property | Value |
|----------|-------|
| Total Images | 21,000 |
| Number of Classes | 15 |
| Image Size | 224 × 224 px (JPEG) |
| Class Balance | Perfectly balanced (1,400 images/class) |
| Pre-built Splits | Train / Validation / Test |
| Train Images | 15,000 (1,000/class) |
| Validation Images | 3,000 (200/class) |
| Test Images | 3,000 (200/class) |

**Vegetable Classes:**

> Bean · Bitter Gourd · Bottle Gourd · Brinjal · Broccoli · Cabbage · Capsicum · Carrot · Cauliflower · Cucumber · Papaya · Potato · Pumpkin · Radish · Tomato

---

## 🏗️ Model Architectures

### Model 1 — Custom CNN from Scratch

```
Input (224×224×3)
    │
    ├── Conv Block 1: Conv2D(32) → BN → Conv2D(32) → MaxPool → Dropout(0.25)
    ├── Conv Block 2: Conv2D(64) → BN → Conv2D(64) → MaxPool → Dropout(0.25)
    ├── Conv Block 3: Conv2D(128) → BN → Conv2D(128) → MaxPool → Dropout(0.25)
    ├── Conv Block 4: Conv2D(256) → BN → MaxPool → Dropout(0.30)
    │
    ├── GlobalAveragePooling2D
    ├── Dense(512) → BN → Dropout(0.50)
    ├── Dense(256) → Dropout(0.30)
    └── Dense(15, softmax)
```

### Model 2 — VGG16 Transfer Learning (2-Phase Fine-Tuning)

```
Phase 1 — Frozen base:
    VGG16 (ImageNet, frozen) → GAP → Dense(512) → BN → Dropout → Dense(256) → Dense(15, softmax)
    LR = 1e-3 | Epochs = 10

Phase 2 — Fine-tuning:
    VGG16 block5 (unfrozen) + classifier head
    LR = 1e-5 | Epochs = 20
```

---

## 📊 Results

| Model | Test Accuracy | Precision | Recall | F1-Score |
|-------|:---:|:---:|:---:|:---:|
| Custom CNN | ~92% | ~92% | ~91% | ~91% |
| **VGG16 Transfer Learning** | **~96%** | **~96%** | **~96%** | **~96%** |

> **Winner: VGG16 Transfer Learning** — ~4–5% accuracy gain over the custom CNN, with stronger per-class performance across difficult-to-distinguish vegetable pairs.

### Training Curves
![Training Curves](outputs/vgg16_training_curves.png)

### Confusion Matrix
![Confusion Matrix](outputs/confusion_matrix_vgg16.png)

### Model Comparison
![Model Comparison](outputs/model_comparison.png)

### Sample Predictions
![Sample Predictions](outputs/sample_predictions.png)

---

## 🔑 Key Findings

1. **VGG16 Transfer Learning** outperforms the custom CNN by ~4–5%, demonstrating the power of ImageNet pre-trained features even on a domain-specific dataset.
2. **Perfectly balanced classes** — no class weighting or oversampling was needed, reducing pipeline complexity.
3. **Data augmentation** (rotation ±20°, zoom 20%, brightness ±20%, horizontal flip) significantly reduced overfitting in the custom CNN.
4. **Two-phase fine-tuning** (freeze all → unfreeze VGG16 block5) was more effective and safer than end-to-end training from scratch.
5. **BatchNormalization + Dropout** at every block was critical for regularisation in the custom architecture.
6. **EarlyStopping + ReduceLROnPlateau** callbacks prevented over-training and maintained generalisation.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/Thummalapalli0084/vegetable-cnn-classification.git
cd vegetable-cnn-classification
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

### 3. Download the dataset

```bash
# Install Kaggle CLI
pip install kaggle

# Download dataset (requires kaggle.json API key)
kaggle datasets download -d misrakahmed/vegetable-image-dataset
unzip vegetable-image-dataset.zip -d .
```

### 4. Create output folders

```bash
mkdir -p outputs models
```

### 5. Run the notebook

```bash
jupyter notebook Vegetable_CNN_Classification.ipynb
```

---

## 📁 Project Structure

```
vegetable-cnn-classification/
│
├── Vegetable_CNN_Classification.ipynb   ← Main project notebook
├── requirements.txt                     ← Python dependencies
├── README.md                            ← This file
│
├── Vegetable Images/                    ← Dataset (download from Kaggle)
│   ├── train/
│   │   ├── Bean/
│   │   ├── Bitter_Gourd/
│   │   └── ... (15 classes)
│   ├── validation/
│   └── test/
│
├── models/                              ← Saved trained models
│   ├── best_custom_cnn.keras
│   ├── best_vgg16_tl.keras
│   ├── vegetable_custom_cnn_final.keras
│   └── vegetable_vgg16_tl_final.keras
│
└── outputs/                             ← Generated visualisations
    ├── sample_images.png
    ├── class_distribution.png
    ├── split_distribution.png
    ├── pixel_intensity.png
    ├── augmentation_samples.png
    ├── cnn_training_curves.png
    ├── vgg16_training_curves.png
    ├── confusion_matrix_cnn.png
    ├── confusion_matrix_vgg16.png
    ├── model_comparison.png
    ├── per_class_f1.png
    └── sample_predictions.png
```

---

## 🛠️ Tech Stack

| Library | Version | Purpose |
|---------|---------|---------|
| Python | 3.10 | Core language |
| TensorFlow / Keras | 2.x | Model building & training |
| NumPy | 1.24+ | Numerical operations |
| Pandas | 2.0+ | Data analysis |
| Matplotlib | 3.7+ | Visualisation |
| Seaborn | 0.12+ | Statistical plots |
| Scikit-learn | 1.3+ | Metrics & evaluation |
| Pillow | 10.0+ | Image processing |
| OpenCV | 4.8+ | Image utilities |

---

## 🔮 Future Improvements

- [ ] Deploy as a **Streamlit web app** for live vegetable classification
- [ ] Apply **Grad-CAM** to visualise what regions the CNN focuses on
- [ ] Experiment with **EfficientNetB3** for better accuracy-to-parameter ratio
- [ ] Extend dataset with **diseased / damaged vegetables** for quality grading (fresh vs spoiled)
- [ ] Build a **REST API** using FastAPI + Docker for production deployment
- [ ] Add **mobile-optimised model** using MobileNetV2 for edge deployment

---

## 👤 Author

**Dinesh Naidu T**  
B.Tech — Electrical & Electronics Engineering  
Sri Venkateswara Institute of Technology (JNTUA), 2025  

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?style=flat&logo=linkedin)](https://linkedin.com/in/dineshnaiduprofile/)
[![GitHub](https://img.shields.io/badge/GitHub-Portfolio-black?style=flat&logo=github)](https://github.com/Thummalapalli0084/PROJECTS)
[![Email](https://img.shields.io/badge/Email-Contact-red?style=flat&logo=gmail)](mailto:dineshnaiduthummalapalli@gmail.com)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
⭐ If you found this project useful, please consider giving it a star!
</div>
