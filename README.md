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
| Khóa mục tiêu: chạy tới và tự đánh tới khi quái chết | Chuột phải vào con quái (con trỏ thành hình kiếm, quái có viền đỏ) |
| Đánh về phía con trỏ (Cung: giữ để gồng, thả để bắn) | Chuột trái |
| Vừa đi vừa đánh quái gặp trên đường (hiện vòng tầm đánh) | A rồi chuột trái |
| Đứng lại | S |
| Kỹ năng 1, 2, 3 của vũ khí (giữ phím để xem tầm, thả ra để tung). Mở ở cấp 5, 10, 15 | Q, W, E |
| Tuyệt chiêu (giữ để xem tầm, thả ra để tung). Mở ở cấp 20 | R |
| Hủy kỹ năng đang ngắm | Chuột phải |
| Lướt né về phía con trỏ (không bị trúng đòn khi lướt) | F |
| Uống bình máu (mở ở cấp 30, trước đó mở túi bấm vào bình máu) | D |
| Mở / đóng túi đồ | B |
| Bảng kỹ năng: xem cấp mở khóa, đổi thứ tự kỹ năng (khi đã mở hết) | K |
| Đi tới một chỗ trên bản đồ nhỏ (vòng tròn góc trên bên trái). Giữ chuột và kéo để đổi chỗ đến | Chuột phải (hoặc trái) lên bản đồ nhỏ |
| Mở / đóng bản đồ lớn giữa màn hình (có tên các khu, cũng bấm để đi được) | M |
| Lên cấp ngay để chạy thử (chỉ khi mở game từ Godot bằng F5) | L |
| Tạm dừng (xem danh sách kỹ năng) | Esc |
| Tạo nhân vật mới (khi đang tạm dừng, thua hoặc thắng) | N |
| Chơi lại khi thua / thắng | R |

Kỹ năng luôn tung về phía con trỏ chuột. Muốn chơi bằng bàn phím thì vẫn dùng được phím mũi tên để đi và J để đánh.

**Chọn mục tiêu kiểu LMHT / Dota**: rê chuột lên quái thì quái có viền đỏ, hiện thanh máu và con trỏ đổi thành hình kiếm.
Chuột phải vào quái là khóa mục tiêu (vòng đỏ dưới chân, mũi tên đỏ trên đầu): nhân vật tự chạy tới và đánh liên tục
tới khi quái chết hoặc bạn bấm chuột phải xuống đất. Quái bị đánh sẽ hiện thanh máu nhỏ trên đầu.
Vùng bấm chuột và vùng trúng đòn của quái rộng hơn hình một chút cho dễ đánh. Chỉnh trong scene của quái
(`scenes/enemies/...`): `hit_radius` = vùng trúng đòn, `visual_scale` = độ to của hình (slime, dơi, cung thủ, sói, heo rừng đang là 1.5).

## Bản đồ nhỏ (giống LMHT)

Góc trên bên trái có **bản đồ nhỏ hình tròn**. Bạn luôn ở giữa vòng tròn, bản đồ trượt theo khi bạn đi.
Bấm **chuột phải** (hoặc chuột trái) vào chỗ nào trong vòng tròn là nhân vật tự tìm đường đi tới đó
(có đường xanh chỉ lối đi). Giữ chuột rồi kéo trên bản đồ để đổi chỗ đến.
Bấm **M** để mở bản đồ lớn của cả thế giới giữa màn hình (có tên các khu), bấm M lần nữa để đóng.
Thanh máu, cấp độ nằm ngay bên phải vòng tròn.

