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
## Bản đồ có 3 dải: dải trên (Làng Ven Hồ + Rừng Thông), dải giữa (Làng Khởi Nguyên + Rừng Hoang
## + đấu trường) và dải dưới (Xóm Ruộng + Đầm Lầy Nấm). Tên, kiểu cảnh và thú của từng khu
## nằm trong AREAS bên dưới. Hầm Ngục Cổ (5 tầng, scripts/dungeon.gd) là bản đồ riêng, khi chạy game
## được ghép vào xa về phía đông, ngăn cách bằng đá đặc: chỉ vào được qua cửa hang G và cầu thang,
## camera và bản đồ nhỏ chỉ thấy khu đang đứng (thế giới bên ngoài hoặc tầng hầm ngục hiện tại).

const TILE := 16

## Các khu vực (toạ độ theo ô: x, y, rộng, cao). Đi vào khu mới sẽ hiện tên khu.
## biome: kiểu cảnh (village, forest, pine = rừng thông, swamp = đầm lầy).
## critters: số thú hiền mỗi loại (rabbit thỏ, deer nai, bird chim, butterfly bướm, frog ếch, duck vịt).
## lilies: tỉ lệ lá sen trên mặt nước. fireflies: có đom đóm bay.
## enemy_level: cấp quái trong khu [thấp nhất, cao nhất] (chữ "Lv" trên đầu quái, cấp càng cao quái càng mạnh).
const AREAS := [
	{
		"name": "Làng Ven Hồ", "rect": Rect2i(0, 0, 31, 32), "biome": "village",
		"message": "Làng chài bên hồ. Vườn cà rốt và vườn táo ở phía nam làng.",
		"critters": { "duck": 4, "bird": 5, "butterfly": 5 }, "lilies": 0.12,
	},
	{
		"name": "Rừng Thông", "rect": Rect2i(31, 0, 52, 32), "biome": "pine", "enemy_level": [4, 7],
		"message": "Rừng thông: có nai, thỏ... và bầy sói! Quả mọng, thảo dược hái được để hồi máu.",
		"critters": { "rabbit": 7, "deer": 4, "bird": 5, "butterfly": 5, "duck": 2 }, "lilies": 0.08,
	},
	{
		"name": "Làng Khởi Nguyên", "rect": Rect2i(0, 32, 31, 32), "biome": "village",
		"message": "",
		"critters": { "bird": 4, "butterfly": 4 },
	},
	{
		"name": "Rừng Hoang", "rect": Rect2i(31, 32, 52, 32), "biome": "forest", "enemy_level": [1, 4],
		"message": "Hãy mạnh lên và đánh bại kẻ canh giữ ở phía đông!",
		"critters": { "rabbit": 4, "bird": 4, "butterfly": 4 }, "lilies": 0.1,
	},
	{
		"name": "Xóm Ruộng", "rect": Rect2i(0, 64, 31, 32), "biome": "village",
		"message": "Ruộng lúa, vườn rau, vườn táo. Đi qua cây chín để thu hoạch, cây sẽ chín lại sau một lúc.",
		"critters": { "bird": 8, "butterfly": 6, "rabbit": 2 },
	},
	{
		"name": "Đầm Lầy Nấm", "rect": Rect2i(31, 64, 52, 32), "biome": "swamp", "enemy_level": [6, 9],
		"message": "Đầm lầy ẩm ướt, đầy nấm và ếch. Coi chừng slime và heo rừng!",
		"critters": { "frog": 10, "butterfly": 3, "bird": 2 }, "lilies": 0.22, "fireflies": true,
	},
]
## Màu phủ lên mặt đất của từng kiểu cảnh (1 = giữ nguyên màu)
const BIOME_TINT := {
	"pine": Color(0.86, 0.96, 0.9),
	"swamp": Color(0.72, 0.84, 0.64),
}
const SWAMP_TREE_COLOR := Color(0.85, 0.93, 0.85)

## Chữ trên các biển báo 'q', theo thứ tự xuất hiện (đọc từ trên xuống, trái sang phải).
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

