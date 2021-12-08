CameraController cameraController = new CameraController();
boolean pressCtrl;
boolean pressCmd;
boolean pressAlt;
boolean pressShift;
Model model;

void setup() {
  size(1280, 720, P3D);
  model = encodeModel(loadStrings("bunny.obj"));
  model.normalize();
}

void draw() {
  background(0);

  cameraController.draw();
  PVector cameraPoint = cameraController.getPoint();

  PVector v = cameraController.fromScreen(mouseX, mouseY, 0);
  pushMatrix();
  translate(v.x, v.y, v.z);
  sphere(5);
  popMatrix();

  PVector v2 = cameraController.fromScreen(mouseX, mouseY, 1000);
  PVector v3 = PVector.sub(v2, v);
  int vId = model.findVertexId(v, v3);
  if (vId != -1) {
    PVector v4 = model.vertices.get(vId);
    pushMatrix();
    translate(v4.x, v4.y, v4.z);
    fill(255, 0, 0);
    sphere(5);
    fill(255, 255, 255);
    popMatrix();
  }

  strokeWeight(2);
  stroke(255, 0, 0);
  line(0, 0, 0, 300, 0, 0);
  stroke(0, 255, 0);
  line(0, 0, 0, 0, 300, 0);
  stroke(0, 0, 255);
  line(0, 0, 0, 0, 0, 300);
  noStroke();

  lights();

  model.draw();
}

void mousePressed() {
  if (pressShift) {
    cameraController.mousePressed();
  }
}

void mouseDragged() {
  if (pressShift) {
    cameraController.mouseDragged();
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
