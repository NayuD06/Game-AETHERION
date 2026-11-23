class_name Level
extends Node2D
## Màn chơi được vẽ từ bản đồ chữ (MAP) bên dưới.
## Hình ảnh: bộ Kenney Tiny Town (làng, cỏ, nhà), Kenney Roguelike RPG (đấu trường, đồ vật)
## và cây rừng, thác nước, đường đất do Claude vẽ (assets/forest).
## Bạn có thể tự sửa bản đồ: mỗi ký tự là một ô 16x16 pixel.
##
##   T  cây rừng (chặn đường, nền rừng tối)   #  tường đá (chặn đường)
##   ~  nước (chặn đường)
##   G  cửa hang vào Hầm Ngục Cổ (đặt trên vách đá, miệng hang quay xuống dưới).
##      Bị phong ấn tới khi hạ Boss, sau đó đi vào là xuống Tầng 1 của hầm ngục.
##   o  bụi cây (chặn đường)      r  tảng đá (chặn đường)
##   .  cỏ      ,  cỏ có hoa      :  sàn đá đấu trường     ;  sàn hầm ngục (phiến đá)
##   _  đường lát đá    f  hàng rào    w  giếng    q  biển báo (đọc khi đi tới gần)
##   y  tổ ong    t  cây trong làng    n  nấm (trang trí)
##   d  bù nhìn tập đánh    D  bù nhìn có giáp (thử Thương phá giáp)
##   -  đường đất    %  bãi đất đá    p  luống rau (trên đất)
##   k  thùng gỗ    l  thùng tròn    z  gốc cây (có Rìu thì chặt được gỗ)    j  lửa trại (nướng đồ ăn được)
##   (các ô trên đều chặn đường)
##   H  nhà gỗ trong rừng (rộng 3, cao 3)    V  thác nước (rộng 3, cao 3, đặt ngay trên hồ '~')
##   Hầm ngục 5 tầng: bản đồ riêng của từng tầng nằm trong scripts/dungeon.gd (có chú thích ký tự riêng).
##   Quảng trường giữa làng (nơi người chơi xuất hiện):
##   =  sân lát đá    +  đá hoa văn màu vàng (lát quanh đài phun nước)
##   F  đài phun nước (rộng 3, cao 2: F x x / x x x)    J  sạp hàng (rộng 3: J x x)
##   e  ghế dài (rộng 2: e x)    L  cột đèn    g  chậu hoa
##   v  dân làng: đi tới gần để nghe nói chuyện (tên, lời thoại, ngoại hình ở NPC_DATA).
##      Người có đồng xu trên đầu là người bán hàng: tới gần là mở cửa hàng mua / bán đồ.
##   Đồ vật đặt trên sân đá (F J e L g v P q k l) tự có nền đá bên dưới.
##   Cây thu hoạch (đi tới gần cây chín là hái, đồ vào túi, một lúc sau cây chín lại):
##   1  bụi quả mọng    2  thảo dược    3  nấm rừng    7  cây táo
##   4  lúa mì    5  cà rốt    6  bí ngô   (3 loại này trồng trên ruộng, tự có đất cày bên dưới)
##   Rừng, hồ, đầm lầy, ruộng:
##   [  cầu gỗ / cầu tàu (đi được, đặt trên nước)    $  thuyền (trên nước)    ^  cây sậy (trang trí)
##   *  nấm khổng lồ    !  cối xay gió (rộng 3, cao 3)    &  nhà kho (rộng 4, cao 3)
##   )  bù nhìn đuổi chim    (  bó rơm    X  sói    N  heo rừng
##   Chế tạo (đi tới gần là mở bảng chế tạo, công thức ở scripts/recipes.gd):
##   C  nồi luyện thuốc    @  bàn chế tạo (rộng 2: @ x)    8  bếp lửa nướng    0  lò nấu ăn (lò gạch)
##   Cạnh mỗi giếng 'w' có xô nước: đi tới là lấy được Bình nước (một lúc sau xô đầy lại).
##   R U W M  nhà (góc trên bên trái), các ô 'x' là phần còn lại của ngôi nhà
##            R, U, W rộng 4 ô, M rộng 3 ô, tất cả cao 3 ô
##   P  vị trí bắt đầu của người chơi
##   s  slime    b  dơi    a  cung thủ xương    B  Boss
##   h  bình máu    m  bình năng lượng    c  pha lê sức mạnh
##   A  bệ thờ cổ (cũng dùng làm đích đến được, giống cổng xoáy O)
##
## THẾ GIỚI MỞ: bản đồ này (104 x 96 ô) nằm ở GIỮA thế giới lớn 320 x 288 ô. Bốn phía xung quanh (làng mới,
## sa mạc, biển, núi tuyết...) nằm trong scripts/world_map.gd, cùng tên, kiểu cảnh, cấp quái của mọi khu (AREAS).
## Ký tự mới ngoài thế giới: á chỗ câu cá, ú cua, ạ bọ cạp, ê xưởng đóng thuyền (xem scripts/world_map.gd).
## Bản đồ chỉ hiện chỗ đã khám phá. Thế giới lớn nên mặt đất, cây cối chỉ vẽ quanh người chơi (từng mảnh 16 x 16 ô),
## quái, thú, cây thu hoạch ở xa thì tạm "ngủ" cho nhẹ máy.
##
## Bản đồ có 3 dải: dải trên (Làng Ven Hồ + Rừng Thông), dải giữa (Làng Khởi Nguyên + Rừng Hoang
## + đấu trường) và dải dưới (Xóm Ruộng + Đầm Lầy Nấm). Tên, kiểu cảnh và thú của từng khu
## nằm trong AREAS của scripts/world_map.gd. Hầm Ngục Cổ (5 tầng, scripts/dungeon.gd) là bản đồ riêng, khi chạy game
## được ghép vào xa về phía đông, ngăn cách bằng đá đặc: chỉ vào được qua cửa hang G và cầu thang,
## camera và bản đồ nhỏ chỉ thấy khu đang đứng (thế giới bên ngoài hoặc tầng hầm ngục hiện tại).

const TILE := 16

## Các khu vực (tên, khung, kiểu cảnh, thú, cấp quái...) nằm trong AREAS của scripts/world_map.gd
## (6 khu đầu là 6 khu của bản đồ này). Đi vào khu mới sẽ hiện tên khu.
const AREAS := WorldMap.AREAS
## Màu phủ lên mặt đất của từng kiểu cảnh (1 = giữ nguyên màu)
const BIOME_TINT := {
	"pine": Color(0.86, 0.96, 0.9),
	"swamp": Color(0.72, 0.84, 0.64),
	"savanna": Color(1.12, 1.0, 0.62),
	"bamboo": Color(0.84, 1.0, 0.8),
	"birch": Color(1.05, 1.07, 0.95),
	"oldforest": Color(0.82, 0.92, 0.82),
	"flowers": Color(1.02, 1.05, 0.94),
}
## Mặt đất của từng kiểu cảnh (không có trong danh sách = cỏ): sand cát, snow tuyết, red cát đỏ, stone đá, myc đất nấm
const BIOME_GROUND := {
	"snow": "snow", "taiga": "snow", "beach": "sand", "ocean": "sand", "desert": "sand", "oasis": "sand",
	"island": "sand", "badlands": "red", "mountain": "stone", "canyon": "stone", "mushroom": "myc",
}
## Màu vách đá '#' ngoài trời theo kiểu cảnh
const ROCK_TINT := {
	"mountain": Color(0.95, 0.95, 1.0), "canyon": Color(1.05, 0.92, 0.78), "badlands": Color(1.18, 0.72, 0.56),
	"desert": Color(1.12, 0.98, 0.72), "snow": Color(1.08, 1.1, 1.18), "taiga": Color(1.0, 1.04, 1.1),
}
## Hình cây cối, đồ vật của các vùng mới (do Claude vẽ)
const BIOME_TEX := {
	"palms": [preload("res://assets/coast/palm_1.png"), preload("res://assets/coast/palm_2.png")],
	"cactus": [preload("res://assets/coast/cactus_1.png"), preload("res://assets/coast/cactus_2.png"),
		preload("res://assets/coast/cactus_3.png")],
	"birch": [preload("res://assets/biomes/birch_1.png"), preload("res://assets/biomes/birch_2.png")],
	"cherry": [preload("res://assets/biomes/cherry_1.png"), preload("res://assets/biomes/cherry_2.png")],
	"acacia": [preload("res://assets/biomes/acacia_1.png"), preload("res://assets/biomes/acacia_2.png")],
	"snow_pine": [preload("res://assets/biomes/snow_pine_1.png"), preload("res://assets/biomes/snow_pine_2.png")],
	"bamboo": [preload("res://assets/biomes/bamboo_1.png"), preload("res://assets/biomes/bamboo_2.png")],
	"stilts": [preload("res://assets/biomes/stilt_1.png"), preload("res://assets/biomes/stilt_2.png")],
	"adobe": [preload("res://assets/coast/adobe_1.png"), preload("res://assets/coast/adobe_2.png")],
	"petals": [preload("res://assets/biomes/petals_1.png"), preload("res://assets/biomes/petals_2.png")],
	"cabin_snow": preload("res://assets/biomes/cabin_snow.png"),
	"rock_sand": preload("res://assets/coast/rock_sand.png"),
	"rock_red": preload("res://assets/biomes/rock_red.png"),
	"rock_snow": preload("res://assets/biomes/rock_snow.png"),
	"rock_stone": preload("res://assets/biomes/rock_stone.png"),
	"dry_bush": preload("res://assets/coast/dry_bush.png"),
	"beach_grass": preload("res://assets/coast/beach_grass.png"),
	"savanna_grass": preload("res://assets/biomes/savanna_grass.png"),
	"fern": preload("res://assets/biomes/fern.png"),
	"shells": preload("res://assets/coast/shells.png"),
	"bones": preload("res://assets/coast/bones.png"),
	"ice_crystals": preload("res://assets/biomes/ice_crystals.png"),
	"small_mushrooms": preload("res://assets/biomes/small_mushrooms.png"),
	"shipyard": preload("res://assets/coast/shipyard.png"),
	"path_stones": preload("res://assets/coast/path_stones.png"),   # đường lát đá trên cát, tuyết (không có cỏ)
}
const SNOW_HOUSES := {
	"R": preload("res://assets/biomes/house_R_snow.png"), "U": preload("res://assets/biomes/house_U_snow.png"),
	"W": preload("res://assets/biomes/house_W_snow.png"), "M": preload("res://assets/biomes/house_M_snow.png"),
}
const SAND_BIOMES := ["beach", "desert", "oasis", "island", "ocean"]
const SWAMP_TREE_COLOR := Color(0.85, 0.93, 0.85)

## Chữ trên các biển báo 'q' của bản đồ này, theo thứ tự xuất hiện (đọc từ trên xuống, trái sang phải).
## Biển báo ở các vùng mới: SIGN_TEXTS trong scripts/world_map.gd.
const SIGN_TEXTS := [
	"Rừng Thông. Nai, thỏ sống ở đây... và cả bầy sói! Quả mọng, thảo dược hái được để hồi máu.",
	"Phía đông là Rừng Thông. Coi chừng sói!",
	"Làng Ven Hồ. Vườn cà rốt và vườn táo ở phía nam làng: đi tới cây chín là hái được.",
	"Giếng làng: đi tới xô nước cạnh giếng để lấy Bình nước (dùng nấu thuốc, nấu ăn).",
	"Phía đông là Rừng Hoang. Quái vật đang tràn tới, hãy cẩn thận!",
	"Quảng trường Làng Khởi Nguyên. Quanh đây có bàn chế tạo, bếp lửa, nồi luyện thuốc và lò nấu ăn: đi tới gần là chế đồ. Người có đồng xu trên đầu bán đồ, Bác Sắt thợ rèn sửa trang bị. Bắc: Làng Ven Hồ. Nam: Xóm Ruộng. Đông: Rừng Hoang.",
	"Bãi tập: tập đánh thường lên bù nhìn. Lên cấp 5 mở kỹ năng Q, rồi W, E, R ở cấp 10, 15, 20. Bù nhìn có khiên rất cứng, Thương phá giáp dễ nhất.",
	"Xóm Ruộng: ruộng lúa, vườn cà rốt, bí ngô và vườn táo. Hái xong một lúc cây sẽ chín lại.",
	"Phía đông là Đầm Lầy Nấm. Nhiều nấm và thảo dược, nhưng có slime và heo rừng.",
	"Đầm Lầy Nấm. Đất lầy ẩm ướt, đi trên cầu gỗ để qua ao.",
]

## Dân làng 'v' của bản đồ này, theo thứ tự xuất hiện (đọc từ trên xuống, trái sang phải).
## Dân làng ở các làng mới: NPC_DATA trong scripts/world_map.gd.
## look: chỉ số ngoại hình giống màn hình tạo nhân vật (xem scripts/character_parts.gd).
## wander: bán kính đi dạo (pixel), 0 = đứng yên.
## shop: người bán hàng, đi tới gần là mở cửa hàng (tên cửa hàng trong scripts/shops.gd).
## prop: đồ đặt bên trái người đó ("anvil" = cái đe của thợ rèn).
const NPC_DATA := [
	{
		"name": "Thợ săn Lâm",
		"lines": [
			"Rừng Thông có nai, thỏ hiền lắm, đừng làm tụi nó sợ.",
			"Bầy sói sống ở bãi đá phía đông nam. Đi một mình thì cẩn thận!",
			"Quả mọng trong rừng ăn hồi máu đó, cứ hái thoải mái.",
			"Hạ sói với heo rừng sẽ có da, thịt, xương. Đem về bàn chế tạo ở làng mà làm ba lô, áo giáp.",
			"Có Rìu thì chặt được gỗ ở mấy gốc cây trong rừng. Gỗ làm đuốc, làm bộ lửa trại.",
		],
		"look": { "skin": 2, "hair": 0, "hair_color": 0, "outfit": 3, "outfit_color": 4, "hat": 3 },
		"wander": 0.0,
	},
	{
		"name": "Ông Năm câu cá",
		"lines": [
			"Hồ này nhiều cá lắm... mà tui câu cả buổi chưa được con nào.",
			"Thấy mấy con vịt kia không? Tụi nó bơi cả ngày, sướng ghê.",
		],
		"look": { "skin": 3, "hair": 4, "hair_color": 0, "outfit": 0, "outfit_color": 0, "hat": 0 },
		"wander": 0.0,
	},
	{
		"name": "Bé Bin",
		"lines": [
			"Ê! Bạn có thấy con thỏ nào chạy qua đây không?",
			"Mẹ mình bảo táo trong vườn chín rồi, bạn hái thử đi!",
		],
		"look": { "skin": 0, "hair": 2, "hair_color": 2, "outfit": 0, "outfit_color": 2, "hat": 0 },
		"wander": 36.0,
	},
	{
		"name": "Cô Mai trồng rau",
		"lines": [
			"Cà rốt chín rồi đó, bạn cứ đi qua luống là hái được.",
			"Hái xong chừng một phút là cây lại lớn. Đất làng này tốt lắm!",
		],
		"look": { "skin": 1, "hair": 3, "hair_color": 1, "outfit": 2, "outfit_color": 7, "hat": 0 },
		"wander": 0.0,
	},
	{
		"name": "Bà Lan bán trái cây",
		"lines": [
			"Trái cây tươi đây! Mua gì cứ chọn, đồ trong túi muốn bán bà cũng mua hết.",
			"Muốn có trái cây miễn phí thì lên Làng Ven Hồ hay xuống Xóm Ruộng mà hái, nhiều lắm.",
		],
		"look": { "skin": 1, "hair": 1, "hair_color": 4, "outfit": 2, "outfit_color": 1, "hat": 0 },
		"wander": 0.0,
		"shop": "fruit",
	},
	{
		"name": "Chú Tư thợ bánh",
		"lines": [
			"Bánh mì mới ra lò đây! Thơm không? Mua về ăn dọc đường nha.",
			"Hai bó lúa mì với một bình nước, cho vào lò gạch là có bánh mì. Dễ ợt!",
			"Nghe nói cuối rừng có đấu trường đá cổ. Con quái to canh giữ cái hang bị phong ấn ở đó.",
		],
		"look": { "skin": 2, "hair": 0, "hair_color": 1, "outfit": 0, "outfit_color": 6, "hat": 4 },
		"wander": 0.0,
		"shop": "bakery",
	},
	{
		"name": "Bác Sắt thợ rèn",
		"lines": [
			"Lò rèn đây! Mũ, giáp, quần, giày bằng da với sắt, mua đi cho chắc thân.",
			"Đồ mặc lâu bị đánh nhiều sẽ mòn, hết độ bền là hỏng. Mang lại đây bác sửa cho, lấy chút vàng thôi.",
			"Đồ xịn hơn thì phải xuống Hầm Ngục Cổ. Tầng càng sâu, rương càng quý!",
		],
		"look": { "skin": 3, "hair": 4, "hair_color": 0, "outfit": 1, "outfit_color": 0, "hat": 0 },
		"wander": 0.0,
		"shop": "smith",
		"prop": "anvil",
	},
	{
		"name": "Bác Ba nông dân",
		"lines": [
			"Vườn rau của bác ngay phía nam đó. Đẹp không?",
			"Bếp lửa, lò nấu ăn, nồi thuốc với bàn chế tạo ở quảng trường ai dùng cũng được. Nước thì múc ở xô cạnh giếng nha.",
			"Mệt thì cứ về quảng trường nghỉ chân, ngắm đài phun nước cho vui.",
		],
		"look": { "skin": 3, "hair": 4, "hair_color": 0, "outfit": 3, "outfit_color": 2, "hat": 0 },
		"wander": 28.0,
	},
	{
		"name": "Lính gác",
		"lines": [
			"Qua khỏi đây là Rừng Hoang. Nhớ bấm F để lướt né đòn nha!",
			"Bị thương thì mở túi (B) bấm vào bình máu hoặc trái cây. Tới cấp 30 bấm D là uống máu nhanh luôn.",
			"Thấy quái thì rê chuột lên rồi bấm chuột phải, cứ thế mà đánh tới khi nó gục.",
		],
		"look": { "skin": 0, "hair": 0, "hair_color": 0, "outfit": 1, "outfit_color": 6, "hat": 1 },
		"wander": 0.0,
	},
	{
		"name": "Bé Tí",
		"lines": [
			"Bạn là lữ khách hả? Ngầu quá!",
			"Đánh quái nhiều vào là lên cấp. Cứ 5 cấp lại mở một kỹ năng mới, bấm K mà xem!",
		],
		"look": { "skin": 1, "hair": 3, "hair_color": 3, "outfit": 0, "outfit_color": 7, "hat": 0 },
		"wander": 40.0,
	},
	{
		"name": "Trưởng làng",
		"lines": [
			"Chào mừng tới Làng Khởi Nguyên! Quảng trường này là nơi mọi lữ khách bắt đầu hành trình.",
			"Quái vật từ phía đông đang tràn tới. Hãy luyện tập rồi lên đường giúp làng nhé!",
			"Phía bắc là Làng Ven Hồ, phía nam là Xóm Ruộng, phía đông là Rừng Hoang.",
		],
		"look": { "skin": 2, "hair": 1, "hair_color": 4, "outfit": 2, "outfit_color": 3, "hat": 0 },
		"wander": 0.0,
	},
	{
		"name": "Bà thầy thuốc",
		"lines": [
			"Thảo dược hồi máu nhiều hơn quả mọng đó cháu.",
			"Hai thảo dược với một bình nước, nấu ở nồi thuốc trong làng là ra bình máu.",
			"Nấm với quả mọng nấu thành súp ở lò, ăn vào hồi máu từ từ, đánh nhau lâu rất có ích.",
			"Xương sói nấu với thảo dược thành thuốc sức mạnh đó. Quả mọng thì làm thuốc nhanh nhẹn, chạy vèo vèo.",
			"Nấm nhỏ trong đầm ăn được, còn mấy cây nấm khổng lồ thì đừng đụng nha.",
			"Slime ưa chỗ ẩm. Đi trên cầu gỗ cho đỡ lầy.",
			"Không rảnh nấu thì mua thuốc của bà cũng được. Có bình máu, thuốc sức mạnh, thuốc nhanh nhẹn.",
		],
		"look": { "skin": 4, "hair": 1, "hair_color": 4, "outfit": 2, "outfit_color": 3, "hat": 2 },
		"wander": 0.0,
		"shop": "potion",
	},
	{
		"name": "Bà Hai nông dân",
		"lines": [
			"Lúa chín vàng rồi! Lúa mì bện được dây thừng, nướng được bánh mì đó.",
			"Cối xay gió kia xay bột cho cả xóm đó.",
		],
		"look": { "skin": 2, "hair": 1, "hair_color": 4, "outfit": 3, "outfit_color": 1, "hat": 4 },
		"wander": 0.0,
	},
	{
		"name": "Bé Na",
		"lines": [
			"Mình thích bí ngô nhất! To ơi là to.",
			"Chim hay xuống ruộng mổ lúa, bạn đuổi giùm mình với!",
		],
		"look": { "skin": 1, "hair": 1, "hair_color": 3, "outfit": 0, "outfit_color": 6, "hat": 0 },
		"wander": 40.0,
	},
	{
		"name": "Chú Bảy làm vườn",
		"lines": [
			"Vườn táo của chú đó. Táo ăn hồi máu ngon lắm.",
			"Phía đông là Đầm Lầy Nấm, nhớ mang theo bình máu nha.",
		],
		"look": { "skin": 3, "hair": 0, "hair_color": 1, "outfit": 0, "outfit_color": 2, "hat": 0 },
		"wander": 0.0,
	},
]

