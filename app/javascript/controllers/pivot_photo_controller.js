import { Controller } from "@hotwired/stimulus"

// The easter egg: on one page load in a hundred, after ten seconds without anyone touching the page, a photograph of
// Karl swings in at the top right of the window, as far from the top as the header is, and comes only halfway in — its own middle sits on the
// window's right edge, so half of it is in the room and half is still outside — and there it stays, leaning well
// over toward the window, far enough that the thumb held up on its far side comes into view, like someone looking in
// through one, or leaning out from behind a tree trunk. It turns
// about a pivot at the middle of its own bottom edge, which is the point that sits on the edge, held at that lean by
// a virtual spring: a torsional one, so it pulls the photograph back toward its lean with a force that grows with how
// far it is from it, and a little damping lets each swing die away rather than ring forever. It comes in already
// turned out past the window's edge and is pulled home by that same spring, which is what makes it swing rather than
// slide. It can be taken by hand and turned; it goes wherever the pointer points from the pivot, and nowhere else,
// since an angle is the only thing that is ever stored — the photograph can never leave its arc. Let go and the
// spring has it again, carrying the speed of the hand with it, so a flick overshoots and rocks back
//
// A page load is a load, not a page: a fresh one, a Turbo visit and a return by the back button each throw the dice
// again, once, and the copy Turbo shows for a moment while the real page is on its way throws none. The image isn't
// fetched until the moment it is due, so nobody who leaves before the ten seconds are up, nor on the ninety-nine loads
// in a hundred that come to nothing, ever downloads it, and once it is up it stays for the rest of the page: nothing
// asked for it to go away again
const PRESENCE_EVENTS = [ "pointermove", "pointerdown", "keydown", "wheel", "scroll", "touchstart" ]
const MAX_RELEASE_SPEED = 25

export default class extends Controller {
	static targets = [ "swing", "image" ]
	static values = {
		src: String,
		idle: { type: Number, default: 10000 },
		// idle: { type: Number, default: 60000 },
		chance: { type: Number, default: 0.01 },
		entryAngle: { type: Number, default: 100 },
		// entryAngle: { type: Number, default: 110 },
		restAngle: { type: Number, default: -40 },
		// restAngle: { type: Number, default: -6 },
		maxAngle: { type: Number, default: 85 },
		frequency: { type: Number, default: 1.1 },
		damping: { type: Number, default: 0.35 }
		// damping: { type: Number, default: 0.25 }
	}

	connect() {
		this.angle = 0
		this.velocity = 0
		this.shown = false
		this.dragging = false
		this.frame = null
		this.lastTime = 0
		this.samples = []
		this.lastActivity = performance.now()
		// a page Turbo brings back from its cache can carry the photograph still showing, from the visit it was cached on
		this.element.classList.remove( "shown" )
		this.swingTarget.style.transform = ""
		this.imageTarget.removeAttribute( "src" )
		this.chosen = !document.documentElement.hasAttribute( "data-turbo-preview" ) && Math.random() < this.chanceValue
		if ( !this.chosen ) return
		this.boundActivity = this.noteActivity.bind( this )
		this.boundVisibility = this.onVisibilityChange.bind( this )
		this.boundTick = this.tick.bind( this )
		this.boundPointerDown = this.onPointerDown.bind( this )
		this.boundPointerMove = this.onPointerMove.bind( this )
		this.boundPointerUp = this.onPointerUp.bind( this )
		// capture, so that a scroll inside any element, not only the page's own, still counts as someone being there
		for ( const name of PRESENCE_EVENTS ) window.addEventListener( name, this.boundActivity, { capture: true, passive: true } )
		document.addEventListener( "visibilitychange", this.boundVisibility )
		this.swingTarget.addEventListener( "pointerdown", this.boundPointerDown )
		this.idleTimer = setInterval( this.checkIdle.bind( this ), 500 )
	}