Trên bản đồ: chấm trắng là bạn, chấm đỏ là quái (tím là quái tinh anh trong hầm ngục), chấm đỏ to là Boss,
ô cam là trạm chế tạo / lửa trại, chấm tím là cửa hang, khung trắng là phần đang thấy trên màn hình.
Hầm Ngục Cổ chỉ hiện lên bản đồ sau khi bạn vào đó lần đầu.
Muốn đổi màu, độ to bản đồ: sửa đầu file `scripts/minimap.gd` (`SMALL_SCALE` = nhìn gần hay xa, `SMALL_SIZE` = độ to vòng tròn,
`SMALL_POS` = vị trí, `BIG_SCALE`, các màu `COLOR_...`). Phần cắt hình tròn nằm ở `scripts/effects/circle_mask.gdshader`.

## Cấp độ và mở khóa kỹ năng

Đánh quái rơi **ngọc xanh** (kinh nghiệm, thanh vàng mỏng dưới thanh máu, số "KN" bên cạnh). Đủ kinh nghiệm là lên cấp:
máu tối đa +8, tấn công +1, hồi đầy máu. Mới vào game (cấp 1) chỉ có **đánh thường** (chuột) và **lướt** (F).
Kỹ năng mở dần theo cấp:

| Cấp | Mở khóa |
|---|---|
| 5 | Kỹ năng thứ 1 (phím Q) |
| 10 | Kỹ năng thứ 2 (phím W) |
| 15 | Kỹ năng thứ 3 (phím E) |
| 20 | Tuyệt chiêu (phím R). Mở hết kỹ năng: được **đổi thứ tự kỹ năng** |
| 30 | Phím **D** uống bình máu nhanh (trước đó mở túi B rồi bấm vào bình máu) |

Ô kỹ năng chưa mở có màu tối và ghi "Cấp 5", "Cấp 10"... Lên tới cấp mở khóa thì có thông báo và vòng sáng xanh.

**Đổi thứ tự kỹ năng**: bấm **K** mở bảng kỹ năng. Từ cấp 20, bấm vào một kỹ năng rồi bấm ô khác là hai kỹ năng đổi chỗ
(ví dụ đưa tuyệt chiêu sang Q). Bấm "Về thứ tự ban đầu" để trả lại như cũ. Thời gian hồi chiêu đi theo kỹ năng.

Kinh nghiệm cần để lên cấp tiếp = 10 + 5 x (cấp hiện tại - 1): cấp 1 cần 10, cấp 2 cần 15, cấp 3 cần 20...
Tổng cộng khoảng 70 kinh nghiệm để tới cấp 5, 270 tới cấp 10, 600 tới cấp 15, 1000 tới cấp 20, 2300 tới cấp 30.
Quái thường (trừ Boss và bù nhìn) hạ xong sẽ quay lại chỗ cũ sau 2 phút để bạn luyện cấp. Quái trong hầm ngục cho gấp 2.5 kinh nghiệm.

Muốn chỉnh: mở `scripts/player.gd`, phần "Cấp độ mở khóa" ở đầu file: `SKILL_UNLOCK_LEVELS` (cấp mở Q W E R),
`QUICK_ITEM_LEVEL` (cấp mở D), `XP_BASE` và `XP_STEP` (kinh nghiệm cần), `LEVEL_HP` và `LEVEL_ATTACK` (thêm mỗi cấp),
`TEST_LEVEL_KEY` (phím L lên cấp để thử, đổi thành `false` để tắt). Thời gian quái hồi sinh: `ENEMY_RESPAWN` trong `scripts/level.gd`.

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
Bình máu nhặt được sẽ cất vào túi, bấm vào bình trong túi để uống (hồi 40% máu). Từ cấp 30 bấm **D** là uống nhanh.
Bắt đầu game có sẵn 2 bình máu. Túi đầy thì bình máu nhặt được sẽ uống luôn.
Bấm vào đồ ăn trong túi để ăn (hồi máu). Súp, canh hồi máu từ từ trong vài giây.
Thuốc sức mạnh / thuốc nhanh nhẹn tăng sức trong 60 giây (hiện ở góc trên màn hình kèm số giây còn lại).
Nguyên liệu (lúa mì, bình nước, gỗ, da thú, xương, dây thừng) dùng để chế tạo.
**Công cụ** (rìu, liềm, đuốc) chỉ cần để trong túi là có tác dụng, không cần bấm.
**Bộ lửa trại**: bấm vào nó trong túi là đặt một bếp lửa xuống trước mặt (ở đâu cũng được, trừ chỗ có nước hoặc sát trạm khác).
Thêm vật phẩm mới: sửa `scripts/items.gd`.

