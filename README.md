# Jack Huston Portfolio

This repository is the single source for [www.jack-huston.com](https://www.jack-huston.com/).

## Structure

- `index.html` — home page and project index
- `about/` — biography, experience, education, and resume links
- `projects/` — canonical project pages and the media/source needed by each page
- `assets/site.css` and `assets/site.js` — shared visual/accessibility/performance baseline
- `legacy/` — internal migration notes and redirect targets for old routes
- `.github/workflows/pages.yml` — GitHub Pages deployment

Generated MATLAB/Simulink output, Python caches, and large local exports are intentionally excluded. Project demonstrations remain in the project folders, but videos use user controls and deferred loading.

## Local check

With Python installed, run `py scripts/check-site.py`. A simple preview can be started with `py -m http.server 8000` from this directory.

## Deployment

The `main` branch deploys through GitHub Actions to GitHub Pages. The custom domain is kept in `CNAME`.
