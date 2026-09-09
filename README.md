# شبكاتت

مشروع "شبكاتت" — موارد وتمارين وملاحظات متعلقة بالشبكات (شبكات حاسوب، شبكات لاسلكية، بروتوكولات، إلخ).

## الهدف
أن يكون هذا المستودع مركزًا لملاحظات ومشاريع وتمارين في مجال الشبكات باللغة العربية.

---

## Getting started with GitHub Copilot (Best way to get started)

If you're new to GitHub Copilot, here are concise steps to get productive quickly:

1. Install an editor extension
   - Visual Studio Code: install the "GitHub Copilot" extension from the Extensions marketplace.
   - JetBrains IDEs: install the Copilot plugin from Settings/Plugins.

2. Sign in to GitHub and enable Copilot
   - Sign in with the GitHub account that has access to Copilot (your plan or trial).
   - Accept any prompts and enable Copilot in the editor.

3. Start with small prompts and accept suggestions
   - Open a file and start typing a comment or function signature, e.g. `// implement Dijkstra's algorithm` or `def shortest_path(graph, start):`.
   - Copilot will show inline suggestions — press `Tab` (VS Code default) to accept.

4. Use natural-language comments
   - Write clear instructions in comments or docstrings in Arabic or English, e.g. `# حساب مسار الأقصر باستخدام دجكسترا` — Copilot understands intent and generates code.

5. Iterate and review
   - Treat suggestions as drafts: review correctness, handle edge cases, and add tests.
   - Use the editor's inline history (Copilot pane) to see alternative suggestions.

6. Safety and secrets
   - Never accept or include secrets (API keys, passwords) suggested by any AI assistant.
   - Verify licenses and attribution when using generated content in production.

7. Learn by example
   - Ask Copilot to generate examples, tests, or comments for unfamiliar concepts and then inspect/modify them.

8. Shortcuts and advanced usage (VS Code)
   - `Alt+Enter` (or Cmd/Ctrl+.) to open Copilot panel for alternatives and explanation (depends on extension).
   - Use prompt-style comments to get higher-level algorithms, tests, or refactors.

9. Feedback loop
   - Rate suggestions (thumbs up/down) so Copilot improves for you.

---

## Quick start (Git)

```bash
# clone repo
git clone https://github.com/yassr1997/-44.git
cd -44

# create files locally (already added in repo via this commit)
# start working, create a new branch for features:
git checkout -b feature/first-note
# add your work
# commit and push
git add .
git commit -m "Add first network note"
git push -u origin feature/first-note
```


## Contributing
مرحبًا بالمساهمات — افتح Issue أو أرسل Pull Request مع محتوى تعليمي أو أمثلة برمجية.

---

## Building required tools (aircrack‑ng and hcxtools)
To perform capture conversions and hash extraction (e.g., cap2hccapx, hcxpcapngtool) you may need to build/install aircrack‑ng and hcxtools. Below are tested commands for Ubuntu/Debian and macOS.

Important: Only run these steps on systems and networks you are authorized to test. Do not use these tools against networks you do not own or without explicit permission.

### Ubuntu / Debian / WSL (recommended)
```bash
sudo apt update
sudo apt install -y build-essential autoconf automake libtool pkg-config libssl-dev libnl-3-dev libnl-genl-3-dev libpcap-dev git

# Build aircrack-ng (provides cap2hccapx)
git clone https://github.com/aircrack-ng/aircrack-ng.git
cd aircrack-ng
autoreconf -i
./configure
make -j$(nproc)
sudo make install
sudo ldconfig
cd ..

# Build hcxtools (recommended for hcxpcapngtool -> 22000)
git clone https://github.com/ZerBea/hcxtools.git
cd hcxtools
make -j$(nproc)
sudo make install
sudo ldconfig
cd ..

# Convert examples:
# hcxpcapngtool produces the modern hashcat 22000 format
hcxpcapngtool -o hackme.22000 hackme.cap
# cap2hccapx produces hccapx (older format)
cap2hccapx hackme.cap hackme.hccapx
```

### macOS (Homebrew)
```bash
brew update
brew install aircrack-ng hashcat
# hcxtools may not be available in main taps; build from source if needed
git clone https://github.com/ZerBea/hcxtools.git
cd hcxtools
make
sudo make install
```

### Quick checks
- Verify converter tools exist: `which cap2hccapx` and `which hcxpcapngtool`.
- Inspect capture for EAPOL frames to ensure handshake exists:
  `tshark -r hackme.cap -Y "eapol" -T fields -e frame.number -e wlan.sa -e wlan.da | head`
- Use `aircrack-ng hackme.cap` to list networks and detected handshakes.

If you prefer automation, there's a build script in this repo: `scripts/build_tools.sh` — run it on Ubuntu/Debian to build both aircrack-ng and hcxtools.

---

© 2026 yassr1997
