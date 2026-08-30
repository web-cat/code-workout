CodeMirror is designed to integrate with the browser's native copy/paste functionality for a seamless user experience. To completely override this behavior and use a local JavaScript variable for a "private clipboard," you need to intercept and handle the `copy`, `cut`, and `paste` events yourself.

This is a more advanced use of the library, and the exact approach can vary slightly depending on the CodeMirror version (v5 vs. v6). Here's a solution that works for CodeMirror 5, which is still widely used.

### The JavaScript to Add

You'll need a local variable to act as your clipboard and event handlers to manage the copy, cut, and paste actions. This code should be added after you've created your CodeMirror instance.

**JavaScript**

```
// Assume 'editor' is your CodeMirror instance
var editor = CodeMirror.fromTextArea(document.getElementById("my-textarea"), {
  lineNumbers: true,
  // other CodeMirror options...
});

// A local variable to store the copied/cut content
var internalClipboard = '';

// Handle copy and cut events
editor.on('copy', function(cm, e) {
  // Prevent the default browser copy action
  e.preventDefault();

  // Get the selected text from the CodeMirror editor
  var selectedText = cm.getSelection();

  // If there is selected text, store it in our internal clipboard
  if (selectedText) {
    internalClipboard = selectedText;
    console.log("Copied to internal clipboard:", internalClipboard);
  }
});

editor.on('cut', function(cm, e) {
  // Prevent the default browser cut action
  e.preventDefault();

  // Get the selected text
  var selectedText = cm.getSelection();

  // If there is selected text, store it and then delete it from the editor
  if (selectedText) {
    internalClipboard = selectedText;
    cm.replaceSelection(''); // Deletes the selected text
    console.log("Cut to internal clipboard:", internalClipboard);
  }
});

// Handle paste events
editor.on('paste', function(cm, e) {
  // Prevent the default browser paste action
  e.preventDefault();

  // Only paste from our internal clipboard
  // Do not access e.clipboardData.getData('text/plain') as this would
  // use the system clipboard
  if (internalClipboard) {
    // Insert the content of our internal clipboard into the editor
    cm.replaceSelection(internalClipboard);
    console.log("Pasted from internal clipboard:", internalClipboard);
  }
});

// Optional: You may also want to handle the keydown events for copy/paste shortcuts
editor.setOption("extraKeys", {
  "Cmd-C": function(cm) {
    // Trigger the 'copy' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('copy'));
  },
  "Ctrl-C": function(cm) {
    // Trigger the 'copy' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('copy'));
  },
  "Cmd-X": function(cm) {
    // Trigger the 'cut' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('cut'));
  },
  "Ctrl-X": function(cm) {
    // Trigger the 'cut' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('cut'));
  },
  "Cmd-V": function(cm) {
    // Trigger the 'paste' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('paste'));
  },
  "Ctrl-V": function(cm) {
    // Trigger the 'paste' event handler we defined
    cm.getWrapperElement().dispatchEvent(new CustomEvent('paste'));
  }
});
```

### How the Code Works:

1. **`internalClipboard` Variable** : This is the core of the solution. It's a simple JavaScript string variable that will hold the text you want to copy or cut. This variable is local to your page and has no interaction with the user's system clipboard.
2. **`editor.on('copy', ...)` and `editor.on('cut', ...)`** :

* These event listeners are attached to the CodeMirror instance. They fire whenever a user attempts to copy or cut text using any method (right-click menu, keyboard shortcut).
* `e.preventDefault()` is crucial here. It stops the browser's default behavior, which would be to interact with the system clipboard.
* `cm.getSelection()` retrieves the currently selected text within the CodeMirror editor.
* The selected text is then stored in the `internalClipboard` variable. For a `cut` action, `cm.replaceSelection('')` is used to delete the selected text from the editor after it's been stored.

1. **`editor.on('paste', ...)`** :

* This listener fires when a user attempts to paste.
* `e.preventDefault()` blocks the browser from pasting content from the system clipboard.
* The code then checks if the `internalClipboard` variable has content. If it does, `cm.replaceSelection(internalClipboard)` inserts that content into the editor at the current cursor position. It completely ignores any data that might be on the system clipboard.

1. **`extraKeys` (Optional but Recommended)** :

* The `editor.on()` handlers might not always capture all keyboard shortcuts on their own, as CodeMirror has its own keymap system. This `extraKeys` configuration ensures that keyboard shortcuts like `Ctrl-C`, `Cmd-C`, `Ctrl-V`, etc., are explicitly intercepted and trigger the custom event handlers you've defined. This makes the behavior consistent for all copy/paste methods.
