# after arecord foo.wav
curl -F "file=@foo.wav" http://127.0.0.1:5000/whisper
