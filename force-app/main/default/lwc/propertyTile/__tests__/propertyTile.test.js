import { createElement } from 'lwc';
import PropertyTile from 'c/propertyTile';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getNavigateCalledWith } from 'lightning/navigation';

const PROPERTY = {
    City__c: 'Some City',
    Beds__c: '3',
    Baths__c: '1',
    Price__c: '450000',
    Thumbnail__c: 'some-property.jpg',
    Id: '12345'
};

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

    it('displays a property in the tile', () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY;
        document.body.appendChild(element);

        const headerEl = element.shadowRoot.querySelector('.truncate');
        expect(headerEl.textContent).toBe(PROPERTY.City__c);

        const paragraphEl = element.shadowRoot.querySelector('p');
        expect(paragraphEl.textContent).toBe(
            `Beds: ${PROPERTY.Beds__c} - Baths: ${PROPERTY.Baths__c}`
        );

        const priceEl = element.shadowRoot.querySelector(
            'lightning-formatted-number'
        );
        expect(priceEl.value).toBe(PROPERTY.Price__c);
    });

    it('displays the correct background image in the tile', () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY;
        document.body.appendChild(element);

        const backgroundEl = element.shadowRoot.querySelector('.tile');
        expect(backgroundEl.style.backgroundImage).toBe(
            `url(${PROPERTY.Thumbnail__c})`
        );
    });

    it('Fires the property selected event on click for non Small formFactors', async () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY;
        document.body.appendChild(element);

        // Mock handler for child event
        const handler = jest.fn();
        element.addEventListener('selected', handler);

        const anchorEl = element.shadowRoot.querySelector('a');
        anchorEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate if event got fired
        expect(handler).toHaveBeenCalled();
        const selectEvent = handler.mock.calls[0][0];
        expect(selectEvent.detail).toBe(PROPERTY.Id);
    });

    it('Navigates to property record page on click for Small formFactor', async () => {
        const NAV_TYPE = 'standard__recordPage';
        const NAV_ACTION_NAME = 'view';
        const NAV_OBJECT_API_NAME = 'Property__c';

        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY;
        document.body.appendChild(element);

        // Mock handler for child event
        const handler = jest.fn();
        element.addEventListener('selected', handler);

        // Mock formFactor
        FORM_FACTOR = 'Small';

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

    it('is accessible', async () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });

        element.property = PROPERTY;
        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});
