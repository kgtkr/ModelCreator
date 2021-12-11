import java.util.StringJoiner;

class Model {
  int vIdCounter = 1;
  HashMap<Integer, PVector> vertices = new HashMap<>();
  int fIdCounter = 1;
  HashMap<Integer, ArrayList<Integer>> faces = new HashMap<>();
  ArrayList<Integer> selectedVIds = new ArrayList();

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
    for (PVector v : this.vertices.values()) {
      push();
      pushMatrix();
      translate(v.x, v.y, v.z);
      fill(100, 100, 100);
      noStroke();
      sphere(cameraController.absoluteScale());
      popMatrix();
      pop();
    }

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

  int addVertex(PVector v) {
    int vId = this.vIdCounter;
    this.vertices.put(this.vIdCounter, v);
    this.vIdCounter++;
    return vId;
  }

  int addFace() {
    if (this.selectedVIds.size() < 3) {
      return -1;
    }

    ArrayList<Integer> vIds = new ArrayList<>(this.selectedVIds);

    int fId = this.fIdCounter;
    this.faces.put(fId, vIds);
    this.fIdCounter++;
    return fId;
  }

  void removeVertices() {
    for (int vId : this.selectedVIds) {
      this.vertices.remove(vId);
      for (int fId : this.faces.keySet()) {
        ArrayList<Integer> f = this.faces.get(fId);
        f.remove(vId);
      }
    }

    this.selectedVIds.clear();
  }

  void moveVertices(PVector v) {
    for (int vId : this.selectedVIds) {
      PVector v1 = this.vertices.get(vId);
      PVector v2 = v1.copy().add(v);
      this.vertices.put(vId, v2);
    }
  }

  void toggleSelectedVertex(boolean multipleSelect, int vId) {
    if (!multipleSelect) {
      this.selectedVIds.clear();
    }

    if (this.selectedVIds.contains(vId)) {
      this.selectedVIds.remove(vId);
    } else {
      this.selectedVIds.add(vId);
    }
  }

  void clearSelectedVertices() {
    this.selectedVIds.clear();
  }

  void drawSelectedVertices(int hoverdVId) {
    for (int selectedVId : this.selectedVIds) {
      PVector v = model.vertices.get(selectedVId);
      push();
      pushMatrix();
      translate(v.x, v.y, v.z);
      if (selectedVId != hoverdVId) {
        fill(255, 0, 0);
      } else {
        fill(255, 255, 0);
      }
      noStroke();
      sphere(5 * cameraController.absoluteScale());
      popMatrix();
      pop();
    }
  }

  void drawHoverdVertex(int hoverdVId) {
    if (!selectedVIds.contains(hoverdVId)) {
      PVector v = model.vertices.get(hoverdVId);
      push();
      pushMatrix();
      translate(v.x, v.y, v.z);
      fill(150, 150, 150);
      noStroke();
      sphere(5 * cameraController.absoluteScale());
      popMatrix();
      pop();
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
        f.add(Integer.parseInt(tokens[i].split("/")[0]));
      }
      m.faces.put(m.fIdCounter, f);
      m.fIdCounter++;
    }
  }
  return m;
}
