package stdlibpack;
/**
 * Test client for StdIn and In. 
 **/

import java.util.Scanner;
import java.util.Arrays;
import java.lang.reflect.Array;
import java.lang.reflect.Method;
import java.io.ByteArrayInputStream;
import java.net.URL;
import java.net.URLClassLoader;

public class StdInTest {
    
    // make a printable/readable version of an object
    public static Object escape(Object original) {
        if (original instanceof Character) {
            char u = (char) ((Character)original);
            int idx = "\b\t\n\f\r\"\'\\".indexOf(u);
            if (idx >= 0)
                return "\\"+"btnfr\"\'\\".charAt(idx);
            if (u < 32) 
                return "\\"+Integer.toOctalString(u);
            if (u > 126) 
                return "\\u"+String.format("%04X", (int)u);
            return original;
        }
        else if (original instanceof String) {
            StringBuilder result = new StringBuilder();
            for (char c : ((String)original).toCharArray())
                result.append(escape(c));
            return "\"" + result.toString() + "\"";
        }
        else if (original.getClass().isArray()) {
            StringBuilder result = new StringBuilder("[");
            int len = Array.getLength(original);
            for (int i=0; i<len; i++)
                result.append(" ").append(escape(Array.get(original, i)));
            return result.append("]").toString();
        }
        return original;
    }
    
    public static boolean testStdIn;
    
    public static Method resyncMethod;
    
    public static boolean canResync() {
        try {
            resyncMethod = StdIn.class.getMethod("resync");
        }
        catch (NoSuchMethodException e) {
            return false;
        }
        return true;
    }
    
    public static int testCount = 0;

    /**
     * In the two methods below, each Object[] of "steps" is a length-2
     * array: the first is a String holding a method name, the second
     * is the expected return value when that method is called in sequence.
     */
    public static void test(String input, Object[][] steps) {
        test(input, steps, false); // create Scanner from String
        if (testStdIn)
            test(input, steps, true);  // uses stdIn/System.setIn
        testCount++;
    }
    
    public static void test(String input, Object[][] steps, boolean useStdIn) {
        In in = null;
        if (useStdIn) {
            try {
                System.setIn(new ByteArrayInputStream(input.getBytes("UTF-8")));
            }
            catch (java.io.UnsupportedEncodingException e) {
                throw new RuntimeException(e.toString());
            }

            // in order for this to work, you need to change resync to public
            
            try { //call StdIn.resync();
                resyncMethod.invoke(null);
            }
            catch (IllegalAccessException e) {
                throw new RuntimeException(e.toString());
            }
            catch (java.lang.reflect.InvocationTargetException e) {
                throw new RuntimeException(e.toString());                   
            }
        }
        else 
            in = new In(new Scanner(input));

        int count = 0;
        for (Object[] step : steps) {
            String cmd = (String)step[0];
            Object expected = step[1];
            Object result;
            
            String preamble = "Failed input %s\nStep %d (%s)\n";

            try {
                Method method;
                // nice and easy since these methods take no arguments
                if (useStdIn)
                    method = StdIn.class.getMethod(cmd);
                else
                    method = in.getClass().getMethod(cmd);
                result = method.invoke(in); // fine to be null for static
            }
            catch (NoSuchMethodException e) {
                java.io.StringWriter errors = new java.io.StringWriter();
                e.printStackTrace(new java.io.PrintWriter(errors));
                throw new RuntimeException(String.format(preamble, 
                                                         input, count, cmd) +
                                           errors.toString());
            }
            catch (IllegalAccessException e) {
                java.io.StringWriter errors = new java.io.StringWriter();
                e.printStackTrace(new java.io.PrintWriter(errors));
                throw new RuntimeException(String.format(preamble, 
                                                         input, count, cmd) +
                                           errors.toString());
            }
            catch (java.lang.reflect.InvocationTargetException e) {
                java.io.StringWriter errors = new java.io.StringWriter();
                e.printStackTrace(new java.io.PrintWriter(errors));
                e.getCause().printStackTrace(new java.io.PrintWriter(errors));
                throw new RuntimeException(String.format(preamble, 
                                                         input, count, cmd) +
                                           errors.toString());
            }
                        
            if (expected.getClass().isArray()) {
                if (!(result.getClass().isArray())) {
                    StdOut.printf(preamble + "Expected array, got %s\n",
                                  input, count, cmd, result);
                    continue;
                }
                Object r = result, e = expected; // to shorten lines below
                int rl = Array.getLength(r);
                int el = Array.getLength(e);
                if (el != rl)
                    StdOut.printf(preamble + "Expected %d, got %d items:\n%s\n",
                                  escape(input), count, cmd, el, rl, escape(r));
                else for (int i=0; i<rl; i++) 
                    if (!(Array.get(r, i).equals(Array.get(e, i)))) 
                    StdOut.printf(preamble + "\nExpected [%d]=%s, got %s\n",
                                  escape(input), count, cmd, i, 
                                  escape(Array.get(e, i)), 
                                  escape(Array.get(r, i)));
            }
            else if (!result.equals(expected)) {
                StdOut.printf(preamble + "Expected %s, got %s\n",
                              escape(input), count, cmd, escape(expected), 
                              escape(result));
            }
            count++;
        }
    }
    
