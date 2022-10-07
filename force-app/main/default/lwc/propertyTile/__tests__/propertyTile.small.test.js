import { createElement } from 'lwc';
import PropertyTile from 'c/propertyTile';
import { getNavigateCalledWith } from 'lightning/navigation';

const PROPERTY = {
    City__c: 'Some City',
    Beds__c: '3',
    Baths__c: '1',
    Price__c: '450000',
    Thumbnail__c: 'some-property.jpg',
    Id: '12345'
};

// Mock small formFactor -> Currently this test resides
// in a different file because there is no way to reassign the mock dynamically
jest.mock(
    '@salesforce/client/formFactor',
    () => {
        return { default: 'Small' };
    },
    { virtual: true }
);

describe('c-property-tile', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    it('Navigates to property record page on click for Small formFactor', async () => {
        const NAV_TYPE = 'standard__recordPage';
        const NAV_ACTION_NAME = 'view';
        const NAV_OBJECT_API_NAME = 'Property__c';

        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY;
        document.body.appendChild(element);

        const anchorEl = element.shadowRoot.querySelector('a');
        anchorEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get data the NavigationMixin was called with
        const { pageReference } = getNavigateCalledWith();

        // Confirm redirection to expected property record
        expect(pageReference.type).toBe(NAV_TYPE);
        expect(pageReference.attributes.actionName).toBe(NAV_ACTION_NAME);
        expect(pageReference.attributes.objectApiName).toBe(
            NAV_OBJECT_API_NAME
        );
        expect(pageReference.attributes.recordId).toBe(PROPERTY.Id);
    });
});
