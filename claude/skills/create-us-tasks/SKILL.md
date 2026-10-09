---
name: create-us-tasks
description: Crea User Stories, Bugs y Tasks en Azure DevOps para el proyecto configurado en config.json (org, proyecto y team). Incluye el mapeo correcto de campos (acceptance criteria va en Microsoft.VSTS.Common.AcceptanceCriteria, los pasos de un bug en Microsoft.VSTS.TCM.ReproSteps, ninguno en description). Usar siempre que el usuario mencione crear US, user story, bug, tareas, backlog, work items, o quiera trackear features/bugs/fixes en Azure DevOps, incluso si no lo pide explícitamente con esos términos.
---

## Configuración

Los datos de la organización **no están en este archivo**: se leen de `config.json`, en la misma carpeta que este SKILL.md. Ese archivo no se versiona (ver `config.example.json`).

**Antes de cualquier otro paso, leer `<skill-dir>\config.json`.** Si no existe, pedirle al usuario los cuatro valores y crearlo a partir de `config.example.json`.

| Clave | Uso |
|---|---|
| `org` | URL de la organización, ej. `https://dev.azure.com/<org>` |
| `projectId` | GUID del proyecto. Usarlo en los comandos CLI en lugar del nombre, para evitar problemas de encoding con acentos y ñ |
| `projectName` | Nombre del proyecto, para `System.IterationPath` y las URLs del board (URL-encoded en las URLs) |
| `team` | Team del proyecto, para listar iteraciones |

En el resto de este documento, `{org}`, `{projectId}`, `{projectName}` y `{team}` se reemplazan por esos valores. `wi.ps1` los lee solo de `config.json`.

## Regla de oro: el contenido nunca viaja por la línea de comandos

`az boards work-item create/update` **corta cualquier valor en el primer salto de línea** y su stdout degrada los caracteres no-ASCII. Pasar descripciones o criterios de aceptación por `--description` / `--fields` produce work items mutilados que parecen correctos en el resumen.

El contenido va **siempre** en un archivo JSON Patch UTF-8 que se manda por la REST API con el helper incluido:

```powershell
& "<skill-dir>\scripts\wi.ps1" -Action create -Type "User Story" -BodyFile "<ruta>\us.json"
& "<skill-dir>\scripts\wi.ps1" -Action update -Id 15839 -BodyFile "<ruta>\patch.json"
& "<skill-dir>\scripts\wi.ps1" -Action show   -Id 15839
```

El script escribe, **relee el work item y compara campo por campo** contra lo enviado (comparando texto, no HTML, porque el server normaliza el markup). Termina con `RESULTADO: todos los campos verificados` o con `MISMATCH` + `exit 1`. Si sale MISMATCH, **no reportar el work item como creado correctamente**: revisar y corregir primero.

Los archivos JSON van al scratchpad de la sesión, no al repo del usuario.

## Flujo

### Paso 1 — Extraer la información del request

Identificar del mensaje del usuario:

- **Tipo(s)**: User Story, Bug, Task. Un pedido de "una US y un bug" son dos work items relacionados, no uno con el otro adentro.
- **Título** (obligatorio, uno por work item).
- **Contenido**, según el tipo (ver mapa de campos abajo).
- **Sprint**: sólo si lo menciona explícitamente ("sprint 144", "sprint actual"). Si no lo menciona, **no asignar**.

Ante la duda entre descripción y criterios de aceptación: el contexto/problema/solución va en la descripción, las condiciones verificables ("cuando X entonces Y") en los criterios.

### Paso 2 — Mapa de campos por tipo

| Tipo | Campos |
|---|---|
| User Story | `System.Title`, `System.Description`, `Microsoft.VSTS.Common.AcceptanceCriteria` |
| Bug | `System.Title`, `Microsoft.VSTS.TCM.ReproSteps`, `Microsoft.VSTS.Common.Severity` (`1 - Critical` … `4 - Low`) |
| Task | `System.Title`, `System.Description` |
| Todos | `System.IterationPath`, `System.AssignedTo` (opcionales) |

El formulario de Bug **no muestra `System.Description`**: los pasos, la causa raíz y el impacto van en `ReproSteps`.

### Paso 3 — Escribir el JSON Patch

Un archivo por work item. Cada valor HTML debe ir en **una sola línea** (JSON no admite saltos de línea literales dentro de un string) y con las entidades escapadas (`&gt;`, `&amp;`).

