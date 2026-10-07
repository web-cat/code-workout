var codemirrors = [];
var indentUnits = {
  'text/x-java': 4,
  'text/x-c++src': 4,
  'text/x-python': 4,
  'text/x-ruby': 2,
  'text/x-yaml': 2
};

// LocalStorage helpers for draft autosave
var MAX_DRAFTS = 50;
var DRAFT_EXPIRY_MS = 3 * 24 * 60 * 60 * 1000; // 3 days

function getDraft(key) {
  try {
    if (!window.localStorage || !key) { return null; }
    var raw = window.localStorage.getItem(key);
    if (!raw) { return null; }
    try {
      var data = JSON.parse(raw);
      if (data && typeof data.code === 'string') {
        if (data.timestamp && (Date.now() - data.timestamp > DRAFT_EXPIRY_MS)) {
          window.localStorage.removeItem(key);
          return null;
        }
        return data.code;
      }
    } catch (parseErr) {
      return raw;
    }
    return null;
  } catch (e) {
    return null;
  }
}

function pruneOldestDrafts() {
  try {
    if (!window.localStorage) { return; }
    var draftEntries = [];
    for (var i = 0; i < window.localStorage.length; i++) {
      var key = window.localStorage.key(i);
      if (key && key.indexOf('cw_draft_') === 0) {
        try {
          var data = JSON.parse(window.localStorage.getItem(key));
          if (data && data.timestamp) {
            draftEntries.push({ key: key, timestamp: data.timestamp });
          }
        } catch (e) {}
      }
    }
    draftEntries.sort(function(a, b) {
      return a.timestamp - b.timestamp; // oldest first
    });
    // Remove oldest 50% of drafts
    var countToRemove = Math.max(1, Math.floor(draftEntries.length / 2));
    for (var j = 0; j < countToRemove; j++) {
      window.localStorage.removeItem(draftEntries[j].key);
    }
  } catch (e) {}
}

function setDraft(key, code) {
  try {
    if (window.localStorage && key) {
      var payload = JSON.stringify({
        code: code,
        timestamp: Date.now()
      });
      try {
        window.localStorage.setItem(key, payload);
      } catch (quotaErr) {
        console.warn('localStorage quota exceeded. Pruning old drafts...');
        pruneOldestDrafts();
        try {
          window.localStorage.setItem(key, payload);
        } catch (retryErr) {
          console.error('Failed to save draft after pruning:', retryErr);
        }
      }
    }
  } catch (e) {
    // Ignore
  }
}

function removeDraft(key) {
  try {
    if (window.localStorage && key) {
      window.localStorage.removeItem(key);
    }
  } catch (e) {
    // Ignore
  }
}

// Global helper to clear active drafts upon successful submission or reset
function clearActiveDrafts() {
  codemirrors.forEach(function(cmObj) {
    if (cmObj.draftKey) {
      removeDraft(cmObj.draftKey);
    }
  });
}
if (typeof window !== 'undefined') {
  window.clearActiveDrafts = clearActiveDrafts;
}

// Active sweep on startup: cleans up expired drafts (>3 days) and enforces MAX_DRAFTS cap
function sweepDrafts() {
  try {
    if (!window.localStorage) { return; }
    var draftEntries = [];
    var now = Date.now();

    for (var i = 0; i < window.localStorage.length; i++) {
      var key = window.localStorage.key(i);
      if (key && key.indexOf('cw_draft_') === 0) {
        var raw = window.localStorage.getItem(key);
        try {
          var data = JSON.parse(raw);
          if (data && data.timestamp) {
            if (now - data.timestamp > DRAFT_EXPIRY_MS) {
              window.localStorage.removeItem(key);
              i--;
            } else {
              draftEntries.push({ key: key, timestamp: data.timestamp });
            }
          } else {
            window.localStorage.removeItem(key);
            i--;
          }
        } catch (e) {
          window.localStorage.removeItem(key);
          i--;
        }
      }
    }

    if (draftEntries.length > MAX_DRAFTS) {
      draftEntries.sort(function(a, b) {
        return a.timestamp - b.timestamp;
      });
      var toRemove = draftEntries.length - MAX_DRAFTS;
      for (var j = 0; j < toRemove; j++) {
        window.localStorage.removeItem(draftEntries[j].key);
      }
    }
  } catch (err) {
    // Ignore sweep errors
  }
}

