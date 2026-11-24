# Cat-ch the Ball

Juego 2D para **Godot 4.7** (GL Compatibility). Un gatito salta de un lado al
otro golpeando la pelota con la cabeza para mantenerla en el aire. Cada punto
acelera la pelota y al gato. Si la pelota toca el suelo, pierdes una vida;
tienes 3.

El récord de puntos se guarda entre sesiones y el juego incluye música y
efectos de sonido.

## Cómo ejecutar

1. Abre Godot 4.7.
2. Importa `project.godot` de esta carpeta.
3. Pulsa **F5** (la escena principal es `scenes/MainMenu.tscn`).

## Controles

| Acción | Tecla |
|---|---|
| Saltar al lado opuesto / reiniciar tras perder | **Shift** |
| Volver al menú / cerrar instrucciones | **Escape** |

## Récord

- Se muestra en el menú, arriba a la derecha durante la partida y en la
  pantalla de fin de partida.
- Se actualiza sólo si superas el récord anterior (aparece **¡Nuevo récord!**
  en el game over).
- Se guarda en `user://record.cfg`, que en Windows es
  `%APPDATA%\Godot\app_userdata\Cat-ch the ball\record.cfg`.

## Audio

- Música de fondo separada para el menú y para la partida.
- Efectos: clic de botones del menú, salto del gato, rebote de la pelota y
  game over.
- Los sonidos actuales son **placeholders generados** con Python (WAV mono
  44.1 kHz / 16 bits). Puedes sustituirlos por audios reales conservando los
  nombres en `assets/audio/`.
- Para regenerarlos:

  ```bash
  python tools/generate_audio.py
  ```

## Estructura

```
scenes/
  MainMenu.tscn      Menú principal e instrucciones
  Main.tscn          Escena de juego (fondo, gato, pelota, suelo, HUD)
scripts/
  GameState.gd       Autoload: carga/guarda el récord persistente
  AudioManager.gd    Autoload: pool de SFX y música con cambio de pista
  MainMenu.gd        Botones, panel de instrucciones y música del menú
  Main.gd            Puntuación, récord, velocidad progresiva y game over
  cat.gd             Salto, animaciones y detección de golpes
  ball.gd            Caída, rebote y fin de partida
  HitArea.gd         Puente entre las Area2D y el script del gato
assets/
  audio/                    WAV generados (SFX y música)
  gato_spriteframes.tres    Animaciones del gato (idle/jump/fall/headbutt)
  pelota_spriteframes.tres  Animación de giro de la pelota
  ...
tools/
  generate_audio.py  Generador determinista de los WAV placeholder
```

## Mecánicas

- El gato empieza a la izquierda y, al pulsar **Shift**, salta en arco al lado
  opuesto.
- Al aterrizar se voltea automáticamente, listo para saltar de vuelta. Los
  saltos alternan izquierda/derecha.
- Si la cabeza del gato golpea la pelota, la pelota rebota, ganas 1 punto y
  tanto la pelota como el gato aceleran (la pelota hasta 3× y el gato hasta
  ~1,8×).
- Tienes **3 vidas** (los iconos de vida del HUD). Cada vez que la pelota toca el
  suelo pierdes una vida y la pelota vuelve a caer desde arriba. Cuando se
  agotan las 3, aparece el cartel de game over.
- La velocidad afecta a la gravedad, la fuerza de rebote de la pelota y la
  rapidez de los saltos del gato.
