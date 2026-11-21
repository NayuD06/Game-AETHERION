# Fantasy: The Awakening (bản chơi thử)

Game nhập vai hành động 2D pixel, góc nhìn từ trên xuống, làm bằng **Godot 4.7** (bản Standard, GDScript).

Một chiến binh thức tỉnh trong thế giới bị các thế lực cổ đại xâm chiếm. Bắt đầu yếu ớt, bạn đánh quái, lên cấp, thức tỉnh nguyên tố **Lửa** rồi **Sấm**, hạ Boss để mở cổng sang vùng đất mới.

## Cách mở game

1. Mở `Godot_v4.7.2-stable_win64.exe`.
2. Trong cửa sổ **Project Manager**, bấm **Import**.
3. Chọn file `project.godot` trong thư mục này (ví dụ `E:\DEV\projects\game\project.godot`), rồi bấm **Import** (hoặc **Import & Edit**).
4. Lần đầu mở, Godot sẽ mất vài giây để nạp hình ảnh. Đợi xong rồi bấm **F5** (hoặc nút ▶ góc trên bên phải) để chơi.
5. Game mở ra ở **màn hình tạo nhân vật**. Đặt tên, chọn vũ khí và ngoại hình, rồi bấm **Bắt đầu phiêu lưu** (hoặc Enter ở ô tên).

## Tạo nhân vật

Mỗi nhân vật chọn **1 trong 4 loại vũ khí** ngay lúc tạo. Vũ khí gắn liền với nhân vật đó và **không đổi được khi đang chơi**.
Sau này mỗi loại sẽ có cây kỹ năng riêng (có thể thêm nguyên tố).

| Vũ khí | Lớp nhân vật | Đặc điểm |
|---|---|---|
| Kiếm | Kiếm Sĩ | Đánh rất nhanh, bấm liên tục ra combo 3 đòn. Bị giáp chặn bớt sát thương. |
| Thương | Thương Thủ | Đâm xa, chậm hơn. Xuyên giáp và **phá giáp** quái. |
| Cung | Xạ Thủ | Bắn xa. **Giữ** nút đánh để gồng (có thanh dưới chân), thả ra bắn mũi tên đau gấp 3, xuyên qua 2 quái. |
| Sách Phép | Pháp Sư | Sách bay cạnh người, bắn tia phép. Sức mạnh nguyên tố sẽ thức tỉnh ở bản sau. |

Ngoại hình chọn được: màu da, kiểu tóc, màu tóc, trang phục, màu áo, mũ. Nút **Ngẫu nhiên** chọn bừa hết cho vui.
Nhân vật luôn cầm vũ khí đã chọn trên tay. Nhân vật được lưu vào máy (`user://nhan_vat.cfg`), lần sau mở game sẽ nhớ. Muốn tạo nhân vật khác: bấm **Esc** rồi **N**.

## Giáp của quái

Quái có giáp (biểu tượng khiên trên đầu, số giáp hiện ở thanh máu Boss) bị trừ bớt sát thương mỗi đòn.
Thương xuyên phần lớn giáp và mỗi đòn trúng làm giáp giảm đi 2 ("Phá giáp!"). Cung thủ xương có 3 giáp, Boss có 5, quái tinh anh thêm 2.

Nếu có lỗi, xem tab **Output** / **Debugger** ở dưới cùng của Godot.

## Điều khiển (chuột kiểu Liên Minh Huyền Thoại / Dota)

| Hành động | Phím |
|---|---|
| Đi tới chỗ bấm (tự tìm đường vòng qua cây, nhà, tường) | Chuột phải (giữ chuột phải để đi theo con trỏ) |
| Chạy tới và tự động đánh một con quái | Chuột phải vào con quái |
| Đánh về phía con trỏ (Cung: giữ để gồng, thả để bắn) | Chuột trái |
| Vừa đi vừa đánh quái gặp trên đường | A rồi chuột trái |
| Đứng lại | S |
| Kỹ năng 1, 2, 3 của vũ khí | Q, W, E |
| Tuyệt chiêu | R |
| Lướt né về phía con trỏ (không bị trúng đòn khi lướt) | F |
| Uống bình máu | D |
| Mở / đóng túi đồ | B |
| Tạm dừng (xem danh sách kỹ năng) | Esc |
| Tạo nhân vật mới (khi đang tạm dừng, thua hoặc thắng) | N |
| Chơi lại khi thua / thắng | R |

Kỹ năng luôn tung về phía con trỏ chuột. Muốn chơi bằng bàn phím thì vẫn dùng được phím mũi tên để đi và J để đánh.

## Kỹ năng theo vũ khí

