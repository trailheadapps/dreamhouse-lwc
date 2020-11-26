import { createElement } from 'lwc';
import PropertyMap from 'c/propertyMap';
import { getRecord } from 'lightning/uiRecordApi';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// Realistic property record
const mockPropertyRecord = require('./data/propertyRecord.json');
const EXPECTED_MAP_MARKERS = [
    {
        location: {
            Latitude: mockPropertyRecord.fields.Location__Latitude__s.value,
            Longitude: mockPropertyRecord.fields.Location__Longitude__s.value
        },
        title: mockPropertyRecord.fields.Address__c.value
    }
];

// Register the test wire adapter
const getRecordAdapter = registerApexTestWireAdapter(getRecord);

describe('c-property-map', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders an error panel when no property is selected', () => {
        const element = createElement('c-property-map', {
            is: PropertyMap
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const panelEl = element.shadowRoot.querySelector('c-error-panel');
            expect(panelEl).not.toBeNull();
        });
    });

    it('renders a map when a property is selected', () => {
        const element = createElement('c-property-map', {
            is: PropertyMap
        });
        document.body.appendChild(element);

        // Simulate property selection
        getRecordAdapter.emit(mockPropertyRecord);

        return Promise.resolve().then(() => {
            const mapEl = element.shadowRoot.querySelector('lightning-map');
            expect(mapEl).not.toBeNull();
            expect(mapEl.mapMarkers).toStrictEqual(EXPECTED_MAP_MARKERS);
        });
    });

    it('is accessible when property is selected', () => {
        const element = createElement('c-property-map', {
            is: PropertyMap
        });

        document.body.appendChild(element);

        // Simulate property selection
        getRecordAdapter.emit(mockPropertyRecord);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
        });
    });

    it('is accessible when property is not selected', () => {
        const element = createElement('c-property-map', {
            is: PropertyMap
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
        });
    });
});