    public static void main(String[] args) {
        testStdIn = canResync();
        
        if (testStdIn) 
            StdOut.println("Note: any errors appear duplicated since tests run 2x.");
        else 
            StdOut.println("Note: StdIn.resync is private, only In will be tested.");

        test("this is a test", 
             new Object[][]{
            {"isEmpty", false}, {"hasNextChar", true}, {"hasNextLine", true},
            {"readAllStrings", new String[]{"this", "is", "a", "test"}},
            {"isEmpty", true}, {"hasNextChar", false}, {"hasNextLine", false}
        });
        test("\n\n\n", 
             new Object[][]{
            {"isEmpty", true}, {"hasNextChar", true}, {"hasNextLine", true},
            {"readAll", "\n\n\n"}
        });
        test("", 
             new Object[][]{
            {"isEmpty", true}, {"hasNextChar", false}, {"hasNextLine", false}
        });
        test("\t\t  \t\t", 
             new Object[][]{
            {"isEmpty", true}, {"hasNextChar", true}, {"hasNextLine", true},
            {"readAll", "\t\t  \t\t"}
        });
        test("readLine consumes newline\nyeah!", 
             new Object[][]{
            {"readLine", "readLine consumes newline"}, {"readChar", 'y'}
        });
        test("readString doesn't consume spaces", 
             new Object[][]{
            {"readString", "readString"}, {"readChar", ' '}
        });
        test("\n\nblank lines test",
             new Object[][]{
            {"readLine", ""}, {"readLine", ""}, {"hasNextLine", true},
            {"readLine", "blank lines test"}, {"hasNextLine", false}
        });
        test("   \n  \t \n  correct  \n\t\n\t .trim replacement \n\t",
             new Object[][]{
            {"readAllStrings", new String[]{"correct", ".trim", "replacement"}},
            {"hasNextChar", false}
        });
        StringBuilder sb = new StringBuilder();
        Object[][] expected = new Object[2000][2];
        for (int i=0; i<1000; i++) {
            sb.append((char)i);
            sb.append((char)(i+8000)); // include weird non-breaking spaces
            expected[2*i][0] = "readChar";
            expected[2*i+1][0] = "readChar";
            expected[2*i][1] = (char)i;
            expected[2*i+1][1] = (char)(i+8000);
        }
        test(sb.toString(), expected);
        test(" this \n and \that \n ",
             new Object[][]{
            {"readString", "this"}, {"readString", "and"}, {"readChar", ' '},
            {"readString", "hat"}, {"readChar", ' '}, {"isEmpty", true},
            {"hasNextLine", true}, {"readLine", ""}, {"readLine", " "}
        });
        test(" 1 2 3 \n\t 4 5 ",
             new Object[][]{
            {"readAllInts", new int[]{1, 2, 3, 4, 5}}
        });
        test(" 0 1 False true falsE True ",
             new Object[][]{
            {"readBoolean", false}, {"readBoolean", true}, 
            {"readBoolean", false}, {"readBoolean", true}, 
            {"readBoolean", false}, {"readBoolean", true}
        });
        test(" \240\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008"
                 + "\u2009\u200A\u205F\u3000",
             new Object[][]{
            {"readString", "\240"},   // non-breaking space - not java whitespace
            {"readString", "\u2007"}, // similarly
            {"hasNextChar", true}, // there is some stuff left over
            {"isEmpty", true},        // but it is all whitespace
            {"readChar", '\u2008'}    // such as this one
        });
        
        // line sep, par sep, NEL, unit sep, vtab --- first 3 are newlines
        // NB: \205 is treated as a line separator, but not whitespace!
        test("a\u2028b\u2029c\37d\13e\205f", 
             new Object[][]{
            {"readAllStrings", new String[]{"a", "b", "c", "d", "e\205f"}}
        });
        test("a\u2028b\u2029c\37d\13e\205f", 
             new Object[][]{
            {"readLine", "a"},
            {"readLine", "b"},
            {"readLine", "c\37d\13e"},
            {"readLine", "f"}
        });
        test("\u2028\u2029", // line separator, par separator
             new Object[][]{
            {"readLine", ""}, {"hasNextLine", true}, {"hasNextChar", true},
            {"readLine", ""}, {"hasNextLine", false}, {"hasNextChar", false}
        });
        test("\n\n", 
             new Object[][]{
            {"readLine", ""}, {"hasNextLine", true}, {"hasNextChar", true},
            {"readLine", ""}, {"hasNextLine", false}, {"hasNextChar", false}
        });
        test("\r\n\r\n", 
             new Object[][]{
            {"readLine", ""}, {"hasNextLine", true}, {"hasNextChar", true},
            {"readLine", ""}, {"hasNextLine", false}, {"hasNextChar", false}
        });
        test("\n\r", 
             new Object[][]{
            {"readLine", ""}, {"hasNextLine", true}, {"hasNextChar", true},
            {"readLine", ""}, {"hasNextLine", false}, {"hasNextChar", false}
        });
        test("\r\n", 
             new Object[][]{
            {"readLine", ""}, {"hasNextChar", false}, {"hasNextLine", false}
        });
        test("3E4 \t -0.5 \n \t +4", 
             new Object[][]{
            {"readAllDoubles", new double[] {30000, -0.5, 4}}
        });
        test(" whitespace ", 
             new Object[][]{
            {"readString", "whitespace"}, {"readChar", ' '},
            {"hasNextLine", false}
        });
        test(" whitespace \n", 
             new Object[][]{
            {"readString", "whitespace"}, {"readChar", ' '},
            {"readLine", ""}, {"hasNextLine", false}
        });
        test(" whitespace \n ", 
             new Object[][]{
            {"readString", "whitespace"}, {"readChar", ' '},
            {"readLine", ""}, {"hasNextLine", true},
            {"readLine", " "}, {"hasNextLine", false}
        });
        test(" 34 -12983   3.25\n\t foo!",
             new Object[][]{
            {"readByte", (byte)34}, 
            {"readShort", (short)-12983},
            {"readDouble", 3.25},
            {"readAll", "\n\t foo!"}
        });
        test("30000000000  3.5 3e4, foo   \t\t ya",
             new Object[][]{
            {"readLong", 30000000000L},
            {"readFloat", (float)3.5},
            {"readAllStrings", new String[]{"3e4,", "foo", "ya"}}
        });
        // testing consistency of whitespace and read(All)String(s)
        test(" \u0001 foo \u0001 foo \u0001 foo",
             new Object[][]{
            {"readAllStrings", new String[]{
                "\u0001", "foo", "\u0001", "foo", "\u0001", "foo"}}
        });
        test(" \u2005 foo \u2005 foo \u2005 foo",
             new Object[][]{
            {"readAllStrings", new String[]{"foo", "foo", "foo"}}
        });
        test(" \u0001 foo \u0001 foo \u0001 foo",
             new Object[][]{
            {"readString", "\u0001"}, {"readString", "foo"},
            {"readString", "\u0001"}, {"readString", "foo"},
            {"readString", "\u0001"}, {"readString", "foo"}
        });
        test(" \u2005 foo \u2005 foo \u2005 foo",
             new Object[][]{
            {"readString", "foo"}, {"readString", "foo"}, {"readString", "foo"}
        });
        StdOut.printf("Ran %d tests.\n", testCount);
    }
}
