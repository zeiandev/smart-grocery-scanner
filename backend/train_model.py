import pandas as pd
import joblib
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import Ridge
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import FunctionTransformer

# Load dataset
df = pd.read_csv("dataset.csv")

# Normalize SKU and Product Name for consistency
df["SKU"] = df["SKU"].astype(str).str.replace(" ", "").str.lower()
df["Product Name"] = df["Product Name"].astype(str).str.lower()

# Define features and target
X = df["Product Name"]
y = df["shelf_life_days"]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Define pipeline
pipeline = Pipeline([
    ("vectorizer", TfidfVectorizer(ngram_range=(1, 2), max_features=2000)),
    ("model", Ridge(alpha=1.0))  # Simpler model, good for regression on text
])

# Train model
pipeline.fit(X_train, y_train)

# Evaluate
y_pred = pipeline.predict(X_test)
mse = mean_squared_error(y_test, y_pred)
r2 = r2_score(y_test, y_pred)
cv_scores = cross_val_score(pipeline, X, y, cv=5, scoring="r2")

print(f"✅ Training complete.")
print(f"📊 R² Score: {r2:.4f} ({r2 * 100:.2f}%)")
print(f"📉 MSE: {mse:.2f}")
print(f"🧪 Cross-validated R²: {cv_scores.mean():.4f} ± {cv_scores.std():.4f}")

# Save components
joblib.dump(pipeline.named_steps["model"], "model.joblib")
joblib.dump(pipeline.named_steps["vectorizer"], "vectorizer.joblib")
print("💾 Model saved: model.joblib, vectorizer.joblib")
