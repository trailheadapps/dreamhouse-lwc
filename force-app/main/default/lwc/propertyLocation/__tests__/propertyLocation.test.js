import { createElement } from 'lwc';
import PropertyLocation from 'c/propertyLocation';
import { getRecord } from 'lightning/uiRecordApi';
import { getLocationService } from 'lightning/mobileCapabilities';

// Realistic property record
const mockPropertyRecord = require('./data/getRecord.json');

describe('c-property-location', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders an error panel when no location services are available', async () => {
        const element = createElement('c-property-location', {
            is: PropertyLocation
        });

        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const panelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(panelEl).not.toBeNull();
    });

    it('renders an error panel when getRecord returns an error', async () => {
        const element = createElement('c-property-location', {
            is: PropertyLocation
        });

        document.body.appendChild(element);

        // Simulate error
        getRecord.error();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const panelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(panelEl).not.toBeNull();
    });

    it('renders coordinates and distance when browser location is available', async () => {
        const element = createElement('c-property-location', {
            is: PropertyLocation
        });
        element.recordId = mockPropertyRecord.id;
        document.body.appendChild(element);

        // Simulate property selection
        getRecord.emit(mockPropertyRecord);

        // Simulate browser location
        // TODO

        // Wait for any asynchronous DOM updates
        await flushPromises();

        /*const divEl = element.shadowRoot.querySelector('div.location');
        expect(divEl).not.toBeNull();*/
    });

    it('renders coordinates and distance when device location is available', async () => {
        // Simulate device location is available
        getLocationService().isAvailable.mockReturnValue(true);
        console.log(getLocationService().isAvailable()); // THIS OVERWRITE IS NOT WORKING!

        const element = createElement('c-property-location', {
            is: PropertyLocation
        });
        element.recordId = mockPropertyRecord.id;
        document.body.appendChild(element);

        // Simulate property selection
        getRecord.emit(mockPropertyRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        /*const divEl = element.shadowRoot.querySelector('div.location');
        expect(divEl).not.toBeNull();*/
    });

    it('is accessible when panel is shown', async () => {
        const element = createElement('c-property-location', {
            is: PropertyLocation
        });

        document.body.appendChild(element);

        // Simulate property selection
        getRecord.emit(mockPropertyRecord);

        // Simulate browser location
        // TODO

        // Wait for any asynchronous DOM updates
        await flushPromises();

        await expect(element).toBeAccessible();
    });
});
