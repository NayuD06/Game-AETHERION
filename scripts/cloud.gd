extends Node
## Autoload "Cloud": đăng nhập bằng Google (qua Firebase) và lưu tài khoản lên mạng.
## Đăng nhập rồi thì các tài khoản (nhân vật) được gửi lên mạng mỗi lần game tự lưu,
## sang máy khác đăng nhập cùng tài khoản Google là có lại đủ nhân vật.
## Không đăng nhập thì game vẫn lưu trong máy như bình thường.
##
## CẦN LÀM TRƯỚC: tạo project Firebase miễn phí rồi điền 4 dòng bên dưới.
## Làm từng bước theo README, phần "Đăng nhập Google" (doc/dang_nhap_google.md).
##
## Cách chạy: bấm "Đăng nhập Google" -> game mở trình duyệt, chọn tài khoản Google -> Google gửi mã về game
## (game tự mở một cổng nhỏ trên máy 127.0.0.1 để nhận mã) -> game đổi mã lấy "vé" Firebase -> xong.
## Tài khoản Full (tài khoản thử) không gửi lên mạng.

# --- Điền thông tin Firebase của bạn vào đây (xem doc/dang_nhap_google.md) ---
const FIREBASE_API_KEY := ""          # Project settings > General > Web API Key (dạng "AIza...")
const FIREBASE_DATABASE_URL := ""     # Realtime Database, dạng "https://ten-project-default-rtdb.asia-southeast1.firebasedatabase.app"
const GOOGLE_CLIENT_ID := ""          # OAuth client loại "Desktop app", dạng "1234-abc.apps.googleusercontent.com"
const GOOGLE_CLIENT_SECRET := ""      # Client secret của OAuth client đó (dạng "GOCSPX-...")

const SESSION_PATH := "user://dang_nhap_google.cfg"   # nhớ đăng nhập, lần sau mở game không phải đăng nhập lại
const LOGIN_TIMEOUT := 180.0          # chờ người chơi chọn tài khoản Google tối đa bấy nhiêu giây
const PORTS := [53682, 53683, 53684, 53685, 53686]    # cổng nhận mã từ Google (thử lần lượt nếu cổng bận)
const UPLOAD_EVERY := 25.0            # gửi lên mạng nhiều nhất mỗi bấy nhiêu giây một lần (lúc thoát thì gửi luôn)

signal login_changed                  # vừa đăng nhập / đăng xuất
signal status(text: String)           # chữ báo cho màn hình chọn tài khoản
signal synced                         # đồng bộ xong, danh sách tài khoản có thể đã đổi

var uid := ""                         # mã người dùng Firebase ("" = chưa đăng nhập)
var email := ""
var display_name := ""
var id_token := ""
var refresh_token := ""
var token_expire := 0                 # giờ hết hạn của id_token (giây, theo đồng hồ máy)
var busy := false                     # đang đăng nhập
var last_upload := {}                 # id tài khoản -> lúc gửi lên gần nhất (giây chạy game)
var _server: TCPServer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_session()


func is_configured() -> bool:
	return FIREBASE_API_KEY != "" and FIREBASE_DATABASE_URL != "" and GOOGLE_CLIENT_ID != "" and GOOGLE_CLIENT_SECRET != ""


func is_logged_in() -> bool:
	return uid != "" and refresh_token != ""


# ---------------------------------------------------------------- Đăng nhập / đăng xuất

