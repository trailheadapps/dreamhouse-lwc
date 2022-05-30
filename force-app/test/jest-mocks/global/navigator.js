// Mock browser geolocation service this way:
// import { mockGeolocation } from '../../../../../test/jest-mocks/global/navigator';
// navigator.geolocation = mockGeolocation;
export const mockGeolocation = {
    getCurrentPosition: jest.fn().mockImplementation((success) =>
        Promise.resolve(
            success({
                coords: {
                    latitude: 42.361145,
                    longitude: -71.057083
                }
            })
        )
    )
};