const MAP := """
TTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTTTTT-.TTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTT#####################
Tt.n.t..................,,.t..TTTTTTTTTTTTTT-.TTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTTT#####################
T..........~~~~~~~~~~~...n....TTTTTTTTTTTTTT-.TTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTT#####################
T....1....~~~~~~~~~~~~~......tTTTTTTTTTTTTTT-.TTTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTT#####################
T........~~~~~~~~~~~~~~~..2...TTTTTTTTTT..T1...TTTTTTTTTTTT~~~TTTTTTTT,...TTTTTTTTT#####################
T......^~~~~~~~~~~~~~~~~~...,.TTTTTTTTTT.........TTTTTTTTTTT~~TTTTTT.......HxxTTTTT#####################
T..,...^~~~~~~~~~~~~~~~~~^....TTTTTTTT.......X...,TTTTTTTTTT~~TTTT3...j....xxxTTTTT#####################
T.....2.~~~~~~[[[~~~~~~~~^....TTTTTTTT...........,3TTTTTTTTT~~TTT,.....,...xxx.....%%%%%#%%%%%%#%%%%%#%%
T.1.....~~~~~~~[~~~$~~~~~.....TTTTTTT..................TTTTT~~.......-----------------------------------
T......^~~~~$~~[~~~~~~~~~.....TTTTTTTT,,.....---......3...T~~~X-------.v.....,z....%%%%%%%%#%%%%%%#%%%%%
T.,1....~~~~~~~[~~~~~~~~~..1..TTTTTTTT.....---.-X----------[[--.1...lk..--....TTTTT#####################
T........~~~~~~[~~~~~~~~......TTTTTTTTTT.---....1TTT......~~~1...TT...,..-...TTTTTT#####################
Tt........^..kv_.l....^.....t.TTTTTTTTTT.-....T.TTTTTTTTT~~~T..TTTT.,.T.,-2TTTTTTTT#####################
T..Hxx........._.k......Hxx...TTTTTTTTT..-..TTTTTTTTTTTTT~~...,.......T..-.TTTTTTTT#####################
T..xxx........._........xxx...TTTTT..,...-.TTTTTTTTTTTTT~~~..,.....s3.T..-.TTTTTTTT#####################
T..xxx.......t._..w...t.xxx...TT.........-.TTTTTTTTTTTT~~~.2........,TTT.-.TTTTTTTT#####################
T..._........n._..,.,..,._.,..TT....q....-..TTTTTTTTTTT~~.....2.N..,TTTT.-.TTTTTTTT#####################
T..._.........._...v....._..q..........s.-2TTTTTTTTTTT~~~T..1..,...TTTTT.-2.TTTTTTT#####################
______________________________.-----------,TTTTTTTTTTT~~TTTTTTTTTTTTTTTT.--.TTTTTTT#####################
T.......,.._..._....._...,......,...,--,...TTTTTTTTTTT~~~~~~~~~~~~TTTTTTT%-%%%TTTTT#####################
Tt.,.....Rxxx.._...Wxxx.......TT......---.1TTTTTTTTTTT~~~~~~~~~~~~~TTTT%%%--%%%TTTT#####################
T.....t.,xxxx,._...xxxx.......TTT.,.....-.TTTTTTTTTTTTTTTT~~~~~~~~~^TT%%r%%%%X%%TTT#####################
T........xxxx.._...xxxx.....t.TTTTT.T..2-.TTTTTTTTTTTTTTTT~~~~~~~~~TT%%%%%X%%%r%%TT#####################
T.............._..............TTTTTTTT..-.2..TTTTTTTT.,TT^~~~~~~~~~^..%%%%%%X%%%%%T#####################
T.fff-fff......_...7..7..7....TTTTTTTT,.--...3.TTTT........~~~~~~[----%r%%%%%%%%%TT#####################
T.f55555f......_t.....,.......TTTTTTTT...-......................--..1.%%%%%X%%%%%TT#####################
T.f55555f.v...._..............TTTTTTTT...--..--------------------.1..TT%%%%%r%%%TTT#####################
T.f55555f....t._..,7..7..7....TTTTTTT..,..-N....3......N........TTTTTTTTT%T%%%TTTTT#####################
T.f55555f......_.............tTTTTTTTTT...-,..TTTTT.T......TTTTTTTTTTTTTTTTTTTTTTTT#####################
T.fffffff......_q.............TTTTTTTTT...-.1.TTTTTTTTT.TTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
T,..........,.._..............TTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
Tt.....t.....t._.t....t......tTTTTTTTTTTT...TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
T.............._..............TTTTTTT.T.T...TTTTTTTTTTTTTTT%TTTTTTTTTTTTT..Hxx.TTTT#####################
T.Rxxx...Uxxx.._..Wxxx..y.y.y.TTTT..........TTTTTTTTTTTT%%%%%%TTTTTTTTTT.k.xxx...TT#####################
T.xxxx...xxxx.._..xxxx.ffffff.TTTT..Hxx.kk..TTTTTTTTTT%%%r%%%%%TTTTTTTT....xxb.l.TT#####################
T.xxxx...xxxx.._..xxxx........TTTn..xxx.l.m.TTTTTTTTTT%%%%%%%%%TTTTTTTTT....-..z.TT#########G###########
T..._......_..._...._.........TT....xxxs.....TTTTTTTTTT%zs%r%%%.TTTTTTTTT...-...TTT#::::::::::::::::####
T.__________________________..TT..z..---..r.TTTTTTTTTT.%%%%%%....TTTTTTTT...-TTTTTT#::::::::::::::::####
T.n,..........._..............TTTT.....-....TTTTTTTTT....%TTT.....TTTTTTT...-TTTTTT#::::::::::::::::####
Tt.....t......._.......t....t.TTTTT....-..TTT.TT.TTTT..b.TTTTT.....T........-TTTTTT#:::#::::::::#:::####
Tk...q...LkJxxg+gJxxlL........TTTTTTTT.-.................TTTTTT.......kkl...-..TTTT#::::::::::::::::####
T........===v==+==v===...v.t.,TTTTTTTTT-......Hxx.......TTTTTTTTo...j.......-r...TT#::::::::::::::::####
Tt..,w...=C=+++++++=0=..t.....TTTTTTT,.--..j..xxx.l....TTTTT......z.......s.-...TTT#::::::::::::::::####
T........===+++++++===.................o--...hxxx.k.T.........------..a....--...TTT#::::::::::::::::####
T.....v..g==++Fxx++==g......q............-..s..-.......--------.b..---------.......:::::::::::::::::####
_________+++++xxx+++++________.----------......-...-----.......TTTTT.......----s---:::::::::B:::::::####
T........g==+++++++==g.....v........T...------------.......TTTTTTTTTTT....TT.......:::::::::::::::::####
T........=v=+++++v+===.............n.........,.......r.T.TTTTTTTTTTTTT....TTTTTTT..:::::::::::::::::####
T.fff-ff.==@x==P==8===........TTTTTTT.T..T.....,.s.....T.TTTHxxTTTTTTT.....VxxTTTTT#::::::::::::::::####
T.fppppf.====q=+======.t...,..TTTTTTTT......o......,..TTTTTTxxxTTTTTT......xxxTTTTT#::::::::::::::::####
T.fppppf.L====g+g====L....t...TTTTTTT..............TTTTTTTT.xxx.lT.........xxxTTTTT#::::::::::::::::####
Ttfppppf,....n._..............TTTTTTT....TT.T.T....TTTTTT.k..-..k....r.~~~~~~~~TTTT#::::::::::::::::####
T.fff-ff......._...........,t.TTTTTT.-...TTTTTT..%%TTTTTT....-.....b...~~~~~~~~TTTT#:::#::::::::#:::####
T.............._q.,...........TTTTfff-fffTTTTT%%%%%%%%T....---...h.....~~~~~~~~TTTT#::::::::::::::::####
T.Mxx....ffffff_ffffff..Rxxx..TTTTfp-p-pfTTTT%%%r%%z%%%.--o-..a....T..n~~~~~~~~TTTT#::::::::::::::::####
T.xxx.t..f....,......f.,xxxx..TTTTfp-s-pfTTTT%%%%%%%%%%..........nTTTTTTTTTTTTTTTTT#::::::::::::::::####
T.xxx...tf...........ft.xxxx..TTTTfp-p-pfTTTTT%%%%s%r%%...T......TTTTTTTTTTTTTTTTTT#####################
T.._.....f..d.....d..f...._...TTTTfffffffTTTTTT%%%%%%%%TTTTTTT...TTTTTTTTTTTTTTTTTT#####################
Tt._.....f.....D.....f...._.t.TTTTTTTTTTTTTTTTTTTT%%%TTTTTTTTT...TTTTTTTTTTTTTTTTTT#####################
T..______f...........f_______.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTTTTTTTTTTTTT#####################
T........fffffffffffff......_.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTTTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTTTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT#####################
Tt.........................._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT#####################
T.ffffffffffff.......&xxx..q_.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT#####################
T.f4444444444f..!xx..xxxx..._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTT..Hxx.TTTT#####################
T.f4444444444f..xxx..xxxx..._tTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTT..xxx..TTT#####################
T.f4444444444f..xxx...__...._.TTTTTTTTTTTTTTTTTTTTTT.TTTT3.T.T.-.TTTTTTT...xxx...TT#####################
T.f4444)44444f.2.,...._______.TTTTTTTTTTTTTTTT...TTT..T.......--.*TTTTTT.......k..T#####################
T.f4444444444f.(...(........_.TTTTTTTTTTTTTTT^^3..1.,.*3..3..b-....TT.T..j....3l.TT#####################
T.f4444444444f......(....(.._.TTTTTTTTTTT~~~~~~~.............-....3....---v-....TTT#####################
T.f4444444444f............(._tTTTTTTTTTTT~~~~~~~.............-^^^..s...-......TTTTT#####################
T.ffffff-fffff.......,......_.TTTTTTTT.T.~~~~~~~.....3...~~~~~~~~~.....-,..T.TTTTTT#####################
T.,........................._.TTTTTTT2.T^~~~~~~~^..,....^~~~~~~~~~....--T1TTTTTTTTT#####################
T.........v....t.....,..w..._.TTTTTT.*.....3^....--------[[[[[[[[[-----..TTTTTTTTTT#####################
Tt..............v..........._qTT...q.........s.---,..3..^~~~~~~~~~--..N...T..TTTTTT#####################
T.,...,............,...,...._,......,......-----........^~~~~~~~~~^-..........TTTTT#####################
_______________________________-------------2,.---...s...^^..^..^^.---.....b..TTTTT#####################
T...._........_..._.....v.......3.............32.-...................-........TTTTT#####################
T...._........_..,_...........TT...2....2....*...---2..N....3........--......T..TTT#####################
T.fff-ffff.fff-fff_.7..7..7...TTTTTT.T...s........^-^^.....s.......^~~[[~~3.....TTT#####################
T.f555555f.f66666f_...........TTTTTTTT,...,....^~~~[~~~~..3........^~~~[[[-.....TTT#####################
T2f555555f.f66666f_..........tTTTTTTT..^.^......~~~[~~~~............[[[[[[-......TT#####################
T.f555)55f.f66666f_...........TTTTTTTT~~~~~.....~~~[~~~~..*.3......^~~~~~~......TTT#####################
Ttf555555f.f66666f_.7..7..7...TTTTTTTT~~~~~.....~~~[~~~~.........^..~~~~~~.....1TTT#####################
T.ffffffff.fffffff_...........TTTTTTTT~~~~~^.....^.-^^^......~~~~~~^,.TTTTTTTTTTTTT#####################
T................._...........TTTTTTTT~~~~~T....,..-.......3^~~~~~~..TTTTTTTTTTTTTT#####################
T................._.....,.,...TTTTTTTTTTT.^....T.b.-------...~~~~~~T.TTTTTTTTTTTTTT#####################
T.Rxxx.,,.Mxx...,._..7..7..7..TTTTTTTTTTTT.TTT.T..T.T.TT.T...~~~~~~TTTTTTTTTTTTTTTT#####################
T.xxxx....xxx.t.,._...........TTTTTTTTTTTTTTTTTTT.TTT2.T..TTTTTTTTTTTTTTTTTTTTTTTTT#####################
T.xxxx....xxx....._...........TTTTTTTTTTTTTTTTTTTTTTTTTTT..TTTTTTTTTTTTTTTTTTTTTTTT#####################
T..._......_......_...t......tTTTTTTTTTTTTTTTTTTTTTTTTTTT-.TTTTTTTTTTTTTTTTTTTTTTTT#####################
T..._______________...........TTTTTTTTTTTTTTTTTTTTTTTTTTT-.TTTTTTTTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTTTTTT_TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT-.TTTTTTTTTTTTTTTTTTTTTTTT#####################
"""

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const ENEMY_SCENES := {
	"s": preload("res://scenes/enemies/slime.tscn"),
	"d": preload("res://scenes/enemies/dummy.tscn"),
	"D": preload("res://scenes/enemies/dummy.tscn"),
	"b": preload("res://scenes/enemies/bat.tscn"),
	"a": preload("res://scenes/enemies/archer.tscn"),
	"B": preload("res://scenes/enemies/boss.tscn"),
	"}": preload("res://scenes/enemies/lich.tscn"),   # Boss hầm ngục (tầng 5)
	"X": preload("res://scenes/enemies/wolf.tscn"),
	"N": preload("res://scenes/enemies/boar.tscn"),
	"ú": preload("res://scenes/enemies/crab.tscn"),       # cua (bờ biển)
	"ạ": preload("res://scenes/enemies/scorpion.tscn"),   # bọ cạp (sa mạc)
}
const ITEM_KINDS := {
	"h": Pickup.Kind.POTION_HP,
	"m": Pickup.Kind.POTION_MP,
	"c": Pickup.Kind.POWER_CRYSTAL,
}
const ITEM_VALUES := { "h": 25, "m": 15, "c": 3 }

const TEX := {
	"grass": preload("res://assets/town/grass.png"),
	"grass_tuft": preload("res://assets/town/grass_tuft.png"),
	"grass_flower": preload("res://assets/town/grass_flower.png"),
	"path": preload("res://assets/town/path_stone.png"),
	"fence_l": preload("res://assets/town/fence_l.png"),
	"fence_m": preload("res://assets/town/fence_m.png"),
	"fence_r": preload("res://assets/town/fence_r.png"),
	"well": preload("res://assets/town/well.png"),
	"sign": preload("res://assets/town/sign.png"),
	"beehive": preload("res://assets/town/beehive.png"),
	"mushroom": preload("res://assets/town/mushroom.png"),
	"house_R": preload("res://assets/town/house_red.png"),
	"house_U": preload("res://assets/town/house_blue.png"),
	"house_W": preload("res://assets/town/house_blue_wood.png"),
	"house_M": preload("res://assets/town/house_small.png"),
	"stone": preload("res://assets/tiles/stone_floor.png"),
	"stone2": preload("res://assets/tiles/stone_floor2.png"),
	"ruin": preload("res://assets/tiles/ruin_floor.png"),
	"ruin2": preload("res://assets/tiles/ruin_floor2.png"),
	"wall_top": preload("res://assets/tiles/wall_top.png"),
	"wall_face": preload("res://assets/tiles/wall_face.png"),
	"gate": preload("res://assets/tiles/gate.png"),
	"altar": preload("res://assets/tiles/altar.png"),
	"bush": preload("res://assets/decor/bush.png"),
	"rock": preload("res://assets/decor/rock.png"),
	"water_tl": preload("res://assets/tiles/water_tl.png"),
	"water_t": preload("res://assets/tiles/water_t.png"),
	"water_tr": preload("res://assets/tiles/water_tr.png"),
	"water_l": preload("res://assets/tiles/water_l.png"),
	"water_c": preload("res://assets/tiles/water_c.png"),
	"water_r": preload("res://assets/tiles/water_r.png"),
	"water_bl": preload("res://assets/tiles/water_bl.png"),
	"water_b": preload("res://assets/tiles/water_b.png"),
	"water_br": preload("res://assets/tiles/water_br.png"),
}
## Cây rừng: 3 cây tán tròn rồi 2 cây thông
const FOREST_TREES := [
	preload("res://assets/forest/tree_1.png"),
	preload("res://assets/forest/tree_2.png"),
	preload("res://assets/forest/tree_3.png"),
	preload("res://assets/forest/tree_4.png"),
	preload("res://assets/forest/tree_5.png"),
]
const FOREST_FLOOR := [
	preload("res://assets/forest/forest_floor_1.png"),
	preload("res://assets/forest/forest_floor_2.png"),
	preload("res://assets/forest/forest_floor_3.png"),
]
const FOREST_TEX := {
	"tree_shadow": preload("res://assets/forest/tree_shadow.png"),
	"small_shadow": preload("res://assets/forest/small_shadow.png"),
	"cabin_grey": preload("res://assets/forest/cabin_grey.png"),
	"cabin_red": preload("res://assets/forest/cabin_red.png"),
	"waterfall": preload("res://assets/forest/waterfall.png"),
	"crate": preload("res://assets/forest/crate.png"),
	"barrel": preload("res://assets/forest/barrel.png"),
	"barrel2": preload("res://assets/forest/barrel2.png"),
	"campfire": preload("res://assets/forest/campfire.png"),
	"stump": preload("res://assets/forest/stump.png"),
	"stump_axe": preload("res://assets/forest/stump_axe.png"),
	"rock_moss": preload("res://assets/forest/rock_moss.png"),
	"rock_grey_moss": preload("res://assets/forest/rock_grey_moss.png"),
	"berry_bush": preload("res://assets/forest/berry_bush.png"),
	"sprout": preload("res://assets/forest/sprout.png"),
	"fence_v_top": preload("res://assets/forest/fence_v_top.png"),
	"fence_v_mid": preload("res://assets/forest/fence_v_mid.png"),
	"fence_v_bottom": preload("res://assets/forest/fence_v_bottom.png"),
}
const DEEP_TREE_COLOR := Color(0.68, 0.78, 0.72)  # cây sâu trong rừng tối hơn cây ở bìa rừng

