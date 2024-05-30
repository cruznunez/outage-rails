// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.routeMapper = function(outages) {
  // definitions
  function boundsOf(outages) {
    // we will make an array of arrays [[lat, lng], [lat, lng]]
    var arrays = []
    outages.forEach((o) => arrays.push([o.lat, o.lng]))
    return L.latLngBounds(arrays)
  }

  function addMarkers(outages, overlays) {
    outages.forEach((outage) => {
      var colors = {
        Planned: 'blue',
        Unplanned: 'red'
      };
      var color = colors[outage.cause];

      var x = L.marker([outage.lat, outage.lng], { icon: xIcon() } )
      var marker = L.marker([outage.lat, outage.lng], { icon: markerIcon(color)} )
      marker.bindPopup(`<b>${outage.cause} outage!</b><br>${outage.customers} customers affected.<br>Average salaray: $100K.`);

      if (outage.cause == 'Planned') {
        overlays['Planned'].addLayer(marker).addLayer(x)
      } else {
        overlays['Unplanned'].addLayer(marker).addLayer(x)
      }

      if (outage.convex_hull) {
        var arrays = []
        outage.convex_hull.forEach((h) => { arrays.push([h.lat, h.lng]) })
        var polygon = L.polygon(arrays, { color: 'red' })
        polygon.bindPopup("I am a convex hull.");

        var x = L.marker([outage.lat, outage.lng], { icon: xIcon() })
        var marker = L.marker([outage.lat, outage.lng], { icon: markerIcon(color) })
        marker.bindPopup(`<b>${outage.cause} outage!</b><br>${outage.customers} customers affected.<br>Average salaray: $100K.`);

        overlays['Convex Hull'].addLayer(marker).addLayer(x).addLayer(polygon)
      }
    })
  }

  function xIcon() {
    return L.divIcon({className: 'x-marker'})
  }

  function markerIcon(color) {
    var h = 40 // (font size in css) - 2
    var w = 30
    return L.divIcon({
      iconSize: [w, h], iconAnchor: [w/2, h], popupAnchor: [0, -h],
      className: `fa-solid fa-location-dot ${color}`
    })
  }

  // add a map
  var map = L.map('map').setView([51.505, -0.09], 13)
    .fitBounds(boundsOf(outages));

  // add a tile layer to map
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
  }).addTo(map);

  // add marker to layers
  var overlayMaps = {
    "Planned": L.layerGroup(),
    "Unplanned": L.layerGroup(),
    "Convex Hull": L.layerGroup()
  };
  addMarkers(outages, overlayMaps)

  // add overlay maps to the map by default
  overlayMaps["Planned"].addTo(map);
  overlayMaps["Unplanned"].addTo(map);
  overlayMaps["Convex Hull"].addTo(map);

  // add layers controls to map
  var layerControl = L.control.layers(null, overlayMaps).addTo(map);
}