Hiện là kỹ năng dùng vũ khí (chưa có nguyên tố). Kỹ năng luôn tung về phía con trỏ chuột.

**Kiếm**

| Phím | Kỹ năng | Mô tả |
|---|---|---|
| Q | Triple Slash | Chém liên tiếp 3 nhát theo hình vòng cung phía trước. |
| W | Piercing Thrust | Lao nhanh về phía trước và đâm kiếm xuyên qua kẻ địch trên đường đi. |
| E | Whirlwind Slash | Xoay người chém một vòng 360°, gây sát thương xung quanh. |
| R | Swordstorm | Tung ra chuỗi 7 nhát chém cực nhanh, kết thúc bằng một nhát chém mạnh diện rộng. |

**Cung**

| Phím | Kỹ năng | Mô tả |
|---|---|---|
| Q | Double Shot | Bắn nhanh 2 mũi tên liên tiếp vào mục tiêu (rê chuột lên quái để nhắm thẳng vào nó). |
| W | Piercing Arrow | Kéo căng cung và bắn một mũi tên xuyên qua nhiều kẻ địch trên đường thẳng. |
| E | Backstep Shot | Lùi nhanh về phía sau đồng thời bắn 3 mũi tên về phía trước. |
| R | Rain of Arrows | Nhắm vào một khu vực và bắn liên tiếp hàng loạt mũi tên từ trên cao xuống. |

**Thương**

| Phím | Kỹ năng | Mô tả |
|---|---|---|
| Q | Spear Thrust | Đâm thương cực nhanh về phía trước, gây sát thương cao trên một đường thẳng. |
| W | Sweeping Strike | Quét thương theo chiều ngang, đánh trúng nhiều kẻ địch phía trước. |
| E | Impaling Charge | Lao tới và đâm mạnh vào mục tiêu, đẩy lùi kẻ địch (con bị đâm trúng bị choáng một chút). |
| R | Heaven's Spear | Lấy đà, nhảy lên rồi giáng một cú đâm thương cực mạnh xuống mặt đất, gây sát thương diện rộng quanh điểm tiếp đất. |

**Sách Phép** (tạm thời, sau này thay bằng phép nguyên tố): Q Cầu Phép, W Vòng Phép, E Dịch Chuyển, R Thiên Thạch.

### Kỹ năng được làm thế nào (để sau này đội kỹ năng nguyên tố)

- `scripts/skills.gd`: danh sách **tất cả** kỹ năng (tên, mô tả, hồi chiêu, sức mạnh...). Muốn cân bằng thì sửa số ở đây.
- `scripts/weapons.gd`, phần `"skills"`: bộ kỹ năng mặc định của mỗi vũ khí khi vào game (Q, W, E, R).
- `scripts/player.gd`: mỗi ô Q W E R chỉ ghi **id** kỹ năng (biến `skill_slots`). Hàm `equip_skill(ô, id)` đổi kỹ năng khác vào ô, ô kỹ năng và bảng Esc tự đổi theo. Cách từng kỹ năng hoạt động là các hàm `_skill_...`.
- Thêm kỹ năng mới: thêm 1 mục vào `scripts/skills.gd` (ghi `"cast"` là tên hàm) rồi viết hàm đó trong `scripts/player.gd`.

## Túi đồ

Bấm **B** để mở túi (12 ô, làm "Ba lô lớn hơn" ở bàn chế tạo để lên 16 rồi 20 ô).
Bình máu nhặt được sẽ cất vào túi, bấm **D** hoặc bấm vào bình trong túi để uống (hồi 40% máu).
Bắt đầu game có sẵn 2 bình máu. Túi đầy thì bình máu nhặt được sẽ uống luôn.
Bấm vào đồ ăn trong túi để ăn (hồi máu). Súp nấm, canh xương hồi máu từ từ trong vài giây.
Nguyên liệu (lúa mì, bình nước, da thú, xương, dây thừng) dùng để chế tạo.
Thêm vật phẩm mới: sửa `scripts/items.gd`.

Kỹ năng nguyên tố (Lửa, Sấm) đang **tạm tắt** để tập trung làm đánh thường trước.
Muốn bật lại: mở `scripts/player.gd`, đổi `const ELEMENTS_ENABLED := false` thành `true`.

## Quảng trường Làng Khởi Nguyên

