# Get Some Points! 🎮

Game platformer 2D bertema *survive* sambil ngumpulin poin sebanyak-banyaknya! Di game ini, player bakal ngelewatin berbagai rintangan, ngalahin musuh, dan bertahan hidup sampai akhir level (nanti di akhir ada lawan boss juga).

## 📖 Ringkasan Game
- **Genre:** 2D Platformer / Action
- **Engine:** Godot 4.6 (GL Compatibility)
- **Tujuan Utama:** Ngumpulin poin sebanyak mungkin dan selesaiin run dengan selamat.
- **Kondisi Kalah:** Player kehabisan darah -> Masuk ke layar `you_died`.
- **Kondisi Menang:** Berhasil kabur atau ngelewatin rintangan akhir -> Masuk ke layar `you_win`.

## ✨ Fitur
- **Movement:** Jalan, lari, lompat, sampai *double jump*!
- **Combat:** Basic attack + Skill slash (ada *cooldown*-nya ya biar gak spam akill terus).
- **Enemy System:** Ada Bat, Slime, sampai Goblin yang punya gaya nyerang beda-beda.
- **Wave Spawner:** Musuh bakal nge-spawn per *wave*, dan makin susah seiring berjalannya level.
- **Trap/Hazard:** Hati-hati sama Spike (Duri) yang bisa muncul tiba-tiba atau naik-turun.
- **Scoring System:** Dapet poin dari ngebunuh musuh, mungut koin, dan bonus kalau berhasil finish.
- **High Score:** Skor tertinggimu bakal selalu kesimpen selama game jalan (pakai sistem *autoload* `Global`).
- **Stage Select & Difficulty:**
  - Mau skip tutorial? Bisa banget!
  - Pilih tingkat kesulitan: *Easy*, *Normal*, atau *Hard*. Makin susah, musuh yang spawn di awal makin rame!
- **Persistent Health:** Nyawa kamu bakal nyambung terus antar level (misal dari Level 1 ke Boss Level). Jadi kalau kamu masuk Boss Level dengan darah sekarat, ya... good luck!

## 🎮 Kontrol Game
Biar nggak bingung, ini kontrol default-nya (bisa dicek juga di *input map* Godot):
- `A` / `Panah Kiri`: Jalan ke kiri
- `D` / `Panah Kanan`: Jalan ke kanan
- `W` / `Panah Atas`: Lompat (Tekan 2x buat *Double Jump*)
- `Shift`: Lari (*Sprint*)
- `J` / *Klik Kiri Mouse*: Serang (*Basic Attack*)
- `Spasi`: Jurus Slash (*Skill*)

## 🗺️ Alur Main (Flow)
1. Buka game -> **Main Menu** (`main_menu`).
2. Pilih jalanmu:
   - Klik `Start` -> Langsung masuk **Tutorial** (`tutorial`).
   - Klik `Stage Select` -> Milih level dan *setting* dulu (`stage_select`).
3. Di **Stage Select**:
   - Bisa *toggle* mau skip tutorial atau nggak.
   - Atur mau seberapa gila musuhnya (Easy/Normal/Hard).
   - Kalau skip tutorial *ON*, langsung gas ke `level_1`. Kalau *OFF*, mampir tutorial dulu.
4. Akhir perjalanan:
   - Darah abis -> **Game Over** (`you_died`).
   - Berhasil tembus -> **Menang!** (`you_win`).

## 🔥 Sistem Difficulty (Tingkat Kesulitan)
Tingkat kesulitan yang kamu pilih bakal kesimpen di *autoload* `Global` dan ngaruh banget ke jumlah musuh di awal *wave*:
- **Easy:** Musuh standar (x1).
- **Normal:** Musuh spawn 3x lipat (x3).
- **Hard:** Musuh spawn 5x lipat (x5)! Auto rusuh!

## 📂 Struktur Folder Penting
Biar gampang nyari file:
- `Scenes/` -> Semua tampilan layar/map ada di sini.
- `Scripts/` -> Otaknya game (logic/kodingan).
- `Assets/` -> Gambar (*sprite*), map (*tileset*), dan musik.

## 🧠 Intip Daleman Kodenya (Scripts)

### Core / Autoload
- `global.gd`: Tempat nyimpen memori game kayak *High Score*, status skip tutorial, *difficulty*, sampai sisa *health* player waktu ganti scene.
- `game_manager.gd`: Mandor urusan poin dan kasih *signal* ke UI/HUD.
- `scene_transition.gd`: Ngurus transisi layar biar mulus pakai animasi *fade in/out*, plus otomatis nyimpen nyawa player sebelum pindah level!

### Player & Berantem
- `player.gd`: Segala hal tentang player: gerak, attack, skill, kena *damage*, sampai sistem mati ada di sini.
- `skill_slash.gd`: *Hitbox* buat jurusnya player.

### Musuh-musuh
- `bat.gd`: Kelelawar nyebelin yang suka ngejar kalau kita deket, ngasih *damage* kalau nabrak.
- `slime.gd`: Monster lendir darat yang gerak sana-sini.
- `goblin.gd`: Musuh pinter yang punya *delay* serangan dan animasi tebas.
- `bird.gd`: Burung lewat yang fungsinya kayak jebakan jalan (kena = *damage*).

### UI & Menu
- `main_menu.gd`: Layar awal. Reset game (kayak reset nyawa dan poin) kejadian di sini.
- `stage_select.gd`: Buat milih penderitaan (*difficulty*).
- `hud.gd`: Nampilin skor kamu sekarang dan hitung mundur (*cooldown*) skill.

### Objek Lainnya
- `health_potion.gd`: Potion buat ngisi darah sampai penuh lagi (mantap!).
- `coin.gd`: Mungut koin = Dapet cuan (poin).
- `door.gd`: Pintu portal buat pindah ke level berikutnya.

## 🚀 Cara Mainin Project Ini
1. Pastiin kamu udah install **Godot 4.6** (atau minimal versi 4 yang *support* GL Compatibility).
2. *Import* folder project ini ke Godot.
3. Langsung aja *Play*! (Secara default bakal jalanin `main_menu`).

Enjoy the game dan selamat mengumpulkan poin!
