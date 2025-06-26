# KevinzHub UI Library v2

Giao diện UI Roblox hiện đại, tối ưu spacing, badge version tự động, badge động, headshot avatar, sidebar/tabs hiện đại, tối ưu UI/UX cho script Roblox.

---

## 🆕 Tính năng nổi bật v2

- **Badge version tự căn sát tên, outline động.**
- **Không thể chỉnh version từ ngoài script.**
- **Spacing và alignment tối ưu, không lỗi hiển thị.**
- **Sidebar có avatar user (headshot thật).**
- **Tabs dùng hình ảnh riêng, không đổi màu khi active.**
- **UIListLayout spacing đều, section tự động giãn cách.**
- **Âm thanh click hiện đại cho nút.**
- **Notification đẹp, auto destroy.**
- **Có Minimize/Restore, kéo thả TopBar.**
- **Giao diện phù hợp mọi độ dài tên window.**

---

## 📦 Hướng dẫn sử dụng

### 1. **Tải thư viện**

```lua
local KevinzHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/XUwUxX/script/refs/heads/main/kevinzhub.lua"))()
```

### 2. **Tạo cửa sổ UI**

```lua
local win = KevinzHub:MakeWindow({ Name = "KevinzHub" })
-- Version sẽ tự động là v2, không cần nhập.
```

### 3. **Thêm Tab, Section và các thành phần**

```lua
-- Thêm 1 tab mới
local mainTab = win:MakeTab({ Name = "Main" })

-- Thêm section vào tab
local mainSection = mainTab:AddSection({ Name = "Chức năng chính" })

-- Thêm nút bấm
mainSection:AddButton({
    Name = "Chạy hack",
    Callback = function()
        KevinzHub:MakeNotification({ Name = "Thông báo", Content = "Đã chạy hack!", Time = 2 })
    end
})

-- Thêm slider có textbox nhập giá trị
mainSection:AddSlider({
    Name = "Speed Hack",
    Min = 1, Max = 100, Default = 25,
    WithTextbox = true,
    Callback = function(val)
        print("Tốc độ:", val)
    end
})

-- Thêm toggle
mainSection:AddToggle({
    Name = "Bật ESP",
    Default = false,
    Callback = function(on)
        print("ESP:", on)
    end
})

-- Có thể tạo nhiều tab, section, button, ... như trên.
```

### 4. **Thông báo đẹp**

```lua
KevinzHub:MakeNotification({
    Name = "Chào mừng!",
    Content = "Bạn đang dùng KevinzHub UI v2.",
    Time = 3
})
```

---

## 🎨 **Tùy chỉnh & Mở rộng**

- Không thể chỉnh `version` từ ngoài, chỉ sửa bên trong file lib (KEVINZHUB_VERSION = "2").
- Có thể đổi tên window, thêm nhiều tab, section, button, slider, toggle,...
- Badge version luôn tự căn, không bị che, outline động sinh động.
- Tab icon: Sử dụng asset id `rbxassetid://11718192673` (có thể sửa trong lib nếu muốn).

---

## 💡 **Tips**

- Kéo thả TopBar để di chuyển UI.
- Nhấn nút - để thu nhỏ, nhấn icon restore để mở lại.
- Sidebar có tìm kiếm tab.
- Hình đại diện luôn lấy headshot chuẩn của user.
- Section tự động căn spacing, không lỗi dính hoặc hở.

---

## 📷 **Minh họa giao diện**

![Demo KevinzHub v2](https://i.imgur.com/1lH9p9E.png) <!-- Thay link demo nếu có -->

---

## 📄 **API Tóm tắt**

| Hàm / Đối tượng             | Chức năng                                              |
|---------------------------- |-------------------------------------------------------|
| `KevinzHub:MakeWindow(opt)` | Tạo cửa sổ, opt.Name là tên window                    |
| `window:MakeTab(opt)`       | Thêm tab mới, opt.Name là tên tab                     |
| `tab:AddSection(opt)`       | Thêm section vào tab, opt.Name là tên section         |
| `section:AddButton(opt)`    | Thêm nút, opt.Name là tên, opt.Callback là hàm        |
| `section:AddSlider(opt)`    | Thêm slider (có/không textbox), opt.Callback là hàm   |
| `section:AddToggle(opt)`    | Thêm toggle, opt.Default là trạng thái mặc định        |
| `KevinzHub:MakeNotification(opt)` | Thông báo đẹp, opt.Name, opt.Content, opt.Time   |

---

## 🛠️ **Ví dụ đầy đủ**

```lua
local KevinzHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/XUwUxX/script/refs/heads/main/kevinzhub.lua"))()
local win = KevinzHub:MakeWindow({ Name = "KevinzHub UI" })

local tab1 = win:MakeTab({ Name = "Tab chính" })
local sec1 = tab1:AddSection({ Name = "Section 1" })

sec1:AddButton({
    Name = "Bấm vào đây!",
    Callback = function()
        KevinzHub:MakeNotification({ Name = "Đẹp chưa?", Content = "UI này là KevinzHub v2!", Time = 2 })
    end
})

sec1:AddSlider({
    Name = "Chọn số",
    Min = 0, Max = 50, Default = 10, WithTextbox = true,
    Callback = function(v) print("Value:", v) end
})

sec1:AddToggle({
    Name = "Tắt/Mở gì đó",
    Default = true,
    Callback = function(on) print("Toggle:", on) end
})

local tab2 = win:MakeTab({ Name = "Khác" })
local sec2 = tab2:AddSection({ Name = "Section 2" })
sec2:AddButton({
    Name = "Báo lỗi",
    Callback = function()
        KevinzHub:MakeNotification({ Name = "Có lỗi!", Content = "Đừng lo, chỉ là ví dụ thôi.", Time = 2.5 })
    end
})
```

---

## 🏷️ **Credit**

- Tác giả: [XUwUxX](https://github.com/XUwUxX)
- Mọi bản quyền thuộc về tác giả. Vui lòng không bán lại hoặc mạo danh.

---
