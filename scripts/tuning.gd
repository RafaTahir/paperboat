extends RefCounted
## Shared physical and presentation constants; all distances are metres.

const WATER_HEIGHT: float = 0.0
const CRUISE_SPEED: float = 0.135
const GUST_SPEED: float = 0.235
const STEER_RESPONSE: float = 0.24
const GUST_RESPONSE: float = 0.19
const COAST_RESPONSE: float = 1.05
const BRAKE_RESPONSE: float = 0.18
const CURRENT_LIMIT: float = 0.052
const CONTACT_RADIUS: float = 0.048
const START: Vector3 = Vector3(-2.8, 0.0, 4.6)
const DESTINATION: Vector3 = Vector3(2.1, 0.0, -4.6)
const CAMERA_OFFSET: Vector3 = Vector3(0.0, 1.35, 1.65)
const CAMERA_FOV: float = 48.0
const CAMERA_FOLLOW_RESPONSE: float = 0.36
const CAMERA_LOOKAHEAD: float = 0.32
