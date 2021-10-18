package traceprinter.ramtools;
import javax.tools.SimpleJavaFileObject;
import java.net.URI;

/***
 This is the same as
  CharSequenceJavaFileObject
 posted by Miron Sadziak, August 20 2009, 
 http://www.javablogging.com/dynamic-in-memory-compilation/
***/

public class RAMJavaFile extends SimpleJavaFileObject {

    /**
     * CharSequence representing the source code to be compiled
     */
    private CharSequence content;

    private String className;

    /**
     * This constructor will store the source code in the
     * internal "content" variable and register it as a
     * source code, using a URI containing the class full name
     *
     * @param className
     *            name of the public class in the source code
     * @param content
     *            source code to compile
     */
    public RAMJavaFile(String className, CharSequence content) {
        super(URI.create("string:///" + className.replace('.', '/')
                         + Kind.SOURCE.extension), Kind.SOURCE);
        this.content = content;
        this.className = className;
    }

    public String toString() {
        return className+".java";
    }

    /**
     * Answers the CharSequence to be compiled. It will give
     * the source code stored in variable "content"
     */
    @Override
    public CharSequence getCharContent(boolean ignoreEncodingErrors) {
        return content;
    }
}