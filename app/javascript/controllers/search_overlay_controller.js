import { Controller } from "@hotwired/stimulus"
import SearchCardLayout from "controllers/search_card_layout"

// Trades the "find" nav link for a bar that reveals outward from that link's own position to
// both screen edges, its background sweeping from the page's theme colors to black-on-white
// text, and a real text input takes focus so the caret blinks as it would in any ordinary
// field. The navigation bar always stays layered above it, never covered. Escape, or a click
// outside the bar, closes it again. A frosted veil covers the whole page, the navigation included, the moment
// the bar appears, leaving the bar alone in front. What is typed is looked up as it goes, and the results come
// back as cards drawn on that veil, never as a page of their own, set around the bar by search_card_layout.js.
// Closing plays all of that backwards: the cards leave first, each running its entrance in reverse, and only then
// does the veil fade and the bar draw back to the link it came out of.
export default class extends Controller {
  static targets = [ "overlay", "input" ]

  connect() {
    this.boundCloseOnEscape = this.closeOnEscape.bind( this )
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind( this )
    this.boundSearchSoon = this.searchSoon.bind( this )
    this.boundSubmit = this.submit.bind( this )

    // the veil and its cards are built here rather than written into the navigation's own markup
    this.results = document.createElement( "div" )
    this.results.id = "search_results"
    this.results.setAttribute( "role", "region" )
    this.results.setAttribute( "aria-label", "Search results" )
    this.results.setAttribute( "aria-live", "polite" )
    this.element.append( this.results )
    this.cards = new SearchCardLayout( { container: this.results, bar: this.overlayTarget } )

    this.inputTarget.addEventListener( "input", this.boundSearchSoon )
    this.inputTarget.form.addEventListener( "submit", this.boundSubmit )
  }

  disconnect() {
    document.removeEventListener( "keydown", this.boundCloseOnEscape )
    document.removeEventListener( "click", this.boundCloseOnClickOutside )
    this.inputTarget.removeEventListener( "input", this.boundSearchSoon )
    this.inputTarget.form.removeEventListener( "submit", this.boundSubmit )
    clearTimeout( this.timer )
    clearTimeout( this.closeTimer )
    this.request?.abort()
    this.cards.destroy()
    this.results.remove()
  }

  open( event ) {
    if ( this.closing ) return

    const rect = event.currentTarget.getBoundingClientRect()
    this.overlayTarget.style.setProperty( "--search_origin_x", `${ rect.left }px` )
    this.overlayTarget.style.setProperty( "--search_origin_y", `${ rect.top }px` )
    this.element.classList.add( "search_open" )
    this.inputTarget.focus()
    document.addEventListener( "keydown", this.boundCloseOnEscape )
    setTimeout( () => document.addEventListener( "click", this.boundCloseOnClickOutside ), 0 )
  }

  closeOnEscape( event ) {
    if ( event.key === "Escape" ) this.close()
  }

  closeOnClickOutside( event ) {
    if ( !this.overlayTarget.contains( event.target ) ) this.close()
  }

  searchSoon() {
    clearTimeout( this.timer )
    this.timer = setTimeout( () => this.search(), 120 )
  }

  submit( event ) {
    event.preventDefault()
    clearTimeout( this.timer )
    this.search()
  }

  async search() {
    const query = this.inputTarget.value.trim()
    this.request?.abort()

    if ( query.length < 2 ) {
      this.cards.clear()
      return
    }

    this.request = new AbortController()
    try {
      const response = await fetch( `${ this.inputTarget.form.action }?${ new URLSearchParams( { q: query } ) }`, {
        headers: { "X-Requested-With": "XMLHttpRequest" },
        signal: this.request.signal
      } )
      if ( !response.ok ) return
      this.cards.update( await response.text() )
    } catch ( error ) {
      if ( error.name !== "AbortError" ) throw error
    }
  }

  close() {
    if ( this.closing ) return

    this.closing = true
    clearTimeout( this.timer )
    this.request?.abort()
    document.removeEventListener( "keydown", this.boundCloseOnEscape )
    document.removeEventListener( "click", this.boundCloseOnClickOutside )

    this.cards.clear()
    this.closeTimer = setTimeout( () => {
      this.element.classList.remove( "search_open" )
      this.closing = false
    }, this.cards.leaving() )
  }
}

//	search_overlay_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
