/*************************************************************************
 *  Compilation:  javac StdIn.java
 *  Execution:    java StdIn   (interactive test of basic functionality)
 *
 *  Reads in data of various types from standard input.
 *
 *************************************************************************/

import java.util.Scanner;
import java.util.regex.Pattern;

/**
 *  <i>Standard input</i>. This class provides methods for reading strings
 *  and numbers from standard input. See 
 *  <a href="http://introcs.cs.princeton.edu/15inout">Section 1.5</a> of
 *  <i>Introduction to Programming in Java: An Interdisciplinary Approach</i>
 *  by Robert Sedgewick and Kevin Wayne.
 *  <p>
 *  See the technical information in the documentation of the {@link In}
 *  class, which applies to this class as well. 
 *
 *  @author Robert Sedgewick
 *  @author Kevin Wayne
 */
public final class StdIn {

    // it doesn't make sense to instantiate this class
    private StdIn() {}

    private static Scanner scanner;
 
    /*** begin: section (1 of 2) of code duplicated from In to StdIn */
    
    // assume Unicode UTF-8 encoding
    private static final String charsetName = "UTF-8";

    // assume language = English, country = US for consistency with System.out.
    private static final java.util.Locale usLocale = 
        new java.util.Locale("en", "US");

    // the default token separator; we maintain the invariant that this value 
    // is held by the scanner's delimiter between calls
    private static final Pattern WHITESPACE_PATTERN
        = Pattern.compile("\\p{javaWhitespace}+");

    // makes whitespace characters significant 
    private static final Pattern EMPTY_PATTERN
        = Pattern.compile("");

    // used to read the entire input. source:
    // http://weblogs.java.net/blog/pat/archive/2004/10/stupid_scanner_1.html
    private static final Pattern EVERYTHING_PATTERN
        = Pattern.compile("\\A");

    /*** end: section (1 of 2) of code duplicated from In to StdIn */

    /*** begin: section (2 of 2) of code duplicated from In to StdIn,
      *  with all methods changed from "public" to "public static" ***/

   /**
     * Is the input empty (except possibly for whitespace)? Use this
     * to know whether the next call to {@link #readString()}, 
     * {@link #readDouble()}, etc will succeed.
     */
    public static boolean isEmpty() {
        return !scanner.hasNext();
    }

   /**
     * Does the input have a next line? Use this to know whether the
     * next call to {@link #readLine()} will succeed. <p> Functionally
     * equivalent to {@link #hasNextChar()}.
     */
    public static boolean hasNextLine() {
        return scanner.hasNextLine();
    }

    /**
     * Is the input empty (including whitespace)? Use this to know 
     * whether the next call to {@link #readChar()} will succeed. <p> Functionally
     * equivalent to {@link #hasNextLine()}.
     */
    public static boolean hasNextChar() {
        scanner.useDelimiter(EMPTY_PATTERN);
        boolean result = scanner.hasNext();
        scanner.useDelimiter(WHITESPACE_PATTERN);
        return result;
    }


   /**
     * Read and return the next line.
     */
    public static String readLine() {
        String line;
        try                 { line = scanner.nextLine(); }
        catch (Exception e) { line = null;               }
        return line;
    }

    /**
     * Read and return the next character.
     */
    public static char readChar() {
        scanner.useDelimiter(EMPTY_PATTERN);
        String ch = scanner.next();
        assert (ch.length() == 1) : "Internal (Std)In.readChar() error!"
            + " Please contact the authors.";
        scanner.useDelimiter(WHITESPACE_PATTERN);
        return ch.charAt(0);
    }  


   /**
     * Read and return the remainder of the input as a string.
     */
    public static String readAll() {
        if (!scanner.hasNextLine())
            return "";

        String result = scanner.useDelimiter(EVERYTHING_PATTERN).next();
        // not that important to reset delimeter, since now scanner is empty
        scanner.useDelimiter(WHITESPACE_PATTERN); // but let's do it anyway
        return result;
    }


   /**
     * Read and return the next string.
     */
    public static String readString() {
        return scanner.next();
    }

