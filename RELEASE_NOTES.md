**English** â€” ChestCounter UI addon build 1.5.56. Fixes the memory that stayed after the web engine stopped.

**What's new in 1.5.56**
- **Memory actually handed back:** when the page is suspended or the window is minimized for 30 s, the engine's processes end *and* the pages still held by the counter are returned to Windows right away. Previously the Task Manager number stayed high even with no web engine running.
- **Idle trim even with no page:** after 90 s without touching the window, the counter trims itself every minute whether or not WebView2 is loaded. Clicking restores full speed.
- **Watcher trimmed too:** the addon watcher no longer sits at ~150 MB; it compacts and trims every 30 s (PowerShell 5.1 needed a compatible GC call).
- No GPU rendering, lazy images, hidden-page polling off. **"All treasure prizes"** still shows manually ticked prizes as **âœ“ Got it**. Counts, chances, map and overlay are unchanged.

---

**Franأ§ais** â€” Build 1.5.56 : la mأ©moire rendue quand le moteur web s'arrأھte.

**Ce qui change en 1.5.56**
- **Mأ©moire rأ©ellement libأ©rأ©e :** quand la page est suspendue ou la fenأھtre minimisأ©e 30 s, les processus du moteur s'arrأھtent *et* les pages gardأ©es par le compteur sont rendues أ  Windows immأ©diatement. Auparavant le chiffre restait أ©levأ© mأھme sans moteur web.
- **Aprأ¨s 90 s sans toucher la fenأھtre :** le compteur se taille chaque minute, mأھme sans WebView2. Un clic rأ©tablit la vitesse.
- **Le surveilleur aussi :** le script d'extension ne reste plus أ  ~150 Mo ; il se compacte et se taille toutes les 30 s.
- Pas de GPU, images أ  la demande, page cachأ©e sans interrogation. Les prix cochأ©s restent marquأ©s. Les comptages ne changent pas.

---

**Espaأ±ol** â€” Build 1.5.56: la memoria se devuelve cuando el motor web se detiene.

**Novedades en 1.5.56**
- **Memoria realmente liberada:** al suspender la pأ،gina o minimizar 30 s, terminan los procesos del motor *y* las pأ،ginas retenidas por el contador se devuelven a Windows al instante. Antes el nأ؛mero seguأ­a alto aunque no hubiera motor.
- **Tras 90 s sin tocar la ventana:** el contador se recorta cada minuto, aunque WebView2 no estأ© cargado. Al hacer clic vuelve a la velocidad normal.
- **El vigilante tambiأ©n:** el script del addon ya no se queda en ~150 MB; se compacta y recorta cada 30 s.
- Sin GPU, imأ،genes bajo demanda, pأ،gina oculta sin sondeos. Los premios marcados siguen marcados. Los conteos no cambian.