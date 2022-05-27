// To activate this mocked device location, add to your test:
//
// getLocationService().isAvailable.mockReturnValue(true);
export const getLocationService = jest.fn().mockImplementation(() => {
    return {
        isAvailable: jest.fn().mockReturnValue(false),
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
