# Activities heatmap

Everyone adds one small file saying how they spend their week. One R script reads all the files and draws a class heatmap.

Each of you edits **only your own file**, so nobody's changes can conflict with anyone else's.

## Your steps

1. Get the latest version of the repo:

   ```bash
   git pull
   ```

2. Copy the template into your own folder:

   ```bash
   cp activities-heatmap/activities-template.csv students/<your-username>/activities.csv
   ```

3. Open `students/<your-username>/activities.csv` and fill in the `percent` column. Your numbers should add up to **100**. Don't change the activity names: the script matches them exactly.

   ```
   activity,percent
   sleep,33
   class,15
   studying,12
   work,15
   screens,15
   other,10
   ```

4. Commit and push just your file:

   ```bash
   git add students/<your-username>/activities.csv
   git commit -m "add my activities"
   git push
   ```

   If the push is rejected because someone pushed first, run `git pull`, then `git push` again.

## Making the heatmap

From the `shiny-collab` folder:

```bash
git pull
```

Then open `activities-heatmap/activities-heatmap.R` and run it. It finds every `students/*/activities.csv`, stacks them with `read_csv()`, and draws one row per student. A row whose numbers don't add to 100 is rescaled, and a red note appears next to it.

## If pulling or pushing goes wrong

First, run `git status`. It almost always says what state you're in and what to do next. Then find your message below.

### Before you start: one-time setup

If you haven't already, run these once (they're also in step 0.3 of the main README):

```bash
git config --global pull.rebase true
git config --global rebase.autoStash true
```

They make `git pull` put your commits on top of everyone else's instead of creating a merge, which avoids most of the problems below.

### `! [rejected] main -> main (fetch first)` when you push

Someone pushed before you. That's normal:

```bash
git pull
git push
```

### An editor (vim) opens with "Merge branch 'main' of ..."

Git wants a message for a merge commit. Accept the default: press `Esc`, type `:wq` and press Enter. Then `git push`.

This means `pull.rebase` isn't set yet. Run the one-time setup above.

Stuck in vim and just want out? Press `Esc`, then type `:q!` and Enter.

### `cp: ... No such file or directory`

- Run the `cp` command from the `shiny-collab` folder (`pwd` shows where you are).
- Use your exact username, the same as your folder name in `students/`.

### `Your local changes to the following files would be overwritten`

You have unsaved changes to files that the pull wants to update.

- **If they're your own files** and you want to keep the changes:

  ```bash
  git stash
  git pull
  git stash pop
  ```

- **If they're files you didn't mean to change** (other people's folders, the README, starter files), throw your changes away:

  ```bash
  git restore <file>
  git pull
  ```

### `The following untracked working tree files would be overwritten`

You have a file that someone else has since committed. If it isn't yours, move it out of the way, then pull:

```bash
mv <file> ~/Desktop/
git pull
```

### `CONFLICT` during `git pull`

You and someone else changed the same lines of the same file. If you only edited your own `activities.csv`, this shouldn't happen. Check `git status` to see which file it is.

- **Not your file?** Back out, and ask me:

  ```bash
  git rebase --abort
  ```

- **Your file?** Open it, keep the lines you want, delete the `<<<<<<<`, `=======` and `>>>>>>>` lines, then:

  ```bash
  git add <file>
  git rebase --continue
  git push
  ```

### `You are currently rebasing` or `interactive rebase in progress`

A pull stopped partway. To undo it and get back to where you were before the pull:

```bash
git rebase --abort
```

If that says `could not read '.git/rebase-merge/head-name'`, git's leftover bookkeeping is broken. Delete it:

```bash
rm -rf .git/rebase-merge .git/rebase-apply
git status
```

### `Unable to create '.../.git/index.lock': File exists`

Another git command is still running, or crashed. Close Positron and any other git windows, then:

```bash
rm -f .git/index.lock
```

### `Permission denied` or `403` when you push

You haven't accepted the GitHub collaborator invite, or you signed in with a different GitHub account. Check <https://github.com/notifications>.

### `fatal: not a git repository`

You're not inside the `shiny-collab` folder. `cd` into it first.

### I committed the wrong file

If you haven't pushed yet, undo the last commit but keep your files as they are:

```bash
git reset --soft HEAD~1
git restore --staged <wrong-file>
```

Then commit again with only your `activities.csv`. If you already pushed, ask me.

### Still stuck?

Copy the output of `git status` and ask me before trying anything drastic. Don't delete and re-clone the repo: you'd lose any work you haven't pushed.