```json
[
  { "op": "add", "path": "/fields/System.Title", "value": "[Módulo] Título con acentos sin problema" },
  { "op": "add", "path": "/fields/System.Description", "value": "<p><strong>Contexto</strong></p><p>...</p>" },
  { "op": "add", "path": "/fields/Microsoft.VSTS.Common.AcceptanceCriteria", "value": "<ul><li>...</li></ul>" }
]
```

**Los links se crean en el mismo POST**, no con una llamada aparte. Para colgar una Task de su US:

```json
{
  "op": "add",
  "path": "/relations/-",
  "value": {
    "rel": "System.LinkTypes.Hierarchy-Reverse",
    "url": "{org}/{projectId}/_apis/wit/workItems/<us_id>"
  }
}
```

Relaciones útiles: `System.LinkTypes.Hierarchy-Reverse` (padre), `System.LinkTypes.Hierarchy-Forward` (hijo), `System.LinkTypes.Related` (relacionado — es lo correcto entre una US y su Bug; el vínculo padre-hijo entre esos dos tipos no siempre está permitido por el proceso).

### Paso 4 — Crear

```powershell
& "<skill-dir>\scripts\wi.ps1" -Action create -Type "User Story" -BodyFile "<scratchpad>\us.json"
```

Capturar el `id=` de la salida. Crear primero el padre, después los hijos con el link ya incluido.

### Paso 5 — Sprint (sólo si fue solicitado)

Va como un campo más del patch, en el momento de crear:

```json
{ "op": "add", "path": "/fields/System.IterationPath", "value": "{projectName}\\sprint 147" }
```

Si pidió "sprint actual", buscar primero el que tenga `Time Frame = current`:

```bash
az boards iteration team list --team "{team}" \
  --org {org} \
  --project {projectId} --output table
```

### Paso 6 — Verificar antes de reportar

El script ya verifica cada write. Si hubo varios work items, cerrar con un `-Action show` de cada uno para confirmar estado, sprint y relaciones.

## Salida final

```
✓ US #<id> — <título>
  {org}/{projectName (URL-encoded)}/_workitems/edit/<id>

  Tasks:
  ├── #<id1> <título task 1>
  └── #<id2> <título task 2>

  Relacionado: Bug #<id>
  Sprint: <nombre> / Sin sprint asignado
```

## Errores conocidos y cómo evitarlos

| Síntoma | Causa | Qué hacer |
|---|---|---|
| La descripción quedó con una sola línea (`<p><strong>Contexto</strong></p>` y nada más) | `az boards` corta el valor en el primer `\n` | Usar `wi.ps1`. Nunca `--description` / `--fields` con contenido |
| Acentos que se ven como `?` o `�` | El stdout de az usa la codepage ANSI; **el dato guardado suele estar bien** | Verificar con `wi.ps1 show` o REST, nunca leyendo la salida de az. No "arreglar" lo que sólo se ve mal |
| `ERROR: unrecognized arguments: --project` | `az boards work-item update` no acepta `--project` (a diferencia de `create` y `delete`) | Omitir el parámetro en ese comando |
| `TF401320 Rule Error ... Error code: ReadOnly` | El work item está en estado `Closed`/`Resolved` y las reglas del proceso vuelven read-only campos como Acceptance Criteria | Cargar todos los campos **antes** de cerrarlo; si ya está cerrado, pedirle al usuario que lo reabra |
| La longitud guardada no coincide con la enviada | Azure DevOps normaliza el HTML al persistirlo | Es esperable; el script compara texto y no marca esto como error |
| `az rest` contra dev.azure.com devuelve 401 | Toma el token de ARM por defecto | Pasar `--resource 499b84ac-1321-427f-aa17-267ca6975798` |
| Un id que "no existe" | Puede estar borrado (papelera) o en otro proyecto | `TF401232` no siempre es permisos; revisar la papelera del proyecto |

Para borrar (va a la papelera de reciclaje del proyecto, es recuperable):

```bash
az boards work-item delete --id <id> --org {org} \
  --project {projectId} --yes
```

## Notas

- **Nunca asumir sprint.** Si el usuario no lo menciona, dejar sin asignar.
- **HTML en los campos de texto.** Usar `<p>`, `<ul>/<li>`, `<strong>`, `<code>` para que se lea bien en el board.
- **Si no da criterios de aceptación**, crear la US igual sin ese campo — no inventarlos.
- **Si no da tasks**, crear sólo el work item pedido y aclararlo en el resumen.
- **Borrar work items es destructivo**: confirmarlo con el usuario salvo que lo haya pedido explícitamente.
