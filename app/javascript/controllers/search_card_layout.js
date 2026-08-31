// Where the search results go. The cards are read the way a page is: left to right and top to bottom, each one
// taking the first free place that sweep comes to around the search bar, which can be above the bar but is never
// under it. They stack in columns, so that every card is the same gap from the one beside it, the one above or
// below it and, for the nearest, from the bar. The physics of a card itself (grabbed, nudged a few percent off its
// place, sprung back and shaken) is medallion_physics_controller.js's own, put on each card from the markup, the
// same as on the medallion and the Cover Flow covers; this only sets the places and keeps a drag from being read
// as a click.
const GAP = 16
const MINIMUM_WIDTH = 220
const MAXIMUM_WIDTH = 340
const ANIMATION = 250 // ms, how long fadeinandbouncefromleft runs on a card in style.css
const STAGGER = 30 // ms between one card's animation and the next's
const CLICK_SLOP = 6 // px a pointer may travel before a press counts as a drag rather than a click

export default class SearchCardLayout {
  constructor( { container, bar } ) {
    this.container = container
    this.bar = bar
    this.cards = new Map()
    this.exiting = new Set()
    this.order = []
    this.pending = []
    this.exitsEndAt = 0
    this.pressed = null
    this.travelled = 0
    this.suppressClick = false

    this.boundPointerDown = this.onPointerDown.bind( this )
    this.boundPointerMove = this.onPointerMove.bind( this )
    this.boundPointerUp = this.onPointerUp.bind( this )
    this.boundClick = this.onClick.bind( this )
    this.boundResize = this.onResize.bind( this )
    this.boundWheel = ( event ) => event.preventDefault()

    this.container.addEventListener( "pointerdown", this.boundPointerDown )
    // captured, so a click that ends a drag never reaches the page's own click-outside handler and closes the bar
    this.container.addEventListener( "click", this.boundClick, true )
    this.container.addEventListener( "wheel", this.boundWheel, { passive: false } )
    window.addEventListener( "resize", this.boundResize )
  }

  destroy() {
    clearTimeout( this.enterTimer )
    clearTimeout( this.resizeTimer )
    this.container.removeEventListener( "pointerdown", this.boundPointerDown )
    this.container.removeEventListener( "click", this.boundClick, true )
    this.container.removeEventListener( "wheel", this.boundWheel )
    window.removeEventListener( "resize", this.boundResize )
    window.removeEventListener( "pointermove", this.boundPointerMove )
    window.removeEventListener( "pointerup", this.boundPointerUp )
    this.cards.clear()
    this.exiting.clear()
    this.container.innerHTML = ""
  }

  // every card leaves the way it came
  clear() {
    this.show( [] )
  }

  // takes the server's markup for a set of results
  update( html ) {
    const template = document.createElement( "template" )
    template.innerHTML = html
    this.show( [ ...template.content.children ] )
  }

  // What is no longer found leaves first, each card playing its entrance backwards, the last to have come the
  // first to go. Only then do the cards that stay move to their new places and the new ones appear in theirs,
  // so a change of results reads as one thing going and the next coming, at the speed of everything else on the
  // site. A change typed before that has finished simply replaces the one waiting.
  show( elements ) {
    const entries = elements.map( ( element ) => ( { key: this.keyFor( element ), element } ) )
    const found = new Set( entries.map( ( entry ) => entry.key ) )
    const leaving = [ ...this.cards ].filter( ( [ key ] ) => !found.has( key ) ).reverse()

    leaving.forEach( ( [ key, card ], index ) => {
      this.cards.delete( key )
      this.exiting.add( card.element )
      card.element.style.setProperty( "--search_card_delay", `${ index * STAGGER }ms` )
      card.element.classList.add( "search_card_leaving" )
    } )
    if ( leaving.length ) this.exitsEndAt = Math.max( this.exitsEndAt, performance.now() + ANIMATION + ( leaving.length - 1 ) * STAGGER )

    this.pending = entries
    clearTimeout( this.enterTimer )
    this.enterTimer = setTimeout( () => this.enter(), Math.max( 0, this.exitsEndAt - performance.now() ) )
  }

  enter() {
    this.exiting.forEach( ( element ) => element.remove() )
    this.exiting.clear()

    let fresh = 0
    this.order = []
    this.pending.forEach( ( { key, element } ) => {
      this.order.push( key )
      if ( this.cards.has( key ) ) return

      element.style.setProperty( "--search_card_delay", `${ fresh * STAGGER }ms` )
      fresh += 1
      this.container.append( element )
      this.cards.set( key, { element, width: 0, height: 0 } )
    } )

    this.layout()
  }

  // the link alone won't do as an identity: every skill and milestone leads to the same about me page
  keyFor( element ) {
    return `${ element.getAttribute( "href" ) }|${ element.textContent.replace( /\s+/g, " " ).trim() }`
  }

