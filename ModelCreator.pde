import java.util.HashSet;

CameraController cameraController = new CameraController();
boolean pressCtrl;
boolean pressCmd;
boolean pressAlt;
boolean pressShift;
boolean pressSpace;
Model model;
int hoverdVId = -1;

void setup() {
  size(1280, 720, P3D);
  model = encodeModel(loadStrings("bunny.obj"));
  model.normalize();
}

void draw() {
  background(0);

  cameraController.draw();

  if (!pressSpace) {
    hoverdVId = findHoverVId();
  } else {
    hoverdVId = -1;
  }


  drawAxis();
  drawModel();
  if (hoverdVId != -1) {
    model.drawHoverdVertex(hoverdVId);
  }
  model.drawSelectedVertices();
}

int findHoverVId() {
  PVector v1 = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
  PVector v2 = cameraController.fromScreen(new PVector(mouseX, mouseY, 1000));
  PVector v3 = PVector.sub(v2, v1);
  return model.findVertexId(v1, v3, 3 * cameraController.absoluteScale());
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
  } else {
    if (pressSpace) {
      PVector v = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
      int vId = model.addVertex(v);
      model.toggleSelectedVertex(pressControl(), vId);
    } else {
      if (hoverdVId != -1) {
        model.toggleSelectedVertex(pressControl(), hoverdVId);
      } else {
        model.clearSelectedVertices();
      }
    }
  }
}

void mouseReleased() {
  if (pressShift) {
    return;
  }
}

void mouseDragged() {
  if (pressShift) {
    cameraController.mouseDragged();
  } else {
    PVector v1 = cameraController.fromScreen(new PVector(mouseX, mouseY, 0));
    PVector v2 = cameraController.fromScreen(new PVector(pmouseX, pmouseY, 0));
    PVector v3 = PVector.sub(v1, v2);
    model.moveVertices(v3);
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

  if (keyCode == 32) {
    pressSpace = true;
  }

  if (pressShift) {
    return;
  }

  if (keyCode == BACKSPACE) {
    model.removeVertices();
  }

  if (keyCode == ENTER) {
    model.addFace();
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
