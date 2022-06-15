// To activate this mocked device location, add to your test:
//
// import { setDeviceLocationServiceAvailable } from 'lightning/mobileCapabilities';
// setDeviceLocationServiceAvailable(true);
var _deviceLocationServiceAvailable = false;

export const getLocationService = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(_deviceLocationServiceAvailable),
        getCurrentPosition: jest.fn().mockImplementation(() =>
            Promise.resolve({
                latitude: 42.361145,
                longitude: -71.057083
            })
        )
    };
});

export const setDeviceLocationServiceAvailable = (value) => {
    _deviceLocationServiceAvailable = value;
};

let _barcodeScannerAvailable = false;

// Allows us to set the above mock variable to true within the component tests
export const setBarcodeScannerAvailable = (value) =>
    (_barcodeScannerAvailable = true);

// Jest mock getBarcodeScanner that returns expected values/"functionality" for all methods and properties accessed in barcodeScannerExample.js
export const getBarcodeScanner = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(_barcodeScannerAvailable),
        barcodeTypes: jest
            .fn()
            .mockReturnValue({ QR: _barcodeScannerAvailable }),
        beginCapture: jest
            .fn()
            .mockImplementation(() =>
                Promise.resolve({ value: '0031700000pJRRWAA4' })
            ),
        endCapture: jest.fn().mockReturnValue(_barcodeScannerAvailable)
    };
});