## Hầm ngục (hình do Claude vẽ)
const DUNGEON_TEX := {
	"wall_face": [preload("res://assets/dungeon/wall_face_1.png"), preload("res://assets/dungeon/wall_face_2.png")],
	"wall_top": [preload("res://assets/dungeon/wall_top_1.png"), preload("res://assets/dungeon/wall_top_2.png")],
	"slabs": [
		preload("res://assets/dungeon/floor_slab_0.png"), preload("res://assets/dungeon/floor_slab_1.png"),
		preload("res://assets/dungeon/floor_slab_2.png"), preload("res://assets/dungeon/floor_slab_3.png"),
	],
	"wall_shadow": preload("res://assets/dungeon/wall_shadow.png"),
	"candles": [preload("res://assets/dungeon/candles_1.png"), preload("res://assets/dungeon/candles_2.png"),
		preload("res://assets/dungeon/candles_3.png")],
	"candelabra": preload("res://assets/dungeon/candelabra.png"),
	"brazier": preload("res://assets/dungeon/brazier.png"),
	"banner": preload("res://assets/dungeon/banner.png"),
	"pots": [preload("res://assets/dungeon/pot_1.png"), preload("res://assets/dungeon/pot_2.png")],
	"stone_block": preload("res://assets/dungeon/stone_block.png"),
	"bones": preload("res://assets/dungeon/bones.png"),
	"pedestal": preload("res://assets/dungeon/pedestal.png"),
	"light_beam": preload("res://assets/dungeon/light_beam.png"),
	"portal_ring": preload("res://assets/dungeon/portal_ring.png"),
	"portal_swirl": preload("res://assets/dungeon/portal_swirl.png"),
	"stairs_down": preload("res://assets/dungeon/stairs_down.png"),
	"rune": preload("res://assets/dungeon/rune.png"),
}
const TRAP_SCRIPT := preload("res://scripts/dungeon_trap.gd")
const RUNE_LIGHT := Color(0.5, 1.0, 0.95)
const WALL_CHARS := "#YZ"                          # các ô tường (đuốc, cờ cũng nằm trên tường)
const CANDLE_LIGHT := Color(1.0, 0.75, 0.45)
const MAGIC_LIGHT := Color(0.75, 0.45, 1.0)
const VILLAGE_TREES := [
	preload("res://assets/town/tree_green.png"),
	preload("res://assets/town/tree_orange.png"),
	preload("res://assets/town/bush.png"),
]

## Quảng trường (hình do Claude vẽ theo bảng màu Tiny Town)
const PLAZA_TEX := {
	"mosaic": preload("res://assets/plaza/plaza_mosaic.png"),
	"alt": preload("res://assets/plaza/plaza_alt.png"),
	"fountain": preload("res://assets/plaza/fountain.png"),
	"bench": preload("res://assets/plaza/bench.png"),
	"lamp": preload("res://assets/plaza/lamp.png"),
	"stalls": [
		preload("res://assets/plaza/stall_fruit.png"),
		preload("res://assets/plaza/stall_bread.png"),
		preload("res://assets/plaza/stall_potion.png"),
	],
	"planters": [
		preload("res://assets/plaza/planter_pink.png"),
		preload("res://assets/plaza/planter_yellow.png"),
	],
}
const PLAZA_CHARS := "=+FxeLJgvPqklC@08"   # các ô thuộc quảng trường (nền đá)
const NPC_SCRIPT := preload("res://scripts/npc.gd")
const HARVEST_SCRIPT := preload("res://scripts/harvestable.gd")
const CRITTER_SCRIPT := preload("res://scripts/critter.gd")

## Hệ sinh thái: cây đầm lầy, đồ trang trí hồ / ruộng (hình do Claude vẽ)
const ECO_TEX := {
	"willows": [preload("res://assets/eco/willow_1.png"), preload("res://assets/eco/willow_2.png")],
	"dead_tree": preload("res://assets/eco/dead_tree.png"),
	"giant_mushrooms": [preload("res://assets/eco/giant_mushroom_1.png"), preload("res://assets/eco/giant_mushroom_2.png")],
	"lilies": [preload("res://assets/eco/lily_1.png"), preload("res://assets/eco/lily_2.png")],
	"reeds": preload("res://assets/eco/reeds.png"),
	"dock": preload("res://assets/eco/dock.png"),
	"boat": preload("res://assets/eco/boat.png"),
	"windmill_body": preload("res://assets/eco/windmill_body.png"),
	"windmill_blades": preload("res://assets/eco/windmill_blades.png"),
	"barn": preload("res://assets/eco/barn.png"),
	"scarecrow": preload("res://assets/eco/scarecrow.png"),
	"hay_bale": preload("res://assets/eco/hay_bale.png"),
	"furrows": preload("res://assets/eco/furrows.png"),
}

## Cây thu hoạch. item: tên vật phẩm trong scripts/items.gd. frames: số giai đoạn lớn (khung cuối = chín).
## grow: số giây từ lúc hái tới lúc chín lại. amount: hái được bao nhiêu [ít nhất, nhiều nhất].
## reach: đứng gần bao nhiêu pixel thì hái. start_ripe: tỉ lệ cây đã chín lúc vào game.
const HARVEST := {
	"1": { "item": "berry", "tex": preload("res://assets/eco/berry_bush.png"), "frames": 2, "grow": 50.0,
		"amount": [2, 3], "reach": 22.0 },
	"2": { "item": "herb", "tex": preload("res://assets/eco/herb.png"), "frames": 2, "grow": 60.0,
		"amount": [1, 2], "reach": 14.0 },
	"3": { "item": "mushroom", "tex": preload("res://assets/eco/mushroom_wild.png"), "frames": 2, "grow": 55.0,
		"amount": [1, 2], "reach": 14.0 },
	"4": { "item": "wheat", "tex": preload("res://assets/eco/wheat.png"), "frames": 3, "grow": 45.0,
		"amount": [1, 2], "reach": 12.0, "start_ripe": 0.7 },
	"5": { "item": "carrot", "tex": preload("res://assets/eco/carrot.png"), "frames": 3, "grow": 40.0,
		"amount": [1, 1], "reach": 12.0, "start_ripe": 0.7 },
	"6": { "item": "pumpkin", "tex": preload("res://assets/eco/pumpkin.png"), "frames": 3, "grow": 70.0,
		"amount": [1, 1], "reach": 12.0, "start_ripe": 0.7 },
	"7": { "item": "apple", "tex": preload("res://assets/eco/apple_tree.png"), "frames": 2, "grow": 80.0,
		"amount": [2, 3], "reach": 24.0, "tree": true },
}
## Chế tạo: nồi luyện thuốc, bàn chế tạo, xô nước cạnh giếng
const CRAFT_TEX := {
	"anvil": preload("res://assets/craft/anvil.png"),
	"cauldron": preload("res://assets/craft/cauldron.png"),
	"workbench": preload("res://assets/craft/workbench.png"),
	"fire_pit": preload("res://assets/craft/fire_pit.png"),
	"oven": preload("res://assets/craft/oven.png"),
	"shipyard": preload("res://assets/coast/shipyard.png"),
}
## Gốc cây 'z': có Rìu trong túi thì đi tới là chặt được gỗ, một lúc sau lại có gỗ
const STUMP_WOOD := { "item": "wood", "tex": preload("res://assets/craft/stump_wood.png"), "frames": 2, "grow": 45.0,
	"amount": [1, 2], "reach": 18.0, "tree": true, "tool": "axe" }
## Hang động vào hầm ngục
const CAVE_TEX := {
	"mouth": preload("res://assets/cave/cave_mouth.png"),
	"seal": preload("res://assets/cave/cave_seal.png"),
	"exit": preload("res://assets/cave/cave_exit.png"),
}
## Chỗ câu cá 'á' (nước gợn sóng): có Cần câu trong túi thì đứng gần là câu được. loot: đồ câu được
## [tên vật phẩm, độ hay gặp, ít nhất, nhiều nhất]. Câu xong một lúc cá lại tới.
const FISHING := { "item": "fish", "tex": preload("res://assets/coast/fish_spot.png"), "frames": 2, "grow": 35.0,
	"amount": [1, 1], "reach": 26.0, "tool": "fishing_rod", "ripple": true,
	"loot": [["fish", 60, 1, 2], ["shrimp", 25, 1, 3], ["big_fish", 12, 1, 1], ["pearl", 3, 1, 1]] }
const WELL_BUCKET := { "item": "water", "tex": preload("res://assets/craft/bucket.png"), "frames": 2, "grow": 20.0,
	"amount": [1, 2], "reach": 18.0, "tree": true }
const STATION_RANGE := 30.0   # đứng gần trạm chế tạo bao nhiêu pixel thì mở bảng chế tạo
## Sói, heo rừng bị hạ sẽ quay lại chỗ cũ sau bấy nhiêu giây (khi người chơi không đứng gần)
const ENEMY_RESPAWN := 120.0   # quái thường hồi sinh sau bao nhiêu giây (Boss và bù nhìn thì không)
## Cấp Boss: [cấp hiện trên đầu, cấp gốc của chỉ số trong file cảnh]. Gorrak giữ nguyên sức mạnh,
## Malakar mạnh hơn bản gốc 8 cấp cho xứng với quái tầng 5. Quái thường: cấp theo "enemy_level" của khu vực
## (AREAS trong scripts/world_map.gd) hoặc "level" của tầng hầm ngục (scripts/dungeon.gd).
const BOSS_LEVELS := { "B": [10, 10], "}": [30, 22] }
const WATER_CHARS := "~[$á"   # các ô có nước bên dưới (cầu gỗ, thuyền, chỗ câu cá nằm trên nước)
## Nước chặn người đi bộ nhưng thuyền đi được (lớp va chạm riêng WATER_LAYER, đạn bay qua được)
const WATER_SOLID := "~$á"
const WATER_LAYER := 8
const CROP_CHARS := "456"     # cây trồng trên ruộng (có đất cày)

const SOLID := "T#orxRUWMfwqytHVklzjYZIuKFeLJg17*!&)(C@08|?ê"   # | dung nham, ? bia cổ ngữ (hầm ngục)
const HOUSE_WIDTH := { "R": 4, "U": 4, "W": 4, "M": 3 }

# ---- Thế giới lớn
const CHUNK := 16                       # mặt đất, cây cối vẽ theo từng mảnh 16 x 16 ô
const CHUNK_KEEP := Vector2i(2, 2)      # giữ các mảnh trong khoảng này quanh người chơi (số mảnh)
const CHUNK_DROP := Vector2i(4, 3)      # mảnh xa hơn khoảng này thì xoá cho nhẹ máy
const SLEEP_DISTANCE := 760.0           # quái, thú, cây thu hoạch xa hơn (pixel) thì tạm ngủ
const FOG_RADIUS := 13                  # đi tới đâu mở bản đồ tới đó: bán kính (ô) quanh người chơi
const OLD_OVERWORLD := Vector2i(104, 96)   # kích thước thế giới trước khi mở rộng (để đổi chỗ đứng trong save cũ)
const MAP_VERSION := 2

var rows: PackedStringArray
var map_size := Vector2i.ZERO
var gate_column := -1
var arena_column := -1      # cột đầu tiên của đấu trường (ô ':' đầu tiên)
var altar_position := Vector2.INF
var rng := RandomNumberGenerator.new()

var player: Player
var entities: Node2D
var gate_body: StaticBody2D
var gate_sprites: Array[Sprite2D] = []
var gate_open := false
var signs: Array[Dictionary] = []  # { "pos": Vector2, "text": String, "near": bool }
var entered_area2 := false
var entered_arena := false
var won := false
var astar := AStarGrid2D.new()   # lưới tìm đường cho điều khiển bằng chuột
var shadows: Node2D              # bóng cây, bóng đồ vật (nằm trên mặt đất, dưới nhân vật)
var dirt_tiles: Array[Texture2D] = []    # đường đất: 16 kiểu mép tùy ô bên cạnh
var rocky_tiles: Array[Texture2D] = []   # bãi đất đá
var shade_tiles := {}                    # viền tối trên cỏ sát bìa rừng
var waterfalls: Array[Sprite2D] = []
var anim_time := 0.0
var cabin_count := 0
var plaza_cells := {}                    # Vector2i -> true: các ô có nền đá quảng trường
var plaza_tiles: Array[Texture2D] = []   # 16 kiểu viền sân đá
var village_anims: Array[Dictionary] = []    # đài phun nước, cột đèn (luôn chuyển động)
var stall_count := 0
var npc_count := 0
var _core_npcs := 0
var _core_signs := 0
var tile_tint := Color.WHITE             # màu phủ lên ô đất đang vẽ (theo kiểu cảnh)
var area_started := false
var current_area := -1
var visited_areas := {}
var windmill_blades: Array[Sprite2D] = []
var stations: Array[Dictionary] = []     # { "pos": Vector2, "kind": "pot" / "bench" / "fire" / "stove" }
var current_station := ""
var dungeon_column := -1                 # hầm ngục (các tầng) ở bên phải cột này
var overworld_size := Vector2i.ZERO      # kích thước thế giới bên ngoài (ô)
var floor_rects: Array[Rect2i] = []      # vị trí từng tầng hầm ngục trong màn chơi (ô)
var current_floor := 0                   # 0 = thế giới bên ngoài, 1..5 = tầng hầm ngục
var visited_floors := {}
var stairs: Array[Dictionary] = []       # { "pos", "kind": "exit"/"up"/"down", "floor", "sealed", "seal" }
var runes: Array[Dictionary] = []        # bia cổ ngữ { "sprite", "pos", "floor", "lit" }
var poison_textures: Array[Texture2D] = []
var lava_textures: Array[Texture2D] = []
var lava_material: CanvasItemMaterial    # dung nham tự phát sáng trong bóng tối
var lava_layer: Node2D
var poison_timer := 0.0
var seal_msg_cd := 0.0
var portal_open := true                  # cổng xoáy cuối hầm ngục: chỉ mở khi hạ Boss hầm ngục
var portal_ring: Sprite2D
var chests: Array = []                   # rương báu trong hầm ngục (scripts/chest.gd)
var floor_alive := {}                    # tầng -> số quái ban đầu còn sống (hạ hết thì rương mở khoá)
var floor_cleared := {}                  # tầng -> true khi đã dọn sạch quái
var cave_entrance := Vector2.INF         # ô miệng hang (ngoài trời)
var cave_exit := Vector2.INF             # ô lối ra (trong hầm)
var cave_busy := false                   # đang chuyển cảnh qua hang
var fade_rect: ColorRect                 # màn đen khi chuyển cảnh

# --- Hầm ngục: bóng tối và ánh sáng
var darkness: CanvasModulate          # làm tối cả màn hình khi vào hầm ngục
var dungeon_lights: Node2D            # chứa các đèn (chỉ bật khi ở trong hầm)
var light_texture: GradientTexture2D  # hình tròn mờ dùng cho mọi đèn
var flicker_lights: Array[Dictionary] = []   # { "light": PointLight2D, "energy": float, "phase": float }
var anim_sprites: Array[Dictionary] = []     # { "sprite": Sprite2D, "fps": float, "phase": float }
var portal_swirls: Array[Sprite2D] = []
var light_beams: Array[Sprite2D] = []
var slab_tiles: Array[AtlasTexture] = []     # 4 kiểu phiến đá x 4 góc
var player_light: PointLight2D
var in_dungeon := false
# Lưu tài khoản (xem get_save_data / apply_save_data ở cuối file)
var loaded_save := false                 # vào game từ tài khoản đã chơi (không hiện lời chào người mới)
var placed_fires: Array = []             # chỗ người chơi đã đặt bếp lửa (lưu lại, vào game lại vẫn còn)
var save_pos := Vector2.INF              # chỗ đứng an toàn gần nhất để lưu (không lưu lúc đang đi qua hang)
var save_floor := 0
# Thế giới lớn: vẽ theo mảnh, quái ở xa ngủ, bản đồ khám phá dần
var arena_rect := Rect2i()               # khung đấu trường (theo ô)
var gate_cells: Array[Vector2i] = []
var ground_root: Node2D                  # ảnh mặt đất của từng mảnh
var chunks := {}                         # Vector2i -> { "ground", "props", "shadows", "anims", "blades", "falls" }
var chunk_queue: Array[Vector2i] = []
var last_chunk := Vector2i(-999, -999)
var image_cache := {}                    # Texture2D -> { Color: Image } (ảnh đã tô màu, dùng để vẽ mảnh)
var ground_sets := {}                    # "sand" -> [Texture2D, ...]
var water_sets := {}                     # "sand" -> { "t": Texture2D, ... } bờ nước theo mặt đất
var grass_sand_tiles: Array[Texture2D] = []
var solid_rects: Array[Rect2i] = []
var water_rects: Array[Rect2i] = []
var variant_index := {}                  # Vector2i -> int: kiểu sạp hàng / nhà gỗ theo thứ tự xuất hiện
var extra_props := {}                    # Vector2i -> Texture2D: đồ đặt cạnh dân làng (cái đe)
var astar_boat := AStarGrid2D.new()      # lưới tìm đường khi có thuyền (nước đi được)
var _query_boat := false
var sleepers: Array = []                 # quái, thú, cây thu hoạch, rương: ở xa thì tạm ngủ
var sleep_timer := 0.0
var explored := PackedByteArray()        # mỗi ô thế giới bên ngoài 1 byte: 1 = đã khám phá
var fog_changes: Array[Vector2i] = []    # các ô vừa mở (bản đồ nhỏ tô lại)
var fog_cell := Vector2i(-999, -999)
var weather: CPUParticles2D
var weather_kind := "-"
var full_account := false


func _ready() -> void:
	rng.seed = 2026  # cùng một "hạt giống" => hoa / cây luôn mọc ở cùng chỗ
	full_account = bool(Accounts.summary(Game.account_id).get("full", false))
	_parse_map()
	_find_plaza()
	_load_forest_tiles()
	_setup_dungeon_lighting()
	entities = Node2D.new()
	entities.name = "Entities"
	entities.y_sort_enabled = true
	_build_ground()
	shadows = Node2D.new()
	shadows.name = "Shadows"
	shadows.z_index = -8
	add_child(shadows)
	_build_walls()
	_build_pathfinding()
	add_child(entities)  # thêm sau cùng để vẽ đè lên mặt đất
	_spawn_everything()
	explored.resize(overworld_size.x * overworld_size.y)
	if full_account:
		explored.fill(1)   # Tài Khoản Full: mở sẵn cả bản đồ
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 20
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(4000, 4000)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)
	Game.boss_defeated.connect(_on_boss_defeated)
	# Tài khoản đã chơi: nạp lại tiến độ thế giới và chỗ đứng lần trước
	var saved: Dictionary = Game.progress.get("the_gioi", {})
	if Game.progress.has("tien_do"):
		apply_save_data(saved)
	call_deferred("_announce_start")


