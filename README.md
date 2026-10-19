# 🎓 Mobs Pupils Mod (`mobs_pupils`)

Bring life, learning, and playful energy to your Minetest / Luanti world! 🎒🌟

`mobs_pupils` introduces adorable pupil NPCs—peaceful, half-sized player characters that follow a realistic daily schedule, go to school, relax at home, follow their parents, and play with toys!

---

## ✨ Features

- 🎒 **Pupil NPCs**: Peaceful half-sized mobs using player mesh models (`visual_size = {x = 0.5, y = 0.5}`).
- 🏫 **School Block (`mobs_pupils:school_block`)**: When placed, pupils gather near the school block during school hours (in-game time **7000 to 12000**).
- 🏡 **Home Block (`mobs_pupils:home_block`)**: When pupils are off school, they return home and hang around their designated home block.
- 👨‍👩‍👧 **Parent Following**: If no school or home block is found in range, pupils follow their parent (the player who spawned them or right-clicked them).
- 🧸 **ToyCity Mod Integration**: If the optional `toycity` mod is loaded, pupils will randomly place fun blocks and toys from the ToyCity mod while hanging around home!
- 🥚 **Spawn Egg**: Easy-to-use spawn egg to bring new pupils into your world.

---

## ⏰ Daily Schedule Breakdown

| In-Game Time | Activity | Target Location |
| :--- | :--- | :--- |
| **7000 – 12000** | **School Time** 📚 | Gathers around `mobs_pupils:school_block` |
| **12001 – 6999** | **Home & Play Time** 🏡 | Gathers around `mobs_pupils:home_block` & places toys |
| *No Block Nearby* | **Parent Following** 🚶‍♂️ | Follows the parent player |

---

## 🛠️ Crafting Recipes

### School Block
```text
[ Book ]   [ Book ]   [ Book ]
[ Cobble ] [ Cobble ] [ Cobble ]
[ Wood ]   [ Wood ]   [ Wood ]
```

### Home Block
```text
[ Wood ]   [ Wood ]         [ Wood ]
[ Chest ]  [ Yellow Wool ]  [ Chest ]
[ Wood ]   [ Wood ]         [ Wood ]
```

---

## 📜 Dependencies & Compatibility

- **Required**: `mobs` (Mobs Redo), `default`
- **Optional**: `player_api`, `3d_armor`, `toycity`

---

## ⚖️ License

- **Code**: MIT License © 2026 ronrob-lu
- **Textures & Media**: CC0 1.0 Universal (Kenney - kenney.nl)
