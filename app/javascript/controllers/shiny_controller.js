import { Controller } from "@hotwired/stimulus"

// A page load can be a shiny one, and at the odds of the games the shininess is taken from, as their data has
// them, not worked into others: a rare page, 8 loads in 65536, the odds of a shiny Pokémon in Gold and Silver,
// and a super rare page, 1 load in 65536, the odds of a square shiny one in Sword and Shield. The 48 frames
// of the Game Boy's own shiny sparkles play, centred on the wordmark, in front of everything, for ever, on
// this load of the page and no other; while they play the page turns once, briefly, to the other of its two
// appearances, day or night, as the battle's background turns black; and characters of text take, in a very
// quick fade, a colour of their own, all of them the same lightness and the same chroma and each its own hue,
// as a shiny Pokémon's palette is another with the same drawing
//
// Which characters depends on which shininess it is, star or square. A rare page is a star: it colours the
// wordmark, and only it, the logo becoming many-coloured. A super rare page is a square: it colours all the
// text the page was loaded with, the wordmark included. Text that comes after, put on the page by a script,
// is not part of the page as it was loaded, and is left as it is; and text that already has a colour, not a
// grey, is left as it is too
//
// The colours are laid over the text without touching it: each character is a range of the text, and each
// range belongs to one of a few highlights, one per hue, which the page's own text is painted with the way a
// search or a selection paints it. Not one element is added to the text nor one node of it split, so what
// scripts hold of the page, a heading a script is rewriting for one, stays as they hold it, and a copy of the
// text is a copy of the text
//
// The game draws a frame every 70224 cycles of its 4194304 Hz clock: 16.7427 ms, 59.7275 Hz. The sparkles are
// an APNG whose frames wait exactly that (400/23891 s), so the 48 of them last 803.65 ms as they do on the
// console; a GIF of them, the fallback for a browser that can't play the APNG, can only wait in hundredths
// of a second and takes 960 ms. The turn to the other appearance is timed off the same frame length: it
// begins on the 4th frame and lasts 5 of them, and it is an inversion and no more, in one frame of the
// display and back in one, nothing easing. It is set on the display's own frames, each to the one nearest
// the instant it is due, so that it lasts the number of them nearest to 5 frames of the console: 5 on a
// display of 60 Hz, 10 on 120 Hz, 12 on 144 Hz
//
// Nothing happens on any other load: no element is added and no character is touched. ?shiny in the
// address is the one way to make it happen at will, as a rare page, and ?shiny=square as a super rare one.
// Someone who asked their system for less motion gets the colours and nothing that moves
const GAME_BOY_FRAME_MS = 70224 / 4194304 * 1000
const FRAME_SIZE = 48
// Gold and Silver: a Pokémon is shiny when its Defense, Speed and Special DVs are all 10 and its Attack DV is
// one of these eight. Each of the four DVs is a number from 0 to 15, 16 to the 4th, 65536 in all, 8 of which
// are these
const SHINY_ATTACK_DVS = [ 2, 3, 6, 7, 10, 11, 14, 15 ]
const rollDV = () => Math.floor( Math.random() * 16 )
const isRare = () => {
	const [ attack, defense, speed, special ] = [ rollDV(), rollDV(), rollDV(), rollDV() ]
	return defense === 10 && speed === 10 && special === 10 && SHINY_ATTACK_DVS.includes( attack )
}
// Sword and Shield: a Pokémon has a personality value of 32 bits, and its trainer an ID and a secret ID of 16
// bits each. XOR the two halves of the personality value with the two IDs and it is shiny when the result is
// under 16, and a square shiny when it is 0: 1 in 65536. The trainer's two IDs are the same for every Pokémon
// of theirs and only shift that XOR, so they don't change the odds, and are left as 0
const isSuperRare = () => {
	const personality = Math.floor( Math.random() * 2 ** 32 )
	return ( ( personality >>> 16 ) ^ ( personality & 0xFFFF ) ) === 0
}
const HUES = 36
// what is never text to colour: what isn't on the page to be read, and what is typed into or chosen from
const NOT_TEXT = "script, style, noscript, template, textarea, select, option, #shiny"

