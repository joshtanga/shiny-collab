# Bug Hunt

Each app in this folder has **exactly one bug**. The comment at the top of each file describes the **symptom**, meaning what you see when you run it. Your job is to find the cause, fix it, and commit the fix with a message that names the bug.

| app | difficulty | symptom |
|---|---|---|
| `bug01.R` | ★ | the app won't start; R stops with an error |
| `bug02.R` | ★ | no errors, but the plot never shows up |
| `bug03.R` | ★ | the second card is missing its title bar |
| `bug04.R` | ★★ | the "scatterplot" is a single dot, whatever you choose |
| `bug05.R` | ★★ | a red error message where the plot should be |
| `bug06.R` | ★★ | the plot is blank until you click the button |
| `bug07.R` | ★★ | clicking "New sample" does nothing |
| `bug08.R` | ★★ | the plot works for two species, but is empty for the third |
| `bug09.R` | ★★ | the value box always says "NA g" |
| `bug10.R` | ★★★ | a clicked point won't stay selected |
| `bug11.R` | ★★★ | the card title and the plot describe different variables |

## How to play

1. **Pull** the latest version of the repo:

   ```bash
   git pull
   ```

2. **Copy** a bug into your own folder. Never edit the files in `bug-hunt/` itself. Everyone shares them, and editing them causes merge conflicts.

   ```bash
   mkdir -p students/<your-username>/bug-hunt
   cp bug-hunt/bug04.R students/<your-username>/bug-hunt/
   ```

3. **Run it** and confirm you see the symptom described at the top.
4. **Find and fix** the bug. Change as little code as possible: one bug means one fix. Add a comment on the line you changed:

   ```r
   # FIX: <what was wrong, in a few words>
   ```

5. **Run it again** and make sure the symptom is gone.
6. **Commit one bug at a time**, with a message that names the bug:

   ```bash
   git add students/<your-username>/bug-hunt/bug04.R
   git commit -m "bug04: <what was wrong and how you fixed it>"
   git pull
   git push
   ```

   A good message says what was wrong. "fixed it" doesn't count.

Start with the ★ bugs and work your way up. The ★★★ bugs are harder because there's no error message, and the code *looks* right.

## Debugging tips

These apply to every bug here, and to every app you'll ever write.

- **Read the error message.** It usually names the line, or the function, that went wrong.
- **No error but nothing shows?** Check that every `*Output("id")` in the `ui` has a matching `output$id` in the `server`, spelled *exactly* the same.
- **Test outside Shiny.** Copy the code from inside a `render*()` or `reactive()` into the console, replace `input$xyz` with a real value (e.g. `input$island` → `"Biscoe"`), and run it line by line.
- **Look at the data.** Use `glimpse()`, `unique()` and `summary()`. Does the value you're filtering for actually appear in the data, spelled the same way?
- **Print things.** Add `print(input$xyz)` or `print(nrow(my_data()))` inside the server, then watch the console while you use the app.
- **Ask "when does this run?"** Many Shiny bugs aren't wrong code. The code runs at the wrong time, too often, or never.

## Bonus: write your own bug

Once you've fixed a few, write a **new** buggy app for your classmates:

1. Start from a working app (yours, or a starter app).
2. Introduce **one** bug, ideally one you've actually made before.
3. Add a header comment describing **only the symptom**, in the same style as the files here.
4. Save it as `students/<your-username>/bug-hunt/mybug_<your-username>.R`, then commit and push.
5. Fix a classmate's bug the same way you fixed the ones above.
