//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its
//	documentation for any purpose and without fee is hereby granted, provided that
//	the above copyright notice appear in all copies and that both that copyright
//	notice and this permission notice appear in supporting documentation, and that
//	the name of Karl Vincent Pierre Bertin not be used in advertising or publicity
//	pertaining to distribution of the software without specific, written prior
//	permission. Karl Vincent Pierre Bertin makes no representations about the
//	suitability of this software for any purpose.  It is provided "as is" without
//	express or implied warranty.

import { Controller } from "@hotwired/stimulus"

// Saves the form in the background a couple of seconds after the user stops typing.
// The first save on a brand new record creates it and switches this controller over
// to updating that record from then on. No interval runs while the user is idle.
//
// Clicking a nav link while there is something unsaved flushes the save immediately
// instead of waiting out the debounce, so leaving through the menu never drops the
// last few seconds of typing.
export default class extends Controller {
  static targets = [ "status" ]
  static values = { url: String, method: String, delay: { type: Number, default: 2000 } }

  connect() {
    this.dirty = false
    this.boundInterceptNavClick = this.interceptNavClick.bind( this )
    document.querySelector( "nav" )?.addEventListener( "click", this.boundInterceptNavClick, true )
  }

  disconnect() {
    clearTimeout( this.timeout )
    document.querySelector( "nav" )?.removeEventListener( "click", this.boundInterceptNavClick, true )
  }

  scheduleSave() {
    this.dirty = true
    clearTimeout( this.timeout )
    this.timeout = setTimeout( () => this.save(), this.delayValue )
  }

  interceptNavClick( event ) {
    const link = event.target.closest( "a[href]" )
    if ( !link || link.target === "_blank" || !this.dirty ) return

    event.preventDefault()
    clearTimeout( this.timeout )
    this.save().then( () => window.Turbo.visit( link.href ) )
  }

  async save() {
    const body = new FormData( this.element )
    const method = this.methodValue

    let response
    try {
      response = await fetch( this.urlValue, {
        method: method === "post" ? "POST" : "PATCH",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector( 'meta[name="csrf-token"]' )?.content
        },
        body
      } )
    } catch {
      this.setStatus( "Not saved (offline?)" )
      return
    }

    if ( !response.ok ) {
      this.setStatus( "Not saved" )
      return
    }

    const data = await response.json()
    this.dirty = false

    if ( method === "post" ) {
      this.urlValue = data.update_url
      this.methodValue = "patch"
      history.replaceState( history.state, "", data.edit_url )
    }

    this.setStatus( `Draft saved ${new Date( data.saved_at ).toLocaleTimeString()}` )
  }

  setStatus( text ) {
    if ( this.hasStatusTarget ) this.statusTarget.textContent = text
  }
}

//	autosave_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
