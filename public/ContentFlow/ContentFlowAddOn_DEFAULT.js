/*  ContentFlowAddOn_DEFAULT, version 1.0.2 
 *  (c) 2008 - 2010 Sebastian Kutsch
 *  <http://www.jacksasylum.eu/ContentFlow/>
 *
 *  This file is distributed under the terms of the MIT license.
 *  (see http://www.jacksasylum.eu/ContentFlow/LICENSE)
 */

/*
 * This is an example file of an AddOn file and will not be used by ContentFlow.
 * All values are the default values of ContentFlow.
 *
 * To create a new AddOn follow this guideline:
 *              (replace ADDONNAME by the name of your AddOn)
 *
 * 1. rename this file to ContentFlowAddOn_ADDONNAME.js
 * 2. Change the string 'DEFAULT' in the 'new ContentFlowAddOn' line to 'ADDONNAME'
 * 3. Make the changes you like/need
 * 4. Remove all settings you do not need (or comment out for testing).
 * 5. Add 'ADDONNAME' to the load attribute of the ContentFlow script tag in your web page
 * 6. Reload your page :-)
 *
 */
new ContentFlowAddOn ('DEFAULT', {

    /* 
     * AddOn configuration object, defining the default configuration values.
     */
    conf: {},

    /* 
     * This function will be executed on creation of this object (on load of this file).
     * It's mostly intended to automatically add additional stylesheets and javascripts.
     *
     * Object helper methods and parameters:
     * scriptpath:          basepath of this AddOn (without the filename)
     * addScript(path):     adds a javascript-script tag to the head with the src set to 'path'
     *                      i.e. this.addScript(scriptpath+"MyScript.js") .
     *
     * addStylesheet(path): adds a css-stylesheet-link tag to the head with href set to
     *                      'path' i.e. this.addStylesheet(scriptpath+"MyStylesheet.css") .
     *                      If path is omittet it defaults to :
     *                      scriptpath+'ContentFlowAddOn_ADDONNAME.css'.
     *
     */
    init: function() {
        // this.addScript();
        // this.addStylesheet();
    },
    
    /* 
     * This method will be executed for each ContentFlow on the page after the
     * HTML document is loaded (when the whole DOM exists). You can use it to
     * add elements automatically to the flow.
     *
     * flow:                the DOM object of the ContentFlow
     * flow.Flow:           the DOM object of the 'flow' element
     * flow.Scrollbar:      the DOM object of the 'scrollbar' element
     * flow.Slider:         the DOM object of the 'slider' element
     * flow.globalCaption:  the DOM object of the 'globalCaption' element
     *
     * You can access also all public methods of the flow by 'flow.METHOD' (see documentation).
     */
    onloadInit: function (flow) {
    },

    /* 
     * This method will be executed _after_ the initialization of each ContentFlow.
     */    
    afterContentFlowInit: function (flow) {
    },
    /*
     * ContentFlow configuration.
     * Will overwrite the default configuration (or configuration of previously loaded AddOns).
     * For a detailed explanation of each value take a look at the documentation.
     */
	ContentFlowConf: {
        loadingTimeout: 30000,          // milliseconds
        activeElement: 'content',       // item or content

        maxItemHeight: 0,               // 0 == auto, >0 max item height in px
        scaleFactor: 1.0,               // overall scale factor of content
        scaleFactorLandscape: 1.33,     // scale factor of landscape images ('max' := height= maxItemHeight)
        scaleFactorPortrait: 1.0,       // scale factor of portraoit and square images ('max' := width = item width)
        fixItemSize: false,             // don't scale item size to fit image, crop image if bigger than item
        relativeItemPosition: "top center", // align top/above, bottom/below, left, right, center of position coordinate

        circularFlow: true,             // should the flow wrap around at begging and end?
        verticalFlow: false,            // turn ContentFlow 90 degree counterclockwise
        visibleItems: -1,               // how man item are visible on each side (-1 := auto)
        endOpacity: 1,                  // opacity of last visible item on both sides
        startItem:  "center",           // which item should be shown on startup?
        scrollInFrom: "pre",            // from where should be scrolled in?

        flowSpeedFactor: 1.0,           // how fast should it scroll?
        flowDragFriction: 1.0,          // how hard should it be be drag the floe (0 := no dragging)
        scrollWheelSpeed: 1.0,          // how fast should the mouse wheel scroll. nagive values will revers the scroll direction (0:= deactivate mouse wheel)
        keys: {                         // key => function definition, if set to {} keys ar deactivated
            13: function () { this.conf.onclickActiveItem(this._activeItem) },
            37: function () { this.moveTo('pre') }, 
            38: function () { this.moveTo('visibleNext') },
            39: function () { this.moveTo('next') },
            40: function () { this.moveTo('visiblePre') }
        },

        reflectionColor: "transparent", // none, transparent, overlay or hex RGB CSS style #RRGGBB
        reflectionHeight: 0.5,          // float (relative to original image height)
        reflectionGap: 0.0,             // gap between the image and the reflection


        /*
         * ==================== helper and calculation methods ====================
         *
         * This section contains all user definable methods. With thees you can
         * change the behavior and the visual effects of the flow.
         * For an explanation of each method take a look at the documentation.
         *
         * BEWARE:  All methods are bond to the ContentFlow!!!
         *          This means that the keyword 'this' refers to the ContentFlow 
         *          which called the method.
         */
        
        /* ==================== actions ==================== */

        /*
         * called after the inactive item is clicked.
         */
        onclickInactiveItem : function (item) {},

        /*
         * called after the active item is clicked.
         */
        onclickActiveItem: function (item) {
            var url, target;

            if (url = item.content.getAttribute('href')) {
                target = item.content.getAttribute('target');
            }
            else if (url = item.element.getAttribute('href')) {
                target = item.element.getAttribute('target');
            }
            else if (url = item.content.getAttribute('src')) {
                target = item.content.getAttribute('target');
            }

            if (url) {
                if (target)
                    window.open(url, target).focus();
                else
                    window.location.href = url;
            }
        },
        
        /*
         * called when an item becomes inactive.
         */
        onMakeInactive: function (item) {},

        /*
         * called when an item becomes active.
         */
        onMakeActive: function (item) {},
        
        /*
         * called when the target item/position is reached
         */
        onReachTarget: function(item) {},

        /*
         * called when a new target is set
         */
        onMoveTo: function(item) {},

        /*
         * called each item an item is drawn (after scaling and positioning)
         */
        onDrawItem: function(item) {},

        /*
         * called if the pre-button is clicked.
         */
        onclickPreButton: function (event) {
            this.moveToIndex('pre');
            Event.stop(event);
        },
        
        /*
         * called if the next-button is clicked.
         */
        onclickNextButton: function (event) {
            this.moveToIndex('next');
            Event.stop(event);
        },
        
        /* ==================== calculations ==================== */

        /*
         * calculates the width of the step.
         */
        calcStepWidth: function(diff) {
            var vI = this.conf.visibleItems;
            var items = this.items.length;
            items = items == 0 ? 1 : items;
            if (Math.abs(diff) > vI) {
                if (diff > 0) {
                    var stepwidth = diff - vI;
                } else {
                    var stepwidth = diff + vI;
                }
            } else if (vI >= this.items.length) {
                var stepwidth = diff / items;
            } else {
                var stepwidth = diff * ( vI / items);
            }
            return stepwidth;
        },
        

        /*
         * calculates the size of the item at its relative position x
         *
         * relativePosition: Math.round(Position(activeItem)) - Position(item)
         * side: -1, 0, 1 :: Position(item)/Math.abs(Position(item)) or 0 
         * returns a size object
         */
        calcSize: function (item) {
            var rP = item.relativePosition;

            var h = 1/(Math.abs(rP)+1);
            var w = h;
            return {width: w, height: h};
        },

        /*
         * calculates the position of an item within the flow depending on it's relative position
         *
         * relativePosition: Math.round(Position(activeItem)) - Position(item)
         * side: -1, 0, 1 :: Position(item)/Math.abs(Position(item)) or 0 
         */
        calcCoordinates: function (item) {
            var rP = item.relativePosition;
            //var rPN = item.relativePositionNormed;
            var vI = this.conf.visibleItems; 

            var f = 1 - 1/Math.exp( Math.abs(rP)*0.75);
            var x =  item.side * vI/(vI+1)* f; 
            var y = 1;

            return {x: x, y: y};
        },
        
        /*
         * calculates the position of an item relative to it's calculated coordinates
         * x,y = 0 ==> center of item has the position calculated by
         * calculateCoordinates
         *
         * relativePosition: Math.round(Position(activeItem)) - Position(item)
         * side: -1, 0, 1 :: Position(item)/Math.abs(Position(item)) or 0 
         * size: size object calculated by calcSize
         */
        calcRelativeItemPosition: function (item) {
            var x = 0;
            var y = -1;
            return {x: x, y: y};
        },

        /*
         * calculates and returns the relative z-index of an item
         */
        calcZIndex: function (item) {
            return -Math.abs(item.relativePositionNormed);
        },

        /*
         * calculates and returns the relative font-size of an item
         */
        calcFontSize: function (item) {
            return item.size;
        },

        /*
         * calculates and returns the opacity of an item
         */
        calcOpacity: function (item) {
            return Math.max(1 - ((1 - this.conf.endOpacity ) * Math.sqrt(Math.abs(item.relativePositionNormed))), this.conf.endOpacity);
        }
	
    }

});
