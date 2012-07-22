
// Generates four chunks
Compucius.generateChunk = function(chunkId) {
  if (chunkId >= 4) {
    doneGeneratingChunks();
  }
  var s;
  for(s=""; s < 20; s++) {
    s += chunkId;
  }
  emitChunk(chunkId, s);
};


Compucius.map = function(chunkId, chunk) {
  for (var i = 0; i < chunk.length; i++) {
    emitMapItem(chunk[i], 1);
  }
};

Compucius.reduce = function(key, values) {
  s = 0;
  for (var i = 0; i < values.length; i++) {
    s += values[i];
  }
  emitReduction(key, s);
};