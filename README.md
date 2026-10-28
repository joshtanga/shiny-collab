# DAT 309 — Shiny Collab: Git + GitHub with Shiny apps

In this project you'll use **git** and **GitHub** the way data scientists actually work together. You'll:

1. install git on your laptop 
2. clone a shared repository of Shiny apps
3. modify the starter apps into apps of your own and push them
4. pull down your classmates' apps, improve one of them, and push a **pair-modified** version

By the end you should be comfortable with the everyday git loop:

```
pull  →  edit  →  add  →  commit  →  push
```

---

## What's in this repo

```
shiny-collab/
├── README.md            ← you are here
├── .gitignore           ← tells git which files to ignore (.RData, .Rhistory, ...)
├── shiny-collab.Rproj
├── data/
│   └── electoral_numbers.csv
├── starter-apps/        ← the class examples. DO NOT EDIT these.
│   ├── app-basic1.R     ← slider + ggplot of y = x^2
│   ├── app-basic2.R     ← adds a reactive table
│   ├── app-basic3.R     ← LaTeX with withMathJax()
│   ├── app-basic3_b.R   ← type in your own function of x
│   ├── app-basic4.R     ← palmerpenguins + 3D plotly
│   ├── app-basic5.R     ← adds selectInput() + table
│   ├── app-basic6.R     ← range slider + verbatimTextOutput()
│   ├── app-basic7.R     ← formatting text: p(), strong(), em(), div(), span(), tags$
│   ├── app-basic8.R     ← bslib cards with layout_column_wrap()
│   ├── app-basic9.R     ← more cards
│   ├── app-basic10.R    ← cards + tabs with navset_card_tab()
│   ├── some-app.R       ← switching layouts with renderUI()
│   └── notes-leaflet-sf.R  ← links for maps (leaflet, sf)
└── students/
    ├── abhall/          ← each student works ONLY in their own folder
    ├── jmorton/
    └── ...
```

> **The golden rule:** only create or change files inside **your own** `students/<your-username>/` folder. If everyone stays in their own folder, nobody's work collides and you'll (almost) never see a merge conflict.

Your username is the same one you use for the SAMBA folder (`abhall`, `jmorton`, `tatgordo`, ...).

---

## Part 0 — Before class

### 0.1 Make a GitHub account

Go to <https://github.com> and sign up (a free account is fine). Use any email you like.
**Send me your GitHub username** so I can add you as a collaborator on the repo. You'll get an email invitation; **accept it**, or you won't be able to push.

### 0.2 Install git on Windows

First check whether you already have it. Open **PowerShell** (Start menu → type `powershell`) and run:

```
git --version
```

If you see something like `git version 2.4x.x.windows.1`, skip to 0.3.

Otherwise, install **Git for Windows** using either option:

- **Option A (easiest):** download the installer from <https://git-scm.com/download/win> and run it. **Accept all the default options.** The defaults include *Git Bash* and *Git Credential Manager*, which you need.
- **Option B (command line):** in PowerShell, run

  ```
  winget install --id Git.Git -e --source winget
  ```

**Close and reopen** PowerShell (and Positron), then check again with `git --version`.

### 0.3 Tell git who you are (one time only)

Open **Git Bash** (Start menu → `Git Bash`) and run these, using your own name and the email from your GitHub account:

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase false
```

Check your settings:

```bash
git config --global --list
```

### 0.4 Use Git Bash inside Positron (recommended)

You don't have to switch back and forth between Positron and a separate Git Bash window. Make Git Bash Positron's default terminal:

1. In Positron, open the Command Palette with **Ctrl + Shift + P**.
2. Type **Terminal: Select Default Profile** and press Enter.
3. Choose **Git Bash**.
4. Open a new terminal (**Terminal → New Terminal**, or press `` Ctrl + ` ``, the backtick key, above Tab). The prompt should end in `$`, not `PS C:\>`.

From now on, whenever this README says "in Git Bash", you can just use Positron's terminal.

