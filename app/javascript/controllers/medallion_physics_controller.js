import { Controller } from "@hotwired/stimulus"

// Lets the whole name-disc — photo and both orbiting text rings together, since the rings are
// physically "attached" to the medallion and have to shake with it rather than hang still while
// it moves — be grabbed and nudged up to a few percent off its resting position, and makes it lag
// behind the page with spring physics, but only once the page's scroll itself accelerates abruptly
// — a sudden start or stop — never during ordinary smooth scrolling, which carries the disc along
// with zero lag. On top of that shared 2D drift, the photo alone leans in 3D like a PS Vita
// LiveArea bubble, tilting toward whatever direction it's currently offset in; the orbiting ring
// text stays flat, since only the disc's shared translation carries it along, not the medallion's
// own tilt. Stiffness is kept low and damping high so the response eases in and out rather than
// snapping — acceleration and deceleration that scale with how far off rest the disc currently is,
// the way an actual spring behaves, rather than a sharp, constant-speed jerk toward the target.
export default class extends Controller {
  static targets = [ "medallion" ]

  static values = {
    maxDragFraction: { type: Number, default: 0.03 },
    stiffness: { type: Number, default: 0.055 },
    damping: { type: Number, default: 0.88 },
    scrollKick: { type: Number, default: 0.5 },
    scrollAccelerationThreshold: { type: Number, default: 2.5 },
    tiltSensitivity: { type: Number, default: 1.8 },
    tiltPerspective: { type: Number, default: 500 }
  }

  connect() {
    this.offsetX = 0
    this.offsetY = 0
    this.velocityX = 0
    this.velocityY = 0
    this.targetX = 0
    this.targetY = 0
    this.dragging = false
    this.lastScrollY = window.scrollY
    this.lastScrollVelocity = 0
    this.frame = null

    this.boundPointerDown = this.onPointerDown.bind( this )
    this.boundPointerMove = this.onPointerMove.bind( this )
    this.boundPointerUp = this.onPointerUp.bind( this )
    this.boundScroll = this.onScroll.bind( this )
    this.boundTick = this.tick.bind( this )

    this.element.style.touchAction = "none"
    this.element.style.cursor = "grab"
    this.element.addEventListener( "pointerdown", this.boundPointerDown )
    window.addEventListener( "scroll", this.boundScroll, { passive: true } )
  }

  disconnect() {
    this.element.removeEventListener( "pointerdown", this.boundPointerDown )
    window.removeEventListener( "pointermove", this.boundPointerMove )
    window.removeEventListener( "pointerup", this.boundPointerUp )
    window.removeEventListener( "scroll", this.boundScroll )
    this.stopTicking()
  }

  onPointerDown( event ) {
    this.dragging = true
    this.element.style.cursor = "grabbing"
    this.dragStartX = event.clientX
    this.dragStartY = event.clientY
    window.addEventListener( "pointermove", this.boundPointerMove )
    window.addEventListener( "pointerup", this.boundPointerUp )
    this.startTicking()
  }

  onPointerMove( event ) {
    if ( !this.dragging ) return
    const rect = this.element.getBoundingClientRect()
    const maxX = rect.width * this.maxDragFractionValue
    const maxY = rect.height * this.maxDragFractionValue
    const dx = event.clientX - this.dragStartX
    const dy = event.clientY - this.dragStartY
    this.targetX = Math.min( Math.max( dx, -maxX ), maxX )
    this.targetY = Math.min( Math.max( dy, -maxY ), maxY )
  }

  onPointerUp() {
    this.dragging = false
    this.element.style.cursor = "grab"
    // letting go doesn't ease the target to 0 — it snaps, so the spring below actually overshoots
    // and shakes on the way back rather than gliding to a stop
    this.targetX = 0
    this.targetY = 0
    window.removeEventListener( "pointermove", this.boundPointerMove )
    window.removeEventListener( "pointerup", this.boundPointerUp )
  }

  // scroll is its own event, not something polled from inside tick(), so the spring can sit
  // completely idle between kicks rather than reading window.scrollY every single frame forever
  onScroll() {
    const scrollY = window.scrollY
    const scrollVelocity = scrollY - this.lastScrollY
    this.lastScrollY = scrollY
    const scrollAcceleration = scrollVelocity - this.lastScrollVelocity
    this.lastScrollVelocity = scrollVelocity

    // only a jump in scroll speed — a sudden start or stop — kicks the spring; steady scrolling at
    // any speed has near-zero frame-to-frame acceleration and leaves the disc at perfect rest
    if ( Math.abs( scrollAcceleration ) > this.scrollAccelerationThresholdValue ) {
      const excess = scrollAcceleration - Math.sign( scrollAcceleration ) * this.scrollAccelerationThresholdValue
      this.velocityY -= excess * this.scrollKickValue
      this.startTicking()
    }
  }

  startTicking() {
    if ( this.frame ) return
    this.frame = requestAnimationFrame( this.boundTick )
  }

  stopTicking() {
    if ( this.frame ) cancelAnimationFrame( this.frame )
    this.frame = null
  }

  tick() {
    const forceX = ( this.targetX - this.offsetX ) * this.stiffnessValue
    const forceY = ( this.targetY - this.offsetY ) * this.stiffnessValue
    this.velocityX = ( this.velocityX + forceX ) * this.dampingValue
    this.velocityY = ( this.velocityY + forceY ) * this.dampingValue
    this.offsetX += this.velocityX
    this.offsetY += this.velocityY

    // the standalone translate property, not transform's own translate() — composes with whatever
    // static transform the element already carries (the Cover Flow side covers' own rotateY lean,
    // in particular) instead of overwriting it
    this.element.style.translate = `${ this.offsetX }px ${ this.offsetY }px`

    // the medallion alone leans in 3D off the same offset — a PS Vita LiveArea bubble tilt — while
    // the ring text above stays flat, carried only by the disc's shared 2D translation
    if ( this.hasMedallionTarget ) {
      const tiltX = -this.offsetY * this.tiltSensitivityValue
      const tiltY = this.offsetX * this.tiltSensitivityValue
      this.medallionTarget.style.transform = `translate( -50%, -50% ) perspective( ${ this.tiltPerspectiveValue }px ) rotateX( ${ tiltX }deg ) rotateY( ${ tiltY }deg )`
    }

    // once dragging has stopped and the spring has settled back to rest, within a fraction of a
    // pixel, stop rescheduling rather than keep writing the exact same translate every frame
    // forever — that constant per-frame style write, times four covers on one Cover Flow stage
    // scrolling past at once, is what was tripping a Chromium compositor bug that duplicated the
    // whole stage's paint for a few frames. onPointerDown/onScroll above wake it back up on demand
    const atRest = !this.dragging
      && Math.abs( this.velocityX ) < 0.01 && Math.abs( this.velocityY ) < 0.01
      && Math.abs( this.targetX - this.offsetX ) < 0.01 && Math.abs( this.targetY - this.offsetY ) < 0.01

    if ( atRest ) {
      this.stopTicking()
    } else {
      this.frame = requestAnimationFrame( this.boundTick )
    }
  }
}

//	medallion_physics_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
