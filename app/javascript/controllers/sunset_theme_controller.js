import { Controller } from "@hotwired/stimulus"

// Forces dark or light theme based on real sunrise/sunset at the visitor's location,
// overriding prefers-color-scheme (which stays as the fallback, handled purely in CSS,
// when geolocation is denied or unavailable). Re-checks periodically so a tab left open
// across sunset still switches without a reload.
export default class extends Controller {
  static values = { recheckDelay: { type: Number, default: 300000 } }

  connect() {
    if ( !navigator.geolocation ) return
    navigator.geolocation.getCurrentPosition(
      ( position ) => this.startWatching( position.coords.latitude, position.coords.longitude ),
      () => {},
      { maximumAge: 3600000, timeout: 10000 }
    )
  }

  disconnect() {
    clearInterval( this.interval )
  }

  startWatching( latitude, longitude ) {
    this.applyTheme( latitude, longitude )
    this.interval = setInterval( () => this.applyTheme( latitude, longitude ), this.recheckDelayValue )
  }

  applyTheme( latitude, longitude ) {
    const now = new Date()
    const { sunrise, sunset } = sunTimes( latitude, longitude, now )
    if ( Number.isNaN( sunrise ) || Number.isNaN( sunset ) ) return

    const nowMinutes = now.getUTCHours() * 60 + now.getUTCMinutes()
    const theme = ( nowMinutes < sunrise || nowMinutes >= sunset ) ? "dark" : "light"
    document.documentElement.dataset.theme = theme
    document.documentElement.style.colorScheme = theme
  }
}

// NOAA solar position formulas. Returns { sunrise, sunset } as minutes past UTC midnight
// for the given latitude/longitude (standard sign convention: north/east positive) and date.
function sunTimes( latitude, longitude, date ) {
  const RAD = Math.PI / 180
  const startOfYear = new Date( Date.UTC( date.getUTCFullYear(), 0, 1 ) )
  const dayOfYear = Math.floor( ( date - startOfYear ) / 86400000 ) + 1
  const fractionalYear = ( 2 * Math.PI / 365 ) * ( dayOfYear - 1 + ( date.getUTCHours() - 12 ) / 24 )

  const equationOfTime = 229.18 * (
    0.000075
    + 0.001868 * Math.cos( fractionalYear )
    - 0.032077 * Math.sin( fractionalYear )
    - 0.014615 * Math.cos( 2 * fractionalYear )
    - 0.040849 * Math.sin( 2 * fractionalYear )
  )

  const declination = 0.006918
    - 0.399912 * Math.cos( fractionalYear )
    + 0.070257 * Math.sin( fractionalYear )
    - 0.006758 * Math.cos( 2 * fractionalYear )
    + 0.000907 * Math.sin( 2 * fractionalYear )
    - 0.002697 * Math.cos( 3 * fractionalYear )
    + 0.00148 * Math.sin( 3 * fractionalYear )

  const zenith = 90.833 * RAD // 90° + atmospheric refraction + solar radius
  const latitudeRad = latitude * RAD
  const hourAngleDegrees = Math.acos(
    ( Math.cos( zenith ) / ( Math.cos( latitudeRad ) * Math.cos( declination ) ) )
    - Math.tan( latitudeRad ) * Math.tan( declination )
  ) / RAD // NaN past the polar circles when the sun doesn't rise/set that day

  const solarNoon = 720 - 4 * longitude - equationOfTime
  return {
    sunrise: solarNoon - 4 * hourAngleDegrees,
    sunset: solarNoon + 4 * hourAngleDegrees
  }
}

//	sunset_theme_controller.js
//	kvpb.fr
//
//	Karl V. P. B. `kvpb`	AKA Karl Thomas George West `ktgw`
//	+33 A BB BB BB BB		+1 (DDD) DDD-DDDD
//	local-part@domain
//
//	Copyright 2026 by Karl Vincent Pierre Bertin
//
//	Permission to use, copy, modify, and distribute this software and its documentation for any purpose and without fee is hereby granted, provided that the above copyright notice appear in all copies and that both that copyright notice and this permission notice appear in supporting documentation, and that the name of Karl Vincent Pierre Bertin not be used in advertising or publicity pertaining to distribution of the software without specific, written prior permission. Karl Vincent Pierre Bertin makes no representations about the suitability of this software for any purpose. It is provided "as is" without express or implied warranty.
