# Webash v2.2

A simple Bash “project generator” that scaffolds a small, modern **static web** structure for you: a `index.html`, a dark-themed `styles/style.css`, and a `src/main.js`.

---

[![Language](https://img.shields.io/badge/Language-Bash-black?style=for-the-badge&logo=bash)](https://www.gnu.org/software/bash)
[![Version](https://img.shields.io/badge/Version-2.2-green?style=flat-square)](https://github.com/fhermas22/webash)

---

## What it generates

Given a project name (prompted at runtime), Webash creates a folder like:

```
<project_name>/
├─ index.html
├─ assets/
├─ src/
│  └─ main.js
└─ styles/
   └─ style.css
```

### `index.html`
- Semantic, structured layout
- Links `styles/style.css`
- Loads `src/main.js`

### `styles/style.css`
- Dark theme using CSS variables
- Global reset (`* { margin: 0; padding: 0; box-sizing: border-box; }`)
- Centered “card” UI container
- Typography + badge styling

### `src/main.js`
- Includes a `DOMContentLoaded` listener
- Logs a success message in the browser console

---

## How it works (high level)

When you run the script:
1. Displays a stylized CLI logo (shows the generator version).
2. Prints the current working directory.
3. Prompts whether to create a dedicated subfolder.
4. If you choose a subfolder, prompts: **Enter your web project name** (defaults to `web_project` if empty).
5. If the target folder already exists, Webash asks before overwriting; when confirmed, it deletes it using `rm -rf` and recreates it.
6. Creates directories and writes the HTML/CSS/JS boilerplate.
7. Prints the resulting directory tree (`tree` if available, otherwise `ls -R`).

---

## Requirements

- Linux/macOS shell with **bash**
- Common utilities: `mkdir`, `cat`
- Optional: `tree` (used for the final output). If not installed, it falls back to `ls -R`.

---

## Usage

1. Make sure the script is executable:

```bash
chmod +x webash_v2.sh
```

2. Run it:

```bash
./webash_v2.sh
```

3. Enter a name when prompted, for example:

- `my-landing-page`

---

## Example

```bash
$ ./webash_v2.sh
Enter your web project name: awesome-site

Your project awesome-site has been created successfully!
...
```

Then open:

- `awesome-site/index.html`

---

## Notes / Safety

- **Destructive behavior:** If the target directory already exists, Webash deletes it using:
  - `rm -rf "$project_name"`

If you want to preserve existing projects, you should rename the project or modify the script to skip deletion.

---

## Customization ideas

You can extend the generator by editing the script sections that write:
- `styles/style.css`
- `src/main.js`
- `index.html`

Suggested next steps:
- Add a template section for additional pages (e.g. `about.html`)
- Add assets scaffolding (images/fonts)
- Add form handling / interactive UI starter in `main.js`

---

## License

MIT

---

## Built by

**[fhermas22](https://github.com/fhermas22)** — Webash index & generator for static web projects.