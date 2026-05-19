"""
ANN Capstone Project: Airline Passenger Satisfaction Prediction
Dataset: Airline Passenger Satisfaction (Kaggle)
Author: Dinesh Naidu T
"""

# ============================================================
# 1. IMPORTS
# ============================================================
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
import warnings
warnings.filterwarnings('ignore')

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder, StandardScaler
from sklearn.metrics import (classification_report, confusion_matrix,
                             accuracy_score, roc_auc_score, roc_curve)

import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout, BatchNormalization
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from tensorflow.keras.optimizers import Adam

# Reproducibility
np.random.seed(42)
tf.random.set_seed(42)

print("All libraries imported successfully.")
print(f"TensorFlow version: {tf.__version__}")

# ============================================================
# 2. LOAD DATA  (using synthetic data that mirrors the real dataset)
# ============================================================
# NOTE: In your actual notebook, replace this block with:
#   df = pd.read_csv("train.csv")
#   df_test = pd.read_csv("test.csv")
# Download from: https://www.kaggle.com/datasets/teejmahal20/airline-passenger-satisfaction

np.random.seed(42)
n = 5000

classes        = np.random.choice(['Business', 'Eco', 'Eco Plus'], n, p=[0.48, 0.45, 0.07])
travel_type    = np.random.choice(['Business travel', 'Personal Travel'], n, p=[0.69, 0.31])
gender         = np.random.choice(['Male', 'Female'], n)
customer_type  = np.random.choice(['Loyal Customer', 'disloyal Customer'], n, p=[0.82, 0.18])
age            = np.random.randint(7, 85, n)
flight_distance= np.random.randint(31, 4983, n)
departure_delay= np.abs(np.random.normal(15, 30, n)).astype(int)
arrival_delay  = departure_delay + np.random.randint(-5, 10, n)
arrival_delay  = np.clip(arrival_delay, 0, None)

service_cols = ['Inflight wifi service', 'Departure/Arrival time convenient',
                'Ease of Online booking', 'Gate location', 'Food and drink',
                'Online boarding', 'Seat comfort', 'Inflight entertainment',
                'On-board service', 'Leg room service', 'Baggage handling',
                'Checkin service', 'Inflight service', 'Cleanliness']

service_ratings = {col: np.random.randint(0, 6, n) for col in service_cols}

df = pd.DataFrame({
    'Gender': gender,
    'Customer Type': customer_type,
    'Age': age,
    'Type of Travel': travel_type,
    'Class': classes,
    'Flight Distance': flight_distance,
    **service_ratings,
    'Departure Delay in Minutes': departure_delay,
    'Arrival Delay in Minutes': arrival_delay
})

# Realistic target: business class + business travel -> more satisfied
score = (
    (df['Class'] == 'Business').astype(int) * 2 +
    (df['Type of Travel'] == 'Business travel').astype(int) +
    (df['Customer Type'] == 'Loyal Customer').astype(int) +
    df[service_cols].mean(axis=1) / 3 -
    (df['Departure Delay in Minutes'] > 30).astype(int)
)
prob = 1 / (1 + np.exp(-score + 3))
df['satisfaction'] = np.where(np.random.rand(n) < prob, 'satisfied', 'neutral or dissatisfied')

print(f"\nDataset shape: {df.shape}")
print(df['satisfaction'].value_counts())

# ============================================================
# 3. EXPLORATORY DATA ANALYSIS (EDA)
# ============================================================
print("\n--- EDA ---")
print(df.head())
print("\nData Types:\n", df.dtypes)
print("\nMissing Values:\n", df.isnull().sum())
print("\nDescriptive Statistics:\n", df.describe())

fig, axes = plt.subplots(2, 3, figsize=(16, 10))
fig.suptitle('Airline Passenger Satisfaction — EDA', fontsize=16, fontweight='bold')

# 1. Target distribution
colors = ['#2196F3', '#FF5722']
df['satisfaction'].value_counts().plot(kind='bar', ax=axes[0,0], color=colors, edgecolor='black')
axes[0,0].set_title('Satisfaction Distribution')
axes[0,0].set_xlabel('Satisfaction')
axes[0,0].set_ylabel('Count')
axes[0,0].tick_params(axis='x', rotation=0)
for bar in axes[0,0].patches:
    axes[0,0].text(bar.get_x() + bar.get_width()/2, bar.get_height() + 20,
                   f'{int(bar.get_height())}', ha='center', va='bottom', fontsize=10)

# 2. Satisfaction by Class
class_sat = pd.crosstab(df['Class'], df['satisfaction'], normalize='index') * 100
class_sat.plot(kind='bar', ax=axes[0,1], color=colors, edgecolor='black')
axes[0,1].set_title('Satisfaction Rate by Travel Class')
axes[0,1].set_xlabel('Class')
axes[0,1].set_ylabel('Percentage (%)')
axes[0,1].tick_params(axis='x', rotation=0)
axes[0,1].legend(loc='upper right', fontsize=8)

