# Webash v2.2.3

A simple, interactive Bash project generator that scaffolds a modern **static web** structure for you in seconds. It generates a semantic `index.html`, a modern dark-themed `styles/style.css`, and a production-ready `src/main.js`.

---

[![Language](https://img.shields.io/badge/Language-Bash-black?style=for-the-badge&logo=bash)](https://www.gnu.org/software/bash)
[![NPM Version](https://img.shields.io/badge/npm-v2.2.3-blue?style=flat-square&logo=npm)](https://www.npmjs.com/package/webash-cli)
[![Version](https://img.shields.io/badge/Version-2.2.3-green?style=flat-square)](https://github.com/fhermas22/webash)

---

## 🚀 Quick Start (No Installation Required)

Thanks to **npm**, you don't even need to clone this repository or download any files. You can execute Webash instantly from anywhere using **`npx`**:

```bash
npx webash-cli
```

---

## 🛠️ What it Generates

Depending on your preference, Webash will scaffold the following modern structure either directly in your current directory or inside a new dedicated folder:

```
<project_name>/
├─ index.html
├─ assets/
├─ src/
│  └─ main.js
└─ styles/
   └─ style.css
```

### 📄 `index.html`

* Clean HTML5 semantic layout.
* Pre-linked to `styles/style.css` and `src/main.js`.
* Responsive viewport configuration.

### 🎨 `styles/style.css`

* Modern Dark Mode theme out-of-the-box using CSS custom properties (variables).
* Clean global layout reset (`* { margin: 0; padding: 0; box-sizing: border-box; }`).
* Fully centered Glassmorphism/Dark UI container box using Flexbox.
* Built-in badge and modern typography styles.

### ⚡ `src/main.js`

* Safe initialization enclosed inside a `DOMContentLoaded` event listener.
* Dynamic console greeting mapping your exact project name.

---

## ⚙️ How it Works (Interactive Flow)

When executed, Webash guides you through a streamlined CLI setup:

1. **Branding:** Displays a stylized ASCII Art logo bound to the current framework global version.
2. **Environment Scan:** Prints your exact current working directory path.
3. **Deployment Mode Choice:** Prompts you whether to create a new subfolder `(y/N)`.
* **If No (Default):** Deploys files directly in your current workspace, dynamically adapting the project metadata to your current folder name.
* **If Yes:** Prompts for a project name (falls back to `web_project` if left blank).
4. **Smart Conflict Resolution:** If the requested folder already exists, Webash triggers an interactive loop asking whether you want to **Overwrite it** `[y/N]` or **Pick another name** safely without losing data.
5. **Boilerplate Injection:** Creates all folders and injects the semantic premium web template.
6. **Architecture Tree:** Outputs a visual breakdown of your new project (`tree` binary if available, otherwise falls back to a recursive `ls -R`).

---

## 📋 Requirements

* Linux / macOS / WSL shell environment running **Bash**.
* Standard system binaries: `mkdir`, `cat`, `tr`, `basename`.
* **Node.js & npm** (Only if you wish to run it globally via `npx`).
* *Optional:* `tree` command for advanced post-generation structural logging.

---

## 💻 Manual Local Usage

If you prefer to download and run the script locally instead of using `npx`:

1. Make sure the script is granted execution permissions:
```bash
chmod +x webash.sh
```

2. Fire it up:
```bash
./webash.sh
```

---

## ⚠️ Safety & Overwrite Policy

Webash prioritizes your data safety. Unlike previous versions, **it will never delete data automatically**.

* If a folder collision occurs, the script enters a protective state.
* Existing files are wiped using `rm -rf` **only if** you explicitly type `y` or `yes` when prompted to overwrite.

---

## 💡 Customization Ideas

The script is modular by design. You can easily modify the script's `cat << EOF` sections to:

* Inject your favorite CSS frameworks (Tailwind CSS CDN, FontAwesome, etc.).
* Add multi-page scaffolding templates (e.g., `about.html`, `contact.html`).
* Preset specific JavaScript utilities or state management templates inside `src/main.js`.

---

## 📄 License

This project is open-source software licensed under the [MIT License](https://github.com/fhermas22/webash?tab=MIT-1-ov-file).

---

## 👨‍💻 Built By

**[Hermas Francisco (fhermas22)](https://github.com/fhermas22)** — Pragmatic software engineering and automated environments.