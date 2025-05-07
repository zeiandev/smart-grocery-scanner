from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import easyocr
import numpy as np
import cv2
import os
import gc
from predict import predict_items, preprocess_image
from memory_monitor import start_memory_monitor

# Start memory monitoring in background
start_memory_monitor()

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=False)

# Lazy-load model and vectorizer
def get_model():
    if not hasattr(get_model, "model") or not hasattr(get_model, "vectorizer"):
        base_dir = os.path.dirname(__file__)
        get_model.model = joblib.load(os.path.join(base_dir, "model.joblib"))
        get_model.vectorizer = joblib.load(os.path.join(base_dir, "vectorizer.joblib"))
        print("✅ Model and vectorizer loaded.")
    return get_model.model, get_model.vectorizer

# Lazy-load EasyOCR reader
def get_reader():
    if not hasattr(get_reader, "reader"):
        get_reader.reader = easyocr.Reader(['en'], gpu=False)
    return get_reader.reader

@app.route('/')
def home():
    return "Smart Grocery Scanner Backend is running!"

@app.route('/scan', methods=['POST', 'OPTIONS'])
def scan_receipt():
    if request.method == 'OPTIONS':
        response = jsonify({'message': 'CORS preflight passed'})
        response.headers.add("Access-Control-Allow-Origin", "*")
        response.headers.add("Access-Control-Allow-Headers", "Content-Type")
        response.headers.add("Access-Control-Allow-Methods", "POST, OPTIONS")
        return response, 200

    print("✅ Received POST to /scan — sending dummy response.")

    return jsonify({
        'items_detected': [
            {'item': 'Milk', 'days_left': 3},
            {'item': 'Eggs', 'days_left': 5}
        ]
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