# 3. Age Distribution
axes[0,2].hist(df[df['satisfaction']=='satisfied']['Age'], bins=30, alpha=0.7,
               color='#2196F3', label='Satisfied')
axes[0,2].hist(df[df['satisfaction']=='neutral or dissatisfied']['Age'], bins=30, alpha=0.7,
               color='#FF5722', label='Dissatisfied')
axes[0,2].set_title('Age Distribution by Satisfaction')
axes[0,2].set_xlabel('Age')
axes[0,2].set_ylabel('Count')
axes[0,2].legend()

# 4. Service Ratings Heatmap (mean by satisfaction)
service_means = df.groupby('satisfaction')[service_cols[:7]].mean().T
im = axes[1,0].imshow(service_means.values, cmap='RdYlGn', aspect='auto', vmin=1, vmax=5)
axes[1,0].set_xticks([0, 1])
axes[1,0].set_xticklabels(['Dissatisfied', 'Satisfied'], fontsize=9)
axes[1,0].set_yticks(range(len(service_means.index)))
axes[1,0].set_yticklabels([s[:20] for s in service_means.index], fontsize=7)
axes[1,0].set_title('Avg Service Ratings by Satisfaction')
plt.colorbar(im, ax=axes[1,0])

# 5. Flight Distance
axes[1,1].boxplot([df[df['satisfaction']=='satisfied']['Flight Distance'],
                   df[df['satisfaction']=='neutral or dissatisfied']['Flight Distance']],
                  labels=['Satisfied', 'Dissatisfied'], patch_artist=True,
                  boxprops=dict(facecolor='#E3F2FD'),
                  medianprops=dict(color='red', linewidth=2))
axes[1,1].set_title('Flight Distance vs Satisfaction')
axes[1,1].set_ylabel('Flight Distance (miles)')

# 6. Departure Delay
axes[1,2].boxplot([df[df['satisfaction']=='satisfied']['Departure Delay in Minutes'],
                   df[df['satisfaction']=='neutral or dissatisfied']['Departure Delay in Minutes']],
                  labels=['Satisfied', 'Dissatisfied'], patch_artist=True,
                  boxprops=dict(facecolor='#FFEBEE'),
                  medianprops=dict(color='blue', linewidth=2))
axes[1,2].set_title('Departure Delay vs Satisfaction')
axes[1,2].set_ylabel('Delay (Minutes)')
axes[1,2].set_ylim(0, 150)

plt.tight_layout()
plt.savefig('/home/claude/eda_plots.png', dpi=150, bbox_inches='tight')
plt.close()
print("EDA plots saved.")

# Correlation Heatmap
plt.figure(figsize=(14, 10))
numeric_df = df.select_dtypes(include=[np.number])
corr = numeric_df.corr()
mask = np.triu(np.ones_like(corr, dtype=bool))
sns.heatmap(corr, mask=mask, annot=True, fmt='.2f', cmap='coolwarm',
            center=0, linewidths=0.5, annot_kws={"size": 7})
plt.title('Feature Correlation Heatmap', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('/home/claude/correlation_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Correlation heatmap saved.")

# ============================================================
# 4. DATA CLEANING & PREPROCESSING
# ============================================================
print("\n--- Data Cleaning ---")

# 4.1 Handle Missing Values
print(f"Missing before: {df.isnull().sum().sum()}")
df['Arrival Delay in Minutes'] = df['Arrival Delay in Minutes'].fillna(df['Arrival Delay in Minutes'].median())
print(f"Missing after: {df.isnull().sum().sum()}")

# 4.2 Remove Outliers (IQR method on delay columns)
def remove_outliers_iqr(dataframe, column):
    Q1 = dataframe[column].quantile(0.25)
    Q3 = dataframe[column].quantile(0.75)
    IQR = Q3 - Q1
    lower = Q1 - 1.5 * IQR
    upper = Q3 + 1.5 * IQR
    return dataframe[(dataframe[column] >= lower) & (dataframe[column] <= upper)]

before = len(df)
df = remove_outliers_iqr(df, 'Departure Delay in Minutes')
df = remove_outliers_iqr(df, 'Arrival Delay in Minutes')
df = remove_outliers_iqr(df, 'Flight Distance')
print(f"Rows before outlier removal: {before} | After: {len(df)} | Removed: {before - len(df)}")
df.reset_index(drop=True, inplace=True)

# 4.3 Encode Categorical Variables
le = LabelEncoder()
cat_cols = ['Gender', 'Customer Type', 'Type of Travel', 'Class']
for col in cat_cols:
    df[col] = le.fit_transform(df[col])

# Target encoding
df['satisfaction'] = (df['satisfaction'] == 'satisfied').astype(int)
print(f"\nTarget distribution after encoding:\n{df['satisfaction'].value_counts()}")

# 4.4 Feature / Target Split
X = df.drop('satisfaction', axis=1)
y = df['satisfaction']

# 4.5 Train-Test Split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2,
                                                      random_state=42, stratify=y)
print(f"\nTrain size: {X_train.shape} | Test size: {X_test.shape}")

# 4.6 Feature Scaling
scaler = StandardScaler()
X_train_sc = scaler.fit_transform(X_train)
X_test_sc  = scaler.transform(X_test)
print("Feature scaling applied.")

# ============================================================
# 5. ANN MODEL BUILDING
# ============================================================
print("\n--- ANN Model ---")

model = Sequential([
    Dense(128, activation='relu', input_shape=(X_train_sc.shape[1],)),
    BatchNormalization(),
    Dropout(0.3),

    Dense(64, activation='relu'),
    BatchNormalization(),
    Dropout(0.2),

    Dense(32, activation='relu'),
    Dropout(0.2),

    Dense(1, activation='sigmoid')
])

model.compile(optimizer=Adam(learning_rate=0.001),
              loss='binary_crossentropy',
              metrics=['accuracy'])

model.summary()

# Callbacks
early_stop = EarlyStopping(monitor='val_loss', patience=10, restore_best_weights=True)
reduce_lr  = ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-6)

