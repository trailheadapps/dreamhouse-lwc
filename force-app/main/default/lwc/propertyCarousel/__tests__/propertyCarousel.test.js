import { createElement } from 'lwc';
import PropertyCarousel from 'c/propertyCarousel';
import { getRecord } from 'lightning/uiRecordApi';
import getPictures from '@salesforce/apex/PropertyController.getPictures';

// Realistic data with multiple records
const mockGetPictures = require('./data/getPictures.json');

// Mock realistic data
const mockGetPropertyRecord = require('./data/getPropertyRecord.json');

// Mock getPictures Apex wire adapter
jest.mock(
    '@salesforce/apex/PropertyController.getPictures',
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

describe('c-property-carousel', () => {
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
        it('renders carousel with pictures when property and pictures returned', async () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecord.emit(mockGetPropertyRecord);

            // Emit mock pictures
            getPictures.emit(mockGetPictures);

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const carouselEl =
                element.shadowRoot.querySelector('lightning-carousel');
            expect(carouselEl).not.toBeNull();
            const carouselImageEls = element.shadowRoot.querySelectorAll(
                'lightning-carousel-image'
            );
            expect(carouselImageEls.length).toBe(mockGetPictures.length);
        });

        it('renders no pictures message when property but no pictures returned', async () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecord.emit(mockGetPropertyRecord);

            // Emit no pictures
            getPictures.emit(null);

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const pEl = element.shadowRoot.querySelector(
                'p.slds-text-align_center'
            );
            expect(pEl).not.toBeNull();
            expect(pEl.textContent).toBe(
                'There are currently no pictures for this property.'
            );
        });

        it('renders error when getProperty returns error', async () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit error
            getRecord.error();

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const errorPanelEl =
                element.shadowRoot.querySelector('c-error-panel');
            expect(errorPanelEl).not.toBeNull();
        });

        it('renders error when getPictures returns error', async () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecord.emit(mockGetPropertyRecord);

            // Emit error
            getPictures.error();

            // Wait for any asynchronous DOM updates
            await flushPromises();

            const errorPanelEl =
                element.shadowRoot.querySelector('c-error-panel');
            expect(errorPanelEl).not.toBeNull();
        });
    });
});
