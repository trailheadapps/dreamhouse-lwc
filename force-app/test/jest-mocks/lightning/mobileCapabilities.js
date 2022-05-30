// To activate this mocked device location, add to your test:
//
// import { setAvailable } from 'lightning/mobileCapabilities';
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
