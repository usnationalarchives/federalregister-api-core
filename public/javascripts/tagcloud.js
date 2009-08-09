/*
	 __                                  ___                         __     
	/\ \__                              /\_ \                       /\ \    
	\ \ ,_\     __        __       ___  \//\ \      ___    __  __   \_\ \   
	 \ \ \/   /'__`\    /'_ `\    /'___\  \ \ \    / __`\ /\ \/\ \  /'_` \  
	  \ \ \_ /\ \L\.\_ /\ \L\ \  /\ \__/   \_\ \_ /\ \L\ \\ \ \_\ \/\ \L\ \ 
	   \ \__\\ \__/.\_\\ \____ \ \ \____\  /\____\\ \____/ \ \____/\ \___,_\
	    \/__/ \/__/\/_/ \/___L\ \ \/____/  \/____/ \/___/   \/___/  \/__,_ /
	                      /\____/                                            
	                      \_/__/    
	                      
	      tagcloud.js v1.0 written by Anson Parker (http://phasetwo.org/)
	      This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 2.5 License
	      Visit http://creativecommons.org/licenses/by-nc-sa/2.5/
	      See http://phasetwo.org/post/a-better-tag-cloud.html for usage
	      
*/
function TagCloud(cntr,sstyle,carray,chighlight,urlstub)
{
	var ua = navigator.userAgent.toLowerCase();
	var isOpera = (ua.indexOf('opera') != -1);
	var isIE = (ua.indexOf('msie') != -1 && !isOpera);

	/* sortstyle can be: 'random','descending' or 'ascending'. Otherwise not sorted. */
	var sortstyle = sstyle || ''
		sortstyle = sortstyle.toLowerCase()
	var colors    = carray || [{r:255,g:197,b:145},{r:255,g:213,b:122},{r:243,g:133,b:99},{r:251,g:158,b:126},{r:254,g:173,b:120}]
	if( !colors.length )
		colors = [colors]
	var highlights = chighlight || [{r:172,g:207,b:175}]
	if( !highlights.length )
		highlights = [highlights]
	var url = urlstub || 'http://phasetwo.org/pennypacker/tag/'
			
	var nodes = new Array(0)
	var drawQueue = new Array(0)
	var scale = 0
	var boundingradius = 0
	var drawn = new Array(0)
	var dom = cntr
	var cx = dom.clientWidth/2
	var cy = dom.clientHeight/2
	var gridsize = 0
	var gpos = {}
	var timeout = null
	
	this.draw      = draw
	this.redraw    = redraw
	this.addNode   = addNode
	this.getNode   = getNode
	
		
	function addNode(node)
	{
		nodes.push(node)
	}

	function getNode(idx)
	{
		return nodes[idx]
	}

	function addStyle(cssRule) {
	    var style = document.createElement('style');
	    style.type = 'text/css';
	    if (document.getElementsByTagName) {
	        document.getElementsByTagName('head')[0].appendChild(style);
	        if (style.sheet && style.sheet.insertRule) {
	            style.sheet.insertRule(cssRule, 0);
	        }
	    }
	}

	function getGridPos(x,y)
	{
		var gp = gpos[''+x+'_'+y]
		return gp || new Array(0)

	}

	function addToGridPos(x,y,c)
	{
		var gp = gpos[''+Math.floor(x/gridsize)+'_'+Math.floor(y/gridsize)]
		if(!gp)
		{
			gpos[''+Math.floor(x/gridsize)+'_'+Math.floor(y/gridsize)] = new Array(1)
			gpos[''+Math.floor(x/gridsize)+'_'+Math.floor(y/gridsize)][0] = c
		} else {
			gpos[''+Math.floor(x/gridsize)+'_'+Math.floor(y/gridsize)].push(c)
		}
		
	}
	
	function redraw()
	{	
		if(drawQueue.length && timeout)
		{
			clearTimeout(timeout)
			drawQueue = new Array(0)

		}
		
		boundingradius = 0
		drawn = new Array(0)
		gpos = {}
			
		while(dom.firstChild.nextSibling)
		{
			dom.removeChild(dom.firstChild.nextSibling)
		}
	
		if(sortstyle == 'random')
		{
			var nodepool = nodes.slice()
			while(nodepool.length)
				drawQueue.push( nodepool.splice(randomIndex(nodepool) ,1)[0] )	
		} else {
			drawQueue = nodes.slice()
		}
		itDraw()
	
	}
	
	function draw()
	{
		YAHOO.util.Event.addListener(document, 'mousemove', mpos);
		
		var maxsize = findMaxSize()
		scale = 35 / (Math.sqrt(maxsize / Math.PI) * 2)
		gridsize = Math.sqrt(maxsize / Math.PI) * 2 * scale
	
		if( sortstyle.indexOf('asc') == 0 )
		{
			nodes.sort(sizeSorter)
			nodes.reverse()
			drawQueue = nodes.slice()
		}
		
		if( sortstyle.indexOf('desc') == 0 )
		{
			nodes.sort(sizeSorter)
			drawQueue = nodes.slice()	
		}
		
		if(sortstyle == 'random')
		{
			nodes.sort(sizeSorter)
			var nodepool = nodes.slice()
			while(nodepool.length)
				drawQueue.push( nodepool.splice(randomIndex(nodepool) ,1)[0] )		
		}
		
		if(drawQueue.length == 0)
			drawQueue = nodes.slice()
			

		itDraw()
	}
	
	function findMaxSize()
	{
		var max = 0
		for(var i=0,j=nodes.length;i<j;i++)
		{
			max = (nodes[i].size > max) ? nodes[i].size : max
		}
		return max
	}
	
	function itDraw()
	{
		var nd = drawQueue.shift()
		if(nd)
		{
			drawCircle(nd)
			timeout = setTimeout(itDraw, 20)
		}
	}
	
	function drawCircle(nd)
	{

		var d = Math.sqrt(nd.size / Math.PI) * 2 * scale
		var r = Math.round( d/2 )	
	
		if(drawn.length == 0)
		{
				var cvs = document.createElement('canvas')
				var x = cx
				var y = cy
				boundingradius = r
				
		} else {

			var rndang  = Math.round(Math.random()*360)
			var sinangle = Math.sin(rndang * Math.PI/180)
			var cosangle = Math.cos(rndang * Math.PI/180)
			var x = cx + sinangle * (boundingradius + r)
			var y = cy + cosangle * (boundingradius + r)
			
			var collision = false
			var checkradius = boundingradius + r
			
			var goodx = x; var goody = y
			
			while(!collision)
			{
				checkradius -= 4
				var newx = cx + sinangle * checkradius
				var newy = cy + cosangle * checkradius

				var gx = Math.floor(newx/gridsize)
				var gy = Math.floor(newy/gridsize)
				
				for(var xp=-1;xp<=1;xp++)
				{

					for(var yp=-1;yp<=1;yp++)
					{

						var ngp = getGridPos(gx+xp,gy+yp)
						if(ngp)
						{
							for(var i=0;i<ngp.length;i++)
							{
								var c=ngp[i]
								var dist = Math.pow(newx - c.x,2) + Math.pow(newy - c.y,2)
								if( dist < Math.pow(( r + c.r ),2) )
								{
									collision = true
									break
								}

							}
							if(collision) break;
						}
						if(collision) break;
					}

				}
				if(collision == false) {
					goodx = newx
					goody = newy
				}
			}		
			
			x=goodx
			y=goody

			var distfromcenter = Math.sqrt(Math.pow(x - cx,2) + Math.pow(y - cy,2)) + r
			if(distfromcenter > boundingradius)
			{
				boundingradius = distfromcenter
			}
		}

		var c = new Circle(x,y,r,randomMember(colors))
		addToGridPos(x,y,c)
		drawn.push(c)
		renderCircle(c,nd.name, nd.slug)

	}
	
	function overlapping(c1,c2)
	{
		var c1left = c1.x-c1.r
		var c1right = c1.x+c1.r
		var c1top = c1.y-c1.r
		var c1bot = c1.y+c1.r
		
		var c2left = c2.x-c2.r
		var c2right = c2.x+c2.r
		var c2top = c2.y-c2.r
		var c2bot = c2.y+c2.r
		
		if( ((c1left < c2left && c1right > c2left) || (c1left > c2left && c1left < c2right)) && ((c1top < c2top && c1bot > c2top) || (c1top > c2top && c1top < c2bot)) )
			return true
			
		return false
	 }

	function renderCircle(c,name, slug)
	{	
		var cvs = null
		if(isIE)
		{
			cvs = document.createElement('div')
			//cvs.innerHTML = '0'
			cvs.innerHTML = "<v:oval style='width:"+(c.r*2)+"px; height:"+(c.r*2)+"px; z-index: 1' fillcolor='rgb("+c.c.r+","+c.c.g+","+c.c.b+")' stroked='false'></v:oval>";
			
			var eventdiv = document.createElement('div')
			eventdiv.className='tagcloud_iediv'
			eventdiv.style.width = eventdiv.style.height = c.r*2+1 + 'px'
		        eventdiv.style.position = "absolute";
			eventdiv.style.zIndex = "2";
			eventdiv.style.cursor = "pointer";
			eventdiv.style.left = c.x - c.r + 'px'
			eventdiv.style.top = c.y - c.r + 'px'
			dom.appendChild(eventdiv)
			
			
			// IE only support onmouseover for shapes! so we use a transparent div over the shape
			YAHOO.util.Event.addListener(eventdiv, 'mouseout', function(evt) {
					cvs.innerHTML = "<v:oval style='width:"+(c.r*2)+"px; height:"+(c.r*2)+"px; z-index: 1' fillcolor='rgb("+c.c.r+","+c.c.g+","+c.c.b+")' stroked='false'></v:oval>";
					hideAbout()
			});
			
			YAHOO.util.Event.addListener(eventdiv, 'click', function(evt) {
				document.location=url+slug
			});
			
			YAHOO.util.Event.addListener(eventdiv, 'mouseover', function(evt) {
				var hcolor = randomMember(highlights)
				cvs.innerHTML = "<v:oval style='width:"+(c.r*2)+"px; height:"+(c.r*2)+"px; z-index: 1' fillcolor='rgb("+hcolor.r+","+hcolor.g+","+hcolor.b+")' stroked='false'></v:oval>";
				showAbout(name,evt)
			});

			cvs.style.left = c.x - c.r + 'px'
			cvs.style.top = c.y - c.r + 'px'
			cvs.style.position='absolute'
			cvs.style.width = cvs.style.height = c.r*2+1 + 'px'

		dom.appendChild(cvs)

		} else {
				cvs = document.createElement('canvas')
				cvs.onmouseover = function(e) {
					var evt = e || window.event
					var ctx = cvs.getContext("2d");
					ctx.clearRect(0,0,c.r*2,c.r*2)
					var hcolor = randomMember(highlights)
					ctx.fillStyle = 'rgb('+hcolor.r+','+hcolor.g+','+hcolor.b+')'
					ctx.arc(c.r,c.r,c.r,0,Math.PI*2,true);
					ctx.fill()
					showAbout(name,evt)
				}
				cvs.onmouseout = function(e) {
					var ctx = cvs.getContext("2d");
					ctx.clearRect(0,0,c.r*2,c.r*2)
					ctx.fillStyle = 'rgb('+c.c.r+','+c.c.g+','+c.c.b+')'
					ctx.arc(c.r,c.r,c.r,0,Math.PI*2,true);
					ctx.fill()
					hideAbout()
				}
				cvs.onclick = function(e) {
					document.location=url+slug
				}
				cvs.style.cursor = 'pointer'
				cvs.style.left = c.x - c.r + 'px'
				cvs.style.top = c.y - c.r + 'px'
				cvs.style.position='absolute'
				cvs.setAttribute("width",c.r*2+1);
				cvs.setAttribute("height",c.r*2+1);
				//cvs.width = cvs.height = c.r*2+1
		dom.appendChild(cvs)
				var ctx = cvs.getContext("2d");
				ctx.fillOpacity=0.5
				ctx.fillStyle = 'rgb('+c.c.r+','+c.c.g+','+c.c.b+')'
				ctx.beginPath();
				ctx.arc(c.r,c.r,c.r,0,Math.PI*2,true);
				ctx.fill()			


		}
	}

	function mpos(e)
	{
		var x = YAHOO.util.Event.getPageX(e)
		var y = YAHOO.util.Event.getPageY(e)
	
			var tl = document.getElementById('tagcloud_label')
			if(tl)
			{
				tl.style.left = x + 5 + 'px'
				tl.style.top  = y + 5 + 'px'
			}
	}
	
	function showAbout(name,evt)
	{
	
		var tl = document.getElementById('tagcloud_label')
		if(!tl)
		{
			var tl = document.createElement('div')
			tl.id = 'tagcloud_label'
			tl.style.position = 'absolute'
			tl.style.zIndex = '65535'
			tl.style.display = 'none'
			tl.style.color= '#000'
			tl.style.fontSize='24px'
			tl.style.fontFamily='arial,helvetica,sans-serif'
			document.body.appendChild(tl)
			mpos(evt)
		}
		tl.innerHTML=name
		tl.style.display='block'
		
	}
	
	function hideAbout()
	{
		var tl = document.getElementById('tagcloud_label')
		if(tl)
		{
			tl.style.display='none'
		}
	}

	function sizeSorter(a,b)
	{
		if(a.size > b.size)
			return -1
			
		return 1
	}
	

	function Circle(x,y,r,c)
	{
		this.x=x
		this.y=y
		this.r=r
		this.c=c
	}

	/* returns random array member */
	function randomMember(arr)
	{
		var arrl = arr.length
		if(arrl == 1)
			return arr[0]
		var idx = Math.round((Math.random() * arrl) - 0.5)
		if(idx >= arrl)
			idx = arrl - 1
		return arr[idx]
	}
	
	function randomIndex(arr)
	{
		var arrl = arr.length
		if(arrl == 1)
			return 0
		var idx = Math.round((Math.random() * arrl) - 0.5)
		if(idx >= arrl)
			idx = arrl - 1
		return idx
	}

}

