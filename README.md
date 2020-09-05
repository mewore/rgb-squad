# rgb-squad

## TODO

### MVP
- [x] Simple environment - single room
- [x] Player (square) that can move around with the arrow keys (see twenty/roguelike)
- [x] The player can change colour with ASD (RGB)
- [x] Stationary turrets (squares) that shoot non-functional bullets at the player (see crypt-guardians)
- [x] The turrets have a colour, as well as their bullets
- [x] The bullets pass through the player if they have the same colour and collide otherwise (maybe there should be 6 collision layers - 3 for the player, 3 for the enemies)
- [x] :skull: `[LOSE STATE]` When hit, the player loses hp; when at 0hp, the player loses
- [x] The player can shoot too
- [ ] Endless automatically generated rooms (see twenty/roguelike)
  - [x] Separate the room layout from the game scene
  - [x] Make an empty base room and another that inherits it
  - [x] Make the room destroy the enemy bullets when they die
  - [x] Make the room open its "doors" when the enemies are dead
  - [ ] When the player exits the level, reinitialize the game scene with a random room
  - [ ] Remember the state of the visited rooms (As packed scenes? No, just assume the enemies are dead since that is a prerequisite for leaving the room)
  - [ ] Automatically generate a tree-like dungeon structure and use it to determine in which directions the player can go (DungeonLayout.gd). Use Kruskal's algorithm with randomized edges between the rooms to generate the tree.
- [ ] Score = rooms cleared
- [ ] Counter before the game begins
- [ ] Health display (just text)

### Main features
- [ ] Hi-scores
- [ ] Player sprite
- [ ] Enemy sprites
- [ ] Terrain (walls, doors, floor, etc.)
- [ ] HP display
- [ ] Score display
- [ ] Enemies may drop HP
- [ ] When hurt: game freeze (momentary) followed by a camera shake
- [ ] Enemies with melee attacks
- [ ] 3 player characters (R = shotgun/fire, G = laser, B = melee)
- [ ] The 3 player characters have their own health bars
- [ ] Random upgrades, specific to every player kind
- [ ] More enemy types with harder to dodge attacks
- [ ] Main menu

### Additional features
- [ ] :checkered_flag: `[WIN STATE]` A non-endless mode where the player must collect 3 keys
- [ ] Minimap
- [ ] Every key is guarded by a boss
- [ ] Checkpoints (for the non-endless mode)

### Potential features
- [ ] Predefined dialogue between the player and the bosses
