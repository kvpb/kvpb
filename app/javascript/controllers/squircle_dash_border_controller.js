import { Controller } from "@hotwired/stimulus"

// Draws an SVG outline of this element's own squircle (a power-5 superellipse corner, matching the
// corner-shape:superellipse(5) the CSS border already uses) as two superimposed paths — one solid,
// one dashed and animated to march — crossfaded by opacity on focus. They share one d/transform
// computed once per update() rather than each tracing its own, so the solid and dashed states are
// pixel-identical and focusing a field reads as the same border changing state, not one border being
// swapped for a slightly different one. Only the dashed path needs SVG at all: a rotating conic-
// gradient ring, the first attempt at just the motion, spins the whole ring like a clock hand, not
// the marching-ants look actually wanted, and only an SVG path's stroke-dashoffset can animate dashes
// flowing along an arbitrary curve, through the corners, the way a native dashed border never could
export default class extends Controller {
	static values = { radius: { type: Number, default: 14 } }

	connect() {
		this.svg = document.createElementNS( "http://www.w3.org/2000/svg", "svg" )
		this.svg.classList.add( "squircle_dash_border_svg" )
		this.svg.setAttribute( "preserveAspectRatio", "none" )
		this.solidPath = document.createElementNS( "http://www.w3.org/2000/svg", "path" )
		this.solidPath.classList.add( "squircle_dash_border_path", "squircle_dash_border_path_solid" )
		this.dashedPath = document.createElementNS( "http://www.w3.org/2000/svg", "path" )
		this.dashedPath.classList.add( "squircle_dash_border_path", "squircle_dash_border_path_dashed" )
		this.svg.append( this.solidPath, this.dashedPath )
		this.element.appendChild( this.svg )

		this.boundUpdate = this.update.bind( this )
		this.resizeObserver = new ResizeObserver( this.boundUpdate )
		this.resizeObserver.observe( this.element )
		this.update()

		this.dashOffset = 0
		this.boundTick = this.tick.bind( this )
		this.boundStartMarching = this.startMarching.bind( this )
		this.boundStopMarching = this.stopMarching.bind( this )
		this.element.addEventListener( "focusin", this.boundStartMarching )
		this.element.addEventListener( "focusout", this.boundStopMarching )
	}

	disconnect() {
		this.resizeObserver.disconnect()
		this.stopMarching()
		this.element.removeEventListener( "focusin", this.boundStartMarching )
		this.element.removeEventListener( "focusout", this.boundStopMarching )
	}

	// CSS itself animating stroke-dashoffset — the earlier, first attempt at this — hits a genuine
	// Chromium rendering bug once the path it's animating gets long enough (a wide field on a wide
	// enough page): most of the dashes silently stop painting past some point along the path, confirmed
	// by freezing that same animation, which alone made it render whole again. Stepping dashoffset by
	// hand on every frame instead doesn't trip it, so the motion is driven from here instead
	startMarching() {
		if ( this.rafId ) return
		this.lastTick = performance.now()
		this.rafId = requestAnimationFrame( this.boundTick )
	}

	stopMarching() {
		if ( this.rafId ) cancelAnimationFrame( this.rafId )
		this.rafId = null
	}

	// 16px every 1000ms, the same cycle the old march_dashes @keyframes ran — dashoffset increasing,
	// not decreasing, is what marches the dashes forward along the path's own clockwise drawing
	// direction, "le sens trigonométrique", the same reasoning march_dashes itself was built on
	tick( now ) {
		const elapsed = now - this.lastTick
		this.lastTick = now
		this.dashOffset = ( this.dashOffset + elapsed * ( 16 / 1000 ) ) % 16
		this.dashedPath.style.strokeDashoffset = this.dashOffset
		this.rafId = requestAnimationFrame( this.boundTick )
	}

	// clientWidth/clientHeight stop at the padding edge, and text_field_glass clips its children there
	// too — so a path drawn flush with that edge only ever shows the inward half of its stroke, reading
	// as a thinner, inset line rather than sitting where a native border would. Insetting the path by
	// half the stroke width puts the stroke's outer edge exactly on that same clipped boundary instead,
	// so the full stroke width renders visibly in place
	update() {
		const width = this.element.clientWidth
		const height = this.element.clientHeight
		if ( width === 0 || height === 0 ) return

		const strokeWidth = parseFloat( getComputedStyle( this.solidPath ).strokeWidth )
		const inset = strokeWidth / 2
		const outerRadius = Math.min( this.radiusValue, width / 2, height / 2 )
		const d = this.squirclePath( width - strokeWidth, height - strokeWidth, outerRadius - inset )
		const transform = `translate( ${ inset }, ${ inset } )`

		this.svg.setAttribute( "viewBox", `0 0 ${ width } ${ height }` )
		this.solidPath.setAttribute( "d", d )
		this.solidPath.setAttribute( "transform", transform )
		this.dashedPath.setAttribute( "d", d )
		this.dashedPath.setAttribute( "transform", transform )
	}

	// four quarter-superellipse corners (|x/r|^5 + |y/r|^5 = 1, the same curve corner-shape:superellipse(5)
	// draws) connected by the rectangle's own straight edges, traced clockwise from the top edge. Each
	// corner is its own explicit formula rather than one generalized/rotated helper — with only four of
	// them, spelling each out plainly reads back correctly against its own geometry far more easily than
	// unwinding a shared transform would
	squirclePath( w, h, r ) {
		const exponent = 2 / 5
		const segments = 12
		const point = ( x, y ) => `${ x.toFixed( 2 ) },${ y.toFixed( 2 ) }`

		const corner = ( cx, cy, curve ) => {
			const pts = []
			for ( let i = 0; i <= segments; i++ ) {
				const theta = ( Math.PI / 2 ) * ( i / segments )
				const a = Math.sin( theta ) ** exponent
				const b = Math.cos( theta ) ** exponent
				const [ x, y ] = curve( a, b )
				pts.push( point( cx + x, cy + y ) )
			}
			return pts.join( " L " )
		}

		const topRight = corner( w - r, r, ( a, b ) => [ r * a, -r * b ] )
		const bottomRight = corner( w - r, h - r, ( a, b ) => [ r * b, r * a ] )
		const bottomLeft = corner( r, h - r, ( a, b ) => [ -r * a, r * b ] )
		const topLeft = corner( r, r, ( a, b ) => [ -r * b, -r * a ] )

		return `M ${ point( r, 0 ) } L ${ point( w - r, 0 ) } L ${ topRight } L ${ point( w, h - r ) } L ${ bottomRight } L ${ point( r, h ) } L ${ bottomLeft } L ${ point( 0, r ) } L ${ topLeft } Z`
	}
}

//	squircle_dash_border_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