	disconnect() {
		if ( !this.chosen ) return
		for ( const name of PRESENCE_EVENTS ) window.removeEventListener( name, this.boundActivity, { capture: true } )
		document.removeEventListener( "visibilitychange", this.boundVisibility )
		this.swingTarget.removeEventListener( "pointerdown", this.boundPointerDown )
		this.swingTarget.removeEventListener( "pointermove", this.boundPointerMove )
		this.swingTarget.removeEventListener( "pointerup", this.boundPointerUp )
		this.swingTarget.removeEventListener( "pointercancel", this.boundPointerUp )
		clearInterval( this.idleTimer )
		this.stopTicking()
	}

	noteActivity() {
		this.lastActivity = performance.now()
	}

	// a tab nobody can see isn't a tab nobody is using, so the minute starts over the moment it is looked at again
	onVisibilityChange() {
		if ( !document.hidden ) this.noteActivity()
	}

	checkIdle() {
		if ( this.shown || document.hidden ) return
		if ( performance.now() - this.lastActivity >= this.idleValue ) this.show()
	}

	async show() {
		this.shown = true
		clearInterval( this.idleTimer )
		this.imageTarget.src = this.srcValue
		try {
			await this.imageTarget.decode()
		} catch {
			// the photograph never arrived, so there is nothing to swing in
			return
		}
		// a Turbo visit can have taken the page away while the image was on its way
		if ( !this.element.isConnected ) return
		// someone who asks for less motion gets the photograph at rest, not swinging in; it can still be grabbed
		const reducedMotion = window.matchMedia( "(prefers-reduced-motion: reduce)" ).matches
		this.angle = reducedMotion ? this.restRadians : this.entryAngleValue * Math.PI / 180
		// this.angle = reducedMotion ? 0 : this.entryAngleValue * Math.PI / 180
		this.velocity = 0
		this.render()
		this.element.classList.add( "shown" )
		this.startTicking()
	}

	// Pointer capture keeps the drag going when the pointer leaves the photograph, which it will, the moment the
	// photograph turns out from under it
	onPointerDown( event ) {
		if ( event.button !== 0 ) return
		event.preventDefault()
		this.dragging = true
		this.stopTicking()
		this.swingTarget.setPointerCapture( event.pointerId )
		this.swingTarget.addEventListener( "pointermove", this.boundPointerMove )
		this.swingTarget.addEventListener( "pointerup", this.boundPointerUp )
		this.swingTarget.addEventListener( "pointercancel", this.boundPointerUp )
		const pointerAngle = this.pointerAngle( event )
		// the photograph is held by the spot that was taken, not by its center: it turns by as much as the pointer
		// does from here on, rather than jumping to face the pointer
		this.grabOffset = this.angle - pointerAngle
		this.lastPointerAngle = pointerAngle
		this.unwrappedPointerAngle = pointerAngle
		this.velocity = 0
		this.samples = [ { time: performance.now(), angle: this.angle } ]
	}

	onPointerMove( event ) {
		if ( !this.dragging ) return
		// right on top of the pivot a pixel either way flips the angle wildly, so there the pointer says nothing
		if ( this.overPivot( event ) ) return
		const pointerAngle = this.pointerAngle( event )
		// atan2 jumps by a whole turn where it wraps at straight down; summing the shortest way round each time keeps
		// the angle continuous, so turning the photograph past there doesn't spin it the other way
		let step = pointerAngle - this.lastPointerAngle
		if ( step > Math.PI ) step -= 2 * Math.PI
		if ( step < -Math.PI ) step += 2 * Math.PI
		this.lastPointerAngle = pointerAngle
		this.unwrappedPointerAngle += step
		const limit = this.maxAngleValue * Math.PI / 180
		this.angle = Math.max( -limit, Math.min( limit, this.unwrappedPointerAngle + this.grabOffset ) )
		this.render()
		const now = performance.now()
		this.samples.push( { time: now, angle: this.angle } )
		while ( this.samples.length > 2 && now - this.samples[ 0 ].time > 100 ) this.samples.shift()
	}

