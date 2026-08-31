import { Controller } from "@hotwired/stimulus"

// Rounds a photo's corners as power-5 squircles, the same curve the text fields' borders and the cards' fills
// are drawn with. Not corner-shape: superellipse( 5 ), which is only in Chromium so far: this cuts the image
// itself to a clip-path, from the size it is actually drawn at, so it comes out the same in Firefox. Only the four
// corners take the curve, the edges between them stay straight, as squircle_fill_controller.js does. A photo set
// object-fit: contain, as the Cover Flow's are, is cut round the picture as it lies in its box, not round the box,
// so a photo that doesn't fill it has round corners on the photo and not on empty space beside it
export default class extends Controller {
	static values = { radius: { type: Number, default: 18 }, power: { type: Number, default: 5 } }

	connect() {
		this.boundUpdate = this.update.bind( this )
		this.resizeObserver = new ResizeObserver( this.boundUpdate )
		this.resizeObserver.observe( this.element )
		this.element.addEventListener( "load", this.boundUpdate )
		this.update()
	}

	disconnect() {
		this.resizeObserver.disconnect()
		this.element.removeEventListener( "load", this.boundUpdate )
		this.element.style.clipPath = ""
	}

	update() {
		const boxWidth = this.element.clientWidth
		const boxHeight = this.element.clientHeight
		if ( boxWidth === 0 || boxHeight === 0 ) return

		let x = 0, y = 0, width = boxWidth, height = boxHeight
		const { naturalWidth, naturalHeight } = this.element
		if ( getComputedStyle( this.element ).objectFit === "contain" && naturalWidth && naturalHeight ) {
			const scale = Math.min( boxWidth / naturalWidth, boxHeight / naturalHeight )
			width = naturalWidth * scale
			height = naturalHeight * scale
			x = ( boxWidth - width ) / 2
			y = ( boxHeight - height ) / 2
		}

		const radius = Math.min( this.radiusValue, width / 2, height / 2 )
		this.element.style.clipPath = `path( "${ this.squirclePath( x, y, width, height, radius ) }" )`
	}

	// four quarter-superellipse corners (|x/r|^5 + |y/r|^5 = 1, only across each r×r corner box) joined by the
	// rectangle's own straight edges, clockwise from the top edge, offset to where the picture lies in the box —
	// squircle_fill_controller.js's own squirclePath, with that offset
	squirclePath( x, y, w, h, r ) {
		const exponent = 2 / this.powerValue
		const segments = 12
		const point = ( px, py ) => `${ ( x + px ).toFixed( 2 ) },${ ( y + py ).toFixed( 2 ) }`

		const corner = ( cx, cy, curve ) => {
			const pts = []
			for ( let i = 0; i <= segments; i++ ) {
				const theta = ( Math.PI / 2 ) * ( i / segments )
				const a = Math.sin( theta ) ** exponent
				const b = Math.cos( theta ) ** exponent
				const [ dx, dy ] = curve( a, b )
				pts.push( point( cx + dx, cy + dy ) )
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

//	squircle_clip_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
