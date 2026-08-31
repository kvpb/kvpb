import { Controller } from "@hotwired/stimulus"

// A tertiary cover's own max-height is a flat vh figure in style.css — nowhere near enough to
// guarantee it never renders taller than the side cover directly in front of it, since that side
// cover's own rendered height depends on its photo's own aspect ratio too, and CSS alone has no way
// to size one element relative to a sibling's actual, post-layout size. This measures the side
// cover's real height directly, once its own image has actually loaded, and pins the matching
// tertiary cover on the same edge to a fraction of it — smaller for real now, not just capped lower
// in the abstract
export default class extends Controller {
  static targets = [ "side", "hint" ]
  static values = { fraction: { type: Number, default: 0.55 } }

  connect() {
    this.boundResize = this.resize.bind( this )
    window.addEventListener( "resize", this.boundResize )
    this.sideTargets.forEach( ( side ) => {
      if ( side.complete ) return
      side.addEventListener( "load", this.boundResize, { once: true } )
    } )
    this.resize()
  }

  disconnect() {
    window.removeEventListener( "resize", this.boundResize )
  }

  resize() {
    this.sideTargets.forEach( ( side, index ) => {
      const hint = this.hintTargets[ index ]
      if ( !hint || !side.complete ) return
      hint.style.maxHeight = `${ side.getBoundingClientRect().height * this.fractionValue }px`
    } )
  }
}

//	cover_flow_depth_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