	onPointerUp( event ) {
		if ( !this.dragging ) return
		this.dragging = false
		this.swingTarget.removeEventListener( "pointermove", this.boundPointerMove )
		this.swingTarget.removeEventListener( "pointerup", this.boundPointerUp )
		this.swingTarget.removeEventListener( "pointercancel", this.boundPointerUp )
		if ( this.swingTarget.hasPointerCapture( event.pointerId ) ) this.swingTarget.releasePointerCapture( event.pointerId )
		// the speed it leaves the hand at is how far it turned over the last tenth of a second; a hand that stopped
		// before letting go leaves nothing in that window, and lets go of it dead still
		const now = performance.now()
		const recent = this.samples.filter( ( sample ) => now - sample.time <= 100 )
		const first = recent[ 0 ]
		const last = recent[ recent.length - 1 ]
		this.velocity = recent.length >= 2 && last.time > first.time
			? Math.max( -MAX_RELEASE_SPEED, Math.min( MAX_RELEASE_SPEED, ( last.angle - first.angle ) / ( ( last.time - first.time ) / 1000 ) ) )
			: 0
		this.startTicking()
	}

	// the angle from straight up, clockwise, of the pointer as seen from the pivot — the middle of the bottom edge of
	// the box the photograph sits in, which is the one thing that never turns, so it is read from the box and not from
	// the photograph
	pointerAngle( event ) {
		const box = this.element.getBoundingClientRect()
		return Math.atan2( event.clientX - ( box.left + box.width / 2 ), box.bottom - event.clientY )
	}

	overPivot( event ) {
		const box = this.element.getBoundingClientRect()
		return Math.hypot( event.clientX - ( box.left + box.width / 2 ), box.bottom - event.clientY ) < 8
	}

	startTicking() {
		if ( this.frame ) return
		this.lastTime = performance.now()
		this.frame = requestAnimationFrame( this.boundTick )
	}

	stopTicking() {
		if ( this.frame ) cancelAnimationFrame( this.frame )
		this.frame = null
	}

	// The spring, integrated against the time that really passed, not once per frame: a screen at 30 frames a second
	// or at 120 sees the same swing at the same speed. Each frame is cut into steps of a 240th of a second at most,
	// so a stiff spring and a long frame together can't overshoot into instability, and a frame that took over a
	// twentieth of a second (a tab coming back to life) is taken as a twentieth rather than skipping the swing ahead
	tick( time ) {
		const elapsed = Math.min( Math.max( ( time - this.lastTime ) / 1000, 0 ), 1 / 20 )
		this.lastTime = time
		const omega = 2 * Math.PI * this.frequencyValue
		const stiffness = omega * omega
		const drag = 2 * this.dampingValue * omega
		const rest = this.restRadians
		const steps = Math.max( 1, Math.ceil( elapsed * 240 ) )
		const step = elapsed / steps
		for ( let i = 0; i < steps; i++ ) {
			this.velocity += ( -stiffness * ( this.angle - rest ) - drag * this.velocity ) * step
			// this.velocity += ( -stiffness * this.angle - drag * this.velocity ) * step
			this.angle += this.velocity * step
		}
		// once it is back within a few hundredths of a degree of its lean and has all but stopped, it is at rest:
		// set it there exactly and stop asking for frames, rather than rewrite the same transform sixty times a second
		if ( Math.abs( this.angle - rest ) < 0.0005 && Math.abs( this.velocity ) < 0.005 ) {
			// if ( Math.abs( this.angle ) < 0.0005 && Math.abs( this.velocity ) < 0.005 ) {
			this.angle = rest
			// this.angle = 0
			this.velocity = 0
			this.render()
			this.frame = null
			return
		}
		this.render()
		this.frame = requestAnimationFrame( this.boundTick )
	}

	// the angle the spring holds it at, in radians: leaning in toward the window, so negative, since the angles run
	// clockwise from straight up and the window is to the photograph's left
	get restRadians() {
		return this.restAngleValue * Math.PI / 180
	}

	render() {
		this.swingTarget.style.transform = `rotate( ${ this.angle }rad )`
	}
}

//	pivot_photo_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
