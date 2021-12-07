import java.util.StringJoiner;

class Model {
  int vIdCounter = 1;
  HashMap<Integer, PVector> vertices = new HashMap<>();
  int fIdCounter = 1;
  HashMap<Integer, ArrayList<Integer>> faces = new HashMap<>();

  String[] decode() {
    ArrayList<String> lines = new ArrayList();
    HashMap<Integer, Integer> vIdMap = new HashMap<>();
    int i = 1;
    for (int vId : this.vertices.keySet()) {
      vIdMap.put(vId, i);
      i++;
      PVector v = this.vertices.get(vId);
      lines.add(String.format("v %f %f %f", v.x, v.y, v.z));
    }

    for (int fId : this.faces.keySet()) {
      ArrayList<Integer> f = this.faces.get(fId);
      StringJoiner sj = new StringJoiner(" ");
      sj.add("f");
      for (int vId : f) {
        sj.add(vIdMap.get(vId).toString());
      }
      lines.add(sj.toString());
    }
    return lines.toArray(new String[0]);
  }

  void draw() {
    fill(255, 255, 255);
    for (ArrayList<Integer> face : this.faces.values()) {
      beginShape();
      for (int vId : face) {
        PVector v = this.vertices.get(vId);
        vertex(v.x, v.y, v.z);
      }
      endShape(CLOSE);
    }
  }

  void normalize() {
    PVector min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    PVector max = new PVector(Float.MIN_VALUE, Float.MIN_VALUE, Float.MIN_VALUE);
    for (PVector v : this.vertices.values()) {
      min.x = Math.min(min.x, v.x);
      min.y = Math.min(min.y, v.y);
      min.z = Math.min(min.z, v.z);
      max.x = Math.max(max.x, v.x);
      max.y = Math.max(max.y, v.y);
      max.z = Math.max(max.z, v.z);
    }
    PVector center = PVector.sub(max, min);
    float scale = Math.max(Math.max(center.x, center.y), center.z) / 100;
    for (PVector v : this.vertices.values()) {
      v.x = (v.x - min.x) / scale;
      v.y = (v.y - min.y) / scale;
      v.z = (v.z - min.z) / scale;
    }
  }
}

Model encodeModel(String[] lines) {
  Model m = new Model();
  for (String line : lines) {
    String[] tokens = line.split(" ");
    if (tokens[0].equals("v")) {
      PVector v = new PVector(Float.parseFloat(tokens[1]), Float.parseFloat(tokens[2]), Float.parseFloat(tokens[3]));
      m.vertices.put(m.vIdCounter, v);
      m.vIdCounter++;
    } else if (tokens[0].equals("f")) {
      ArrayList<Integer> f = new ArrayList<>();
      for (int i = 1; i < tokens.length; i++) {
        f.add(Integer.parseInt(tokens[i]));
      }
      m.faces.put(m.fIdCounter, f);
      m.fIdCounter++;
    }
  }
  return m;
}
