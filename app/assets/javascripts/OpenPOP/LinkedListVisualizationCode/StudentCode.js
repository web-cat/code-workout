/**
 * class to represent the code written by students
 */
class StudentCode{
    /**
     * class constructor
     * @param {String} code string that contains the student solution
     */
    constructor(code) {
    this.code = this.filterCode(code);
    }
    /**
     * remove empty lines
     */
    filterCode(code) {
        var lines = code.split('\n');
        var newLines = [];
        var tabs = 0;
        lines.forEach(function(line) {
            if (line === '}')
                tabs--;
            if (line.trim() !== "") {
                for (var i = 0; i < tabs; i++)
                    line = '    ' + line;
                newLines.push(line);
            }
            if (line === '{')
                tabs++;

        });
        newLines.push('return statement');
        if (newLines.length > 1)
            return newLines.join('\n');
        else
            return newLines[0];
    }
    /**
     * returns the code line based on the line number
     */
    getCodeAtLine(lineNumber) {
        var line = null;
        this.code.forEach(function(element, index) {
            if (index === lineNumber) {
                line = element;
            }
        });
        return line;
    }
    /**
     * returns the line number for the given code
     */
    getCodeLineNumber(codeLine) {
        var line = null;
        this.code.forEach(function(element, index) {
            if (element === codeLine) {
                line = index;
            }
        });
        return line;
    }
    /**
     * returns the student code.
     */
    getCode() {
        return this.code;
    }
}