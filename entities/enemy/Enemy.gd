extends Node2D

class_name Enemy

signal dead()
signal done_reloading()

export(PackedScene) var BULLET_SCENE: PackedScene
onready var PLAYER: Node2D = Global.get_player()
onready var BULLET_CONTAINER: Node2D = Global.get_bullet_container()

var power_ratio: float = sqrt(max(max(Global.player_power[0],
    Global.player_power[1]), Global.player_power[2]))

export(float) var HP_MULTIPLIER: int = 3
var MAX_HP: int = HP_MULTIPLIER + int(HP_MULTIPLIER * power_ratio)
var hp: int = MAX_HP

export(float) var BULLET_SPEED: int = 200.0
var MIN_SPREAD_BULLET_COUNT: int = 4

onready var FREEZE_TIMER: Timer = $FreezeTimer
onready var WAITING_TIMER: Timer = $StateMachine/Waiting/WaitingTime
onready var DURATION_TIMER: Timer = $StateMachine/Shooting/Duration

onready var SPRITE: Sprite = $Sprite
onready var ANIMATION_PLAYER: AnimationPlayer = $AnimationPlayer
var COLOUR_MAP: Dictionary = {
    Types.RgbColour.RED: Color.indianred,
    Types.RgbColour.GREEN: Color.chartreuse,
    Types.RgbColour.BLUE: Color.royalblue,
}
export(bool) var RANDOMIZE_COLOUR: bool = true
export(Types.RgbColour) var colour: int = Types.RgbColour.RED
onready var HURTBOX: Area2D = $Hurtbox
onready var INITIAL_PHYSICS_LAYER: int = HURTBOX.collision_layer

func _ready() -> void:
    if Global.is_room_cleared():
        queue_free()
    else:
        if RANDOMIZE_COLOUR:
            var random: RandomNumberGenerator = RandomNumberGenerator.new()
            random.randomize()
            colour = random.randi_range(0, 2)
        update_colour()

func set_colour(new_colour: int) -> void:
    colour = new_colour
    update_colour()

func update_colour() -> void:
    SPRITE.self_modulate = COLOUR_MAP[colour]
    HURTBOX.collision_layer = INITIAL_PHYSICS_LAYER << colour

func start_shooting() -> void:
    ANIMATION_PLAYER.play("shooting")

func reload() -> void:
    ANIMATION_PLAYER.play("reloading")
    yield(ANIMATION_PLAYER, "animation_finished")
    shoot_in_all_directions()
    emit_signal("done_reloading")

func shoot_at_player() -> void:
    shoot((PLAYER.position - self.position).angle())

func shoot_in_all_directions() -> void:
    var bullet_count: int = int(power_ratio)
    if bullet_count >= MIN_SPREAD_BULLET_COUNT:
        for i in range(bullet_count):
            shoot((float(i) / float(bullet_count)) * TAU)

func shoot(angle: float) -> void:
    var bullet: Bullet = BULLET_SCENE.instance()
    bullet.position = self.position
    bullet.speed = Vector2.RIGHT.rotated(angle) * BULLET_SPEED
    bullet.colour = colour
    BULLET_CONTAINER.add_child(bullet)

func take_damage(damage: int) -> void:
    hp -= damage
    if hp <= 0:
        emit_signal("dead")
        queue_free()

func freeze(time: float) -> void:
    self.modulate = Color.blue
    ANIMATION_PLAYER.playback_speed = 0.0
    WAITING_TIMER.paused = true
    DURATION_TIMER.paused = true
    FREEZE_TIMER.wait_time = time
    FREEZE_TIMER.start()

func _on_FreezeTimer_timeout():
    ANIMATION_PLAYER.playback_speed = 1.0
    WAITING_TIMER.paused = false
    DURATION_TIMER.paused = false
    self.modulate = Color.white
