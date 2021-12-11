import java.util.HashSet;

CameraController cameraController = new CameraController();
boolean pressCtrl;
boolean pressCmd;
boolean pressAlt;
boolean pressShift;
boolean pressSpace;
Model model;
int hoverdVId = -1;
boolean redrawModel = true;
boolean redrawCamera = true;
boolean redrawHover = true;
Quadtree quadtree = new Quadtree();
final float HOVER_R = 5;
PShape facesShape;

void setup() {
  size(1280, 720, P3D);
  facesShape = createShape(GROUP);
  model = new Model();
  model.listener = new ModelListener() {
    PShape createFaceShape(int fId, ArrayList<PVector> vs) {
      PShape p = createShape();
      p.set3D(true);
      p.beginShape();
      p.fill(255, 255, 255);
      p.noStroke();
      for (PVector v : vs) {
        p.vertex(v.x, v.y, v.z);
      }
      p.endShape(CLOSE);
      p.setName(Integer.toString(fId));
      return p;
    }

    @Override void onAddVertex(int vId, PVector v) {
      int[] quadtreeValue = quadtreeValue(v);
      quadtree.insert(quadtreeValue[0], quadtreeValue[1], quadtreeValue[2], quadtreeValue[3], vId);
      redrawModel = true;
    }
    @Override void onAddFace(int fId, ArrayList<PVector> face) {
      facesShape.addChild(createFaceShape(fId, face));
      redrawModel = true;
    }
    @Override void onRemoveVertex(int vId, PVector v) {
      int[] quadtreeValue = quadtreeValue(v);
      quadtree.remove(quadtreeValue[0], quadtreeValue[1], quadtreeValue[2], quadtreeValue[3], vId);
      redrawModel = true;
    }
    @Override void onRemoveFace(int fId) {
      for (int i = 0; i < facesShape.getChildCount(); i++) {
        PShape p = facesShape.getChild(i);
        if (Integer.toString(fId).equals(p.getName())) {
          facesShape.removeChild(i);
          break;
        }
      }
      redrawModel = true;
    }
    @Override void onSelectVertex(int vId) {
      redrawModel = true;
    }
    @Override void onDeselectVertex(int vId) {
      redrawModel = true;
    }
    @Override void onChangeVertex(int vId, PVector prev, PVector vertex) {
      {
        int[] quadtreeValue = quadtreeValue(prev);
        quadtree.remove(quadtreeValue[0], quadtreeValue[1], quadtreeValue[2], quadtreeValue[3], vId);
      }
      {
        int[]  quadtreeValue = quadtreeValue(vertex);
        quadtree.insert(quadtreeValue[0], quadtreeValue[1], quadtreeValue[2], quadtreeValue[3], vId);
      }
      redrawModel = true;
    }
    @Override void onChangeFace(int fId, ArrayList<PVector> face) {
      redrawModel = true;
      for (int i = 0; i < facesShape.getChildCount(); i++) {
        PShape p = facesShape.getChild(i);
        if (Integer.toString(fId).equals(p.getName())) {
          facesShape.removeChild(i);
          facesShape.addChild(createFaceShape(fId, face));

          break;
        }
      }
    }
  };
  encodeModel(model, loadStrings("model.obj"));
}

