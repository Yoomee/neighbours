(function(){var e=!0,t=null,n=!1;(function(){var i,s={}.hasOwnProperty,o=[].slice;((i=this.google)!=t?i.maps:void 0)!=t&&(this.OverlappingMarkerSpiderfier=function(){function i(e,n){var r,i,o,a,f=this;this.map=e,n==t&&(n={});for(r in n)s.call(n,r)&&(i=n[r],this[r]=i);this.p=new this.constructor.f(this.map),this.m(),this.b={},a=["click","zoom_changed","maptypeid_changed"],i=0;for(o=a.length;i<o;i++)r=a[i],u.addListener(this.map,r,function(){return f.unspiderfy()})}var u,a,f,l,c,p,d;return p=i.prototype,p.VERSION="0.2.8",a=google.maps,u=a.event,c=a.MapTypeId,d=2*Math.PI,p.keepSpiderfied=n,p.markersWontHide=n,p.markersWontMove=n,p.nearbyDistance=20,p.circleSpiralSwitchover=9,p.circleFootSeparation=23,p.circleStartAngle=d/12,p.spiralFootSeparation=26,p.spiralLengthStart=11,p.spiralLengthFactor=4,p.spiderfiedZIndex=1e3,p.usualLegZIndex=10,p.highlightedLegZIndex=20,p.legWeight=1.5,p.legColors={usual:{},highlighted:{}},l=p.legColors.usual,f=p.legColors.highlighted,l[c.HYBRID]=l[c.SATELLITE]="#fff",f[c.HYBRID]=f[c.SATELLITE]="#f00",l[c.TERRAIN]=l[c.ROADMAP]="#444",f[c.TERRAIN]=f[c.ROADMAP]="#f00",p.m=function(){this.a=[],this.i=[]},p.addMarker=function(i){var s,o=this;return i._oms!=t?this:(i._oms=e,s=[u.addListener(i,"click",function(){return o.F(i)})],this.markersWontHide||s.push(u.addListener(i,"visible_changed",function(){return o.n(i,n)})),this.markersWontMove||s.push(u.addListener(i,"position_changed",function(){return o.n(i,e)})),this.i.push(s),this.a.push(i),this)},p.n=function(e,n){if(e._omsData!=t&&(n||!e.getVisible())&&this.s==t&&this.t==t)return this.H(n?e:t)},p.getMarkers=function(){return this.a.slice(0)},p.removeMarker=function(e){var n,r,i,s,o;e._omsData!=t&&this.unspiderfy(),n=this.l(this.a,e);if(0>n)return this;i=this.i.splice(n,1)[0],s=0;for(o=i.length;s<o;s++)r=i[s],u.removeListener(r);return delete e._oms,this.a.splice(n,1),this},p.clearMarkers=function(){var e,t,n,r,i,s,o,a;this.unspiderfy(),a=this.a,e=r=0;for(s=a.length;r<s;e=++r){n=a[e],t=this.i[e],i=0;for(o=t.length;i<o;i++)e=t[i],u.removeListener(e);delete n._oms}return this.m(),this},p.addListener=function(e,n){var r,i;return((i=(r=this.b)[e])!=t?i:r[e]=[]).push(n),this},p.removeListener=function(e,t){var n;return n=this.l(this.b[e],t),0>n||this.b[e].splice(n,1),this},p.clearListeners=function(e){return this.b[e]=[],this},p.trigger=function(){var e,n,r,i,s,u;n=arguments[0],e=2<=arguments.length?o.call(arguments,1):[],n=(r=this.b[n])!=t?r:[],u=[],i=0;for(s=n.length;i<s;i++)r=n[i],u.push(r.apply(t,e));return u},p.u=function(e,t){var n,r,i,s,o;i=this.circleFootSeparation*(2+e)/d,r=d/e,o=[];for(n=s=0;0<=e?s<e:s>e;n=0<=e?++s:--s)n=this.circleStartAngle+n*r,o.push(new a.Point(t.x+i*Math.cos(n),t.y+i*Math.sin(n)));return o},p.v=function(e,t){var n,r,i,s,o;i=this.spiralLengthStart,n=0,o=[];for(r=s=0;0<=e?s<e:s>e;r=0<=e?++s:--s)n+=this.spiralFootSeparation/i+5e-4*r,r=new a.Point(t.x+i*Math.cos(n),t.y+i*Math.sin(n)),i+=d*this.spiralLengthFactor/n,o.push(r);return o},p.F=function(e){var n,r,i,s,o,u,a,f,l;s=e._omsData!=t,(!s||!this.keepSpiderfied)&&this.unspiderfy();if(s||this.map.getStreetView().getVisible())return this.trigger("click",e);s=[],o=[],n=this.nearbyDistance,u=n*n,i=this.c(e.position),l=this.a,a=0;for(f=l.length;a<f;a++)n=l[a],n.map!=t&&n.getVisible()&&(r=this.c(n.position),this.e(r,i)<u?s.push({A:n,o:r}):o.push(n));return 1===s.length?this.trigger("click",e):this.G(s,o)},p.willSpiderfy=function(i){var s,o,u,a,f,l,c,p;o=this.nearbyDistance,u=o*o,o=this.c(i.position),l=this.a,a=0;for(f=l.length;a<f;a++)if(s=l[a],s!==i&&s.map!=t&&!!s.getVisible())if(s=this.c((c=(p=s._omsData)!=t?p.k:void 0)!=t?c:s.position),this.e(s,o)<u)return e;return n},p.markersThatWillAndWontSpiderfy=function(){var i,s,o,u,a,f,l,c,p,d,v,m;f=this.nearbyDistance,i=f*f,u=this.a,f=[],d=0;for(o=u.length;d<o;d++)s=u[d],f.push({q:this.c((l=(c=s._omsData)!=t?c.k:void 0)!=t?l:s.position),d:n});d=this.a,s=l=0;for(c=d.length;l<c;s=++l)if(o=d[s],o.map!=t&&o.getVisible()&&(u=f[s],!u.d)){m=this.a,o=p=0;for(v=m.length;p<v;o=++p)if(a=m[o],o!==s&&a.map!=t&&a.getVisible()&&(a=f[o],(!(o<s)||a.d)&&this.e(u.q,a.q)<i)){u.d=a.d=e;break}}l=[],c=[],u=this.a,i=d=0;for(o=u.length;d<o;i=++d)s=u[i],(f[i].d?l:c).push(s);return[l,c]},p.z=function(e){var t=this;return{g:function(){return e._omsData.h.setOptions({strokeColor:t.legColors.highlighted[t.map.mapTypeId],zIndex:t.highlightedLegZIndex})},j:function(){return e._omsData.h.setOptions({strokeColor:t.legColors.usual[t.map.mapTypeId],zIndex:t.usualLegZIndex})}}},p.G=function(t,n){var r,i,s,o,f,l,c,p,d,v;return this.s=e,v=t.length,r=this.C(function(){var e,n,r;r=[],e=0;for(n=t.length;e<n;e++)p=t[e],r.push(p.o);return r}()),o=v>=this.circleSpiralSwitchover?this.v(v,r).reverse():this.u(v,r),r=function(){var e,n,r,h=this;r=[],e=0;for(n=o.length;e<n;e++)s=o[e],i=this.D(s),d=this.B(t,function(e){return h.e(e.o,s)}),c=d.A,l=new a.Polyline({map:this.map,path:[c.position,i],strokeColor:this.legColors.usual[this.map.mapTypeId],strokeWeight:this.legWeight,zIndex:this.usualLegZIndex}),c._omsData={k:c.position,h:l},this.legColors.highlighted[this.map.mapTypeId]!==this.legColors.usual[this.map.mapTypeId]&&(f=this.z(c),c._omsData.w={g:u.addListener(c,"mouseover",f.g),j:u.addListener(c,"mouseout",f.j)}),c.setPosition(i),c.setZIndex(Math.round(this.spiderfiedZIndex+s.y)),r.push(c);return r}.call(this),delete this.s,this.r=e,this.trigger("spiderfy",r,n)},p.unspiderfy=function(n){var r,i,s,o,a,f,l;n==t&&(n=t);if(this.r==t)return this;this.t=e,o=[],s=[],l=this.a,a=0;for(f=l.length;a<f;a++)i=l[a],i._omsData!=t?(i._omsData.h.setMap(t),i!==n&&i.setPosition(i._omsData.k),i.setZIndex(t),r=i._omsData.w,r!=t&&(u.removeListener(r.g),u.removeListener(r.j)),delete i._omsData,o.push(i)):s.push(i);return delete this.t,delete this.r,this.trigger("unspiderfy",o,s),this},p.e=function(e,t){var n,r;return n=e.x-t.x,r=e.y-t.y,n*n+r*r},p.C=function(e){var t,n,r,i,s;i=n=r=0;for(s=e.length;i<s;i++)t=e[i],n+=t.x,r+=t.y;return e=e.length,new a.Point(n/e,r/e)},p.c=function(e){return this.p.getProjection().fromLatLngToDivPixel(e)},p.D=function(e){return this.p.getProjection().fromDivPixelToLatLng(e)},p.B=function(e,n){var r,i,s,o,u,a;s=u=0;for(a=e.length;u<a;s=++u)if(o=e[s],o=n(o),"undefined"==typeof r||r===t||o<i)i=o,r=s;return e.splice(r,1)[0]},p.l=function(e,n){var r,i,s,o;if(e.indexOf!=t)return e.indexOf(n);r=s=0;for(o=e.length;s<o;r=++s)if(i=e[r],i===n)return r;return-1},i.f=function(e){return this.setMap(e)},i.f.prototype=new a.OverlayView,i.f.prototype.draw=function(){},i}())}).call(this)}).call(this);