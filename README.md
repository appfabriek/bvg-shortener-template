# BV Geert — Shortener template

Bitly-style URL forwarder template for [BV Geert](https://bvgeert.com) domains.

Currently in use on **[nm.nu](https://nm.nu)** and **[geert.link](https://geert.link)**.

## What it does

- **Public landing**: a dark, focused promo page that says "private URL forwarder — sign in if you're invited"
- **Admin chrome**: clean dark dashboard with `Links` + `Settings` nav, auto-redirects logged-in admins to `/admin/links`
- **Non-admin lockout**: regular users who sign in see a "nothing here for you" card with a logout button — no nav, no access

Authorization is enforced by BV Geert (`user.admin?`). This template just renders accordingly.

## How to use this template

1. Fork (or *Use this template*) on GitHub.
2. In **/admin/instellingen** on your domain, fill **Template-repo** with `owner/repo`.
3. Click **Save** → **Sync now**.
4. (Optional) Set up auto-sync — see `.github/workflows/sync.yml` and the section below.

## Files

| File             | Purpose                                                |
|------------------|--------------------------------------------------------|
| `index.html`     | Public landing (English)                               |
| `index.nl.html`  | Public landing (Dutch)                                 |
| `app.html`       | Logged-in shell (wraps every authenticated page)       |
| `css/landing.css`| Styling for the public landing                         |
| `css/app.css`    | Styling for the logged-in shell + Rails content        |
| `images/`        | Logo/favicon served by BcAssetServer (`/images/*`)           |
| `icons/`         | Optional pack for Admin → Logo upload / mobile icons         |
| `.github/workflows/sync.yml` | Webhook to BV Geert on push           |

## Placeholders

Used in `index.html` (public):

| Placeholder        | What it becomes                                           |
|--------------------|-----------------------------------------------------------|
| `{{login_form}}`   | Full OAuth + magic-link login form (with built-in styling) |
| `{{login_button}}` | Single primary OAuth button                                |
| `{{footer}}`       | BV Geert footer                                            |
| `{{csrf_meta}}`    | CSRF meta tags                                             |
| `{{brand_name}}`   | Your domain's brand name                                   |
| `{{brand_logo}}`   | Domain logo URL from Admin → Settings (fallback `/logokl.svg`) |
| `{{brand_apple_touch_icon}}` | 180×180 apple-touch (or `/icon.png`)               |
| `{{current_year}}` | Current year                                               |

Used in `app.html` (logged-in):

| Placeholder        | What it becomes                                           |
|--------------------|-----------------------------------------------------------|
| `{{content}}`      | The Rails-rendered page content                            |
| `{{flash}}`        | Toast container                                            |
| `{{user_menu}}`    | Email + logout button                                      |
| `{{user_role}}`    | `"admin"`, `"user"`, or `"guest"` — used for role gating  |
| `{{footer}}`       | BV Geert footer                                            |
| `{{csrf_meta}}`    | CSRF meta tags                                             |
| `{{brand_name}}`   | Your domain's brand name                                   |
| `{{brand_logo}}`   | Domain logo URL from Admin → Settings (fallback `/logokl.svg`) |
| `{{brand_apple_touch_icon}}` | 180×180 apple-touch (or `/icon.png`)               |
| `{{page_title}}`   | Current page title                                         |
| `{{current_year}}` | Current year                                               |

## Role-based UI

The shell uses `<body data-role="{{user_role}}">` plus CSS to gate the admin chrome:

- `body[data-role="user"] .admin-only { display: none }` — hides nav and content
- `body[data-role="user"] .user-empty { display: flex }` — shows the lockout card

No JavaScript, no Rails changes. Authorization is still enforced by BV Geert; this is purely cosmetic.

## Auto-sync on push

The repo ships with `.github/workflows/sync.yml` which pings BV Geert on every push to `main`.

One-time setup in **Settings → Secrets → Actions**:

- `WEBHOOK_SECRET` — the secret BV Geert gave you
- `WEBHOOK_URLS` — one URL per line, e.g.:
  ```
  https://staging.nm.nu/webhooks/github/assets
  https://nm.nu/webhooks/github/assets
  ```

Without this, you can still trigger a sync manually via *Sync now* in `/admin/instellingen`.

## Customizing for your domain

The defaults are intentionally generic. Tweak:

- **Colors**: edit `--accent` and `--accent-2` in both CSS files.
- **Demo slugs**: edit the `.demo-card` rows in `index.html` to match your actual top links.
- **Copy**: rewrite the hero and feature sections — make it feel like your team.
- **Logo**: upload under **Admin → Settings → Logo** (requires bvgeert with `{{brand_logo}}` placeholders deployed). Until then the shell falls back to `/images/logo.png` (synced from this repo; served via BcAssetServer under `/images/*`, not `/icons/*`).

## Docs

- [Custom landing pages & app shell](https://github.com/appfabriek/bvgeert/blob/main/docs/features/custom-landing-pages.md)
- [BC asset sync](https://github.com/appfabriek/bvgeert/blob/main/docs/bc-asset-sync.md)