Kỹ năng nguyên tố (Lửa, Sấm) đang **tạm tắt** để tập trung làm đánh thường trước.
Muốn bật lại: mở `scripts/player.gd`, đổi `const ELEMENTS_ENABLED := false` thành `true`.

## Quảng trường Làng Khởi Nguyên

Vào game là bạn đứng ngay giữa **quảng trường**: sân lát đá, đài phun nước ở giữa, ghế dài, cột đèn, chậu hoa,
hai sạp hàng (trái cây, bánh mì). Đường đá đi ra 4 hướng: **bắc** là khu nhà dân, **nam** là bãi tập,
**tây** là giếng nước và vườn rau, **đông** là đường ra Rừng Hoang.
Bốn góc sân là 4 **trạm chế tạo**: nồi luyện thuốc (trên trái), lò nấu ăn (trên phải), bàn chế tạo (dưới trái), bếp lửa (dưới phải).
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
Sói, heo rừng và các quái thường khác quay lại chỗ cũ sau 2 phút (chỉnh `ENEMY_RESPAWN`).

## Chế tạo

Quanh **quảng trường Làng Khởi Nguyên** (chỗ bắt đầu game) có 4 trạm chế tạo, mỗi trạm làm được món riêng:
**nồi luyện thuốc** (góc trên trái), **lò nấu ăn** bằng gạch (góc trên phải), **bàn chế tạo** (góc dưới trái),
**bếp lửa** có xiên nướng (góc dưới phải). Lửa trại trong rừng cũng nướng đồ được như bếp lửa.
Đi tới gần trạm là bảng chế tạo của trạm đó tự mở (đi ra xa thì đóng). Bảng ghi nguyên liệu đang có / cần
(xanh là đủ, đỏ là thiếu), đủ đồ thì bấm **Chế**. Nước lấy ở **xô cạnh giếng** (giếng ở cả 3 làng, xô đầy lại sau 20 giây).

| Trạm | Làm ra | Nguyên liệu |
|---|---|---|
| Nồi luyện thuốc | Bình máu (hồi 40% máu) | 2 thảo dược + 1 bình nước |
| Nồi luyện thuốc | Bình máu lớn (hồi 80% máu) | 3 thảo dược + 1 táo + 1 bình nước |
| Nồi luyện thuốc | Thuốc sức mạnh (tấn công +6 trong 60 giây) | 1 thảo dược + 2 xương + 1 bình nước |
| Nồi luyện thuốc | Thuốc nhanh nhẹn (tốc độ +30% trong 60 giây) | 2 quả mọng + 1 thảo dược + 1 bình nước |
| Bếp lửa | Thịt nướng (hồi 35 máu) | 1 thịt sống |
| Bếp lửa | Xiên nấm nướng (hồi 25 máu) | 3 nấm |
| Bếp lửa | Bí ngô nướng (hồi 50 máu) | 1 bí ngô |
| Bếp lửa | Xiên thịt rau (hồi 60 máu) | 1 thịt + 1 cà rốt + 1 nấm |
| Lò nấu ăn | Bánh mì (hồi 25 máu) | 2 lúa mì + 1 bình nước |
| Lò nấu ăn | Bánh táo (hồi 45 máu) | 2 táo + 2 lúa mì |
| Lò nấu ăn | Súp nấm (hồi 5 máu/giây trong 10 giây) | 2 nấm + 2 quả mọng |
| Lò nấu ăn | Súp bí ngô (hồi 8 máu/giây trong 12 giây) | 1 bí ngô + 1 cà rốt + 1 bình nước |
| Lò nấu ăn | Canh xương (hồi 6 máu/giây trong 15 giây) | 2 xương + 1 cà rốt + 1 bình nước |
| Bàn chế tạo | Dây thừng | 3 lúa mì |
| Bàn chế tạo | Rìu (chặt gốc cây lấy gỗ) | 2 xương + 1 dây thừng |
| Bàn chế tạo | Liềm (hái cây được thêm 1) | 1 xương + 1 gỗ + 1 dây thừng |
| Bàn chế tạo | Đuốc (vòng sáng to hơn trong hầm ngục) | 1 gỗ + 1 dây thừng |
| Bàn chế tạo | Bộ lửa trại (đặt bếp lửa ở đâu cũng được) | 3 gỗ + 1 dây thừng |
| Bàn chế tạo | Ba lô lớn hơn (+4 ô túi, làm 2 lần) | 3 da thú + 2 dây thừng |
| Bàn chế tạo | Áo giáp da (máu tối đa +25) | 4 da thú + 1 dây thừng |
| Bàn chế tạo | Bùa răng sói (tấn công +4) | 4 xương + 1 da thú + 1 dây thừng |

