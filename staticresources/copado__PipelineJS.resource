/* Minimap */
(function($, pipelineConnector) {
    $.fn.minimap = function($mapSource, elem) {
        var x, y, l, t, w, h;
        var $window = $(window);
        var $minimap = this;
        var minimapWidth = $minimap.width();
        var minimapHeight = $minimap.height();
        var $viewport = $('<div></div>').addClass('minimap-viewport');
        $minimap.append($viewport);
        synchronize();

        $window.on('resize', synchronize);
        $mapSource.on('scroll', synchronize);
        $mapSource.on('drag', init);
        $minimap.on('mousedown touchstart', down);

        function down(e) {
            var moveEvent, upEvent;
            var pos = $minimap.position();

            x = Math.round(pos.left + l + w / 2);
            y = Math.round(pos.top + t + h / 2);
            move(e);

            if (e.type === 'touchstart') {
                moveEvent = 'touchmove.minimapDown';
                upEvent = 'touchend';
            } else {
                moveEvent = 'mousemove.minimapDown';
                upEvent = 'mouseup';
            }
            $window.on(moveEvent, move);
            $window.on(upEvent, up);
        }

        function move(e) {
            e.preventDefault();

            if (e.type.match(/touch/)) {
                if (e.touches.length > 1) {
                    return;
                }
                var event = e.touches[0];
            } else {
                var event = e;
            }

            var dx = event.clientX - x;
            var dy = event.clientY - y;
            if (l + dx < 0) {
                dx = -l;
            }
            if (t + dy < 0) {
                dy = -t;
            }
            if (l + w + dx > minimapWidth) {
                dx = minimapWidth - l - w;
            }
            if (t + h + dy > minimapHeight) {
                dy = minimapHeight - t - h;
            }

            x += dx;
            y += dy;

            l += dx;
            t += dy;

            var coefX = minimapWidth / $mapSource[0].scrollWidth;
            var coefY = minimapHeight / $mapSource[0].scrollHeight;
            var left = l / coefX;
            var top = t / coefY;

            $mapSource[0].scrollLeft = Math.round(left);
            $mapSource[0].scrollTop = Math.round(top);

            redraw();
        }

        function up() {
            $window.off('.minimapDown');
        }

        function synchronize() {
            var dims = [$mapSource.width(), $mapSource.height()];
            var scroll = [$mapSource.scrollLeft(), $mapSource.scrollTop()];
            var scaleX = minimapWidth / $mapSource[0].scrollWidth;
            var scaleY = minimapHeight / $mapSource[0].scrollHeight;

            var lW = dims[0] * scaleX;
            var lH = dims[1] * scaleY;
            var lX = scroll[0] * scaleX;
            var lY = scroll[1] * scaleY;

            w = Math.round(lW);
            h = Math.round(lH);
            l = Math.round(lX);
            t = Math.round(lY);
            //set the mini viewport dimensions
            redraw();
        }

        function redraw() {
            $viewport.css({
                width: w,
                height: h,
                left: l,
                top: t
            });

            // Recalculate SVG
            ccd.connectAll();
        }

        function calculateHeightFactor() {
            var firstColumnEnvNumber = $copado($mapSource.children('.column').get(0)).find(elem).length;
            var secondColumnEnvNumber = $copado($mapSource.children('.column').get(1)).find(elem).length;
            var heightFactor = 0;

            columnsNumber = firstColumnEnvNumber > secondColumnEnvNumber ? firstColumnEnvNumber : secondColumnEnvNumber;
            heightFactor = columnsNumber <= 10 ? 0.7 : 0.9;

            return heightFactor;
        }

        function init() {
            $minimap.find('.minimap-node').remove();
            //creating mini version of the supplied children

            var heightFactor = calculateHeightFactor();

            $mapSource.find(elem).each(function() {
                var $child = $(this);
                var mini = $('<div></div>').addClass('minimap-node');
                $minimap.append(mini);

                var ratioX = minimapWidth / $mapSource[0].scrollWidth;
                var ratioY = minimapHeight / $mapSource[0].scrollHeight;

                var ratioX = (minimapWidth / $mapSource[0].scrollWidth) * 0.8;
                var ratioY = (minimapHeight / $mapSource[0].scrollHeight) * heightFactor;

                var wM = $child.width() * ratioX;
                var hM = $child.height() * ratioY;
                var xM = ($child.position().left + $mapSource.scrollLeft()) * ratioX;
                var yM = ($child.position().top + $mapSource.scrollTop()) * ratioY;

                mini.css({
                    width: Math.round(wM),
                    height: Math.round(hM),
                    left: Math.round(xM),
                    top: Math.round(yM)
                });
            });
        }

        init();

        return this;
    };
})(jQuery, ccd);

