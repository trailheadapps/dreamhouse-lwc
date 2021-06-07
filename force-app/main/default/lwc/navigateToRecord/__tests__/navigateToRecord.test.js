import { createElement } from 'lwc';
import NavigateToRecord from 'c/navigateToRecord';
import { getNavigateCalledWith } from 'lightning/navigation';

describe('c-navigate-to-record', () => {
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

    it('navigates to record view', async () => {
        // Nav param values to test later
        const NAV_TYPE = 'standard__recordPage';
        const NAV_ACTION_NAME = 'view';
        const NAV_RECORD_ID = '0031700000pJRRWAA4';

        // Create initial lwc element and attach to virtual DOM
        const element = createElement('c-navigate-to-record', {
            is: NavigateToRecord
        });

        element.recordId = NAV_RECORD_ID;
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        const { pageReference } = getNavigateCalledWith();

        // Verify component called with correct event type and params
        expect(pageReference.type).toBe(NAV_TYPE);
        expect(pageReference.attributes.actionName).toBe(NAV_ACTION_NAME);
        expect(pageReference.attributes.recordId).toBe(NAV_RECORD_ID);
    });
});