func _announce_start() -> void:
	if loaded_save:
		Game.area_entered.emit(_current_area_name())
		Game.message.emit("Chào mừng trở lại, %s! Game tự lưu, cứ thế chơi tiếp nhé." % Game.appearance.get("name", ""))
		if gate_open and current_floor == 0:
			Game.message.emit("Cửa hang sau Đấu Trường Đá Cổ đã mở: đi vào để xuống Hầm Ngục Cổ.")
		return
	Game.area_entered.emit("Làng Khởi Nguyên")
	Game.message.emit("Chuột phải để đi / đánh quái, F: lướt. Lên cấp để mở kỹ năng Q W E R (K: xem kỹ năng, Esc: hướng dẫn)")
	Game.message.emit("Đi tới gần dân làng để nghe họ nói chuyện. Luyện tập ở bãi tập rồi lên đường về phía đông!")


func _parse_map() -> void:
	var core_rows := MAP.strip_edges().split("\n")
	for i in core_rows.size():
		core_rows[i] = core_rows[i].strip_edges()
	rows = WorldMap.compose(core_rows)   # bản đồ này nằm giữa thế giới lớn (scripts/world_map.gd)
	overworld_size = WorldMap.SIZE
	_add_dungeon_floors()
	var width := 0
	for r in rows:
		width = maxi(width, r.length())
	map_size = Vector2i(width, rows.size())
	for i in rows.size():
		rows[i] = rows[i].rpad(width, "#")   # ô ngoài lề = đá đặc
	var arena := Rect2i()
	for y in overworld_size.y:
		var gx := rows[y].find("G")
		while gx != -1 and gx < overworld_size.x:
			gate_cells.append(Vector2i(gx, y))
			if gate_column == -1:
				gate_column = gx
			gx = rows[y].find("G", gx + 1)
		var ax := rows[y].find(":")
		while ax != -1 and ax < overworld_size.x:
			arena = Rect2i(ax, y, 1, 1) if arena.size == Vector2i.ZERO else arena.expand(Vector2i(ax, y)).expand(Vector2i(ax + 1, y + 1))
			if arena_column == -1 or ax < arena_column:
				arena_column = ax
			ax = rows[y].find(":", ax + 1)
	arena_rect = arena.grow(1) if arena.size != Vector2i.ZERO else Rect2i()
	if not floor_rects.is_empty():
		dungeon_column = overworld_size.x + int(Dungeon.GAP * 0.5)


## Ghép các tầng hầm ngục (scripts/dungeon.gd) vào bên phải bản đồ thế giới, ngăn cách bằng đá đặc.
## Người chơi không đi bộ sang được, chỉ qua cửa hang và cầu thang.
func _add_dungeon_floors() -> void:
	var start_x := overworld_size.x + Dungeon.GAP
	var x := start_x
	var y := 4
	var row_h := 0
	for i in Dungeon.FLOORS.size():
		var lines: PackedStringArray = (Dungeon.FLOORS[i]["map"] as String).strip_edges().split("\n")
		var w := 0
		for j in lines.size():
			lines[j] = lines[j].strip_edges()
			w = maxi(w, lines[j].length())
		if i > 0 and i % Dungeon.PER_ROW == 0:
			x = start_x
			y += row_h + Dungeon.GAP
			row_h = 0
		floor_rects.append(Rect2i(x, y, w, lines.size()))
		while rows.size() < y + lines.size() + 2:
			rows.append("")
		for j in lines.size():
			var row: String = rows[y + j].rpad(x, "#")
			var rest := row.substr(x + w) if row.length() > x + w else ""
			rows[y + j] = row.substr(0, x) + lines[j].rpad(w, "#") + rest
		x += w + Dungeon.GAP
		row_h = maxi(row_h, lines.size())


## Ô (x, y) thuộc khu nào: 0 = thế giới bên ngoài, 1..5 = tầng hầm ngục, -1 = đá đặc giữa các tầng.
func floor_at(x: int, y: int) -> int:
	if x < overworld_size.x and y < overworld_size.y:
		return 0
	for i in floor_rects.size():
		if floor_rects[i].has_point(Vector2i(x, y)):
			return i + 1
	return -1


func floor_of(world_pos: Vector2) -> int:
	var c := _to_cell(to_local(world_pos))
	return floor_at(c.x, c.y)


## Khung (theo ô) của khu: 0 = thế giới bên ngoài, 1..5 = tầng hầm ngục.
func region_rect(index: int) -> Rect2i:
	if index <= 0 or index > floor_rects.size():
		return Rect2i(Vector2i.ZERO, overworld_size)
	return floor_rects[index - 1]


## Khung (pixel, toạ độ thế giới) của khu, dùng làm giới hạn camera.
func region_pixels(index: int) -> Rect2:
	var r := region_rect(index)
	return Rect2(to_global(Vector2(r.position) * TILE), Vector2(r.size) * TILE)


## Ô đá đặc nằm sâu trong lòng đất (8 ô xung quanh đều là tường): không cần vẽ.
func _deep_rock(x: int, y: int) -> bool:
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if not WALL_CHARS.contains(cell(x + dx, y + dy)):
				return false
	return cell(x, y) == "#"


func cell(x: int, y: int) -> String:
	if y < 0 or y >= rows.size() or x < 0 or x >= rows[y].length():
		return "#"
	return rows[y][x]


func _find_plaza() -> void:
	var todo: Array[Vector2i] = []
	var core := WorldMap.CORE
	for y in range(core.position.y, core.end.y):
		for x in range(core.position.x, core.end.x):
			if cell(x, y) == "=" or cell(x, y) == "+":
				plaza_cells[Vector2i(x, y)] = true
				todo.append(Vector2i(x, y))
	while not todo.is_empty():
		var c: Vector2i = todo.pop_back()
		for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n: Vector2i = c + d
			if not plaza_cells.has(n) and PLAZA_CHARS.contains(cell(n.x, n.y)):
				plaza_cells[n] = true
				todo.append(n)


## Nền đá quảng trường: viền bo theo các ô bên cạnh, chỗ hoa văn thì lát đá vàng.
func _plaza_texture(x: int, y: int) -> Texture2D:
	if _is_mosaic(x, y):
		return PLAZA_TEX["mosaic"]
	var mask := 0
	if plaza_cells.has(Vector2i(x, y - 1)):
		mask |= 1
	if plaza_cells.has(Vector2i(x + 1, y)):
		mask |= 2
	if plaza_cells.has(Vector2i(x, y + 1)):
		mask |= 4
	if plaza_cells.has(Vector2i(x - 1, y)):
		mask |= 8
	if mask == 15 and _rand(x, y, 11) < 0.4:
		return PLAZA_TEX["alt"]
	return plaza_tiles[mask]


## Ô '+' là đá hoa văn. Đồ vật đứng giữa đá hoa văn (người chơi, dân làng...) cũng lát đá hoa văn.
func _is_mosaic(x: int, y: int) -> bool:
	var c := cell(x, y)
	if c == "+":
		return true
	if c == "=":
		return false
	var count := 0
	for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if cell(x + d.x, y + d.y) == "+":
			count += 1
	return count >= 2


func _floor_texture(x: int, y: int) -> Texture2D:
	var c := cell(x, y)
	if WATER_CHARS.contains(c):
		return _water_texture(x, y)
	var in_dungeon_area := dungeon_column != -1 and x > dungeon_column
	if WALL_CHARS.contains(c):
		# Ô tường có ô trống ở dưới thì vẽ mặt tường, còn lại vẽ nóc tường
		var face := not WALL_CHARS.contains(cell(x, y + 1))
		if in_dungeon_area:
			var walls: Array = DUNGEON_TEX["wall_face" if face else "wall_top"]
			return walls[_pick(x, y, 1, walls.size())]
		return TEX["wall_face"] if face else TEX["wall_top"]
	if in_dungeon_area:
		# Hầm ngục: phiến đá lớn 2x2 ô, mỗi khối 2x2 chọn một kiểu phiến
		var block := posmod(floori(x / 2.0) * 7 + floori(y / 2.0) * 13, 4)
		return slab_tiles[block * 4 + posmod(y, 2) * 2 + posmod(x, 2)]
	if arena_rect.has_point(Vector2i(x, y)):
		return TEX["stone2"] if _rand(x, y, 2) < 0.08 else TEX["stone"]   # sàn đá đấu trường
	var ground: String = BIOME_GROUND.get(_biome_at(x, y), "grass")
	if c == "T":
		if ground == "grass":
			return FOREST_FLOOR[_pick(x, y, 3, FOREST_FLOOR.size())]  # nền rừng tối dưới tán cây
		if ground == "snow":
			return _ground_tex("snow_floor", x, y)
		return _ground_tex(ground, x, y)
	if c == "_" and ground == "grass":
		return TEX["path"]
	if ground != "grass":
		return _ground_tex(ground, x, y)
	if c == ",":
		return TEX["grass_flower"]
	var roll := _rand(x, y, 4)
	if roll < 0.025:
		return TEX["grass_flower"]
	return TEX["grass_tuft"] if roll < 0.14 else TEX["grass"]


## Một ô mặt đất của loại kind (cát, tuyết...): kiểu đầu hay gặp nhất, 2 kiểu sau thỉnh thoảng mới có.
func _ground_tex(kind: String, x: int, y: int) -> Texture2D:
	var tiles: Array = ground_sets[kind]
	var r := _rand(x, y, 5)
	if r < 0.7 or tiles.size() == 1:
		return tiles[0]
	return tiles[1] if r < 0.88 or tiles.size() == 2 else tiles[2]


## Số ngẫu nhiên 0..1 cố định cho từng ô (vẽ lại mảnh nào cũng ra y hệt).
func _rand(x: int, y: int, salt: int) -> float:
	var h := (x * 374761393 + y * 668265263 + salt * 982451653) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float((h ^ (h >> 16)) & 0xffff) / 65536.0


func _pick(x: int, y: int, salt: int, count: int) -> int:
	return mini(int(_rand(x, y, salt) * count), count - 1)


func _water_texture(x: int, y: int) -> Texture2D:
	var row := ""
	if not WATER_CHARS.contains(cell(x, y - 1)):
		row = "t"
	elif not WATER_CHARS.contains(cell(x, y + 1)):
		row = "b"
	var col := ""
	if not WATER_CHARS.contains(cell(x - 1, y)):
		col = "l"
	elif not WATER_CHARS.contains(cell(x + 1, y)):
		col = "r"
	var key := row + col
	if key == "":
		if _biome_at(x, y) == "ocean" and _open_sea(x, y):
			return ground_sets["deep"][_pick(x, y, 6, 2)]   # biển sâu: nước đậm hơn
		return TEX["water_c"]
	# Bờ nước theo mặt đất bên cạnh (cỏ, cát, tuyết, đá...)
	var shore := "grass"
	for d in [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]:
		var n := Vector2i(x + d.x, y + d.y)
		if not WATER_CHARS.contains(cell(n.x, n.y)):
			shore = BIOME_GROUND.get(_biome_at(n.x, n.y), "grass")
			break
	if water_sets.has(shore):
		return water_sets[shore][key]
	return TEX["water_" + key]


## Ô biển cách bờ ít nhất 2 ô.
func _open_sea(x: int, y: int) -> bool:
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			var nx := x + dx
			var ny := y + dy
			if nx < 0 or ny < 0 or nx >= overworld_size.x or ny >= overworld_size.y:
				continue
			if not WATER_CHARS.contains(rows[ny][nx]):
				return false
	return true


func _load_forest_tiles() -> void:
	for mask in 16:
		dirt_tiles.append(load("res://assets/forest/dirt_%d.png" % mask))
		rocky_tiles.append(load("res://assets/forest/rocky_%d.png" % mask))
		plaza_tiles.append(load("res://assets/plaza/plaza_%d.png" % mask))
		grass_sand_tiles.append(load("res://assets/coast/grass_sand_%d.png" % mask))
	for side in ["n", "e", "s", "w", "ne", "nw", "se", "sw"]:
		shade_tiles[side] = load("res://assets/forest/shade_%s.png" % side)
	for mask in 16:
		poison_textures.append(load("res://assets/dungeon/poison_%d.png" % mask))
		lava_textures.append(load("res://assets/dungeon/lava_%d.png" % mask))
	# Mặt đất các vùng mới
	var grounds := { "sand": "coast/sand_%d", "snow": "biomes/snow_%d", "snow_floor": "biomes/snow_floor_%d",
		"red": "biomes/red_sand_%d", "stone": "biomes/stone_%d", "myc": "biomes/mycelium_%d" }
	for kind in grounds:
		var tiles: Array[Texture2D] = []
		for i in range(1, 4):
			tiles.append(load("res://assets/%s.png" % (grounds[kind] % i)))
		ground_sets[kind] = tiles
	ground_sets["deep"] = [load("res://assets/coast/water_deep_1.png"), load("res://assets/coast/water_deep_2.png")]
	var shores := { "sand": "coast/water_sand_%s", "snow": "biomes/water_snow_%s", "red": "biomes/water_red_%s",
		"stone": "biomes/water_stone_%s", "myc": "biomes/water_myc_%s" }
	for kind in shores:
		var edges := {}
		for key in ["tl", "t", "tr", "l", "r", "bl", "b", "br"]:
			edges[key] = load("res://assets/%s.png" % (shores[kind] % key))
		water_sets[kind] = edges


func _build_ground() -> void:
	ground_root = Node2D.new()
	ground_root.name = "Ground"
	ground_root.z_index = -10
	add_child(ground_root)
	var detail := Node2D.new()  # đường đất, bãi đá, viền tối... vẽ đè lên cỏ (hầm ngục)
	detail.name = "GroundDetail"
	detail.z_index = -9
	add_child(detail)
	# Hầm ngục: nền đen phía sau mỗi tầng (chỗ đá đặc không vẽ), dung nham tự phát sáng
	for r in floor_rects:
		var back := ColorRect.new()
		back.color = Color.BLACK
		back.position = Vector2(r.position) * TILE
		back.size = Vector2(r.size) * TILE
		back.z_index = -11
		back.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(back)
	lava_material = CanvasItemMaterial.new()
	lava_material.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	lava_layer = Node2D.new()
	lava_layer.name = "Lava"
	lava_layer.z_index = -9
	add_child(lava_layer)
	var pulse := lava_layer.create_tween().set_loops()
	pulse.tween_property(lava_layer, "modulate", Color(0.82, 0.78, 0.74), 1.3).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(lava_layer, "modulate", Color.WHITE, 1.3).set_trans(Tween.TRANS_SINE)
	# Thế giới bên ngoài vẽ theo từng mảnh quanh người chơi (_update_chunks). Ở đây chỉ vẽ các tầng hầm ngục.
	for fi in floor_rects.size():
		var fr: Rect2i = floor_rects[fi]
		var fl := fi + 1
		for y in range(fr.position.y, fr.end.y):
			for x in range(fr.position.x, fr.end.x):
				if _deep_rock(x, y):
					continue   # đá đặc trong lòng tầng: để nền đen
				var c := cell(x, y)
				tile_tint = Dungeon.FLOORS[fl - 1]["tint"]
				_add_tile_sprite(ground_root, _floor_texture(x, y), x, y)
				if c == "-" or c == "p":
					_add_tile_sprite(detail, dirt_tiles[_terrain_mask(x, y, "-p_" + CROP_CHARS)], x, y)
				elif c == "%":
					_add_tile_sprite(detail, rocky_tiles[_terrain_mask(x, y, "%")], x, y)
				elif c == "n":
					_add_tile_sprite(detail, TEX["mushroom"], x, y)
				elif c == "]":
					_add_tile_sprite(detail, poison_textures[_terrain_mask(x, y, "]")], x, y)
				elif c == "|":
					var lava := _add_tile_sprite(lava_layer, lava_textures[_terrain_mask(x, y, "|")], x, y)
					lava.material = lava_material
					lava.modulate = Color.WHITE
				elif c == ">":
					_add_tile_sprite(detail, DUNGEON_TEX["stairs_down"], x, y)
				if c == "Z":
					var flag := _add_tile_sprite(detail, DUNGEON_TEX["banner"], x, y)
					flag.position += Vector2(2, 1)
				elif c == "S":
					var bone := _add_tile_sprite(detail, DUNGEON_TEX["bones"], x, y)
					bone.position.y += 3.0
				if not WALL_CHARS.contains(c) and WALL_CHARS.contains(cell(x, y - 1)):
					_add_tile_sprite(detail, DUNGEON_TEX["wall_shadow"], x, y)  # bóng tường đổ xuống sàn
	tile_tint = Color.WHITE


# ---------------------------------------------------------------- Thế giới lớn: vẽ theo mảnh quanh người chơi

## Vẽ một mảnh 16 x 16 ô: mặt đất (gộp thành một ảnh) và cây cối, nhà cửa, đồ trang trí đứng trên đó.
func _build_chunk(cc: Vector2i) -> void:
	if chunks.has(cc):
		return
	var x0 := cc.x * CHUNK
	var y0 := cc.y * CHUNK
	var x1 := mini(x0 + CHUNK, overworld_size.x)
	var y1 := mini(y0 + CHUNK, overworld_size.y)
	if x1 <= x0 or y1 <= y0:
		return
	var img := Image.create_empty((x1 - x0) * TILE, (y1 - y0) * TILE, false, Image.FORMAT_RGBA8)
	var props := Node2D.new()
	props.y_sort_enabled = true
	entities.add_child(props)
	var shade := Node2D.new()
	shadows.add_child(shade)
	var data := { "props": props, "shadows": shade, "anims": [], "blades": [], "falls": [] }
	for y in range(y0, y1):
		for x in range(x0, x1):
			var at := Vector2i((x - x0) * TILE, (y - y0) * TILE)
			var area := _area_at(x, y)
			tile_tint = _cell_tint(x, y, area)
			_stamp(img, _floor_texture(x, y), at)
			for tex in _cell_details(x, y, area):
				_stamp(img, tex, at)
			tile_tint = Color.WHITE
			_spawn_prop(x, y, props, shade, data)
	var ground := Sprite2D.new()
	ground.texture = ImageTexture.create_from_image(img)
	ground.centered = false
	ground.position = Vector2(x0, y0) * TILE
	ground_root.add_child(ground)
	data["ground"] = ground
	chunks[cc] = data


func _free_chunk(cc: Vector2i) -> void:
	var data: Dictionary = chunks[cc]
	for key in ["ground", "props", "shadows"]:
		var node: Node = data.get(key)
		if node != null and is_instance_valid(node):
			node.queue_free()
	chunks.erase(cc)


## Giữ các mảnh quanh người chơi, xoá mảnh ở xa. Mảnh đang hiện trên màn hình mà chưa có thì vẽ ngay.
func _update_chunks() -> void:
	var span := CHUNK * TILE
	var pc := Vector2i(floori(player.position.x / span), floori(player.position.y / span))
	var count := Vector2i(ceili(overworld_size.x / float(CHUNK)), ceili(overworld_size.y / float(CHUNK)))
	if pc != last_chunk:
		last_chunk = pc
		for cc in chunks.keys():
			if absi(cc.x - pc.x) > CHUNK_DROP.x or absi(cc.y - pc.y) > CHUNK_DROP.y:
				_free_chunk(cc)
		chunk_queue.clear()
		for dy in range(-CHUNK_KEEP.y, CHUNK_KEEP.y + 1):
			for dx in range(-CHUNK_KEEP.x, CHUNK_KEEP.x + 1):
				var cc := pc + Vector2i(dx, dy)
				if cc.x >= 0 and cc.y >= 0 and cc.x < count.x and cc.y < count.y and not chunks.has(cc):
					chunk_queue.append(cc)
		chunk_queue.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return (a - pc).length_squared() < (b - pc).length_squared())
	if current_floor == 0 and player.camera != null:
		var view := Rect2(player.camera.get_screen_center_position() - Vector2(340, 200), Vector2(680, 400))
		var c0 := Vector2i(floori(view.position.x / span), floori(view.position.y / span))
		var c1 := Vector2i(floori(view.end.x / span), floori(view.end.y / span))
		for cy in range(maxi(c0.y, 0), mini(c1.y, count.y - 1) + 1):
			for cx in range(maxi(c0.x, 0), mini(c1.x, count.x - 1) + 1):
				if not chunks.has(Vector2i(cx, cy)):
					_build_chunk(Vector2i(cx, cy))
	if not chunk_queue.is_empty():
		_build_chunk(chunk_queue.pop_front())


