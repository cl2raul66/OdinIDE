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
9. [Licencia](#licencia)

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

### Estructura de Directorios

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

### Dependencias

El proyecto usa **vendor packages** para dependencias externas:

```odin
import "vendor:raylib"  // Gráficos 2D
```

Raylib ya está incluido como vendor dependency. No necesitas instalarlo manualmente.

### Comandos de Build

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

### Configuración del Editor

#### VS Code (Recomendado)

1. Instala la extensión oficial: `odin-lang.vscode-odin`
2. La configuración de tareas ya está lista en `.vscode/tasks.json`

---

## Arquitectura del Proyecto

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

#### Backend

| Archivo | Responsabilidad |
|---------|-----------------|
| `gap_buffer.odin` | Estructura de datos para edición eficiente de texto |
| `line_table.odin` | Mapeo de números de línea a offsets (para click del ratón) |
| `editor.odin` | Abstracción de alto nivel: crear, insertar, mover cursor |



#### Frontend

| Archivo | Responsabilidad |
|---------|-----------------|
| `core.odin` | Tipos base (ID, Rect, UI_State) y estado global |
| `window.odin` | Inicialización/cierre de ventana (vacío aún) |
| `renderer.odin` | Wrappers de Raylib: drawing, input, medición de texto |



#### `semantic` (Análisis)

| Archivo | Responsabilidad |
|---------|-----------------|
| `tokenizer.odin` | Análisis léxico (pendiente de implementar) |

---

## Convenciones de Código

### Formato de Código
- En la declaracion de `Structs`, los elementos deben agrupar por mismo tipo. Por ejemplo, todos los `i32` juntos, luego los `f32`, etc. Por ejemplo:

```odin
// Correcto
my_struct :: struct {
    id, age: i32
    size, weight : f32
    name: string
}
// Incorrecto (mezcla de tipos)
my_struct :: struct {
    id: i32
    age: i32
    size: f32
    weight: f32
    name: string
}
```
- No alineas las columnas de partes de la sintaxis, como los tipos en las declaraciones de variables o los campos en un struct. Por ejemplo:

```odin
// Correcto
my_struct :: struct {
    id: i32
    name: string
    value: f32
}
// Incorrecto (alineación de tipos)
my_struct :: struct {
    id:    i32
    name:  string
    value: f32
}
```
-

### Nomenclatura

| Elemento | Convención | Ejemplo |
|----------|------------|---------|
| Ficheros | `snake_case` | `gap_buffer.odin`, `editor.odin`, `renderer.odin` |
| Package | `snake_case` | `text_engine`, `gui` |
| Procedimientos | `snake_case` | `gb_init()`, `ed_create_editor()`, `rd_draw_text()` |
| Structs | `PascalCase` | `Gap_Buffer`, `Editor`, `UI_State` |
| Variables | `snake_case` | `gap_start`, `cursor_index` |
| Constants | `SCREAMING_SNAKE_CASE` | `TABLE_SIZE_MIN` |

### Formato de procedimientos para procedimientos públicos

{prefijo_fichero}_{descripción}(...)
ejemplo: `gb_init()`, `ed_insert_rune()`, `rd_draw_text()` donde `gb`, `ed` y `rd` son los prefijos de los ficheros `gap_buffer.odin`, `editor.odin` y `renderer.odin` respectivamente.

### Formato para uso de procedimientos públicos

{alias_paquete}.{procedimiento}(...)
ejemplo: `te.gb_init()`, `te.ed_insert_rune()`, `ui.rd_draw_text()` donde `te` y `ui` son los alias de los paquetes `text_engine` y `gui` respectivamente.

### Imports con Alias

Usa el nombre del package como alias para acceder a los procedimientos:

```odin
import te "text_engine"
import ui "gui"

gb: te.Gap_Buffer
te.gb_init(&gb, 100)
te.ed_insert_rune(&editor, 'H')
ui.rd_draw_text("Hello", 10, 10)
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

### Ramas

#### Estructura de Ramas

```
main                    # Rama principal (estable) - ver x.x.x
│                       # Merge desde develop
│
develop                 # Rama de desarrollo (preview) - ver x.x.x-preview
│                       # Merge desde ramas de trabajo
│
feat/42-xxx             # Ramas de trabajo basadas en issues (se eliminan tras merge a develop)
fix/42-xxx
chore/42-xxx
```

#### Tipos de Ramas de Trabajo

| Prefijo | Propósito | Versionado |
|---------|-----------|------------|
| `feat` | Nuevas funcionalidades | Sí (semver) |
| `fix` | Corrección de bugs | Sí (semver) |
| `chore` | Ajustes menores, refactors | No |

#### Flujo de Integración

```
1. Crear issue desde plantilla (.github/ISSUE_TEMPLATE/)
         ↓
2. Asignarse el issue
         ↓
3. Crear rama desde develop:
   git checkout -b feat/42-descripcion develop
         ↓
4. Trabajar en la rama (commits)
         ↓
5. Push y crear PR a develop
         ↓
6. Revisión de código
         ↓
7. Merge a develop (merge commit):
   - Tag en develop: v1.x.x-preview
         ↓
8. Rama de trabajo se elimina
         ↓
9. Cuando ready → merge develop a main:
   - Tag en main: v1.x.x
```

#### Nombramiento de Ramas

```
<tipo>/<numero-issue>-<descripcion-breve>

Ejemplos:
feat/42-gap-buffer-optimization
fix/15-cursor-blink-issue
chore/08-update-readme
```

### Issues

#### Plantillas de Issues

El proyecto usa plantillas estandarizadas en `.github/ISSUE_TEMPLATE/`:

| Plantilla | Descripción | Versionado |
|-----------|-------------|------------|
| [`feat.yml`](.github/ISSUE_TEMPLATE/feat.yml) | Solicitar nueva funcionalidad | Sí |
| [`fix.yml`](.github/ISSUE_TEMPLATE/fix.yml) | Reportar un bug | Sí |
| [`chore.yml`](.github/ISSUE_TEMPLATE/chore.yml) | Tareas menores, ajustes | No |

#### Proceso de Issue

1. Crear issue usando la plantilla correspondiente
2. Describir el problema o funcionalidad
3. Asignarse el issue
4. Crear rama de trabajo para el issue asignado y basarla en la rama `develop`
5. linked el issue en el PR

### Commits

#### Formato

```
<tipo>: <descripción>

[cuerpo opcional]
```

#### Tipos

| Tipo | Descripción | Versionado |
|------|-------------|------------|
| `feat` | Nueva funcionalidad | Sí |
| `fix` | Corrección de bug | Sí |
| `chore` | Tareas menores, ajustes | No |

#### Ejemplos

```
feat: agregar soporte para scroll vertical
fix: corregir parpadeo del cursor en Windows
chore: actualizar configuración de VS Code
```

### Pull Requests

#### Antes de Crear un PR

1. Sincronizar con la rama base (`develop`)
2. Ejecutar `odin check src` sin errores
3. Verificar que no haya memory leaks
4. Actualizar documentación si es necesario
5. linked el issue relacionado

#### Template de PR

Ver [`.github/PULL_REQUEST_TEMPLATE.md`](.github/PULL_REQUEST_TEMPLATE.md)

```markdown
## Pull Request: ver x.x.x-preview

### Descripción
[Breve descripción del cambio]

### Tipo de cambio
- [ ] Nueva funcionalidad (feat)
- [ ] Corrección de bug (fix)
- [ ] Tarea menor (chore)

### Issue relacionado
Closes #

### Checklist
- [ ] El código sigue las convenciones del proyecto
- [ ] `odin check src` pasa sin errores
- [ ] No hay memory leaks
- [ ] Documentación actualizada (si aplica)
```

### Code Review

#### Criterios de Revisión

- ¿El código sigue las convenciones del proyecto?
- ¿Hay tests para la nueva funcionalidad?
- ¿La lógica es clara y eficiente?
- ¿Se manejan correctamente los casos edge?
- ¿La documentación está actualizada?
- ¿El tipo de cambio es correcto (feat/fix/chore)?

### Versionado

#### Tags

| Rama | Formato | Ejemplo |
|------|---------|---------|
| `main` | `x.x.x` | `v1.0.0` |
| `develop` | `x.x.x-preview` | `v1.0.0-preview` |

#### Criterios de Versionado

| Tipo | Incremento | Ejemplo |
|------|------------|---------|
| `feat` | Minor (x.x.0) | `v1.1.0` |
| `fix` | Patch (x.x.x) | `v1.0.1` |
| `chore` | Sin cambio | - |

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

## Licencia

Al contribuir a este proyecto, aceptas que tus contribuciones serán licenciadas bajo la misma licencia del proyecto. Actualmente, el proyecto está bajo la licencia MIT. Para más detalles, consulta el archivo `LICENSE`.
