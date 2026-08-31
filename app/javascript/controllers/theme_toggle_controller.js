import { Controller } from "@hotwired/stimulus"

// A manual light/dark switch. Flipping it stores the choice, and from then on it overrides
// the sunset controller's automatic schedule permanently, the same way flipping a real light
// switch overrides whatever a timer was doing.
export default class extends Controller {
  connect() {
    const stored = localStorage.getItem( "theme_override" )
    const theme = stored || document.documentElement.dataset.theme || ( matchMedia( "(prefers-color-scheme: dark)" ).matches ? "dark" : "light" )
    document.documentElement.dataset.theme = theme
    document.documentElement.style.colorScheme = theme
    this.element.setAttribute( "aria-checked", theme === "dark" )
  }

  toggle() {
    const theme = document.documentElement.dataset.theme === "dark" ? "light" : "dark"
    document.documentElement.dataset.theme = theme
    document.documentElement.style.colorScheme = theme
    localStorage.setItem( "theme_override", theme )
    this.element.setAttribute( "aria-checked", theme === "dark" )
  }
}

//	theme_toggle_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
