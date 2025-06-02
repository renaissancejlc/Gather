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
