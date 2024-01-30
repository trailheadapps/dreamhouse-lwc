import { api, LightningElement } from 'lwc';
import generateSocialMediaPosts from '@salesforce/apex/PropertyController.generateSocialMediaPosts';

export default class GenerateSocialMediaPosts extends LightningElement {
    twitterPost;
    linkedinPost;
    error;
    @api recordId;

    async generateSocialMediaPosts() {
        try {
            const posts = await generateSocialMediaPosts({
                propertyId: this.recordId
            });
            const parsedPosts = JSON.parse(posts);
            this.twitterPost = parsedPosts.twitter;
            this.linkedinPost = parsedPosts.linkedin;
        } catch (error) {
            this.error = error;
        }
    }
}
