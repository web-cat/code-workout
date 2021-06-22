/*****************************************************************************

traceprinter: a Java package to print traces of Java programs
David Pritchard (daveagp@gmail.com), created May 2013

The contents of this directory are released under the GNU Affero
General Public License, versions 3 or later. See LICENSE or visit:
http://www.gnu.org/licenses/agpl.html

See README for documentation on this package.

This file was originally based on
com.sun.tools.example.trace.EventThread, written by Robert Field.

******************************************************************************/

package traceprinter;

import com.sun.jdi.*;
import com.sun.jdi.request.*;
import com.sun.jdi.event.*;

import java.util.*;
import java.io.*;
import javax.json.*;

/*
 * Original author: Robert Field, see
 *
 * This version: David Pritchard (http://dave-pritchard.net)
 */

public class JSONTracingThread extends Thread {

    private final VirtualMachine vm;   // Running VM
    private String[] no_breakpoint_requests = {"java.*", "javax.*", "sun.*", "com.sun.*", "Stack", "Queue", "ST",
                                               "jdk.internal.org.objectweb.asm.*" // for creating lambda classes
    };

    private boolean connected = true;  // Connected to VM
    private boolean vmDied = true;     // VMDeath occurred

    private EventRequestManager mgr;

    private JDI2JSON jdi2json;

    static int MAX_STEPS = 256;

    static double MAX_WALLTIME_SECONDS = 50;

    private int steps = 0;

    static int MAX_STACK_SIZE = 16;

    private String usercode;

    private InMemory im;

    private VMCommander vmc;

    private JsonArrayBuilder output = Json.createArrayBuilder();

    JSONTracingThread(InMemory im) {
        super("event-handler");
        this.vm = im.vm;
        this.im = im;
        this.usercode = im.usercode;
        mgr = vm.eventRequestManager();
        jdi2json = new JDI2JSON(vm,
                                vm.process().getInputStream(),
                                vm.process().getErrorStream(),
                                im.optionsObject);
        setEventRequests();
    }

    void setEventRequests() {
        ExceptionRequest excReq = mgr.createExceptionRequest(null, true, true);
        excReq.setSuspendPolicy(EventRequest.SUSPEND_ALL);
        for (String clob : no_breakpoint_requests)
            excReq.addClassExclusionFilter(clob);
        excReq.enable();

        MethodEntryRequest menr = mgr.createMethodEntryRequest();
        for (String clob : no_breakpoint_requests)
            menr.addClassExclusionFilter(clob);
        menr.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
        menr.enable();

        MethodExitRequest mexr = mgr.createMethodExitRequest();
        for (String clob : no_breakpoint_requests)
            mexr.addClassExclusionFilter(clob);
        mexr.setSuspendPolicy(EventRequest.SUSPEND_EVENT_THREAD);
        mexr.enable();

        ThreadDeathRequest tdr = mgr.createThreadDeathRequest();
        tdr.setSuspendPolicy(EventRequest.SUSPEND_ALL);
        tdr.enable();

        ClassPrepareRequest cpr = mgr.createClassPrepareRequest();
        for (String clob : no_breakpoint_requests)
            cpr.addClassExclusionFilter(clob);
        cpr.setSuspendPolicy(EventRequest.SUSPEND_ALL);
        cpr.enable();
    }

