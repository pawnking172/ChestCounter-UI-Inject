**English** — ChestCounter build 1.5.47. **Check for updates** follows this repository, so this build arrives through the button.

**What's new in 1.5.47**
- More reliable update check: it always falls back to this repository's own API, even if `CHESTCOUNTER_UPDATE_API` is old, points to an HTML page or returns a releases list; each request has a changing address so GitHub's CDN cannot keep serving the previous "latest" right after a release.
- When there is nothing new, the message now shows both your installed version and the newest release GitHub reports, so "you already have the latest" can be checked at a glance.
- Settings → Updates shows the installed version and a **Download the latest build** button (opens the releases page) for manual updates.
- Counts, replay analysis, report totals, prize table, map, overlay and the Events tab are unchanged.

---

**Français** — Build 1.5.47. La vérification des mises à jour retombe toujours sur l'API de ce dépôt, même si `CHESTCOUNTER_UPDATE_API` est ancien ou renvoie une liste ; le message affiche votre version et la dernière version annoncée par GitHub. Paramètres → Mises à jour montre la version installée et un bouton **Télécharger la dernière version**. Les comptages ne changent pas.

---

**Español** — Build 1.5.47. La comprobación de actualizaciones siempre vuelve a la API de este repositorio, aunque `CHESTCOUNTER_UPDATE_API` esté desactualizado o devuelva una lista; el mensaje muestra tu versión y la última que anuncia GitHub. Ajustes → Actualizaciones muestra la versión instalada y un botón **Descargar la última versión**. Los conteos no cambian.