Rìu, liềm, đuốc chỉ làm 1 cái (có rồi thì bảng ghi "Đã có rồi").
**Gỗ**: gốc cây có khúc gỗ (`z` trên bản đồ, có trong các khu rừng) chặt được khi trong túi có Rìu, gỗ mọc lại sau 45 giây.
Thêm công thức mới: thêm một dòng vào `LIST` trong `scripts/recipes.gd` (hướng dẫn ở đầu file).
Ký tự bản đồ: `C` nồi luyện thuốc, `0` lò nấu ăn, `@` bàn chế tạo (rộng 2: `@x`), `8` bếp lửa, `j` lửa trại.

## Rừng Hoang

Rừng rậm có nhiều bãi cỏ sáng nối với nhau bằng đường đất, nền rừng tối giữa các gốc cây, nhà gỗ, bãi đất đá,
luống rau có hàng rào, lửa trại, thùng gỗ và một cái hồ có thác nước. Cây sâu trong rừng tối hơn cây ở bìa rừng.
Muốn sửa rừng: sửa phần `MAP` trong `scripts/level.gd` (ký tự `T` cây, `-` đường đất, `%` bãi đá, `H` nhà gỗ,
`V` thác nước, `k` `l` thùng, `z` gốc cây chặt gỗ, `j` lửa trại, `p` luống rau). Đường đất và bãi đá tự nối mép với ô bên cạnh.

## Hầm Ngục Cổ

**Lối vào**: cửa hang ở **vách bắc Đấu Trường Đá Cổ**, ngay sau lưng Boss. Cửa hang bị phong ấn tím cho tới khi hạ Boss.
Hạ Boss xong, đi vào miệng hang là màn hình tối dần rồi bạn xuống hầm ngục. Ngay chỗ xuống có **cầu thang sáng** trên vách:
đi vào đó là ra lại cửa hang. Ký tự bản đồ: `G` cửa hang, `{` cầu thang ra.

Hầm ngục tối: vào trong thì màn hình tối lại, chỉ có nến, đuốc trên tường, bệ thờ và cổng xoáy
phát sáng (dùng đèn 2D của Godot: `PointLight2D` và `CanvasModulate`). Người chơi có một vòng sáng nhỏ quanh người.
Hai bệ thờ có cột sáng tím, trên bệ có pha lê sức mạnh hoặc bình máu. Cổng xoáy ở phòng cuối là đích đến.
Muốn chỉnh độ tối: sửa `DUNGEON_DARK` trong `scripts/level.gd`. Ký tự bản đồ hầm ngục ghi ở đầu file đó.

