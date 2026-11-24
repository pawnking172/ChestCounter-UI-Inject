**English** â€” ChestCounter UI addon build 1.5.55. This build is about using less memory.

**What's new in 1.5.55**
- **Web engine without GPU:** the local page is rendered in software, so Edge's GPU process no longer keeps tens of MB reserved. The page, charts and scrolling work the same.
- **Idle trim:** after 90 s without touching the window, WebView2 switches to its low-memory mode and unused pages are handed back to Windows. Clicking the window restores full speed.
- **Minimized for 30 s:** the web engine is closed completely (its extra processes end) and restarted on the same page when you open the window again. Short minimizes keep it warm.
- **Lighter page:** images load lazily; the hidden GUI page no longer polls for state. **"All treasure prizes"** still shows manually ticked prizes as **âœ“ Got it**.
- Counts, prizes, chances, map, overlay style and events are unchanged.

---

**Franأ§ais** â€” Build 1.5.55 : moins de mأ©moire utilisأ©e.

**Ce qui change en 1.5.55**
- **Moteur web sans GPU :** la page locale est dessinأ©e en logiciel, sans processus GPU d'Edge qui garde des dizaines de Mo rأ©servأ©s. L'affichage reste identique.
- **Aprأ¨s 90 s sans toucher la fenأھtre :** WebView2 passe en mode basse mأ©moire et les pages inutilisأ©es sont rendues أ  Windows. Un clic rأ©tablit la vitesse normale.
- **Fenأھtre minimisأ©e 30 s :** le moteur web est fermأ© (ses processus supplأ©mentaires disparaissent) et relancأ© sur la mأھme page أ  la rأ©ouverture.
- Les images chargent أ  la demande ; la page cachأ©e n'interroge plus l'أ©tat. Les prix cochأ©s أ  la main restent marquأ©s. Les comptages ne changent pas.

---

**Espaأ±ol** â€” Build 1.5.55: menos memoria.

**Novedades en 1.5.55**
- **Motor web sin GPU:** la pأ،gina local se dibuja por software, sin el proceso GPU de Edge reservando decenas de MB. La pأ،gina funciona igual.
- **Tras 90 s sin tocar la ventana:** WebView2 pasa a modo de bajo consumo de memoria y se devuelven las pأ،ginas sin uso. Al hacer clic vuelve a la velocidad normal.
- **Minimizada 30 s:** el motor web se cierra (terminan sus procesos extra) y se reinicia en la misma pأ،gina al abrirla de nuevo.
- Las imأ،genes cargan cuando hace falta; la pأ،gina oculta ya no consulta el estado. Los premios marcados a mano siguen marcados. Los conteos no cambian.