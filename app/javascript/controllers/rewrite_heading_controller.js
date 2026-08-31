import { Controller } from "@hotwired/stimulus"

// Plays once, right after a message is sent, in three distinct beats: erase "Wanna reach out to
// me?" a character at a time in place (staying put on the left, no sliding yet), then throw the
// now-empty cursor over to the right edge in one quick snap, then type the reply in gray, growing
// back out from that same right edge. Left alone (sent is false) it is just the plain heading
// with a cursor blinking at the end.
const ORIGINAL = "Wanna reach out to me?"
const REPLACEMENT = "I may or may not get back to you."
const STEP_MS = 40
const THROW_MS = 200

export default class extends Controller {
  static targets = [ "line", "text" ]
  static values = { sent: Boolean }

  connect() {
    if ( this.sentValue ) this.erase( ORIGINAL.length )
  }

  disconnect() {
    clearTimeout( this.timeout )
  }

  erase( remaining ) {
    this.textTarget.textContent = ORIGINAL.slice( 0, remaining )

    if ( remaining === 0 ) {
      this.align()
      this.timeout = setTimeout( () => {
        this.lineTarget.classList.add( "heading_replacement" )
        this.type( 0 )
      }, THROW_MS )
      return
    }

    this.timeout = setTimeout( () => this.erase( remaining - 1 ), STEP_MS )
  }

  type( length ) {
    this.textTarget.textContent = REPLACEMENT.slice( 0, length )
    this.align()

    if ( length === REPLACEMENT.length ) return

    this.timeout = setTimeout( () => this.type( length + 1 ), STEP_MS )
  }

  align() {
    const containerWidth = this.element.clientWidth
    const lineWidth = this.lineTarget.getBoundingClientRect().width
    this.lineTarget.style.marginLeft = `${ containerWidth - lineWidth }px`
  }
}

//	rewrite_heading_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
