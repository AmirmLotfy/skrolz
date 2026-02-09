# Push to GitHub repo `skrolz`

Do this once to create the remote repo and push.

## 1. Create the repo on GitHub

- **Option A — GitHub CLI** (if you have `gh` installed):
  ```bash
  gh repo create skrolz --public --source=. --remote=origin --push
  ```
  Run this from the project root. If you already ran `git init` and `git add` / `git commit` below, use:
  ```bash
  gh repo create skrolz --public --source=. --remote=origin
  git push -u origin main
  ```

- **Option B — GitHub website**
  1. Go to [github.com/new](https://github.com/new).
  2. Repository name: **skrolz**.
  3. Public, no template, then **Create repository**.
  4. Do **not** add a README or .gitignore (you already have them).

## 2. Initialize and push from this project

From the project root:

```bash
git init
git add .
git commit -m "Initial commit: Skrolz — Gemini 3 Hackathon"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/skrolz.git
git push -u origin main
```

Replace **YOUR_USERNAME** with your GitHub username.

## 3. Update README repo link

After pushing, edit **README.md** and replace:

- `YOUR_USERNAME` with your GitHub username in the repo URL and clone command.

Then commit and push:

```bash
git add README.md && git commit -m "docs: fix repo URL in README" && git push
```
