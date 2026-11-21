class_name Level
extends Node2D
## Màn chơi được vẽ từ bản đồ chữ (MAP) bên dưới.
## Hình ảnh: bộ Kenney Tiny Town (làng, cỏ, nhà), Kenney Roguelike RPG (đấu trường, đồ vật)
## và cây rừng, thác nước, đường đất do Claude vẽ (assets/forest).
## Bạn có thể tự sửa bản đồ: mỗi ký tự là một ô 16x16 pixel.
##
##   T  cây rừng (chặn đường, nền rừng tối)   #  tường đá (chặn đường)
##   ~  nước (chặn đường)         G  cổng phong ấn (mở khi hạ Boss)
##   o  bụi cây (chặn đường)      r  tảng đá (chặn đường)
##   .  cỏ      ,  cỏ có hoa      :  sàn đá đấu trường     ;  sàn hầm ngục (phiến đá)
##   _  đường lát đá    f  hàng rào    w  giếng    q  biển báo (đọc khi đi tới gần)
##   y  tổ ong    t  cây trong làng    n  nấm (trang trí)
##   d  bù nhìn tập đánh    D  bù nhìn có giáp (thử Thương phá giáp)
##   -  đường đất    %  bãi đất đá    p  luống rau (trên đất)
##   k  thùng gỗ    l  thùng tròn    z  gốc cây    j  lửa trại    (đều chặn đường)
##   H  nhà gỗ trong rừng (rộng 3, cao 3)    V  thác nước (rộng 3, cao 3, đặt ngay trên hồ '~')
##   Hầm ngục (bên phải cổng G, tối, có ánh sáng):
##   Y  đuốc treo tường (đặt lên ô tường)   Z  cờ treo tường (đặt lên ô tường)
##   i  nến dưới đất (đi qua được)   I  chân nến cao   u  bình gốm   K  khối đá   S  xương (trang trí)
##   E  bệ thờ có cột sáng + pha lê sức mạnh   Q  bệ thờ có cột sáng + bình máu
##   O  cổng xoáy (đích đến của bản demo)
##   Quảng trường giữa làng (nơi người chơi xuất hiện):
##   =  sân lát đá    +  đá hoa văn màu vàng (lát quanh đài phun nước)
##   F  đài phun nước (rộng 3, cao 2: F x x / x x x)    J  sạp hàng (rộng 3: J x x)
##   e  ghế dài (rộng 2: e x)    L  cột đèn    g  chậu hoa
##   v  dân làng: đi tới gần để nghe nói chuyện (tên, lời thoại, ngoại hình ở NPC_DATA)
##   Đồ vật đặt trên sân đá (F J e L g v P q k l) tự có nền đá bên dưới.
##   Cây thu hoạch (đi tới gần cây chín là hái, đồ vào túi, một lúc sau cây chín lại):
##   1  bụi quả mọng    2  thảo dược    3  nấm rừng    7  cây táo
##   4  lúa mì    5  cà rốt    6  bí ngô   (3 loại này trồng trên ruộng, tự có đất cày bên dưới)
##   Rừng, hồ, đầm lầy, ruộng:
##   [  cầu gỗ / cầu tàu (đi được, đặt trên nước)    $  thuyền (trên nước)    ^  cây sậy (trang trí)
##   *  nấm khổng lồ    !  cối xay gió (rộng 3, cao 3)    &  nhà kho (rộng 4, cao 3)
##   )  bù nhìn đuổi chim    (  bó rơm    X  sói    N  heo rừng
##   Chế tạo (đi tới gần là mở bảng chế tạo, công thức ở scripts/recipes.gd):
##   C  nồi luyện thuốc    @  bàn chế tạo (rộng 2: @ x)
##   Cạnh mỗi giếng 'w' có xô nước: đi tới là lấy được Bình nước (một lúc sau xô đầy lại).
##   R U W M  nhà (góc trên bên trái), các ô 'x' là phần còn lại của ngôi nhà
##            R, U, W rộng 4 ô, M rộng 3 ô, tất cả cao 3 ô
##   P  vị trí bắt đầu của người chơi
##   s  slime    b  dơi    a  cung thủ xương    B  Boss
##   h  bình máu    m  bình năng lượng    c  pha lê sức mạnh
##   A  bệ thờ cổ (cũng dùng làm đích đến được, giống cổng xoáy O)
##
## Bản đồ có 3 dải: dải trên (Làng Ven Hồ + Rừng Thông), dải giữa (Làng Khởi Nguyên + Rừng Hoang
## + đấu trường + hầm ngục) và dải dưới (Xóm Ruộng + Đầm Lầy Nấm). Tên, kiểu cảnh và thú của từng khu
## nằm trong AREAS bên dưới. Bên phải cổng G là hầm ngục, quái bên phải cổng tự động mạnh hơn (elite).