Vào game là bạn đứng ngay giữa **quảng trường**: sân lát đá, đài phun nước ở giữa, ghế dài, cột đèn, chậu hoa,
hai sạp hàng (trái cây, bánh mì). Đường đá đi ra 4 hướng: **bắc** là khu nhà dân, **nam** là bãi tập,
**tây** là giếng nước và vườn rau, **đông** là đường ra Rừng Hoang.
Có 6 **dân làng** (trưởng làng, người bán hàng, nông dân, lính gác, một em bé). Đi tới gần là họ quay sang nói chuyện
(bong bóng chữ trên đầu), mỗi lần tới gần nói câu tiếp theo. Sạp hàng hiện chỉ để trang trí, chưa mua bán được.
Muốn sửa lời thoại, tên hoặc ngoại hình dân làng: sửa `NPC_DATA` trong `scripts/level.gd` (theo thứ tự chữ `v` trên bản đồ,
đọc từ trên xuống, trái sang phải). Ký tự quảng trường: `=` sân đá, `+` đá hoa văn, `F` đài phun nước, `J` sạp hàng,
`e` ghế, `L` cột đèn, `g` chậu hoa, `v` dân làng.

## Thế giới: 3 làng, 3 khu rừng

Bản đồ có 3 dải nối liền nhau (đi qua mép khu nào là hiện tên khu đó):

- **Dải trên**: Làng Ven Hồ (làng chài, hồ lớn, cầu tàu, thuyền, vịt, vườn cà rốt, vườn táo) và
  Rừng Thông (suối, cầu gỗ, nai, thỏ, quả mọng, thảo dược, hang sói).
- **Dải giữa**: Làng Khởi Nguyên (nơi bắt đầu), Rừng Hoang, đấu trường trùm, Hầm Ngục Cổ.
- **Dải dưới**: Xóm Ruộng (ruộng lúa, cối xay gió, nhà kho, bí ngô, cà rốt, vườn táo) và
  Đầm Lầy Nấm (ao, cầu gỗ, nấm khổng lồ, ếch, đom đóm, slime, heo rừng).

**Thu hoạch**: đi tới gần cây đã chín (hoặc chuột phải vào cây) là tự hái, đồ vào túi. Hái xong cây tự lớn lại sau một lúc.
Cây: `1` quả mọng, `2` thảo dược, `3` nấm, `4` lúa mì, `5` cà rốt, `6` bí ngô, `7` cây táo
(thông số trong `HARVEST` ở `scripts/level.gd`).
**Thú hiền** (thỏ, nai, chim, bướm, ếch, vịt) đi lại, ăn cỏ, bỏ chạy khi bạn tới gần, không đánh được.
Số thú mỗi khu chỉnh trong `AREAS` ở `scripts/level.gd`.
**Thú dữ**: `X` sói (lao tới cắn), `N` heo rừng (gồng rồi húc). Hạ chúng rơi da thú, thịt, xương.
Sói và heo rừng quay lại chỗ cũ sau 2 phút (chỉnh `BEAST_RESPAWN`).

## Chế tạo

Bên trái quảng trường, cạnh giếng nước, có **góc chế tạo**: nồi luyện thuốc và bàn chế tạo.
Đi tới gần là bảng chế tạo tự mở (đi ra xa thì đóng). Bảng ghi nguyên liệu đang có / cần (xanh là đủ, đỏ là thiếu),
đủ đồ thì bấm **Chế**. Nước lấy ở **xô cạnh giếng** (giếng ở cả 3 làng, xô đầy lại sau 20 giây).

| Trạm | Làm ra | Nguyên liệu |
|---|---|---|
| Nồi luyện thuốc | Bình máu | 2 thảo dược + 1 bình nước |
| Nồi luyện thuốc | Súp nấm (hồi 5 máu/giây trong 10 giây) | 2 nấm + 2 quả mọng |
| Nồi luyện thuốc | Thịt nướng (hồi 35 máu) | 1 thịt sống |
| Nồi luyện thuốc | Bánh mì (hồi 25 máu) | 2 lúa mì + 1 bình nước |
| Nồi luyện thuốc | Canh xương (hồi 6 máu/giây trong 15 giây) | 2 xương + 1 cà rốt + 1 bình nước |
| Bàn chế tạo | Dây thừng | 3 lúa mì |
| Bàn chế tạo | Ba lô lớn hơn (+4 ô túi, làm 2 lần) | 3 da thú + 2 dây thừng |
| Bàn chế tạo | Áo giáp da (máu tối đa +25) | 4 da thú + 1 dây thừng |
| Bàn chế tạo | Bùa răng sói (tấn công +4) | 4 xương + 1 da thú + 1 dây thừng |

Thêm công thức mới: thêm một dòng vào `LIST` trong `scripts/recipes.gd` (hướng dẫn ở đầu file).
Ký tự bản đồ: `C` nồi luyện thuốc, `@` bàn chế tạo (rộng 2: `@x`).

## Rừng Hoang

