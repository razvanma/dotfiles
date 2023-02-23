# after arecord foo.wav
curl -F "file=@foo.wav" http://172.17.0.2:5000/whisper