> **Why Git Bash and not PowerShell?** `git` works in either. But Git Bash gives you the same commands (`ls`, `cp`, `mkdir`, ...) used on Mac/Linux, in this README, and in almost every git tutorial online. Some commands behave differently in PowerShell; for example, `echo "..." > file` writes a file that shows up garbled on GitHub.

---

## Part 1 — Clone the repo (in class)

1. On the repo's GitHub page, click the green **Code** button and copy the **HTTPS** URL. It looks like `https://github.com/joshtanga/shiny-collab.git`.
2. In Git Bash (or Positron's terminal, see 0.4), go to wherever you keep your DAT 309 work and clone:

   ```bash
   cd ~/Documents            # or wherever you keep class files
   git clone https://github.com/joshtanga/shiny-collab.git
   cd shiny-collab
   ls
   ```

3. Open the `shiny-collab` folder in **Positron** (File → Open Folder).
4. Find your folder. I've already created a folder for each of you at `students/<your-username>/` (e.g. `students/jmorton/`), with a placeholder `README.md` inside. **Don't create a new folder, and don't rename yours.**

   ```bash
   ls students                       # you should see your username
   ls students/<your-username>       # you should see README.md
   ```

5. Do your first commit and push. In Positron, open `students/<your-username>/README.md` and replace the placeholder with your name and one sentence about yourself. Save it, then:

   ```bash
   git status                         # see what changed (red = not staged)
   git add students/<your-username>   # stage ONLY your folder
   git status                         # green = staged
   git commit -m "<your-username>: update my README"
   git pull                           # get anyone else's changes first
   git push
   ```

   The **first** time you push, a window pops up asking you to sign in to GitHub. Choose **Sign in with your browser** and authorize Git Credential Manager. After that, git remembers you.

If `git push` is **rejected**, someone else pushed first. That's normal; see [When git complains](#when-git-complains).

---

## Part 2 — Make your own modified apps

### 2.1 Always start by pulling

```bash
git pull
```

### 2.2 Copy a starter app into your folder, then modify it

**Never edit the files in `starter-apps/` directly.** Copy one into your folder first:

```bash
cp starter-apps/app-basic5.R students/<your-username>/<your-username>_app1.R
```

Open your copy in Positron and click **Run App** to make sure it works before you change anything. Then make it yours. Some ideas:

- use a different dataset (`palmerpenguins`, `gapminder`, `nycflights13`, your Project 2 data, ...)
- add a new input: `selectInput()`, `checkboxGroupInput()`, `radioButtons()`, `dateRangeInput()`, ...
- add a new output, such as a table (`renderTable()`) or summary text (`renderText()`)
- switch a `ggplot` to `plotly`, or the other way around
- re-lay it out with `bslib` cards, columns or tabs (see `app-basic8.R` to `app-basic10.R`)
- add a `reactive()` so that one filtered dataset feeds several outputs

### 2.3 Requirements for each app you write

Put a header comment block at the top of every app:

```r
# ------------------------------------------------------------
# App:        <your-username>_app1.R
# Author:     <Your Name>
# Started from: starter-apps/app-basic5.R
# What I changed:
#   - swapped penguins for gapminder
#   - added a selectInput for continent
#   - added a summary table that reacts to the slider
# ------------------------------------------------------------
```

Each app must:

- [ ] run without errors from a fresh R session (click **Run App**)
- [ ] have **at least one input** that changes **at least one output**
- [ ] differ from its starter app in a meaningful way (more than changing a title or a color)
- [ ] use relative paths for any data, e.g. `read_csv("../../data/electoral_numbers.csv")`. Never use `C:/Users/...`, because nobody else's laptop has your C: drive.
- [ ] list every package it uses with `library()` at the top

Make **at least two** modified apps: `<your-username>_app1.R` and `<your-username>_app2.R`. They should start from different starter apps.

### 2.4 Commit early, commit often

Every time something works, commit it:

```bash
git status
git add students/<your-username>/<your-username>_app1.R
git commit -m "app1: add continent selectInput and summary table"
git pull          # grab everyone else's work first
git push
```

Good commit messages say **what** changed: `"app2: switch to plotly, add tab layout"`. Avoid messages like `"stuff"` or `"asdf"`.

---

## Part 3 — Pair-modify a classmate's app

### 3.1 Pull everyone's work

```bash
git pull
ls students/*
```

### 3.2 Pick (or get assigned) a partner's app

I'll post the pairings. If none are posted, pick an app from a classmate whose app nobody else has claimed yet, and tell the class.

**Copy their app into your own folder.** Don't edit their file:

```bash
cp students/<partner>/<partner>_app1.R students/<your-username>/pair_<partner>_app1.R
```

### 3.3 Improve it

1. Run it first. Read their code and their header comment. What were they going for?
2. Then build on it. Add a feature, fix a bug, improve the layout, add explanatory text, or make the plot clearer.
3. **Add to** the header block rather than replacing it:

```r
# ------------------------------------------------------------
# App:        pair_<partner>_app1.R
# Original author: <Partner Name>  (students/<partner>/<partner>_app1.R)
# Pair-modified by: <Your Name>
# What I changed:
#   - fixed the y-axis label
#   - added a checkboxGroupInput for species
#   - moved the table into a second tab
# ------------------------------------------------------------
```

### 3.4 Push it

```bash
git add students/<your-username>/pair_<partner>_app1.R
git commit -m "pair-modify <partner>'s app1: add species filter + tabs"
git pull
git push
```

Then **tell your partner** to `git pull` and look at what you did with their app.

---

## What to turn in

Your work in the repo **is** the submission. By the deadline, your `students/<your-username>/` folder should contain:

| file | what it is |
|---|---|
| `README.md` | your name, plus 2–3 sentences about each of your apps |
| `<you>_app1.R` | your first modified app |
| `<you>_app2.R` | your second modified app |
| `pair_<partner>_appN.R` | your pair-modified version of a classmate's app |

I'll also look at the **commit history**, so commit as you go, not all at once at the end. You can see the history with:

```bash
git log --oneline --graph --all
```

---

## Everyday git cheat sheet

| command | what it does |
|---|---|
| `git status` | what's changed? what's staged? (**run this constantly**) |
| `git pull` | download and merge everyone else's new commits |
| `git add <file>` | stage a file for the next commit |
| `git commit -m "msg"` | save a snapshot of staged files, with a message |
| `git push` | upload your commits to GitHub |
| `git log --oneline` | list recent commits |
| `git diff` | show exactly what you changed (press `q` to quit) |
| `git restore <file>` | throw away your unsaved changes to a file (careful!) |

**Positron users:** the **Source Control** panel (the branch icon in the left sidebar) does the same things with buttons: `+` stages, the ✓ commits, and **Sync** pulls and pushes. Use whichever you like, but learn the commands too.

---

## When git complains

**`! [rejected] main -> main (fetch first)`** or **`Updates were rejected because the remote contains work...`**
Someone pushed before you. That's normal. Run:

```bash
git pull
git push
```

**An editor opens with a "Merge branch 'main'..." message after `git pull`**
Git is asking you to confirm a merge commit message. Accept the default. In **vim** (what Git Bash uses by default), type `:wq` and press Enter. To avoid vim in future, set Positron/VS Code as git's editor: `git config --global core.editor "code --wait"`.

**`CONFLICT (content): Merge conflict in ...`**
You edited a file someone else also edited. This shouldn't happen if you stay in your own folder. If it does:

1. Open the file. Look for the `<<<<<<<`, `=======` and `>>>>>>>` markers.
2. Keep the version you want and delete the markers.
3. Run `git add <file>`, then `git commit`, then `git push`.
4. If you're stuck, ask me before doing anything drastic.

**`Permission denied` or `403` on push**
Either you haven't accepted the collaborator invite (check your email or <https://github.com/notifications>), or you signed in to GitHub with the wrong account.

**`fatal: not a git repository`**
You're not inside the `shiny-collab` folder. Run `cd` into it first.

**I committed something I didn't mean to (like `.RData`)**
Don't panic, and don't delete the repo. Ask me. The `.gitignore` should prevent most of this.

---
