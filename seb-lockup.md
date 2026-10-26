I have multiple reports of users who are using Safe Exam Browser (SEB, found at https://safeexambrowser.org/) on Mac OS who are using CodeWorkout workouts as part of a quiz. The reports indicate a small number of users experiencing "lock ups" where they are answering a coding question, and at some point the codemirror edit area stops responding and no longer appears to respond to any mouse clicks or button presses. Students are forced to close the browser tab and re-open the page, which also means losing any work that was not submitted/saved at the time when the incident happened. This does not appear to be related to the time limit enforcement on the quiz workouts, since there is time remaining and the student can resume working after relaunching the tab. So far, there have not been reports of this happening in non-quiz environments that are not using SEB. what could be causing this kind of issue

----

This issue is caused by the intersection of how **Safe Exam Browser (SEB) for macOS** enforces its kiosk lockdown and how **CodeMirror 5** manages input focus and mouse/keyboard events.

SEB on macOS embeds Apple's **WebKit engine (`WKWebView`)** inside a native Cocoa wrapper that installs low-level event taps (`CGEventTap` / `NSEvent` monitors) and modifies system window responder chains. Meanwhile, CodeMirror 5 does not use a standard visible text input; it uses an off-screen, invisible `<textarea>` (`inputStyle: 'textarea'`) and simulates cursor, selection, and keyboard input via JavaScript.

Here are the primary causes of this lockup behavior, ranked from most likely to least likely, along with concrete mitigations for CodeWorkout:

---

### 1. Stuck Modifier Key (`Cmd` / `metaKey`) from SEB Shortcut Interception *(Most Probable)*

* **Mechanism**: When students edit code, they reflexively press shortcuts like `Cmd+C`, `Cmd+V`, `Cmd+Z`, `Cmd+A`, or `Cmd+Shift+Arrow`. 
* **The Collision**: SEB intercepts system shortcuts and clipboard hotkeys at the macOS/Cocoa level. When SEB suppresses or intercepts a Command key combination (or when SEB's lockdown hooks trigger), the `keydown` event for `Cmd` is captured by WebKit, but the corresponding **`keyup` (or `flagsChanged`) event is never delivered** back to the webview.
* **Why the editor freezes**:
  * **Keys stop responding**: CodeMirror tracks modifier state. If it believes `Cmd` (`metaKey`) is still held down, every subsequent keystroke (letters, numbers, space, enter) is processed as a Command combo (`Cmd+a`, `Cmd+e`, etc.). Because no editor command matches, CodeMirror silently swallows the keystroke. To the student, typing appears completely dead.
  * **Clicks stop working or misbehave**: In CodeMirror, clicking while `Cmd` is active is interpreted as **multi-cursor or rectangle selection**. Clicking does not place the normal typing cursor or re-focus the input; it simply toggles invisible cursor states.
* **Why closing the tab fixes it**: Relaunching the tab destroys the `WKWebView` instance, clearing the stuck modifier flags in WebKit.

---

### 2. Accidental Drag-and-Drop Deadlock (`dragDrop: true`)

* **Mechanism**: In CodeMirror 5, drag-and-drop is **enabled by default**. In [`app/assets/javascripts/cm.js`](file:///Users/edwards/git/code-workout/app/assets/javascripts/cm.js#L42-L57), `dragDrop: false` is not configured.
* **The Collision**: When students select code (e.g., double-clicking or click-dragging to highlight a variable or line), slight mouse movement after selection initiates a native WebKit drag session (`dragstart`).
* **Why the editor freezes**: SEB restricts or blocks inter-window drag-and-drop. If SEB or macOS intercepts and aborts the drag session without dispatching the standard DOM `dragend` or `drop` events to the page, CodeMirror remains trapped in an internal mouse-captured "dragging" state. While in this state:
  * Mouse clicks inside the editor are ignored.
  * The hidden textarea cannot regain focus.

---

### 3. WebKit `WKWebView` Native Focus Loss ("First Responder Drop")

* **Mechanism**: In macOS AppKit, `WKWebView` contains an internal `NSView` (`WKContentView`) that must maintain macOS `firstResponder` status to receive keyboard events.
* **The Collision**: Clicking on CodeMirror's editor surface (`.CodeMirror` / `.CodeMirror-scroll`) clicks on a `<div>`, not a native HTML form control. CodeMirror's JavaScript catches the `mousedown` event and programmatically calls `.focus()` on its hidden `<textarea>`.
* **Why the editor freezes**: If SEB momentarily shifts focus (e.g., background lockdown audit, SEB dock animation, unauthorized shortcut notification), `WKContentView` resigns first responder. WebKit in macOS frequently refuses to restore native first-responder status when JavaScript programmatically focuses a 0-size, off-screen, or hidden `<textarea>`, requiring a click on a visible, native form element. Clicks on CodeMirror's `<div>` trigger DOM events, but the native macOS view never regains keyboard focus.

---

### 4. macOS "Press and Hold" (Accent Menu) or Autocorrect Overlay Hang

* **Mechanism**: On macOS, holding down a key (such as `e`, `a`, `i`, or `u`) triggers the system Character Accent Picker popup, or macOS text replacement/spellcheck.
* **The Collision**: In SEB's locked-down kiosk mode, secondary system panel windows (`NSPanel`, `NSSpellServer`) are suppressed or cannot become active.
* **Why the editor freezes**: WebKit initiates an Input Method Editor (IME) composition session (`compositionstart`). Because the system popup is blocked, the session never completes with a `compositionend`. While WebKit is in an active IME composition state, normal typing is blocked, and mouse clicks inside the editor do not dismiss the state.

---

### 5. Interaction with CodeWorkout's `clipboard_protection.js`

* **Mechanism**: In [`app/assets/javascripts/clipboard_protection.js`](file:///Users/edwards/git/code-workout/app/assets/javascripts/clipboard_protection.js#L61-L93), custom hooks are registered on `copy`, `cut`, `paste`, and `extraKeys` (`Cmd-C`, `Cmd-V`, etc.):
  ```javascript
  cm.on('copy', function(cm, e) { e.preventDefault(); doCopy(cm); });
  ...
  var newKeys = { "Cmd-C": function(cm) { doCopy(cm); }, ... };
  ```
* **The Collision**: SEB also enforces clipboard policies (such as clearing `NSPasteboard` or blocking edit commands). When SEB and CodeWorkout both attempt to intercept and `preventDefault()` clipboard actions, unexpected `null` or restricted event objects from WebKit can cause JavaScript exceptions inside the event handler. An uncaught exception inside a CodeMirror event handler breaks its internal dispatch loop.

---

### Recommended Mitigations for CodeWorkout

To protect students from losing work and stop these lockups from occurring:

#### 1. Add Local Storage Draft Autosave (Highest Priority)
Currently, coding questions in [`practice.html.haml`](file:///Users/edwards/git/code-workout/app/views/exercises/practice.html.haml#L123-L128) only save code when the student submits ("Check my answer" / "Save my answer"). 
* **Fix**: Save the editor contents to browser `localStorage` (keyed by `workout_id` and `exercise_id`) on every CodeMirror `change` event (debounced). When the page loads, if the saved draft is newer than the starter code, restore it. Even if an SEB lockup forces a tab reload, **zero student work is lost**.

#### 2. Disable Drag-and-Drop in CodeMirror
In [`app/assets/javascripts/cm.js`](file:///Users/edwards/git/code-workout/app/assets/javascripts/cm.js#L42-L57), add `dragDrop: false`:
```javascript
var codemirror = CodeMirror.fromTextArea(codeNode, {
  theme: 'aptana',
  mode: lang,
  dragDrop: false, // Prevents WebKit drag session lockup in SEB
  ...
});
```

#### 3. Clear Modifier Flags and Reset State on Blur / Focus
Add window-level event listeners to force-clear any stuck modifier flags or dragging states when the window or editor experiences focus transitions:
```javascript
$(window).on('blur focus', function() {
  codemirrors.forEach(function(cmObj) {
    if (cmObj.editor && cmObj.editor.state) {
      cmObj.editor.state.draggingText = false;
    }
  });
});
```

#### 4. SEB Configuration Recommendations for Instructors
If your department provides the `.seb` configuration file:
* Ensure **Allow spell checking** and **Allow dictionary lookup** are disabled in SEB settings to prevent macOS from attempting to spawn background popup services.
* Ensure macOS press-and-hold is disabled in the SEB profile or system defaults (`defaults write -g ApplePressAndHoldEnabled -bool false`).