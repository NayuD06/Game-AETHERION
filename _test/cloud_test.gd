extends Node
## Chạy thử phần đăng nhập Google / đổi tên (chỉ để kiểm tra, xóa sau khi xong).

var got_code := ""


func _ready() -> void:
	await get_tree().process_frame
	print("CLOUD configured=", Cloud.is_configured(), " logged_in=", Cloud.is_logged_in())
	var v := "thu-nghiem_PKCE.verifier~1234567890abcdefghijklmnopqrstuvwxyzABCD"
	print("PKCE ", Cloud._base64url(v.sha256_buffer()))
	print("RANDOM ", Cloud._random_text(24).length(), " ", Cloud._random_text(10))
	print("QUERY ", Cloud._query({ "a b": "c&d", "redirect_uri": "http://127.0.0.1:53682" }))
	print("PARSE ", Cloud._parse_request("GET /?state=xyz&code=4%2F0Ab_c-d&scope=email+profile HTTP/1.1\r\nHost: x\r\n"))
	print("PARSE favicon ", Cloud._parse_request("GET /favicon.ico HTTP/1.1\r\n"))
	# Cổng nhận mã: giả làm trình duyệt gọi về
	var port := Cloud._open_server()
	print("PORT ", port)
	_fake_browser(port)
	var code: String = await Cloud._wait_for_code("xyz")
	Cloud._server.stop()
	print("CODE ", code)
	# Gọi thử máy chủ Google với dữ liệu giả để xem đọc lỗi được không
	var r: Dictionary = await Cloud._request("https://oauth2.googleapis.com/token", HTTPClient.METHOD_POST,
		"client_id=khong-co&grant_type=authorization_code&code=gia", true)
	print("GOOGLE code=", r["code"], " error=", Cloud._error_text(r))
	# Đổi tên tài khoản
	var look := CharacterParts.DEFAULT.duplicate()
	look["name"] = "_thu_ten_"
	var tid := Accounts.create(look)
	print("RENAME ok=", Accounts.rename(tid, "  Tên Mới Rất Dài Quá Mười Bốn  "), " name=", Accounts.summary(tid).get("name"))
	var text := Accounts.read_text(tid)
	print("TEXT len=", text.length(), " roundtrip=", Accounts.write_text(tid, text) == OK, " bad=", Accounts.write_text(tid, "rác") != OK)
	Accounts.delete(tid)
	print("CLOUD TEST DONE")
	get_tree().quit()


func _fake_browser(port: int) -> void:
	await get_tree().create_timer(0.5).timeout
	var c := StreamPeerTCP.new()
	c.connect_to_host("127.0.0.1", port)
	for i in 50:
		c.poll()
		if c.get_status() == StreamPeerTCP.STATUS_CONNECTED:
			break
		await get_tree().create_timer(0.02).timeout
	c.put_data("GET /?state=xyz&code=ma-thu-123&scope=email HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n".to_utf8_buffer())
	var reply := ""
	for i in 100:
		await get_tree().create_timer(0.02).timeout
		c.poll()
		var n := c.get_available_bytes()
		if n > 0:
			reply += c.get_utf8_string(n)
		if c.get_status() != StreamPeerTCP.STATUS_CONNECTED and reply != "":
			break
	print("BROWSER got: ", reply.get_slice("\r\n", 0), " | has_page=", reply.contains("Đăng nhập xong"))
