import { Controller } from "@hotwired/stimulus"

// A tertiary cover's own max-height is a flat vh figure in style.css — nowhere near enough to
// guarantee it never renders taller than the side cover directly in front of it, since that side
// cover's own rendered height depends on its photo's own aspect ratio too, and CSS alone has no way
// to size one element relative to a sibling's actual, post-layout size. This measures the side
// cover's real height directly, once its own image has actually loaded, and pins the matching
// tertiary cover on the same edge to a fraction of it — smaller for real now, not just capped lower
// in the abstract
//
// And it keeps that tertiary cover in sight. The side cover sits at the stage's own edge and its lean
// throws its near edge out past it, further the bigger the window gets, while the tertiary cover behind
// it sits 1% in from that same edge: in a window wide enough the one lay wholly over the other and the
// tertiary cover was gone. So after sizing it, the side cover is drawn in from the edge, when it has to
// be, just as far as leaves the tertiary cover showing beyond it by a tenth of its own width, and never
// less than MIN_PEEK pixels. In a window where that much already shows, nothing moves
const MIN_PEEK = 24

export default class extends Controller {
  static targets = [ "side", "hint" ]
  static values = { fraction: { type: Number, default: 0.55 }, peek: { type: Number, default: 0.1 } }

  connect() {
    this.boundResize = this.resize.bind( this )
    window.addEventListener( "resize", this.boundResize )
    // a cover's own size is only known once its image has loaded, the tertiary one's as much as the side one's
    this.sideTargets.concat( this.hintTargets ).forEach( ( cover ) => {
      if ( cover.complete ) return
      cover.addEventListener( "load", this.boundResize, { once: true } )
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
      // the side cover back where the stylesheet puts it, so that it is measured from there and not from
      // wherever an earlier pass, in another window size, drew it in to
      side.style.left = ""
      side.style.right = ""
      hint.style.maxHeight = `${ side.getBoundingClientRect().height * this.fractionValue }px`
      if ( hint.complete ) this.keepHintShowing( side, hint )
    } )
  }

  // Where the two are actually drawn, read back from the page, since the lean and the shared perspective
  // move a cover's edges from where its own box says they are
  keepHintShowing( side, hint ) {
    const sideBox = side.getBoundingClientRect()
    const hintBox = hint.getBoundingClientRect()
    const peek = Math.max( hintBox.width * this.peekValue, MIN_PEEK )
    if ( side.classList.contains( "cover_flow_side_left" ) ) {
      const shortfall = ( hintBox.left + peek ) - sideBox.left
      if ( shortfall > 0 ) side.style.left = `${ shortfall }px`
    } else {
      const shortfall = sideBox.right - ( hintBox.right - peek )
      if ( shortfall > 0 ) side.style.right = `${ shortfall }px`
    }
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
