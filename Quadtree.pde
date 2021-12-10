class Quadtree {
  final int LEVEL = 8;
  final int N = 1 << LEVEL;
  HashSet<Integer>[] values = new HashSet[levelLinearN(LEVEL)];

  Quadtree() {
    for (int i = 0; i < values.length; i++) {
      values[i] = new HashSet<Integer>(0);
    }
  }

  int levelLinearN(int level) {
    int n = 1 << level;
    return 1 + (n * n - 1) * 4 / 3;
  }

  int morton(int x, int y) {
    int z = 0;
    for (int i = 0; i < LEVEL; i++) {
      z |= ((x >>> i) & 1) << (2 * i);
      z |= ((y >>> i) & 1) << (2 * i + 1);
    }
    return z;
  }

  int index(int level, int subMorton) {
    return levelLinearN(level - 1) + subMorton;
  }

  int subMorton(int morton, int level) {
    int i = LEVEL - level;
    return morton >>> (i * 2);
  }

  int intersectLevel(int lt, int rb) {
    int xor = lt ^ rb;
    int i = 0;
    while (xor != 0) {
      xor >>>= 2;
      i++;
    }
    return LEVEL - i;
  }

  int objectIndex(int x1, int y1, int x2, int y2) {
    int lt = morton(x1, y1);
    int rb = morton(x2, y2);
    int level = intersectLevel(lt, rb);
    int subMorton = subMorton(lt, level);
    return index(level, subMorton);
  }

  void insert(int x1, int y1, int x2, int y2, int value) {
    int index = objectIndex(x1, y1, x2, y2);
    values[index].add(value);
  }

  void remove(int x1, int y1, int x2, int y2, int value) {
    int index = objectIndex(x1, y1, x2, y2);
    values[index].remove(value);
  }

  ArrayList<Integer> query(int x, int y) {
    int morton = morton(x, y);
    ArrayList<Integer> result = new ArrayList<Integer>();
    for (int level = 0; level <= LEVEL; level++) {
      int subMorton = subMorton(morton, level);
      int index = index(level, subMorton);
      result.addAll(values[index]);
    }
    return result;
  }
}
