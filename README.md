//
//  README.md.swift
//  Gather
//
//  Created by Renaissance Carr on 6/1/25.
//

# 📬 Gather – Group Planning iMessage App

**Gather** is an all-in-one group planning experience, built directly into iMessage. Designed to feel completely native, Gather empowers group chats (friends, families, clubs, etc.) to quickly coordinate plans without leaving the conversation.

---

## 🎯 What It Does

Gather embeds rich interactive cards in iMessage threads for:

- ✅ **Polls** – Create single- or multi-choice polls with live vote tracking
- ✅ **Micro-RSVPs** – Quickly respond with "Yes / No / Maybe" to group invites
- ✅ **Live Results** – Results shown as animated bar charts in chat bubbles
- ✅ **Multi-Select Support** – Users can vote on more than one option when allowed
- ✅ **One-Vote Lock** – Users can only vote once per poll
- ✅ **Electric Violet Branding** – Clean, dark/light adaptive UI
- ✅ **iMessage-Native UX** – Seamlessly embedded in the conversation thread

---

## 🧱 Tech Stack

| Layer              | Tech                      |
|--------------------|---------------------------|
| iMessage Extension | `Swift`, `UIKit`          |
| Data Encoding      | `Base64 JSON → URL`       |
| Message Format     | `MSMessageTemplateLayout` |
| Styling            | `Dark/Light Mode`, custom color system |
| Chart UI           | Animated `UIView` bars for result display |

---

## ✨ Planned Features (Upcoming)

| Category               | Feature                                       |
|------------------------|-----------------------------------------------|
| 📊 Voting              | Vote-by-emoji, write-in answers               |
| 🗓 Event Planning      | Calendar-style RSVP cards                     |
| 🧾 Shared Lists        | Collaborative checklists (e.g. potlucks)      |
| 🎲 Lightning Tools     | Coin flips, name spinners, random decisions   |
| 📍 Location Polls      | Map previews, voting on venues                |
| 🎂 Birthday Tracking   | Birthday reminders with tap-to-remind cards   |
| 📤 Full App (v2)       | Push notifications and archive of past polls |
| 🕹️ Game Mode           | Group party games (e.g. vote-based trivia)    |

---

## 🧪 Testing

### On Simulator:
1. Open the **Messages app** in the simulator
2. Start a new thread with a fake contact (e.g. `555-0100`)
3. Open the **Gather** iMessage app from the app drawer
4. Create and send a poll
5. Tap the message bubble to view and vote

### On Device:
1. Connect an iPhone via USB
2. Select your device in Xcode and build `MessagesExtension`
3. Open an iMessage thread and launch Gather from the app drawer
4. Create and vote on polls in a real conversation

---

## 🚧 Development Notes

- Polls are encoded via Base64 and passed as `MSMessage.url`
- Each user gets one vote tracked per session
- Vote counts update live and resend new card bubbles
- Animations reflect engagement using UIKit

---

## 🖌️ Brand Colors

| Name            | Color      | Hex       |
|-----------------|------------|-----------|
| Primary (Violet)| Electric Violet | `#8F00FF` |
| Accent          | Golden Amber (future) | `#FFC857` |

---

## 📁 Folder Structure

```
📁 Gather/
├── 📦 MessagesExtension/
│   ├── 🎨 Views/                  # UIKit views and layout logic for message bubbles
│   ├── 📡 Messaging/              # MSMessage creation, encoding, decoding logic
│   ├── 🧠 Models/                 # Codable structs like Poll, PollOption
│   ├── 🛠️ Controllers/           # View controllers for composing and handling polls
│   ├── 🧪 Testing/                # Test helpers and sample polls
│   └── Assets.xcassets/          # App icons, bubble backgrounds, brand visuals
├── 📲 Gather (Host App)/
│   ├── AppDelegate.swift         # Standard app delegate
│   ├── Assets.xcassets/          # Icon and brand assets for the host app
│   └── LaunchScreen.storyboard   # Blank screen for launching the iMessage extension
└── 📄 README.md                  # You're here!
```

---

## 🧠 Key Design Decisions

- All messages are ephemeral: we use the iMessage bubble itself as the single source of truth for state.
- Poll data is embedded in the URL, eliminating the need for a backend.
- Layouts are adaptive, theme-aware (dark/light), and aligned with Apple's HIG.
- We avoid push notifications or background services in v1 to keep the app extension lightweight and performant.

---

## 💡 Inspiration


Gather is inspired by the small frictions we experience daily in group chats— indecision, forgotten plans, too many texts with no resolution. We designed Gather to bring structure without killing spontaneity.

---

## 🗓️ Launch Timeline

We’re aiming to ship Gather to the App Store in **July 2025**.
Stay tuned for beta access and early demos!

---

## 👥 Made By

Renaissance Carr — 2025
Built with Swift, UIKit, and a lot of group text frustration.

## 📸 Screenshots

Here’s what Gather looks like in action:

<div align="center" style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">

  <img src="https://github.com/user-attachments/assets/82ee019e-27a5-4cc8-913f-67a90618ddb8" width="200" />
  <img src="https://github.com/user-attachments/assets/260bf7c7-ed53-4fa1-9430-0fa6456c2a7f" width="200" />
  <img src="https://github.com/user-attachments/assets/18a1900e-add8-42b1-8ef1-5e0b1260aa9a" width="200" />
  <img src="https://github.com/user-attachments/assets/6dcaab3f-666f-4872-9540-3ddf55b2ae84" width="200" />
  <img src="https://github.com/user-attachments/assets/b10e2a5d-725a-4df6-ba15-22739e2f462b" width="200" />
  <img src="https://github.com/user-attachments/assets/690b0ee3-f8ab-4999-ab01-5477a81ddbf4" width="200" />

</div>
