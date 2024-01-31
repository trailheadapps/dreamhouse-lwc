import { api, LightningElement } from 'lwc';
import generateSocialMediaPosts from '@salesforce/apex/PropertyController.generateSocialMediaPosts';
import { copyTextToClipboard } from 'c/copyTextToClipboard';

export default class GenerateSocialMediaPosts extends LightningElement {
    twitterPost;
    linkedinPost;
    error;
    showSpinner = false;
    @api recordId;

    async generateSocialMediaPosts() {
        this.showSpinner = true;
        try {
            const posts = await generateSocialMediaPosts({
                propertyId: this.recordId
            });
            const parsedPosts = JSON.parse(posts);
            this.twitterPost = parsedPosts.twitter;
            this.linkedinPost = parsedPosts.linkedin;
        } catch (error) {
            this.error = error;
        } finally {
            this.showSpinner = false;
        }
    }

    async copyTwitter() {
        await copyTextToClipboard(this.twitterPost);
    }

    async copyLinkedin() {
        await copyTextToClipboard(this.linkedinPost);
    }
}
