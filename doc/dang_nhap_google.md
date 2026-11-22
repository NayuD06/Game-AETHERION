# Cài đặt đăng nhập Google (lưu tài khoản lên mạng)

Game đã có sẵn nút **Đăng nhập Google** ở màn hình chọn tài khoản. Để nút đó chạy được, bạn cần tạo một
**project Firebase miễn phí** (Firebase là dịch vụ của Google) rồi điền 4 thông tin vào file `scripts/cloud.gd`.
Làm một lần là xong, mất khoảng 15 phút. Gói miễn phí (Spark) là quá đủ cho game này.

Đăng nhập rồi thì mỗi lần game tự lưu, nhân vật cũng được gửi lên mạng. Sang máy khác, đăng nhập cùng Gmail là có lại đủ nhân vật.
Không đăng nhập thì game vẫn lưu trong máy như bình thường.

Bạn sẽ lấy được 4 thứ sau, ghi tạm ra Notepad:

| Tên trong `scripts/cloud.gd` | Lấy ở đâu | Trông như thế này |
|---|---|---|
| `FIREBASE_API_KEY` | Bước 2 | `AIzaSy...` |
| `GOOGLE_CLIENT_ID` | Bước 4 | `123456789-abcd....apps.googleusercontent.com` |
| `GOOGLE_CLIENT_SECRET` | Bước 4 | `GOCSPX-...` |
| `FIREBASE_DATABASE_URL` | Bước 5 | `https://ten-project-default-rtdb.asia-southeast1.firebasedatabase.app` |

---

## Bước 1: Tạo project Firebase

1. Vào https://console.firebase.google.com và đăng nhập bằng Gmail của bạn.
2. Bấm **Create a project** (hoặc **Get started with a Firebase project**).
3. Đặt tên, ví dụ `fantasy-awakening`, bấm **Continue**.
4. Ở trang Google Analytics: tắt đi (không cần), bấm **Create project**. Đợi chạy xong rồi bấm **Continue**.

## Bước 2: Lấy Web API Key

1. Trong project, bấm **hình bánh răng** cạnh chữ "Project Overview" ở góc trên bên trái, chọn **Project settings**.
2. Ở tab **General**, kéo xuống phần **Your apps**, bấm biểu tượng **`</>`** (Web).
3. Đặt tên app là `game` (không cần tích Firebase Hosting), bấm **Register app**.
4. Màn hình hiện một đoạn code có `firebaseConfig`. Chép giá trị trong ngoặc kép sau **`apiKey:`** (bắt đầu bằng `AIza`).
   Đây là `FIREBASE_API_KEY`. Bấm **Continue to console**.

## Bước 3: Bật đăng nhập Google trong Firebase

1. Menu bên trái: **Build** (hoặc **Security**) > **Authentication** > bấm **Get started**.
2. Tab **Sign-in method** > bấm **Google**.
3. Gạt nút **Enable**, ở ô **Project support email** chọn Gmail của bạn, bấm **Save**.

## Bước 4: Tạo "OAuth client" loại Desktop app

Game chạy trên máy tính nên cần một mã đăng nhập loại **Desktop app** (tạo trong Google Cloud, cùng project với Firebase).

1. Vào https://console.cloud.google.com/auth/overview
2. Ở ô chọn project trên cùng, chọn đúng project vừa tạo ở Bước 1 (cùng tên).
3. Nếu trang ghi "Google Auth Platform not configured yet", bấm **Get started** và điền:
   - **App name**: `Fantasy The Awakening`, **User support email**: Gmail của bạn, bấm **Next**.
   - **Audience**: chọn **External**, bấm **Next**.
   - **Contact information**: Gmail của bạn, bấm **Next**.
   - Tích đồng ý điều khoản, bấm **Continue** rồi **Create**.
4. Menu bên trái chọn **Audience**. Ở phần **Test users** bấm **Add users**, thêm Gmail của bạn
   (và Gmail của bạn bè muốn chơi thử), bấm **Save**. Để nguyên chế độ **Testing**.
5. Menu bên trái chọn **Clients** > **Create client**:
   - **Application type**: chọn **Desktop app**.
   - **Name**: `Godot game`, bấm **Create**.
6. Cửa sổ hiện ra có **Client ID** và **Client secret**. Chép cả hai (nên bấm **Download JSON** để giữ lại).
   Đây là `GOOGLE_CLIENT_ID` và `GOOGLE_CLIENT_SECRET`.
7. Quay lại Firebase: **Authentication** > **Sign-in method** > bấm vào dòng **Google** để mở ra.
   Tìm phần **Safelist client IDs from external projects (optional)**, dán **Client ID** ở bước 6 vào, bấm **Add**, rồi **Save**.
   Bước này để Firebase chấp nhận đăng nhập từ game.

