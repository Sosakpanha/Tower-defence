## Tiny helper for drawing a texture scaled to fit a box while keeping its aspect ratio.
class_name Sprite
extends RefCounted


## Rect (relative to the node origin) for `tex` scaled so its longest side is `max_px`,
## centred horizontally on x=0 and with its bottom edge at `bottom.y`.
static func fit(tex: Texture2D, max_px: float, bottom: Vector2) -> Rect2:
	var k := max_px / maxf(tex.get_width(), tex.get_height())
	var sz := Vector2(tex.get_width(), tex.get_height()) * k
	return Rect2(Vector2(bottom.x - sz.x / 2.0, bottom.y - sz.y), sz)
