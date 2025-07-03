# 🛠️ Manjaro KDE Dev Setup Script

This script automates the installation of a full-featured development environment on **Manjaro KDE** (Arch-based). It installs essential CLI tools, desktop apps, and configures popular runtimes like Node.js, Rust, Docker, and Nushell.

---

> ⚠️ **WARNING:**
> **Do NOT run this script as root!**
> It must be run as a normal user with sudo privileges.
> Running as root can cause permission issues and break tool installations like `nvm`, `rustup`, and `cargo`.
>
> If you accidentally ran it as root, please remove root-owned tool directories (`/root/.nvm`, `/root/.cargo`, `/root/go`) before rerunning as your user.

## 🚀 Features

- System update and cleanup
- Installs:
  - CLI tools: `git`, `docker`, `go`, `python`, `sqlite`, etc.
  - Desktop apps: `Brave`, `LibreOffice`, `OBS Studio`, `VLC`, etc.
- Sets up:
  - **Node.js** via `nvm` (LTS)
  - **Rust** via `rustup`
  - **Nushell** via Cargo
- Adds user to `docker` group
- Tracks install status and version
- Outputs a log of installed tools

---

## 📦 Included Packages

<details>
<summary>Click to expand</summary>

- `base-devel`, `git`, `go`, `python`, `pip`, `virtualenv`, `build`
- `sqlite`, `postgresql`, `redis`
- `docker`, `docker-compose`
- `brave`, `libreoffice`, `vlc`, `obs-studio`, `thunderbird`, `qbittorrent`
- `kde-partitionmanager`

</details>

---

## 🧪 What it installs via other methods

- **Node.js** (via `nvm`)
- **TypeScript** (via `npm`)
- **Rust** and **Nushell** (via `rustup` + `cargo`)

---

## 📄 Usage

```bash
chmod +x manjaro-kde-setup.sh
./manjaro-kde-setup.sh
```

> ⚠️ Do not run this script as root. Use a normal user with `sudo` access.

---

## 📝 Output

At the end, the script prints and saves a log to:

```bash
~/setup-summary.log
```

This contains a list of all installed tools and their versions.

---

## ✅ After Installation

- Log out and back in to apply Docker group changes
- Verify installations:
  ```bash
  docker --version
  node --version
  nu --version
  ```

---

## 🔧 Customize

Edit the `PACKAGES` array in the script to include or exclude tools.

---

## 🐧 Requirements

- Manjaro KDE (or compatible Arch-based distro)
- Internet connection
- sudo privileges

---

## ❤️ Inspired by

- [Arch Wiki](https://wiki.archlinux.org/)
- [Rust](https://www.rust-lang.org/)
- [Node Version Manager (nvm)](https://github.com/nvm-sh/nvm)
- [Nushell](https://www.nushell.sh/)

---

## 📬 License

MIT – Use, modify, share freely.
