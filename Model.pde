import java.util.StringJoiner;

class Model {
  int vIdCounter = 1;
  HashMap<Integer, PVector> vertices = new HashMap<>();
  int fIdCounter = 1;
  HashMap<Integer, ArrayList<Integer>> faces = new HashMap<>();
  ArrayList<Integer> selectedVIds = new ArrayList();
  HashMap<Integer, HashSet<Integer>> vertexFaces = new HashMap<>();

  int addVertex(PVector v) {
    int vId = this.vIdCounter;
    this.vertices.put(vId, v);
    this.vertexFaces.put(vId, new HashSet<>());
    this.vIdCounter++;
    return vId;
  }

  int addFace(ArrayList<Integer> f) {
    int fId = this.fIdCounter;
    this.faces.put(this.fIdCounter, f);
    for (int vId : f) {
      this.vertexFaces.get(vId).add(fId);
    }
    this.fIdCounter++;
    return fId;
  }

  void removeFace(int fId) {
    ArrayList<Integer> face =  this.faces.remove(fId);
    for (int vId : face) {
      this.vertexFaces.get(vId).remove(fId);
    }
  }

  void removeVertex(int vId) {
    for (int fId : this.vertexFaces.get(vId)) {
      this.removeFace(fId);
    }
    this.vertices.remove(vId);
    this.deselectVertex(vId);
  }

  void selectVertex(int vId) {
    this.selectedVIds.add(vId);
  }

  void deselectVertex(int vId) {
    this.selectedVIds.remove((Integer)vId);
  }

  void changeVertex(int vId, PVector v) {
    this.vertices.put(vId, v);
  }

  int addFaceWithSelectedVertices() {
    if (this.selectedVIds.size() < 3) {
      return -1;
    }

    ArrayList<Integer> vIds = new ArrayList<>(this.selectedVIds);
    return this.addFace(vIds);
  }

  void removeSelectedVertices() {
    for (int vId : this.selectedVIds.toArray(new Integer[0])) {
      this.removeVertex(vId);
    }
  }

  void moveVertices(PVector v) {
    for (int vId : this.selectedVIds) {
      PVector v1 = this.vertices.get(vId);
      PVector v2 = v1.copy().add(v);
      this.changeVertex(vId, v2);
    }
  }

  void toggleSelectedVertex(boolean multipleSelect, int vId) {
    if (!multipleSelect) {
      this.clearSelectedVertices();
    }

    if (this.selectedVIds.contains(vId)) {
      this.deselectVertex(vId);
    } else {
      this.selectVertex(vId);
    }
  }

  void clearSelectedVertices() {
    for (int vId1 : this.selectedVIds.toArray(new Integer[0])) {
      this.deselectVertex(vId1);
    }
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
}

Model encodeModel(String[] lines, Model m) {
  for (String line : lines) {
    String[] tokens = line.split(" ");
    if (tokens[0].equals("v")) {
      PVector v = new PVector(Float.parseFloat(tokens[1]), Float.parseFloat(tokens[2]), Float.parseFloat(tokens[3]));
      m.addVertex(v);
    } else if (tokens[0].equals("f")) {
      ArrayList<Integer> f = new ArrayList<>();
      for (int i = 1; i < tokens.length; i++) {
        f.add(Integer.parseInt(tokens[i].split("/")[0]));
      }
      m.addFace(f);
    }
  }
  return m;
}
