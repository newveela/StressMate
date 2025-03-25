import tensorflow as tf
from flask import Flask, request, jsonify
import pandas as pd
import pickle

# Load the TensorFlow Model and Scaler
model = tf.keras.models.load_model('model.h5')
with open('scaler.pkl', 'rb') as f:
    scaler = pickle.load(f)

# Initialize Flask App
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Parse input JSON data
        json_ = request.json
        query_df = pd.DataFrame(json_)

        # Scale the input data
        query = scaler.transform(query_df)

        # Make predictions
        prediction = model.predict(query)
        predicted_class = prediction.argmax(axis=1)  # Class with highest probability

        return jsonify({'prediction': predicted_class.tolist()})
    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    app.run(port=5000, debug=True)
