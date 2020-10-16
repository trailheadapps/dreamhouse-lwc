import { createElement } from 'lwc';
import PropertyTileList from 'c/propertyTileList';
import getPagedPropertyList from '@salesforce/apex/PropertyController.getPagedPropertyList';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import FILTERSCHANGEMC from '@salesforce/messageChannel/FiltersChange__c';
import PROPERTYSELECTEDMC from '@salesforce/messageChannel/PropertySelected__c';
import {
    registerTestWireAdapter,
    registerApexTestWireAdapter
} from '@salesforce/sfdx-lwc-jest';

// Realistic data with multiple records
const mockGetPagedProperties = require('./data/getPagedPropertyList.json');

// Register the Apex wire adapter
const getPagedPropertiesAdapter = registerApexTestWireAdapter(
    getPagedPropertyList
);

// Register as a standard wire adapter because the component under test requires this adapter.
// We don't exercise this wire adapter in the tests.
const messageContextWireAdapter = registerTestWireAdapter(MessageContext);

describe('c-property-tile-list', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    describe('@wire data', () => {
        it('renders properties when data returned', () => {
            const element = createElement('c-property-tile-list', {
                is: PropertyTileList
            });
            document.body.appendChild(element);

            // Emit mock properties
            getPagedPropertiesAdapter.emit(mockGetPagedProperties);

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const propertyTileEls = element.shadowRoot.querySelectorAll(
                    'c-property-tile'
                );
                expect(propertyTileEls.length).toBe(
                    mockGetPagedProperties.records.length
                );
            });
        });

        it('renders error panel when error returned', () => {
            const element = createElement('c-property-tile-list', {
                is: PropertyTileList
            });
            document.body.appendChild(element);

            // Emit error
            getPagedPropertiesAdapter.error();

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const errorPanelEl = element.shadowRoot.querySelector(
                    'c-error-panel'
                );
                expect(errorPanelEl).not.toBeNull();
            });
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

    it('invokes getPagedProperties with the propertyFilters message payload value', () => {
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
        publish(messageContextWireAdapter, FILTERSCHANGEMC, messagePayload);

        return Promise.resolve().then(() => {
            // The component subscription should cause getRecord to be invoked.
            // Below we test that it is invoked with the messagePayload value
            // that was published with the simulated publish invocation above.
            const receivedPayload = getPagedPropertiesAdapter.getLastConfig();
            expect(receivedPayload.searchKey).toBe(messagePayload.searchKey);
            expect(receivedPayload.maxPrice).toBe(messagePayload.maxPrice);
            expect(receivedPayload.minBedrooms).toBe(
                messagePayload.minBedrooms
            );
            expect(receivedPayload.minBathrooms).toBe(
                messagePayload.minBathrooms
            );
        });
    });

    it('sends propertySelected event when c-property-tile selected', () => {
        const element = createElement('c-property-tile-list', {
            is: PropertyTileList
        });
        document.body.appendChild(element);
        getPagedPropertiesAdapter.emit(mockGetPagedProperties);

        return Promise.resolve().then(() => {
            const propertyTile = element.shadowRoot.querySelector(
                'c-property-tile'
            );
            propertyTile.dispatchEvent(new CustomEvent('selected'));
            expect(publish).toHaveBeenCalledWith(
                undefined,
                PROPERTYSELECTEDMC,
                { propertyId: null }
            );
        });
    });
});
