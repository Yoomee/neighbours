/**
 * jQuery.ScrollTo
 * Copyright (c) 2007-2009 Ariel Flesler - aflesler(at)gmail(dot)com | http://flesler.blogspot.com
 * Dual licensed under MIT and GPL.
 * Date: 3/9/2009
 *
 * @projectDescription Easy element scrolling using jQuery.
 * http://flesler.blogspot.com/2007/10/jqueryscrollto.html
 * Works with jQuery +1.2.6. Tested on FF 2/3, IE 6/7/8, Opera 9.5/6, Safari 3, Chrome 1 on WinXP.
 *
 * @author Ariel Flesler
 * @version 1.4.1
 *
 * @id jQuery.scrollTo
 * @id jQuery.fn.scrollTo
 * @param {String, Number, DOMElement, jQuery, Object} target Where to scroll the matched elements.
 *	  The different options for target are:
 *		- A number position (will be applied to all axes).
 *		- A string position ('44', '100px', '+=90', etc ) will be applied to all axes
 *		- A jQuery/DOM element ( logically, child of the element to scroll )
 *		- A string selector, that will be relative to the element to scroll ( 'li:eq(2)', etc )
 *		- A hash { top:x, left:y }, x and y can be any kind of number/string like above.
 *		- The string 'max' for go-to-end. 
 * @param {Number} duration The OVERALL length of the animation, this argument can be the settings object instead.
 * @param {Object,Function} settings Optional set of settings or the onAfter callback.
 *	 @option {String} axis Which axis must be scrolled, use 'x', 'y', 'xy' or 'yx'.
 *	 @option {Number} duration The OVERALL length of the animation.
 *	 @option {String} easing The easing method for the animation.
 *	 @option {Boolean} margin If true, the margin of the target element will be deducted from the final position.
 *	 @option {Object, Number} offset Add/deduct from the end position. One number for both axes or { top:x, left:y }.
 *	 @option {Object, Number} over Add/deduct the height/width multiplied by 'over', can be { top:x, left:y } when using both axes.
 *	 @option {Boolean} queue If true, and both axis are given, the 2nd axis will only be animated after the first one ends.
 *	 @option {Function} onAfter Function to be called after the scrolling ends. 
 *	 @option {Function} onAfterFirst If queuing is activated, this function will be called after the first scrolling ends.
 * @return {jQuery} Returns the same jQuery object, for chaining.
 *
 * @desc Scroll to a fixed position
 * @example $('div').scrollTo( 340 );
 *
 * @desc Scroll relatively to the actual position
 * @example $('div').scrollTo( '+=340px', { axis:'y' } );
 *
 * @dec Scroll using a selector (relative to the scrolled element)
 * @example $('div').scrollTo( 'p.paragraph:eq(2)', 500, { easing:'swing', queue:true, axis:'xy' } );
 *
 * @ Scroll to a DOM element (same for jQuery object)
 * @example var second_child = document.getElementById('container').firstChild.nextSibling;
 *			$('#container').scrollTo( second_child, { duration:500, axis:'x', onAfter:function(){
 *				alert('scrolled!!');																   
 *			}});
 *
 * @desc Scroll on both axes, to different values
 * @example $('div').scrollTo( { top: 300, left:'+=200' }, { axis:'xy', offset:-20 } );
 */
(function(e){function n(e){return typeof e=="object"?e:{top:e,left:e}}var t=e.scrollTo=function(t,n,r){e(window).scrollTo(t,n,r)};t.defaults={axis:"xy",duration:parseFloat(e.fn.jquery)>=1.3?0:1},t.window=function(t){return e(window).scrollable()},e.fn.scrollable=function(){return this.map(function(){var t=this,n=!t.nodeName||e.inArray(t.nodeName.toLowerCase(),["iframe","#document","html","body"])!=-1;if(!n)return t;var r=(t.contentWindow||t).document||t.ownerDocument||t;return e.browser.safari||r.compatMode=="BackCompat"?r.body:r.documentElement})},e.fn.scrollTo=function(r,i,s){return typeof i=="object"&&(s=i,i=0),typeof s=="function"&&(s={onAfter:s}),r=="max"&&(r=9e9),s=e.extend({},t.defaults,s),i=i||s.speed||s.duration,s.queue=s.queue&&s.axis.length>1,s.queue&&(i/=2),s.offset=n(s.offset),s.over=n(s.over),this.scrollable().each(function(){function c(e){o.animate(f,i,s.easing,e&&function(){e.call(this,r,s)})}function h(e){var n="scroll"+e;if(!l)return t[n];var r="client"+e,i=t.ownerDocument.documentElement,s=t.ownerDocument.body;return Math.max(i[n],s[n])-Math.min(i[r],s[r])}var t=this,o=e(t),u=r,a,f={},l=o.is("html,body");switch(typeof u){case"number":case"string":if(/^([+-]=)?\d+(\.\d+)?(px)?$/.test(u)){u=n(u);break}u=e(u,this);case"object":if(u.is||u.style)a=(u=e(u)).offset()}e.each(s.axis.split(""),function(e,n){var r=n=="x"?"Left":"Top",i=r.toLowerCase(),p="scroll"+r,d=t[p],v=n=="x"?"Width":"Height";a?(f[p]=a[i]+(l?0:d-o.offset()[i]),s.margin&&(f[p]-=parseInt(u.css("margin"+r))||0,f[p]-=parseInt(u.css("border"+r+"Width"))||0),f[p]+=s.offset[i]||0,s.over[i]&&(f[p]+=u[v.toLowerCase()]()*s.over[i])):f[p]=u[i],/^\d+$/.test(f[p])&&(f[p]=f[p]<=0?0:Math.min(f[p],h(v))),!e&&s.queue&&(d!=f[p]&&c(s.onAfterFirst),delete f[p])}),c(s.onAfter)}).end()}})(jQuery);