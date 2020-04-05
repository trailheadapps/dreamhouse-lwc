import { LightningElement } from 'lwc';

export default class TreeBasic extends LightningElement {
    items = [
        {
            label: 'Western Sales Director',
            name: '1',
            expanded: true,
            items: [
                {
                    label: 'Western Sales Manager',
                    name: '2',
                    expanded: true,
                    items: [
                        {
                            label: 'CA Sales Rep',
                            name: '3',
                            expanded: true,
                            items: [],
                        },
                        {
                            label: 'OR Sales Rep',
                            name: '4',
                            expanded: true,
                            items: [],
                        },
                    ],
                },
            ],
        },
        {
            label: 'Eastern Sales Director',
            name: '5',
            expanded: false,
            items: [
                {
                    label: 'Easter Sales Manager',
                    name: '6',
                    expanded: true,
                    items: [
                        {
                            label: 'NY Sales Rep',
                            name: '7',
                            expanded: true,
                            items: [],
                        },
                        {
                            label: 'MA Sales Rep',
                            name: '8',
                            expanded: true,
                            items: [],
                        },
                    ],
                },
            ],
        },
        {
            label: 'International Sales Director',
            name: '9',
            expanded: true,
            items: [
                {
                    label: 'Asia Sales Manager',
                    name: '10',
                    expanded: true,
                    items: [
                        {
                            label: 'Sales Rep1',
                            name: '11',
                            expanded: true,
                            items: [],
                        },
                        {
                            label: 'Sales Rep2',
                            name: '12',
                            expanded: true,
                            items: [],
                        },
                    ],
                },
                {
                    label: 'Europe Sales Manager',
                    name: '13',
                    expanded: false,
                    items: [
                        {
                            label: 'Sales Rep1',
                            name: '14',
                            expanded: true,
                            items: [],
                        },
                        {
                            label: 'Sales Rep2',
                            name: '15',
                            expanded: true,
                            items: [],
                        },
                    ],
                },
            ],
        },
    ];
}
