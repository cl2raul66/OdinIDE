## Estructura del proyecto

```txt
OdinIDE/
├── bin/
│   └── odin_ide.exe          # Tu ejecutable final
├── rsc/
│   ├── demo.odin             # Archivos de prueba
│   └── fonts/                # Aquí irán tus fuentes TTF para Raylib
├── src/                      # (Antes tokens_view) Carpeta principal del código
│   ├── main.odin             # Punto de entrada (package main)
│   │
│   ├── text_engine/          # BACKEND: Paquete para la gestión de texto
│   │   ├── gap_buffer.odin   # La estructura de datos pura
│   │   ├── line_table.odin   # Mapeo de líneas a índices (para el ratón)
│   │   └── editor.odin       # Lógica de alto nivel (insertar, borrar, seleccionar)
│   │
│   ├── ui/                   # FRONTEND: Paquete para gráficos y ventanas
│   │   ├── window.odin       # Inicialización de Raylib
│   │   └── renderer.odin     # Lógica para dibujar el texto y el cursor
│   │
│   └── semantic/             # EL CEREBRO: Paquete para el análisis de código
│       └── tokenizer.odin    # Integración con core:odin/tokenizer
```
