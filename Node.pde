class Node {

	PVector position;
	int label;
  float radius = 30;
  boolean goal;
  boolean current;
  boolean bad;
  
  ArrayList<Node> connections;

	Node(int _label, float x, float y) {
		label = _label;
		position = new PVector(x, y);
    connections = new ArrayList();
	}

  void connect(Node other) {
    connections.add(other);
  }

  void draw_circle() {
    ellipse(position.x, position.y, radius*2, radius*2);

    fill(0);
    textSize(18);
    float w = textWidth(Integer.toString(label));
    float h = textAscent()/2 + textDescent()/2;
    
    text(label, position.x - (w/2), position.y + (h/2));
  }
  
  void draw_lines() {
    stroke(255);
    strokeWeight(2);
    noFill();
    
    for (Node other : connections) {
      line(position.x, position.y, other.position.x, other.position.y);
    }
  }

	void show() {
    stroke(0);
    strokeWeight(3);
    fill(255);

    if (current) {
      fill(255, 255, 0);
    }
    
    if (goal) {
      fill(0, 255, 0);
      if (current) {
        fill(125, 125, 0);
      }
    }
    
    if (bad) {
      fill(255, 0, 0);
      if (current) {
        fill(255, 125, 0);
      }
    }
    
    
    draw_circle();
    
	}

  void hover() {
    stroke(125);
    strokeWeight(3);
    fill(255);
    
    if (current) {
      fill(255, 255, 0);
    }
    
    if (goal) {
      fill(0, 255, 0);
      if (current) {
        fill(125, 125, 0);
      }
    }
    
    if (bad) {
      fill(255, 0, 0);
      if (current) {
        fill(255, 125, 0);
      }
    }
    
    draw_circle();
  }

  void dragging() {
    stroke(125);
    strokeWeight(3);
    fill(125);
    
    if (current) {
      fill(255, 255, 0);
    }
    
    if (goal) {
      fill(0, 255, 0);
      if (current) {
        fill(125, 125, 0);
      }
    }
    
    if (bad) {
      fill(255, 0, 0);
      if (current) {
        fill(255, 125, 0);
      }
    }
    
    draw_circle();
  }

  boolean inside(float x, float y) {
    if (dist(x, y, position.x, position.y) < radius) {
        return true;
    }
    return false;
  }

  void setPos(float x, float y) {
    position.set(x, y);
  }
}
