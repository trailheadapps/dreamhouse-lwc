// ~~~~~ MOCK getLocationService ~~~~~

// To stub getLocationService.isAvailable(), add the following to your test:
// import { setDeviceLocationServiceAvailable } from 'lightning/mobileCapabilities';
// setDeviceLocationServiceAvailable(true);

let _deviceLocationServiceAvailable = false;

export const getLocationService = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(_deviceLocationServiceAvailable),
        getCurrentPosition: jest.fn().mockImplementation(() =>
            Promise.resolve({
                coords: {
                    latitude: 42.361145,
                    longitude: -71.057083
                }
            })
        )
    };
});

export const setDeviceLocationServiceAvailable = (value = true) => {
    _deviceLocationServiceAvailable = value;
};

// ~~~~~ MOCK getBarcodeScanner ~~~~~

// To stub getBarcodeScanner.isAvailable(), add the following to your test:
// import { setBarcodeScannerAvailable } from 'lightning/mobileCapabilities';
// setBarcodeScannerAvailable(true);

// Mock getBarcodeScanner stubs that can be altered from within test files
let _barcodeScannerAvailable = false;
let _userCanceledScan = false;
let _scanThrewAnError = false;

// Reset all BarcodeScanner stubs to false
export const resetBarcodeScannerStubs = () => {
    _barcodeScannerAvailable = false;
    _userCanceledScan = false;
    _scanThrewAnError = false;
};

// Enables us to stub getBarcodeScanner.isAvailable() to a desired value (or true) from within the component test
export const setBarcodeScannerAvailable = (value = true) => {
    _barcodeScannerAvailable = value;
};

// Enables us to mock user canceling (or not canceling) a scan from within the component test
export const setUserCanceledScan = (value = true) => {
    _userCanceledScan = value;
};

// Enables us to mock there being an error (or not) from within the component test
export const setBarcodeScanError = (value = true) => {
    _scanThrewAnError = value;
};

// Jest mock getBarcodeScanner that returns expected values/"functionality" for all methods and properties accessed in barcodeScanner.js
export const getBarcodeScanner = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(_barcodeScannerAvailable),
        barcodeTypes: jest
            .fn()
            .mockReturnValue({ QR: _barcodeScannerAvailable }),
        beginCapture: jest.fn().mockImplementation(() => {
            // NB: Simultaneously initialising & throwing an Error (e.g. `throw new Error`) will exclude options
            // See https://rollbar.com/guides/javascript/how-to-throw-exceptions-in-javascript

            let error;

            if (_userCanceledScan) {
                error = new Error('User canceled scan');
                error.code = 'userDismissedScanner';
            }

            // ELSE if instead of plain IF to ensure only one error type is assigned
            else if (_scanThrewAnError) {
                error = new Error('There was a problem scanning the code');
                error.code = 'unknownReason';
            }

            if (error) throw error;

            // Return scan result
            return Promise.resolve({ value: '0031700000pJRRWAA4' });
        }),
        endCapture: jest.fn().mockReturnValue(_barcodeScannerAvailable)
    };
});
