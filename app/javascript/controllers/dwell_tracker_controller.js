import { Controller } from "@hotwired/stimulus"

// Attention retained on this one photo, weighted by how much of it is actually in the viewport —
// never per visitor, never stored anywhere but folded once into the photo's own single running
// total server-side. No periodic pings: everything accumulates locally in this.accumulated and is
// flushed exactly once, whichever comes first — disconnect() (a Turbo navigation removes this
// element from the DOM without ever firing a real unload event) or pagehide/visibility turning
// hidden (an actual tab close/reload, which Turbo navigation alone never triggers). keepalive lets
// that flush's fetch survive the navigation or tab close that's happening in the same instant
export default class extends Controller {
	static values = { photoId: Number }

	connect() {
		this.accumulated = 0
		this.lastTick = null
		this.ratio = 0

		this.boundIntersect = this.onIntersect.bind( this )
		this.observer = new IntersectionObserver( this.boundIntersect, { threshold: [ 0, 0.25, 0.5, 0.75, 1 ] } )
		this.observer.observe( this.element )

		this.boundTick = this.tick.bind( this )
		this.boundVisibilityChange = this.onVisibilityChange.bind( this )
		this.boundFlush = this.flush.bind( this )
		document.addEventListener( "visibilitychange", this.boundVisibilityChange )
		window.addEventListener( "pagehide", this.boundFlush )
		this.rafId = requestAnimationFrame( this.boundTick )
	}

	disconnect() {
		this.observer.disconnect()
		cancelAnimationFrame( this.rafId )
		document.removeEventListener( "visibilitychange", this.boundVisibilityChange )
		window.removeEventListener( "pagehide", this.boundFlush )
		this.flush()
	}

	onIntersect( entries ) {
		this.ratio = entries[ entries.length - 1 ].intersectionRatio
	}

	tick( now ) {
		if ( this.lastTick !== null && document.visibilityState === "visible" && this.ratio > 0 ) {
			this.accumulated += ( ( now - this.lastTick ) / 1000 ) * this.ratio
		}
		this.lastTick = now
		this.rafId = requestAnimationFrame( this.boundTick )
	}

	onVisibilityChange() {
		if ( document.visibilityState === "hidden" ) {
			this.flush()
		} else {
			this.lastTick = null
		}
	}

	flush() {
		if ( this.accumulated < 0.5 ) return
		const seconds = this.accumulated
		this.accumulated = 0

		fetch( `/photos/${ this.photoIdValue }/dwell`, {
			method: "POST",
			keepalive: true,
			headers: {
				"Content-Type": "application/json",
				"X-CSRF-Token": document.querySelector( 'meta[name="csrf-token"]' ).content,
			},
			body: JSON.stringify( { seconds } ),
		} )
	}
}

//	dwell_tracker_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
