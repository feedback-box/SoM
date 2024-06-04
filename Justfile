deploy:   
  gradio deploy


cp cId file="app.py":
  docker cp {{file}} {{cId}}:/app

som cid="QmPSwBPP1fBxTt56ZN6ZiqPo1gHYQ8iHRVaiEAn9k9ycWd": 
  bacalhau docker run --download \
  --wait \
  --memory '12Gb' \
  --gpu 1 \
  --input https://gateway.lighthouse.storage/ipfs/{{cid}}:/inputs  \
  ghcr.io/playback-network/som:v0.4.0 -- '/inputs' 2.6

hive tag="v0.4.0-rc1": 
  hive run github.com/playback-network/som:{{tag}} -i 