Rừng rậm có nhiều bãi cỏ sáng nối với nhau bằng đường đất, nền rừng tối giữa các gốc cây, nhà gỗ, bãi đất đá,
luống rau có hàng rào, lửa trại, thùng gỗ và một cái hồ có thác nước. Cây sâu trong rừng tối hơn cây ở bìa rừng.
Muốn sửa rừng: sửa phần `MAP` trong `scripts/level.gd` (ký tự `T` cây, `-` đường đất, `%` bãi đá, `H` nhà gỗ,
`V` thác nước, `k` `l` thùng, `z` gốc cây, `j` lửa trại, `p` luống rau). Đường đất và bãi đá tự nối mép với ô bên cạnh.

## Hầm Ngục Cổ

Sau cổng trùm là hầm ngục tối: vào trong thì màn hình tối lại, chỉ có nến, đuốc trên tường, bệ thờ và cổng xoáy
phát sáng (dùng đèn 2D của Godot: `PointLight2D` và `CanvasModulate`). Người chơi có một vòng sáng nhỏ quanh người.
Hai bệ thờ có cột sáng tím, trên bệ có pha lê sức mạnh hoặc bình máu. Cổng xoáy ở phòng cuối là đích đến.
Muốn chỉnh độ tối: sửa `DUNGEON_DARK` trong `scripts/level.gd`. Ký tự bản đồ hầm ngục ghi ở đầu file đó.

## Mục tiêu bản demo

1. **Làng Khởi Nguyên**: bắt đầu ở quảng trường giữa làng. Nói chuyện với dân làng, đọc biển báo, ra **bãi tập** đánh bù nhìn để quen vũ khí. Bù nhìn có khiên rất cứng, thử phá giáp bằng Thương.
2. **Rừng Hoang** (phía đông làng): đánh slime, dơi, cung thủ xương. Nhặt ngọc xanh để lấy kinh nghiệm, bình máu, vàng, pha lê tím (+Tấn công).
3. Đi tiếp về phía đông vào **Đấu Trường Đá Cổ** và hạ Boss **Gorrak**. Boss có 5 giáp, biết nhảy đập (né vòng đỏ!), bắn cầu bóng tối, và nổi điên khi còn nửa máu.
4. Hạ Boss thì cổng phong ấn mở. Vào **Hầm Ngục Cổ** (tối, quái mạnh hơn), đi qua Sảnh Nến và Điện Thờ, rồi bước vào **Cổng Xoáy** ở phòng cuối để hoàn thành.

## Cảm giác chiến đấu (chỉnh được)

- Combo 3 đòn: đòn 1 và 2 vung qua lại, đòn 3 mạnh hơn, đẩy lùi xa hơn.
- Khựng hình (hit-stop) và rung màn hình khi chém trúng.
- Quái bị nháy trắng, nảy hình, khựng lại và bắn hạt khi chết.
- Nhân vật tăng tốc / hãm tốc mượt, có bụi dưới chân, bóng đổ, camera nhìn trước theo hướng đi.

Các con số nằm ở Inspector của `scenes/player.tscn` (tốc độ, tăng tốc, lướt...),
trong `scripts/weapons.gd` (sát thương, tốc đánh, tầm, xuyên giáp, phá giáp, thời gian gồng cung của từng vũ khí)
và trong `scripts/game.gd` (hàm `hit_stop`).

## Cấu trúc thư mục

