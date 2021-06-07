import { createElement } from 'lwc';
import SampleDataImporter from 'c/sampleDataImporter';
import { ShowToastEventName } from 'lightning/platformShowToastEvent';
import importSampleData from '@salesforce/apex/SampleDataController.importSampleData';

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/SampleDataController.importSampleData',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Sample data for imperative Apex call
const APEX_OPERATION_SUCCESS = null;

// Sample error for imperative Apex call
const APEX_OPERATION_ERROR = {
    message: 'An internal server error has occurred'
};

describe('c-sample-data-importer', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // Prevent data saved on mocks from leaking between tests
        jest.clearAllMocks();
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('fires success event when importSampleData runs successfully', async () => {
        // Assign mock value for resolved Apex promise
        importSampleData.mockResolvedValue(APEX_OPERATION_SUCCESS);

        // Create initial element
        const element = createElement('c-sample-data-importer', {
            is: SampleDataImporter
        });
        document.body.appendChild(element);

        // Mock handler for toast event
        const handler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, handler);

        // Select button for executing Apex call
        const buttonEl = element.shadowRoot.querySelector('lightning-button');
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check if toast event has been fired
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.variant).toBe('success');
        expect(handler.mock.calls[0][0].detail.title).toBe('Success');
        expect(handler.mock.calls[0][0].detail.message).toBe(
            'Sample data successfully imported'
        );
    });

    it('fires error event when importSampleData runs with error', async () => {
        // Assign mock value for resolved Apex promise
        importSampleData.mockRejectedValue(APEX_OPERATION_ERROR);

        // Create initial element
        const element = createElement('c-sample-data-importer', {
            is: SampleDataImporter
        });
        document.body.appendChild(element);

        // Mock handler for toast event
        const handler = jest.fn();
        // Add event listener to catch toast event
        element.addEventListener(ShowToastEventName, handler);

        // Select button for executing Apex call
        const buttonEl = element.shadowRoot.querySelector('lightning-button');
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check if toast event has been fired
        expect(handler).toHaveBeenCalled();
        expect(handler.mock.calls[0][0].detail.variant).toBe('error');
        expect(handler.mock.calls[0][0].detail.title).toBe(
            'Error while importing data'
        );
        expect(handler.mock.calls[0][0].detail.message).toBe(
            APEX_OPERATION_ERROR.message
        );
    });

    it('is accessible', async () => {
        const element = createElement('c-sample-data-importer', {
            is: SampleDataImporter
        });

        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});
