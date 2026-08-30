import { Controller } from "@hotwired/stimulus"

// Karl's Hall of Fame is set in Didot, a typeface most visitors won't have installed (it isn't
// bundled with Windows, Linux, or Android, and embedding a licensed copy isn't an option). Rather
// than fall back to a lesser substitute, the whole room stays closed when Didot can't be found.
export default class extends Controller {
  connect() {
    if ( document.fonts && !document.fonts.check( "16px Didot" ) ) {
      this.element.classList.add( "doors_closed" )
    }
  }
}

//	pantheon_door_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
