import java.util.Collections;
import java.util.Comparator;
import java.util.Random;

class Agent {
  double[][] Q;
  int current;
  double gamma = 0.8;
  
  Agent(int size, int _current) {
    Q = new double[size][size];
    current = _current;
  }
  
  int step(double[][] R) {
    
    int next = maxQ(current, R);
    
    Q[current][next] = getQValue(current, next, R);
    
    return next;
  }
  
  int maxQ(int state, double[][] R) {
    ArrayList<Double[]> validActions = new ArrayList ();
    // Get all valid actions as (index, Q value) pairs
    for (int i = 0; i < R[state].length; i++) {
      if (R[state][i] == -1) continue;
      else validActions.add(new Double[] {(double)i, Q[state][i]});
    }
    
    // Sort list by Q values.
    Collections.sort(validActions, 
    new Comparator<Double[]>(){
      public int compare(Double[] a, Double[] b) {
        if (a[1] < b[1]) return -1;
        if (a[1] > b[1]) return 1;
        return 0;
      }
    });
    
    ArrayList<Double[]> largestValues = new ArrayList();
    
    double largest = validActions.get(validActions.size()-1)[1];
    
    for (int i = validActions.size()-1; i >= 0; i--) {
      Double[] current = validActions.get(i); 
      if (current[1] < largest) break;
      
      largestValues.add(current);
    }
    Random rand = new Random();
    return largestValues.get(rand.nextInt(largestValues.size()))[0].intValue();

  }
  
  double getQValue(int state, int next, double[][] R) {
    double[] nextActions = R[next];
    ArrayList<Double> validRewards = new ArrayList ();
    
    for (int i = 0; i < nextActions.length; i++) {
      if (nextActions[i] == -1) continue;
      validRewards.add(Q[next][i]);
    }
    
    return R[state][next] + (gamma * maxReward(validRewards));
  }
  
  double maxReward(ArrayList<Double> rewards) {
    Collections.sort(rewards);
    
    double biggest = rewards.get(rewards.size()-1);
    
    return biggest;
  }
}