/* It detects collisions between two DOM elements */
var overlaps = (function() {
    function getPositions(elem) {
        var pos, width, height;
        pos = $copado(elem).position();
        width = $copado(elem).width() / 2;
        height = $copado(elem).height();
        return [
            [pos.left, pos.left + width],
            [pos.top, pos.top + height]
        ];
    }

    function comparePositions(p1, p2) {
        var r1, r2;
        r1 = p1[0] < p2[0] ? p1 : p2;
        r2 = p1[0] < p2[0] ? p2 : p1;
        return r1[1] > r2[0] || r1[0] === r2[0];
    }

    return function(a, b) {
        var pos1 = getPositions(a),
            pos2 = getPositions(b);
        return comparePositions(pos1[0], pos2[0]) && comparePositions(pos1[1], pos2[1]);
    };
})();

// Continuous Delivery Javascript
var ccd = ccd || {};
var copadoApp = copadoApp ? copadoApp : {};
var staticResourcesPath = staticResourcesPath ? staticResourcesPath : '';

(pipelineConnector => {
    var pipelineConnector = pipelineConnector || {};
    var boxClassIdentifier = '.box-container';

    var signum = x => {
        return x < 0 ? -1 : 1;
    };

    // Get a entire positive value
    var absolute = x => {
        return x < 0 ? -x : x;
    };

    // Get data from Apex controller
    var getConnectionsList = () => {
        if (ccd.data.connections.length > 0) {
            pipelineConnector.data.connectionsList = JSON.parse(ccd.data.connections);
        }
    };

    // Draw a SVG line between two points
    var drawPath = (svg, path, startX, startY, endX, endY) => {
        var stroke = parseFloat(path.css('stroke-width'));
        var offsetHeight = 20;

        if (endY < startY && startY > 0) {
            svg.attr('height', startY + offsetHeight);
        } else if (svg.attr('height') < endY) {
            svg.attr('height', endY + offsetHeight);
        }

        if (svg.attr('width') < startX + stroke) {
            svg.attr('width', startX + stroke);
        }

        if (svg.attr('width') < endX + stroke) {
            svg.attr('width', endX + stroke);
        }

        var deltaX = (endX - startX) * 0.15;
        var deltaY = (endY - startY) * 0.15;
        var delta = startY !== endY ? 25 : deltaY < absolute(deltaX) ? deltaY : absolute(deltaX);
        var offset = 30;
        var arc1 = 1;
        var arc2 = 0;

        if (startY > endY) {
            arc1 = 0;
            arc2 = 1;
        }

        var belowPoint = startY > endY ? -1 : 1;
        delta = startY > endY ? absolute(delta) : delta;
        if (absolute(startY - endY) > 5) {
            path.attr(
                'd',
                ' M' +
                    startX +
                    ' ' +
                    startY +
                    ' H' +
                    (startX + delta + offset) +
                    ' A' +
                    delta +
                    ' ' +
                    delta +
                    ' 0 0 ' +
                    arc1 +
                    ' ' +
                    (offset + startX + 2 * delta) +
                    ' ' +
                    (startY + delta * belowPoint * signum(delta)) +
                    ' V' +
                    endY +
                    ' H' +
                    endX
            );
        } else {
            path.attr('d', ' M' + startX + ' ' + startY + ' H' + endX);
        }
    };

    // Calculate the start and end point to draw a line
    var connectElements = (svg, path, startElem, endElem) => {
        var svgContainer = $copado('#svgContainer');

        if (Object.keys(startElem).length === 0 || Object.keys(endElem).length === 0) {
            return;
        }

        if (startElem.offset().left > endElem.offset().left) {
            var temp = startElem;
            startElem = endElem;
            endElem = temp;
        }

        var svgTop = svgContainer.offset().top;
        var svgLeft = svgContainer.offset().left;

        var startCoord = startElem.offset();
        var endCoord = endElem.offset();

        var startX = startCoord.left + startElem.outerWidth() - svgLeft;
        var startY = startCoord.top + 0.5 * startElem.outerHeight() - svgTop;
        var endX = endCoord.left - svgLeft;
        var endY = endCoord.top + 0.5 * endElem.outerHeight() - svgTop;

        if (startY > endY && startY - endY < 3) {
            startY = endY;
        }
        if (endY > startY && endY - startY < 3) {
            endY = startY;
        }

        drawPath(svg, path, startX - 10, startY, endX - 5, endY);
    };

    // Paint an arrow at the end of each SVG line
    var getLineArrows = () => {
        var svgContainer = document.getElementById('svgContainer');
        var svgs = svgContainer.children;
        var i, j;
        var svgNS = 'http://www.w3.org/2000/svg';
        var id, svg, mainPath, defs, defTags, path, marker;

        for (var i = 0; i < svgs.length; i++) {
            id = svgs[i].getAttribute('id');

            svg = document.getElementById(id);
            defs = document.createElementNS(svgNS, 'defs');
            svg.appendChild(defs);

            defTags = document.getElementsByTagName('defs');

            path = document.createElementNS(svgNS, 'path');
            path.setAttributeNS(null, 'd', 'M0,0 L0,6 L9,3 z');
            path.setAttributeNS(null, 'fill', '#f00');

            marker = document.createElementNS(svgNS, 'marker');
            marker.appendChild(path);

            marker.setAttributeNS(null, 'id', 'arrow');
            marker.setAttributeNS(null, 'markerWidth', 20);
            marker.setAttributeNS(null, 'markerHeight', 20);
            marker.setAttributeNS(null, 'refX', 0);
            marker.setAttributeNS(null, 'refY', 3);
            marker.setAttributeNS(null, 'orient', 'auto');
            marker.setAttributeNS(null, 'markerUnits', 'strokeWidth');
            marker.setAttributeNS(null, 'viewBox', '0 0 20 20');

            for (j = 0; j < defTags.length; j++) {
                defTags[j].appendChild(marker);
            }

            mainPath = svg.getElementsByTagName('path')[0];
            mainPath.setAttributeNS(null, 'marker-end', 'url(#arrow)');
        }
    };

    // Expand svg a bit more to see arrows entirely
    var adjustSvgDimensions = () => {
        var svgContainer = $copado('#svgContainer');
        var svg, svgHeight, svgWidth;

        svgContainer.children().each(function() {
            svg = $copado(this);
            svgHeight = parseFloat(svg.attr('height'));
            svgWidth = parseFloat(svg.attr('width'));

            svg.attr('height', svgHeight + 20);
            svg.attr('width', svgWidth + 10);
        });
    };

    // Create SVG containers to paint each line
    var createSvgs = () => {
        var svgContainer = $copado('#svgContainer');
        var connectionsList = pipelineConnector.data.targetToSourceList;
        if (!connectionsList) {
            return;
        }
        connectionsList.forEach((connection, index) => {
            svgContainer.append(`<svg id="svg${index}" width="0" height="0">
                <path id="path${index}"/>
            </svg>`);
        });
    };

    // Public function to connect all elements.
    pipelineConnector.connectAll = () => {
        var connectionsList = pipelineConnector.data.targetToSourceList;
        if (!connectionsList) {
            return;
        }
        connectionsList.forEach((connection, index) => {
            connectElements($copado(`#svg${index}`), $copado(`#path${index}`), $copado(`#${connection.origin}`), $copado(`#${connection.target}`));
        });
    };

    // Get an element top position
    var getTop = elem => {
        var eTop = elem.offset().top;
        var wTop = $copado(window).scrollTop();
        var top = eTop - wTop;

        return top;
    };

    // Minimap configuration
    var setMinimap = () => {
        var myWrapper = $copado('.pipeline');
        var $minimap = $copado('#minimap');

        if (pipelineConnector.data.isSalesforceClassic) {
            $copado('#minimap').css({ bottom: '95px', right: '80px' });
        }

        if ($copado(boxClassIdentifier).length > 0) {
            $copado('#minimap').minimap(myWrapper, boxClassIdentifier);
            $minimap.show();
        }

        $minimap.draggable({
            handle: '#minimapHeader',
            containment: '.wrapper',
            stop: (event, ui) => {
                var top = getTop(ui.helper);
                ui.helper.css('position', 'fixed');
                ui.helper.css('top', top + 'px');
            }
        });
    };

    // Function to group all task needed to paint SVG lines
    var initLineConnections = () => {
        createSvgs();
        getLineArrows();
        pipelineConnector.connectAll();
        adjustSvgDimensions();
    };

    // Format a data array from the data received of Apex controller
    var formatConnections = connectionsList => {
        var convertedList = [];
        var stage, fromEnvId, toEnvId, columnNumber;
        var finalConnectionList = [];
        var connectionData;
        var fromEnvId, toEnvId, columnNumber;
        var fromEnvName, toEnvName;
        var namespace = pipelineConnector.config.ns;

        for (var key in connectionsList) {
            stage = connectionsList[key];

            for (var stageObject in stage) {
                if (stageObject !== 'Final') {
                    for (var j = 0; j < stage[stageObject].length; j++) {
                        fromEnvId = stage[stageObject][j].currentStep[namespace + 'Source_Environment__c']
                            ? stage[stageObject][j].currentStep[namespace + 'Source_Environment__c']
                            : stage[stageObject][j].currentStep[namespace + 'Branch__c'];
                        toEnvId = stage[stageObject][j].currentStep[namespace + 'Destination_Environment__c']
                            ? stage[stageObject][j].currentStep[namespace + 'Destination_Environment__c']
                            : stage[stageObject][j].currentStep[namespace + 'Destination_Branch__c'];
                        fromEnvName = stage[stageObject][j].currentStep[namespace + 'Source_Environment__r']
                            ? stage[stageObject][j].currentStep[namespace + 'Source_Environment__r'].Name
                            : '';
                        toEnvName = stage[stageObject][j].currentStep[namespace + 'Destination_Environment__r']
                            ? stage[stageObject][j].currentStep[namespace + 'Destination_Environment__r'].Name
                            : '';
                        columnNumber = key.replace('Stage ', '');
                        convertedList.push({
                            originName: fromEnvName,
                            targetName: toEnvName,
                            origin: `wrapper_${fromEnvId}`,
                            target: `wrapper_${toEnvId}`,
                            column: columnNumber
                        });
                    }
                }
            }
        }

        pipelineConnector.data.targetToSourceList = convertedList;
        finalConnectionList = [
            {
                target: convertedList[0].target,
                connections: [convertedList[0].origin],
                column: convertedList[0].column
            }
        ];

        convertedList.forEach(item => {
            if (
                item.target === finalConnectionList[finalConnectionList.length - 1].target &&
                item.column === finalConnectionList[finalConnectionList.length - 1].column
            ) {
                finalConnectionList[finalConnectionList.length - 1].connections.push(item.origin);
            } else {
                connectionData = {
                    target: item.target,
                    connections: [item.origin],
                    column: item.column
                };

                finalConnectionList.push(connectionData);
            }
        });
        return finalConnectionList;
    };

    // Move all the environments boxes down a given value
    var moveBoxes = displaceHeightValue => {
        var boxes = $copado(boxClassIdentifier);
        var currentOffset = 0;
        boxes.each(function(index) {
            var $box = $copado(this);
            currentOffset = $box.offset().top;
            $box.offset({ top: currentOffset + displaceHeightValue });
        });
    };

    // Check if an environment box have a collision with another one of its group
    var checkCollision = (group, env) => {
        var haveCollisions = true;
        var collisions = [];
        var box = env;

        groupedIds = group
            .join()
            .replace(/"/, '')
            .replace(/wrapper/g, '#wrapper');

        collisions = $copado(groupedIds)
            .not(box)
            .map(function(i) {
                return { id: $copado(this).attr('id'), collision: overlaps(box, this) };
            });

        collisions = collisions.filter((index, item) => item.collision === true);
        return collisions;
    };

    // Move environment boxes connected to a given box
    var setPreviousConnectionPositions = (list, id, currentColumn) => {
        var envs = getConnectedEnvironments(list, id, currentColumn);
        var idTop = $copado(`#${id}`).position().top;
        var boxHeight = $copado(boxClassIdentifier).height() + 10;
        var heightIncrease = 0;

        envs.forEach(boxId => {
            var height = $copado(`#${boxId}`).offset().top;
            $copado(`#${boxId}`).offset({ top: height + heightIncrease });
            heightIncrease += boxHeight;
        });
    };

    // Handle the collisions between environment boxes and avoid it
    var handleCollisions = (nextColumnBoxes, box, list, currentColumn) => {
        var collisions = checkCollision(nextColumnBoxes, box);
        var isCollided = true;
        var collidedBox;
        var found;
        var collisionedEnv;

        if (collisions.length > 0) {
            collisions.toArray().forEach(collision => {
                isCollided = true;
                collisionedEnv = $copado(`#${collision.id}`);
                while (isCollided) {
                    if (box.data('order') > collisionedEnv.data('order')) {
                        collisionedEnv.offset({ top: collisionedEnv.offset().top - 10 });
                    } else {
                        collisionedEnv.offset({ top: collisionedEnv.offset().top + 10 });
                    }
                    collidedBox = checkCollision(nextColumnBoxes, collisionedEnv);
                    found = collidedBox.toArray().find(item => item.id === box.attr('id'));

                    if (!found) {
                        isCollided = false;

                        if (hasPreviousConnection(list, collision.id, currentColumn)) {
                            setPreviousConnectionPositions(list, collision.id, currentColumn);
                        }
                    }
                }
            });
        }
    };

    // Get a list of the environment boxes that is connected to a given box
    var getConnectedEnvironments = (connectionList, id, currentColumn) => {
        var columnGroups, groupElems;
        var connectedEnv = [];
        var list = JSON.parse(JSON.stringify(connectionList));

        if (currentColumn > 1) {
            lastColumn = (currentColumn - 1).toString();
            columnGroups = list.filter(connection => parseInt(connection.column, 10) === currentColumn);
            groupElems = columnGroups.find(group => group.target === id);

            connectedEnv = groupElems.connections;
        }

        return connectedEnv;
    };

    // Check if a given box is connected to a previous box
    var hasPreviousConnection = (connectionList, id, column) => {
        var columnGroups, previousColumnGroup;
        var isConnected = false;
        var list = JSON.parse(JSON.stringify(connectionList));

        if (column > 1) {
            columnGroups = list.filter(connection => parseInt(connection.column, 10) === column);
            previousColumnGroup = columnGroups.find(group => group.target === id);

            if (previousColumnGroup && previousColumnGroup.connections.length > 0) {
                isConnected = true;
            }
        }
        return isConnected;
    };

    // Convert connectionsList array in a list prepared to create a tree structure
    var createListForTree = list => {
        var l = list.length;
        var finalList = [];

        while (l--) {
            var n = list[l];

            if (!finalList.length) {
                finalList.push({ id: n.target, parentId: '0', level: n.column + 1, children: null });
            }

            for (var i = 0; i < n.connections.length; i++) {
                var m = n.connections[i];
                finalList.push({ id: m, parentId: n.target, level: n.column, children: null });
            }
        }
        return finalList;
    };

    // Convert a list into tree data structure
    var listToTree = list => {
        var map = {};
        var roots = [];
        var node, i;

        for (i = 0; i < list.length; i += 1) {
            map[list[i].id] = i; // initialize the map
            list[i].children = []; // initialize the children
        }

        for (i = 0; i < list.length; i += 1) {
            node = list[i];
            if (node.parentId !== '0') {
                // if you have dangling branches check that map[node.parentId] exists
                list[map[node.parentId]].children.push(node);
            } else {
                roots.push(node);
            }
        }

        return roots;
    };

    // Add order to nodes
    var addOrderToTreeNodes = finalList => {
        var orderedList = [];
        var tree = listToTree(finalList);
        
        function listTree(node, order, i) {
            node.order = order + '0' + i;
            orderedList.push(node);
            for (var j = 0; j < node.children.length; j++) {
                i++;
                listTree(node.children[j], node.order, j);
            }
        }

        listTree(tree[0], 0, 1);

        orderedList.sort((a, b) => {
            return parseFloat(a.order) > parseFloat(b.order) ? -1 : 1;
        });

        orderedList.forEach((elem, index) => {
            $copado(`#${elem.id}`).data('order', elem.order);
        });
    };

    // Order DOM boxes according order attribute
    var reorganizeDOMBoxes = () => {
        var $columns;
        $columns = $copado('.pipeline').children();
        $columns.each(function(index) {
            var $column = $copado(this);
            var columnBoxesNumber = $column.children().length;
            if (index > 0 && columnBoxesNumber > 1) {
                $column.append(
                    $column
                        .find(boxClassIdentifier)
                        .get()
                        .sort((a, b) => {
                            return parseFloat($copado(a).data('order')) - parseFloat($copado(b).data('order'));
                        })
                );
            }
        });
    };

    // Order array according order attribute
    var reorderConnectionsArray = formattedConnectionsList => {
        var currentColumnNumber = 0,
            lastColumn = 0;
        var currentColumn = [];
        var formattedConnectionsListCopy = JSON.parse(JSON.stringify(formattedConnectionsList));
        var orderedConnectionList = [];
        var newColumn = false;
        var orderedListColumn = [];

        formattedConnectionsList.forEach((item, index) => {
            newColumn = false;
            orderedListColumn = [];

            currentColumnNumber = parseInt(item.column, 10);
            currentColumn = formattedConnectionsListCopy.filter(connection => parseInt(connection.column, 10) === currentColumnNumber);

            if (currentColumnNumber !== lastColumn) {
                lastColumn = currentColumnNumber;
                newColumn = true;
            } else {
                newColumn = false;
            }
            
            if (newColumn) {  
                if (currentColumn.length > 1) {
                    orderedListColumn = currentColumn.sort((a, b) => {
                        return $copado(`#${a.connections[0]}`).data('order') < $copado(`#${b.connections[0]}`).data('order') ? -1 : 1;
                    });

                    orderedListColumn.forEach(group => {
                        orderedConnectionList.push(group);
                    });
                } else {
                    orderedConnectionList.push(currentColumn[0]);
                }
            }
        });
        return orderedConnectionList;
    };

    // Environment boxes positions calculation
    var setPositions = orderedConnectionList => {
        var boxHeight = $copado(boxClassIdentifier).height() + 10;
        var classicHeaderHeight = $copado('#AppBodyHeader').height() + 3;
        var currentColumnNumber = 0,
            lastColumn = 0,
            newColumn = false;
        var nextColumnNumber = '';
        var formattedConnectionsListCopy = JSON.parse(JSON.stringify(orderedConnectionList));
        var nextColumnBoxes;
        var lastPositionedBox;
        var firstItemTop, lastItemTop;
        var totalHeight = 0;
        var targetIndex, aboveBoxes, bellowBoxes;

        orderedConnectionList.forEach((item, index) => {
            newColumn = false;
            currentColumnNumber = parseInt(item.column, 10);
            nextColumnNumber = (currentColumnNumber + 1).toString();
            item.connections = item.connections.filter((v, i, a) => a.indexOf(v) === i); // remove repeated connections
            
            nextColumn = formattedConnectionsListCopy.filter(connection => {
                return connection.column === nextColumnNumber;
            });
            
            nextColumnBoxes = nextColumn.map(item => {
                return item.connections;
            });

            nextColumnBoxes = [].concat.apply([], nextColumnBoxes); // Flatten array

            if ($copado(`#${item.connections[0]}`).length > 0 && $copado(`#${item.connections[item.connections.length - 1]}`).length > 0) {
                firstItemTop = $copado(`#${item.connections[0]}`).position().top;
                lastItemTop = $copado(`#${item.connections[item.connections.length - 1]}`).position().top;
                totalHeight = Math.floor((lastItemTop + firstItemTop) / 2);

                if (pipelineConnector.data.isSalesforceClassic) {
                    totalHeight += classicHeaderHeight;
                }

                $copado(`#${item.target}`).offset({ top: totalHeight });

                var $box = $copado(`#${item.target}`);

                handleCollisions(nextColumnBoxes, $box, formattedConnectionsListCopy, currentColumnNumber);
            }
            
            if (currentColumnNumber !== lastColumn) {
                lastColumn = currentColumnNumber;
                newColumn = true;
            } else {
                newColumn = false;
            }

            if (newColumn) {
                targetIndex = nextColumnBoxes.findIndex(elem => elem === item.target);
                aboveBoxes = nextColumnBoxes.slice(0, targetIndex);
                aboveBoxes.reverse();
                bellowBoxes = nextColumnBoxes.slice(targetIndex + 1, nextColumnBoxes.length);

                lastPositionedBox = item.target;
                aboveBoxes.forEach((id, index) => {
                    var $box = $copado(`#${id}`);

                    $box.offset({ top: $copado(`#${lastPositionedBox}`).offset().top - boxHeight });
                    lastPositionedBox = id;
                });

                lastPositionedBox = item.target;
                bellowBoxes.forEach((id, index) => {
                    var $box = $copado(`#${id}`);

                    if ($box.offset().top < $copado(`#${lastPositionedBox}`).offset().top) {
                        $box.offset({ top: $copado(`#${lastPositionedBox}`).offset().top + boxHeight });
                        lastPositionedBox = id;
                    }
                });
            } else {
                targetIndex = nextColumnBoxes.findIndex(elem => elem === item.target);
                aboveBoxes = nextColumnBoxes.slice(0, targetIndex);
                aboveBoxes.reverse();
                bellowBoxes = nextColumnBoxes.slice(targetIndex + 1, nextColumnBoxes.length);

                if ($copado(`#${aboveBoxes[0]}`).offset().top > $copado(`#${item.target}`).offset().top) {
                    $copado(`#${item.target}`).offset({ top: $copado(`#${aboveBoxes[0]}`).offset().top + boxHeight });
                }

                lastPositionedBox = item.target;
                aboveBoxes.forEach((id, index) => {
                    var $box = $copado(`#${id}`);

                    if ($box.offset().top > $copado(`#${lastPositionedBox}`).offset().top) {
                        $box.offset({ top: $copado(`#${lastPositionedBox}`).offset().top - boxHeight });
                    }

                    handleCollisions(nextColumnBoxes, $box, formattedConnectionsListCopy, currentColumnNumber);
                    lastPositionedBox = id;
                });

                lastPositionedBox = item.target;
                bellowBoxes.forEach((id, index) => {
                    var $box = $copado(`#${id}`);

                    if ($box.offset().top < $copado(`#${lastPositionedBox}`).offset().top) {
                        $box.offset({ top: $copado(`#${lastPositionedBox}`).offset().top + boxHeight });
                    }

                    handleCollisions(nextColumnBoxes, $box, formattedConnectionsListCopy, currentColumnNumber);
                    lastPositionedBox = id;
                });
            }
        });
    };

    // Check if all box position calculations are inside the container and displace it if not
    var displaceEnvironments = () => {
        var boxes = $copado(boxClassIdentifier);
        var $box;
        var filterOffset = $copado('.filter-main-object').offset().top + $copado('.filter-main-object').height();
        boxes.each(function(index) {
            var $box = $copado(this);
            var displaceHeightValue = 0;
            var margin = 20;

            if ($box.offset().top < filterOffset) {
                displaceHeightValue = filterOffset - $box.offset().top + margin;
                moveBoxes(displaceHeightValue);
            }
        });
    };

    // In case of after all calculations some environment is hidden or overlaped, it can be placed manually
    var setBoxesDraggable = () => {
        $copado(boxClassIdentifier).draggable({
            axis: 'y',
            handle: '.info',
            containment: '.pipeline',
            drag: (event, ui) => {},
            stop: (event, ui) => {
                pipelineConnector.connectAll();
            }
        });
    };

    // Prepare the info from Apex controller and calculate positions for each environment box
    var calculateSmartPositioning = () => {
        var connectionsList = pipelineConnector.data.connectionsList;
        var finalList = [];
        var formattedConnectionsList = [];
        var orderedConnectionList = [];
        if (Object.entries(connectionsList).length === 0 && connectionsList.constructor === Object) {
            console.error('Empty connection list. Check your pipeline configuration');
        } else {
            formattedConnectionsList = formatConnections(connectionsList);
            finalList = createListForTree(formattedConnectionsList);
            addOrderToTreeNodes(finalList);
            reorganizeDOMBoxes();
            orderedConnectionList = reorderConnectionsArray(formattedConnectionsList);
            setPositions(orderedConnectionList);
            displaceEnvironments();
            setBoxesDraggable();
        }
    };

    // Set rules for dropdown menus behaviour
    var handleDropdownMenus = () => {
        var envDropdowns = document.querySelectorAll('.box-container div.slds-dropdown');
        var diagramDropdown = document.querySelector('.diagramDropwdown');
        var filterDropdown = document.querySelector('.filter-main-object div.slds-dropdown');
        var dropdowns;

        if (document.querySelector('.slds-dropdown-trigger_click.diagramDropwdown')) {
            document.querySelector('.slds-dropdown-trigger_click.diagramDropwdown').addEventListener('click', event => {
                var thisMenu = event.target.closest('.slds-dropdown-trigger_click');
                if (thisMenu.className.includes('diagramDropwdown')) {
                    thisMenu.classList.toggle('slds-is-open');
                }
            });
        }

        document.querySelector('.slds-dropdown-trigger_click.filterOptionsMenu').addEventListener('click', event => {
            var thisMenu = event.target.closest('.slds-dropdown-trigger_click');
            if (thisMenu.className.includes('filterOptionsMenu')) {
                thisMenu.classList.toggle('slds-is-open');
            }
        });

        if (envDropdowns.length > 0) {
            document.addEventListener('click', event => {
                for (var i = 0; i < envDropdowns.length; i++) {
                    var isClickInside = envDropdowns[i].contains(event.target);
                    var button = envDropdowns[i].parentElement.querySelector('.slds-dropdown-trigger > button');
                    var isTriggered = button && button.contains(event.target);

                    if (!isClickInside && !isTriggered) {
                        $copado(envDropdowns[i]).addClass('slds-hide');
                    }
                }

                if (!(event.target.closest('button') && event.target.className.includes('diagramActionButton'))) {
                    $copado(diagramDropdown).removeClass('slds-is-open');
                }

                if (!(event.target.closest('button') && event.target.closest('button').id === 'filterSettings')) {
                    $copado(filterDropdown)
                        .parent()
                        .removeClass('slds-is-open');
                }
            });
        }
    };

    // Public function to group all task needed to load the pipeline manager page
    pipelineConnector.loadPage = () => {
        try {
            getConnectionsList();
            if (!pipelineConnector.data.connectionsList) {
                return;
            }
            calculateSmartPositioning();
            initLineConnections();
            setMinimap();
            handleDropdownMenus();
        } catch (error) {
            console.error(error);
            unlockScreen();
            alert(error);
        }
    };

    // Public function to update last deployment and set the properly icon
    pipelineConnector.updateLastDeployment = (envId, deploymentStatus) => {
        var statusMap = {
            'Completed Successfully': copadoApp.icons.success,
            'Completed with Errors': copadoApp.icons.failed,
            'In progress': copadoApp.icons.paused,
            'Outdated': copadoApp.icons.paused
        };
        var idString = '#deploymentStatus_' + envId;
        var environmentStatus = $copado(idString);

        if (environmentStatus) {
            $copado(environmentStatus).attr('src', statusMap[deploymentStatus]);
        }
    };

    // Public function to open an environment box dropdown
    pipelineConnector.openDropdownMenu = currentButton => {
        var box = currentButton.closest('.env-box');
        var dropdown = box.nextElementSibling;

        if ($copado(dropdown).hasClass('slds-hide')) {
            $copado('.slds-dropdown.envActionDropdown').addClass('slds-hide');
            $copado(dropdown).removeClass('slds-hide');
        } else {
            $copado('.slds-dropdown.envActionDropdown').addClass('slds-hide');
            $copado(dropdown).addClass('slds-hide');
        }
    };

    // Public function to create an org credential
    pipelineConnector.createOrg = (stepId, envId, envName, useStep) => {
        lockScreen();
        createOrgCredentials(stepId, envId, '', '', 'true', useStep);
    };

    pipelineConnector.isManagerRunning = currentMode => {
        if (currentMode === 'manager') {
            promotableUserStories();
        } else {
            reRenderPipelineWrapper();
        }
    };

    pipelineConnector.openConnectionBehavior = connectionBehaviorId => {
        window.open('/' + connectionBehaviorId, '_blank');
    };

    pipelineConnector.fromAcf2Open = () => {
        $copado('[id$=dependencyUSComponent]').show();
        $copado('[id$=operationModal]').hide();
        $copado('[id$=promotionListModal]').hide();
        applyRenderSVG(undefined, ['chevrondown']);
        unlockScreen();
    };

    // Public function to render again all the page
    pipelineConnector.reRenderFunction = () => {
        ccd.loadPage();
        renderPageMessage();
    };

    // Public function to show and hide the connection behaviour depending if the mouse is over or not
    pipelineConnector.toggleNewConnectionIcon = elem => {
        var box = $copado(elem).find('.connection-behaviour-override');

        if (box.hasClass('hide')) {
            box.removeClass('hide');
            box.addClass('show');
        } else {
            box.addClass('hide');
            box.removeClass('show');
        }
    };

    // Get data from visual force page to be used here
    var definePipelineConnector = () => {
        pipelineConnector.data = pipelineConnector.data || {};
        pipelineConnector.config = pipelineConnector.config || {};
        pipelineConnector.config.ns = copadoApp.ns;
        pipelineConnector.data.flowId = copadoApp.data.flowId;
        pipelineConnector.data.isSalesforceClassic = copadoApp.data.isClassic === 'true' ? true : false;

        pipelineConnector.data.connectionsList = [];
    };

    $(document).ready(() => {
        definePipelineConnector();
    });
})(ccd);
