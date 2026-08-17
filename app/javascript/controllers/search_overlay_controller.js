import { Controller } from "@hotwired/stimulus"

// Trades the "find" nav link for a full-width bar: the background sweeps from the page's
// theme colors to black-on-white text, and a real text input takes focus so the caret blinks
// as it would in any ordinary field. Escape, or a click outside the bar, closes it again.
export default class extends Controller {
  static targets = [ "overlay", "input" ]

  connect() {
    this.boundCloseOnEscape = this.closeOnEscape.bind( this )
    this.boundCloseOnClickOutside = this.closeOnClickOutside.bind( this )
  }

  disconnect() {
    document.removeEventListener( "keydown", this.boundCloseOnEscape )
    document.removeEventListener( "click", this.boundCloseOnClickOutside )
  }

  open() {
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

  close() {
    this.element.classList.remove( "search_open" )
    document.removeEventListener( "keydown", this.boundCloseOnEscape )
    document.removeEventListener( "click", this.boundCloseOnClickOutside )
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
