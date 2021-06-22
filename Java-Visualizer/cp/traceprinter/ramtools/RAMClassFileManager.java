package traceprinter.ramtools;
import javax.tools.*;
import java.io.*;
import java.util.*;
import java.security.SecureClassLoader;

/***
 This is based on 
  ClassFileManager
 posted by Miron Sadziak, August 20 2009, 
 http://www.javablogging.com/dynamic-in-memory-compilation/

 The difference is that this allows multiple class files
 (for example when you have inner classes), and exposes the
 compiled bytes of them.
***/

public class RAMClassFileManager 
    extends ForwardingJavaFileManager<JavaFileManager> {
    /**
     * Instance of JavaClassObject that will store the
     * compiled bytecode of our class
     */
    

    // ideally, you would make this private and provide an immutable getter
    public Map<String, RAMClassFile> contents = new TreeMap<>();

    /**
     * Will initialize the manager with the specified
     * standard java file manager
     *
     * @param standardManger
     */
    public RAMClassFileManager(StandardJavaFileManager standardManager) {
        super(standardManager);
    }

    /**
     * Will be used by us to get the class loader for our
     * compiled class. It creates an anonymous class
     * extending the SecureClassLoader which uses the
     * byte code created by the compiler and stored in
     * the RAMClassFile, and returns the Class for it
     */
    @Override
    public ClassLoader getClassLoader(Location location) {
        return new SecureClassLoader() {
           @Override
           protected Class<?> findClass(String name)
                throws ClassNotFoundException {
                byte[] b = contents.get(name).getBytes();
                return super.defineClass(name, b, 0, b.length);
           }
            };
    }

    /**
     * Gives the compiler an instance of the RAMClassFile
     * so that the compiler can write the byte code into it.
     */
    @Override
    public JavaFileObject getJavaFileForOutput
     (Location location, String className, JavaFileObject.Kind kind, 
      FileObject sibling) throws IOException {
        RAMClassFile jclassObject = new RAMClassFile(className, kind);
        contents.put(className, jclassObject);
        return jclassObject;
    }

}