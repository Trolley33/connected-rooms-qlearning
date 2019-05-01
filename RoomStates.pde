Node[] nodes;
Node draggedNode;

double[][] R;
int goal;

int episodes = 0;
int deaths = 0;

int speed = 1;

Agent agent;

void setup() {
  size(600, 600);
  
  JSONObject json = loadJSONObject("data.json");

  println("Generating nodes...");
  JSONArray json_nodes = json.getJSONArray("nodes");
  println("Creating agent...");
  agent = new Agent(json_nodes.size(), 0);
  
  nodes = new Node[json_nodes.size()];
  for (int i = 0; i < json_nodes.size(); i++)
  {
    JSONObject json_node = json_nodes.getJSONObject(i);

    int label = json_node.getInt("label");
    float x = json_node.getFloat("x");
    float y = json_node.getFloat("y");

    nodes[i] = new Node(label, x, y);
  }
  
  println("Loading punish nodes...");
  JSONArray json_punishments = json.getJSONArray("bad_nodes");
  for (int i = 0; i < json_punishments.size(); i++) {
    nodes[json_punishments.getInt(i)].bad = true;;
  }

  println("Generating reward matrix...");    
  R = new double[nodes.length][nodes.length];
  for (int state = 0; state < R.length; state++) {
    for (int action = 0; action < R[state].length; action++) {
      R[state][action] = -1;
    }
  }
  println("Calculating reward matrix...");
  JSONArray json_connection = json.getJSONArray("connections");
  for (int i = 0; i < json_connection.size(); i++) {
    JSONObject connection = json_connection.getJSONObject(i);
    int a = connection.getInt("a");
    int b = connection.getInt("b");

    R[a][b] = 0;
    R[b][a] = 0;
    
    if (nodes[a].bad) R[b][a] = -50;
    if (nodes[b].bad) R[a][b] = -50;
  }
    
  println("Loading goal node...");
  // Goal is last node.
  goal = R.length-1;
  for (int state = 0; state < R.length; state++) {
    if (R[state][goal] != -1) R[state][goal] = 100;
  }
  
  println("Connecting nodes...");
  for (int y = 0; y < R.length; y++) {
    for (int x = 0; x < R[y].length; x++) {
      if (R[y][x] != -1) {
        if (nodes[x].connections.indexOf(nodes[y]) == -1) 
          nodes[x].connect(nodes[y]);
      }
    }
  }
  nodes[goal].goal = true;
  
  // Set agent's memory.
  JSONArray qTable = json.getJSONArray("q_table");
  if (qTable.size() == agent.Q.length) {
    println("Loading Agent memory...");
    for (int y = 0; y < qTable.size(); y++) {
      JSONArray row = qTable.getJSONArray(y);
      for (int x = 0; x < row.size(); x++) {
        agent.Q[y][x] = row.getDouble(x);
      }
    }
  }
  
}

int prev = 0;

void draw() {
  background(51);
  if (millis() - prev >= 1000/speed)
  {
    move(agent.step(R));
    prev = millis();
  }
  
  for (Node node : nodes) {
    node.draw_lines();
  }
  for (Node node : nodes) {
    if (nodes[agent.current] == node) node.current = true;
    else node.current = false;

    node.show();
    if (draggedNode == null) 
      if (node.inside(mouseX, mouseY)) node.hover();
  }
  if (draggedNode != null) draggedNode.dragging();
  
  String episodes_string = "Episodes: " + episodes;
  String speed_string = "Speed: " + speed + " moves/s";
  String deaths_string = "Deaths: " + deaths;
  fill(255);
  stroke(255);
  text(episodes_string, width-textWidth(episodes_string)-50, 50);
  text(speed_string, width-textWidth(speed_string)-50, 50+textDescent()+textAscent());
  // Uncomment if using punishment nodes.
  // text(deaths_string, width-textWidth(deaths_string)-50, 50+(textDescent()+textAscent())*2);
}

void move(int next) {
  double[] states = R[agent.current];
  
  if (states[next] != -1) 
  {
    if (nodes[next].bad) {
      agent.current = 0;
      deaths++;
      return;
    }
    agent.current = next;
    if (next == goal || agent.current == goal) {
      episodes += 1;
      agent.current = (int) random(0, nodes.length - 1); // last node is always goal.
      
      if (episodes % 10 == 0)
        saveData();
    }
    
  }
}

void mousePressed() {
  if (draggedNode != null) return;

  for (Node node : nodes) {
    if (node.inside(mouseX, mouseY)) {
      draggedNode = node;
      break;
    }
  }
}

void mouseDragged() {
  if (draggedNode == null) return;
  draggedNode.setPos(mouseX, mouseY);
}

void mouseReleased() {
  if (draggedNode == null) return;
  draggedNode = null;
  saveData();
}

/**
 * Export node positions, connections, and goal as JSON.
 */
void saveData() {
  JSONObject json = new JSONObject();
  
  println("Saving node values...");
  JSONArray json_nodes = new JSONArray();
  for (int i = 0; i < nodes.length; i++) {
    JSONObject json_node = new JSONObject();
    json_node.setInt("label", nodes[i].label);
    json_node.setFloat("x", nodes[i].position.x);
    json_node.setFloat("y", nodes[i].position.y);

    json_nodes.setJSONObject(i, json_node);
  }
  json.setJSONArray("nodes", json_nodes);

  println("Saving connections...");
  JSONArray json_connections = new JSONArray();
  int i = 0;
  for (int y = 0; y < R.length; y++) {
    for (int x = 0; x < R[y].length; x++) {

      if (R[y][x] != -1) {
        JSONObject json_connection = new JSONObject();
        json_connection.setInt("a", x);
        json_connection.setInt("b", y);
        json_connections.setJSONObject(i, json_connection);
        i++;
      }
    }
  }
  json.setJSONArray("connections", json_connections);
  
  println("Saving punish nodes...");
  JSONArray json_punishments = new JSONArray();
  int counter = 0;
  for (int j = 0; j < nodes.length; j++) {
    if (nodes[j].bad) json_punishments.setInt(counter++, j);
  }
  
  json.setJSONArray("bad_nodes", json_punishments);
  
  println("Saving Agent memory...");
  JSONArray qTable = new JSONArray();
  for (int y = 0; y < agent.Q.length; y++) {
    JSONArray row = new JSONArray();
    for (int x = 0; x < agent.Q[y].length; x++) {
      row.setDouble(x, agent.Q[y][x]);
    }
    qTable.setJSONArray(y, row);
  }
  
  json.setJSONArray("q_table", qTable);

  println("Saving file...");
  saveJSONObject(json, "data/data.json");
}

int speedStep = 2;

void changeSpeed(int amount) {
  speed += amount;
  speed = (int(speed / speedStep)) * speedStep;
  if (speed <= 0) speed = 1;
  else if (speed >= 1000) speed = 1000;
}

void keyPressed() {
  switch (key) {
    case '=':
      changeSpeed(speedStep);
      return;
    case '-':
      changeSpeed(-speedStep);
      return;
    case '#':
      speed = 1;
      return;
    case 'c':
      agent.Q = new double[agent.Q.length][agent.Q.length];
      return;
  }
  
  try {
    int pressed = Integer.parseInt(Character.toString(key));
    if (pressed < R.length)
      move(pressed);
  }
  catch (NumberFormatException e) {
    return;
  }
}
