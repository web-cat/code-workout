(function() {
  // A local variable to store the copied/cut content, shared across all CodeMirror instances
  var internalClipboard = '';

  // Helper function to check if the page is exempt from clipboard protection
  function isExempt() {
    var exemptClasses = [
      'active_admin',
      'staff',
      'edit',
      'new',
      'create',
      'update',
      'course_enrollments',
      'choose_roster',
      'roster_upload',
      'upload_roster',
      'generate_gradebook'
    ];
    return exemptClasses.some(function(cls) {
      return $('body').hasClass(cls);
    }) || window.location.pathname.indexOf('/admin') === 0;
  }

  // 1. CodeMirror 5 Internal Clipboard Protection
  if (typeof CodeMirror !== 'undefined') {
    CodeMirror.defineInitHook(function(cm) {
      if (isExempt()) {
        return;
      }

      // Helper function to handle copy logic
      var doCopy = function(cm) {
        var selectedText = cm.getSelection();
        if (selectedText) {
          internalClipboard = selectedText;
          console.log("Copied to internal clipboard:", internalClipboard);
        }
      };

      // Helper function to handle cut logic
      var doCut = function(cm) {
        var selectedText = cm.getSelection();
        if (selectedText) {
          internalClipboard = selectedText;
          if (!cm.getOption("readOnly")) {
            cm.replaceSelection(''); // Deletes the selected text
          }
          console.log("Cut to internal clipboard:", internalClipboard);
        }
      };

      // Helper function to handle paste logic
      var doPaste = function(cm) {
        if (internalClipboard) {
          cm.replaceSelection(internalClipboard);
          console.log("Pasted from internal clipboard:", internalClipboard);
        }
      };

      // Handle copy, cut, and paste events triggered by the browser (e.g., context menu)
      cm.on('copy', function(cm, e) {
        e.preventDefault();
        doCopy(cm);
      });

      cm.on('cut', function(cm, e) {
        e.preventDefault();
        doCut(cm);
      });

      cm.on('paste', function(cm, e) {
        e.preventDefault();
        doPaste(cm);
      });

      // Handle keyboard shortcuts explicitly via extraKeys to ensure they are captured
      var extraKeys = cm.getOption("extraKeys") || {};
      var newKeys = {
        "Cmd-C": function(cm) { doCopy(cm); },
        "Ctrl-C": function(cm) { doCopy(cm); },
        "Cmd-X": function(cm) { doCut(cm); },
        "Ctrl-X": function(cm) { doCut(cm); },
        "Cmd-V": function(cm) { doPaste(cm); },
        "Ctrl-V": function(cm) { doPaste(cm); }
      };

      // Merge newKeys into extraKeys without overwriting existing ones
      for (var key in newKeys) {
        extraKeys[key] = newKeys[key];
      }
      cm.setOption("extraKeys", extraKeys);
    });
  }

  // 2. Global Protection for the rest of the page
  $(document).ready(function() {
    if (isExempt()) {
      return;
    }

    $(document).on('copy cut paste', function(e) {
      // If the event target is within a CodeMirror instance, let CodeMirror's handlers deal with it
      if ($(e.target).closest('.CodeMirror').length > 0) {
        return;
      }

      // Otherwise, prevent the default action (disables copy/paste for regular text, sidebar, etc.)
      e.preventDefault();
      console.log("Copy/Paste prevented on non-CodeMirror element");
    });
  });
})();
