import { createElement } from 'lwc';
import PropertySummary from 'c/propertySummary';
import { getRecord } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter } from '@salesforce/sfdx-lwc-jest';

// Realistic property record
const mockPropertyRecord = require('./data/getRecord.json');

// Register the test wire adapter
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

describe('c-property-summary', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    it('renders an error panel when no property is selected', () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            const panelEl = element.shadowRoot.querySelector('c-error-panel');
            expect(panelEl).not.toBeNull();
        });
    });

    it('renders an error panel when getRecord returns an error', () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        // Simulate error
        getRecordAdapter.error();

        return Promise.resolve().then(() => {
            const panelEl = element.shadowRoot.querySelector('c-error-panel');
            expect(panelEl).not.toBeNull();
        });
    });

    it('renders a lightning-record-form when a property is selected', () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });
        element.recordId = mockPropertyRecord.id;
        document.body.appendChild(element);

        // Simulate property selection
        getRecordAdapter.emit(mockPropertyRecord);

        return Promise.resolve().then(() => {
            const formEl = element.shadowRoot.querySelector(
                'lightning-record-form'
            );
            expect(formEl).not.toBeNull();
            expect(formEl.recordId).toStrictEqual(mockPropertyRecord.id);
        });
    });

    it('is accessible when property is selected', () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        // Simulate property selection
        getRecordAdapter.emit(mockPropertyRecord);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
        });
    });

    it('is accessible when property is not selected', () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            expect(element).toBeAccessible();
        });
    });
});
