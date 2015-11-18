import java.util.*;

/**
 * String matching Boyer-Moore.
 */
public class BoyerMoore {
  public static final int ALPHABET_SIZE = 256; //Ascii table
  private int[] bmBC;  //
  private int[] bmGs;  //

  public void preBmBc(char[] x) {
    int m = x.length;
    bmBC = new int[ALPHABET_SIZE];

    Arrays.fill(bmBC, m);

    //
    for (int i = 0; i < m - 1; i++) bmBC[x[i]] = m - i - 1;
  }

  public int[] suffixes(char[] x) {
    int m = x.length;
    int suff[] = new int[m];
    int g = m - 1;
    int f = m - 1;

    suff[m - 1] = m;

    for (int i = m - 2; i >= 0; --i) {
      if (i > g && (i + m - 1 - f) < m && suff[i + m - 1 - f] < i - g) {
        suff[i] = suff[i + m - 1 - f];
      } else {
        g = i;
        f = g;

        //
        while (g >= 0 && x[g] == x[g + m - 1 - f]) --g;

        suff[i] = f - g;
      }
    }

    return suff;
  }

  public void preBmGs(char[] x) {
    int m = x.length;
    bmGs = new int[m];

    int suff[] = suffixes(x);

    Arrays.fill(bmGs, m);

    int j = 0;

    for (int i = m - 1; i >= -1; --i) {
      if (i == -1 || suff[i] == i + 1) {
        for (; j < m - 1 - i; ++j) {
          if (bmGs[j] == m) {
            bmGs[j] = m - 1 - i;
          }
        }
      }
    }

    //
    for (int i = 0; i < m - 1; i++) {
      bmGs[m - 1 - suff[i]] = m - 1 - i;
    }
  }


  public boolean search(String text, String pattern) {
    char[] y = text.toCharArray();
    char[] x = pattern.toCharArray();
    int n = y.length; // string length
    int m = x.length; // pattern length
    boolean result = false;

    int j = 0;
    int i = 0;

    /* Precompute */
    preBmBc(x);
    preBmGs(x);

    System.out.println("Searching; BMBC " + Arrays.toString(bmBC)
                       + "\nBMGS " + Arrays.toString(bmGs));
    /* Searching */
    while (j <= n - m && !result) {
      for (i = m - 1; i >= 0 && x[i] == y[i + j]; i--);

      if (i < 0) {
        result = true;
      } else {
        j += Math.max(bmGs[i], bmBC[y[i + j]] - m + 1 + i);
      }

    }

    return result;
  }

  public static void main(String args[]) {
    String text = args[0];
    String pattern = args[1];

    BoyerMoore bm = new BoyerMoore();

    System.out.println("found " + bm.search(text, pattern));

  }

}
