import { createElement } from 'lwc';
import Paginator from 'c/paginator';

describe('c-paginator', () => {
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

    it('sends "next" event on button click', async () => {
        // Create initial element
        const element = createElement('c-paginator', {
            is: Paginator
        });
        // Simulate we are on first page
        element.pageNumber = 1;
        element.pageSize = 10;
        element.totalItemCount = 100;
        document.body.appendChild(element);

        // Mock handlers for child events
        const handlerNext = jest.fn();

        // Add event listener to catch child events
        element.addEventListener('next', handlerNext);

        // Click the next(>) button
        const nextButtonEl =
            element.shadowRoot.querySelector('.right-button-icon');
        nextButtonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate if mocked events got fired
        expect(handlerNext.mock.calls.length).toBe(1);

        // Validate previous button is hidden
        const prevButtonEl =
            element.shadowRoot.querySelector('.left-button-icon');
        expect(prevButtonEl).toBeNull();
    });

    it('sends "previous" event on button click', async () => {
        // Create initial element
        const element = createElement('c-paginator', {
            is: Paginator
        });
        // Simulate we are on last page
        element.pageNumber = 10;
        element.pageSize = 10;
        element.totalItemCount = 100;
        document.body.appendChild(element);

        // Mock handlers for child events
        const handlerPrevious = jest.fn();

        // Add event listener to catch child events
        element.addEventListener('previous', handlerPrevious);

        // Click the Previous(<) button
        const prevButtonEl =
            element.shadowRoot.querySelector('.left-button-icon');
        prevButtonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Validate if mocked events got fired
        expect(handlerPrevious.mock.calls.length).toBe(1);

        // Validate next button is hidden
        const nextButtonEl =
            element.shadowRoot.querySelector('.right-button-icon');
        expect(nextButtonEl).toBeNull();
    });

    it('displays total item count, page number, and number of pages with zero items', () => {
        // Create initial element
        const element = createElement('c-paginator', {
            is: Paginator
        });
        //Set the public property values
        element.pageNumber = 0;
        element.pageSize = 9;
        element.totalItemCount = 0;

        document.body.appendChild(element);

        // Query div for validating the display message on component init
        const lightningLayoutItemEl =
            element.shadowRoot.querySelector('.nav-info');
        //Check for the 0 items message
        expect(lightningLayoutItemEl).not.toBeNull();
        expect(lightningLayoutItemEl.textContent).toBe('0 items • page 0 of 0');
    });

    it('displays total item count, page number, and number of pages with some items', async () => {
        // Create initial element
        const element = createElement('c-paginator', {
            is: Paginator
        });
        document.body.appendChild(element);

        //Set the public properties for item count greater than zero
        element.pageNumber = 1;
        element.pageSize = 9;
        element.totalItemCount = 12;

        // Query div for validating the display message on component init
        const lightningLayoutItemEl =
            element.shadowRoot.querySelector('.nav-info');

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Query div for validating computed style attribute value on public property change
        expect(lightningLayoutItemEl).not.toBeNull();
        expect(lightningLayoutItemEl.textContent).toBe(
            '12 items • page 1 of 2'
        );
    });

    it('is accessible', async () => {
        const element = createElement('c-paginator', {
            is: Paginator
        });

        element.pageNumber = 3;
        element.pageSize = 9;
        element.totalItemCount = 12;
        document.body.appendChild(element);

        await expect(element).toBeAccessible();
    });
});