## Bước 5: Tạo Realtime Database (nơi cất tài khoản)

1. Firebase, menu bên trái: **Build** (hoặc **Databases & Storage**) > **Realtime Database** > **Create Database**.
2. **Database location**: chọn **Singapore (asia-southeast1)** cho gần Việt Nam, bấm **Next**.
3. Chọn **Start in locked mode**, bấm **Enable**.
4. Ở tab **Data**, trên cùng có địa chỉ dạng `https://....firebasedatabase.app` (hoặc `https://....firebaseio.com`).
   Bấm biểu tượng chép cạnh nó. Đây là `FIREBASE_DATABASE_URL`.
5. Sang tab **Rules**, xóa hết chữ cũ, dán đoạn này vào rồi bấm **Publish**:

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid === $uid",
        ".write": "auth != null && auth.uid === $uid"
      }
    }
  }
}
```

Luật này cho mỗi người chỉ đọc và ghi được tài khoản của chính mình.

## Bước 6: Điền vào game

1. Mở `scripts/cloud.gd` (trong Godot hoặc Antigravity).
2. Điền 4 dòng ở đầu file, giữ nguyên dấu ngoặc kép, ví dụ:

```gdscript
const FIREBASE_API_KEY := "AIzaSy...."
const FIREBASE_DATABASE_URL := "https://fantasy-awakening-default-rtdb.asia-southeast1.firebasedatabase.app"
const GOOGLE_CLIENT_ID := "123456789-abcd....apps.googleusercontent.com"
const GOOGLE_CLIENT_SECRET := "GOCSPX-...."
```

3. Lưu file (**Ctrl + S**).

## Bước 7: Thử đăng nhập

1. Bấm **F5**. Ở màn hình chọn tài khoản, bấm **Đăng nhập Google** ở góc trên bên phải.
2. Trình duyệt tự mở ra, chọn Gmail của bạn.
3. Nếu Google báo **"Google hasn't verified this app"** (Google chưa xác minh ứng dụng này): bấm **Continue** (Tiếp tục).
   Thông báo này hiện vì app đang ở chế độ thử nghiệm của chính bạn, không sao cả.
4. Bấm **Continue** để cho phép xem tên và email. Tab trình duyệt hiện **"Đăng nhập xong!"** thì đóng tab, quay lại game.
5. Góc trên bên phải game hiện Gmail của bạn, dòng dưới danh sách ghi "Đã đồng bộ với Google". Xong!

Từ giờ mỗi lần game tự lưu, nhân vật cũng được gửi lên mạng. Lần sau mở game không cần đăng nhập lại.
Bấm **Đăng xuất Google** thì nhân vật vẫn còn trong máy, chỉ không gửi lên mạng nữa.

---

## Lỗi hay gặp

| Thấy gì | Sửa thế nào |
|---|---|
| Trình duyệt báo **Error 403: access_denied** | Gmail chưa có trong **Test users** (Bước 4, mục 4). |
| Game ghi **"Chưa cài Firebase"** | 4 dòng trong `scripts/cloud.gd` còn trống (Bước 6). |
| Game ghi **"Firebase từ chối: INVALID_IDP_RESPONSE..."** | Chưa dán Client ID vào ô **Safelist** (Bước 4, mục 7). |
| Game ghi **"Google từ chối: invalid_client"** | Client ID hoặc Client secret chép thiếu / sai. |
| Game ghi **"API key not valid"** | `FIREBASE_API_KEY` sai (Bước 2). |
| Game ghi **"Permission denied"** khi đồng bộ | Rules chưa đúng hoặc chưa bấm **Publish** (Bước 5). |
| Game ghi **"Không mở được cổng nhận mã"** | Tắt bớt chương trình đang dùng cổng 53682 đến 53686 rồi thử lại. |

## Vài điều nên biết

- Khi đăng nhập, game mở một "cổng" nhỏ chỉ trong máy bạn (`127.0.0.1`, cổng 53682) để nhận mã từ Google. Cổng đóng ngay sau khi đăng nhập xong.
- Client secret của loại **Desktop app** và API key của Firebase không phải mật khẩu thật (Google cũng nói vậy với app cài trên máy).
  Dữ liệu được bảo vệ bằng **Rules** ở Bước 5.
- Phiên đăng nhập được nhớ trong file `dang_nhap_google.cfg` ở thư mục dữ liệu game (Godot > Project > Open User Data Folder).
  Đừng gửi file này cho người khác.
- **Tài Khoản Full** là tài khoản thử nên không gửi lên mạng.
- Hai máy cùng chơi một nhân vật: bản nào chơi gần đây hơn sẽ được giữ.
