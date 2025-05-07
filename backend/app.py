from flask import Flask, request, jsonify
from flask_cors import CORS
import joblib
import easyocr
import numpy as np
import cv2
import os
from predict import predict_items, preprocess_image
from memory_monitor import start_memory_monitor
import gc

# force Git to track this file

start_memory_monitor()

app = Flask(__name__)
CORS(app)

# Lazy-load model and vectorizer
def get_model():
    if not hasattr(get_model, "model") or not hasattr(get_model, "vectorizer"):
        get_model.model = joblib.load("model.joblib")
        get_model.vectorizer = joblib.load("vectorizer.joblib")
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

@app.route('/scan', methods=['POST'])
def scan_receipt():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400

    file = request.files['file']
    image_bytes = np.frombuffer(file.read(), np.uint8)
    image = cv2.imdecode(image_bytes, cv2.IMREAD_COLOR)

    if image is None:
        return jsonify({'error': 'Invalid image'}), 400

    # Preprocess image before OCR
    preprocessed = preprocess_image(image)

    # Perform OCR
    reader = get_reader()
    ocr_result = reader.readtext(preprocessed)
    print(f"🔍 OCR Output Length: {len(ocr_result)} lines")

    # Load model and make predictions
    model, vectorizer = get_model()
    predictions = predict_items(ocr_result, model, vectorizer)
    print("✅ Final Predictions:", predictions)

    # Cleanup to free memory
    del image, image_bytes, preprocessed, ocr_result
    gc.collect()

    return jsonify({'items_detected': predictions})

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
