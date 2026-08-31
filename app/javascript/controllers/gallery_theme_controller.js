import { Controller } from "@hotwired/stimulus"

// Adds gallery_page after the page's own first paint rather than the server rendering the class
// directly, so there's a real "before" value for the transition below to animate from — a class
// already present in the HTML Turbo delivers has no prior state on this fresh body to shift away
// from, so the recolor would just snap. Two rAFs, not one: the first only guarantees the browser
// has scheduled the next paint, not that it already painted the pre-class styles; the second runs
// after that paint has actually happened, which is what a style change here needs to be seen as a
// change at all instead of folding into the page's very first render
export default class extends Controller {
	connect() {
		requestAnimationFrame( () => {
			requestAnimationFrame( () => {
				this.element.classList.add( "gallery_page" )
			} )
		} )
	}
}

//	gallery_theme_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