## Vẽ ảnh tex (đã tô màu tile_tint) vào ảnh mảnh tại điểm at. Ảnh nhỏ (vỏ sò, xương...) đặt giữa đáy ô.
func _stamp(img: Image, tex: Texture2D, at: Vector2i) -> void:
	if tex == null:
		return
	var src := _image_of(tex, tile_tint)
	var w := mini(src.get_width(), TILE)
	var h := mini(src.get_height(), TILE)
	var dst := at
	if w < TILE or h < TILE:
		dst += Vector2i((TILE - w) / 2, TILE - h - 1)
	img.blend_rect(src, Rect2i(0, 0, w, h), dst)


## Ảnh (Image) của một hình, tô màu tint. Mỗi cặp hình + màu chỉ tạo một lần rồi dùng lại.
func _image_of(tex: Texture2D, tint: Color) -> Image:
	var per_tex: Dictionary = image_cache.get(tex, {})
	if per_tex.has(tint):
		return per_tex[tint]
	var img: Image
	if per_tex.has(Color.WHITE):
		img = (per_tex[Color.WHITE] as Image).duplicate()
	else:
		img = tex.get_image()
		if img == null:
			img = Image.create_empty(TILE, TILE, false, Image.FORMAT_RGBA8)
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		if tint != Color.WHITE:
			per_tex[Color.WHITE] = img.duplicate()
	if tint != Color.WHITE:
		for py in img.get_height():
			for px in img.get_width():
				var c := img.get_pixel(px, py)
				if c.a > 0.0:
					img.set_pixel(px, py, Color(minf(c.r * tint.r, 1.0), minf(c.g * tint.g, 1.0), minf(c.b * tint.b, 1.0), c.a))
	per_tex[tint] = img
	image_cache[tex] = per_tex
	return img


## Màu phủ lên ô (x, y): theo kiểu cảnh của khu, vách đá thì theo ROCK_TINT.
func _cell_tint(x: int, y: int, area: Dictionary) -> Color:
	var biome: String = area.get("biome", "")
	if cell(x, y) == "#" and ROCK_TINT.has(biome):
		return ROCK_TINT[biome]
	return BIOME_TINT.get(biome, Color.WHITE)


## Các lớp vẽ đè lên mặt đất của ô (x, y): đường đất, sân đá, bãi đá, lá sen, viền rừng...
func _cell_details(x: int, y: int, area: Dictionary) -> Array:
	var out := []
	var c := cell(x, y)
	var biome: String = area.get("biome", "")
	var ground: String = BIOME_GROUND.get(biome, "grass")
	if plaza_cells.has(Vector2i(x, y)):
		out.append(_plaza_texture(x, y))
	if c == "-" or c == "p":
		out.append(dirt_tiles[_terrain_mask(x, y, "-p_" + CROP_CHARS)])
		if c == "p":
			out.append(FOREST_TEX["sprout"])
	elif CROP_CHARS.contains(c):
		out.append(dirt_tiles[_terrain_mask(x, y, "-p" + CROP_CHARS)])   # ruộng: đất cày có rãnh
		out.append(ECO_TEX["furrows"])
	elif c == "[":
		out.append(ECO_TEX["dock"])
	elif c == "~" and _rand(x, y, 7) < float(area.get("lilies", 0.0)) and _water_inside(x, y):
		var lilies: Array = ECO_TEX["lilies"]
		out.append(lilies[_pick(x, y, 8, lilies.size())])
	elif c == "%":
		out.append(rocky_tiles[_terrain_mask(x, y, "%")])
	elif c == "n":
		out.append(_small_deco(biome))
	elif c == "f":
		out.append(_fence_texture(x, y))
	elif c == "," and ground != "grass":
		out.append(grass_sand_tiles[_grass_mask(x, y)])   # bãi cỏ nhỏ trên cát
	elif c == "_" and ground != "grass":
		out.append(BIOME_TEX["path_stones"])   # đường lát đá trên cát, tuyết
	if biome == "cherry" and c != "T" and not WATER_CHARS.contains(c) and _rand(x, y, 9) < 0.12:
		var petals: Array = BIOME_TEX["petals"]
		out.append(petals[_pick(x, y, 10, petals.size())])   # cánh hoa đào rơi
	if c != "T" and not arena_rect.has_point(Vector2i(x, y)) and ground != "sand":
		out.append_array(_forest_shade(x, y))
	return out


## Đồ trang trí nhỏ 'n' theo kiểu cảnh: nấm, vỏ sò, xương, tinh thể băng...
func _small_deco(biome: String) -> Texture2D:
	match biome:
		"beach", "island", "ocean":
			return BIOME_TEX["shells"]
		"desert", "oasis", "badlands", "savanna":
			return BIOME_TEX["bones"]
		"snow", "taiga":
			return BIOME_TEX["ice_crystals"]
		"mushroom":
			return BIOME_TEX["small_mushrooms"]
	return TEX["mushroom"]


## Kiểu mép bãi cỏ trên cát: cộng 1 nếu ô trên là cỏ, 2 ô phải, 4 ô dưới, 8 ô trái.
func _grass_mask(x: int, y: int) -> int:
	var mask := 0
	var dirs := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
	for i in 4:
		var n: Vector2i = Vector2i(x, y) + dirs[i]
		var nc := cell(n.x, n.y)
		if nc == "," or (not WATER_CHARS.contains(nc) and BIOME_GROUND.get(_biome_at(n.x, n.y), "grass") == "grass"):
			mask |= 1 << i
	return mask


func _area_at(x: int, y: int) -> Dictionary:
	var i := _area_index(x, y)
	return WorldMap.AREAS[i] if i != -1 else {}


## Kiểu cảnh của ô (x, y) ("" nếu không thuộc khu nào).
func _biome_at(x: int, y: int) -> String:
	var i := _area_index(x, y)
	return WorldMap.AREAS[i].get("biome", "") if i != -1 else ""


func _area_index(x: int, y: int) -> int:
	if x < 0 or y < 0 or x >= overworld_size.x or y >= overworld_size.y:
		return -1
	return WorldMap.area_index(x, y)


## Ô nước nằm giữa hồ (4 bên đều là nước) để đặt lá sen, cho vịt bơi.
func _water_inside(x: int, y: int) -> bool:
	return cell(x, y) == "~" and cell(x + 1, y) == "~" and cell(x - 1, y) == "~" \
		and cell(x, y + 1) == "~" and cell(x, y - 1) == "~"


## Kiểu mép của ô đường đất / bãi đá: cộng 1 nếu ô trên cùng loại, 2 ô phải, 4 ô dưới, 8 ô trái.
func _terrain_mask(x: int, y: int, same: String) -> int:
	var mask := 0
	if same.contains(cell(x, y - 1)):
		mask |= 1
	if same.contains(cell(x + 1, y)):
		mask |= 2
	if same.contains(cell(x, y + 1)):
		mask |= 4
	if same.contains(cell(x - 1, y)):
		mask |= 8
	return mask


func _forest_shade(x: int, y: int) -> Array:
	var out := []
	var n := cell(x, y - 1) == "T"
	var s := cell(x, y + 1) == "T"
	var w := cell(x - 1, y) == "T"
	var e := cell(x + 1, y) == "T"
	if n:
		out.append(shade_tiles["n"])
	if s:
		out.append(shade_tiles["s"])
	if w:
		out.append(shade_tiles["w"])
	if e:
		out.append(shade_tiles["e"])
	if not n and not w and cell(x - 1, y - 1) == "T":
		out.append(shade_tiles["nw"])
	if not n and not e and cell(x + 1, y - 1) == "T":
		out.append(shade_tiles["ne"])
	if not s and not w and cell(x - 1, y + 1) == "T":
		out.append(shade_tiles["sw"])
	if not s and not e and cell(x + 1, y + 1) == "T":
		out.append(shade_tiles["se"])
	return out


func _add_tile_sprite(parent: Node, tex: Texture2D, x: int, y: int) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = Vector2(x * TILE, y * TILE)
	s.modulate = tile_tint
	parent.add_child(s)
	return s


func _fence_texture(x: int, y: int) -> Texture2D:
	var left := cell(x - 1, y) == "f"
	var right := cell(x + 1, y) == "f"
	var up := cell(x, y - 1) == "f"
	var down := cell(x, y + 1) == "f"
	if not left and not right and (up or down):  # hàng rào dọc
		if not up:
			return FOREST_TEX["fence_v_top"]
		if not down:
			return FOREST_TEX["fence_v_bottom"]
		return FOREST_TEX["fence_v_mid"]
	if left and not right:
		return TEX["fence_r"]
	if right and not left:
		return TEX["fence_l"]
	return TEX["fence_m"]


func _add_prop(tex: Texture2D, x: int, y: int, width_tiles: int = 1, height_tiles: int = 1,
		frames: int = 1, parent: Node = null) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.hframes = frames
	s.centered = false
	s.position = Vector2((x + width_tiles / 2.0) * TILE, (y + height_tiles) * TILE)  # gốc ở đáy
	s.offset = Vector2(-tex.get_width() / float(frames) / 2.0, -tex.get_height())
	(parent if parent != null else entities).add_child(s)
	return s


func _add_shadow(tex: Texture2D, pos: Vector2, parent: Node = null) -> void:
	var sh := Sprite2D.new()
	sh.texture = tex
	sh.position = pos
	(parent if parent != null else shadows).add_child(sh)


func _add_tree(x: int, y: int, parent: Node = null, shade: Node = null) -> void:
	var deep := true
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var n := cell(x + dx, y + dy)
			if n != "T" and n != "#":
				deep = false
	if deep and _rand(x, y, 20) < 0.4:
		return
	var biome := _biome_at(x, y)
	if biome == "":
		biome = "forest"
	var tex: Texture2D
	var roll := _rand(x, y, 21)
	var pick := _rand(x, y, 22)
	var tint := Color.WHITE
	match biome:
		"pine", "mountain", "canyon":   # rừng thông: hầu hết là cây thông
			tex = FOREST_TREES[3 + int(pick * 2) % 2] if roll < 0.85 else FOREST_TREES[int(pick * 3) % 3]
		"swamp":  # đầm lầy: cây liễu rủ, cây chết khô
			var willows: Array = ECO_TEX["willows"]
			if roll < 0.55:
				tex = willows[int(pick * willows.size()) % willows.size()]
			elif roll < 0.75:
				tex = ECO_TEX["dead_tree"]
			else:
				tex = FOREST_TREES[int(pick * 3) % 3]
			tint = SWAMP_TREE_COLOR
		"birch":
			tex = _from(BIOME_TEX["birch"], pick) if roll < 0.88 else FOREST_TREES[int(pick * 3) % 3]
		"cherry":
			tex = _from(BIOME_TEX["cherry"], pick) if roll < 0.85 else FOREST_TREES[int(pick * 3) % 3]
		"snow", "taiga":
			tex = _from(BIOME_TEX["snow_pine"], pick)
		"bamboo":
			tex = _from(BIOME_TEX["bamboo"], pick)
		"savanna":
			tex = _from(BIOME_TEX["acacia"], pick)
		"badlands":
			tex = ECO_TEX["dead_tree"] if roll < 0.6 else _from(BIOME_TEX["acacia"], pick)
		"mushroom":
			tex = _from(ECO_TEX["giant_mushrooms"], pick)
		"beach", "desert", "oasis", "island", "ocean":
			tex = _from(BIOME_TEX["palms"], pick)
		"oldforest":
			tex = FOREST_TREES[3 + int(pick * 2) % 2] if roll < 0.2 else FOREST_TREES[int(pick * 3) % 3]
			tint = Color(0.82, 0.9, 0.82)
		_:
			tex = FOREST_TREES[3 + int(pick * 2) % 2] if roll < 0.3 else FOREST_TREES[int(pick * 3) % 3]
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.flip_h = _rand(x, y, 23) < 0.5
	s.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height())
	s.position = Vector2((x + 0.5) * TILE + _rand(x, y, 24) * 8.0 - 4.0, (y + 1) * TILE - 1.0 + _rand(x, y, 25) * 5.0 - 4.0)
	s.modulate = tint
	if deep:
		s.modulate *= DEEP_TREE_COLOR
	(parent if parent != null else entities).add_child(s)
	_add_shadow(FOREST_TEX["tree_shadow"], s.position + Vector2(2, -2), shade)


func _from(list: Array, roll: float) -> Texture2D:
	return list[mini(int(roll * list.size()), list.size() - 1)]


func _add_small_prop(tex: Texture2D, x: int, y: int, parent: Node = null, shade: Node = null) -> Sprite2D:
	var s := _add_prop(tex, x, y, 1, 1, 1, parent)
	_add_shadow(FOREST_TEX["small_shadow"], s.position + Vector2(1, -2), shade)
	return s


func _build_walls() -> void:
	solid_rects = _merged_rects(SOLID)
	water_rects = _merged_rects(WATER_SOLID)
	# Khối va chạm: gộp các ô chặn liền nhau thành hình chữ nhật lớn
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	add_child(walls)
	for r in solid_rects:
		_add_box_shape(walls, r)
	# Nước: lớp va chạm riêng (người đi bộ, quái bị chặn; có thuyền thì đi được; đạn bay qua được)
	var water := StaticBody2D.new()
	water.name = "Water"
	water.collision_layer = WATER_LAYER
	water.collision_mask = 0
	add_child(water)
	for r in water_rects:
		_add_box_shape(water, r)

	# Cổng phong ấn: thân va chạm riêng để có thể mở ra
	gate_body = StaticBody2D.new()
	gate_body.name = "Gate"
	gate_body.collision_layer = 1
	gate_body.collision_mask = 0
	add_child(gate_body)
	for g in gate_cells:
		var x := g.x
		var y := g.y
		# Cửa hang: vách đá có miệng hang, phong ấn tím chắn ở miệng hang tới khi hạ Boss
		_add_rect_shape(gate_body, x, y, 1)
		var mouth := _add_prop(CAVE_TEX["mouth"], x, y)
		mouth.position.y += 1.0
		var seal := Sprite2D.new()
		seal.texture = CAVE_TEX["seal"]
		seal.hframes = 2
		seal.centered = false
		seal.offset = Vector2(-8, -22)
		seal.position = Vector2((x + 0.5) * TILE, (y + 1) * TILE + 2.0)
		entities.add_child(seal)
		village_anims.append({"sprite": seal, "fps": 3.0, "phase": 0.0})
		gate_sprites.append(seal)
		cave_entrance = Vector2((x + 0.5) * TILE, (y + 0.5) * TILE)


## Gộp các ô có ký tự trong chars liền nhau thành ít hình chữ nhật nhất (ngang trước, rồi nối các hàng giống nhau).
func _merged_rects(chars: String) -> Array[Rect2i]:
	var done: Array[Rect2i] = []
	var open := {}   # Vector2i(x đầu, x cuối) -> Rect2i đang kéo dài xuống
	for y in map_size.y:
		var row: String = rows[y]
		var n := row.length()
		var next := {}
		var x := 0
		while x < n:
			if chars.contains(row[x]):
				var start := x
				while x < n and chars.contains(row[x]):
					x += 1
				var key := Vector2i(start, x)
				if open.has(key):
					var r: Rect2i = open[key]
					r.size.y += 1
					next[key] = r
					open.erase(key)
				else:
					next[key] = Rect2i(start, y, x - start, 1)
			else:
				x += 1
		for r in open.values():
			done.append(r)
		open = next
	for r in open.values():
		done.append(r)
	return done


func _add_box_shape(body: StaticBody2D, r: Rect2i) -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(r.size) * TILE
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = (Vector2(r.position) + Vector2(r.size) / 2.0) * TILE
	body.add_child(col)


# ---------------------------------------------------------------- Tìm đường (chuột phải để đi)

func _build_pathfinding() -> void:
	for grid in [astar, astar_boat]:
		var g: AStarGrid2D = grid
		g.region = Rect2i(0, 0, map_size.x, map_size.y)
		g.cell_size = Vector2(TILE, TILE)
		g.offset = Vector2(TILE / 2.0, TILE / 2.0)  # điểm nằm ở giữa ô
		g.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		g.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		g.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
		g.update()
		for r in solid_rects:
			g.fill_solid_region(r, true)
		for c in gate_cells:
			g.set_point_solid(c, true)
	for r in water_rects:
		astar.fill_solid_region(r, true)   # đi bộ: nước chặn. Có thuyền: dùng astar_boat (nước đi được)


func _to_cell(local_pos: Vector2) -> Vector2i:
	return Vector2i(floori(local_pos.x / TILE), floori(local_pos.y / TILE))


func _blocked(c: Vector2i) -> bool:
	var grid := astar_boat if _query_boat else astar
	return not grid.is_in_boundsv(c) or grid.is_point_solid(c)


## Người chơi có thuyền trong túi: tìm đường được cả trên nước.
func _player_has_boat() -> bool:
	return player != null and player.has_boat()


## Ô trống gần nhất (khi bấm chuột vào cây, tường...). Trả về (-1, -1) nếu không có.
func _nearest_open_cell(c: Vector2i) -> Vector2i:
	for r in range(1, 5):
		var best := Vector2i(-1, -1)
		var best_d := INF
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var n := c + Vector2i(dx, dy)
				if not _blocked(n) and Vector2(dx, dy).length() < best_d:
					best = n
					best_d = Vector2(dx, dy).length()
		if best != Vector2i(-1, -1):
			return best
	return Vector2i(-1, -1)


func segment_clear(a: Vector2, b: Vector2, clearance: float = 6.0, walls_only: bool = false) -> bool:
	var was := _query_boat
	if walls_only:
		_query_boat = true   # chỉ xét tường, cây (nhìn / bắn qua nước được)
	var ok := _segment_clear(a, b, clearance)
	_query_boat = was
	return ok


func _segment_clear(a: Vector2, b: Vector2, clearance: float) -> bool:
	var p0 := to_local(a)
	var d := to_local(b) - p0
	var length := d.length()
	if length < 1.0:
		return true
	var side := Vector2(-d.y, d.x) / length * clearance
	var steps := int(length / 4.0) + 1
	for s in steps + 1:
		var p := p0 + d * (float(s) / steps)
		if _blocked(_to_cell(p)) or _blocked(_to_cell(p + side)) or _blocked(_to_cell(p - side)):
			return false
	return true


## Chỗ pos có trống không (không phải tường, cây, nước...), chừa khoảng clearance pixel xung quanh.
func is_open(pos: Vector2, clearance: float = 5.0) -> bool:
	var p := to_local(pos)
	for offset in [Vector2.ZERO, Vector2(clearance, 0), Vector2(-clearance, 0), Vector2(0, clearance), Vector2(0, -clearance)]:
		if _blocked(_to_cell(p + offset)):
			return false
	return true


func can_teleport(a: Vector2, b: Vector2) -> bool:
	_query_boat = _player_has_boat()
	var ok := is_open(b, 5.0)
	_query_boat = false
	if not ok:
		return false
	if dungeon_column != -1:
		var wall_x := (dungeon_column + 1) * TILE
		if (to_local(a).x < wall_x) != (to_local(b).x < wall_x):
			return false   # hầm ngục chỉ vào được bằng cửa hang
	return true


