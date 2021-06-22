/*****************************************************************************

traceprinter: a Java package to print traces of Java programs
David Pritchard (daveagp@gmail.com), created May 2013

The contents of this directory are released under the GNU Affero 
General Public License, versions 3 or later. See LICENSE or visit:
http://www.gnu.org/licenses/agpl.html

See README for documentation on this package.

******************************************************************************/

package traceprinter;

import com.sun.jdi.*;
import java.util.*;

public class VMCommander extends Thread {

    private InMemory im;
    private ThreadReference tr;
    private VirtualMachine vm;
    private Map<String, byte[]> classesToLoad;
    private String mainClassName;

    private ClassType ClassLoader_;
    private ObjectReference ClassLoader_SystemClassLoader;

    Boolean success;
    String errorMessage;

    public VMCommander(InMemory im, ThreadReference tr) {
        this.im = im;
        this.tr = tr;
        this.vm = im.vm;
        this.classesToLoad = im.bytecode;
        this.mainClassName = im.mainClass;
    }

    ObjectReference VMCommandee_instance = null;
    public void run() {
        try {
            vm.suspend();

            // first, make instance of ByteClassLoader
            ClassLoader_ = classType("java.lang.ClassLoader");
            ClassLoader_SystemClassLoader = (ObjectReference) 
                call_s(ClassLoader_, "getSystemClassLoader");

            ObjectReference ByteClassLoader_instance = instantiate("traceprinter.shoelace.ByteClassLoader");

            // load the classes from their bytecodes
            for (Map.Entry<String, byte[]> me : classesToLoad.entrySet())
                call_i(ByteClassLoader_instance, "define", vm.mirrorOf(me.getKey()), mirrorOf(vm, me.getValue()));

            // load and instantiate Commandee. very similar to above!
            VMCommandee_instance = instantiate("traceprinter.shoelace.VMCommandee");

            ArrayReference mirrorOfArgs = newArray("java.lang.String", im.argsArray.size());
            for (int i=0; i<im.argsArray.size(); i++)
                mirrorOfArgs.setValue(i, vm.mirrorOf(im.argsArray.getString(i)));
            
            StringReference result;
            try {
                result = (StringReference)
                    call_i(VMCommandee_instance, 
                           "runMain", 
                           vm.mirrorOf(mainClassName), 
                           mirrorOfArgs, 
                           vm.mirrorOf(im.givenStdin));
            }
            catch (VMDisconnectedException e) {
                // means we exceeded step limit
                success = true; // visualization is fine
                return;
            }
            /*            // uncaught exception that originates in non-user code (e.g. scanner runs out)
            catch (InvocationException e) {
                System.out.println(e.toString());
                return;
            }
            */
            if (result == null) {
                success = true;
            }
            else {
                success = false;
                errorMessage = "Error: " + result.value();
            }

            vm.resume();
        }
        catch (Exception e) {
            e.printStackTrace(System.out);
            throw new RuntimeException(e.toString());
        }
    }

    // utility methods

    // calls the default no-arg constructor
    private ObjectReference instantiate(String x)
        throws InvalidTypeException, ClassNotLoadedException, 
               IncompatibleThreadStateException, InvocationException { 
        ObjectReference Class_x = (ObjectReference)
            call_i(ClassLoader_SystemClassLoader, ClassLoader_, "loadClass", 
                   vm.mirrorOf(x));
        ArrayReference ConstructorArray_x = (ArrayReference)
            call_i(Class_x, "getConstructors");
        ObjectReference Constructor_x = (ObjectReference)
            ConstructorArray_x.getValue(0);
        ObjectReference x_instance = (ObjectReference)
            call_i(Constructor_x, "newInstance");       
        return x_instance;
    }

    // call instance method 
    private Value call_i(ObjectReference o, String s, Value... v) 
        throws InvalidTypeException, ClassNotLoadedException, 
               IncompatibleThreadStateException, InvocationException {
        return call_i(o, (ClassType) o.referenceType(), s, v);
    }
 
    // call instance method w.r.t. specific class
    private Value call_i(ObjectReference o, ClassType t, String s, Value... v) 
        throws InvalidTypeException, ClassNotLoadedException, 
               IncompatibleThreadStateException, InvocationException {
        Method m = t.methodsByName(s).get(0);
        return o.invokeMethod(tr, m, lv(v), 0);
    }

    // call static method
    private Value call_s(ClassType t, String s, Value... v) 
        throws InvalidTypeException, ClassNotLoadedException, 
               IncompatibleThreadStateException, InvocationException {
        Method m = t.methodsByName(s).get(0);
        return t.invokeMethod(tr, m, lv(v), 0);
    }

    private ArrayReference newArray(String elementType, int length) {
        ArrayType at = (ArrayType)
            vm.classesByName(elementType+"[]").get(0);
        return at.newInstance(length);
    }

    private ClassType classType(String className) {
        return (ClassType) vm.classesByName(className).get(0);
    }

    private List<Value> lv(Value... vs) {
        return Arrays.asList(vs);
    }

    private ArrayReference mirrorOf(VirtualMachine vm, byte[] bytes) 
        throws InvalidTypeException, ClassNotLoadedException {
        ArrayReference result = newArray("byte", bytes.length);
        for (int i=0; i < bytes.length; i++)
            result.setValue(i, vm.mirrorOf(bytes[i]));
        return result;
    }


}