  // as many columns as fit with a card at least MINIMUM_WIDTH wide. The space above the bar is filled first, then
  // the space below it; within a side each card goes on the emptiest column, the leftmost when they tie. What is
  // above the bar is set against it, and what is below hangs from it, so the gap to the bar is GAP on both sides
  layout() {
    const width = this.container.clientWidth
    const height = this.container.clientHeight
    const bar = this.bar.getBoundingClientRect()

    const columns = Math.max( 1, Math.floor( ( width - GAP ) / ( MINIMUM_WIDTH + GAP ) ) )
    const cardWidth = Math.min( MAXIMUM_WIDTH, ( width - GAP * ( columns + 1 ) ) / columns )
    const cards = this.order.map( ( key ) => this.cards.get( key ) ).filter( Boolean )

    // nothing found is the one thing that is not a card: a line of text, under the bar and against the left edge
    const notice = cards.find( ( card ) => card.element.classList.contains( "search_no_results" ) )
    if ( notice ) {
      this.fit( notice.element, width, bar )
      return
    }

    cards.forEach( ( card ) => {
      card.element.style.display = ""
      card.element.style.width = `${ cardWidth }px`
      card.width = cardWidth
      card.height = card.element.offsetHeight
    } )

    const sides = [
      { name: "above", space: bar.top - GAP - GAP, columns: Array.from( { length: columns }, () => [] ) },
      { name: "below", space: height - GAP - ( bar.bottom + GAP ), columns: Array.from( { length: columns }, () => [] ) }
    ]
    const stackHeight = ( stack ) => stack.reduce( ( sum, card ) => sum + card.height + GAP, -GAP )

    cards.forEach( ( card ) => {
      for ( const side of sides ) {
        let best = null
        side.columns.forEach( ( stack ) => {
          const used = stack.length ? stackHeight( stack ) + GAP : 0
          if ( used + card.height > side.space ) return
          if ( !best || used < best.used ) best = { stack, used }
        } )
        if ( best ) {
          best.stack.push( card )
          return
        }
      }

      // no room left on either side: the rest of the results stay unshown rather than pile onto the bar
      card.element.style.display = "none"
    } )

    sides.forEach( ( side ) => {
      const occupied = side.columns.filter( ( stack ) => stack.length ).length
      const left = ( width - ( occupied * cardWidth + GAP * ( occupied - 1 ) ) ) / 2

      side.columns.filter( ( stack ) => stack.length ).forEach( ( stack, index ) => {
        const x = left + index * ( cardWidth + GAP )
        let offset = side.name === "above" ? bar.top - GAP - stackHeight( stack ) : bar.bottom + GAP

        stack.forEach( ( card ) => {
          card.element.style.left = `${ x.toFixed( 2 ) }px`
          card.element.style.top = `${ offset.toFixed( 2 ) }px`

          // slid between places only from the second time it is placed, so a new card appears where it belongs, and
          // placed with left and top, not transform, so as to leave transform to the entrance and translate to the physics
          if ( !card.placed ) {
            card.placed = true
            requestAnimationFrame( () => requestAnimationFrame( () => card.element.classList.add( "search_card_placed" ) ) )
          }
          offset += card.height + GAP
        } )
      } )
    } )
  }

  // sizes the line so that it runs from GAP off the left edge to GAP off the right one, the same space that is left
  // round the cards, by measuring it at a known size and scaling from that
  fit( element, width, bar ) {
    element.style.fontSize = "100px"
    element.style.left = `${ GAP }px`
    element.style.top = `${ bar.bottom + GAP }px`
    element.style.fontSize = `${ 100 * ( width - 2 * GAP ) / element.getBoundingClientRect().width }px`
  }

  onPointerDown( event ) {
    if ( event.button !== 0 || !event.target.closest( ".search_result_card" ) ) return
    this.pressed = { x: event.clientX, y: event.clientY }
    this.travelled = 0
    this.suppressClick = false
    window.addEventListener( "pointermove", this.boundPointerMove )
    window.addEventListener( "pointerup", this.boundPointerUp )
  }

  onPointerMove( event ) {
    if ( !this.pressed ) return
    this.travelled = Math.max( this.travelled, Math.hypot( event.clientX - this.pressed.x, event.clientY - this.pressed.y ) )
    if ( this.travelled > CLICK_SLOP ) this.suppressClick = true
  }

  onPointerUp() {
    this.pressed = null
    window.removeEventListener( "pointermove", this.boundPointerMove )
    window.removeEventListener( "pointerup", this.boundPointerUp )
  }

  onClick( event ) {
    if ( !this.suppressClick ) return
    event.preventDefault()
    event.stopPropagation()
    this.suppressClick = false
  }

  onResize() {
    clearTimeout( this.resizeTimer )
    this.resizeTimer = setTimeout( () => this.layout(), 100 )
  }
}

//	search_card_layout.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
