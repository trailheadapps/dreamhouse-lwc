{
    "meta": {
        "current-page": 1,
        "per-page": 100,
        "from": 1,
        "to": 4,
        "total": 4,
        "last-page": 1,
        "total_resources": 4,
        "resources_per_page": 100
    },
    "links": {
        "first": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance?page%5Bnumber%5D=1&page%5Bsize%5D=100",
        "last": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance?page%5Bnumber%5D=1&page%5Bsize%5D=100"
    },
    "data": [
        {
            "type": "salesforce-instance",
            "id": "195",
            "attributes": {
                "description": "SF_PROD2",
                "environment-id": 1,
                "environment": "Development",
                "service-name": "Salesforce",
                "url": "https:\/\/eu8.salesforce.com",
                "login-url": "https:\/\/login.salesforce.com",
                "last-scan-test-result": "FAIL",
                "last-scan-test-datetime": "2019-08-07 14:58:01",
                "last-scan-test-details": "Authentication Failure. Check credentials and verify that the user is configured with local authentication.",
                "target": "org",
                "is-feature-branch": false,
                "git-flavor-id": null,
                "git-repository-url": null,
                "git-branch": null,
                "go-live": "0000-00-00",
                "dont-persist-credentials": false,
                "org-id": null
            },
            "links": {
                "self": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance\/195"
            }
        },
        {
            "type": "salesforce-instance",
            "id": "209",
            "attributes": {
                "description": "SF_INNOVA",
                "environment-id": 1,
                "environment": "Development",
                "service-name": "Salesforce",
                "url": "https:\/\/login.salesforce.com\/",
                "login-url": null,
                "last-scan-test-result": "FAIL",
                "last-scan-test-datetime": "2019-03-20 20:44:27",
                "last-scan-test-details": "Required parameter with invalid value",
                "target": "org",
                "is-feature-branch": false,
                "git-flavor-id": null,
                "git-repository-url": null,
                "git-branch": null,
                "go-live": null,
                "dont-persist-credentials": false,
                "org-id": null
            },
            "links": {
                "self": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance\/209"
            }
        },
        {
            "type": "salesforce-instance",
            "id": "315",
            "attributes": {
                "description": "Feature Branch Test",
                "environment-id": 1,
                "environment": "Development",
                "service-name": "Salesforce",
                "url": "",
                "login-url": "https:\/\/login.salesforce.com",
                "last-scan-test-result": "SUCCESS",
                "last-scan-test-datetime": "2019-09-05 10:18:17",
                "last-scan-test-details": "SUCCESS",
                "target": "git",
                "is-feature-branch": true,
                "git-flavor-id": 1,
                "git-repository-url": "https:\/\/github.com\/jluesma\/qualitycloudssalesforceapp.git",
                "git-branch": null,
                "go-live": "0000-00-00",
                "dont-persist-credentials": false,
                "org-id": null
            },
            "links": {
                "self": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance\/315"
            }
        },
        {
            "type": "salesforce-instance",
            "id": "348",
            "attributes": {
                "description": "SF_GIT_TEST",
                "environment-id": 1,
                "environment": "Development",
                "service-name": "Salesforce",
                "url": "",
                "login-url": "https:\/\/login.salesforce.com",
                "last-scan-test-result": "SUCCESS",
                "last-scan-test-datetime": "2019-09-05 10:14:49",
                "last-scan-test-details": "SUCCESS",
                "target": "git",
                "is-feature-branch": false,
                "git-flavor-id": 1,
                "git-repository-url": "https:\/\/github.com\/jluesma\/qualitycloudssalesforceapp.git",
                "git-branch": "master",
                "go-live": "0000-00-00",
                "dont-persist-credentials": false,
                "org-id": null
            },
            "links": {
                "self": "https:\/\/dev.qualityclouds.com\/api\/v2\/salesforce-instance\/348"
            }
        }
    ]
}