// a grey, the colour of a text that has none of its own: its three channels no further apart than this
const isGrey = ( colour ) => {
	const channels = colour.match( /^rgba?\( *([\d.]+)[ ,]+([\d.]+)[ ,]+([\d.]+)/ )?.slice( 1 ).map( Number )
	return !!channels && Math.max( ...channels ) - Math.min( ...channels ) <= 8
}

export default class extends Controller {
	static values = {
		sparkles: String,
		fallback: String,
		flashStart: { type: Number, default: 3 },
		flashFrames: { type: Number, default: 5 },
		lightness: { type: Number, default: 0.65 },
		chroma: { type: Number, default: 0.2 },
		fade: { type: Number, default: 150 }
	}

	connect() {
		this.phase = "before"
		const asked = new URLSearchParams( window.location.search ).get( "shiny" )
		this.kind = document.documentElement.hasAttribute( "data-turbo-preview" ) ? null
			: asked !== null ? ( asked === "square" ? "square" : "star" )
			: isSuperRare() ? "square" : isRare() ? "star" : null
		this.chosen = this.kind !== null
		if ( !this.chosen ) return
		this.boundCache = this.uncolorFields.bind( this )
		document.addEventListener( "turbo:before-cache", this.boundCache )
		const reduced = window.matchMedia( "(prefers-reduced-motion: reduce)" ).matches
		this.colorText( !reduced )
		if ( !reduced ) this.playSparkles()
	}

	disconnect() {
		if ( !this.chosen ) return
		document.removeEventListener( "turbo:before-cache", this.boundCache )
		cancelAnimationFrame( this.request )
		cancelAnimationFrame( this.fadeRequest )
		if ( this.phase === "turned" ) this.turnBack()
		document.documentElement.classList.remove( "shiny_turn" )
		document.documentElement.style.removeProperty( "--shiny_mix" )
		this.overlay?.remove()
		document.getElementById( "wordmark" )?.style.removeProperty( "anchor-name" )
		for ( const name of this.names ?? [] ) CSS.highlights.delete( name )
		if ( this.sheet ) document.adoptedStyleSheets = document.adoptedStyleSheets.filter( ( sheet ) => sheet !== this.sheet )
		this.uncolorFields()
	}

	// The characters of the wordmark, or of all the page, each in the highlight of a hue, the hue anything but
	// always between 40 and 320 degrees away from the one of the character before. A highlight is a hue over
	// a colour the text had, since its colour is the text's mixed with its own, less of the text's as the fade
	// goes: the fade begins on the text's own colour, so that there is a colour to fade from, and a highlight
	// can't be told what that colour is, only be given it
	colorText( fade ) {
		this.names = []
		if ( !CSS.highlights ) return
		const hueColour = ( hue ) => `oklch( ${ this.lightnessValue } ${ this.chromaValue } ${ hue * 360 / HUES } )`
		const rules = []
		const highlights = new Map()
		const highlightFor = ( hue, from ) => {
			const key = `${ hue } ${ from }`
			if ( !highlights.has( key ) ) {
				const name = `shiny_${ this.names.length }`
				this.names.push( name )
				highlights.set( key, new Highlight() )
				CSS.highlights.set( name, highlights.get( key ) )
				rules.push( `::highlight( ${ name } ){ color: color-mix( in oklch, ${ from } calc( ( 1 - var( --shiny_mix, 1 ) ) * 100% ), ${ hueColour( hue ) } ); }` )
			}
			return highlights.get( key )
		}
		for ( let hue = 0; hue < HUES; hue++ ) {
			const mixed = `color-mix( in oklch, var( --shiny_from ) calc( ( 1 - var( --shiny_mix, 1 ) ) * 100% ), ${ hueColour( hue ) } )`
			rules.push( `[data-shiny-hue="${ hue }"]::placeholder{ color: ${ mixed }; }` )
			rules.push( `:is( input[type=submit], input[type=button], input[type=reset] )[data-shiny-hue="${ hue }"]{ color: ${ mixed } !important; }` )
		}
		if ( fade ) document.documentElement.style.setProperty( "--shiny_mix", "0" )
		const root = this.kind === "square" ? document.body : document.getElementById( "wordmark" )
		if ( root ) {
			let previous = null
			const from = new Map()
			const walker = document.createTreeWalker( root, NodeFilter.SHOW_TEXT )
			while ( walker.nextNode() ) {
				const text = walker.currentNode
				const element = text.parentElement
				if ( !element || element.closest( NOT_TEXT ) ) continue
				if ( !from.has( element ) ) {
					const colour = getComputedStyle( element ).color
					from.set( element, isGrey( colour ) ? colour : null )
				}
				if ( !from.get( element ) ) continue
				let offset = 0
				for ( const character of text.data ) {
					const end = offset + character.length
					if ( character.trim() ) {
						previous = previous === null ? Math.floor( Math.random() * HUES ) : ( previous + 4 + Math.floor( Math.random() * 29 ) ) % HUES
						highlightFor( previous, from.get( element ) ).add( new StaticRange( { startContainer: text, startOffset: offset, endContainer: text, endOffset: end } ) )
					}
					offset = end
				}
			}
		}
		this.sheet = new CSSStyleSheet()
		this.sheet.replaceSync( rules.join( "\n" ) )
		document.adoptedStyleSheets = [ ...document.adoptedStyleSheets, this.sheet ]
		if ( this.kind === "square" ) this.colorFields()
		if ( fade ) this.fadeIn()
	}

	// What a field says while it is empty, and what a button of a form says, is the page's text too, though
	// of one colour for all of it and not one for each character: a control has no range of its text to
	// colour. What is typed into a field comes after the page. The fade of each starts from what it was
	colorFields() {
		for ( const field of document.querySelectorAll( "input[placeholder], textarea[placeholder], input[type=submit], input[type=button], input[type=reset]" ) ) {
			const colour = getComputedStyle( field, field.matches( "[type=submit], [type=button], [type=reset]" ) ? null : "::placeholder" ).color
			if ( !isGrey( colour ) ) continue
			field.style.setProperty( "--shiny_from", colour )
			field.dataset.shinyHue = Math.floor( Math.random() * HUES )
		}
	}

	uncolorFields() {
		for ( const field of document.querySelectorAll( "[data-shiny-hue]" ) ) {
			delete field.dataset.shinyHue
			field.style.removeProperty( "--shiny_from" )
		}
	}

	// The mix from the text's own colour, at nothing, to the highlight's, at all of it, in a straight line over
	// the length of the fade, a frame at a time
	fadeIn() {
		let origin
		const step = ( time ) => {
			origin ??= time
			const mix = Math.min( 1, ( time - origin ) / this.fadeValue )
			if ( mix < 1 ) {
				document.documentElement.style.setProperty( "--shiny_mix", mix )
				this.fadeRequest = requestAnimationFrame( step )
			} else {
				document.documentElement.style.removeProperty( "--shiny_mix" )
			}
		}
		this.fadeRequest = requestAnimationFrame( step )
	}

	// Where the wordmark is inked: each of its lines' text, less the letter-spacing that trails the last
	// character, which the box of the line counts and the eye does not. Given as the size of that extent and
	// as how far its centre lies from the centre of the wordmark's own box, which is what the sparkles are
	// anchored to
	inkedExtent( wordmark ) {
		const box = wordmark.getBoundingClientRect()
		let left = Infinity, top = Infinity, right = -Infinity, bottom = -Infinity
		for ( const line of wordmark.children ) {
			const range = document.createRange()
			range.selectNodeContents( line )
			const text = range.getBoundingClientRect()
			left = Math.min( left, text.left )
			top = Math.min( top, text.top )
			right = Math.max( right, text.right - ( parseFloat( getComputedStyle( line ).letterSpacing ) || 0 ) )
			bottom = Math.max( bottom, text.bottom )
		}
		return {
			width: right - left,
			height: bottom - top,
			dx: ( left + right ) / 2 - ( box.left + box.width / 2 ),
			dy: ( top + bottom ) / 2 - ( box.top + box.height / 2 )
		}
	}

	// The sparkles are decoded before they are shown, so that their first frame is the first thing seen and
	// the turn of the page can be timed from it. Drawn at a whole multiple of their own size, and nearest
	// neighbour, so that each of their pixels stays one square: the whole multiple that comes closest to the
	// wordmark's larger side, as the sparkles cover the sprite they are played over on the console. Anchored
	// to the wordmark by CSS, so that they stay on it when the page scrolls under the sticky nav
	async playSparkles() {
		const wordmark = document.getElementById( "wordmark" )
		if ( !wordmark ) return
		const image = new Image()
		image.className = "shiny_sparkles"
		image.alt = ""
		image.setAttribute( "aria-hidden", "true" )
		image.addEventListener( "error", () => { if ( image.src !== new URL( this.fallbackValue, document.baseURI ).href ) image.src = this.fallbackValue }, { once: true } )
		image.src = this.sparklesValue
		try {
			await image.decode()
		} catch {
			return
		}
		if ( !this.element.isConnected ) return
		const { width, height, dx, dy } = this.inkedExtent( wordmark )
		image.width = image.height = FRAME_SIZE * Math.max( 1, Math.round( Math.max( width, height ) / FRAME_SIZE ) )
		image.style.setProperty( "--shiny_dx", `${ dx }px` )
		image.style.setProperty( "--shiny_dy", `${ dy }px` )
		wordmark.style.setProperty( "anchor-name", "--shiny_wordmark" )
		this.overlay = image
		document.body.append( image )
		// the first frame the sparkles are drawn in is the first of the 48, and the one the turn is timed from
		this.request = requestAnimationFrame( ( origin ) => this.follow( origin, origin ) )
	}

	// One display frame after another until the turn is over. Each is handed the time it will be shown at, and
	// the turn takes the frame nearest each instant it is due at, on whichever side of it, hence the half frame
	// added: it begins on the frame nearest the 4th of the console, and ends on the one nearest 5 of the
	// console's frames after that, so it lasts the number of display frames nearest to those 5 and never
	// fewer than one
	follow( origin, previous ) {
		this.request = requestAnimationFrame( ( time ) => {
			const half = ( time - previous ) / 2
			if ( this.phase === "before" && time - origin + half >= this.flashStartValue * GAME_BOY_FRAME_MS ) this.turn( time )
			else if ( this.phase === "turned" && time - this.turnedAt + half >= this.flashFramesValue * GAME_BOY_FRAME_MS ) this.turnBack()
			else if ( this.phase === "after" ) return document.documentElement.classList.remove( "shiny_turn" )
			this.follow( origin, time )
		} )
	}

	// To the other appearance, with the page's own easing off, since it takes a quarter of a second to ease
	// from one appearance to the other, longer than the turn lasts, and an instant is what it is; then back
	// to just what it was, in an instant too, and the easing on again a frame after
	turn( time ) {
		const root = document.documentElement
		this.before = { theme: root.dataset.theme, scheme: root.style.colorScheme }
		const current = this.before.theme || ( window.matchMedia( "(prefers-color-scheme: dark)" ).matches ? "dark" : "light" )
		const other = current === "dark" ? "light" : "dark"
		root.classList.add( "shiny_turn" )
		root.dataset.theme = other
		root.style.colorScheme = other
		this.turnedAt = time
		this.phase = "turned"
	}

	turnBack() {
		const root = document.documentElement
		if ( this.before.theme === undefined ) delete root.dataset.theme
		else root.dataset.theme = this.before.theme
		root.style.colorScheme = this.before.scheme
		this.phase = "after"
	}
}

//	shiny_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
