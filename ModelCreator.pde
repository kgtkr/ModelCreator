CameraController cameraController = new CameraController();
boolean pressCtrl;
boolean pressCmd;
boolean pressAlt;
boolean pressShift;
Model model;
int hoverdVId = -1;
int selectedVId = -1;

void setup() {
  size(1280, 720, P3D);
  model = encodeModel(loadStrings("bunny.obj"));
  model.normalize();
}

void draw() {
  background(0);

  cameraController.draw();

  hoverdVId = findHoverVId();
  drawHoverdVertex();
  drawSelectedVertex();

  drawAxis();
  drawModel();
}

int findHoverVId() {
  PVector v1 = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
  PVector v2 = cameraController.fromScreen(new PVector(mouseX, mouseY, 1000));
  PVector v3 = PVector.sub(v2, v1);
  return model.findVertexId(v1, v3, 3 * cameraController.absoluteScale());
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
  }
  if (hoverdVId != -1) {
    selectedVId = hoverdVId;
  }
}

void mouseReleased() {
  selectedVId = -1;
}

void mouseDragged() {
  if (pressShift) {
    cameraController.mouseDragged();
  }

  if (selectedVId != -1) {
    PVector v1 = model.vertices.get(selectedVId);
    PVector v2 = cameraController.toScreen(v1);
    v2.add(new PVector(mouseX - pmouseX, mouseY - pmouseY, 0));
    PVector v3 = cameraController.fromScreen(v2);
    PVector v = model.vertices.get(selectedVId);
    v.set(v3);
  }
}

void mouseWheel(MouseEvent event) {
  if (pressShift) {
    cameraController.mouseWheel(event);
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

void drawHoverdVertex() {
  if (selectedVId == -1 && hoverdVId != -1) {
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

void drawSelectedVertex() {
  if (selectedVId != -1) {
    PVector v = model.vertices.get(selectedVId);
    push();
    pushMatrix();
    translate(v.x, v.y, v.z);
    fill(255, 0, 0);
    noStroke();
    sphere(5 * cameraController.absoluteScale());
    popMatrix();
    pop();
  }
}