func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	_query_boat = _player_has_boat()
	var result := _find_path(from, to)
	_query_boat = false
	return result


func _find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var grid := astar_boat if _query_boat else astar
	var result := PackedVector2Array()
	var start := _to_cell(to_local(from))
	var goal := _to_cell(to_local(to))
	if not grid.is_in_boundsv(goal):
		return result
	var exact := true
	if _blocked(goal):
		goal = _nearest_open_cell(goal)
		exact = false
		if goal == Vector2i(-1, -1):
			return result
	if _blocked(start):
		start = _nearest_open_cell(start)
		if start == Vector2i(-1, -1):
			return result
	# Đi thẳng được thì khỏi tìm đường
	if exact and _segment_clear(from, to, 6.0):
		result.append(to)
		return result
	var points := grid.get_point_path(start, goal, true)
	for i in range(1, points.size()):
		result.append(to_global(points[i]))
	if exact and points.size() > 0 and _to_cell(points[points.size() - 1]) == goal:
		if result.is_empty():
			result.append(to)
		else:
			result[result.size() - 1] = to
	return _smooth_path(from, result)


## Bỏ bớt các điểm không cần thiết để nhân vật đi thẳng, tự nhiên hơn (không đi zíc zắc theo ô).
func _smooth_path(from: Vector2, points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	var current := from
	var i := 0
	while i < points.size():
		var j := mini(points.size() - 1, i + 10)
		while j > i and not _segment_clear(current, points[j], 6.0):
			j -= 1
		out.append(points[j])
		current = points[j]
		i = j + 1
	return out


## Thêm hiệu ứng nằm trên mặt đất (dưới chân nhân vật), ví dụ dấu chỗ bấm chuột.
func add_ground_effect(node: Node2D, world_pos: Vector2) -> void:
	add_child(node)
	move_child(node, entities.get_index())
	node.global_position = world_pos


func _add_rect_shape(body: StaticBody2D, x: int, y: int, width_tiles: int) -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width_tiles * TILE, TILE)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2((x + width_tiles / 2.0) * TILE, (y + 0.5) * TILE)
	body.add_child(col)


func _spawn_everything() -> void:
	# Bản đồ cũ (ở giữa) trước, rồi tới phần còn lại: giữ đúng thứ tự dân làng / biển báo / sạp hàng như trước
	var core := WorldMap.CORE
	for y in range(core.position.y, core.end.y):
		for x in range(core.position.x, core.end.x):
			_register_cell(x, y)
	for y in map_size.y:
		for x in map_size.x:
			if not core.has_point(Vector2i(x, y)):
				_register_cell(x, y)
	_spawn_critters()
	_add_fireflies()
	_seal_rune_stairs()
	if not portal_open and portal_ring:
		portal_ring.modulate = Color(0.5, 0.45, 0.55, 0.6)   # cổng xoáy còn tắt
	if player:
		player.set_camera_limits(region_pixels(0))
		# Đèn nhỏ quanh người chơi, chỉ bật trong hầm ngục
		player_light = PointLight2D.new()
		player_light.texture = light_texture
		player_light.texture_scale = 100.0 * 2.0 / light_texture.width
		player_light.color = Color(1.0, 0.9, 0.8)
		player_light.energy = 0.7
		player_light.enabled = false
		player.add_child(player_light)


## Những thứ có "sự sống" (dân làng, quái, cây thu hoạch, rương, trạm chế tạo, biển báo...) tạo ngay từ đầu.
## Cây cối, nhà cửa, đồ trang trí ngoài trời thì vẽ theo mảnh quanh người chơi (_spawn_prop).
func _register_cell(x: int, y: int) -> void:
	var c := cell(x, y)
	var fl := floor_at(x, y)
	if fl > 0:   # hầm ngục: vẽ luôn từ đầu như trước
		_spawn_prop(x, y, entities, shadows, { "anims": village_anims, "blades": windmill_blades, "falls": waterfalls })
	if c == "." or c == "T" or c == "#" or c == "~" or c == ",":
		return
	var pos := Vector2(x + 0.5, y + 0.5) * TILE
	match c:
		"z":
			var stump = HARVEST_SCRIPT.new()
			stump.setup(STUMP_WOOD)
			stump.position = Vector2((x + 0.5) * TILE, (y + 1) * TILE)
			entities.add_child(stump)
			sleepers.append(stump)
			_add_shadow(FOREST_TEX["small_shadow"], stump.position + Vector2(1, -2))
		"j", "8":
			stations.append({"pos": _prop_base(x, y, 1, 1) + Vector2(0, -6), "kind": "fire"})
		"0":
			stations.append({"pos": _prop_base(x, y, 1, 1) + Vector2(0, -6), "kind": "stove"})
		"C":
			stations.append({"pos": _prop_base(x, y, 1, 1) + Vector2(0, -6), "kind": "pot"})
		"@":
			stations.append({"pos": _prop_base(x, y, 2, 1) + Vector2(0, -6), "kind": "bench"})
		"ê":
			stations.append({"pos": _prop_base(x, y, 3, 2) + Vector2(0, -6), "kind": "shipyard"})
		"J", "H":
			variant_index[Vector2i(x, y)] = stall_count if c == "J" else cabin_count
			if c == "J":
				stall_count += 1
			else:
				cabin_count += 1
		"{", "<":
			_add_light(pos + Vector2(0, -4), 70.0, Color(1.0, 0.95, 0.8), 1.0, false)
			stairs.append({"pos": pos, "kind": "exit" if c == "{" else "up", "floor": fl})
			if c == "{":
				cave_exit = pos
		">":
			_add_light(pos, 46.0, Color(0.7, 0.75, 1.0), 0.6, false)
			stairs.append({"pos": pos, "kind": "down", "floor": fl, "sealed": false})
		"9":
			_add_trap("spike", pos, x, y)
		"/":
			_add_trap("vent", pos, x, y)
		"|":
			if posmod(x * 3 + y * 5, 7) == 0:
				_add_light(pos, 44.0, Color(1.0, 0.5, 0.2), 0.8, true)
		"]":
			if posmod(x * 5 + y * 3, 9) == 0:
				_add_light(pos, 34.0, Color(0.5, 1.0, 0.35), 0.5, true)
		"v":
			var npc = NPC_SCRIPT.new()
			var npc_data := _next_npc_data(x, y)
			npc.setup(npc_data)
			npc.position = pos
			npc.level_ref = self
			entities.add_child(npc)
			sleepers.append(npc)
			if npc_data.get("prop", "") == "anvil":
				extra_props[Vector2i(x - 1, y)] = CRAFT_TEX["anvil"]   # cái đe cạnh thợ rèn
				if fl > 0:
					_add_small_prop(CRAFT_TEX["anvil"], x - 1, y)
		"w":
			var bucket = HARVEST_SCRIPT.new()
			bucket.setup(WELL_BUCKET)
			bucket.position = Vector2((x + 1) * TILE + 2, (y + 1) * TILE + 2)
			entities.add_child(bucket)
			sleepers.append(bucket)
		"á":
			var spot = HARVEST_SCRIPT.new()
			spot.setup(FISHING)
			spot.position = Vector2((x + 0.5) * TILE, (y + 1) * TILE)
			entities.add_child(spot)
			sleepers.append(spot)
		"q":
			var text := _next_sign_text(x, y)
			signs.append({"pos": pos, "text": text, "near": false})
		"A":
			altar_position = pos
		"Y":
			_add_light(pos + Vector2(0, -4), 90.0, Color(1.0, 0.62, 0.3), 1.1, true)
		"i":
			_add_light(pos + Vector2(0, -2), 44.0, CANDLE_LIGHT, 0.85, true)
		"I":
			_add_light(pos + Vector2(0, -14), 60.0, CANDLE_LIGHT, 0.95, true)
		"E", "Q":
			_add_pedestal(x, y, Pickup.Kind.POWER_CRYSTAL if c == "E" else Pickup.Kind.POTION_HP)
		"O":
			_add_portal(x, y)
		"'":
			_add_chest(x, y)
		"P":
			player = PLAYER_SCENE.instantiate() as Player
			player.position = pos
			player.level_ref = self
			entities.add_child(player)
	if HARVEST.has(c):
		var plant = HARVEST_SCRIPT.new()
		plant.setup(HARVEST[c])
		plant.position = Vector2((x + 0.5) * TILE, (y + 1) * TILE)
		entities.add_child(plant)
		sleepers.append(plant)
		if c == "1" or c == "7":
			_add_shadow(FOREST_TEX["tree_shadow" if c == "7" else "small_shadow"], plant.position + Vector2(1, -2))
	if ENEMY_SCENES.has(c):
		var enemy := (ENEMY_SCENES[c] as PackedScene).instantiate() as Enemy
		enemy.position = pos
		if fl > 0 and c != "}":
			_apply_floor_power(enemy, fl)   # quái hầm ngục mạnh dần theo tầng
		if c == "}":
			portal_open = false               # cổng xoáy chỉ mở khi hạ Boss hầm ngục
		if fl > 0:
			_track_floor_enemy(enemy, fl)     # hạ hết quái của tầng thì rương mở khoá
		_apply_enemy_level(enemy, c, x, y)
		_apply_area_look(enemy, c, x, y)
		if c == "D":
			enemy.armor = 6
			enemy.display_name = "Bù nhìn giáp"
		if c != "B" and c != "D" and c != "}":
			enemy.died.connect(_on_enemy_died.bind(c, pos))
		entities.add_child(enemy)
		sleepers.append(enemy)
	elif ITEM_KINDS.has(c):
		var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
		item.kind = ITEM_KINDS[c]
		item.value = ITEM_VALUES[c]
		item.position = pos
		entities.add_child(item)


## Gốc (chân) của đồ vật rộng w, cao h ô đặt ở ô (x, y).
func _prop_base(x: int, y: int, w: int, h: int) -> Vector2:
	return Vector2((x + w / 2.0) * TILE, (y + h) * TILE)


## Lời thoại cho dân làng tiếp theo: bản đồ cũ dùng NPC_DATA ở trên, các làng mới dùng WorldMap.NPC_DATA.
func _next_npc_data(x: int, y: int) -> Dictionary:
	var in_core := WorldMap.CORE.has_point(Vector2i(x, y))
	var list: Array = NPC_DATA if in_core else WorldMap.NPC_DATA
	var index := npc_count if in_core else npc_count - _core_npcs
	npc_count += 1
	if in_core:
		_core_npcs += 1
	return list[index] if index >= 0 and index < list.size() else {}


func _next_sign_text(x: int, y: int) -> String:
	var in_core := WorldMap.CORE.has_point(Vector2i(x, y))
	var list: Array = SIGN_TEXTS if in_core else WorldMap.SIGN_TEXTS
	var index := signs.size() if in_core else signs.size() - _core_signs
	if in_core:
		_core_signs += 1
	return list[index] if index >= 0 and index < list.size() else "..."


## Cây cối, nhà cửa, đồ trang trí đứng (chỉ là hình): vẽ khi mảnh chứa ô (x, y) hiện ra.
## holder: nơi chứa hình (mảnh), shade: nơi chứa bóng, data: các danh sách hình chuyển động của mảnh.
func _spawn_prop(x: int, y: int, holder: Node, shade: Node, data: Dictionary) -> void:
	var c := cell(x, y)
	if c == "." or c == "#" or c == "~" or c == "," or c == "-" or c == "_":
		return
	var biome := _biome_at(x, y)
	var anims: Array = data["anims"]
	match c:
		"T":
			_add_tree(x, y, holder, shade)
		"o":
			var bush: Texture2D
			match biome:
				"desert", "badlands":
					bush = BIOME_TEX["dry_bush"]
				"savanna":
					bush = BIOME_TEX["savanna_grass"]
				"beach", "island", "oasis", "ocean":
					bush = BIOME_TEX["beach_grass"]
				"bamboo", "oldforest", "taiga":
					bush = BIOME_TEX["fern"]
				_:
					bush = TEX["bush"] if _rand(x, y, 30) < 0.6 else FOREST_TEX["berry_bush"]
			_add_small_prop(bush, x, y, holder, shade)
		"r":
			var rock: Texture2D
			match BIOME_GROUND.get(biome, "grass"):
				"sand":
					rock = BIOME_TEX["rock_sand"]
				"snow":
					rock = BIOME_TEX["rock_snow"]
				"red":
					rock = BIOME_TEX["rock_red"]
				"stone":
					rock = BIOME_TEX["rock_stone"]
				_:
					var rocks := [TEX["rock"], FOREST_TEX["rock_moss"], FOREST_TEX["rock_grey_moss"]]
					rock = rocks[_pick(x, y, 31, rocks.size())]
			_add_small_prop(rock, x, y, holder, shade)
		"k":
			_add_small_prop(FOREST_TEX["crate"], x, y, holder, shade)
		"l":
			_add_small_prop(FOREST_TEX["barrel"] if _rand(x, y, 32) < 0.5 else FOREST_TEX["barrel2"], x, y, holder, shade)
		"j":
			var fire := _add_prop(FOREST_TEX["campfire"], x, y, 1, 1, 1, holder)
			var flicker := fire.create_tween().set_loops()
			flicker.tween_property(fire, "modulate", Color(1.3, 1.15, 0.9), 0.12)
			flicker.tween_property(fire, "modulate", Color(1.0, 0.9, 0.85), 0.18)
		"8":
			var pit := _add_prop(CRAFT_TEX["fire_pit"], x, y, 1, 1, 3, holder)
			anims.append({"sprite": pit, "fps": 6.0, "phase": 0.0})
		"0":
			var stove := _add_prop(CRAFT_TEX["oven"], x, y, 1, 1, 3, holder)
			anims.append({"sprite": stove, "fps": 5.0, "phase": 0.0})
			_add_shadow(FOREST_TEX["small_shadow"], stove.position + Vector2(1, -2), shade)
		"C":
			var pot := _add_prop(CRAFT_TEX["cauldron"], x, y, 1, 1, 3, holder)
			anims.append({"sprite": pot, "fps": 5.0, "phase": 0.0})
			_add_shadow(FOREST_TEX["small_shadow"], pot.position + Vector2(1, -2), shade)
		"@":
			var bench := _add_prop(CRAFT_TEX["workbench"], x, y, 2, 1, 1, holder)
			_add_shadow(FOREST_TEX["tree_shadow"], bench.position + Vector2(1, -2), shade)
		"ê":
			var yard := _add_prop(CRAFT_TEX["shipyard"], x, y, 3, 2, 1, holder)
			_add_shadow(FOREST_TEX["tree_shadow"], yard.position + Vector2(0, -2), shade)
		"H":
			var house: Texture2D
			var n := int(variant_index.get(Vector2i(x, y), 0))
			match biome:
				"snow", "taiga":
					house = BIOME_TEX["cabin_snow"]
				"beach", "bamboo", "island":
					house = BIOME_TEX["stilts"][n % 2]
				"desert", "oasis", "badlands":
					house = BIOME_TEX["adobe"][n % 2]
				_:
					house = FOREST_TEX["cabin_grey" if n % 2 == 0 else "cabin_red"]
			_add_prop(house, x, y, 3, 3, 1, holder)
		"V":
			var fall := _add_prop(FOREST_TEX["waterfall"], x, y, 3, 3, 3, holder)
			fall.position.y += 4.0  # bọt nước tràn xuống mép hồ
			data["falls"].append(fall)
		"t":
			var tree_tex: Texture2D
			if SAND_BIOMES.has(biome):
				tree_tex = _from(BIOME_TEX["palms"], _rand(x, y, 33))
			elif biome == "snow" or biome == "taiga":
				tree_tex = _from(BIOME_TEX["snow_pine"], _rand(x, y, 33))
			elif biome == "cherry":
				tree_tex = _from(BIOME_TEX["cherry"], _rand(x, y, 33))
			else:
				tree_tex = VILLAGE_TREES[_pick(x, y, 33, VILLAGE_TREES.size())]
			_add_prop(tree_tex, x, y, 1, 1, 1, holder)
		"^":
			var reed := _add_prop(ECO_TEX["reeds"], x, y, 1, 1, 2, holder)
			anims.append({"sprite": reed, "fps": 1.5, "phase": _rand(x, y, 34) * 2.0})
		"*":
			if biome == "desert" or biome == "badlands" or biome == "savanna" or biome == "oasis":
				var cactus := _add_prop(_from(BIOME_TEX["cactus"], _rand(x, y, 35)), x, y, 1, 1, 1, holder)
				_add_shadow(FOREST_TEX["small_shadow"], cactus.position + Vector2(1, -2), shade)
			else:
				var shroom := _add_prop(_from(ECO_TEX["giant_mushrooms"], _rand(x, y, 35)), x, y, 1, 1, 1, holder)
				_add_shadow(FOREST_TEX["tree_shadow"], shroom.position + Vector2(1, -2), shade)
		"!":
			var mill := _add_prop(ECO_TEX["windmill_body"], x, y, 3, 3, 1, holder)
			var blades := Sprite2D.new()
			blades.texture = ECO_TEX["windmill_blades"]
			blades.position = Vector2(0, -44)
			mill.add_child(blades)
			data["blades"].append(blades)
		"&":
			_add_prop(ECO_TEX["barn"], x, y, 4, 3, 1, holder)
		"$":
			var boat := _add_prop(ECO_TEX["boat"], x, y, 1, 1, 1, holder)
			var bob := boat.create_tween().set_loops()
			bob.tween_property(boat, "offset:y", boat.offset.y + 1.0, 0.9)
			bob.tween_property(boat, "offset:y", boat.offset.y, 0.9)
		")":
			_add_small_prop(ECO_TEX["scarecrow"], x, y, holder, shade)
		"(":
			_add_small_prop(ECO_TEX["hay_bale"], x, y, holder, shade)
		"F":
			var fountain := _add_prop(PLAZA_TEX["fountain"], x, y, 3, 2, 4, holder)
			anims.append({"sprite": fountain, "fps": 7.0, "phase": 0.0})
		"J":
			var stalls: Array = PLAZA_TEX["stalls"]
			_add_prop(stalls[int(variant_index.get(Vector2i(x, y), 0)) % stalls.size()], x, y, 3, 1, 1, holder)
		"e":
			_add_prop(PLAZA_TEX["bench"], x, y, 2, 1, 1, holder)
		"L":
			var lamp := _add_prop(PLAZA_TEX["lamp"], x, y, 1, 1, 2, holder)
			anims.append({"sprite": lamp, "fps": 3.0, "phase": _rand(x, y, 36) * 2.0})
			_add_shadow(FOREST_TEX["small_shadow"], lamp.position + Vector2(1, -2), shade)
		"g":
			var planters: Array = PLAZA_TEX["planters"]
			_add_small_prop(planters[_pick(x, y, 37, planters.size())], x, y, holder, shade)
		"w":
			_add_prop(TEX["well"], x, y, 1, 1, 1, holder)
		"y":
			_add_prop(TEX["beehive"], x, y, 1, 1, 1, holder)
		"q":
			_add_prop(TEX["sign"], x, y, 1, 1, 1, holder)
		"R", "U", "W", "M":
			var house_tex: Texture2D = SNOW_HOUSES[c] if (biome == "snow" or biome == "taiga") else TEX["house_" + c]
			_add_prop(house_tex, x, y, HOUSE_WIDTH[c], 3, 1, holder)
		"A":
			_add_prop(TEX["altar"], x, y, 1, 1, 1, holder)
		"Y":
			var torch := _add_prop(DUNGEON_TEX["brazier"], x, y, 1, 1, 3, holder)
			torch.position.y += 1.0
			anim_sprites.append({"sprite": torch, "fps": 10.0, "phase": _rand(x, y, 38) * 3.0})
		"i":
			var candles: Array = DUNGEON_TEX["candles"]
			var candle := _add_prop(candles[_pick(x, y, 39, candles.size())], x, y, 1, 1, 2, holder)
			anim_sprites.append({"sprite": candle, "fps": 5.0, "phase": _rand(x, y, 40) * 2.0})
		"I":
			var stand := _add_prop(DUNGEON_TEX["candelabra"], x, y, 1, 1, 2, holder)
			anim_sprites.append({"sprite": stand, "fps": 5.0, "phase": _rand(x, y, 41) * 2.0})
		"u":
			var pots: Array = DUNGEON_TEX["pots"]
			_add_small_prop(pots[_pick(x, y, 42, pots.size())], x, y, holder, shade)
		"K":
			_add_small_prop(DUNGEON_TEX["stone_block"], x, y, holder, shade)
		"{", "<":
			var steps := _add_prop(CAVE_TEX["exit"], x, y, 1, 1, 1, holder)
			steps.position.y += 1.0
		"?":
			var stone := _add_prop(DUNGEON_TEX["rune"], x, y, 1, 1, 2, holder)
			_add_shadow(FOREST_TEX["small_shadow"], stone.position + Vector2(1, -2), shade)
			for r in runes:
				if r["pos"] == Vector2(x + 0.5, y + 0.5) * TILE:
					return
			runes.append({"sprite": stone, "pos": Vector2(x + 0.5, y + 0.5) * TILE, "floor": floor_at(x, y), "lit": false})
	if extra_props.has(Vector2i(x, y)):
		_add_small_prop(extra_props[Vector2i(x, y)], x, y, holder, shade)


