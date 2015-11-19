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

  public boolean search(String text, String pattern) {
    char[] y = text.toCharArray();
    char[] x = pattern.toCharArray();
    int n = y.length; // string length
    int m = x.length; // pattern length
    boolean result = false;

    int j = 0;
    int i = 0;
    int last = m - 1;

    /* Precompute */
    preBmBc(x);

    System.out.println("n=" + n + " m=" + m + " last=" + last);

    /* Searching */
    while (j <= n - m && !result) {
      for (i = last; x[i] == y[i + j]; i--)
        if (i == 0) result = true;

      j += bmBC[y[j+last]];
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
