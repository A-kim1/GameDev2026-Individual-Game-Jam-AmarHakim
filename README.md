# Get Some Points

Game platformer 2D bertema bertahan hidup sambil ngumpulin poin
Player harus melewati rintangan, ngalahin musuh, dan survive sampai akhir level

## Ringkasan Game
- Genre: 2D Platformer / Action
- Engine: Godot 4.6 (GL Compatibility)
- Tujuan utama: dapet poin sebanyak mungkin dan selesain run
- Kondisi kalah: player mati -> masuk scene `you_died`
- Kondisi menang: lolos level/escape -> masuk scene `you_win`

## Fitur Utama
- Movement: jalan, lari, lompat, double jump
- Combat: basic attack + skill slash dengan cooldown
- Enemy system: bat, slime, goblin dengan behavior masing-masing
- Wave spawner: musuh spawn per wave dengan growth multiplier
- Trap/hazard: spike dan spike up/down
- Scoring system: poin dari kill musuh + coin + bonus finish
- High score tersimpan selama game jalan (via autoload `Global`)
- Stage Select:
  - Toggle skip tutorial (ON/OFF)
  - Pilih difficulty (Easy/Normal/Hard)

## Kontrol
Diambil dari `project.godot` input map:
- `A` / `Left Arrow`: gerak kiri
- `D` / `Right Arrow`: gerak kanan
- `W` / `Up Arrow`: lompat
- `Shift`: lari
- `J` / Mouse Left: attack
- `Space`: skill

## Alur Scene
1. `main_menu`
2. Pilih salah satu:
   - `Start` -> `tutorial`
   - `Stage Select` -> `stage_select`
3. Dari `stage_select`:
   - Set skip tutorial
   - Set difficulty
   - Jika skip ON -> `level_1`
   - Jika skip OFF -> `tutorial` dulu
4. Di akhir run:
   - Mati -> `you_died`
   - Berhasil escape -> `you_win`

## Sistem Difficulty
Difficulty disimpan di autoload `Global` lalu dipakai saat `level_1` load

- Easy: `start_wave_size` normal (x1)
- Normal: `start_wave_size` x3
- Hard: `start_wave_size` x5

Implementasi inti:
- `Scripts/stage_select.gd`: simpan pilihan skip + difficulty
- `Scripts/global.gd`: state global difficulty dan multiplier
- `Scripts/level_1.gd`: apply multiplier ke semua node `EnemySpawner*`

## Sistem Score dan HUD
- `GameManager` (autoload) ngurus poin + signal update UI
- Poin nambah dari:
  - kill musuh (bat/slime/goblin)
  - coin pickup
- Scene `you_win` kasih escape bonus `+500`
- High score dibandingin dan diupdate via `Global.high_score`

## Struktur Folder Penting
- `Scenes/` -> semua scene game
- `Scripts/` -> logic gameplay
- `Assets/` -> sprite, tileset, musik

## Penjelasan Script Inti
### Core / Autoload
- `Scripts/global.gd`
  - Nyimpen data global: high score, skip tutorial, difficulty
- `Scripts/game_manager.gd`
  - Ngurus poin dan signal ke HUD
- `Scripts/scene_transition.gd`
  - Fade transition saat pindah scene

### Player dan Combat
- `Scripts/player.gd`
  - Movement, jump, attack, skill, damage, death
- `Scripts/skill_slash.gd`
  - Hitbox skill slash

### Enemy
- `Scripts/bat.gd`
  - Enemy terbang, ngejar dalam radius, kasih damage kontak
- `Scripts/slime.gd`
  - Enemy darat, chase horizontal, damage interval
- `Scripts/goblin.gd`
  - Enemy darat dengan attack timer dan animasi serang
- `Scripts/bird.gd`
  - Hazard area yang kasih damage ke player

### Spawner
- `Scripts/enemy_spawner_1.gd`
- `Scripts/enemy_spawner_2.gd`
- `Scripts/enemy_spawner_3.gd`
- `Scripts/enemy_spawner_4.gd`
- `Scripts/enemy_spawner_5.gd`

Catatan:
- Spawner `2` ada sedikit beda implementasi dibanding lainnya
- Spawner `1/3/4/5` mirip pola (spawn ke parent level)
- Perbedaan ini dibiarkan sebagai jejak perkembangan kode

### UI dan Menu
- `Scripts/main_menu.gd`
  - Tombol start, stage select, credit, exit
- `Scripts/stage_select.gd`
  - Toggle skip tutorial + pilih difficulty
- `Scripts/hud.gd`
  - Tampil poin dan cooldown skill
- `Scripts/control.gd`
  - UI score di scene kalah
- `Scripts/you_win.gd`
  - UI score di scene menang

### Trap / Object
- `Scripts/spike.gd`
  - Trap aktif-delay-cooldown
- `Scripts/spike_up_down.gd`
  - Damage area sederhana
- `Scripts/coin.gd`
  - Coin pickup dan tambah poin
- `Scripts/health_potion.gd`
  - Heal full HP
- `Scripts/door.gd`
  - Pindah scene saat player masuk door

## Cara Jalanin Project
1. Buka Godot 4.6
2. Import folder project ini
3. Jalankan project (main scene: `main_menu`)

## Catatan Pengembangan
- Style komentar di script dibuat simpel dan santai biar gampang dipelajari
- Fokus project ini bukan cuma hasil akhir game, tapi juga nunjukkin progres coding dari awal sampai sekarang