```
project.godot          Cấu hình project (mở file này bằng Godot)
scenes/                Các scene: main, player, quái, đạn, vật phẩm
scripts/
  game.gd              Autoload "Game": phím điều khiển, tín hiệu dùng chung, lưu nhân vật
  character_creator.gd Màn hình tạo nhân vật (giao diện tạo bằng code)
  character_parts.gd   Danh sách màu da, tóc, áo, mũ và cách ghép các lớp hình
  weapons.gd           Thông số 4 loại vũ khí và bộ kỹ năng mặc định của từng loại
  items.gd             Vật phẩm cất trong túi đồ
  recipes.gd           Công thức chế tạo (nồi luyện thuốc, bàn chế tạo)
  harvestable.gd       Cây thu hoạch được (tự lớn lại sau khi hái), xô nước cạnh giếng
  critter.gd           Thú hiền: thỏ, nai, chim, bướm, ếch, vịt
  skills.gd            Danh sách tất cả kỹ năng (Q W E R)
  npc.gd               Dân làng: đi dạo, quay sang nói chuyện khi người chơi tới gần
  main.gd              Tạm dừng, thua, thắng, chơi lại
  level.gd             Bản đồ (vẽ bằng chữ), sinh quái, cổng, khu vực, tìm đường cho chuột phải
  player.gd            Nhân vật: điều khiển chuột, đánh, kỹ năng Q W E R, túi đồ, lên cấp
  hud.gd               Thanh máu, năng lượng, kỹ năng, thông báo, túi đồ, bảng chế tạo
  enemies/             enemy.gd (lớp chung, có giáp, đồ rơi), slime, bat, archer, wolf (sói), boar (heo rừng), boss, dummy
  projectile.gd        Đạn (cầu lửa, mũi tên, cầu bóng tối)
  pickup.gd            Vật phẩm rơi
  effects/             Hiệu ứng chém, vòng nổ, tia sét, dấu chỗ bấm chuột, mưa tên / thiên thạch
assets/
  town/                Hình từ Kenney Tiny Town (làng, cỏ, nhà, hàng rào...)
  tiles/, decor/       Hình từ Kenney Roguelike RPG (nước, đá, tường...)
  plaza/               Quảng trường: sân đá, đài phun nước, ghế, cột đèn, sạp hàng, chậu hoa (Claude vẽ theo màu Tiny Town)
  dungeon/             Hầm ngục: sàn, tường, nến, đuốc, bình gốm, bệ thờ, cột sáng, cổng xoáy (Claude vẽ)
  eco/                 Cây thu hoạch, cây liễu, nấm khổng lồ, cối xay gió, nhà kho, thuyền, cầu tàu... (Claude vẽ)
  critters/            Thú hiền (Claude vẽ)
  craft/               Nồi luyện thuốc, bàn chế tạo, xô nước (Claude vẽ)
  forest/              Rừng Hoang: cây, nền rừng tối, đường đất, bãi đá, thác nước (Claude vẽ) và thùng, gốc cây, lửa trại (Kenney)
  kenney/              Nguyên tấm sprite sheet Roguelike RPG để dùng thêm sau
  character/           Các lớp ngoại hình nhân vật: thân, mặt, áo, tay, tóc, mũ (Claude vẽ, khung 24x32, hoạt ảnh 4 hướng)
  ui/                  Con trỏ chuột (mũi tên, kiếm khi rê lên quái)
  weapons/             Vũ khí: kiếm từ Kenney Tiny Dungeon; thương, cung, tên, sách phép do Claude vẽ
  sprites/             Quái, bóng đổ, hiệu ứng (Claude vẽ, có hoạt ảnh)
  items/               Vật phẩm
```

## Tự chỉnh sửa

- **Đổi hình**: thay file PNG trong `assets/` bằng hình của bạn, giữ nguyên tên file. Ô bản đồ 16x16.
  Mỗi lớp nhân vật trong `assets/character/` là sprite sheet 4 cột x 3 hàng (khung 24x32): hàng 1 đi xuống, hàng 2 đi lên, hàng 3 đi ngang (sang phải).
- **Thêm kiểu tóc / áo / mũ mới**: vẽ một sheet 96x96 như trên. Tóc và áo vẽ bằng **màu xám** (game tự tô màu theo lựa chọn), mũ vẽ màu thật.
  Bỏ file vào `assets/character/`, rồi thêm một dòng vào `HAIR_STYLES`, `OUTFITS` hoặc `HATS` trong `scripts/character_parts.gd`.
  Thêm màu mới thì thêm dòng vào `SKIN_TONES`, `HAIR_COLORS`, `OUTFIT_COLORS`.
  Quái (`slime`, `bat`, `archer`) là 2 khung 16x16 nằm ngang, Boss là 2 khung 32x32.
- **Sửa bản đồ**: mở `scripts/level.gd`, sửa phần `MAP`. Mỗi ký tự là một ô, chú thích ký tự nằm ngay đầu file.
- **Chỉnh chỉ số quái**: trong Godot, mở `scenes/enemies/slime.tscn` (hoặc quái khác), chọn node gốc, chỉnh máu, tốc độ, sát thương ở bảng **Inspector** bên phải.
- **Chỉnh nhân vật**: tốc độ, lướt nằm ở Inspector của `scenes/player.tscn`. Máu, tấn công khởi đầu và mức tăng khi lên cấp nằm trong `scripts/player.gd`.
- **Đổi phím**: sửa `KEY_BINDINGS` trong `scripts/game.gd`.

Mẹo: bạn có thể sửa code trong Antigravity IDE. Lưu file xong quay lại Godot, bấm F5 để chạy lại.

## Ghi công hình ảnh

- Kenney Tiny Town, Kenney Roguelike RPG và Kenney Tiny Dungeon (www.kenney.nl), giấy phép CC0, dùng tự do kể cả thương mại.