## Dân làng 'v', theo thứ tự xuất hiện trên bản đồ (đọc từ trên xuống, trái sang phải).
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
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTT#####################
Tt.n.t..................,,.t..TTTTTTTTTTTTTTTTTTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTTT#####################
T..........~~~~~~~~~~~...n....TTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTT#####################
T....1....~~~~~~~~~~~~~......tTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTT#####################
T........~~~~~~~~~~~~~~~..2...TTTTTTTTTT..T1...TTTTTTTTTTTT~~~TTTTTTTT,...TTTTTTTTT#####################
T......^~~~~~~~~~~~~~~~~~...,.TTTTTTTTTT.........TTTTTTTTTTT~~TTTTTT.......HxxTTTTT#####################
T..,...^~~~~~~~~~~~~~~~~~^....TTTTTTTT.......X...,TTTTTTTTTT~~TTTT3...j....xxxTTTTT#####################
T.....2.~~~~~~[[[~~~~~~~~^....TTTTTTTT...........,3TTTTTTTTT~~TTT,.....,...xxx..TTT#####################
T.1.....~~~~~~~[~~~$~~~~~.....TTTTTTT..................TTTTT~~.......----......TTTT#####################
T......^~~~~$~~[~~~~~~~~~.....TTTTTTTT,,.....---......3...T~~~X-------.v.....,zTTTT#####################
T.,1....~~~~~~~[~~~~~~~~~..1..TTTTTTTT.....---.-X----------[[--.1...lk..--....TTTTT#####################
T........~~~~~~[~~~~~~~~......TTTTTTTTTT.---....1TTT......~~~1...TT...,..-...TTTTTT#####################
Tt........^..kv_.l....^.....t.TTTTTTTTTT.-....T.TTTTTTTTT~~~T..TTTT.,.T.,-2TTTTTTTT#####################
T..Hxx........._.k......Hxx...TTTTTTTTT..-..TTTTTTTTTTTTT~~...,.......T..-.TTTTTTTT#####################
T..xxx........._........xxx...TTTTT..,...-.TTTTTTTTTTTTT~~~..,.....s3.T..-.TTTTTTTT#####################
T..xxx.......t._..w...t.xxx...TT.........-.TTTTTTTTTTTT~~~.2........,TTT.-.TTTTTTTT#####################
T..._........n._..,.,..,._.,..TT....q....-..TTTTTTTTTTT~~.....2.N..,TTTT.-.TTTTTTTT#####################
T..._.........._...v....._..q..........s.-2TTTTTTTTTTT~~~T..1..,...TTTTT.-2.TTTTTTT#####################
T.____________________________.-----------,TTTTTTTTTTT~~TTTTTTTTTTTTTTTT.--.TTTTTTT#####################
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
T________+++++xxx+++++________.----------......-...-----.......TTTTT.......----s---:::::::::B:::::::####
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
T______________________________-------------2,.---...s...^^..^..^^.---.....b..TTTTT#####################
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
T..._......_......_...t......tTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
T..._______________...........TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT#####################
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
const WELL_BUCKET := { "item": "water", "tex": preload("res://assets/craft/bucket.png"), "frames": 2, "grow": 20.0,
	"amount": [1, 2], "reach": 18.0, "tree": true }
const STATION_RANGE := 30.0   # đứng gần trạm chế tạo bao nhiêu pixel thì mở bảng chế tạo
## Sói, heo rừng bị hạ sẽ quay lại chỗ cũ sau bấy nhiêu giây (khi người chơi không đứng gần)
const ENEMY_RESPAWN := 120.0   # quái thường hồi sinh sau bao nhiêu giây (Boss và bù nhìn thì không)
## Cấp Boss: [cấp hiện trên đầu, cấp gốc của chỉ số trong file cảnh]. Gorrak giữ nguyên sức mạnh,
## Malakar mạnh hơn bản gốc 8 cấp cho xứng với quái tầng 5. Quái thường: cấp theo "enemy_level" của khu vực
## (AREAS ở trên) hoặc "level" của tầng hầm ngục (scripts/dungeon.gd).
const BOSS_LEVELS := { "B": [10, 10], "}": [30, 22] }
const WATER_CHARS := "~[$"    # các ô có nước bên dưới (cầu gỗ và thuyền nằm trên nước)
const CROP_CHARS := "456"     # cây trồng trên ruộng (có đất cày)

const SOLID := "T#~orxRUWMfwqytHVklzjYZIuKFeLJg17*!&$)(C@08|?"   # | dung nham, ? bia cổ ngữ (hầm ngục)
const HOUSE_WIDTH := { "R": 4, "U": 4, "W": 4, "M": 3 }

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


func _ready() -> void:
	rng.seed = 2026  # cùng một "hạt giống" => hoa / cây luôn mọc ở cùng chỗ
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
	var fade_layer := CanvasLayer.new()
	fade_layer.layer = 20
	add_child(fade_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0)
	fade_rect.size = Vector2(4000, 4000)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_layer.add_child(fade_rect)
	Game.boss_defeated.connect(_on_boss_defeated)
	call_deferred("_announce_start")


func _announce_start() -> void:
	Game.area_entered.emit("Làng Khởi Nguyên")
	Game.message.emit("Chuột phải để đi / đánh quái, F: lướt. Lên cấp để mở kỹ năng Q W E R (K: xem kỹ năng, Esc: hướng dẫn)")
	Game.message.emit("Đi tới gần dân làng để nghe họ nói chuyện. Luyện tập ở bãi tập rồi lên đường về phía đông!")


func _parse_map() -> void:
	rows = MAP.strip_edges().split("\n")
	for i in rows.size():
		rows[i] = rows[i].strip_edges()
	var width := 0
	for r in rows:
		width = maxi(width, r.length())
	overworld_size = Vector2i(width, rows.size())
	_add_dungeon_floors()
	for r in rows:
		width = maxi(width, r.length())
	map_size = Vector2i(width, rows.size())
	for y in rows.size():
		var gx := rows[y].find("G")
		if gx != -1:
			gate_column = gx
			break
	for y in rows.size():
		var ax := rows[y].find(":")
		if ax != -1:
			arena_column = ax if arena_column == -1 else mini(arena_column, ax)
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


## Tìm các ô thuộc quảng trường: bắt đầu từ các ô '=' / '+' rồi lan sang các đồ vật
## đặt trên sân (đài phun nước, ghế, đèn, dân làng...) để chúng cũng có nền đá bên dưới.
func _find_plaza() -> void:
	var todo: Array[Vector2i] = []
	for y in map_size.y:
		for x in map_size.x:
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
	if mask == 15 and rng.randf() < 0.4:
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
	if c == "T":
		return FOREST_FLOOR[rng.randi() % FOREST_FLOOR.size()]  # nền rừng tối dưới tán cây
	if WATER_CHARS.contains(c):
		return _water_texture(x, y)
	if WALL_CHARS.contains(c):
		# Ô tường có ô trống ở dưới thì vẽ mặt tường, còn lại vẽ nóc tường
		var face := not WALL_CHARS.contains(cell(x, y + 1))
		if dungeon_column != -1 and x > dungeon_column:
			var walls: Array = DUNGEON_TEX["wall_face" if face else "wall_top"]
			return walls[rng.randi() % walls.size()]
		return TEX["wall_face"] if face else TEX["wall_top"]
	if c == "_":
		return TEX["path"]
	if c == ",":
		return TEX["grass_flower"]
	if arena_column == -1 or x < arena_column:
		var roll := rng.randf()
		if roll < 0.025:
			return TEX["grass_flower"]
		return TEX["grass_tuft"] if roll < 0.14 else TEX["grass"]
	if dungeon_column == -1 or x <= dungeon_column:
		return TEX["stone2"] if rng.randf() < 0.08 else TEX["stone"]
	# Hầm ngục: phiến đá lớn 2x2 ô, mỗi khối 2x2 chọn một kiểu phiến
	var block := posmod(floori(x / 2.0) * 7 + floori(y / 2.0) * 13, 4)
	return slab_tiles[block * 4 + posmod(y, 2) * 2 + posmod(x, 2)]


## Chọn ô nước có bờ phù hợp dựa vào 4 ô xung quanh.
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
		key = "c"
	return TEX["water_" + key]


## Đọc các ô đường đất, bãi đá, viền tối (tên file có số nên tải bằng vòng lặp).
func _load_forest_tiles() -> void:
	for mask in 16:
		dirt_tiles.append(load("res://assets/forest/dirt_%d.png" % mask))
		rocky_tiles.append(load("res://assets/forest/rocky_%d.png" % mask))
		plaza_tiles.append(load("res://assets/plaza/plaza_%d.png" % mask))
	for side in ["n", "e", "s", "w", "ne", "nw", "se", "sw"]:
		shade_tiles[side] = load("res://assets/forest/shade_%s.png" % side)
	for mask in 16:
		poison_textures.append(load("res://assets/dungeon/poison_%d.png" % mask))
		lava_textures.append(load("res://assets/dungeon/lava_%d.png" % mask))


func _build_ground() -> void:
	var ground := Node2D.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	var detail := Node2D.new()  # đường đất, bãi đá, viền tối... vẽ đè lên cỏ
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
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			var fl := floor_at(x, y)
			if fl == -1 or (fl > 0 and _deep_rock(x, y)):
				continue   # đá đặc giữa / trong lòng các tầng: để nền đen
			var area := _area_at(x, y)
			tile_tint = BIOME_TINT.get(area.get("biome", ""), Color.WHITE)
			if fl > 0:
				tile_tint = Dungeon.FLOORS[fl - 1]["tint"]
			_add_tile_sprite(ground, _floor_texture(x, y), x, y)
			if plaza_cells.has(Vector2i(x, y)):
				_add_tile_sprite(detail, _plaza_texture(x, y), x, y)
			if c == "-" or c == "p":
				_add_tile_sprite(detail, dirt_tiles[_terrain_mask(x, y, "-p_" + CROP_CHARS)], x, y)
				if c == "p":
					_add_tile_sprite(detail, FOREST_TEX["sprout"], x, y)
			elif CROP_CHARS.contains(c):
				# ruộng: đất cày có rãnh
				_add_tile_sprite(detail, dirt_tiles[_terrain_mask(x, y, "-p" + CROP_CHARS)], x, y)
				_add_tile_sprite(detail, ECO_TEX["furrows"], x, y)
			elif c == "[":
				_add_tile_sprite(detail, ECO_TEX["dock"], x, y)
			elif c == "~" and rng.randf() < float(area.get("lilies", 0.0)) and _water_inside(x, y):
				var lilies: Array = ECO_TEX["lilies"]
				_add_tile_sprite(detail, lilies[rng.randi() % lilies.size()], x, y)
			elif c == "%":
				_add_tile_sprite(detail, rocky_tiles[_terrain_mask(x, y, "%")], x, y)
			elif c == "n":
				_add_tile_sprite(detail, TEX["mushroom"], x, y)
			elif c == "f":
				_add_tile_sprite(detail, _fence_texture(x, y), x, y)
			if c != "T" and (arena_column == -1 or x < arena_column):
				_add_forest_shade(detail, x, y)
			if dungeon_column != -1 and x > dungeon_column:
				if c == "]":
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


## Khu vực chứa ô (x, y). Không thuộc khu nào (đấu trường, hầm ngục) thì trả về {}.
func _area_at(x: int, y: int) -> Dictionary:
	var i := _area_index(x, y)
	return AREAS[i] if i != -1 else {}


func _area_index(x: int, y: int) -> int:
	for i in AREAS.size():
		var r: Rect2i = AREAS[i]["rect"]
		if r.has_point(Vector2i(x, y)):
			return i
	return -1


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


## Viền tối mờ trên ô cỏ nằm sát nền rừng (giống bóng rừng đổ ra bãi cỏ).
func _add_forest_shade(parent: Node, x: int, y: int) -> void:
	var n := cell(x, y - 1) == "T"
	var s := cell(x, y + 1) == "T"
	var w := cell(x - 1, y) == "T"
	var e := cell(x + 1, y) == "T"
	if n:
		_add_tile_sprite(parent, shade_tiles["n"], x, y)
	if s:
		_add_tile_sprite(parent, shade_tiles["s"], x, y)
	if w:
		_add_tile_sprite(parent, shade_tiles["w"], x, y)
	if e:
		_add_tile_sprite(parent, shade_tiles["e"], x, y)
	if not n and not w and cell(x - 1, y - 1) == "T":
		_add_tile_sprite(parent, shade_tiles["nw"], x, y)
	if not n and not e and cell(x + 1, y - 1) == "T":
		_add_tile_sprite(parent, shade_tiles["ne"], x, y)
	if not s and not w and cell(x - 1, y + 1) == "T":
		_add_tile_sprite(parent, shade_tiles["sw"], x, y)
	if not s and not e and cell(x + 1, y + 1) == "T":
		_add_tile_sprite(parent, shade_tiles["se"], x, y)


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


## Vật trang trí đứng (cây, bụi, đá, nhà...) được sắp xếp theo chiều dọc
## để nhân vật có thể đi "sau" tán cây / mái nhà.
## (x, y) là ô trên cùng bên trái; width_tiles / height_tiles là kích thước chân đế.
## frames: số khung hình nằm ngang trong ảnh (ảnh động như thác nước).
func _add_prop(tex: Texture2D, x: int, y: int, width_tiles: int = 1, height_tiles: int = 1,
		frames: int = 1) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.hframes = frames
	s.centered = false
	s.position = Vector2((x + width_tiles / 2.0) * TILE, (y + height_tiles) * TILE)  # gốc ở đáy
	s.offset = Vector2(-tex.get_width() / float(frames) / 2.0, -tex.get_height())
	entities.add_child(s)
	return s


## Bóng mờ dưới chân cây / đồ vật.
func _add_shadow(tex: Texture2D, pos: Vector2) -> void:
	var sh := Sprite2D.new()
	sh.texture = tex
	sh.position = pos
	shadows.add_child(sh)


## Cây rừng: lệch vị trí một chút cho tự nhiên, có bóng. Cây sâu trong rừng thì tối hơn
## và thỉnh thoảng bỏ trống để lộ nền rừng tối (giống rừng rậm).
func _add_tree(x: int, y: int) -> void:
	var deep := true
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var n := cell(x + dx, y + dy)
			if n != "T" and n != "#":
				deep = false
	if deep and rng.randf() < 0.4:
		return
	var biome: String = _area_at(x, y).get("biome", "forest")
	var tex: Texture2D
	var roll := rng.randf()
	match biome:
		"pine":   # rừng thông: hầu hết là cây thông
			tex = FOREST_TREES[3 + rng.randi() % 2] if roll < 0.85 else FOREST_TREES[rng.randi() % 3]
		"swamp":  # đầm lầy: cây liễu rủ, cây chết khô
			var willows: Array = ECO_TEX["willows"]
			if roll < 0.55:
				tex = willows[rng.randi() % willows.size()]
			elif roll < 0.75:
				tex = ECO_TEX["dead_tree"]
			else:
				tex = FOREST_TREES[rng.randi() % 3]
		_:
			tex = FOREST_TREES[3 + rng.randi() % 2] if roll < 0.3 else FOREST_TREES[rng.randi() % 3]
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.flip_h = rng.randf() < 0.5
	s.offset = Vector2(-tex.get_width() / 2.0, -tex.get_height())
	s.position = Vector2((x + 0.5) * TILE + rng.randf_range(-4.0, 4.0), (y + 1) * TILE - 1.0 + rng.randf_range(-4.0, 1.0))
	if deep:
		s.modulate = DEEP_TREE_COLOR
	if biome == "swamp":
		s.modulate *= SWAMP_TREE_COLOR
	entities.add_child(s)
	_add_shadow(FOREST_TEX["tree_shadow"], s.position + Vector2(2, -2))


## Đồ vật nhỏ trong rừng (thùng, gốc cây...) có bóng dưới chân.
func _add_small_prop(tex: Texture2D, x: int, y: int) -> Sprite2D:
	var s := _add_prop(tex, x, y)
	_add_shadow(FOREST_TEX["small_shadow"], s.position + Vector2(1, -2))
	return s


func _build_walls() -> void:
	# Gộp các ô chặn liền nhau theo hàng ngang thành một khối va chạm
	var walls := StaticBody2D.new()
	walls.name = "Walls"
	walls.collision_layer = 1
	walls.collision_mask = 0
	add_child(walls)
	for y in map_size.y:
		var x := 0
		while x < map_size.x:
			if SOLID.contains(cell(x, y)):
				var start := x
				while x < map_size.x and SOLID.contains(cell(x, y)):
					x += 1
				_add_rect_shape(walls, start, y, x - start)
			else:
				x += 1

	# Cổng phong ấn: thân va chạm riêng để có thể mở ra
	gate_body = StaticBody2D.new()
	gate_body.name = "Gate"
	gate_body.collision_layer = 1
	gate_body.collision_mask = 0
	add_child(gate_body)
	for y in map_size.y:
		for x in map_size.x:
			if cell(x, y) == "G":
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


# ---------------------------------------------------------------- Tìm đường (chuột phải để đi)

func _build_pathfinding() -> void:
	astar.region = Rect2i(0, 0, map_size.x, map_size.y)
	astar.cell_size = Vector2(TILE, TILE)
	astar.offset = Vector2(TILE / 2.0, TILE / 2.0)  # điểm nằm ở giữa ô
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.update()
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			if SOLID.contains(c) or c == "G":
				astar.set_point_solid(Vector2i(x, y), true)


func _to_cell(local_pos: Vector2) -> Vector2i:
	return Vector2i(floori(local_pos.x / TILE), floori(local_pos.y / TILE))


func _blocked(c: Vector2i) -> bool:
	return not astar.is_in_boundsv(c) or astar.is_point_solid(c)


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


## Đoạn thẳng từ a tới b có đi qua được không (chừa khoảng clearance pixel hai bên).
func segment_clear(a: Vector2, b: Vector2, clearance: float = 6.0) -> bool:
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


## Có được dịch chuyển tức thời từ a tới b không (không cho nhảy qua cổng phong ấn khi chưa mở).
func can_teleport(a: Vector2, b: Vector2) -> bool:
	if not is_open(b, 5.0):
		return false
	if dungeon_column != -1:
		var wall_x := (dungeon_column + 1) * TILE
		if (to_local(a).x < wall_x) != (to_local(b).x < wall_x):
			return false   # hầm ngục chỉ vào được bằng cửa hang
	return true


## Đường đi từ from tới to (toạ độ thế giới), vòng qua vật cản.
## Trả về các điểm cần đi qua (không gồm điểm đang đứng). Không tới được thì đi gần nhất có thể.
func find_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	var start := _to_cell(to_local(from))
	var goal := _to_cell(to_local(to))
	if not astar.is_in_boundsv(goal):
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
	if exact and segment_clear(from, to):
		result.append(to)
		return result
	var points := astar.get_point_path(start, goal, true)
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
		while j > i and not segment_clear(current, points[j]):
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
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			var pos := Vector2(x + 0.5, y + 0.5) * TILE
			match c:
				"T":
					_add_tree(x, y)
				"o":
					_add_small_prop(TEX["bush"] if rng.randf() < 0.6 else FOREST_TEX["berry_bush"], x, y)
				"r":
					var rocks := [TEX["rock"], FOREST_TEX["rock_moss"], FOREST_TEX["rock_grey_moss"]]
					_add_small_prop(rocks[rng.randi() % rocks.size()], x, y)
				"k":
					_add_small_prop(FOREST_TEX["crate"], x, y)
				"l":
					_add_small_prop(FOREST_TEX["barrel"] if rng.randf() < 0.5 else FOREST_TEX["barrel2"], x, y)
				"z":
					var stump = HARVEST_SCRIPT.new()
					stump.setup(STUMP_WOOD)
					stump.position = Vector2((x + 0.5) * TILE, (y + 1) * TILE)
					entities.add_child(stump)
					_add_shadow(FOREST_TEX["small_shadow"], stump.position + Vector2(1, -2))
				"j":
					var fire := _add_prop(FOREST_TEX["campfire"], x, y)
					var flicker := fire.create_tween().set_loops()
					flicker.tween_property(fire, "modulate", Color(1.3, 1.15, 0.9), 0.12)
					flicker.tween_property(fire, "modulate", Color(1.0, 0.9, 0.85), 0.18)
					stations.append({"pos": fire.position + Vector2(0, -6), "kind": "fire"})
				"8":
					var pit := _add_prop(CRAFT_TEX["fire_pit"], x, y, 1, 1, 3)
					village_anims.append({"sprite": pit, "fps": 6.0, "phase": 0.0})
					stations.append({"pos": pit.position + Vector2(0, -6), "kind": "fire"})
				"0":
					var stove := _add_prop(CRAFT_TEX["oven"], x, y, 1, 1, 3)
					village_anims.append({"sprite": stove, "fps": 5.0, "phase": 0.0})
					_add_shadow(FOREST_TEX["small_shadow"], stove.position + Vector2(1, -2))
					stations.append({"pos": stove.position + Vector2(0, -6), "kind": "stove"})
				"{", "<":
					var steps := _add_prop(CAVE_TEX["exit"], x, y)
					steps.position.y += 1.0
					_add_light(pos + Vector2(0, -4), 70.0, Color(1.0, 0.95, 0.8), 1.0, false)
					stairs.append({"pos": pos, "kind": "exit" if c == "{" else "up", "floor": floor_at(x, y)})
					if c == "{":
						cave_exit = pos
				">":
					_add_light(pos, 46.0, Color(0.7, 0.75, 1.0), 0.6, false)
					stairs.append({"pos": pos, "kind": "down", "floor": floor_at(x, y), "sealed": false})
				"9":
					_add_trap("spike", pos, x, y)
				"/":
					_add_trap("vent", pos, x, y)
				"?":
					var stone := _add_prop(DUNGEON_TEX["rune"], x, y, 1, 1, 2)
					_add_shadow(FOREST_TEX["small_shadow"], stone.position + Vector2(1, -2))
					runes.append({"sprite": stone, "pos": pos, "floor": floor_at(x, y), "lit": false})
				"|":
					if posmod(x * 3 + y * 5, 7) == 0:
						_add_light(pos, 44.0, Color(1.0, 0.5, 0.2), 0.8, true)
				"]":
					if posmod(x * 5 + y * 3, 9) == 0:
						_add_light(pos, 34.0, Color(0.5, 1.0, 0.35), 0.5, true)
				"H":
					_add_prop(FOREST_TEX["cabin_grey" if cabin_count % 2 == 0 else "cabin_red"], x, y, 3, 3)
					cabin_count += 1
				"V":
					var fall := _add_prop(FOREST_TEX["waterfall"], x, y, 3, 3, 3)
					fall.position.y += 4.0  # bọt nước tràn xuống mép hồ
					waterfalls.append(fall)
				"t":
					_add_prop(VILLAGE_TREES[rng.randi() % VILLAGE_TREES.size()], x, y)
				"^":
					var reed := _add_prop(ECO_TEX["reeds"], x, y, 1, 1, 2)
					village_anims.append({"sprite": reed, "fps": 1.5, "phase": rng.randf() * 2.0})
				"*":
					var shrooms: Array = ECO_TEX["giant_mushrooms"]
					var shroom := _add_prop(shrooms[rng.randi() % shrooms.size()], x, y)
					_add_shadow(FOREST_TEX["tree_shadow"], shroom.position + Vector2(1, -2))
				"!":
					var mill := _add_prop(ECO_TEX["windmill_body"], x, y, 3, 3)
					var blades := Sprite2D.new()
					blades.texture = ECO_TEX["windmill_blades"]
					blades.position = Vector2(0, -44)
					mill.add_child(blades)
					windmill_blades.append(blades)
				"&":
					_add_prop(ECO_TEX["barn"], x, y, 4, 3)
				"$":
					var boat := _add_prop(ECO_TEX["boat"], x, y)
					var bob := boat.create_tween().set_loops()
					bob.tween_property(boat, "offset:y", boat.offset.y + 1.0, 0.9)
					bob.tween_property(boat, "offset:y", boat.offset.y, 0.9)
				")":
					_add_small_prop(ECO_TEX["scarecrow"], x, y)
				"(":
					_add_small_prop(ECO_TEX["hay_bale"], x, y)
				"F":
					var fountain := _add_prop(PLAZA_TEX["fountain"], x, y, 3, 2, 4)
					village_anims.append({"sprite": fountain, "fps": 7.0, "phase": 0.0})
				"J":
					var stalls: Array = PLAZA_TEX["stalls"]
					_add_prop(stalls[stall_count % stalls.size()], x, y, 3, 1)
					stall_count += 1
				"e":
					_add_prop(PLAZA_TEX["bench"], x, y, 2, 1)
				"L":
					var lamp := _add_prop(PLAZA_TEX["lamp"], x, y, 1, 1, 2)
					village_anims.append({"sprite": lamp, "fps": 3.0, "phase": rng.randf() * 2.0})
					_add_shadow(FOREST_TEX["small_shadow"], lamp.position + Vector2(1, -2))
				"g":
					var planters: Array = PLAZA_TEX["planters"]
					_add_small_prop(planters[rng.randi() % planters.size()], x, y)
				"v":
					var npc = NPC_SCRIPT.new()
					var npc_data: Dictionary = NPC_DATA[npc_count] if npc_count < NPC_DATA.size() else {}
					npc.setup(npc_data)
					npc_count += 1
					npc.position = pos
					npc.level_ref = self
					entities.add_child(npc)
					if npc_data.get("prop", "") == "anvil":
						_add_small_prop(CRAFT_TEX["anvil"], x - 1, y)   # cái đe cạnh thợ rèn
				"w":
					_add_prop(TEX["well"], x, y)
					var bucket = HARVEST_SCRIPT.new()
					bucket.setup(WELL_BUCKET)
					bucket.position = Vector2((x + 1) * TILE + 2, (y + 1) * TILE + 2)
					entities.add_child(bucket)
				"C":
					var pot := _add_prop(CRAFT_TEX["cauldron"], x, y, 1, 1, 3)
					village_anims.append({"sprite": pot, "fps": 5.0, "phase": 0.0})
					_add_shadow(FOREST_TEX["small_shadow"], pot.position + Vector2(1, -2))
					stations.append({"pos": pot.position + Vector2(0, -6), "kind": "pot"})
				"@":
					var bench := _add_prop(CRAFT_TEX["workbench"], x, y, 2, 1)
					_add_shadow(FOREST_TEX["tree_shadow"], bench.position + Vector2(1, -2))
					stations.append({"pos": bench.position + Vector2(0, -6), "kind": "bench"})
				"y":
					_add_prop(TEX["beehive"], x, y)
				"q":
					_add_prop(TEX["sign"], x, y)
					var text: String = SIGN_TEXTS[signs.size()] if signs.size() < SIGN_TEXTS.size() else "..."
					signs.append({"pos": pos, "text": text, "near": false})
				"R", "U", "W", "M":
					_add_prop(TEX["house_" + c], x, y, HOUSE_WIDTH[c], 3)
				"A":
					_add_prop(TEX["altar"], x, y)
					altar_position = pos
				"Y":
					var torch := _add_prop(DUNGEON_TEX["brazier"], x, y, 1, 1, 3)
					torch.position.y += 1.0
					anim_sprites.append({"sprite": torch, "fps": 10.0, "phase": rng.randf() * 3.0})
					_add_light(pos + Vector2(0, -4), 90.0, Color(1.0, 0.62, 0.3), 1.1, true)
				"i":
					var candles: Array = DUNGEON_TEX["candles"]
					var candle := _add_prop(candles[rng.randi() % candles.size()], x, y, 1, 1, 2)
					anim_sprites.append({"sprite": candle, "fps": 5.0, "phase": rng.randf() * 2.0})
					_add_light(pos + Vector2(0, -2), 44.0, CANDLE_LIGHT, 0.85, true)
				"I":
					var stand := _add_prop(DUNGEON_TEX["candelabra"], x, y, 1, 1, 2)
					anim_sprites.append({"sprite": stand, "fps": 5.0, "phase": rng.randf() * 2.0})
					_add_light(pos + Vector2(0, -14), 60.0, CANDLE_LIGHT, 0.95, true)
				"u":
					var pots: Array = DUNGEON_TEX["pots"]
					_add_small_prop(pots[rng.randi() % pots.size()], x, y)
				"K":
					_add_small_prop(DUNGEON_TEX["stone_block"], x, y)
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
				if c == "1" or c == "7":
					_add_shadow(FOREST_TEX["tree_shadow" if c == "7" else "small_shadow"], plant.position + Vector2(1, -2))
			if ENEMY_SCENES.has(c):
				var enemy := (ENEMY_SCENES[c] as PackedScene).instantiate() as Enemy
				enemy.position = pos
				var fl := floor_at(x, y)
				if fl > 0 and c != "}":
					_apply_floor_power(enemy, fl)   # quái hầm ngục mạnh dần theo tầng
				if c == "}":
					portal_open = false               # cổng xoáy chỉ mở khi hạ Boss hầm ngục
				if fl > 0:
					_track_floor_enemy(enemy, fl)     # hạ hết quái của tầng thì rương mở khoá
				_apply_enemy_level(enemy, c, x, y)
				if c == "D":
					enemy.armor = 6
					enemy.display_name = "Bù nhìn giáp"
				if c != "B" and c != "D" and c != "}":
					enemy.died.connect(_on_enemy_died.bind(c, pos))
				entities.add_child(enemy)
			elif ITEM_KINDS.has(c):
				var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
				item.kind = ITEM_KINDS[c]
				item.value = ITEM_VALUES[c]
				item.position = pos
				entities.add_child(item)

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
	var fl := floor_at(floori(pos.x / TILE), floori(pos.y / TILE))
	if fl > 0:
		_apply_floor_power(enemy, fl)   # quái trong hầm ngục mạnh dần theo tầng
	_apply_enemy_level(enemy, c, floori(pos.x / TILE), floori(pos.y / TILE))
	enemy.died.connect(_on_enemy_died.bind(c, pos))
	entities.add_child(enemy)


## Rương báu ' trong hầm ngục: loại rương (thường, bạc, vàng, kim cương) chọn ngẫu nhiên theo
## "chest_odds" của tầng. Rương khoá tới khi hạ hết quái của tầng đó.
func _add_chest(x: int, y: int) -> void:
	var fl := floor_at(x, y)
	if fl <= 0:
		return
	var chest := Chest.new()
	chest.setup(Chest.roll_tier(Dungeon.FLOORS[fl - 1].get("chest_odds", {})), fl, true, self)
	chest.position = Vector2(x + 0.5, y + 0.5) * TILE + Vector2(0, 5)
	entities.add_child(chest)
	chests.append(chest)


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


## Quái ở tầng fl của hầm ngục: thêm giáp, tốc độ, màu theo "power" của tầng (scripts/dungeon.gd).
func _apply_floor_power(enemy: Enemy, fl: int) -> void:
	var data: Dictionary = Dungeon.FLOORS[fl - 1]
	enemy.apply_floor(data["power"], data["enemy_tint"], data["elite"])


## Thả thú hiền vào từng khu theo số lượng trong AREAS.
func _spawn_critters() -> void:
	for area in AREAS:
		var critters: Dictionary = area.get("critters", {})
		var r: Rect2i = area["rect"]
		for kind in critters:
			for i in int(critters[kind]):
				var c := _critter_cell(r, kind)
				if c.x == -1:
					continue
				var critter = CRITTER_SCRIPT.new()
				critter.setup(kind)
				critter.level_ref = self
				critter.position = Vector2(c.x + 0.5, c.y + 0.5) * TILE + Vector2(rng.randf_range(-4, 4), rng.randf_range(-4, 4))
				entities.add_child(critter)


## Tìm một ô hợp với loài thú: vịt ở giữa hồ, ếch gần nước, các loài khác trên bãi cỏ trống.
func _critter_cell(r: Rect2i, kind: String) -> Vector2i:
	for attempt in 300:
		var x := rng.randi_range(r.position.x + 1, r.end.x - 2)
		var y := rng.randi_range(r.position.y + 1, r.end.y - 2)
		var c := cell(x, y)
		if kind == "duck":
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
	for area in AREAS:
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


## Ô ở vị trí pos (toạ độ thế giới) có phải nước không (vịt chỉ bơi trên nước).
func is_water(pos: Vector2) -> bool:
	var c := _to_cell(to_local(pos))
	return cell(c.x, c.y) == "~"


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
	# Thác nước chảy
	for fall in waterfalls:
		fall.frame = int(anim_time * 8.0) % 3
	for blades in windmill_blades:
		blades.rotation += delta * 1.2
	# Đài phun nước, cột đèn ở quảng trường, cây sậy
	for a in village_anims:
		var anim_sprite: Sprite2D = a["sprite"]
		anim_sprite.frame = int(anim_time * float(a["fps"]) + float(a["phase"])) % anim_sprite.hframes
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
	if player == null or player.is_dead:
		_set_station("")
		return
	_update_station()
	_update_cave()
	var tile_x := player.global_position.x / TILE
	# Biển báo: đi tới gần thì hiện chữ
	for sign_data in signs:
		var near: bool = player.global_position.distance_to(sign_data["pos"]) < 22.0
		if near and not sign_data["near"]:
			Game.message.emit(sign_data["text"])
		sign_data["near"] = near
	_update_area(floori(tile_x), floori(player.global_position.y / TILE))
	if not entered_arena and arena_column != -1 and tile_x > arena_column + 1 and tile_x < overworld_size.x:
		entered_arena = true
		Game.area_entered.emit("Đấu Trường Đá Cổ")
	var fl := floor_of(player.global_position)
	if fl != -1 and fl != current_floor:
		_enter_floor(fl)
	seal_msg_cd = maxf(seal_msg_cd - delta, 0.0)
	if in_dungeon:
		_update_player_light()
		_update_poison(delta)
		_update_runes()
	if not won and portal_open and altar_position != Vector2.INF and player.global_position.distance_to(altar_position) < 14.0:
		won = true
		Game.game_won.emit()


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


## Hiện tên khu vực khi người chơi đi sang khu mới (lần đầu tới còn hiện thêm lời giới thiệu).
func _update_area(tx: int, ty: int) -> void:
	var index := _area_index(tx, ty)
	if not area_started:
		area_started = true
		current_area = index
		visited_areas[index] = true
		return
	if index == current_area:
		return
	current_area = index
	if index == -1:
		return
	var area: Dictionary = AREAS[index]
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
	gate_open = true
	Game.message.emit("Phong ấn cửa hang đã vỡ! Đi vào hang ở vách bắc đấu trường để xuống Hầm Ngục Cổ (5 tầng)")
	Game.shake(4.0)
	for col in gate_body.get_children():
		if col is CollisionShape2D:
			col.set_deferred("disabled", true)
	for y in map_size.y:
		for x in map_size.x:
			if cell(x, y) == "G":
				astar.set_point_solid(Vector2i(x, y), false)
	for s in gate_sprites:
		var tw := s.create_tween()
		tw.tween_property(s, "modulate:a", 0.0, 1.0)
