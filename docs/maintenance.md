# Portfolio maintenance

## Canonical routes

The home page is `/`, the biography is `/about/`, and each project lives under `/projects/<slug>/`. The mixed-case project folders at the repository root are redirect-only compatibility routes for the old GitHub Pages URLs.

Each canonical page keeps its project-specific layout CSS beside the page and loads `assets/site.css` after it. The shared file owns the baseline palette, focus treatment, responsive media behavior, reduced-motion behavior, print rules, and common card/button treatment. `assets/site.js` owns the shared menu/dropdown behavior and safe defaults for media loading.

## Updating a project

1. Edit the canonical page in `projects/<slug>/index.html`.
2. Keep media beside the page or in a clearly named subfolder.
3. Put runnable source and supporting documents in that same project folder.
4. Do not commit `.cache/`, `__pycache__/`, `slprj/`, `.slxc`, or local data exports.
5. Run `python scripts/check-site.py` and preview with `python -m http.server 8765`.
6. Commit the site repo independently from any legacy project-repo changes.

## Decommissioning the legacy repositories

The consolidated site is the source of truth. After confirming the new canonical routes in production:

- change each old repository's Pages setting to the consolidated repository or add a redirect-only `index.html`;
- archive the old repositories after their redirect has been verified;
- keep the old repository history available for provenance, but stop publishing from it;
- update any external resume, LinkedIn, or project links to `https://www.jack-huston.com/projects/<slug>/`.

The redirect folders in this repository protect the old custom-domain paths. They do not change GitHub's separate project-site settings, which must be retired in the GitHub repository settings.
