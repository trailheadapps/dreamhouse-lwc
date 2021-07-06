import { createElement } from 'lwc';
import PropertyTileList from 'c/propertyTileList';
import getPagedPropertyList from '@salesforce/apex/PropertyController.getPagedPropertyList';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';

// Realistic data with multiple records
const mockgetPagedPropertyList = require('./data/getPagedPropertyList.json');

// Mock getPagedPropertyList Apex wire adapter
jest.mock(
    '@salesforce/apex/PropertyController.getPagedPropertyList',
    () => {
        const {
            createApexTestWireAdapter
        } = require('@salesforce/sfdx-lwc-jest');
        return {
            default: createApexTestWireAdapter(jest.fn())
        };
    },
    { virtual: true }
);

describe('c-property-tile-list', () => {
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

    describe('@wire data', () => {
        it('renders properties when data returned', async () => {
            const element = createElement('c-property-tile-list', {
                is: PropertyTileList
            });
            document.body.appendChild(element);

            // Emit mock properties
            getPagedPropertyList.emit(mockgetPagedPropertyList);

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const propertyTileEls =
                element.shadowRoot.querySelectorAll('c-property-tile');
            expect(propertyTileEls.length).toBe(
                mockgetPagedPropertyList.records.length
            );
        });

        it('renders error panel when error returned', async () => {
            const element = createElement('c-property-tile-list', {
                is: PropertyTileList
            });
            document.body.appendChild(element);

            // Emit error
            getPagedPropertyList.error();

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const errorPanelEl =
                element.shadowRoot.querySelector('c-error-panel');
            expect(errorPanelEl).not.toBeNull();
        });
    });

    it('registers propertyFilters subscriber during the component lifecycle', () => {
        const element = createElement('c-property-tile-list', {
            is: PropertyTileList
        });
        document.body.appendChild(element);

        // Validate if subscriber got registered after connected to the DOM
        expect(subscribe).toHaveBeenCalled();
        expect(subscribe.mock.calls[0][1]).toBe(FILTERSCHANGEMC);
    });

    it('invokes getPagedPropertyList with the propertyFilters message payload value', async () => {
        const element = createElement('c-property-tile-list', {
            is: PropertyTileList
        });
        document.body.appendChild(element);

        // Simulate pulishing a message using FILTERSCHANGEMC message channel
        const messagePayload = {
            searchKey: 'victorian',
            maxPrice: 400000,
            minBedrooms: 4,
            minBathrooms: 2
        };
        publish(MessageContext, FILTERSCHANGEMC, messagePayload);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // The component subscription should cause getRecord to be invoked.
        // Below we test that it is invoked with the messagePayload value
        // that was published with the simulated publish invocation above.
        const receivedPayload = getPagedPropertyList.getLastConfig();
        expect(receivedPayload.searchKey).toBe(messagePayload.searchKey);
        expect(receivedPayload.maxPrice).toBe(messagePayload.maxPrice);
        expect(receivedPayload.minBedrooms).toBe(messagePayload.minBedrooms);
        expect(receivedPayload.minBathrooms).toBe(messagePayload.minBathrooms);
    });

    it('sends propertySelected event when c-property-tile selected', async () => {
        const element = createElement('c-property-tile-list', {
            is: PropertyTileList
        });
        document.body.appendChild(element);
        getPagedPropertyList.emit(mockgetPagedPropertyList);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const propertyTile =
            element.shadowRoot.querySelector('c-property-tile');
        propertyTile.dispatchEvent(new CustomEvent('selected'));
        expect(publish).toHaveBeenCalledWith(undefined, PROPERTYSELECTEDMC, {
            propertyId: null
        });
    });
});
