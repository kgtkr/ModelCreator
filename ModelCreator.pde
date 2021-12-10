import java.util.HashSet;

CameraController cameraController = new CameraController();
boolean pressCtrl;
boolean pressCmd;
boolean pressAlt;
boolean pressShift;
boolean pressSpace;
Model model;
int hoverdVId = -1;
boolean redraw = true;
Quadtree quadtree = new Quadtree();
final float HOVER_R = 1;

void setup() {
  size(1280, 720, P3D);
  model = encodeModel(loadStrings("bunny.obj"));
  model.normalize();
}

void draw() {
  translate(width / 2, height / 2);
  if (redraw) {
    calclateQuadtree();
  }
  calclateHoverdVId();
  if (redraw) {
    long start = System.nanoTime();
    background(0);
    sphereDetail(3);
    cameraController.draw();
    drawAxis();
    drawModel();
    if (hoverdVId != -1) {
      model.drawHoverdVertex(hoverdVId);
    }
    model.drawSelectedVertices(hoverdVId);

    redraw = false;
    long end = System.nanoTime();
    println("redraw", (end - start) / 1000000.0);
  }
}

void calclateQuadtree() {
  long beginTime = System.nanoTime();
  quadtree = new Quadtree();

  for (int vId : model.vertices.keySet()) {
    PVector v1 = model.vertices.get(vId);
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
    quadtree.insert(x1, y1, x2, y2, vId);
  }
  long endTime = System.nanoTime();
  println("calclateQuadtree", (endTime - beginTime) / 1000000.0);
}

void calclateHoverdVId() {
  long beginTime = System.nanoTime();
  int newHoverdVId;
  if (!pressSpace) {
    newHoverdVId = findHoverVId();
  } else {
    newHoverdVId = -1;
  }
  if (newHoverdVId != hoverdVId) {
    hoverdVId = newHoverdVId;
    redraw = true;
  }
  long endTime = System.nanoTime();
  println("calclateHoverdVId", (endTime - beginTime) / 1000000.0);
}

int findHoverVId() {
  int result = -1;
  float zMax = Float.MIN_VALUE;
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
  model.draw();
  pop();
}

void mousePressed() {
  if (pressShift) {
    cameraController.mousePressed();
    redraw = true;
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
    redraw = true;
  }
}

void mouseDragged() {
  if (pressShift) {
    cameraController.mouseDragged();
    redraw = true;
  } else {
    PVector v1 = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
    PVector v2 = cameraController.fromScreen(new PVector(pmouseX, pmouseY, 0));
    PVector v3 = PVector.sub(v1, v2);
    model.moveVertices(v3);
    redraw = true;
  }
}

void mouseWheel(MouseEvent event) {
  if (pressShift) {
    cameraController.mouseWheel(event);
    redraw = true;
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
    model.removeVertices();
    redraw = true;
  }

  if (keyCode == ENTER) {
    model.addFace();
    redraw = true;
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