const TILE := 16

## Các khu vực (toạ độ theo ô: x, y, rộng, cao). Đi vào khu mới sẽ hiện tên khu.
## biome: kiểu cảnh (village, forest, pine = rừng thông, swamp = đầm lầy).
## critters: số thú hiền mỗi loại (rabbit thỏ, deer nai, bird chim, butterfly bướm, frog ếch, duck vịt).
## lilies: tỉ lệ lá sen trên mặt nước. fireflies: có đom đóm bay.
const AREAS := [
	{
		"name": "Làng Ven Hồ", "rect": Rect2i(0, 0, 31, 32), "biome": "village",
		"message": "Làng chài bên hồ. Vườn cà rốt và vườn táo ở phía nam làng.",
		"critters": { "duck": 4, "bird": 5, "butterfly": 5 }, "lilies": 0.12,
	},
	{
		"name": "Rừng Thông", "rect": Rect2i(31, 0, 52, 32), "biome": "pine",
		"message": "Rừng thông: có nai, thỏ... và bầy sói! Quả mọng, thảo dược hái được để hồi máu.",
		"critters": { "rabbit": 7, "deer": 4, "bird": 5, "butterfly": 5, "duck": 2 }, "lilies": 0.08,
	},
	{
		"name": "Làng Khởi Nguyên", "rect": Rect2i(0, 32, 31, 32), "biome": "village",
		"message": "",
		"critters": { "bird": 4, "butterfly": 4 },
	},
	{
		"name": "Rừng Hoang", "rect": Rect2i(31, 32, 52, 32), "biome": "forest",
		"message": "Hãy mạnh lên và đánh bại kẻ canh giữ ở phía đông!",
		"critters": { "rabbit": 4, "bird": 4, "butterfly": 4 }, "lilies": 0.1,
	},
	{
		"name": "Xóm Ruộng", "rect": Rect2i(0, 64, 31, 32), "biome": "village",
		"message": "Ruộng lúa, vườn rau, vườn táo. Đi qua cây chín để thu hoạch, cây sẽ chín lại sau một lúc.",
		"critters": { "bird": 8, "butterfly": 6, "rabbit": 2 },
	},
	{
		"name": "Đầm Lầy Nấm", "rect": Rect2i(31, 64, 52, 32), "biome": "swamp",
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
	"Góc chế tạo: đi tới nồi luyện thuốc hoặc bàn chế tạo là mở bảng chế tạo. Lấy nước ở xô cạnh giếng.",
	"Phía đông là Rừng Hoang. Quái vật đang tràn tới, hãy cẩn thận!",
	"Quảng trường Làng Khởi Nguyên. Bắc: Làng Ven Hồ. Nam: Xóm Ruộng. Đông: Rừng Hoang. Chuột phải để đi, F để lướt né.",
	"Bãi tập: thử đánh và kỹ năng Q W E R lên bù nhìn. Bù nhìn có khiên rất cứng, Thương phá giáp dễ nhất.",
	"Xóm Ruộng: ruộng lúa, vườn cà rốt, bí ngô và vườn táo. Hái xong một lúc cây sẽ chín lại.",
	"Phía đông là Đầm Lầy Nấm. Nhiều nấm và thảo dược, nhưng có slime và heo rừng.",
	"Đầm Lầy Nấm. Đất lầy ẩm ướt, đi trên cầu gỗ để qua ao.",
]

## Dân làng 'v', theo thứ tự xuất hiện trên bản đồ (đọc từ trên xuống, trái sang phải).
## look: chỉ số ngoại hình giống màn hình tạo nhân vật (xem scripts/character_parts.gd).
## wander: bán kính đi dạo (pixel), 0 = đứng yên.
const NPC_DATA := [
	{
		"name": "Thợ săn Lâm",
		"lines": [
			"Rừng Thông có nai, thỏ hiền lắm, đừng làm tụi nó sợ.",
			"Bầy sói sống ở bãi đá phía đông nam. Đi một mình thì cẩn thận!",
			"Quả mọng trong rừng ăn hồi máu đó, cứ hái thoải mái.",
			"Hạ sói với heo rừng sẽ có da, thịt, xương. Đem về bàn chế tạo ở làng mà làm ba lô, áo giáp.",
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
			"Trái cây tươi đây! Tiếc là quầy chưa mở bán, bạn quay lại sau nha.",
			"Muốn có trái cây thì lên Làng Ven Hồ hay xuống Xóm Ruộng mà hái, nhiều lắm.",
		],
		"look": { "skin": 1, "hair": 1, "hair_color": 4, "outfit": 2, "outfit_color": 1, "hat": 0 },
		"wander": 0.0,
	},
	{
		"name": "Chú Tư thợ bánh",
		"lines": [
			"Bánh mì mới ra lò đây! Thơm không?",
			"Hai bó lúa mì với một bình nước, nấu ở nồi là có bánh mì. Dễ ợt!",
			"Nghe nói cuối rừng có đấu trường đá cổ, một con quái rất to canh giữ ở đó.",
		],
		"look": { "skin": 2, "hair": 0, "hair_color": 1, "outfit": 0, "outfit_color": 6, "hat": 4 },
		"wander": 0.0,
	},
	{
		"name": "Bác Ba nông dân",
		"lines": [
			"Vườn rau của bác ngay phía nam đó. Đẹp không?",
			"Nồi thuốc với bàn chế tạo bên giếng ai dùng cũng được. Nước thì múc ở xô cạnh giếng nha.",
			"Mệt thì cứ về quảng trường nghỉ chân, ngắm đài phun nước cho vui.",
		],
		"look": { "skin": 3, "hair": 4, "hair_color": 0, "outfit": 3, "outfit_color": 2, "hat": 0 },
		"wander": 28.0,
	},
	{
		"name": "Lính gác",
		"lines": [
			"Qua khỏi đây là Rừng Hoang. Nhớ bấm F để lướt né đòn nha!",
			"Bị thương thì bấm D để uống bình máu, hoặc mở túi (B) ăn trái cây.",
		],
		"look": { "skin": 0, "hair": 0, "hair_color": 0, "outfit": 1, "outfit_color": 6, "hat": 1 },
		"wander": 0.0,
	},
	{
		"name": "Bé Tí",
		"lines": [
			"Bạn là lữ khách hả? Ngầu quá!",
			"Bạn đánh thử bù nhìn ở bãi tập phía nam chưa? Bấm Q W E R đó!",
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
			"Nấm với quả mọng nấu thành súp, ăn vào hồi máu từ từ, đánh nhau lâu rất có ích.",
			"Nấm nhỏ trong đầm ăn được, còn mấy cây nấm khổng lồ thì đừng đụng nha.",
			"Slime ưa chỗ ẩm. Đi trên cầu gỗ cho đỡ lầy.",
		],
		"look": { "skin": 4, "hair": 1, "hair_color": 4, "outfit": 2, "outfit_color": 3, "hat": 2 },
		"wander": 0.0,
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
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTTT################################################################
Tt.n.t..................,,.t..TTTTTTTTTTTTTTTTTTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTTT################################################################
T..........~~~~~~~~~~~...n....TTTTTTTTTTTTTTTTTTTTTTTTTTTT~~TTTTTTTTTTTTTTTTTTTTTTT################################################################
T....1....~~~~~~~~~~~~~......tTTTTTTTTTTTTTTTTTTTTTTTTTTTT~~~TTTTTTTTTTTTTTTTTTTTTT################################################################
T........~~~~~~~~~~~~~~~..2...TTTTTTTTTT..T1...TTTTTTTTTTTT~~~TTTTTTTT,...TTTTTTTTT################################################################
T......^~~~~~~~~~~~~~~~~~...,.TTTTTTTTTT.........TTTTTTTTTTT~~TTTTTT.......HxxTTTTT################################################################
T..,...^~~~~~~~~~~~~~~~~~^....TTTTTTTT.......X...,TTTTTTTTTT~~TTTT3...j....xxxTTTTT################################################################
T.....2.~~~~~~[[[~~~~~~~~^....TTTTTTTT...........,3TTTTTTTTT~~TTT,.....,...xxx..TTT################################################################
T.1.....~~~~~~~[~~~$~~~~~.....TTTTTTT..................TTTTT~~.......----......TTTT################################################################
T......^~~~~$~~[~~~~~~~~~.....TTTTTTTT,,.....---......3...T~~~X-------.v.....,zTTTT################################################################
T.,1....~~~~~~~[~~~~~~~~~..1..TTTTTTTT.....---.-X----------[[--.1...lk..--....TTTTT################################################################
T........~~~~~~[~~~~~~~~......TTTTTTTTTT.---....1TTT......~~~1...TT...,..-...TTTTTT################################################################
Tt........^..kv_.l....^.....t.TTTTTTTTTT.-....T.TTTTTTTTT~~~T..TTTT.,.T.,-2TTTTTTTT################################################################
T..Hxx........._.k......Hxx...TTTTTTTTT..-..TTTTTTTTTTTTT~~...,.......T..-.TTTTTTTT################################################################
T..xxx........._........xxx...TTTTT..,...-.TTTTTTTTTTTTT~~~..,.....s3.T..-.TTTTTTTT################################################################
T..xxx.......t._..w...t.xxx...TT.........-.TTTTTTTTTTTT~~~.2........,TTT.-.TTTTTTTT################################################################
T..._........n._..,.,..,._.,..TT....q....-..TTTTTTTTTTT~~.....2.N..,TTTT.-.TTTTTTTT################################################################
T..._.........._...v....._..q..........s.-2TTTTTTTTTTT~~~T..1..,...TTTTT.-2.TTTTTTT################################################################
T.____________________________.-----------,TTTTTTTTTTT~~TTTTTTTTTTTTTTTT.--.TTTTTTT################################################################
T.......,.._..._....._...,......,...,--,...TTTTTTTTTTT~~~~~~~~~~~~TTTTTTT%-%%%TTTTT################################################################
Tt.,.....Rxxx.._...Wxxx.......TT......---.1TTTTTTTTTTT~~~~~~~~~~~~~TTTT%%%--%%%TTTT################################################################
T.....t.,xxxx,._...xxxx.......TTT.,.....-.TTTTTTTTTTTTTTTT~~~~~~~~~^TT%%r%%%%X%%TTT################################################################
T........xxxx.._...xxxx.....t.TTTTT.T..2-.TTTTTTTTTTTTTTTT~~~~~~~~~TT%%%%%X%%%r%%TT################################################################
T.............._..............TTTTTTTT..-.2..TTTTTTTT.,TT^~~~~~~~~~^..%%%%%%X%%%%%T################################################################
T.fff-fff......_...7..7..7....TTTTTTTT,.--...3.TTTT........~~~~~~[----%r%%%%%%%%%TT################################################################
T.f55555f......_t.....,.......TTTTTTTT...-......................--..1.%%%%%X%%%%%TT################################################################
T.f55555f.v...._..............TTTTTTTT...--..--------------------.1..TT%%%%%r%%%TTT################################################################
T.f55555f....t._..,7..7..7....TTTTTTT..,..-N....3......N........TTTTTTTTT%T%%%TTTTT################################################################
T.f55555f......_.............tTTTTTTTTT...-,..TTTTT.T......TTTTTTTTTTTTTTTTTTTTTTTT################################################################
T.fffffff......_q.............TTTTTTTTT...-.1.TTTTTTTTT.TTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
T,..........,.._..............TTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
TTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
TTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
Tt.....t.....t._.t....t......tTTTTTTTTTTT...TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
T.............._..............TTTTTTT.T.T...TTTTTTTTTTTTTTT%TTTTTTTTTTTTT..Hxx.TTTT##########################################Y##Z##Y###############
T.Rxxx...Uxxx.._..Wxxx..y.y.y.TTTT..........TTTTTTTTTTTT%%%%%%TTTTTTTTTT.k.xxx...TT#######################################ii;;;;;;;;;ui############
T.xxxx...xxxx.._..xxxx.ffffff.TTTT..Hxx.kk..TTTTTTTTTT%%%r%%%%%TTTTTTTT....xxb.l.TT#######################################;;;;;;;b;;;;;############
T.xxxx...xxxx.._..xxxx........TTTn..xxx.l.m.TTTTTTTTTT%%%%%%%%%TTTTTTTTT....-..z.TT#######################################;;;I;;;;;I;;;############
T..._......_..._...._.........TT....xxxs.....TTTTTTTTTT%zs%r%%%.TTTTTTTTT...-...TTT#::::::::::::::::######################;;;;;;E;;;;;;############
T.__________________________..TT..z..---..r.TTTTTTTTTT.%%%%%%....TTTTTTTT...-TTTTTT#::::::::::::::::######################;;;;;;;;;;;;;############
T.n,..........._..............TTTT.....-....TTTTTTTTT....%TTT.....TTTTTTT...-TTTTTT#::::::::::::::::#########Y##Z##Y######;;a;;;;;;;a;;############
Tt.....t......._.......t....t.TTTTT....-..TTT.TT.TTTT..b.TTTTT.....T........-TTTTTT#:::#::::::::#:::######iu;;;;;;;;;Ki;;;;;;;;;;;;;;m;############
Tk...q...LkJxxg+gJxxlL........TTTTTTTT.-.................TTTTTT.......kkl...-..TTTT#::::::::::::::::######;;;;;;;;;;;;;;;;u;;;;;;;;;;;i############
T.@x...C.===v==+==v===.....t.,TTTTTTTTT-......Hxx.......TTTTTTTTo...j.......-r...TT#::::::::::::::::######;;;;;;;;;;b;;#########;;#################
Tt..,w...===+++++++===..t.....TTTTTTT,.--..j..xxx.l....TTTTT......z.......s.-...TTT#::::::::::::::::######I;;s;;;;;;;;;#########;;#################
T........===+++++++===.................o--...hxxx.k.T.........------..a....--...TTT#::::::::::::::::######;;;;S;;;;;;;I#########;;#################
T.....v..g==++Fxx++==g......q............-..s..-.......--------.b..---------.......:::::::::::::::::G;;;;;;;;;;;;;;;;;;#####Z#Y#;;###Y##Z###Y######
T________+++++xxx+++++________.----------......-...-----.......TTTTT.......----s---:::::::::B:::::::G;;;;;;;;;;;;;;;;;;###iiuK;;;;;;;;;;;;;;;;Kii##
T........g==+++++++==g.....v........T...------------.......TTTTTTTTTTT....TT.......:::::::::::::::::G;;;;;;;;;;;;;s;;;;###i;;;;;;;;;;;;;;;;;;;;;I##
T........=v=+++++v+===.............n.........,.......r.T.TTTTTTTTTTTTT....TTTTTTT..:::::::::::::::::G;;;;;;;h;;;;;;;;;;###;;;;;;;;;;;;b;;;;;;;;;;##
T.fff-ff.==ex==P==ex==........TTTTTTT.T..T.....,.s.....T.TTTHxxTTTTTTT.....VxxTTTTT#::::::::::::::::######;;;;;;;;;;;;;;;;;;;;;S;;;;;;;;;s;;;;;;;##
T.fppppf.====q=+======.t...,..TTTTTTTT......o......,..TTTTTTxxxTTTTTT......xxxTTTTT#::::::::::::::::######I;;;;;;;;;;;;;;;;;;;;;s;;;;;;;;;;;a;;;;##
T.fppppf.L====g+g====L....t...TTTTTTT..............TTTTTTTT.xxx.lT.........xxxTTTTT#::::::::::::::::######;;;;;b;;;S;;;###;;;;;;;;;;;;;;;;;;;;;;;##
Ttfppppf,....n._..............TTTTTTT....TT.T.T....TTTTTT.k..-..k....r.~~~~~~~~TTTT#::::::::::::::::######K;;;;;;;;;;;;###I;;;;;;;;;;;;;;;;;;;;O;##
T.fff-ff......._...........,t.TTTTTT.-...TTTTTT..%%TTTTTT....-.....b...~~~~~~~~TTTT#:::#::::::::#:::######ii;;;;;;;;;iu###u;;;;;;;;E;;;;Q;;;;;;;;##
T.............._q.,...........TTTTfff-fffTTTTT%%%%%%%%T....---...h.....~~~~~~~~TTTT#::::::::::::::::######################;;;;;;;;;;;;;;;;;;;;;;;##
T.Mxx....ffffff_ffffff..Rxxx..TTTTfp-p-pfTTTT%%%r%%z%%%.--o-..a....T..n~~~~~~~~TTTT#::::::::::::::::######################;;;b;;;;;;;;;;;;;;;;;;;##
T.xxx.t..f....,......f.,xxxx..TTTTfp-s-pfTTTT%%%%%%%%%%..........nTTTTTTTTTTTTTTTTT#::::::::::::::::######################;;;;;;;;;;;;;;;;;Sa;;;;##
T.xxx...tf...........ft.xxxx..TTTTfp-p-pfTTTTT%%%%s%r%%...T......TTTTTTTTTTTTTTTTTT#######################################;;;;;;;s;;;;S;;;;;;;;;;##
T.._.....f..d.....d..f...._...TTTTfffffffTTTTTT%%%%%%%%TTTTTTT...TTTTTTTTTTTTTTTTTT#######################################I;;;;;;;;;h;;;;;;;;;;;i##
Tt._.....f.....D.....f...._.t.TTTTTTTTTTTTTTTTTTTT%%%TTTTTTTTT...TTTTTTTTTTTTTTTTTT#######################################iiK;;;;;;;;;;;;;;;;;uui##
T..______f...........f_______.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTTTTTTTTTTTTT################################################################
T........fffffffffffff......_.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT...TTTTTTTTTTTTTTTTTT################################################################
TTTTTTTTTTTTTTTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT################################################################
TTTTTTTTTTTTTTTTTTTTTTTTTTT._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT################################################################
Tt.........................._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT################################################################
T.ffffffffffff.......&xxx..q_.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTTTTTTTTTTTT################################################################
T.f4444444444f..!xx..xxxx..._.TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTT..Hxx.TTTT################################################################
T.f4444444444f..xxx..xxxx..._tTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT.-.TTTTTTTT..xxx..TTT################################################################
T.f4444444444f..xxx...__...._.TTTTTTTTTTTTTTTTTTTTTT.TTTT3.T.T.-.TTTTTTT...xxx...TT################################################################
T.f4444)44444f.2.,...._______.TTTTTTTTTTTTTTTT...TTT..T.......--.*TTTTTT.......k..T################################################################
T.f4444444444f.(...(........_.TTTTTTTTTTTTTTT^^3..1.,.*3..3..b-....TT.T..j....3l.TT################################################################
T.f4444444444f......(....(.._.TTTTTTTTTTT~~~~~~~.............-....3....---v-....TTT################################################################
T.f4444444444f............(._tTTTTTTTTTTT~~~~~~~.............-^^^..s...-......TTTTT################################################################
T.ffffff-fffff.......,......_.TTTTTTTT.T.~~~~~~~.....3...~~~~~~~~~.....-,..T.TTTTTT################################################################
T.,........................._.TTTTTTT2.T^~~~~~~~^..,....^~~~~~~~~~....--T1TTTTTTTTT################################################################
T.........v....t.....,..w..._.TTTTTT.*.....3^....--------[[[[[[[[[-----..TTTTTTTTTT################################################################
Tt..............v..........._qTT...q.........s.---,..3..^~~~~~~~~~--..N...T..TTTTTT################################################################
T.,...,............,...,...._,......,......-----........^~~~~~~~~~^-..........TTTTT################################################################
T______________________________-------------2,.---...s...^^..^..^^.---.....b..TTTTT################################################################
T...._........_..._.....v.......3.............32.-...................-........TTTTT################################################################
T...._........_..,_...........TT...2....2....*...---2..N....3........--......T..TTT################################################################
T.fff-ffff.fff-fff_.7..7..7...TTTTTT.T...s........^-^^.....s.......^~~[[~~3.....TTT################################################################
T.f555555f.f66666f_...........TTTTTTTT,...,....^~~~[~~~~..3........^~~~[[[-.....TTT################################################################
T2f555555f.f66666f_..........tTTTTTTT..^.^......~~~[~~~~............[[[[[[-......TT################################################################
T.f555)55f.f66666f_...........TTTTTTTT~~~~~.....~~~[~~~~..*.3......^~~~~~~......TTT################################################################
Ttf555555f.f66666f_.7..7..7...TTTTTTTT~~~~~.....~~~[~~~~.........^..~~~~~~.....1TTT################################################################
T.ffffffff.fffffff_...........TTTTTTTT~~~~~^.....^.-^^^......~~~~~~^,.TTTTTTTTTTTTT################################################################
T................._...........TTTTTTTT~~~~~T....,..-.......3^~~~~~~..TTTTTTTTTTTTTT################################################################
T................._.....,.,...TTTTTTTTTTT.^....T.b.-------...~~~~~~T.TTTTTTTTTTTTTT################################################################
T.Rxxx.,,.Mxx...,._..7..7..7..TTTTTTTTTTTT.TTT.T..T.T.TT.T...~~~~~~TTTTTTTTTTTTTTTT################################################################
T.xxxx....xxx.t.,._...........TTTTTTTTTTTTTTTTTTT.TTT2.T..TTTTTTTTTTTTTTTTTTTTTTTTT################################################################
T.xxxx....xxx....._...........TTTTTTTTTTTTTTTTTTTTTTTTTTT..TTTTTTTTTTTTTTTTTTTTTTTT################################################################
T..._......_......_...t......tTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
T..._______________...........TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT################################################################
"""

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const ENEMY_SCENES := {
	"s": preload("res://scenes/enemies/slime.tscn"),
	"d": preload("res://scenes/enemies/dummy.tscn"),
	"D": preload("res://scenes/enemies/dummy.tscn"),
	"b": preload("res://scenes/enemies/bat.tscn"),
	"a": preload("res://scenes/enemies/archer.tscn"),
	"B": preload("res://scenes/enemies/boss.tscn"),
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
}
const WALL_CHARS := "#YZ"                          # các ô tường (đuốc, cờ cũng nằm trên tường)
const DUNGEON_DARK := Color(0.22, 0.2, 0.32)       # độ tối trong hầm ngục (1 = sáng như ngoài trời)
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
const PLAZA_CHARS := "=+FxeLJgvPqkl"   # các ô thuộc quảng trường (nền đá)
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
	"cauldron": preload("res://assets/craft/cauldron.png"),
	"workbench": preload("res://assets/craft/workbench.png"),
}
const WELL_BUCKET := { "item": "water", "tex": preload("res://assets/craft/bucket.png"), "frames": 2, "grow": 20.0,
	"amount": [1, 2], "reach": 18.0, "tree": true }
const STATION_RANGE := 30.0   # đứng gần trạm chế tạo bao nhiêu pixel thì mở bảng chế tạo
## Sói, heo rừng bị hạ sẽ quay lại chỗ cũ sau bấy nhiêu giây (khi người chơi không đứng gần)
const BEAST_RESPAWN := 120.0
const WATER_CHARS := "~[$"    # các ô có nước bên dưới (cầu gỗ và thuyền nằm trên nước)
const CROP_CHARS := "456"     # cây trồng trên ruộng (có đất cày)

const SOLID := "T#~orxRUWMfwqytHVklzjYZIuKFeLJg17*!&$)(C@"
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
var stations: Array[Dictionary] = []     # { "pos": Vector2, "kind": "pot" / "bench" }
var current_station := ""

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
	Game.boss_defeated.connect(_on_boss_defeated)
	call_deferred("_announce_start")


func _announce_start() -> void:
	Game.area_entered.emit("Làng Khởi Nguyên")
	Game.message.emit("Chuột phải để đi / đánh quái, Q W E R: kỹ năng, Esc: xem hướng dẫn")
	Game.message.emit("Đi tới gần dân làng để nghe họ nói chuyện. Luyện tập ở bãi tập rồi lên đường về phía đông!")


func _parse_map() -> void:
	rows = MAP.strip_edges().split("\n")
	for i in rows.size():
		rows[i] = rows[i].strip_edges()
	var width := 0
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
		if gate_column != -1 and x > gate_column:
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
	if gate_column == -1 or x <= gate_column:
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


func _build_ground() -> void:
	var ground := Node2D.new()
	ground.name = "Ground"
	ground.z_index = -10
	add_child(ground)
	var detail := Node2D.new()  # đường đất, bãi đá, viền tối... vẽ đè lên cỏ
	detail.name = "GroundDetail"
	detail.z_index = -9
	add_child(detail)
	for y in map_size.y:
		for x in map_size.x:
			var c := cell(x, y)
			var area := _area_at(x, y)
			tile_tint = BIOME_TINT.get(area.get("biome", ""), Color.WHITE)
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
			if gate_column != -1 and x > gate_column:
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
				_add_rect_shape(gate_body, x, y, 1)
				gate_sprites.append(_add_tile_sprite(gate_body, TEX["gate"], x, y))


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
	if not gate_open and gate_column != -1:
		var gate_x := gate_column * TILE + TILE / 2.0
		if (to_local(a).x < gate_x) != (to_local(b).x < gate_x):
			return false
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
					_add_small_prop(FOREST_TEX["stump"] if rng.randf() < 0.6 else FOREST_TEX["stump_axe"], x, y)
				"j":
					var fire := _add_prop(FOREST_TEX["campfire"], x, y)
					var flicker := fire.create_tween().set_loops()
					flicker.tween_property(fire, "modulate", Color(1.3, 1.15, 0.9), 0.12)
					flicker.tween_property(fire, "modulate", Color(1.0, 0.9, 0.85), 0.18)
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
					npc.setup(NPC_DATA[npc_count] if npc_count < NPC_DATA.size() else {})
					npc_count += 1
					npc.position = pos
					npc.level_ref = self
					entities.add_child(npc)
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
				if gate_column != -1 and x > gate_column and c != "B":
					enemy.make_elite()
				if c == "D":
					enemy.armor = 6
					enemy.display_name = "Bù nhìn giáp"
				if c == "X" or c == "N":
					enemy.died.connect(_on_beast_died.bind(c, pos))
				entities.add_child(enemy)
			elif ITEM_KINDS.has(c):
				var item := (load("res://scenes/pickup.tscn") as PackedScene).instantiate() as Pickup
				item.kind = ITEM_KINDS[c]
				item.value = ITEM_VALUES[c]
				item.position = pos
				entities.add_child(item)

	_spawn_critters()
	_add_fireflies()
	if player:
		player.set_camera_limits(Rect2(Vector2.ZERO, Vector2(map_size) * TILE))
		# Đèn nhỏ quanh người chơi, chỉ bật trong hầm ngục
		player_light = PointLight2D.new()
		player_light.texture = light_texture
		player_light.texture_scale = 100.0 * 2.0 / light_texture.width
		player_light.color = Color(1.0, 0.9, 0.8)
		player_light.energy = 0.7
		player_light.enabled = false
		player.add_child(player_light)


# ---------------------------------------------------------------- Hệ sinh thái: thú hiền, đom đóm

## Sói / heo rừng chết: một lúc sau con khác quay về chỗ cũ (để luôn có da, thịt, xương).
func _on_beast_died(_enemy: Enemy, c: String, pos: Vector2) -> void:
	get_tree().create_timer(BEAST_RESPAWN, false).timeout.connect(_respawn_beast.bind(c, pos))


func _respawn_beast(c: String, pos: Vector2) -> void:
	if not is_inside_tree():
		return
	# Người chơi đang đứng gần thì đợi thêm, không cho quái hiện ra ngay trước mặt
	if player != null and player.global_position.distance_to(to_global(pos)) < 220.0:
		get_tree().create_timer(15.0, false).timeout.connect(_respawn_beast.bind(c, pos))
		return
	var enemy := (ENEMY_SCENES[c] as PackedScene).instantiate() as Enemy
	enemy.position = pos
	enemy.died.connect(_on_beast_died.bind(c, pos))
	entities.add_child(enemy)


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
	altar_position = center
	_add_light(center, 100.0, MAGIC_LIGHT, 1.2, false)


## Vào / ra hầm ngục: làm tối màn hình và bật đèn (chuyển dần trong 0.8 giây).
func _set_in_dungeon(value: bool) -> void:
	in_dungeon = value
	dungeon_lights.visible = value
	if player_light:
		player_light.enabled = value
	var tw := create_tween()
	tw.tween_property(darkness, "color", DUNGEON_DARK if value else Color.WHITE, 0.8)


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
	var tile_x := player.global_position.x / TILE
	# Biển báo: đi tới gần thì hiện chữ
	for sign_data in signs:
		var near: bool = player.global_position.distance_to(sign_data["pos"]) < 22.0
		if near and not sign_data["near"]:
			Game.message.emit(sign_data["text"])
		sign_data["near"] = near
	_update_area(floori(tile_x), floori(player.global_position.y / TILE))
	if not entered_arena and arena_column != -1 and tile_x > arena_column + 1 and tile_x < gate_column:
		entered_arena = true
		Game.area_entered.emit("Đấu Trường Đá Cổ")
	var now_in_dungeon := gate_column != -1 and tile_x > gate_column + 1
	if now_in_dungeon != in_dungeon:
		_set_in_dungeon(now_in_dungeon)
	if not entered_area2 and now_in_dungeon:
		entered_area2 = true
		Game.area_entered.emit("Hầm Ngục Cổ")
		Game.message.emit("Hầm ngục tối và lạnh, quái nơi đây mạnh hơn. Hãy tìm Cổng Xoáy ở cuối hầm!")
	if not won and altar_position != Vector2.INF and player.global_position.distance_to(altar_position) < 14.0:
		won = true
		Game.game_won.emit()


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
	if gate_open:
		return
	gate_open = true
	Game.message.emit("Cổng phong ấn đã mở! Khu vực mới: Hầm Ngục Cổ")
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
