/**
 * class to represent the encoded locals for the heap stack
 */
class EncodedLocal{
    /**
     * Class constructor
     * @param {String} key the variable name
     * @param {reference} value the variable memory reference
     */
    constructor(key, value) {
    this.variableName = key;
    this.referenceValue = (value === null) ? null : value[1];
    }
}