func login() -> void:
	if busy or is_logged_in():
		return
	if not is_configured():
		status.emit("Chưa cài Firebase: điền 4 dòng đầu file scripts/cloud.gd (xem doc/dang_nhap_google.md)")
		return
	busy = true
	var port := _open_server()
	if port == 0:
		busy = false
		status.emit("Không mở được cổng nhận mã đăng nhập (cổng %d-%d đang bận)" % [PORTS[0], PORTS[PORTS.size() - 1]])
		return
	var redirect := "http://127.0.0.1:%d" % port
	var verifier := _random_text(64)
	var state := _random_text(24)
	var url := "https://accounts.google.com/o/oauth2/v2/auth?" + _query({
		"client_id": GOOGLE_CLIENT_ID,
		"redirect_uri": redirect,
		"response_type": "code",
		"scope": "openid email profile",
		"code_challenge": _base64url(verifier.sha256_buffer()),
		"code_challenge_method": "S256",
		"state": state,
		"prompt": "select_account",
	})
	OS.shell_open(url)
	status.emit("Đã mở trình duyệt: chọn tài khoản Google, xong thì quay lại game")
	var code := await _wait_for_code(state)
	_server.stop()
	if code == "":
		busy = false
		status.emit("Đăng nhập Google bị hủy hoặc quá lâu, thử lại nhé")
		return
	status.emit("Đang đăng nhập...")
	# Đổi mã lấy id_token của Google
	var tok := await _request("https://oauth2.googleapis.com/token", HTTPClient.METHOD_POST, _query({
		"code": code,
		"client_id": GOOGLE_CLIENT_ID,
		"client_secret": GOOGLE_CLIENT_SECRET,
		"redirect_uri": redirect,
		"grant_type": "authorization_code",
		"code_verifier": verifier,
	}), true)
	if not tok["ok"] or not (tok["data"] is Dictionary) or not tok["data"].has("id_token"):
		busy = false
		status.emit("Google từ chối: %s" % _error_text(tok))
		return
	# Dùng id_token của Google để đăng nhập Firebase
	var fb := await _request("https://identitytoolkit.googleapis.com/v1/accounts:signInWithIdp?key=" + FIREBASE_API_KEY,
		HTTPClient.METHOD_POST, JSON.stringify({
			"postBody": "id_token=%s&providerId=google.com" % tok["data"]["id_token"],
			"requestUri": redirect,
			"returnSecureToken": true,
		}))
	busy = false
	if not fb["ok"] or not (fb["data"] is Dictionary) or not fb["data"].has("idToken"):
		status.emit("Firebase từ chối: %s" % _error_text(fb))
		return
	var d: Dictionary = fb["data"]
	uid = str(d.get("localId", ""))
	email = str(d.get("email", ""))
	display_name = str(d.get("displayName", email))
	id_token = str(d["idToken"])
	refresh_token = str(d.get("refreshToken", ""))
	token_expire = _now() + int(d.get("expiresIn", "3600")) - 60
	_save_session()
	login_changed.emit()
	status.emit("Đã đăng nhập Google: %s" % email)
	await sync_all()


func logout() -> void:
	uid = ""
	email = ""
	display_name = ""
	id_token = ""
	refresh_token = ""
	token_expire = 0
	if FileAccess.file_exists(SESSION_PATH):
		DirAccess.remove_absolute(SESSION_PATH)
	login_changed.emit()
	status.emit("Đã đăng xuất Google. Tài khoản vẫn còn trong máy.")


# ---------------------------------------------------------------- Đồng bộ tài khoản

## Lấy danh sách trên mạng về so với trong máy: bên nào chơi gần hơn thì lấy bên đó.
## Tài khoản đã xóa ở máy khác thì xóa luôn ở máy này.
func sync_all() -> void:
	if not await _ensure_token():
		return
	status.emit("Đang đồng bộ với Google...")
	var r := await _request(_db_url("users/%s" % uid), HTTPClient.METHOD_GET, "")
	if not r["ok"]:
		status.emit("Không đồng bộ được: %s" % _error_text(r))
		return
	var data: Dictionary = r["data"] if r["data"] is Dictionary else {}
	var cloud: Dictionary = data.get("accounts", {}) if data.get("accounts") is Dictionary else {}
	var deleted: Dictionary = data.get("deleted", {}) if data.get("deleted") is Dictionary else {}
	var downloaded := 0
	var uploaded := 0
	for id in deleted:
		if FileAccess.file_exists(Accounts.path(id)) and not cloud.has(id):
			Accounts.delete(id)
	for id in cloud:
		var entry = cloud[id]
		if not entry is Dictionary or deleted.has(id):
			continue
		if int(entry.get("choi_luc", 0)) > Accounts.last_played(id) and Accounts.write_text(id, str(entry.get("cfg", ""))) == OK:
			downloaded += 1
	for acc in Accounts.list():
		if acc["full"]:
			continue
		var entry = cloud.get(acc["id"])
		if entry is Dictionary and int(entry.get("choi_luc", 0)) >= int(acc["last_played"]):
			continue
		if await upload(acc["id"], true):
			uploaded += 1
	status.emit("Đã đồng bộ với Google (%s): tải về %d, gửi lên %d tài khoản" % [email, downloaded, uploaded])
	synced.emit()