void draw() {
  translate(width / 2, height / 2);
  if (redrawCamera) {
    calclateQuadtree();
  }
  calclateHoverdVId();
  if (redrawCamera || redrawModel || redrawHover) {
    long start = System.nanoTime();
    background(0);
    sphereDetail(8);
    cameraController.draw();
    drawAxis();
    drawModel();
    if (hoverdVId != -1) {
      if (!model.selectedVIds.contains(hoverdVId)) {
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

    for (int selectedVId : model.selectedVIds) {
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

    redrawCamera = false;
    redrawModel = false;
    redrawHover = false;
    long end = System.nanoTime();
    println("redraw", (end - start) / 1000000.0);
  }
}

int[] quadtreeValue(PVector v1) {
  PVector v2 = cameraController.toScreen(v1);
  v2.add(new PVector(width / 2, height / 2));
  float fx1 = v2.x - HOVER_R;
  float fy1 = v2.y - HOVER_R;
  float fx2 = v2.x + HOVER_R;
  float fy2 = v2.y + HOVER_R;
  int x1 = Integer.min(Integer.max((int) (fx1 / width * quadtree.N), 0), quadtree.N - 1);
  int y1 = Integer.min(Integer.max((int) (fy1 / height * quadtree.N), 0), quadtree.N - 1);
  int x2 = Integer.min(Integer.max((int) (fx2 / width * quadtree.N), 0), quadtree.N - 1);
  int y2 = Integer.min(Integer.max((int) (fy2 / height * quadtree.N), 0), quadtree.N - 1);
  return new int[] { x1, y1, x2, y2 };
}

void calclateQuadtree() {
  long beginTime = System.nanoTime();
  quadtree.clear();

  for (int vId : model.vertices.keySet()) {
    PVector v = model.vertices.get(vId);
    int[] quadtreeValue = quadtreeValue(v);
    quadtree.insert(quadtreeValue[0], quadtreeValue[1], quadtreeValue[2], quadtreeValue[3], vId);
  }
  long endTime = System.nanoTime();
  println("calclateQuadtree", (endTime - beginTime) / 1000000.0);
}

void calclateHoverdVId() {
  int newHoverdVId;
  if (!pressSpace) {
    newHoverdVId = findHoverVId();
  } else {
    newHoverdVId = -1;
  }
  if (newHoverdVId != hoverdVId) {
    hoverdVId = newHoverdVId;
    redrawHover = true;
  }
}

int findHoverVId() {
  int result = -1;
  float zMax = -Float.MAX_VALUE;
  int x = mouseX * quadtree.N / width;
  int y = mouseY * quadtree.N / height;
  ArrayList<Integer> vIds = quadtree.query(x, y);
  for (int vId : vIds) {
    PVector v = model.vertices.get(vId);
    PVector v2 = cameraController.toScreen(v);
    float z = v2.z;
    v2.z = 0;
    float d = PVector.dist(getMouse(), v2);
    if (d < HOVER_R) {
      if (z > zMax) {
        zMax = z;
        result = vId;
      }
    }
  }
  return result;
}

boolean pressControl() {
  return pressCtrl || pressCmd;
}

void drawModel() {
  push();
  lights();
  fill(255, 255, 255);
  strokeWeight(cameraController.absoluteScale());
  stroke(200, 200, 200);
  shape(facesShape);
  pop();
}

void mousePressed() {
  if (pressShift) {
    cameraController.mousePressed();
    redrawCamera = true;
  } else {
    if (pressSpace) {
      PVector v = cameraController.fromScreen(getMouse());
      int vId = model.addVertex(v);
      model.toggleSelectedVertex(pressControl(), vId);
    } else {
      if (hoverdVId != -1) {
        model.toggleSelectedVertex(pressControl(), hoverdVId);
      } else {
        model.clearSelectedVertices();
      }
    }
    redrawModel = true;
  }
}

void mouseDragged() {
  if (pressShift) {
    cameraController.mouseDragged();
    redrawCamera = true;
  } else {
    PVector v1 = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
    PVector v2 = cameraController.fromScreen(new PVector(pmouseX, pmouseY, 0));
    PVector v3 = PVector.sub(v1, v2);
    model.moveVertices(v3);
    redrawModel = true;
  }
}

void mouseWheel(MouseEvent event) {
  if (pressShift) {
    cameraController.mouseWheel(event);
    redrawCamera = true;
  }
}

void keyPressed() {
  if (keyCode == CONTROL) {
    pressCtrl = true;
  }

  if (keyCode == 157) {
    pressCmd = true;
  }

  if (keyCode == ALT) {
    pressAlt = true;
  }

  if (keyCode == SHIFT) {
    pressShift = true;
  }

  if (keyCode == 32) {
    pressSpace = true;
  }

  if (pressShift) {
    return;
  }

  if (keyCode == BACKSPACE) {
    model.removeSelectedVertices();
    redrawModel = true;
  }

  if (keyCode == ENTER) {
    model.addFaceWithSelectedVertices();
    redrawModel = true;
  }
}

void keyReleased() {
  if (keyCode == CONTROL) {
    pressCtrl = false;
  }

  if (keyCode == 157) {
    pressCmd = false;
  }

  if (keyCode == ALT) {
    pressAlt = false;
  }

  if (keyCode == SHIFT) {
    pressShift = false;
  }

  if (keyCode == 32) {
    pressSpace = false;
  }
}


void drawAxis() {
  push();
  strokeWeight(2 * cameraController.absoluteScale());
  stroke(255, 0, 0);
  line(0, 0, 0, 300, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 300, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 300);
  pop();
}

PVector getMouse() {
  return new PVector(mouseX - width / 2, mouseY - height / 2);
}
