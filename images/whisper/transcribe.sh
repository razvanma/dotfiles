rm transcript.txt
for file in *.wav; do
  curl -F file=@$file http://172.17.0.2:5000/whisper -o $file.txt
  cat $file.txt | jq .results[0].transcript | sed 's/"//g' >> transcript.txt
done

