/*
 * EnhanceJS version 1.0a - Test-Driven Progressive Enhancement
 * Copyright (c) 2010 Filament Group, Inc, authors.txt
 * Licensed under MIT (license.txt)
*/
(function(win,doc){var settings,body,windowLoaded,head;if(doc.getElementsByTagName){head=doc.getElementsByTagName('head')[0]||doc.documentElement;}
else{head=doc.documentElement;}
enhance=function(options){options=options||{};settings={};for(var name in enhance.defaultSettings){var option=options[name];settings[name]=option!==undefined?option:enhance.defaultSettings[name];}
for(var test in options.addTests){settings.tests[test]=options.addTests[test];}
runTests();applyDocReadyHack();windowLoad(function(){windowLoaded=true;});};enhance.defaultTests={getById:function(){return!!doc.getElementById;},getByTagName:function(){return!!doc.getElementsByTagName;},createEl:function(){return!!doc.createElement;},boxmodel:function(){var newDiv=doc.createElement('div');newDiv.style.cssText='width: 1px; padding: 1px;';body.appendChild(newDiv);var divWidth=newDiv.offsetWidth;body.removeChild(newDiv);return divWidth===3;},position:function(){var newDiv=doc.createElement('div');newDiv.style.cssText='position: absolute; left: 10px;';body.appendChild(newDiv);var divLeft=newDiv.offsetLeft;body.removeChild(newDiv);return divLeft===10;},floatClear:function(){var pass=false,newDiv=doc.createElement('div'),style='style="width: 5px; height: 5px; float: left;"';newDiv.innerHTML='<div '+style+'></div><div '+style+'></div>';body.appendChild(newDiv);var childNodes=newDiv.childNodes,topA=childNodes[0].offsetTop,divB=childNodes[1],topB=divB.offsetTop;if(topA===topB){divB.style.clear='left';topB=divB.offsetTop;if(topA!==topB){pass=true;}}
body.removeChild(newDiv);return pass;},overflow:function(){var newDiv=doc.createElement('div');newDiv.innerHTML='<div style="height: 10px; overflow: hidden;"></div>';body.appendChild(newDiv);var divHeight=newDiv.offsetHeight;body.removeChild(newDiv);return divHeight===10;},ajax:function(){var xmlhttp=false,index=-1,factory,XMLHttpFactories=[function(){return new XMLHttpRequest()},function(){return new ActiveXObject("Msxml2.XMLHTTP")},function(){return new ActiveXObject("Msxml3.XMLHTTP")},function(){return new ActiveXObject("Microsoft.XMLHTTP")}];while((factory=XMLHttpFactories[++index])){try{xmlhttp=factory();}
catch(e){continue;}
break;}
return!!xmlhttp;},resize:function(){return win.onresize!=false;},print:function(){return!!win.print;}};enhance.defaultSettings={testName:'enhanced',loadScripts:[],loadStyles:[],queueLoading:true,appendToggleLink:true,forcePassText:'View high-bandwidth version',forceFailText:'View low-bandwidth version',tests:enhance.defaultTests,addTests:{},alertOnFailure:false,onPass:function(){},onFail:function(){},onLoadError:addIncompleteClass};function cookiesSupported(){var testCookie='enhancejs-cookietest';createCookie(testCookie,'enabled');var result=readCookie(testCookie);eraseCookie(testCookie);return result==='enabled';}
enhance.cookiesSupported=cookiesSupported();function forceFail(){createCookie(settings.testName,'fail');win.location.reload();}
if(enhance.cookiesSupported){enhance.forceFail=forceFail;}
function forcePass(){createCookie(settings.testName,'pass');win.location.reload();}
if(enhance.cookiesSupported){enhance.forcePass=forcePass;}
function reTest(){eraseCookie(settings.testName);win.location.reload();}
if(enhance.cookiesSupported){enhance.reTest=reTest;}
function runTests(){var result=readCookie(settings.testName);if(result){if(result==='pass'){enhancePage();settings.onPass();}else{settings.onFail();}
if(settings.appendToggleLink){windowLoad(function(){appendToggleLinks(result);});}}
else{bodyOnReady(function(){var pass=true;for(var name in settings.tests){pass=settings.tests[name]();if(!pass){if(settings.alertOnFailure){alert(name+' failed');}
break;}}
result=pass?'pass':'fail';createCookie(settings.testName,result);if(pass){enhancePage();settings.onPass();}else{settings.onFail();}
if(settings.appendToggleLink){windowLoad(function(){appendToggleLinks(result);});}});}}
function bodyOnReady(callback){var checkBody=setInterval(bodyReady,1);function bodyReady(){if(doc.body){body=doc.body;clearInterval(checkBody);callback();}}}
function windowLoad(callback){if(windowLoaded){callback();}else{var oldonload=win.onload
win.onload=function(){if(oldonload){oldonload();}
callback();}}}
function appendToggleLinks(result){if(!settings.appendToggleLink||!enhance.cookiesSupported){return;}
if(result){var a=doc.createElement('a');a.href="#";a.className=settings.testName+'_toggleResult';a.innerHTML=result==='pass'?settings.forceFailText:settings.forcePassText;a.onclick=result==='pass'?enhance.forceFail:enhance.forcePass;doc.getElementsByTagName('body')[0].appendChild(a);}}
function enhancePage(){if(doc.documentElement.className.indexOf(settings.testName)===-1){doc.documentElement.className+=' '+settings.testName;}
if(settings.loadStyles.length){appendStyles();}
if(settings.loadScripts.length){settings.queueLoading?appendScriptsSync():appendScriptsAsync();}}
function addIncompleteClass(){var errorClass=settings.testName+'-incomplete';if(doc.documentElement.className.indexOf(errorClass)===-1){doc.documentElement.className+=' '+errorClass;}}
function appendStyles(){var index=-1,item;while((item=settings.loadStyles[++index])){var link=doc.createElement('link');link.type='text/css';link.rel='stylesheet';link.onerror=settings.onLoadError;if(typeof item==='string'){link.href=item;head.appendChild(link);}
else{for(var attr in item){if(attr!=='iecondition'){link.setAttribute(attr,item[attr]);}}
if(item['iecondition']&&isIE()){if(isIE(item['iecondition'])){head.appendChild(link);}}
else if(!item['iecondition']){head.appendChild(link);}}}}
function isIE(version){var isIE=(/MSIE (\d+)\.\d+;/).test(navigator.userAgent);var ieVersion=new Number(RegExp.$1);if(isIE&&version){if(version==='all'||version==ieVersion){return true;}}
else{return isIE;}}
function appendScriptsSync(){var queue=[].concat(settings.loadScripts);function next(){if(queue.length===0){return;}
var item=queue.shift();script=createScriptTag(item),done=false;if(script){script.onload=script.onreadystatechange=function(){if(!done&&(!this.readyState||this.readyState=='loaded'||this.readyState=='complete')){done=true;next();this.onload=this.onreadystatechange=null;}}
head.insertBefore(script,head.firstChild);}
else{next();}}
next();}
function appendScriptsAsync(){var index=-1,item;while((item=settings.loadScripts[++index])){var script=createScriptTag(item);if(script){head.insertBefore(script,head.firstChild);}}}
function createScriptTag(item){var script=doc.createElement('script');script.type='text/javascript';script.onerror=settings.onLoadError;if(typeof item==='string'){script.src=item;return script;}
else{for(var attr in item){if(attr!=='iecondition'){script.setAttribute(attr,item[attr]);}}
if(item['iecondition']&&isIE()){if(isIE(item['iecondition'])){return script;}}
else if(!item['iecondition']){return script;}
else{return false;}}}
function createCookie(name,value,days){if(days){var date=new Date();date.setTime(date.getTime()+(days*24*60*60*1000));var expires="; expires="+date.toGMTString();}
else var expires="";doc.cookie=name+"="+value+expires+"; path=/";}
function readCookie(name){var nameEQ=name+"=";var ca=doc.cookie.split(';');for(var i=0;i<ca.length;i++){var c=ca[i];while(c.charAt(0)==' ')c=c.substring(1,c.length);if(c.indexOf(nameEQ)==0)return c.substring(nameEQ.length,c.length);}
return null;}
function eraseCookie(name){createCookie(name,"",-1);}
function applyDocReadyHack(){if(doc.readyState==null&&doc.addEventListener){doc.addEventListener("DOMContentLoaded",function DOMContentLoaded(){doc.removeEventListener("DOMContentLoaded",DOMContentLoaded,false);doc.readyState="complete";},false);doc.readyState="loading";}}})(window,document);