# ---------------------------------------------------------------- Hệ sinh thái: thú hiền, đom đóm

## Quái thường chết: một lúc sau con khác quay về chỗ cũ (để luyện cấp, lấy da, thịt, xương).
## Boss và bù nhìn thì không.
func _on_enemy_died(_enemy: Enemy, c: String, pos: Vector2) -> void:
	get_tree().create_timer(ENEMY_RESPAWN, false).timeout.connect(_respawn_enemy.bind(c, pos))


func _respawn_enemy(c: String, pos: Vector2) -> void:
	if not is_inside_tree():
		return
	# Người chơi đang đứng gần thì đợi thêm, không cho quái hiện ra ngay trước mặt
	if player != null and player.global_position.distance_to(to_global(pos)) < 220.0:
		get_tree().create_timer(15.0, false).timeout.connect(_respawn_enemy.bind(c, pos))
		return
	var enemy := (ENEMY_SCENES[c] as PackedScene).instantiate() as Enemy
	enemy.position = pos
	var cx := floori(pos.x / TILE)
	var cy := floori(pos.y / TILE)
	var fl := floor_at(cx, cy)
	if fl > 0:
		_apply_floor_power(enemy, fl)   # quái trong hầm ngục mạnh dần theo tầng
	_apply_enemy_level(enemy, c, cx, cy)
	_apply_area_look(enemy, c, cx, cy)
	enemy.died.connect(_on_enemy_died.bind(c, pos))
	entities.add_child(enemy)
	sleepers.append(enemy)


func _add_chest(x: int, y: int) -> void:
	var fl := floor_at(x, y)
	if fl < 0:
		return
	var chest := Chest.new()
	if fl == 0:
		# Rương ngoài trời: không khoá, loại rương và độ xịn theo khu (chest_odds, chest_level trong AREAS)
		var area := _area_at(x, y)
		chest.setup(Chest.roll_tier(area.get("chest_odds", { "normal": 60, "silver": 35, "gold": 5 })), 0, false, self,
			int(area.get("chest_level", 2)))
	else:
		chest.setup(Chest.roll_tier(Dungeon.FLOORS[fl - 1].get("chest_odds", {})), fl, true, self)
	chest.position = Vector2(x + 0.5, y + 0.5) * TILE + Vector2(0, 5)
	entities.add_child(chest)
	chests.append(chest)
	sleepers.append(chest)


## Đếm quái ban đầu của tầng fl (quái hồi sinh và lính Boss gọi ra không tính).
func _track_floor_enemy(enemy: Enemy, fl: int) -> void:
	floor_alive[fl] = int(floor_alive.get(fl, 0)) + 1
	enemy.died.connect(_on_floor_enemy_died.bind(fl))


func _on_floor_enemy_died(_enemy: Enemy, fl: int) -> void:
	floor_alive[fl] = maxi(int(floor_alive.get(fl, 0)) - 1, 0)
	if floor_alive[fl] > 0 or floor_cleared.has(fl):
		return
	floor_cleared[fl] = true
	var opened := 0
	for chest in chests:
		if is_instance_valid(chest) and chest.floor_index == fl and chest.locked:
			chest.unlock()
			opened += 1
	Game.shake(3.0)
	if opened > 0:
		Game.message.emit("Đã dọn sạch Tầng %d! %d rương báu trên tầng đã mở khoá, đi tới rương để mở." % [fl, opened])
	else:
		Game.message.emit("Đã dọn sạch Tầng %d!" % fl)


## Số quái ban đầu của tầng fl còn sống (rương mở khoá khi về 0).
func floor_enemies_left(fl: int) -> int:
	return int(floor_alive.get(fl, 0))


## Cấp quái mới sinh ra ở ô (x, y): Boss theo BOSS_LEVELS, bù nhìn không có cấp,
## quái thường theo tầng hầm ngục ("level" trong scripts/dungeon.gd) hoặc khu vực ngoài trời ("enemy_level" trong AREAS).
func _apply_enemy_level(enemy: Enemy, c: String, x: int, y: int) -> void:
	if c == "d" or c == "D":
		enemy.show_level = false
		return
	if BOSS_LEVELS.has(c):
		var boss_level: Array = BOSS_LEVELS[c]
		enemy.base_level = int(boss_level[1])
		enemy.set_level(int(boss_level[0]))
		return
	var fl := floor_at(x, y)
	var lv_range: Array = [1, 1]
	if fl > 0:
		lv_range = Dungeon.FLOORS[fl - 1].get("level", [1, 1])
	else:
		lv_range = _area_at(x, y).get("enemy_level", [1, 1])
	enemy.set_level(randi_range(int(lv_range[0]), int(lv_range[1])))


## Quái ngoài trời đổi tên, đổi màu theo khu (enemy_names, enemy_tint trong AREAS): sói tuyết, slime cát...
func _apply_area_look(enemy: Enemy, c: String, x: int, y: int) -> void:
	if floor_at(x, y) != 0:
		return
	var area := _area_at(x, y)
	var names: Dictionary = area.get("enemy_names", {})
	if names.has(c):
		enemy.display_name = names[c]
	if area.has("enemy_tint"):
		enemy.base_modulate = area["enemy_tint"]


## Quái ở tầng fl của hầm ngục: thêm giáp, tốc độ, màu theo "power" của tầng (scripts/dungeon.gd).
func _apply_floor_power(enemy: Enemy, fl: int) -> void:
	var data: Dictionary = Dungeon.FLOORS[fl - 1]
	enemy.apply_floor(data["power"], data["enemy_tint"], data["elite"])


func _spawn_critters() -> void:
	for i in WorldMap.AREAS.size():
		var area: Dictionary = WorldMap.AREAS[i]
		var critters: Dictionary = area.get("critters", {})
		var r: Rect2i = area["rect"]
		for kind in critters:
			for n in int(critters[kind]):
				var c := _critter_cell(r, kind, i)
				if c.x == -1:
					continue
				var critter = CRITTER_SCRIPT.new()
				critter.setup(kind)
				critter.level_ref = self
				critter.position = Vector2(c.x + 0.5, c.y + 0.5) * TILE + Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
				entities.add_child(critter)
				sleepers.append(critter)


func _critter_cell(r: Rect2i, kind: String, area_index: int = -1) -> Vector2i:
	var swimmer: bool = CRITTER_SCRIPT.SWIMMERS.has(kind)
	for attempt in 300:
		var x := rng.randi_range(r.position.x + 1, r.end.x - 2)
		var y := rng.randi_range(r.position.y + 1, r.end.y - 2)
		if area_index != -1 and _area_index(x, y) != area_index:
			continue
		var c := cell(x, y)
		if swimmer:
			if _water_inside(x, y):
				return Vector2i(x, y)
			continue
		if not ".,-%".contains(c) or plaza_cells.has(Vector2i(x, y)):
			continue
		if kind == "frog" and attempt < 200:
			var wet := false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(2, 0), Vector2i(-2, 0)]:
				if cell(x + d.x, y + d.y) == "~":
					wet = true
			if not wet:
				continue
		return Vector2i(x, y)
	return Vector2i(-1, -1)


## Đom đóm lấp lánh bay trên các khu có "fireflies".
func _add_fireflies() -> void:
	for area in WorldMap.AREAS:
		if not area.get("fireflies", false):
			continue
		var r: Rect2i = area["rect"]
		var p := CPUParticles2D.new()
		p.amount = 70
		p.lifetime = 5.0
		p.preprocess = 5.0
		p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		p.emission_rect_extents = Vector2(r.size) * TILE / 2.0
		p.position = (Vector2(r.position) + Vector2(r.size) / 2.0) * TILE
		p.gravity = Vector2.ZERO
		p.direction = Vector2.UP
		p.spread = 180.0
		p.initial_velocity_min = 2.0
		p.initial_velocity_max = 7.0
		p.scale_amount_min = 1.5
		p.scale_amount_max = 2.5
		var ramp := Gradient.new()   # hiện dần rồi tắt dần
		ramp.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
		ramp.colors = PackedColorArray([Color(0.85, 1.0, 0.4, 0.0), Color(0.9, 1.0, 0.5, 0.9), Color(0.85, 1.0, 0.4, 0.0)])
		p.color_ramp = ramp
		p.z_index = 20
		add_child(p)


func is_water(pos: Vector2) -> bool:
	var c := _to_cell(to_local(pos))
	var ch := cell(c.x, c.y)
	return ch == "~" or ch == "á"


## Chỗ đất liền gần pos nhất (người chơi lỡ đứng giữa nước mà không có thuyền). Không thấy thì trả về pos.
func nearest_land(pos: Vector2) -> Vector2:
	var c := _to_cell(to_local(pos))
	for r in range(1, 12):
		for dy in range(-r, r + 1):
			for dx in range(-r, r + 1):
				if maxi(absi(dx), absi(dy)) != r:
					continue
				var n := c + Vector2i(dx, dy)
				if astar.is_in_boundsv(n) and not astar.is_point_solid(n):
					return to_global(Vector2(n.x + 0.5, n.y + 0.5) * TILE)
	return pos


# ---------------------------------------------------------------- Hầm ngục: ánh sáng và đồ vật

func _setup_dungeon_lighting() -> void:
	# Hình tròn sáng ở giữa, mờ dần ra ngoài
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	gradient.add_point(0.45, Color(1, 1, 1, 0.45))
	light_texture = GradientTexture2D.new()
	light_texture.width = 128
	light_texture.height = 128
	light_texture.fill = GradientTexture2D.FILL_RADIAL
	light_texture.fill_from = Vector2(0.5, 0.5)
	light_texture.fill_to = Vector2(1.0, 0.5)
	light_texture.gradient = gradient
	darkness = CanvasModulate.new()
	darkness.color = Color.WHITE
	add_child(darkness)
	dungeon_lights = Node2D.new()
	dungeon_lights.name = "DungeonLights"
	dungeon_lights.visible = false
	add_child(dungeon_lights)
	# Phiến đá sàn hầm ngục: cắt mỗi ảnh 32x32 thành 4 ô 16x16
	for slab in DUNGEON_TEX["slabs"]:
		for qy in 2:
			for qx in 2:
				var atlas := AtlasTexture.new()
				atlas.atlas = slab
				atlas.region = Rect2(qx * TILE, qy * TILE, TILE, TILE)
				slab_tiles.append(atlas)


## Thêm một ngọn đèn. radius: bán kính vùng sáng (pixel). flicker: lập lòe như lửa.
func _add_light(pos: Vector2, radius: float, color: Color, energy: float, flicker: bool) -> PointLight2D:
	var light := PointLight2D.new()
	light.texture = light_texture
	light.texture_scale = radius * 2.0 / light_texture.width
	light.color = color
	light.energy = energy
	light.position = pos
	dungeon_lights.add_child(light)
	if flicker:
		flicker_lights.append({"light": light, "energy": energy, "phase": rng.randf() * TAU})
	return light


## Bệ thờ: có cột sáng tím chiếu xuống và một món đồ lơ lửng phía trên.
func _add_pedestal(x: int, y: int, kind: Pickup.Kind) -> void:
	var base := _add_prop(DUNGEON_TEX["pedestal"], x, y)
	base.position.y += 4.0
	var beam := Sprite2D.new()
	beam.texture = DUNGEON_TEX["light_beam"]
	beam.position = Vector2(0, -16 - DUNGEON_TEX["light_beam"].get_height() / 2.0)
	beam.z_index = 1
	var glow := CanvasItemMaterial.new()
	glow.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	glow.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	beam.material = glow
	base.add_child(beam)
	light_beams.append(beam)
	var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
	item.kind = kind
	item.value = ITEM_VALUES["c"] if kind == Pickup.Kind.POWER_CRYSTAL else ITEM_VALUES["h"]
	item.position = Vector2(x + 0.5, y + 0.5) * TILE + Vector2(0, -10)
	entities.add_child(item)
	_add_light(base.position + Vector2(0, -12), 56.0, MAGIC_LIGHT, 0.9, false)


## Cổng xoáy: vòng đá có xoáy tím quay tròn. Chạm vào là hoàn thành bản demo.
func _add_portal(x: int, y: int) -> void:
	var center := Vector2(x + 0.5, y + 0.5) * TILE
	var ring := Sprite2D.new()
	ring.texture = DUNGEON_TEX["portal_ring"]
	ring.position = center
	ring.z_index = -1
	var swirl := Sprite2D.new()
	swirl.texture = DUNGEON_TEX["portal_swirl"]
	swirl.z_index = -1
	ring.add_child(swirl)
	add_child(ring)
	move_child(ring, entities.get_index())  # nằm dưới nhân vật
	portal_swirls.append(swirl)
	portal_ring = ring
	altar_position = center
	_add_light(center, 100.0, MAGIC_LIGHT, 1.2, false)


## Bẫy gai '9' / lỗ phun lửa '/' (scripts/dungeon_trap.gd). Tầng càng sâu bẫy càng đau.
func _add_trap(kind: String, pos: Vector2, x: int, y: int) -> void:
	var fl := maxi(floor_at(x, y), 1)
	var trap := TRAP_SCRIPT.new() as DungeonTrap
	var damage := (Dungeon.SPIKE_DAMAGE if kind == "spike" else Dungeon.FIRE_DAMAGE) + fl * 2
	trap.setup(kind, damage, (x + y) * 0.3)   # các bẫy cạnh nhau lệch giờ một chút: thành "sóng"
	trap.position = pos
	if kind == "vent":
		trap.light = _add_light(pos + Vector2(0, -10), 64.0, Color(1.0, 0.55, 0.2), 0.0, false)
	add_child(trap)


## Tầng có bia cổ ngữ: lối xuống bị phong ấn tới khi thắp sáng hết bia.
func _seal_rune_stairs() -> void:
	for st in stairs:
		if st["kind"] != "down" or _rune_total(st["floor"]) == 0:
			continue
		st["sealed"] = true
		var seal := Sprite2D.new()
		seal.texture = CAVE_TEX["seal"]
		seal.hframes = 2
		seal.position = st["pos"] + Vector2(0, -3)
		entities.add_child(seal)
		village_anims.append({"sprite": seal, "fps": 3.0, "phase": 0.0})
		st["seal"] = seal


func _rune_total(fl: int) -> int:
	var n := 0
	for r in runes:
		if r["floor"] == fl:
			n += 1
	return n


## Đi tới gần bia cổ ngữ là thắp sáng nó. Sáng hết bia trong tầng thì mở lối xuống.
func _update_runes() -> void:
	for r in runes:
		if r["lit"] or r["floor"] != current_floor:
			continue
		if player.global_position.distance_to(r["pos"]) > 22.0:
			continue
		r["lit"] = true
		(r["sprite"] as Sprite2D).frame = 1
		_add_light(r["pos"] + Vector2(0, -8), 80.0, RUNE_LIGHT, 1.0, false)
		Game.burst(r["pos"] + Vector2(0, -8), RUNE_LIGHT, 14, 60.0, 30.0, 0.6, 1.5)
		var lit := 0
		for other in runes:
			if other["floor"] == current_floor and other["lit"]:
				lit += 1
		var total := _rune_total(current_floor)
		if lit < total:
			Game.message.emit("Bia cổ ngữ sáng lên! (%d/%d)" % [lit, total])
			continue
		Game.message.emit("Cả %d bia cổ ngữ đã sáng! Phong ấn lối xuống ở giữa mê cung đã vỡ." % total)
		Game.shake(4.0)
		for st in stairs:
			if st["floor"] == current_floor and st["kind"] == "down" and st["sealed"]:
				st["sealed"] = false
				var seal: Sprite2D = st["seal"]
				var tw := seal.create_tween()
				tw.tween_property(seal, "modulate:a", 0.0, 1.0)
				tw.tween_callback(seal.hide)


## Đứng trong đầm độc: đi chậm, cứ 0.6 giây mất một ít máu (lướt F qua thì không sao).
func _update_poison(delta: float) -> void:
	var c := _to_cell(to_local(player.global_position))
	if cell(c.x, c.y) != "]":
		player.ground_slow = 1.0
		poison_timer = 0.25
		return
	player.ground_slow = Dungeon.POISON_SLOW
	poison_timer -= delta
	if poison_timer <= 0.0:
		poison_timer = 0.6
		player.take_poison(Dungeon.POISON_DAMAGE + current_floor)


## Đổi sang khu khác (thế giới bên ngoài / tầng hầm ngục): đổi độ tối, đèn, lời nhắc lần đầu tới.
func _enter_floor(fl: int) -> void:
	current_floor = fl
	if fl > 0:
		_set_weather("")   # trong hầm ngục không có tuyết, cánh hoa
	if (fl > 0) != in_dungeon:
		_set_in_dungeon(fl > 0)
	var tw := create_tween()
	tw.tween_property(darkness, "color", Color.WHITE if fl == 0 else Dungeon.FLOORS[fl - 1]["dark"], 0.8)
	if fl == 0 or visited_floors.has(fl):
		return
	visited_floors[fl] = true
	entered_area2 = true
	if fl == 1:
		Game.message.emit("Hầm Ngục Cổ có 5 tầng, càng xuống sâu quái càng mạnh, tầng 5 có Boss! Hố đen dưới sàn: xuống tầng dưới. Cầu thang sáng trên tường: đi lên.")
	Game.message.emit(Dungeon.FLOORS[fl - 1]["message"])


## Chỗ đứng an toàn quanh điểm p (cách 2 ô, ưu tiên phía dưới), dùng khi đi cầu thang lên.
func _arrival_near(p: Vector2) -> Vector2:
	var c := _to_cell(p)
	for o in [Vector2i(0, 2), Vector2i(1, 2), Vector2i(-1, 2), Vector2i(0, -2), Vector2i(2, 0), Vector2i(-2, 0),
			Vector2i(2, 2), Vector2i(-2, 2), Vector2i(2, -2), Vector2i(-2, -2), Vector2i(0, 3), Vector2i(3, 0)]:
		var n: Vector2i = c + o
		var ch := cell(n.x, n.y)
		if not SOLID.contains(ch) and not "9/]><{".contains(ch) and not _blocked(n):
			return Vector2(n.x + 0.5, n.y + 0.5) * TILE
	return p + Vector2(0, 2 * TILE)


