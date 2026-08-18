import { Controller } from "@hotwired/stimulus"

// Keeps the medallion centered on the sidebar column it lives in — except once that sidebar has
// wrapped below the timeline instead of sitting beside it, at which point the two no longer form
// two columns but one, and the nav's own fixed width would otherwise leave the medallion looking
// off-center against the screen as a whole. When wrapped, this centers on the actual window
// instead of the body's content column. The two states are told apart by comparing the sidebar's
// bottom edge to the timeline's top edge: side by side, they line up near the same height; wrapped,
// the timeline starts only after the sidebar ends.
export default class extends Controller {
  connect() {
    this.boundUpdate = this.update.bind( this )
    window.addEventListener( "resize", this.boundUpdate )
    this.update()
  }

  disconnect() {
    window.removeEventListener( "resize", this.boundUpdate )
  }

  update() {
    const sidebar = this.element.closest( ".about_sidebar" )
    const timeline = document.querySelector( ".resume_timeline" )

    const wrapped = !timeline || timeline.getBoundingClientRect().top >= sidebar.getBoundingClientRect().bottom - 1

    if ( !wrapped ) {
      this.element.style.transform = ""
      return
    }

    const rect = this.element.getBoundingClientRect()
    const currentCenter = rect.left + rect.width / 2
    const targetCenter = window.innerWidth / 2
    this.element.style.transform = `translateX( ${ targetCenter - currentCenter }px )`
  }
}

//	viewport_center_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
