import java.util.StringJoiner;
import java.util.stream.Collectors;

class ModelListener {
  void onAddVertex(int vId, PVector vertex) {
  }
  void onAddFace(int fId, ArrayList<PVector> face) {
  }
  void onRemoveVertex(int vId, PVector vertex) {
  }
  void onRemoveFace(int fId) {
  }
  void onSelectVertex(int vId) {
  }
  void onDeselectVertex(int vId) {
  }
  void onChangeVertex(int vId, PVector prev, PVector v) {
  }
  void onChangeFace(int fId, ArrayList<PVector> face) {
  }
}

class Model {
  int vIdCounter = 1;
  HashMap<Integer, PVector> vertices = new HashMap<>();
  int fIdCounter = 1;
  HashMap<Integer, ArrayList<Integer>> faces = new HashMap<>();
  ArrayList<Integer> selectedVIds = new ArrayList();
  HashMap<Integer, HashSet<Integer>> vertexFaces = new HashMap<>();
  ModelListener listener = new ModelListener();

  int addVertex(PVector v) {
    int vId = this.vIdCounter;
    this.vertices.put(vId, v);
    this.vertexFaces.put(vId, new HashSet<>());
    this.vIdCounter++;
    this.listener.onAddVertex(vId, v);
    return vId;
  }

  int addFace(ArrayList<Integer> f) {
    int fId = this.fIdCounter;
    this.faces.put(this.fIdCounter, f);
    for (int vId : f) {
      this.vertexFaces.get(vId).add(fId);
    }
    this.fIdCounter++;
    ArrayList<PVector> face = new ArrayList<>();
    for (int vId : f) {
      face.add(this.vertices.get(vId));
    }
    this.listener.onAddFace(fId, face);
    return fId;
  }

  void removeVertex(int vId) {
    for (int fId : this.vertexFaces.get(vId).toArray(new Integer[0])) {
      this.removeFace(fId);
    }
    PVector v = this.vertices.remove(vId);
    this.deselectVertex(vId);
    this.listener.onRemoveVertex(vId, v);
  }

  void removeFace(int fId) {
    ArrayList<Integer> face =  this.faces.remove(fId);
    for (int vId : face) {
      this.vertexFaces.get(vId).remove(fId);
    }
    this.listener.onRemoveFace(fId);
  }

  void selectVertex(int vId) {
    this.selectedVIds.add(vId);
    this.listener.onSelectVertex(vId);
  }

  void deselectVertex(int vId) {
    this.selectedVIds.remove((Integer)vId);
    this.listener.onDeselectVertex(vId);
  }

  void changeVertex(int vId, PVector v) {
    PVector prev = this.vertices.put(vId, v);
    this.listener.onChangeVertex(vId, prev, v);
    for (int fId : this.vertexFaces.get(vId)) {
      ArrayList<Integer> f = this.faces.get(fId);
      ArrayList<PVector> face = new ArrayList<>();
      for (int vId2 : f) {
        face.add(this.vertices.get(vId2));
      }
      this.listener.onChangeFace(fId, face);
    }
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
}

void encodeModel(Model m, String[] lines) {
  ArrayList<PVector> vertices = new ArrayList<>();
  ArrayList<ArrayList<Integer>> faces = new ArrayList<>();

  for (String line : lines) {
    String[] tokens = line.split(" ");
    if (tokens[0].equals("v")) {
      PVector v = new PVector(Float.parseFloat(tokens[1]), Float.parseFloat(tokens[2]), Float.parseFloat(tokens[3]));
      vertices.add(v);
    } else if (tokens[0].equals("f")) {
      ArrayList<Integer> f = new ArrayList<>();
      for (int i = 1; i < tokens.length; i++) {
        f.add(Integer.parseInt(tokens[i].split("/")[0]));
      }
      faces.add(f);
    }
  }

  if (vertices.size() > 0) {
    PVector min = new PVector(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    PVector max = new PVector(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE);
    for (PVector v : vertices) {
      min.x = Math.min(min.x, v.x);
      min.y = Math.min(min.y, v.y);
      min.z = Math.min(min.z, v.z);
      max.x = Math.max(max.x, v.x);
      max.y = Math.max(max.y, v.y);
      max.z = Math.max(max.z, v.z);
    }
    PVector center = PVector.sub(max, min);
    float scale = Math.max(Math.max(center.x, center.y), center.z) / 100;
    for (PVector v : vertices) {
      v.sub(min).div(scale);
    }
  }

  for (PVector v : vertices) {
    m.addVertex(v);
  }

  for (ArrayList<Integer> f : faces) {
    m.addFace(f);
  }
}