## Vị trí cầu thang loại kind ở tầng fl (Vector2.INF nếu không có).
func _stairs_pos(fl: int, kind: String) -> Vector2:
	for st in stairs:
		if st["floor"] == fl and st["kind"] == kind:
			return st["pos"]
	return Vector2.INF


func _open_portal() -> void:
	if portal_open:
		return
	portal_open = true
	Game.message.emit("Malakar đã gục ngã! Cổng Xoáy ở cuối điện thờ đã mở, bước vào để chiến thắng!")
	Game.shake(5.0)
	if portal_ring:
		var tw := portal_ring.create_tween()
		tw.tween_property(portal_ring, "modulate", Color.WHITE, 1.2)


## Vào / ra hầm ngục: làm tối màn hình và bật đèn (chuyển dần trong 0.8 giây).
## Có Đuốc trong túi thì vòng sáng quanh người to hơn.
func _update_player_light() -> void:
	if player_light == null or player == null:
		return
	var has_torch := player.count_item("torch") > 0
	var radius: float = Dungeon.FLOORS[current_floor - 1]["light"] if current_floor > 0 else 100.0
	player_light.texture_scale = radius * (1.7 if has_torch else 1.0) * 2.0 / light_texture.width
	player_light.energy = 0.95 if has_torch else 0.7


func _set_in_dungeon(value: bool) -> void:
	in_dungeon = value
	dungeon_lights.visible = value
	if player_light:
		player_light.enabled = value
	if not value and player:
		player.ground_slow = 1.0


func _animate(delta: float) -> void:
	anim_time += delta
	# Thác nước chảy, cối xay gió quay
	for fall in waterfalls:
		fall.frame = int(anim_time * 8.0) % 3
	for blades in windmill_blades:
		blades.rotation += delta * 1.2
	# Đài phun nước, cột đèn ở quảng trường, cây sậy, bếp lửa...
	for a in village_anims:
		var anim_sprite: Sprite2D = a["sprite"]
		if is_instance_valid(anim_sprite):
			anim_sprite.frame = int(anim_time * float(a["fps"]) + float(a["phase"])) % anim_sprite.hframes
	for cc in chunks:
		var data: Dictionary = chunks[cc]
		for fall in data["falls"]:
			fall.frame = int(anim_time * 8.0) % 3
		for blades in data["blades"]:
			blades.rotation += delta * 1.2
		for a in data["anims"]:
			var s: Sprite2D = a["sprite"]
			s.frame = int(anim_time * float(a["fps"]) + float(a["phase"])) % s.hframes
	if not in_dungeon:
		return
	# Lửa đuốc, nến
	for a in anim_sprites:
		var sprite: Sprite2D = a["sprite"]
		sprite.frame = int(anim_time * float(a["fps"]) + float(a["phase"])) % sprite.hframes
	# Đèn lập lòe
	for f in flicker_lights:
		var light: PointLight2D = f["light"]
		var phase: float = f["phase"]
		light.energy = float(f["energy"]) * (0.88 + 0.08 * sin(anim_time * 9.0 + phase) + 0.04 * sin(anim_time * 23.0 + phase * 2.0))
	# Cổng xoáy quay, cột sáng nhấp nháy nhẹ
	for swirl in portal_swirls:
		swirl.rotation += delta * 2.5
	for beam in light_beams:
		beam.modulate.a = 0.75 + 0.25 * sin(anim_time * 2.0)


func _process(delta: float) -> void:
	_animate(delta)
	if player == null:
		return
	_update_chunks()
	sleep_timer -= delta
	if sleep_timer <= 0.0:
		sleep_timer = 0.25
		_update_sleepers()
	_update_weather_position()
	if player.is_dead:
		_set_station("")
		return
	_update_station()
	_update_cave()
	var tile := _to_cell(to_local(player.global_position))
	# Biển báo: đi tới gần thì hiện chữ
	for sign_data in signs:
		var near: bool = player.global_position.distance_to(sign_data["pos"]) < 22.0
		if near and not sign_data["near"]:
			Game.message.emit(sign_data["text"])
		sign_data["near"] = near
	_update_area(tile.x, tile.y)
	if not entered_arena and arena_rect.has_point(tile) and cell(tile.x, tile.y) == ":":
		entered_arena = true
		Game.area_entered.emit("Đấu Trường Đá Cổ")
	var fl := floor_of(player.global_position)
	if fl != -1 and fl != current_floor:
		_enter_floor(fl)
	if fl == 0 and tile != fog_cell:
		fog_cell = tile
		_reveal_around(tile)
	if not cave_busy and fl == current_floor and not is_water(player.global_position):
		save_pos = player.position    # chỗ đứng để lưu tài khoản (không lưu lúc đang ở trên thuyền)
		save_floor = current_floor
	seal_msg_cd = maxf(seal_msg_cd - delta, 0.0)
	if in_dungeon:
		_update_player_light()
		_update_poison(delta)
		_update_runes()
	if not won and portal_open and altar_position != Vector2.INF and player.global_position.distance_to(altar_position) < 14.0:
		won = true
		Game.game_won.emit()


## Quái, thú, cây thu hoạch, rương ở xa người chơi thì tạm ngủ (không chạy, không vẽ) cho nhẹ máy.
func _update_sleepers() -> void:
	var me := player.global_position
	var far := SLEEP_DISTANCE * SLEEP_DISTANCE
	var i := sleepers.size() - 1
	while i >= 0:
		var n = sleepers[i]
		if not is_instance_valid(n) or (n as Node).is_queued_for_deletion():
			sleepers.remove_at(i)
		else:
			var node := n as Node2D
			var awake := node.global_position.distance_squared_to(me) < far
			var asleep := node.process_mode == Node.PROCESS_MODE_DISABLED
			if awake and asleep:
				node.process_mode = Node.PROCESS_MODE_INHERIT
				node.visible = bool(node.get_meta("was_visible", true))
			elif not awake and not asleep:
				node.set_meta("was_visible", node.visible)
				node.visible = false
				node.process_mode = Node.PROCESS_MODE_DISABLED
		i -= 1


# ---------------------------------------------------------------- Bản đồ khám phá dần

## Mở bản đồ quanh ô c (bán kính FOG_RADIUS).
func _reveal_around(c: Vector2i) -> void:
	if explored.is_empty():
		return
	var r := FOG_RADIUS
	for dy in range(-r, r + 1):
		var y := c.y + dy
		if y < 0 or y >= overworld_size.y:
			continue
		var span := int(sqrt(float(r * r - dy * dy)))
		for x in range(maxi(c.x - span, 0), mini(c.x + span, overworld_size.x - 1) + 1):
			var i := y * overworld_size.x + x
			if explored[i] == 0:
				explored[i] = 1
				fog_changes.append(Vector2i(x, y))


## Ô (x, y) của thế giới bên ngoài đã khám phá chưa.
func is_explored(x: int, y: int) -> bool:
	if x < 0 or y < 0 or x >= overworld_size.x or y >= overworld_size.y or explored.is_empty():
		return false
	return explored[y * overworld_size.x + x] != 0


func _reveal_rect(r: Rect2i) -> void:
	for y in range(maxi(r.position.y, 0), mini(r.end.y, overworld_size.y)):
		for x in range(maxi(r.position.x, 0), mini(r.end.x, overworld_size.x)):
			explored[y * overworld_size.x + x] = 1


# ---------------------------------------------------------------- Thời tiết theo khu (tuyết, cánh hoa, đom đóm)

func _set_weather(kind: String) -> void:
	if kind == weather_kind:
		return
	weather_kind = kind
	if weather == null:
		weather = CPUParticles2D.new()
		weather.z_index = 30
		weather.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
		weather.emission_rect_extents = Vector2(360, 210)
		add_child(weather)
	weather.emitting = kind != ""
	if kind == "":
		return
	var ramp := Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.15, 0.85, 1.0])
	match kind:
		"snow":
			weather.amount = 160
			weather.lifetime = 6.0
			weather.direction = Vector2(0.25, 1.0)
			weather.spread = 15.0
			weather.gravity = Vector2(0, 4)
			weather.initial_velocity_min = 14.0
			weather.initial_velocity_max = 26.0
			weather.scale_amount_min = 1.0
			weather.scale_amount_max = 2.0
			ramp.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0.9), Color(1, 1, 1, 0)])
		"petals":
			weather.amount = 50
			weather.lifetime = 7.0
			weather.direction = Vector2(0.6, 1.0)
			weather.spread = 30.0
			weather.gravity = Vector2(0, 3)
			weather.initial_velocity_min = 8.0
			weather.initial_velocity_max = 18.0
			weather.scale_amount_min = 1.5
			weather.scale_amount_max = 2.5
			ramp.colors = PackedColorArray([Color(1, 0.7, 0.85, 0), Color(1, 0.72, 0.86, 0.95), Color(1, 0.8, 0.9, 0.9), Color(1, 0.8, 0.9, 0)])
		"spores":
			weather.amount = 50
			weather.lifetime = 6.0
			weather.direction = Vector2.UP
			weather.spread = 180.0
			weather.gravity = Vector2(0, -2)
			weather.initial_velocity_min = 2.0
			weather.initial_velocity_max = 6.0
			weather.scale_amount_min = 1.5
			weather.scale_amount_max = 2.5
			ramp.colors = PackedColorArray([Color(0.85, 0.6, 1, 0), Color(0.9, 0.7, 1, 0.85), Color(0.85, 0.65, 1, 0.8), Color(0.85, 0.6, 1, 0)])
		_:   # fireflies
			weather.amount = 45
			weather.lifetime = 5.0
			weather.direction = Vector2.UP
			weather.spread = 180.0
			weather.gravity = Vector2.ZERO
			weather.initial_velocity_min = 2.0
			weather.initial_velocity_max = 7.0
			weather.scale_amount_min = 1.5
			weather.scale_amount_max = 2.5
			ramp.colors = PackedColorArray([Color(0.85, 1, 0.4, 0), Color(0.9, 1, 0.5, 0.9), Color(0.9, 1, 0.5, 0.9), Color(0.85, 1, 0.4, 0)])
	weather.color_ramp = ramp
	weather.restart()


func _update_weather_position() -> void:
	if weather != null and weather.emitting and player.camera != null:
		weather.global_position = player.camera.get_screen_center_position()


## Đi vào miệng hang (sau khi hạ Boss) thì xuống Tầng 1. Trong hầm ngục:
## cầu thang sáng trên tường '{' (Tầng 1) ra lại cửa hang, '<' lên tầng trên, hố '>' xuống tầng dưới.
func _update_cave() -> void:
	if cave_busy:
		return
	var me := player.global_position
	if gate_open and current_floor == 0 and cave_entrance != Vector2.INF and me.distance_to(cave_entrance) < 9.0:
		_go_through_cave(cave_exit + Vector2(0, 2 * TILE), Dungeon.floor_name(1), 1)
		return
	for st in stairs:
		if st["floor"] != current_floor or me.distance_to(st["pos"]) >= 9.0:
			continue
		var fl: int = st["floor"]
		match st["kind"]:
			"exit":
				_go_through_cave(cave_entrance + Vector2(0, 2 * TILE), "Đấu Trường Đá Cổ", 0)
			"up":
				var down := _stairs_pos(fl - 1, "down")
				if down != Vector2.INF:
					_go_through_cave(_arrival_near(down), Dungeon.floor_name(fl - 1), fl - 1)
			"down":
				if st["sealed"]:
					if seal_msg_cd <= 0.0:
						seal_msg_cd = 3.0
						Game.message.emit("Lối xuống bị phong ấn. Hãy thắp sáng hết bia cổ ngữ trong mê cung!")
					return
				var up := _stairs_pos(fl + 1, "up")
				if up != Vector2.INF:
					_go_through_cave(up + Vector2(0, 2 * TILE), Dungeon.floor_name(fl + 1), fl + 1)
		return


## Màn hình tối dần, đưa người chơi sang chỗ mới (khu dest_floor) rồi sáng lại.
func _go_through_cave(dest: Vector2, area_name: String, dest_floor: int) -> void:
	if dest.x == INF:
		return
	cave_busy = true
	player.stop_for_cutscene()
	var tw := create_tween()
	tw.tween_property(fade_rect, "color:a", 1.0, 0.35)
	tw.tween_callback(func():
		player.set_camera_limits(region_pixels(dest_floor))
		player.teleport_to(to_global(dest))
		Game.area_entered.emit(area_name))
	tw.tween_interval(0.15)
	tw.tween_property(fade_rect, "color:a", 0.0, 0.4)
	tw.tween_callback(func(): cave_busy = false)


## Đặt bộ lửa trại (vật phẩm trong túi) xuống đất: thành bếp lửa nướng đồ ăn được.
## Trả về chữ báo lỗi, "" = đặt được.
func place_station(kind: String, world_pos: Vector2) -> String:
	var local := to_local(world_pos)
	if not is_open(world_pos, 5.0) or is_water(world_pos):
		return "Không đặt được ở đây"
	for st in stations:
		if local.distance_to(st["pos"]) < 40.0:
			return "Gần trạm khác quá"
	match kind:
		"fire":
			var pit := Sprite2D.new()
			pit.texture = CRAFT_TEX["fire_pit"]
			pit.hframes = 3
			pit.centered = false
			pit.offset = Vector2(-CRAFT_TEX["fire_pit"].get_width() / 6.0, -CRAFT_TEX["fire_pit"].get_height())
			pit.position = local + Vector2(0, 6)
			entities.add_child(pit)
			village_anims.append({"sprite": pit, "fps": 6.0, "phase": 0.0})
			stations.append({"pos": local, "kind": "fire"})
			placed_fires.append(local)
			if in_dungeon or (dungeon_column != -1 and local.x > (dungeon_column + 1) * TILE):
				_add_light(local + Vector2(0, -4), 80.0, CANDLE_LIGHT, 1.0, true)
		_:
			return "Không đặt được"
	Game.burst(world_pos, Color(1.0, 0.7, 0.3), 10, 50.0, 60.0, 0.4, 1.5)
	return ""


## Đứng gần nồi luyện thuốc / bàn chế tạo thì mở bảng chế tạo (HUD nghe tín hiệu Game.station_changed).
func _update_station() -> void:
	var near := ""
	var best := STATION_RANGE
	for st in stations:
		var d: float = player.global_position.distance_to(st["pos"])
		if d < best:
			best = d
			near = st["kind"]
	_set_station(near)


func _set_station(kind: String) -> void:
	if kind != current_station:
		current_station = kind
		Game.station_changed.emit(kind)


func _update_area(tx: int, ty: int) -> void:
	var index := _area_index(tx, ty)
	if not area_started:
		area_started = true
		current_area = index
		visited_areas[index] = true
		_set_weather(str(WorldMap.AREAS[index].get("weather", "")) if index != -1 and current_floor == 0 else "")
		return
	if index == current_area:
		return
	current_area = index
	_set_weather(str(WorldMap.AREAS[index].get("weather", "")) if index != -1 and current_floor == 0 else "")
	if index == -1:
		return
	var area: Dictionary = WorldMap.AREAS[index]
	Game.area_entered.emit(area["name"])
	if not visited_areas.has(index) and str(area.get("message", "")) != "":
		Game.message.emit(area["message"])
	visited_areas[index] = true


func _on_boss_defeated() -> void:
	if current_floor > 0:
		_open_portal()   # Boss hầm ngục (Malakar) chết
		return
	if gate_open:
		return
	_open_cave_seal(true)


func _open_cave_seal(announce: bool) -> void:
	gate_open = true
	if announce:
		Game.message.emit("Phong ấn cửa hang đã vỡ! Đi vào hang ở vách bắc đấu trường để xuống Hầm Ngục Cổ (5 tầng)")
		Game.shake(4.0)
	for col in gate_body.get_children():
		if col is CollisionShape2D:
			col.set_deferred("disabled", true)
	for c in gate_cells:
		astar.set_point_solid(c, false)
		astar_boat.set_point_solid(c, false)
	for s in gate_sprites:
		if announce:
			var tw := s.create_tween()
			tw.tween_property(s, "modulate:a", 0.0, 1.0)
		else:
			s.modulate.a = 0.0


# ---------------------------------------------------------------- Lưu tài khoản

func get_save_data() -> Dictionary:
	var data := {
		"map_v": MAP_VERSION,
		"gate_open": gate_open,
		"visited_areas": visited_areas.keys(),
		"visited_floors": visited_floors.keys(),
		"fires": placed_fires.duplicate(),
	}
	if not explored.is_empty():
		data["fog"] = Marshalls.raw_to_base64(explored.compress(FileAccess.COMPRESSION_DEFLATE))
	if save_pos != Vector2.INF:
		data["pos"] = save_pos
		data["floor"] = save_floor
	return data


func apply_save_data(d: Dictionary) -> void:
	loaded_save = true
	# Save từ trước khi mở rộng thế giới: đổi chỗ đứng, bếp lửa sang toạ độ mới, mở sẵn bản đồ cũ
	var old_map := int(d.get("map_v", 1)) < MAP_VERSION
	if bool(d.get("gate_open", false)) and not gate_open:
		_open_cave_seal(false)
	for a in d.get("visited_areas", []):
		visited_areas[int(a)] = true
	for f in d.get("visited_floors", []):
		visited_floors[int(f)] = true
	for p in d.get("fires", []):
		if p is Vector2:
			place_station("fire", to_global(_from_old_map(p) if old_map else p))
	var fog: String = str(d.get("fog", ""))
	if fog != "" and not full_account:
		var bytes := Marshalls.base64_to_raw(fog).decompress(explored.size(), FileAccess.COMPRESSION_DEFLATE)
		if bytes.size() == explored.size():
			explored = bytes
	if old_map:
		_reveal_rect(WorldMap.CORE)
		if full_account and player != null:
			player.add_item("boat")          # Tài Khoản Full có sẵn thuyền và cần câu để đi khắp thế giới mới
			player.add_item("fishing_rod")
	# Về lại chỗ đứng lần trước (chỗ đó phải đi được, tầng hầm ngục thì cửa hang phải mở rồi)
	var pos = d.get("pos", null)
	var fl := int(d.get("floor", 0))
	if player == null or not pos is Vector2 or fl < 0 or fl > floor_rects.size() or (fl > 0 and not gate_open):
		return
	if old_map:
		pos = _from_old_map(pos)
	var world_pos := to_global(pos)
	if floor_of(world_pos) != fl or not is_open(world_pos, 4.0):
		return
	player.set_camera_limits(region_pixels(fl))
	player.teleport_to(world_pos)
	save_pos = pos
	save_floor = fl
	if fl > 0:
		_enter_floor(fl)


## Toạ độ (pixel) trong bản đồ trước khi mở rộng -> toạ độ mới. Thế giới cũ nằm ở giữa thế giới mới,
## các tầng hầm ngục bị đẩy sang phải theo chiều rộng mới.
func _from_old_map(p: Vector2) -> Vector2:
	if p.x < OLD_OVERWORLD.x * TILE and p.y < OLD_OVERWORLD.y * TILE:
		return p + Vector2(WorldMap.CORE.position) * TILE
	return p + Vector2(overworld_size.x - OLD_OVERWORLD.x, 0) * TILE


func _current_area_name() -> String:
	if current_floor > 0:
		return Dungeon.floor_name(current_floor)
	var c := _to_cell(player.position)
	var index := _area_index(c.x, c.y)
	if index == -1:
		return "Làng Khởi Nguyên"
	return WorldMap.AREAS[index]["name"]