## Gửi một tài khoản lên mạng. force = false thì không gửi dồn dập (xem UPLOAD_EVERY).
func upload(id: String, force: bool = false) -> bool:
	if not is_logged_in() or id == "":
		return false
	var now := Time.get_ticks_msec() / 1000.0
	if not force and now - float(last_upload.get(id, -1000.0)) < UPLOAD_EVERY:
		return false
	var info := Accounts.summary(id)
	if info.is_empty() or info["full"]:
		return false
	last_upload[id] = now
	if not await _ensure_token():
		return false
	var body := JSON.stringify({
		"name": info["name"],
		"level": info["level"],
		"weapon": info["weapon"],
		"choi_luc": info["last_played"],
		"cfg": Accounts.read_text(id),
	})
	var r := await _request(_db_url("users/%s/accounts/%s" % [uid, id]), HTTPClient.METHOD_PUT, body)
	return r["ok"]


## Xóa tài khoản trên mạng (ghi lại để máy khác cũng xóa theo).
func delete_account(id: String) -> void:
	if not is_logged_in() or not await _ensure_token():
		return
	await _request(_db_url("users/%s/deleted/%s" % [uid, id]), HTTPClient.METHOD_PUT, "true")
	await _request(_db_url("users/%s/accounts/%s" % [uid, id]), HTTPClient.METHOD_DELETE, "")


# ---------------------------------------------------------------- Phần bên trong

## id_token của Firebase hết hạn sau 1 giờ: đổi refresh_token lấy cái mới.
func _ensure_token() -> bool:
	if not is_logged_in() or not is_configured():
		return false
	if id_token != "" and _now() < token_expire:
		return true
	var r := await _request("https://securetoken.googleapis.com/v1/token?key=" + FIREBASE_API_KEY, HTTPClient.METHOD_POST,
		_query({ "grant_type": "refresh_token", "refresh_token": refresh_token }), true)
	if not r["ok"] or not (r["data"] is Dictionary):
		status.emit("Phiên đăng nhập Google hết hạn, hãy đăng nhập lại (%s)" % _error_text(r))
		return false
	var d: Dictionary = r["data"]
	id_token = str(d.get("id_token", ""))
	refresh_token = str(d.get("refresh_token", refresh_token))
	uid = str(d.get("user_id", uid))
	token_expire = _now() + int(d.get("expires_in", "3600")) - 60
	_save_session()
	return id_token != ""


func _open_server() -> int:
	_server = TCPServer.new()
	for port in PORTS:
		if _server.listen(port, "127.0.0.1") == OK:
			return port
	return 0


## Chờ trình duyệt quay về http://127.0.0.1:cổng/?code=...&state=... rồi trả về mã ("" nếu hủy / quá lâu).
func _wait_for_code(state: String) -> String:
	var waited := 0.0
	while waited < LOGIN_TIMEOUT:
		await get_tree().create_timer(0.2, true, false, true).timeout
		waited += 0.2
		if not _server.is_connection_available():
			continue
		var peer := _server.take_connection()
		var request := ""
		for i in 50:   # đợi trình duyệt gửi xong dòng đầu tiên (tối đa 1 giây)
			peer.poll()
			var n := peer.get_available_bytes()
			if n > 0:
				request += peer.get_utf8_string(n)
			if request.contains("\r\n"):
				break
			await get_tree().create_timer(0.02, true, false, true).timeout
		var params := _parse_request(request)
		if params.is_empty():
			peer.disconnect_from_host()   # trình duyệt xin favicon...: bỏ qua
			continue
		var ok: bool = params.get("state", "") == state and params.has("code")
		var page := "Đăng nhập xong! Quay lại game Fantasy: The Awakening nhé." if ok else "Đăng nhập không thành công. Quay lại game và thử lại nhé."
		var html := "<html><head><meta charset=\"utf-8\"><title>Fantasy: The Awakening</title></head><body style=\"font-family:sans-serif;text-align:center;padding-top:60px\"><h2>%s</h2><p>Có thể đóng tab này.</p></body></html>" % page
		var body := html.to_utf8_buffer()
		var head := "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\nContent-Length: %d\r\nConnection: close\r\n\r\n" % body.size()
		peer.put_data(head.to_utf8_buffer())
		peer.put_data(body)
		await get_tree().create_timer(0.3, true, false, true).timeout
		peer.disconnect_from_host()
		return str(params["code"]) if ok else ""
	return ""


