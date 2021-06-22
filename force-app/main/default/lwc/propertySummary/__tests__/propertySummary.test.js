import { createElement } from 'lwc';
import PropertySummary from 'c/propertySummary';
import { getRecord } from 'lightning/uiRecordApi';

// Realistic property record
const mockPropertyRecord = require('./data/getRecord.json');

describe('c-property-summary', () => {
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

    it('renders an error panel when no property is selected', async () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const panelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(panelEl).not.toBeNull();
    });

    it('renders an error panel when getRecord returns an error', async () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        // Simulate error
        getRecord.error();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const panelEl = element.shadowRoot.querySelector('c-error-panel');
        expect(panelEl).not.toBeNull();
    });

    it('renders a lightning-record-form when a property is selected', async () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });
        element.recordId = mockPropertyRecord.id;
        document.body.appendChild(element);

        // Simulate property selection
        getRecord.emit(mockPropertyRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const formEl = element.shadowRoot.querySelector(
            'lightning-record-form'
        );
        expect(formEl).not.toBeNull();
        expect(formEl.recordId).toStrictEqual(mockPropertyRecord.id);
    });

    it('is accessible when property is selected', async () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        // Simulate property selection
        getRecord.emit(mockPropertyRecord);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        await expect(element).toBeAccessible();
    });

    it('is accessible when property is not selected', async () => {
        const element = createElement('c-property-summary', {
            is: PropertySummary
        });

        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});
