Explanation https://www.explainxkcd.com/wiki/index.php/426:_Geohashing
Sharing on the wiki: https://geohashing.site/geohashing/A_beginner%27s_guide

## Problems with Foot travel to GeoHash
One negative outcome is the geohash might be in an unsafe/illegal area: https://geohashing.site/geohashing/Guidelines
Also, the closest geohash is often 15-25 miles as the crow flies, which would make for a pretty long out-and-back run <sup>[citation needed]</sup>.

## Varying the distance
- [ ] Look for other examples of this online

To make the point walkable, an average distance as-the-crow-flies of 1 mile is probably about right. (So maybe 1.5 miles routing distance -> 3 miles)
5K is a good distance for runners, but the distance could be increased up to around 5 miles (15 miles round trip) for a daily run.

A simple approach to decreasing the distance 10x is to take the first decimal place of your current GPS location.
An example of taking the comic from https://www.xkcd.com/426/ would start with:
Your Location: **37.4**21542 with 0.8**57713** giving 37.457713.
(Throwing away the 8 gives the advantage that 1% of the pedestrian geohashes are the official geohashes!)

Another approach giving more variety would be to create a family of geohash algorithms, like SHA-256 and SHA-512 for hashing.
Official geohash would be geohash-1. Then geohash-2 would be 2x more zoomed in, geohash-4 would be 4x more, etc. (The simple approach would be geohash-10, and [globalhash](https://geohashing.site/geohashing/Globalhash) would be geohash-one-over-360).

### Making the location accessible
OpenStreetMap has a large database of which roads are accessible to pedestrians, both from a safety and from a no-trespassing perspective.
When using a routing tool built from OpenStreetMap data, it is common to click on a pixel not perfectly aligned with a street, then the routing tool "snaps" to the closest possible street.
An example tool is GraphHopper: the [map matching](https://docs.graphhopper.com/#tag/Map-Matching-API) and [routing](https://docs.graphhopper.com/#tag/Routing-API) APIs could automate this snapping.
- [ ] Check if either of these APIs could work. Compare price to a different solution, or self-hosting the docker image?

One con to this approach is if you lived next to the ocean, half of your snapped points would just be on the beach. Maybe you could work around this by only snapping a certain distance, otherwise re-roll the points?

Another difference is most geohashs aren't right on the road; they're quite off-road. Snapping to road would remove the possibility of hiking through an accessible field.