    @Override
    public void run() {
        StepRequest request = null;
        final EventQueue queue = vm.eventQueue();
        while (connected) {
            try {
                final EventSet eventSet = queue.remove();
                for (Event ev : new Iterable<Event>(){public Iterator<Event> iterator(){return eventSet.eventIterator();}}) {


                    //System.out.println("in run: " + steps+" "+ev+" "+(System.currentTimeMillis()-startTime));

                    //        System.out.println(currentTimeMillis());
                    if (System.currentTimeMillis() > MAX_WALLTIME_SECONDS * 1000 + InMemory.startTime) {
                        output.add(Json.createObjectBuilder()
                                   .add("exception_msg", "<exceeded max visualizer time limit>")
                                   .add("event", "instruction_limit_reached"));

                        try {
                            PrintStream out = new PrintStream(System.out, true, "UTF-8");
                            String outputString = JDI2JSON.output(usercode, output.build()).toString();
                            out.print(outputString);
                        } catch (UnsupportedEncodingException e) {
                            System.out.print("UEE");
                            }
                        System.exit(0);
                        vm.exit(0); // might take a long time
                    }


                    handleEvent(ev);
                    if (request != null && request.isEnabled()) {
                        request.disable();
                    }
                    if (request != null) {
                        mgr.deleteEventRequest(request);
                        request = null;
                    }
                    if (ev instanceof LocatableEvent &&
                        jdi2json.reportEventsAtLocation(((LocatableEvent)ev).location())
                        ||
                        (ev.toString().contains("NoopMain")))
                        {
                        request = mgr.
                            createStepRequest(((LocatableEvent)ev).thread(),
                                              StepRequest.STEP_MIN,
                                              StepRequest.STEP_INTO);
                        request.addCountFilter(1);  // next step only
                        request.enable();
                    }
                }
                eventSet.resume();
            } catch (InterruptedException exc) {
                exc.printStackTrace();
                // Ignore
            } catch (VMDisconnectedException discExc) {
                handleDisconnectedException();
                break;
            }
        }
        String outputString = null;
        try {
            if (vmc == null) {
                outputString = JDI2JSON.compileErrorOutput(usercode, "Internal error: there was an error starting the debuggee VM.", 0, 0).toString();
            }
            else {
                vmc.join();
                if (vmc.success == null) {
                    outputString = JDI2JSON.compileErrorOutput(usercode, "Success is null?", 0, 0).toString();
                }
                else if (vmc.success == false) {
                    outputString = JDI2JSON.compileErrorOutput(usercode, vmc.errorMessage, 1, 1).toString();
                }
                else {
                    outputString = JDI2JSON.output(usercode, output.build()).toString();
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace(System.out);
        }

        try {
            PrintStream out = new PrintStream(System.out, true, "UTF-8");
            out.print(outputString);
        } catch (UnsupportedEncodingException e) {
            System.out.print(outputString);
        }
    }

    ThreadReference theThread = null;

    private Thread handleEvent(Event event) {
        //System.out.println(event);
        if (event instanceof ClassPrepareEvent) {
            classPrepareEvent((ClassPrepareEvent)event);
        } else if (event instanceof VMDeathEvent) {
            vmDeathEvent((VMDeathEvent)event);
        } else if (event instanceof VMDisconnectEvent) {
            vmDisconnectEvent((VMDisconnectEvent)event);
        }

        if (event instanceof LocatableEvent) {
            //System.out.println("in handle subloop: " + steps+" "+event);
            if (theThread == null)
                theThread = ((LocatableEvent)event).thread();
            else {
                if (theThread != ((LocatableEvent)event).thread())
                    throw new RuntimeException("Assumes one thread!");
            }
            Location loc = ((LocatableEvent)event).location();
            try {
                if (loc.sourceName().equals("NoopMain.java") && steps == 0) {
                    steps++;
                    vmc = new VMCommander(im, theThread);
                    vmc.start();
                }
            } catch (AbsentInformationException e) {}

            if (steps < MAX_STEPS && jdi2json.reportEventsAtLocation(loc)
                || event instanceof ExceptionEvent && ((ExceptionEvent)event).catchLocation()==null) {
		try {
                    for (JsonObject ep : jdi2json.convertExecutionPoint(event, loc, theThread)) {
			output.add(ep);
			steps++;
                        int stackSize = ((JsonArray)ep.get("stack_to_render")).size();

                        boolean quit = false;
                        if (stackSize >= MAX_STACK_SIZE) {
                            output.add(Json.createObjectBuilder()
                                       .add("exception_msg", "<exceeded max visualizer stack size>")
                                       .add("event", "instruction_limit_reached"));
                            quit = true;
                        }
			if (steps == MAX_STEPS) {
                            output.add(Json.createObjectBuilder()
                                       .add("exception_msg", "<exceeded max visualizer step limit>")
                                       .add("event", "instruction_limit_reached"));
			    quit = true;
			}
                        if (quit)
                            vm.exit(0);
		    }
                    if (event instanceof ExceptionEvent && ((ExceptionEvent)event).catchLocation()==null) {
                        vm.exit(0);
                    }
		} catch (RuntimeException e) {
		    System.out.println("Error " + e.toString());
		    e.printStackTrace();
		}
            }
        }
        return null;
    }

    /***
     * A VMDisconnectedException has happened while dealing with
     * another event. We need to flush the event queue, dealing only
     * with exit events (VMDeath, VMDisconnect) so that we terminate
     * correctly.
     */
    synchronized void handleDisconnectedException() {
        EventQueue queue = vm.eventQueue();
        while (connected) {
            try {
                EventSet eventSet = queue.remove();
                EventIterator iter = eventSet.eventIterator();
                while (iter.hasNext()) {
                    Event event = iter.nextEvent();
                    if (event instanceof VMDeathEvent) {
                        vmDeathEvent((VMDeathEvent)event);
                    } else if (event instanceof VMDisconnectEvent) {
                        vmDisconnectEvent((VMDisconnectEvent)event);
                    }
                }
                eventSet.resume(); // Resume the VM
            } catch (InterruptedException exc) {
                // ignore
            }
        }
    }

    private void classPrepareEvent(ClassPrepareEvent event)  {
        //System.out.println("CPE!");
        ReferenceType rt = event.referenceType();

        if (!rt.name().equals("traceprinter.shoelace.NoopMain")) {
            if (rt.name().equals("StdIn"))
                jdi2json.stdinRT = rt;

            if (jdi2json.in_builtin_package(rt.name()))
                return;
        }

        jdi2json.staticListable.add(rt);

        //System.out.println(rt.name());
        try {
            for (Location loc : rt.allLineLocations()) {
                BreakpointRequest br = mgr.createBreakpointRequest(loc);
                br.enable();
            }
        }
        catch (AbsentInformationException e) {
            if (!rt.name().contains("$Lambda$"))
                System.out.println("AIE!" + rt.name());
        }
    }

    public void vmDeathEvent(VMDeathEvent event) {
        vmDied = true;
    }

    public void vmDisconnectEvent(VMDisconnectEvent event) {
        connected = false;
    }

}