   /**
     * Read and return the next int.
     */
    public static int readInt() {
        return scanner.nextInt();
    }

   /**
     * Read and return the next double.
     */
    public static double readDouble() {
        return scanner.nextDouble();
    }

   /**
     * Read and return the next float.
     */
    public static float readFloat() {
        return scanner.nextFloat();
    }

   /**
     * Read and return the next long.
     */
    public static long readLong() {
        return scanner.nextLong();
    }

   /**
     * Read and return the next short.
     */
    public static short readShort() {
        return scanner.nextShort();
    }

   /**
     * Read and return the next byte.
     */
    public static byte readByte() {
        return scanner.nextByte();
    }

    /**
     * Read and return the next boolean, allowing case-insensitive
     * "true" or "1" for true, and "false" or "0" for false.
     */
    public static boolean readBoolean() {
        String s = readString();
        if (s.equalsIgnoreCase("true"))  return true;
        if (s.equalsIgnoreCase("false")) return false;
        if (s.equals("1"))               return true;
        if (s.equals("0"))               return false;
        throw new java.util.InputMismatchException();
    }

    /**
     * Read all strings until the end of input is reached, and return them.
     */
    public static String[] readAllStrings() {
        // we could use readAll.trim().split(), but that's not consistent
        // since trim() uses characters 0x00..0x20 as whitespace
        String[] tokens = WHITESPACE_PATTERN.split(readAll());
        if (tokens.length == 0 || tokens[0].length() > 0)
            return tokens;
        String[] decapitokens = new String[tokens.length-1];
        for (int i=0; i < tokens.length-1; i++)
            decapitokens[i] = tokens[i+1];
        return decapitokens;
    }

    /**
     * Read all ints until the end of input is reached, and return them.
     */
    public static int[] readAllInts() {
        String[] fields = readAllStrings();
        int[] vals = new int[fields.length];
        for (int i = 0; i < fields.length; i++)
            vals[i] = Integer.parseInt(fields[i]);
        return vals;
    }

    /**
     * Read all doubles until the end of input is reached, and return them.
     */
    public static double[] readAllDoubles() {
        String[] fields = readAllStrings();
        double[] vals = new double[fields.length];
        for (int i = 0; i < fields.length; i++)
            vals[i] = Double.parseDouble(fields[i]);
        return vals;
    }
    
    /*** end: section (2 of 2) of code duplicated from In to StdIn */
    
    
    /**
     * If StdIn changes, use this to reinitialize the scanner.
     */
    private static void resync() {
        setScanner(new Scanner(new java.io.BufferedInputStream(System.in), 
                               charsetName));
    }
    
    private static void setScanner(Scanner scanner) {
        StdIn.scanner = scanner;
        StdIn.scanner.useLocale(usLocale);
    }

    // do this once when StdIn is initialized
    static {
        resync();
    }

   /**
     * Reads all ints from stdin.
     * @deprecated For more consistency, use {@link #readAllInts()}
     */
    public static int[] readInts() {
        return readAllInts();
    }

   /**
     * Reads all doubles from stdin.
     * @deprecated For more consistency, use {@link #readAllDoubles()}
     */
    public static double[] readDoubles() {
        return readAllDoubles();
    }

   /**
     * Reads all Strings from stdin.
     * @deprecated For more consistency, use {@link #readAllStrings()}
     */
    public static String[] readStrings() {
        return readAllStrings();
    }


    /**
     * Interactive test of basic functionality.
     */
    public static void main(String[] args) {

        System.out.println("Type a string: ");
        String s = StdIn.readString();
        System.out.println("Your string was: " + s);
        System.out.println();

        System.out.println("Type an int: ");
        int a = StdIn.readInt();
        System.out.println("Your int was: " + a);
        System.out.println();

        System.out.println("Type a boolean: ");
        boolean b = StdIn.readBoolean();
        System.out.println("Your boolean was: " + b);
        System.out.println();

        System.out.println("Type a double: ");
        double c = StdIn.readDouble();
        System.out.println("Your double was: " + c);
        System.out.println();

    }

}