function prepareEditor()
{
  $("pre").each(function()
  {
    var codeNode = this;
    if ($(codeNode).data('lang') === 'plain'
        || $(codeNode).data('lang') === 'text'
        || $(codeNode).hasClass('example')
        || $(codeNode).hasClass('examples'))
    {
      return; // do nothing
    }
    var body = codeNode.innerText || codeNode.textContent;
    if (body != null) { body = body.replace(/(\r?\n|\r)\s*$/, ''); }
    CodeMirror(function(newEditor)
    {
      $(codeNode).replaceWith(newEditor);
    }, {
      value: body,
      theme: 'aptana',
      mode: $(codeNode).data('lang') || 'text/x-java',
      readOnly: true,
      autofocus: false,
      lineNumbers: $(codeNode).hasClass('lineNumbers') || !$(codeNode).hasClass('noLineNumbers'),
      dragDrop: false
    });
  });

  $("textarea.code").each(function()
  {
  	var codeNode = this;
    var lang = $(codeNode).data('lang') || 'text/x-java';
    var indentUnit = indentUnits[lang];
  	var codemirror = CodeMirror.fromTextArea(codeNode,
  	{
      theme: 'aptana',
      mode: lang,
      indentUnit: indentUnit,
      tabSize: indentUnit,
      autoClearEmptyLines: true,
      fixedGutter: true,
      matchBrackets: true,
      /* autofocus: true, */
      autofocus: false,
      lineNumbers: true,
      viewportMargin: 150,
      lineWrapping: true,
      dragDrop: false, // Prevents WebKit drag session lockups in SEB
      screenReaderLabel: 'answer area'
  	});
  	/* For some reason, CodeMirror's focus() doesn't seem to work
  	 * correctly, so need to leave it turned off until we can fix it.
  	 * Once fixed, remove the comment for autofocus above.
  	 */
     var exerciseId = $(codeNode).data('exercise-id');
     var workoutScoreId = $(codeNode).data('workout-score-id');
     var userId = $(codeNode).data('user-id') || 'anon';

     // Mutually exclusive keying:
     // If workoutScoreId is available, ONLY use cw_draft_ws{workoutScoreId}_e{exerciseId}.
     // Gym fallback keys cw_draft_gym_u{userId}_e{exerciseId} are ONLY used when no workoutScoreId is present.
     var draftKey = null;
     if (exerciseId) {
       if (workoutScoreId) {
         draftKey = 'cw_draft_ws' + workoutScoreId + '_e' + exerciseId;
       } else {
         draftKey = 'cw_draft_gym_u' + userId + '_e' + exerciseId;
       }
     }

     var cmObj =
     {
       editor: codemirror,
       starterCode: $(codeNode).data('starter-code'),
       draftKey: draftKey
     };
     cmObj.editor.widgets=[];
     codemirrors.push(cmObj);

     // Recommendation 1: Restore unsaved draft from localStorage if present
     if (draftKey) {
       var initialCode = codemirror.getValue();
       var savedDraft = getDraft(draftKey);
       if (savedDraft && savedDraft !== initialCode) {
         codemirror.setValue(savedDraft);
         console.log("Restored unsaved draft for exercise " + exerciseId);
         var assurance = $('#saved_assurance');
         if (assurance.length) {
           assurance.html('<div class="alert alert-info alert-dismissible" role="alert" style="margin-top: 10px;">' +
             '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>' +
             '<i class="fa fa-info-circle"></i> Restored your unsaved draft from this browser session.</div>');
         }
       }

       // Debounced autosave on change
       var saveTimeout = null;
       codemirror.on('change', function(cm) {
         if (saveTimeout) {
           clearTimeout(saveTimeout);
         }
         saveTimeout = setTimeout(function() {
           setDraft(draftKey, cm.getValue());
         }, 400);
       });
     }
  });
}

