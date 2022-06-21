/**
 * For the original lightning/platformShowToastEvent mock that comes by default with
 * @salesforce/sfdx-lwc-jest, see:
 * https://github.com/salesforce/sfdx-lwc-jest/blob/master/src/lightning-stubs/platformShowToastEvent/platformShowToastEvent.js
 */

// ~~~~~ MOCK ShowToastEvent ~~~~~
let _title;
let _message;
let _mode;

export const resetAllShowToastEventStubs = () => {
    // Usually prefer `null` to `undefined` but since this is a "reset"...
    _title = undefined;
    _message = undefined;
    _mode = undefined;
};

export const ShowToastEventName = 'lightning__showtoast';

// Mock ShowToastEvent
export class ShowToastEvent extends CustomEvent {
    constructor(toast) {
        super(ShowToastEventName, {
            composed: true,
            cancelable: true,
            bubbles: true,
            detail: toast
        });

        // Set exposed toast values for showToastEventCalledWith
        _title = toast.title;
        _message = toast.message;
        _mode = toast.mode;
    }
}

// Enable checking what ShowToastEvent was called with in tests
export const showToastEventCalledWith = () => ({
    title: _title,
    message: _message,
    mode: _mode
});
