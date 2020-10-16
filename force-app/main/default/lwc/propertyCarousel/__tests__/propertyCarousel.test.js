import { createElement } from 'lwc';
import PropertyCarousel from 'c/propertyCarousel';
import { getRecord } from 'lightning/uiRecordApi';
import getPictures from '@salesforce/apex/PropertyController.getPictures';

import {
    registerApexTestWireAdapter,
    registerLdsTestWireAdapter
} from '@salesforce/sfdx-lwc-jest';

// Realistic data with multiple records
const mockGetPictures = require('./data/getPictures.json');

// Mock realistic data
const mockGetPropertyRecord = require('./data/getPropertyRecord.json');

// Register the Apex wire adapter
const getPicturesAdapter = registerApexTestWireAdapter(getPictures);

// Register the LDS wire adapter
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

describe('c-property-carousel', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    describe('@wire data', () => {
        it('renders carousel with pictures when property and pictures returned', () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecordAdapter.emit(mockGetPropertyRecord);

            // Emit mock pictures
            getPicturesAdapter.emit(mockGetPictures);

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const carouselEl = element.shadowRoot.querySelector(
                    'lightning-carousel'
                );
                expect(carouselEl).not.toBeNull();
                const carouselImageEls = element.shadowRoot.querySelectorAll(
                    'lightning-carousel-image'
                );
                expect(carouselImageEls.length).toBe(mockGetPictures.length);
            });
        });

        it('renders no pictures message when property but no pictures returned', () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecordAdapter.emit(mockGetPropertyRecord);

            // Emit no pictures
            getPicturesAdapter.emit(null);

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const pEl = element.shadowRoot.querySelector(
                    'p.slds-text-align_center'
                );
                expect(pEl).not.toBeNull();
                expect(pEl.textContent).toBe(
                    'There are currently no pictures for this property.'
                );
            });
        });

        it('renders error when getProperty returns error', () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit error
            getRecordAdapter.error();

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const errorPanelEl = element.shadowRoot.querySelector(
                    'c-error-panel'
                );
                expect(errorPanelEl).not.toBeNull();
            });
        });

        it('renders error when getPictures returns error', () => {
            const element = createElement('c-property-carousel', {
                is: PropertyCarousel
            });
            document.body.appendChild(element);

            // Emit mock property
            getRecordAdapter.emit(mockGetPropertyRecord);

            // Emit error
            getPicturesAdapter.error();

            // Return a promise to wait for any asynchronous DOM updates.
            return Promise.resolve().then(() => {
                const errorPanelEl = element.shadowRoot.querySelector(
                    'c-error-panel'
                );
                expect(errorPanelEl).not.toBeNull();
            });
        });
    });
});
