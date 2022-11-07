// SetupDashboardJS

function applyRenderSVG(listIdArray,listClassArray){
    if(listIdArray){
        listIdArray.forEach(function(element){
            renderSVG('#'+element);
        });
    }

    if(listClassArray) {
        listClassArray.forEach(function(element){
            renderSVG('.'+element);
        });
    }
}

function renderSVG(elemId){
    var elem = $copado(elemId);
    var struct = svgStruct[elemId];
    var imageURL = struct.imageURL;
    var SVG = $copado('<svg/>', {
       class: struct.class,
    });

    var SVGUse = $copado('<use/>');
    SVGUse.attr('xlink:href',imageURL);
    elem.prepend(SVG.append(SVGUse));
    elem.html(elem.html());
}