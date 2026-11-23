**English** — ChestCounter build 1.5.48. From now on the program reads one canonical file in the repository, so every new release reaches everyone who clicks **Check for updates**.

**What's new in 1.5.48**
- **One source of truth:** `latest.json` in the repository names the newest build, its direct download URL, size, SHA-256 and release notes. `Check for updates` reads it first; GitHub's API is only a fallback. Every release rewrites that file automatically (publish script + GitHub Actions), so a version published anywhere is picked up right away.
- **Automatic delivery:** while the counter is open it re-checks every 5 minutes; with the new default **Installed automatically** it downloads and starts the new build without a click. Existing settings are respected.
- The up-to-date message shows both your installed version and the newest one the repository reports.
- Counts, replay analysis, report totals, prize table, map, overlay and the Events tab are unchanged.

---

**Français** — Build 1.5.48. Le programme lit maintenant `latest.json` du dépôt : chaque nouvelle version est annoncée immédiatement à **Vérifier les mises à jour**. Vérification toutes les 5 minutes, installation automatique par défaut. Les comptages ne changent pas.

---

**Español** — Build 1.5.48. El programa lee ahora `latest.json` del repositorio: cada versión nueva llega enseguida a **Buscar actualizaciones**. Comprobación cada 5 minutos e instalación automática por defecto. Los conteos no cambian.
