import { Controller } from "@hotwired/stimulus"

// only the four corners take the power-5 superellipse curve — the edges between them stay perfectly
// straight, same as squircle_dash_border_controller.js's own squirclePath already does for the text
// fields' border. A full |x/a|^5 + |y/b|^5 = 1 curve walked around the whole element, tried first,
// bends every point along the way, edges included — there's no straight run anywhere on a true
// superellipse's own perimeter, which is a different shape from a rectangle with rounded corners, not
// the same shape looking different. Drawn as an actual filled SVG <path>, appended as a real child, the
// same as squircle_dash_border_controller.js appends its own border paths — not a CSS clip-path,
// removing any doubt about whether the browser is rendering the exact path drawn
export default class extends Controller {
	static values = { radius: { type: Number, default: 11 }, power: { type: Number, default: 5 } }

	connect() {
		this.svg = document.createElementNS( "http://www.w3.org/2000/svg", "svg" )
		this.svg.classList.add( "squircle_fill_svg" )
		this.svg.setAttribute( "preserveAspectRatio", "none" )
		this.path = document.createElementNS( "http://www.w3.org/2000/svg", "path" )
		this.path.classList.add( "squircle_fill_path" )
		this.svg.appendChild( this.path )
		this.element.prepend( this.svg )

		this.boundUpdate = this.update.bind( this )
		this.resizeObserver = new ResizeObserver( this.boundUpdate )
		this.resizeObserver.observe( this.element )
		this.update()
	}

	disconnect() {
		this.resizeObserver.disconnect()
	}

	update() {
		const width = this.element.clientWidth
		const height = this.element.clientHeight
		if ( width === 0 || height === 0 ) return

		const radius = Math.min( this.radiusValue, width / 2, height / 2 )
		this.svg.setAttribute( "viewBox", `0 0 ${ width } ${ height }` )
		this.path.setAttribute( "d", this.squirclePath( width, height, radius ) )
	}

	// four quarter-superellipse corners (|x/r|^5 + |y/r|^5 = 1, only across each r×r corner box, not
	// the element's own full half-width/half-height) connected by the rectangle's own straight edges,
	// traced clockwise from the top edge — identical to squircle_dash_border_controller.js's own
	// squirclePath, since a filled shape and a stroked border trace the exact same outline either way
	squirclePath( w, h, r ) {
		const exponent = 2 / this.powerValue
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

//	squircle_fill_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
