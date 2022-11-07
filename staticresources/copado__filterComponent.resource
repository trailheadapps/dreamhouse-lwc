// Data Template Setup Javascript
var fc = fc || {};
var globalSldsResourcePath = globalSldsResourcePath ? globalSldsResourcePath : undefined;

((app) => {
    'use strict';

    var iconsList = [{
            svgButtonsClass: 'warningToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'warning'
        },
        {
            svgButtonsClass: 'successToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'success'
        },
        {
            svgButtonsClass: 'errorToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'error'
        },
        {
            svgButtonsClass: 'infoToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'check'
        },
        {
            svgButtonsClass: 'closeToastIcon',
            styleClass: 'slds-icon_x-small',
            name: 'close'
        },
        {
            svgButtonsClass: 'downIcon',
            styleClass: 'slds-icon_x-small',
            name: 'down'
        },
        {
            svgButtonsClass: 'info-icon',
            styleClass: 'slds-icon_x-small',
            name: 'info'
        },
        {
            svgButtonsClass: 'deleteIcon',
            styleClass: 'slds-icon_x-small',
            name: 'delete'
        },
        {
            svgButtonsClass: 'resetIcon',
            styleClass: 'slds-icon_x-small rotate-icon',
            name: 'rotate'
        }
    ];

    var svgStruct = [];

    app.renderSVG = (elemId) => {
        var elem = $copado(elemId);
        var struct = svgStruct[elemId];
        var imageURL, SVG, SVGUse;

        if (struct) {
            imageURL = struct.imageURL;
            SVG = $copado('<svg/>', {
                class: struct.class,
            });
            SVGUse = $copado('<use/>');

            SVGUse.attr('xlink:href', imageURL);
            if(elem.find('svg').length === 0){
                elem.prepend(SVG.append(SVGUse));
            }
            elem.html(elem.html());
        }
    };

    app.applyRenderSVG = () => {
        if (iconsList) {
            iconsList.forEach((element) => {
                app.renderSVG('.' + element.svgButtonsClass);
            });
        }
    };

    app.setSVGStruct = () => {
        var className;
        if (globalSldsResourcePath) {

            iconsList.forEach((item) => {
                className = item.styleClass ? `slds-button__icon ${item.styleClass}` : 'slds-button__icon';
                svgStruct['.' + item.svgButtonsClass] = {
                    imageURL: `${globalSldsResourcePath}/icons/utility-sprite/svg/symbols.svg#${item.name}`,
                    class: className
                };
            });
        }
    };

    app.onClickFunction = () => {
        lockScreen();
    };


    app.onCompleteFunctionToreRender = () => {
        app.applyRenderSVG();
        unlockScreen();
    };

    $(document).ready(() => {
        app.setSVGStruct();
        app.applyRenderSVG();
    });

})(fc);
