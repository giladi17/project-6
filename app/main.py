from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({"message": "Hello from AUI DevOps Assignment!", "status": "Success"})

@app.route('/health')
def health():
    return jsonify({"status": "Healthy"})

if __name__ == '__main__':
    # מאזין על פורט 8000 כפי שהגדרנו ב-Dockerfile
    app.run(host='0.0.0.0', port=8000)