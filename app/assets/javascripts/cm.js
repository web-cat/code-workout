var codemirror;

$(function() {
  $("pre").each(function() {
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
    CodeMirror(function(newEditor) {
      $(codeNode).replaceWith(newEditor);
    }, {
      value: body,
      theme: 'aptana',
      mode: $(codeNode).data('lang') || 'text/x-java',
      readOnly: true,
      autofocus: false,
      lineNumbers: $(codeNode).hasClass('lineNumbers') || !$(codeNode).hasClass('noLineNumbers')
    });
  });

  $(".practice textarea").each(function() {
  	var codeNode = this;
  	codemirror = CodeMirror.fromTextArea(codeNode, {
      theme: 'aptana',
      mode: $(codeNode).data('lang') || 'text/x-java',
      indentUnit: 4,
      autoClearEmptyLines: true,
      fixedGutter: true,
      matchBrackets: true,
      /* autofocus: true, */
      autofocus: false,
      lineNumbers: true,
      viewportMargin: 150
  	});
  	/* For some reason, CodeMirror's focus() doesn't seem to work
  	 * correctly, so need to leave it turned off until we can fix it.
  	 * Once fixed, remove the comment for autofocus above.
  	 */
  });
});