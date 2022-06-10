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

// TODO: Explain comments
export const getBarcodeScanner = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(true),
        barcodeTypes: jest.fn().mockReturnValue({ QR: true }),
        beginCapture: jest
            .fn()
            .mockImplementation(() =>
                Promise.resolve({ value: '0031700000pJRRWAA4' })
            ),
        endCapture: jest.fn().mockReturnValue(true)
    };
});
