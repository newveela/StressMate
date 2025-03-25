import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, Dropout
from tensorflow.keras.optimizers import Adam
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

# Dataset and Parameters
pathdf = 'Stress-Lysis.csv'
Yvar = 'Stress Level'
test_size = 0.30
seed = 49

# Load Dataset
df = pd.read_csv(pathdf)
df = df.drop(['Humidity'], axis=1)

# Split Data
X = df.drop(Yvar, axis=1)
y = pd.get_dummies(df[Yvar])  # One-hot encoding for categorical target variable
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=test_size, stratify=df[Yvar], random_state=seed)

# Scale Data
scaler = StandardScaler()
X_train = scaler.fit_transform(X_train)
X_test = scaler.transform(X_test)

# Save the scaler for use in the API
import pickle
with open('scaler.pkl', 'wb') as f:
    pickle.dump(scaler, f)

# Define the TensorFlow Model
model = Sequential([
    Dense(64, input_shape=(X_train.shape[1],), activation='relu'),
    Dropout(0.3),
    Dense(32, activation='relu'),
    Dense(y_train.shape[1], activation='softmax')  # Output layer for classification
])

# Compile the Model
model.compile(optimizer=Adam(learning_rate=0.001),
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train the Model
model.fit(X_train, y_train, epochs=50, batch_size=16, validation_split=0.2)

# Save the Model
model.save('model.h5')
print("Model and scaler saved successfully.")
