extends RefCounted
## The same smooth velocity field drives both the boat and floating debris.
## XZ-only velocities are metres per second, never impulses per frame.

const Tuning = preload("res://scripts/tuning.gd")

static func _falloff(distance: float, inner: float, outer: float) -> float:
	return 1.0 - smoothstep(inner, outer, distance)

static func directional(position: Vector3, center: Vector3, radius: float, flow: Vector3) -> Vector3:
	var flat: Vector3 = position - center
	flat.y = 0.0
	return flow * _falloff(flat.length(), radius * 0.45, radius)

static func curved(position: Vector3, center: Vector3, radius: float, width: float, speed: float) -> Vector3:
	var offset: Vector3 = position - center
	offset.y = 0.0
	var distance: float = offset.length()
	if distance < 0.001:
		return Vector3.ZERO
	var weight: float = _falloff(absf(distance - radius), width * 0.2, width)
	# At the south side of the central planter the water moves west;
	# along the west side it gently turns north toward the rain chain.
	var tangent: Vector3 = Vector3(-offset.z, 0.0, offset.x) / distance
	return tangent * speed * weight

static func crossing(position: Vector3) -> Vector3:
	var across: float = _falloff(absf(position.z + 1.65), 0.25, 0.75)
	var along: float = _falloff(absf(position.x + 2.25), 0.75, 1.6)
	return Vector3(0.036, 0.0, -0.008) * across * along

static func sample(position: Vector3) -> Vector3:
	var flow: Vector3 = Vector3.ZERO
	flow += directional(position, Vector3(-1.5, 0.0, 3.7), 2.05, Vector3(0.008, 0.0, -0.003))
	flow += curved(position, Vector3(0.0, 0.0, -0.85), 1.45, 0.9, 0.038)
	flow += crossing(position)
	flow += directional(position, Vector3(1.9, 0.0, -4.5), 1.25, Vector3(-0.003, 0.0, -0.004))
	# Calm shelter: the chair and hibiscus pockets should invite lingering.
	var chair: float = _falloff(position.distance_to(Vector3(2.7, 0.0, 2.75)), 0.4, 1.1)
	var hibiscus: float = _falloff(position.distance_to(Vector3(0.15, 0.0, -3.0)), 0.25, 0.75)
	flow *= 1.0 - maxf(chair, hibiscus) * 0.8
	flow.y = 0.0
	return flow.limit_length(Tuning.CURRENT_LIMIT)