function Node(nm,sz,sl)
{
	this.size = sz
	this.name = nm
	this.slug = sl
}


/* yahoo event bundled */
/* Copyright (c) 2006, Yahoo! Inc. All rights reserved.
   Code licensed under the BSD License: http://developer.yahoo.net/yui/license.txt
   version: 0.10.0
*/
var YAHOO=window.YAHOO||{};YAHOO.namespace=function(_1){if(!_1||!_1.length){return null;}var _2=_1.split(".");var _3=YAHOO;for(var i=(_2[0]=="YAHOO")?1:0;i<_2.length;++i){_3[_2[i]]=_3[_2[i]]||{};_3=_3[_2[i]];}return _3;};YAHOO.log=function(_5,_6){if(YAHOO.widget.Logger){YAHOO.widget.Logger.log(null,_5,_6);}else{return false;}};YAHOO.namespace("util");YAHOO.namespace("widget");YAHOO.namespace("example");
YAHOO.util.CustomEvent=function(_1,_2){this.type=_1;this.scope=_2||window;this.subscribers=[];if(YAHOO.util.Event){YAHOO.util.Event.regCE(this);}};YAHOO.util.CustomEvent.prototype={subscribe:function(fn,_4,_5){this.subscribers.push(new YAHOO.util.Subscriber(fn,_4,_5));},unsubscribe:function(fn,_6){var _7=false;for(var i=0,len=this.subscribers.length;i<len;++i){var s=this.subscribers[i];if(s&&s.contains(fn,_6)){this._delete(i);_7=true;}}return _7;},fire:function(){for(var i=0,len=this.subscribers.length;i<len;++i){var s=this.subscribers[i];if(s){var _10=(s.override)?s.obj:this.scope;s.fn.call(_10,this.type,arguments,s.obj);}}},unsubscribeAll:function(){for(var i=0,len=this.subscribers.length;i<len;++i){this._delete(i);}},_delete:function(_11){var s=this.subscribers[_11];if(s){delete s.fn;delete s.obj;}delete this.subscribers[_11];}};YAHOO.util.Subscriber=function(fn,obj,_13){this.fn=fn;this.obj=obj||null;this.override=(_13);};YAHOO.util.Subscriber.prototype.contains=function(fn,obj){return (this.fn==fn&&this.obj==obj);};if(!YAHOO.util.Event){YAHOO.util.Event=function(){var _14=false;var _15=[];var _16=[];var _17=[];var _18=[];var _19=[];var _20=[];var _21=0;var _22=[];var _23=[];var _24=0;return {POLL_RETRYS:200,POLL_INTERVAL:50,EL:0,TYPE:1,FN:2,WFN:3,SCOPE:3,ADJ_SCOPE:4,isSafari:(/Safari|Konqueror|KHTML/gi).test(navigator.userAgent),isIE:(!this.isSafari&&!navigator.userAgent.match(/opera/gi)&&navigator.userAgent.match(/msie/gi)),addDelayedListener:function(el,_26,fn,_27,_28){_16[_16.length]=[el,_26,fn,_27,_28];if(_14){_21=this.POLL_RETRYS;this.startTimeout(0);}},startTimeout:function(_29){var i=(_29||_29===0)?_29:this.POLL_INTERVAL;var _30=this;var _31=function(){_30._tryPreloadAttach();};this.timeout=setTimeout(_31,i);},onAvailable:function(_32,_33,_34,_35){_22.push({id:_32,fn:_33,obj:_34,override:_35});_21=this.POLL_RETRYS;this.startTimeout(0);},addListener:function(el,_36,fn,_37,_38){if(!fn||!fn.call){return false;}if(this._isValidCollection(el)){var ok=true;for(var i=0,len=el.length;i<len;++i){ok=(this.on(el[i],_36,fn,_37,_38)&&ok);}return ok;}else{if(typeof el=="string"){var oEl=this.getEl(el);if(_14&&oEl){el=oEl;}else{this.addDelayedListener(el,_36,fn,_37,_38);return true;}}}if(!el){return false;}if("unload"==_36&&_37!==this){_17[_17.length]=[el,_36,fn,_37,_38];return true;}var _41=(_38)?_37:el;var _42=function(e){return fn.call(_41,YAHOO.util.Event.getEvent(e),_37);};var li=[el,_36,fn,_42,_41];var _45=_15.length;_15[_45]=li;if(this.useLegacyEvent(el,_36)){var _46=this.getLegacyIndex(el,_36);if(_46==-1){_46=_19.length;_23[el.id+_36]=_46;_19[_46]=[el,_36,el["on"+_36]];_20[_46]=[];el["on"+_36]=function(e){YAHOO.util.Event.fireLegacyEvent(YAHOO.util.Event.getEvent(e),_46);};}_20[_46].push(_45);}else{if(el.addEventListener){el.addEventListener(_36,_42,false);}else{if(el.attachEvent){el.attachEvent("on"+_36,_42);}}}return true;},fireLegacyEvent:function(e,_47){var ok=true;var le=_20[_47];for(var i=0,len=le.length;i<len;++i){var _49=le[i];if(_49){var li=_15[_49];if(li&&li[this.WFN]){var _50=li[this.ADJ_SCOPE];var ret=li[this.WFN].call(_50,e);ok=(ok&&ret);}else{delete le[i];}}}return ok;},getLegacyIndex:function(el,_52){var key=this.generateId(el)+_52;if(typeof _23[key]=="undefined"){return -1;}else{return _23[key];}},useLegacyEvent:function(el,_54){if(!el.addEventListener&&!el.attachEvent){return true;}else{if(this.isSafari){if("click"==_54||"dblclick"==_54){return true;}}}return false;},removeListener:function(el,_55,fn,_56){if(!fn||!fn.call){return false;}if(typeof el=="string"){el=this.getEl(el);}else{if(this._isValidCollection(el)){var ok=true;for(var i=0,len=el.length;i<len;++i){ok=(this.removeListener(el[i],_55,fn)&&ok);}return ok;}}if("unload"==_55){for(i=0,len=_17.length;i<len;i++){var li=_17[i];if(li&&li[0]==el&&li[1]==_55&&li[2]==fn){delete _17[i];return true;}}return false;}var _57=null;if("undefined"==typeof _56){_56=this._getCacheIndex(el,_55,fn);}if(_56>=0){_57=_15[_56];}if(!el||!_57){return false;}if(el.removeEventListener){el.removeEventListener(_55,_57[this.WFN],false);}else{if(el.detachEvent){el.detachEvent("on"+_55,_57[this.WFN]);}}delete _15[_56][this.WFN];delete _15[_56][this.FN];delete _15[_56];return true;},getTarget:function(ev,_59){var t=ev.target||ev.srcElement;if(_59&&t&&"#text"==t.nodeName){return t.parentNode;}else{return t;}},getPageX:function(ev){var x=ev.pageX;if(!x&&0!==x){x=ev.clientX||0;if(this.isIE){x+=this._getScrollLeft();}}return x;},getPageY:function(ev){var y=ev.pageY;if(!y&&0!==y){y=ev.clientY||0;if(this.isIE){y+=this._getScrollTop();}}return y;},getXY:function(ev){return [this.getPageX(ev),this.getPageY(ev)];},getRelatedTarget:function(ev){var t=ev.relatedTarget;if(!t){if(ev.type=="mouseout"){t=ev.toElement;}else{if(ev.type=="mouseover"){t=ev.fromElement;}}}return t;},getTime:function(ev){if(!ev.time){var t=new Date().getTime();try{ev.time=t;}catch(e){return t;}}return ev.time;},stopEvent:function(ev){this.stopPropagation(ev);this.preventDefault(ev);},stopPropagation:function(ev){if(ev.stopPropagation){ev.stopPropagation();}else{ev.cancelBubble=true;}},preventDefault:function(ev){if(ev.preventDefault){ev.preventDefault();}else{ev.returnValue=false;}},getEvent:function(e){var ev=e||window.event;if(!ev){var c=this.getEvent.caller;while(c){ev=c.arguments[0];if(ev&&Event==ev.constructor){break;}c=c.caller;}}return ev;},getCharCode:function(ev){return ev.charCode||((ev.type=="keypress")?ev.keyCode:0);},_getCacheIndex:function(el,_64,fn){for(var i=0,len=_15.length;i<len;++i){var li=_15[i];if(li&&li[this.FN]==fn&&li[this.EL]==el&&li[this.TYPE]==_64){return i;}}return -1;},generateId:function(el){var id=el.id;if(!id){id="yuievtautoid-"+(_24++);el.id=id;}return id;},_isValidCollection:function(o){return (o&&o.length&&typeof o!="string"&&!o.tagName&&!o.alert&&typeof o[0]!="undefined");},elCache:{},getEl:function(id){return document.getElementById(id);},clearCache:function(){},regCE:function(ce){_18.push(ce);},_load:function(e){_14=true;},_tryPreloadAttach:function(){if(this.locked){return false;}this.locked=true;var _68=!_14;if(!_68){_68=(_21>0);}var _69=[];for(var i=0,len=_16.length;i<len;++i){var d=_16[i];if(d){var el=this.getEl(d[this.EL]);if(el){this.on(el,d[this.TYPE],d[this.FN],d[this.SCOPE],d[this.ADJ_SCOPE]);delete _16[i];}else{_69.push(d);}}}_16=_69;notAvail=[];for(i=0,len=_22.length;i<len;++i){var _71=_22[i];if(_71){el=this.getEl(_71.id);if(el){var _72=(_71.override)?_71.obj:el;_71.fn.call(_72,_71.obj);delete _22[i];}else{notAvail.push(_71);}}}_21=(_69.length===0&&notAvail.length===0)?0:_21-1;if(_68){this.startTimeout();}this.locked=false;},_unload:function(e,me){for(var i=0,len=_17.length;i<len;++i){var l=_17[i];if(l){var _75=(l[this.ADJ_SCOPE])?l[this.SCOPE]:window;l[this.FN].call(_75,this.getEvent(e),l[this.SCOPE]);}}if(_15&&_15.length>0){for(i=0,len=_15.length;i<len;++i){l=_15[i];if(l){this.removeListener(l[this.EL],l[this.TYPE],l[this.FN],i);}}this.clearCache();}for(i=0,len=_18.length;i<len;++i){_18[i].unsubscribeAll();delete _18[i];}for(i=0,len=_19.length;i<len;++i){delete _19[i][0];delete _19[i];}},_getScrollLeft:function(){return this._getScroll()[1];},_getScrollTop:function(){return this._getScroll()[0];},_getScroll:function(){var dd=document.documentElement;db=document.body;if(dd&&dd.scrollTop){return [dd.scrollTop,dd.scrollLeft];}else{if(db){return [db.scrollTop,db.scrollLeft];}else{return [0,0];}}}};}();YAHOO.util.Event.on=YAHOO.util.Event.addListener;if(document&&document.body){YAHOO.util.Event._load();}else{YAHOO.util.Event.on(window,"load",YAHOO.util.Event._load,YAHOO.util.Event,true);}YAHOO.util.Event.on(window,"unload",YAHOO.util.Event._unload,YAHOO.util.Event,true);YAHOO.util.Event._tryPreloadAttach();}