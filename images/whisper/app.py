# https://lablab.ai/t/whisper-api-flask-docker

from flask import Flask, abort, request, jsonify
from flask_cors import CORS
from tempfile import NamedTemporaryFile
import whisper
import torch

# Check if NVIDIA GPU is available
print("GPU availability:")
print(torch.cuda.is_available())
DEVICE = "cuda" if torch.cuda.is_available() else "cpu"

# Load the Whisper model:
model = whisper.load_model("medium", device=DEVICE)

app = Flask(__name__)
CORS(app, resources={r"/whisper": {"origins": "http://localhost:8001"}})


@app.route("/")
def hello():
    return "Whisper Hello World!"


@app.route('/whisper', methods=['POST'])
def handler():
    if not request.files:
        # If the user didn't submit any files, return a 400 (Bad Request) error.
        abort(400)

    # For each file, let's store the results in a list of dictionaries.
    results = []

    # Loop over every file that the user submitted.
    for filename, handle in request.files.items():
        # Create a temporary file.
        # The location of the temporary file is available in `temp.name`.
        temp = NamedTemporaryFile()
        # Write the user's uploaded file to the temporary file.
        # The file will get deleted when it drops out of scope.
        handle.save(temp)
        # Let's get the transcript of the temporary file.
        result = model.transcribe(temp.name)
        # Now we can store the result object for this file.
        no_speech_prob = 1.0
        if result.get('segments', None):
            no_speech_prob = min(
                    [x['no_speech_prob'] for x in result['segments']])
        results.append({
            'filename': filename,
            'transcript': result['text'],
            'message': 'Transcribed',
            'no_speech_prob': no_speech_prob,
        })
    return jsonify(results)


