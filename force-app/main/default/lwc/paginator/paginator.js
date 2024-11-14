import { LightningElement, api } from 'lwc';

const MAX_ITEM_OFFSET = 2000;

export default class Paginator extends LightningElement {
    /** The current page number. */
    @api pageNumber;

    /** The number of items on a page. */
    @api pageSize;

    /** The total number of items in the list. */
    @api totalItemCount;

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    get isNotFirstPage() {
        return this.pageNumber > 1;
    }

    get isNotLastPage() {
        return (
            this.pageNumber < this.totalPages &&
            this.pageNumber * this.pageSize < MAX_ITEM_OFFSET
        );
    }

    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }
}
