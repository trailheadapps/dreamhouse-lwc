import { createElement } from 'lwc';
import PropertyTile from 'c/propertyTile';

const PROPERTY_DETAILS = {
    City__c: 'Some City',
    Beds__c: '3',
    Baths__c: '1',
    Price__c: '450000',
    Thumbnail__c: 'some-property.jpg'
};

describe('c-property-tile', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('displays a property in the tile', () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY_DETAILS;
        document.body.appendChild(element);

        const headerEl = element.shadowRoot.querySelector('.truncate');
        expect(headerEl.textContent).toBe(PROPERTY_DETAILS.City__c);

        const pElement = element.shadowRoot.querySelector('p');
        expect(pElement.textContent).toBe(
            `Beds: ${PROPERTY_DETAILS.Beds__c} - Baths: ${PROPERTY_DETAILS.Baths__c}`
        );

        const priceElement = element.shadowRoot.querySelector(
            'lightning-formatted-number'
        );
        expect(priceElement.value).toBe(PROPERTY_DETAILS.Price__c);
    });

    it('displays the correct background image in the tile', () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY_DETAILS;
        document.body.appendChild(element);

        const bgElement = element.shadowRoot.querySelector('.tile');
        expect(bgElement.style.backgroundImage).toBe(
            `url(${PROPERTY_DETAILS.Thumbnail__c})`
        );
    });

    it('fires the property selected event on click', () => {
        const element = createElement('c-property-tile', {
            is: PropertyTile
        });
        element.property = PROPERTY_DETAILS;
        document.body.appendChild(element);

        // Mock handler for child event
        const handler = jest.fn();
        element.addEventListener('selected', handler);

        const anchorEl = element.shadowRoot.querySelector('a');
        anchorEl.click();

        return Promise.resolve().then(() => {
            // Validate if event got fired
            expect(handler).toHaveBeenCalled();
        });
    });
});