## Mục tiêu bản demo

1. **Làng Khởi Nguyên**: bắt đầu ở quảng trường giữa làng. Nói chuyện với dân làng, đọc biển báo, ra **bãi tập** đánh bù nhìn để quen vũ khí. Bù nhìn có khiên rất cứng, thử phá giáp bằng Thương.
2. **Rừng Hoang** (phía đông làng): đánh slime, dơi, cung thủ xương. Nhặt ngọc xanh để lấy kinh nghiệm và lên cấp mở kỹ năng (Q ở cấp 5), bình máu, vàng, pha lê tím (+Tấn công).
3. Đi tiếp về phía đông vào **Đấu Trường Đá Cổ** và hạ Boss **Gorrak**. Boss có 5 giáp, biết nhảy đập (né vòng đỏ!), bắn cầu bóng tối, và nổi điên khi còn nửa máu.
4. Hạ Boss thì phong ấn cửa hang (vách bắc đấu trường) vỡ ra. Đi vào hang xuống **Hầm Ngục Cổ** (tối, quái mạnh hơn), đi qua Sảnh Nến và Điện Thờ, rồi bước vào **Cổng Xoáy** ở phòng cuối để hoàn thành.

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
  recipes.gd           Công thức chế tạo của 4 trạm (nồi thuốc, bếp lửa, lò nấu ăn, bàn chế tạo)
  harvestable.gd       Cây thu hoạch được (tự lớn lại sau khi hái), xô nước cạnh giếng
  critter.gd           Thú hiền: thỏ, nai, chim, bướm, ếch, vịt
  skills.gd            Danh sách tất cả kỹ năng (Q W E R)
  npc.gd               Dân làng: đi dạo, quay sang nói chuyện khi người chơi tới gần
  main.gd              Tạm dừng, thua, thắng, chơi lại
  level.gd             Bản đồ (vẽ bằng chữ), sinh quái, cổng, khu vực, tìm đường cho chuột phải
  player.gd            Nhân vật: điều khiển chuột, đánh, kỹ năng Q W E R, túi đồ, lên cấp
  hud.gd               Thanh máu, năng lượng, kỹ năng, thông báo, túi đồ, bảng chế tạo, bảng kỹ năng (K)
  minimap.gd           Bản đồ nhỏ hình tròn góc trên bên trái, bản đồ lớn (M), bấm lên bản đồ để đi tới đó
  enemies/             enemy.gd (lớp chung, có giáp, đồ rơi), slime, bat, archer, wolf (sói), boar (heo rừng), boss, dummy
  projectile.gd        Đạn (cầu lửa, mũi tên, cầu bóng tối)
  pickup.gd            Vật phẩm rơi
  effects/             Hiệu ứng chém, vòng nổ, tia sét, dấu chỗ bấm chuột, mưa tên / thiên thạch, khung tròn bản đồ nhỏ
assets/
  town/                Hình từ Kenney Tiny Town (làng, cỏ, nhà, hàng rào...)
  tiles/, decor/       Hình từ Kenney Roguelike RPG (nước, đá, tường...)
  plaza/               Quảng trường: sân đá, đài phun nước, ghế, cột đèn, sạp hàng, chậu hoa (Claude vẽ theo màu Tiny Town)
  dungeon/             Hầm ngục: sàn, tường, nến, đuốc, bình gốm, bệ thờ, cột sáng, cổng xoáy (Claude vẽ)
  eco/                 Cây thu hoạch, cây liễu, nấm khổng lồ, cối xay gió, nhà kho, thuyền, cầu tàu... (Claude vẽ)
  critters/            Thú hiền (Claude vẽ)
  craft/               Nồi luyện thuốc, bàn chế tạo, bếp lửa, lò nấu ăn, gốc cây có gỗ, xô nước (Claude vẽ)
  cave/                Cửa hang, phong ấn, cầu thang ra hang (Claude vẽ)
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