function clearLineWidgets(editor)
{
  editor.widgets.forEach(function(widget)
  {
    editor.removeLineWidget(widget);
  });
  editor.widgets.length = 0;
}

function addLineWidget(editor, msg, lineNumber, widgetType)
{
  var widget = $('<div class="widget ' + widgetType + '">' +
    '<i class="fa fa-times-circle"></i> ' + msg + '</div>');
  editor.widgets.push(editor.addLineWidget(lineNumber - 1, widget[0]));
}

$(document).ready(function()
{
  prepareEditor();

  if (typeof window !== 'undefined') {
    if (window.requestIdleCallback) {
      window.requestIdleCallback(sweepDrafts);
    } else {
      setTimeout(sweepDrafts, 2000);
    }
  }

  $('.btn-reset').on('click', function()
  {
    $('#confirm-reset').modal('toggle');
    codemirrors.forEach(function(cmObj, index, array)
    {
      if (cmObj.draftKey) {
        removeDraft(cmObj.draftKey);
      }
      cmObj.editor.setValue(cmObj.starterCode);
    });
  });

  // Save active drafts immediately before page unload
  $(window).on('beforeunload', function() {
    codemirrors.forEach(function(cmObj) {
      if (cmObj.draftKey && cmObj.editor) {
        setDraft(cmObj.draftKey, cmObj.editor.getValue());
      }
    });
  });

  // Save active drafts immediately upon form submit
  $(document).on('submit', 'form', function() {
    codemirrors.forEach(function(cmObj) {
      if (cmObj.draftKey && cmObj.editor) {
        setDraft(cmObj.draftKey, cmObj.editor.getValue());
      }
    });
  });

  // Recommendation 3: Clear stuck dragging/selection state on blur, focus, or visibility change
  $(window).on('focus blur', function() {
    codemirrors.forEach(function(cmObj) {
      if (cmObj.editor) {
        if (cmObj.editor.state) {
          cmObj.editor.state.draggingText = false;
        }
        cmObj.editor.refresh();
      }
    });
  });

  $(document).on('visibilitychange', function() {
    if (!document.hidden) {
      codemirrors.forEach(function(cmObj) {
        if (cmObj.editor) {
          if (cmObj.editor.state) {
            cmObj.editor.state.draggingText = false;
          }
          cmObj.editor.refresh();
        }
      });
    }
  });

  // Ensure clicking on CodeMirror clears any stuck dragging state and ensures focus
  $(document).on('click', '.CodeMirror', function() {
    var cmElement = this;
    codemirrors.forEach(function(cmObj) {
      if (cmObj.editor && cmObj.editor.getWrapperElement() === cmElement) {
        if (cmObj.editor.state) {
          cmObj.editor.state.draggingText = false;
        }
        if (!cmObj.editor.hasFocus()) {
          cmObj.editor.focus();
        }
      }
    });
  });

  // Clear stuck dragging or modifier flags on modifier key release
  $(window).on('keyup', function(e) {
    if (e.key === 'Meta' || e.key === 'Control' || e.key === 'Alt' || e.key === 'Shift' ||
        e.keyCode === 91 || e.keyCode === 93 || e.keyCode === 17 || e.keyCode === 18 || e.keyCode === 16) {
      codemirrors.forEach(function(cmObj) {
        if (cmObj.editor && cmObj.editor.state) {
          cmObj.editor.state.draggingText = false;
        }
      });
    }
  });

  // Pressing Escape clears any stuck state and forces an editor refresh
  $(window).on('keydown', function(e) {
    if (e.key === 'Escape' || e.keyCode === 27) {
      codemirrors.forEach(function(cmObj) {
        if (cmObj.editor) {
          if (cmObj.editor.state) {
            cmObj.editor.state.draggingText = false;
          }
          cmObj.editor.refresh();
        }
      });
    }
  });
});
