class DataParser {
  HashMap<String, Vector> data;
  
  DataParser() {
    data = new HashMap<String, Vector>();
  }
  
  void parse(String s) {
    data.clear();
    s = s.substring(1, s.length() - 1);
    String entries[] = s.split("\\),");                              /////WARNING : ")," considered as entry end
    for (int i = 0; i < entries.length; i++) {
      String keyValue[] = entries[i].split(":");
      data.put(keyValue[0], new Vector(keyValue[1]));
    }
  }
}
