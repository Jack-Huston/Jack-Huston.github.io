(() => {
  "use strict";

  const qs = (selector, root = document) => root.querySelector(selector);
  const qsa = (selector, root = document) => [...root.querySelectorAll(selector)];

  const mobileMenu = qs("#mobileMenu") || qs(".mobileMenu");
  const mobileButton = qs("#mobileMenuBtn") || qs(".menuBtn") || qs(".mobile-menu-btn");
  const navLinks = qs("#navLinks") || qs(".navLinks") || qs(".nav-links");

  const setMobileMenu = (open) => {
    if (!mobileMenu) return;
    mobileMenu.classList.toggle("active", open);
    mobileMenu.classList.toggle("open", open);
    mobileMenu.hidden = !open;
    if (mobileButton) mobileButton.setAttribute("aria-expanded", String(open));
  };

  if (mobileMenu && !mobileMenu.hasAttribute("hidden")) mobileMenu.hidden = true;
  mobileButton?.addEventListener("click", () => setMobileMenu(mobileMenu.hidden));
  qsa(".mobile-menu a, .mobileMenu a").forEach((link) => link.addEventListener("click", () => setMobileMenu(false)));

  qsa(".dropdown-toggle-btn, .mobile-toggle-btn").forEach((toggle) => {
    const targetId = toggle.getAttribute("aria-controls");
    const target = targetId ? document.getElementById(targetId) : toggle.nextElementSibling;
    if (!target) return;
    toggle.addEventListener("click", (event) => {
      event.stopPropagation();
      const open = toggle.getAttribute("aria-expanded") !== "true";
      toggle.setAttribute("aria-expanded", String(open));
      target.classList.toggle("show", open);
      target.classList.toggle("open", open);
    });
  });

  document.addEventListener("click", (event) => {
    if (!(event.target instanceof Element)) return;
    if (event.target.closest(".nav-dropdown, .mobile-dropdown")) return;
    qsa(".dropdown-toggle-btn, .mobile-toggle-btn").forEach((toggle) => toggle.setAttribute("aria-expanded", "false"));
    qsa(".dropdown-content, .mobile-dropdown-content").forEach((menu) => menu.classList.remove("show", "open"));
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") {
      setMobileMenu(false);
      qsa(".dropdown-toggle-btn, .mobile-toggle-btn").forEach((toggle) => toggle.setAttribute("aria-expanded", "false"));
      qsa(".dropdown-content, .mobile-dropdown-content").forEach((menu) => menu.classList.remove("show", "open"));
    }
  });

  // Give pages that predate the shared shell a reliable keyboard target.
  if (!document.querySelector("main")) {
    const primary = qs(".project-hero, .hero, section");
    if (primary && !primary.id) primary.id = "main-content";
  } else {
    const main = qs("main");
    if (main && !main.id) main.id = "main-content";
  }

  qsa("img:not([loading])").forEach((image) => {
    image.loading = "lazy";
    image.decoding = "async";
  });
  qsa("video").forEach((video) => {
    video.controls = true;
    if (!video.hasAttribute("preload")) video.preload = "none";
  });

  if (window.lucide?.createIcons) window.lucide.createIcons();
})();