## "GET /?code=abc&state=xyz HTTP/1.1" -> { "code": "abc", "state": "xyz" }
func _parse_request(request: String) -> Dictionary:
	var first := request.get_slice("\r\n", 0)
	var parts := first.split(" ")
	if parts.size() < 2 or not parts[1].contains("?"):
		return {}
	var out := {}
	for pair in parts[1].get_slice("?", 1).split("&"):
		var kv := pair.split("=")
		if kv.size() == 2:
			out[kv[0].uri_decode()] = kv[1].replace("+", " ").uri_decode()
	return out


## Gửi yêu cầu lên mạng. Trả về { "ok": bool, "code": mã HTTP, "data": JSON đã đọc }.
func _request(url: String, method: int, body: String, form: bool = false) -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout = 20.0
	add_child(http)
	var headers := PackedStringArray(["Content-Type: application/x-www-form-urlencoded" if form else "Content-Type: application/json"])
	if http.request(url, headers, method, body) != OK:
		http.queue_free()
		return { "ok": false, "code": 0, "data": null }
	var result: Array = await http.request_completed
	http.queue_free()
	var text := (result[3] as PackedByteArray).get_string_from_utf8()
	var code: int = result[1]
	return {
		"ok": result[0] == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300,
		"code": code,
		"data": JSON.parse_string(text) if text != "" else null,
	}


## Lỗi dễ hiểu hơn cho vài lỗi hay gặp khi cài Firebase.
func _error_text(r: Dictionary) -> String:
	var d = r.get("data")
	var msg := ""
	if d is Dictionary:
		var e = d.get("error")
		if e is Dictionary:
			msg = str(e.get("message", ""))
		elif e != null:
			msg = str(e) + (" " + str(d.get("error_description", "")) if d.has("error_description") else "")
	if msg == "":
		msg = "không kết nối được mạng" if int(r.get("code", 0)) == 0 else "lỗi %d" % int(r.get("code", 0))
	if msg.contains("INVALID_IDP_RESPONSE") or msg.contains("audience"):
		msg += " (thêm Client ID vào ô Safelist ở Firebase > Authentication > Google, xem hướng dẫn bước 4)"
	elif msg.contains("Permission denied"):
		msg += " (kiểm tra Rules của Realtime Database, xem hướng dẫn bước 5)"
	elif msg.contains("API key not valid") or msg.contains("API_KEY_INVALID"):
		msg += " (FIREBASE_API_KEY trong scripts/cloud.gd chưa đúng)"
	return msg


func _db_url(path: String) -> String:
	return "%s/%s.json?auth=%s" % [FIREBASE_DATABASE_URL.trim_suffix("/"), path, id_token]


func _query(params: Dictionary) -> String:
	var parts := PackedStringArray()
	for key in params:
		parts.append("%s=%s" % [str(key).uri_encode(), str(params[key]).uri_encode()])
	return "&".join(parts)


func _random_text(length: int) -> String:
	const CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
	var bytes := Crypto.new().generate_random_bytes(length)
	var out := ""
	for b in bytes:
		out += CHARS[b % CHARS.length()]
	return out


func _base64url(data: PackedByteArray) -> String:
	return Marshalls.raw_to_base64(data).replace("+", "-").replace("/", "_").replace("=", "")


func _now() -> int:
	return int(Time.get_unix_time_from_system())


func _save_session() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("google", "uid", uid)
	cfg.set_value("google", "email", email)
	cfg.set_value("google", "name", display_name)
	cfg.set_value("google", "refresh_token", refresh_token)
	cfg.save(SESSION_PATH)


func _load_session() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SESSION_PATH) != OK:
		return
	uid = str(cfg.get_value("google", "uid", ""))
	email = str(cfg.get_value("google", "email", ""))
	display_name = str(cfg.get_value("google", "name", ""))
	refresh_token = str(cfg.get_value("google", "refresh_token", ""))
