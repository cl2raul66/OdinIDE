# Contributing to OdinIDE

---

## Tabla de Contenidos

1. [Bienvenida](#bienvenida)
2. [Requisitos del Entorno](#requisitos-del-entorno)
3. [Configuración del Proyecto](#configuración-del-proyecto)
4. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
5. [Convenciones de Código](#convenciones-de-código)
6. [Flujo de Trabajo](#flujo-de-trabajo)
7. [Testing](#testing)
8. [CI/CD](#cicd)
9. [Áreas para Contribuir](#áreas-para-contribuir)
10. [Recursos y Enlaces](#recursos-y-enlaces)

---

## Bienvenida

¡Gracias por tu interés en contribuir a OdinIDE! Este documento te guiará a través de todo lo que necesitas saber para comenzar.

**¿Por qué contribuir?**
- Aprender sobre construcción de IDEs y análisis de código
- Explorar las capacidades del lenguaje Odin para aplicaciones de escritorio
- Forma parte del ecosistema de tooling de Odin
- Contribuir a un proyecto con impacto real en la comunidad

---

## Requisitos del Entorno

### Software Necesario

| Requisito | Versión | Descripción |
|-----------|---------|-------------|
| **Odin Compiler** | Estable  | Compilador principal del proyecto |
| **Raylib** | ~5.0+ | Framework gráfico (incluido como vendor) |
| **Git** | Cualquier versión reciente | Control de versiones |
| **GitHub CLI** | Cualquier versión reciente | Control de versiones |

### Sistemas Operativos Soportados

- **Windows**

---

## Configuración del Proyecto

### 1. Clonar el Repositorio

```bash
git clone https://github.com/<tu-fork>/OdinIDE.git
cd OdinIDE
```

### 2. Estructura de Directorios

```
OdinIDE/
├── bin/                      # Ejecutables compilados (ignorado en git)
├── rsc/                      # Recursos estáticos
│   ├── demo.odin             # Archivo de prueba de ejemplo
│   └── SourceCodePro/        # Fuentes TTF monoespaciadas
├── src/                      # Código fuente principal
│   ├── main.odin             # Punto de entrada (package main)
│   ├── text_engine/          # BACKEND: Gestión de texto
│   │   ├── gap_buffer.odin   # Estructura Gap Buffer
│   │   ├── line_table.odin   # Mapeo líneas ↔ offsets
│   │   └── editor.odin      # Lógica de alto nivel del editor
│   ├── gui/                  # FRONTEND: Renderizado y entrada
│   │   ├── core.odin         # Tipos base y estado global UI
│   │   ├── window.odin       # Inicialización de Raylib
│   │   └── renderer.odin     # Renderizado de texto y cursor
│   └── semantic/            # CEREBRO: Análisis de código
│       └── tokenizer.odin   # (pendiente) Integración con lexer
├── .vscode/                  # Configuración de VS Code
│   └── tasks.json           # Tareas de build
├── .gitignore
├── README.md
└── CONTRIBUTING.md
```

### 3. Dependencias

El proyecto usa **vendor packages** para dependencias externas:

```odin
import "vendor:raylib"  // Gráficos 2D
```

Raylib ya está incluido como vendor dependency. No necesitas instalarlo manualmente.

### 4. Comandos de Build

#### Desde Terminal

```bash
# Desarrollo (debug, más lento pero con información)
odin run src -out:bin/OdinIDE.exe -debug -show-debug-messages

# Verificación de tipos y sintaxis
odin check src

# Producción (optimizado para velocidad)
odin build src -out:bin/OdinIDE.exe -o:speed

# Producción (optimizado para tamaño)
odin build src -out:bin/OdinIDE.exe -o:size
```

#### Flags de Compilación

| Flag | Propósito |
|------|-----------|
| `-debug` | Info de debugging, sin optimizar |
| `-show-debug-messages` | Muestra mensajes internos del compilador |
| `-o:speed` | Optimización para velocidad |
| `-o:size` | Optimización para tamaño |
| `-o:aggressive` | Máxima optimización (compilación lenta) |
| `-out:<path>` | Ruta de salida del ejecutable |

#### Desde VS Code

El proyecto incluye configuración predefinida en `.vscode/tasks.json`:

- **Odin: Run** — Compila y ejecuta con debug
- **Odin: Check** — Verificación de tipos sin ejecutar

Presiona `Ctrl+Shift+B` para ver las tareas disponibles.

### 5. Configuración del Editor

#### VS Code (Recomendado)

1. Instala la extensión oficial: `odin-lang.vscode-odin`
2. La configuración de tareas ya está lista en `.vscode/tasks.json`

---

## Arquitectura del Proyecto

### Visión General

OdinIDE sigue una arquitectura **MVC simplificada** con tres capas principales:

```
┌─────────────────────────────────────────────────────────────┐
│                         main.odin                            │
│                    (Orquestador Principal)                   │
│   - Inicialización                                          │
│   - Game Loop (Input → Process → Render)                     │
│   - Gestión de memoria (Tracking Allocator)                 │
└──────────────────────────┬──────────────────────────────────┘
                           │
         ┌─────────────────┴─────────────────┐
         ▼                                   ▼
┌─────────────────────┐           ┌─────────────────────┐
│    text_engine/     │           │        gui/         │
│      (BACKEND)     │           │    (FRONTEND)       │
├─────────────────────┤           ├─────────────────────┤
│ • Gap Buffer        │           │ • Raylib Window     │
│ • Line Table        │           │ • Renderer          │
│ • Editor Logic      │           │ • Input Handling    │
└─────────────────────┘           └─────────────────────┘
```

### Flujo de Datos

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Keyboard   │────▶│  gui/input   │────▶│ text_engine  │
│   Input      │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
                                               │
                                               ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   Screen     │◀────│  gui/draw    │◀────│ ed_get_text  │
│   Output     │     │              │     │              │
└──────────────┘     └──────────────┘     └──────────────┘
```

### Módulos Principales

#### `text_engine` (Backend)

| Archivo | Responsabilidad |
|---------|-----------------|
| `gap_buffer.odin` | Estructura de datos para edición eficiente de texto |
| `line_table.odin` | Mapeo de números de línea a offsets (para click del ratón) |
| `editor.odin` | Abstracción de alto nivel: crear, insertar, mover cursor |

**Estructuras clave:**

```odin
Gap_Buffer :: struct {
    data: [dynamic]u8,
    gap_start, gap_end: int,
}

Editor :: struct {
    buffer: Gap_Buffer,
}

Line_Info :: struct {
    line_number, start_offset, end_offset: int,
}
```

#### `gui` (Frontend)

| Archivo | Responsabilidad |
|---------|-----------------|
| `core.odin` | Tipos base (ID, Rect, UI_State) y estado global |
| `window.odin` | Inicialización/cierre de ventana (vacío aún) |
| `renderer.odin` | Wrappers de Raylib: drawing, input, medición de texto |

**Tipos clave:**

```odin
ID :: u32

Rect :: struct {
    x, y, w, h: i32
}

UI_State :: struct {
    hot_item, active_item: ID,
    mouse_x, mouse_y: i32,
    mouse_down, mouse_pressed: bool,
    current_panel: Rect,
    cursor_x, cursor_y: i32,
}
```

#### `semantic` (Análisis)

| Archivo | Responsabilidad |
|---------|-----------------|
| `tokenizer.odin` | Análisis léxico (pendiente de implementar) |

---

## Convenciones de Código

### Convenciones de Nomenclatura

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Packages | `snake_case` | `text_engine`, `gui` |
| Structs | `PascalCase` | `Gap_Buffer`, `Editor`, `UI_State` |
| Procedures | `snake_case` con prefijo del módulo | `gb_insert()`, `ed_create_editor()` |
| Variables | `snake_case` | `gap_start`, `cursor_index` |
| Types | `PascalCase` | `ID`, `Rect`, `Line_Info` |
| Constants | `SCREAMING_SNAKE_CASE` | `TABLE_SIZE_MIN` |

### Prefijos de Procedimientos por Módulo

```
gap_buffer:  gb_*  (gb_init, gb_insert, gb_move_left, gb_move_right, etc.)
editor:      ed_*  (ed_create_editor, ed_insert_rune, ed_backspace, ed_get_visible_text, etc.)
gui:         gui_* (gui_init_window, gui_draw_text, gui_draw_cursor, gui_should_close, etc.)
```

### Estructura de un Archivo Odin

```odin
package <nombre_paquete>

import "core:fmt"
import "core:mem"
import "vendor:raylib"

// Types al inicio
My_Type :: struct {
    field: int,
}

// Procedures después
my_procedure :: proc(ptr: ^My_Type) {
    // implementación
}
```

### Directivas de Compilación

Usa `#+vet` para controlar advertencias:

```odin
#+vet !using-stmt !using-param
#+feature dynamic-literals using-stmt
```

### Gestión de Memoria

El proyecto usa **Tracking Allocator** para detectar memory leaks:

```odin
track: mem.Tracking_Allocator
mem.tracking_allocator_init(&track, context.allocator)
defer {
    if len(track.allocation_map) > 0 {
        mem.dump_unallocated_data(track)
    }
    mem.tracking_allocator_destroy(&track)
}
```

**Reglas:**
- Usa `context.temp_allocator` para allocations temporales
- Libera recursos con `defer` para garantizar limpieza
- Verifica que no haya memory leaks antes de enviar PRs

---

## Flujo de Trabajo

### 1. Ramas (Branches)

```
main                    # Rama principal (estable)
├── develop             # Rama de desarrollo (si existe)
├── feature/xxx         # Nuevas funcionalidades
├── fix/xxx             # Corrección de bugs
├── refactor/xxx        # Refactorización
└── docs/xxx            # Documentación
```

**Nombramiento de ramas:**
- `feature/gap-buffer-optimization`
- `fix/crash-on-backspace`
- `docs/contributing-guide`

### 2. Commits

**Formato:**
```
<tipo>(<alcance>): <descripción>

[cuerpo opcional]

[notas de pie opcionales]
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formateo (sin cambio de lógica)
- `refactor`: Refactorización
- `test`: Agregar tests
- `chore`: Tareas de mantenimiento

**Ejemplos:**
```
feat(text_engine): agregar soporte para múltiples cursores
fix(gui): corregir parpadeo del cursor en Windows
docs(readme): actualizar instrucciones de instalación
test(gap_buffer): agregar tests para gb_move_left
```

### 3. Pull Requests

**Antes de crear un PR:**

1. Sincroniza con la rama base
2. Ejecuta `odin check src` sin errores
3. Verifica que no haya memory leaks
4. Actualiza documentación si es necesario
5. Agrega tests para nuevas funcionalidades

**Template de PR (por implementar):**

```markdown
## Descripción
[Breve descripción del cambio]

## Tipo de Cambio
- [ ] Nueva funcionalidad
- [ ] Corrección de bug
- [ ] Cambio rompe-compatibilidad
- [ ] Documentación

## Testing
[Describe las pruebas realizadas]

## Checklist
- [ ] El código sigue las convenciones
- [ ] `odin check src` pasa sin errores
- [ ] No hay memory leaks
- [ ] Documentación actualizada
```

### 4. Code Review

**Criterios de revisión:**
- ¿El código sigue las convenciones del proyecto?
- ¿Hay tests para la nueva funcionalidad?
- ¿La lógica es clara y eficiente?
- ¿Se manejan correctamente los casos edge?
- ¿La documentación está actualizada?

---

## Testing

### Estado Actual

El proyecto se encuentra en **fase temprana de desarrollo**. Actualmente no existe un framework de testing formal.

### Validación Manual

```bash
# Verificación de tipos
odin check src

# Compilación
odin build src -out:bin/OdinIDE.exe

# Con debug
odin run src -out:bin/OdinIDE.exe -debug -show-debug-messages
```

### Verificación de Memoria

El proyecto incluye tracking de memoria automático:

```odin
// En main.odin, se imprime al cerrar si hay leaks
if len(track.allocation_map) > 0 {
    mem.dump_unallocated_data(track)
}
```

### Estructura Sugerida para Tests

```
tests/
├── text_engine/
│   ├── gap_buffer_test.odin
│   ├── line_table_test.odin
│   └── editor_test.odin
├── gui/
│   └── renderer_test.odin
└── integration/
    └── full_editor_test.odin
```

### Framework de Testing Recomendado

Usa `assert()` de Odin para pruebas unitarias:

```odin
package text_engine_test

import "core:testing"
import "core:fmt"
import "../src/text_engine"

@(test)
test_gap_buffer_insert :: proc(t: ^testing.T) {
    gb: text_engine.Gap_Buffer
    text_engine.gb_init(&gb, 100)
    defer text_engine.gb_destroy(&gb)

    text_engine.gb_insert(&gb, "hello")

    // Verificar inserción
    if gb.gap_start != 5 {
        testing.error(t, "Expected gap_start to be 5")
    }
}
```

---

## CI/CD

### Estado Actual

No hay pipelines de CI/CD configurados actualmente.

### Configuración Sugerida (por implementar)

Se recomienda crear `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v4

    - name: Setup Odin
      run: |
        # Descargar e instalar Odin compiler
        # (pendiente de documentar pasos específicos)

    - name: Odin Check
      run: odin check src

    - name: Odin Build
      run: odin build src -out:bin/OdinIDE.exe -debug

    - name: Verify Binary
      run: |
        if (Test-Path bin/OdinIDE.exe) {
            Write-Host "Build successful"
        } else {
            Write-Host "Build failed"
            exit 1
        }
```

### Linting

Odin incluye `odin vet` para análisis estático:

```bash
odin check src -vet
```

---

## Áreas para Contribuir

### Funcionalidades Pendientes

| Prioridad | Funcionalidad | Descripción | Complejidad |
|-----------|----------------|-------------|-------------|
| 🔴 Alta | **Line_Table** | Completar mapeo de líneas para soporte multi-línea | Media |
| 🔴 Alta | **Tokenizer** | Integrar `core:odin/tokenizer` para análisis léxico | Alta |
| 🔴 Alta | **Scroll** | Implementar scroll vertical/horizontal | Media |
| 🟡 Media | **Fuentes TTF** | Cargar fuentes monoespaciadas desde `rsc/` | Baja |
| 🟡 Media | **Selección** | Implementar selección de texto (Shift+ flechas) | Media |
| 🟡 Media | **I/O** | Carga y guardado de archivos | Media |
| 🟢 Baja | **Sintaxis** | Resaltado de sintaxis básico | Alta |
| 🟢 Baja | **Pestañas** | Múltiples buffers/pestañas | Media |
| 🟢 Baja | **UI** | Barras de herramientas y menús | Media |

### Guía por Área

#### Gap Buffer (`src/text_engine/gap_buffer.odin`)

- Mantener compatibilidad con API existente
- Optimizar operaciones de inserción/borrado
- Agregar tests unitarios

#### Line Table (`src/text_engine/line_table.odin`)

- Completar mapeo líneas ↔ offsets
- Implementar búsqueda eficiente
- Soportar edición con re-cálculo de líneas

#### Editor (`src/text_engine/editor.odin`)

- Extender API pública
- Manejar multi-línea
- Agregar comandos de edición (copy, cut, paste)

#### GUI (`src/gui/`)

- Completar `window.odin` para inicialización avanzada
- Mejorar `renderer.odin` para scroll
- Agregar widgets UI básicos

#### Semantic (`src/semantic/`)

- Integrar `core:odin/tokenizer`
- Implementar tokenización de código Odin
- Preparar infraestructura para highlighting

---

## Recursos y Enlaces

### Documentación del Proyecto

- [README.md](README.md) — Estructura del proyecto
- [CONTRIBUTING.md](CONTRIBUTING.md) — Esta guía

### Documentación Externa

| Recurso | URL |
|---------|-----|
| Documentación de Odin | https://odin-lang.org/docs/ |
| Repo de Odin | https://github.com/odin-lang/Odin |
| Documentación de Raylib | https://raylib.com/ |
| Tutorial de Gap Buffer | https://en.wikipedia.org/wiki/Gap_buffer |

### Comunidad

- **Foro de Odin**: https://odin-lang.org/discord
- **GitHub Issues**: Reportar bugs y solicitar features

---

## Glosario

| Término | Definición |
|---------|-----------|
| **Gap Buffer** | Estructura de datos para edición de texto que mantiene un "hueco" en la posición del cursor, optimizando inserciones |
| **Tokenización** | Proceso de convertir texto fuente en una secuencia de tokens (palabras clave, identificadores, símbolos) |
| **Tracking Allocator** | Asignador de memoria que registra todas las asignaciones para detectar fugas |
| **Vendor Package** | Dependencia externa incluida en el proyecto (carpeta `vendor/`) |
| **core:xxx** | Paquetes de la biblioteca estándar de Odin |

---

## Licencia

Al contribuir a este proyecto, aceptas que tus contribuciones serán licenciadas bajo la misma licencia del proyecto.

---

*Última actualización: 2026-04-11*
*Versión del documento: 1.0.0*
