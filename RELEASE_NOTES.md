**English** — ChestCounter UI addon build 1.5.66. Fixes the memory that stayed after the web engine stopped.

**What's new in 1.5.66**
- **Memory actually handed back:** when the page is suspended or the window is minimized for 30 s, the engine's processes end *and* the pages still held by the counter are returned to Windows right away. Previously the Task Manager number stayed high even with no web engine running.
- **Idle trim even with no page:** after 90 s without touching the window, the counter trims itself every minute whether or not WebView2 is loaded. Clicking restores full speed.
- **New background:** the picture you chose is now behind the window, with a lighter veil so it actually shows while the text stays readable.
- **Update popup:** the automatic check still runs every 5 minutes, but it no longer installs in silence. A popup says a new version is available with **Update**, **Download manually** and **Later** buttons; nothing is downloaded until you press Update. If the install fails (blocked download, no write access, antivirus), the exact reason is now shown in the window instead of being printed to an invisible console.
- **Renamed exe updates too:** the updater no longer refuses to install when the file is named ChestCounter (1).exe or anything else ending in .exe; it replaces the exe that is actually running.
- **Unnamed treasures no longer silent:** when Fortnite grants a car, jam track or loading screen without sending its name in the replay, the collection opens by itself and tells you to tick what you received. Your ticks are saved in data.json.
- **Session counts the squad:** the Session line (overlay and window) now adds your teammates' chests, not just yours. It still means "since this tool was started", not since Fortnite opened.
- **Skin cups in Events:** official cups with an outfit reward (Scott Pilgrim Cup) now show as an event card, a notice and a desktop alert before they start.
- **Closing really closes:** the addon watcher used to stay as a hidden PowerShell process forever. It now exits with the counter, and ChestCounter starts a fresh one on the next launch. No process is left behind (the optional "start with Fortnite" standby still follows its own setting).
- **Watcher trimmed too:** the addon watcher no longer sits at ~150 MB; it compacts and trims every 30 s (PowerShell 5.1 needed a compatible GC call).
- No GPU rendering, lazy images, hidden-page polling off. **"All treasure prizes"** still shows manually ticked prizes as **✓ Got it**. Counts, chances, map and overlay are unchanged.

---

**Français** — Build 1.5.66 : la mémoire rendue quand le moteur web s'arrête.

**Ce qui change en 1.5.66**
- **Mémoire réellement libérée :** quand la page est suspendue ou la fenêtre minimisée 30 s, les processus du moteur s'arrêtent *et* les pages gardées par le compteur sont rendues à Windows immédiatement. Auparavant le chiffre restait élevé même sans moteur web.
- **Après 90 s sans toucher la fenêtre :** le compteur se taille chaque minute, même sans WebView2. Un clic rétablit la vitesse.
- **Nouveau fond :** l'image que tu as choisie est maintenant derrière la fenêtre, avec un voile plus léger pour qu'elle se voie vraiment sans gêner la lecture.
- **Fenêtre de mise à jour :** la vérification automatique reste active toutes les 5 minutes, mais n'installe plus en silence. Une fenêtre annonce la nouvelle version avec **Mettre à jour**, **Télécharger à la main** et **Plus tard** ; rien n'est téléchargé avant ton clic. Si l'installation échoue (téléchargement bloqué, droit d'écriture, antivirus), la raison exacte s'affiche dans la fenêtre au lieu d'un console invisible.
- **Mise à jour même avec un exe renommé :** le programme n'exige plus que le fichier s'appelle exactement ChestCounter.exe ; il remplace l'exe réellement ouvert, même ChestCounter (1).exe.
- **Trésors sans nom plus silencieux :** quand Fortnite donne une voiture, un morceau ou un loading sans envoyer son nom dans le replay, la collection s'ouvre toute seule et te dit quoi cocher. Tes coches sont gardés dans data.json.
- **La session compte l'équipe :** la ligne Session (overlay et fenêtre) ajoute maintenant les coffres de tes coéquipiers, pas seulement les tiens. Ça veut toujours dire « depuis le lancement du compteur », pas depuis l'ouverture de Fortnite.
- **Cups à skins dans Événements :** les tournois officiels qui donnent une tenue (Scott Pilgrim Cup) apparaissent dans les événements, avec un avis et une alerte avant le début.
- **Fermer, c'est fermer :** le script d'extension restait ouvert en PowerShell caché ; il quitte maintenant avec le compteur, qui en relance un nouveau à la prochaine ouverture. Aucun processus ne reste (l'option « ouvrir avec Fortnite » garde son propre réglage).
- **Le surveilleur aussi :** le script d'extension ne reste plus à ~150 Mo ; il se compacte et se taille toutes les 30 s.
- Pas de GPU, images à la demande, page cachée sans interrogation. Les prix cochés restent marqués. Les comptages ne changent pas.

---

**Español** — Build 1.5.66: la memoria se devuelve cuando el motor web se detiene.

**Novedades en 1.5.66**
- **Memoria realmente liberada:** al suspender la página o minimizar 30 s, terminan los procesos del motor *y* las páginas retenidas por el contador se devuelven a Windows al instante. Antes el número seguía alto aunque no hubiera motor.
- **Tras 90 s sin tocar la ventana:** el contador se recorta cada minuto, aunque WebView2 no esté cargado. Al hacer clic vuelve a la velocidad normal.
- **Nuevo fondo:** la imagen que elegiste está ahora detrás de la ventana, con un velo más ligero para que se vea sin dificultar la lectura.
- **Ventana de actualización:** la comprobación automática sigue cada 5 minutos, pero ya no instala en silencio. Una ventana anuncia la versión nueva con **Actualizar**, **Descargar a mano** y **Después**; no se descarga nada hasta que pulses el botón. Si la instalación falla (descarga bloqueada, permisos, antivirus), el motivo exacto aparece en la ventana en vez de una consola invisible.
- **Actualiza aunque cambies el nombre:** ya no exige que el archivo se llame exactamente ChestCounter.exe; reemplaza el exe que está abierto, aunque sea ChestCounter (1).exe.
- **Tesoros sin nombre ya no pasan desapercibidos:** cuando Fortnite entrega un coche, pista o pantalla de carga sin enviar su nombre en la repetición, la colección se abre sola y te dice qué marcar. Tus marcas se guardan en data.json.
- **La sesión cuenta al equipo:** la línea Session (overlay y ventana) suma ahora los cofres de tus compañeros, no solo los tuyos. Sigue significando "desde que se abrió el contador", no desde que abriste Fortnite.
- **Cups de trajes en Eventos:** los torneos oficiales que dan un traje (Scott Pilgrim Cup) aparecen como evento, aviso y alerta antes de empezar.
- **Cerrar es cerrar:** el script del addon se quedaba como PowerShell oculto; ahora sale con el contador, que inicia uno nuevo al abrirse de nuevo. No queda ningún proceso (la opción "abrir con Fortnite" sigue su propio ajuste).
- **El vigilante también:** el script del addon ya no se queda en ~150 MB; se compacta y recorta cada 30 s.
- Sin GPU, imágenes bajo demanda, página oculta sin sondeos. Los premios marcados siguen marcados. Los conteos no cambian.