# Training
history = model.fit(
    X_train_sc, y_train,
    epochs=100,
    batch_size=32,
    validation_split=0.2,
    callbacks=[early_stop, reduce_lr],
    verbose=1
)

# ============================================================
# 6. EVALUATION
# ============================================================
print("\n--- Evaluation ---")

y_pred_prob = model.predict(X_test_sc).flatten()
y_pred      = (y_pred_prob >= 0.5).astype(int)

acc    = accuracy_score(y_test, y_pred)
roc    = roc_auc_score(y_test, y_pred_prob)
report = classification_report(y_test, y_pred, target_names=['Dissatisfied', 'Satisfied'])
cm     = confusion_matrix(y_test, y_pred)

print(f"\nAccuracy : {acc:.4f}")
print(f"ROC-AUC  : {roc:.4f}")
print(f"\nClassification Report:\n{report}")

# ============================================================
# 7. VISUALIZATION — Training History + Evaluation
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('ANN Model — Training & Evaluation Results', fontsize=15, fontweight='bold')

# Training Loss
axes[0,0].plot(history.history['loss'], label='Train Loss', color='#2196F3', linewidth=2)
axes[0,0].plot(history.history['val_loss'], label='Val Loss', color='#FF5722',
               linewidth=2, linestyle='--')
axes[0,0].set_title('Model Loss')
axes[0,0].set_xlabel('Epoch')
axes[0,0].set_ylabel('Loss')
axes[0,0].legend()
axes[0,0].grid(alpha=0.3)

# Training Accuracy
axes[0,1].plot(history.history['accuracy'], label='Train Acc', color='#4CAF50', linewidth=2)
axes[0,1].plot(history.history['val_accuracy'], label='Val Acc', color='#FF9800',
               linewidth=2, linestyle='--')
axes[0,1].set_title('Model Accuracy')
axes[0,1].set_xlabel('Epoch')
axes[0,1].set_ylabel('Accuracy')
axes[0,1].legend()
axes[0,1].grid(alpha=0.3)

# Confusion Matrix
sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', ax=axes[1,0],
            xticklabels=['Dissatisfied', 'Satisfied'],
            yticklabels=['Dissatisfied', 'Satisfied'],
            linewidths=1, linecolor='gray')
axes[1,0].set_title('Confusion Matrix')
axes[1,0].set_xlabel('Predicted')
axes[1,0].set_ylabel('Actual')

# ROC Curve
fpr, tpr, _ = roc_curve(y_test, y_pred_prob)
axes[1,1].plot(fpr, tpr, color='#9C27B0', linewidth=2.5, label=f'AUC = {roc:.3f}')
axes[1,1].plot([0,1], [0,1], 'k--', linewidth=1, label='Random Classifier')
axes[1,1].fill_between(fpr, tpr, alpha=0.1, color='#9C27B0')
axes[1,1].set_title('ROC-AUC Curve')
axes[1,1].set_xlabel('False Positive Rate')
axes[1,1].set_ylabel('True Positive Rate')
axes[1,1].legend()
axes[1,1].grid(alpha=0.3)

plt.tight_layout()
plt.savefig('/home/claude/model_evaluation.png', dpi=150, bbox_inches='tight')
plt.close()
print("\nEvaluation plots saved.")
print(f"\nFinal Accuracy: {acc*100:.2f}%")
print(f"Final ROC-AUC: {roc:.4f}")
print("\nProject complete!")
