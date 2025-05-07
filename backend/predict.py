
import pandas as pd
import joblib
import numpy as np
import re
import cv2
import os

# force Git to track this file

# Load model and vectorizer
base_dir = os.path.dirname(__file__)
model = joblib.load(os.path.join(base_dir, "model.joblib"))
vectorizer = joblib.load(os.path.join(base_dir, "vectorizer.joblib"))

# Load reference product data
df = pd.read_csv("dataset.csv")
df["normalized"] = df["SKU"].str.replace(" ", "").str.lower()
sku_to_name = dict(zip(df["normalized"], df["Product Name"]))
sku_to_shelf_life = dict(zip(df["normalized"], df["shelf_life_days"]))
known_skus = set(sku_to_name.keys())

def clean_ocr_text(text):
    text = text.lower()
    text = re.sub(r"[^a-z0-9]", "", text)
    return text

def find_best_sku_match(raw_sku):
    cleaned = clean_ocr_text(raw_sku)
    tokens = [cleaned[i:i+5] for i in range(len(cleaned)-4)]

    best_match = None
    best_score = 0
    for sku in known_skus:
        score = sum(1 for token in tokens if token in sku)
        if score > best_score:
            best_score = score
            best_match = sku

    return best_match if best_score >= 2 else None

def preprocess_image(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    gray = cv2.bilateralFilter(gray, 11, 17, 17)
    _, thresh = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    return thresh

def predict_items(ocr_result, model, vectorizer):
    detected = []

    ocr_lines = [
        line[1] for line in ocr_result
        if len(line[1]) > 3
        and re.search(r'[a-zA-Z]', line[1])
        and not any(keyword in line[1].lower() for keyword in ["total", "cash", "vat", "amt", "change", "valid", "sales", "invoice", "date"])
    ]

    for raw in ocr_lines:
        match = find_best_sku_match(raw)
        if match:
            name = sku_to_name[match]
            X = vectorizer.transform([name])
            pred_days = int(np.round(model.predict(X)[0]))
            category = "non-food" if any(word in name.lower() for word in ["coil", "soap", "lighter", "cleaner", "pad"]) else "food"

            # Add quantity if repeated
            existing = next((d for d in detected if d["sku"] == match), None)
            if existing:
                existing["quantity"] += 1
            else:
                detected.append({
                    "sku": match,
                    "item": name,
                    "days_left": pred_days,
                    "category": category,
                    "quantity": 1
                })

    return detected
