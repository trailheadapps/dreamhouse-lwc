import { createElement } from 'lwc';
import PropertyListMap from 'c/propertyListMap';
import getPagedPropertyList from '@salesforce/apex/PropertyController.getPagedPropertyList';

import { subscribe } from 'lightning/messageService';
import FILTERS_CHANGED from '@salesforce/messageChannel/FiltersChange__c';

import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

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

const MOCK_PROPERTIES = {
    records: [
        { Id: 'id1', Location__Latitude__s: 10, Location__Longitude__s: 11 },
        { Id: 'id2', Location__Latitude__s: 20, Location__Longitude__s: 21 }
    ]
};

// Sample error for loadScript error
const LOAD_SCRIPT_ERROR = {
    body: { message: 'Mock load script error has occurred' },
    ok: false,
    status: 400,
    statusText: 'Bad Request'
};

const LEAFLET_STUB = {
    map: () => ({
        setView: () => {},
        scrollWheelZoom: {
            disable: () => {}
        },
        removeLayer: () => {}
    }),
    tileLayer: () => ({
        addTo: () => {}
    }),
    divIcon: () => {},
    marker: () => ({
        on: () => {},
        bindTooltip: () => {}
    }),
    layerGroup: () => ({
        addTo: () => {}
    })
};

describe('c-property-list-map', () => {
    beforeEach(() => {
        // Inject Leaflet stub as a global 'L' variable
        global.L = LEAFLET_STUB;
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        // Reset mocks so that every test run has a clean implementation
        jest.resetAllMocks();
        // Clear leaflet global
        global.L = undefined;
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('registers propertyFilters subscriber during the component lifecycle', () => {
        // Create component
        const element = createElement('c-property-list-map', {
            is: PropertyListMap
        });
        document.body.appendChild(element);

        // Validate if subscriber got registered after connected to the DOM
        expect(subscribe).toHaveBeenCalled();
        expect(subscribe.mock.calls[0][1]).toBe(FILTERS_CHANGED);
    });

    it('loads the leaflet javascript and css static resources', () => {
        // Create component
        const element = createElement('c-property-list-map', {
            is: PropertyListMap
        });
        document.body.appendChild(element);

        // Validation that the loadScript and loadStyle promises
        // are called once.
        expect(loadScript.mock.calls.length).toBe(1);
        expect(loadStyle.mock.calls.length).toBe(1);

        // Validation that the JS and CSS files are passed as parameters.
        expect(loadScript.mock.calls[0][1]).toEqual('leafletjs/leaflet.js');
        expect(loadStyle.mock.calls[0][1]).toEqual('leafletjs/leaflet.css');
    });

    it('fires a toast event if the static resource cannot be loaded', async () => {
        loadScript.mockRejectedValue(LOAD_SCRIPT_ERROR);

        // Create component
        const element = createElement('c-property-list-map', {
            is: PropertyListMap
        });
        document.body.appendChild(element);

        // Mock handler for toast event
        const handler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, handler);

        // Wait for any asynchronous DOM updates
        // We wait twice here in order to ensure that style and script are loaded
        await flushPromises();
        await flushPromises();

        // Check if toast event has been fired
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.title).toBe(
            'Error while loading Leaflet'
        );
        expect(handler.mock.calls[0][0].detail.variant).toBe('error');
    });

    it('fires a toast event when properties cannot be retrieved', async () => {
        // Create component
        const element = createElement('c-property-list-map', {
            is: PropertyListMap
        });
        document.body.appendChild(element);

        // Mock handler for toast event
        const handler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, handler);

        // Emit error from @wire
        getPagedPropertyList.error();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check if toast event has been fired
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.title).toBe(
            'Error loading properties'
        );
        expect(handler.mock.calls[0][0].detail.variant).toBe('error');
    });

    it('updates map when properties are received', async () => {
        // Mock leaflet and add it as a global 'L' variable
        const markerMock = jest.fn(() => ({
            on: () => {},
            bindTooltip: () => {}
        }));
        const layerGroupAddToMock = jest.fn();
        const leafletMock = {
            map: () => ({
                setView: () => {},
                scrollWheelZoom: {
                    disable: () => {}
                },
                removeLayer: () => {}
            }),
            tileLayer: () => ({
                addTo: () => {}
            }),
            divIcon: () => {},
            marker: markerMock,
            layerGroup: () => ({
                addTo: layerGroupAddToMock
            })
        };
        global.L = leafletMock;

        // Create component
        const element = createElement('c-property-list-map', {
            is: PropertyListMap
        });
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Emit mock properties
        getPagedPropertyList.emit(MOCK_PROPERTIES);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check that markers are set up with property data
        expect(markerMock).toHaveBeenCalledTimes(
            MOCK_PROPERTIES.records.length
        );
        MOCK_PROPERTIES.records.forEach((property, index) => {
            expect(markerMock.mock.calls[index][0]).toStrictEqual([
                MOCK_PROPERTIES.records[index].Location__Latitude__s,
                MOCK_PROPERTIES.records[index].Location__Longitude__s
            ]);
        });
        // Check that layer is added to map
        expect(layerGroupAddToMock).toHaveBeenCalled();
    });
});
