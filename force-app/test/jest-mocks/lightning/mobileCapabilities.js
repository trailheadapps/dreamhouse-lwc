// To activate this mocked device location, add to your test:
//
// import { setDeviceLocationServiceAvailable } from 'lightning/mobileCapabilities';
// setDeviceLocationServiceAvailable(true);
var _available = false;

export const getLocationService = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(_available),
        getCurrentPosition: jest.fn().mockImplementation(() =>
            Promise.resolve({
                latitude: 42.361145,
                longitude: -71.057083
            })
        )
    };
});

export const setDeviceLocationServiceAvailable = (value) => {
    _available = value;
};

// TODO: @Alba, should this use the same variable and method as above or no?
// If yes, should we rename the variable and method?
// If no, should we rename _available?
let _barcodeScannerAvailable = false;
export const setBarcodeScannerAvailable = (value) =>
    (_barcodeScannerAvailable = true);

// TODO: Explain in comments
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
