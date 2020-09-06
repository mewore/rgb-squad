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
- [x] Endless automatically generated rooms (see twenty/roguelike)
  - [x] Separate the room layout from the game scene
  - [x] Make an empty base room and another that inherits it
  - [x] Make the room destroy the enemy bullets when they die
  - [x] Make the room open its "doors" when the enemies are dead
  - [x] When the player exits the level, reinitialize the game scene with a random room
  - [x] Remember the state of the visited rooms (As packed scenes? No, just assume the enemies are dead since that is a prerequisite for leaving the room)
  - [x] Automatically generate a tree-like dungeon structure and use it to determine in which directions the player can go (DungeonLayout.gd). Use Kruskal's algorithm with randomized edges between the rooms to generate the tree.
- [x] Score = rooms cleared
- [x] Counter when entering a room with enemies
- [x] Health display (just text)
- [x] Add room variations
- [x] Add a simple minimap

### Main features
- [ ] Hi-scores
- [x] Player sprite
- [x] Different player sprites for the different colours
- [x] Enemy sprites
- [ ] Terrain (walls, doors, floor, etc.)
- [ ] HP display
- [x] Score display
- [ ] Enemies may drop HP
- [x] When hurt: game freeze (momentary) followed by a camera shake
- [ ] Enemies with melee attacks
- [ ] 3 player characters (R = shotgun/fire, G = laser, B = melee)
- [x] The 3 player characters have their own health bars
- [ ] Random upgrades, specific to every player kind
- [ ] More enemy types with harder to dodge attacks
- [ ] Main menu
- [ ] Add a font ([JELLEE TYPEFACE](https://fontlibrary.org/en/font/jellee-typeface))

### Additional features
- [ ] :checkered_flag: `[WIN STATE]` A non-endless mode where the player must collect 3 keys
- [ ] Every key is guarded by a boss
- [ ] Checkpoints (for the non-endless mode)
- [ ] Replace the obstacles in the middle of the room with holes

### Potential features
- [ ] Predefined dialogue between the player and the bosses
