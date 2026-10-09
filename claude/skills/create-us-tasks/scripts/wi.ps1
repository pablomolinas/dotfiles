<#
.SYNOPSIS
  Crea / actualiza work items en Azure DevOps mandando el JSON Patch desde un archivo UTF-8.

.DESCRIPTION
  Existe para esquivar tres fallas del CLI `az boards` en Windows:
    1. `--description` y `--fields` cortan el valor en el primer salto de linea.
    2. El stdout de az degrada los caracteres no-ASCII, asi que no sirve para verificar.
    3. `az boards work-item update` no acepta `--project`.

  Despues de escribir, relee el work item y compara campo por campo contra lo que se envio.
  La comparacion es sobre el texto (tags HTML removidos, espacios colapsados) porque Azure
  DevOps normaliza el HTML al guardarlo y una comparacion literal daria falsos negativos.

  La salida es ASCII pura a proposito: el estado se reporta con longitudes y OK/MISMATCH,
  nunca imprimiendo el contenido, que es justamente lo que la consola rompe.

.EXAMPLE
  .\wi.ps1 -Action create -Type "User Story" -BodyFile .\us.json
  .\wi.ps1 -Action update -Id 15839 -BodyFile .\us-link.json
  .\wi.ps1 -Action show   -Id 15839

  Org y proyecto se leen de config.json; -Org y -Project los sobreescriben.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidateSet('create', 'update', 'show')][string]$Action,
    [ValidateSet('User Story', 'Bug', 'Task', 'Feature')][string]$Type,
    [int]$Id,
    [string]$BodyFile,
    # Por defecto se toman de config.json (org y projectId), junto al SKILL.md
    [string]$Org,
    [string]$Project
)

$ErrorActionPreference = 'Stop'

if (-not $Org -or -not $Project) {
    $configFile = Join-Path (Split-Path $PSScriptRoot -Parent) 'config.json'
    if (-not (Test-Path $configFile)) {
        throw "No existe $configFile. Crearlo a partir de config.example.json o pasar -Org y -Project."
    }
    $config = Get-Content $configFile -Raw -Encoding utf8 | ConvertFrom-Json
    if (-not $Org) { $Org = $config.org }
    if (-not $Project) { $Project = $config.projectId }
}

# App id fijo de Azure DevOps: el token de ARM no sirve contra dev.azure.com.
$AzureDevOpsResource = '499b84ac-1321-427f-aa17-267ca6975798'
$ApiVersion = '7.0'

function Get-AuthHeader {
    $token = az account get-access-token --resource $AzureDevOpsResource --query accessToken -o tsv
    if (-not $token) { throw "No se pudo obtener el token. Correr 'az login'." }
    return @{ Authorization = "Bearer $token" }
}

function Invoke-WorkItemApi {
    param($Method, $Uri, $Headers, $Bytes)

    try {
        if ($null -eq $Bytes) {
            return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers
        }
        # charset=utf-8 + bytes explicitos: sin esto los acentos viajan en la codepage ANSI.
        return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $Headers `
            -ContentType 'application/json-patch+json; charset=utf-8' -Body $Bytes
    }
    catch {
        $detalle = $null
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $cuerpo = $reader.ReadToEnd()
            $reader.Close()
            try { $detalle = ($cuerpo | ConvertFrom-Json).message } catch { $detalle = $cuerpo }
        }
        if (-not $detalle) { $detalle = $_.Exception.Message }
        throw "API $Method fallo: $detalle"
    }
}

function ConvertTo-ComparableText {
    param([string]$Html)

    if (-not $Html) { return '' }
    # Primero se quitan los tags y despues se decodifican las entidades: al revez, un
    # &lt;p&gt; escapado se volveria un tag real y se perderia al limpiar.
    # HtmlDecode cubre el set completo (&iacute;, &rarr;, &nbsp;, ...): decodificar a mano
    # solo un punado de entidades daba MISMATCH falsos cuando el patch usaba acentos escapados.
    $texto = $Html -replace '<[^>]+>', ' '
    $texto = [System.Net.WebUtility]::HtmlDecode($texto)
    return ($texto -replace '\s+', ' ').Trim()
}

function Test-RoundTrip {
    param($Patch, $WorkItem)

    # El reporte se acumula y se devuelve junto al contador en un solo objeto. Si estas
    # lineas salieran por el stream de salida, el llamador las capturaria dentro de
    # $problemas (quedando un array de strings + el contador) y el chequeo `-gt 0`
    # posterior daria verdadero siempre, marcando MISMATCH incluso sin diferencias.
    $lineas = [System.Collections.Generic.List[string]]::new()
    $problemas = 0

    foreach ($op in $Patch) {
        if ($op.path -notlike '/fields/*') { continue }

        $campo = $op.path.Substring(8)
        $enviado = [string]$op.value
        $guardado = [string]$WorkItem.fields.$campo

        $txtEnviado = ConvertTo-ComparableText $enviado
        $txtGuardado = ConvertTo-ComparableText $guardado

        if ($txtEnviado -ceq $txtGuardado) {
            $lineas.Add(("  OK        {0} ({1} chars)" -f $campo, $guardado.Length))
            continue
        }

        $problemas++
        $lineas.Add(("  MISMATCH  {0}: texto enviado {1} chars, guardado {2} chars" -f $campo, $txtEnviado.Length, $txtGuardado.Length))

        if ($txtGuardado.Length -lt $txtEnviado.Length -and $txtEnviado.StartsWith($txtGuardado)) {
            $lineas.Add("            -> TRUNCADO: quedo solo el prefijo (tipico de pasar el valor por linea de comandos)")
        }

        $noAsciiEnviado = ([regex]::Matches($txtEnviado, '[^\x00-\x7F]')).Count
        $noAsciiGuardado = ([regex]::Matches($txtGuardado, '[^\x00-\x7F]')).Count
        if ($noAsciiEnviado -ne $noAsciiGuardado) {
            $lineas.Add(("            -> ENCODING: {0} caracteres no-ASCII enviados vs {1} guardados" -f $noAsciiEnviado, $noAsciiGuardado))
        }
    }

    $relaciones = @($Patch | Where-Object { $_.path -like '/relations/*' }).Count
    if ($relaciones -gt 0) {
        $lineas.Add(("  relaciones enviadas: {0} | presentes en el work item: {1}" -f $relaciones, @($WorkItem.relations).Count))
    }

    return [pscustomobject]@{ Problemas = $problemas; Lineas = $lineas }
}

$headers = Get-AuthHeader
$base = "$Org/$Project/_apis/wit/workitems"

switch ($Action) {
    'show' {
        if (-not $Id) { throw "-Id es obligatorio para 'show'." }
        $wi = Invoke-WorkItemApi -Method Get -Uri "$base/$($Id)?`$expand=relations&api-version=$ApiVersion" -Headers $headers
        "id={0}" -f $wi.id
        "type={0}" -f $wi.fields.'System.WorkItemType'
        "state={0}" -f $wi.fields.'System.State'
        "iteration={0}" -f $wi.fields.'System.IterationPath'
        foreach ($campo in ($wi.fields.PSObject.Properties.Name | Sort-Object)) {
            $valor = [string]$wi.fields.$campo
            if ($valor.Length -gt 60) { "  {0}: {1} chars" -f $campo, $valor.Length }
        }
        foreach ($rel in $wi.relations) { "  rel {0} -> {1}" -f $rel.rel, $rel.url.Split('/')[-1] }
        return
    }

    'create' {
        if (-not $Type) { throw "-Type es obligatorio para 'create'." }
        if (-not $BodyFile) { throw "-BodyFile es obligatorio para '$Action'." }
        if (-not (Test-Path $BodyFile)) { throw "No existe el body file: $BodyFile" }
        $uri = "$base/`$$($Type -replace ' ', '%20')?api-version=$ApiVersion"
        $method = 'Post'
    }

    'update' {
        if (-not $Id) { throw "-Id es obligatorio para 'update'." }
        if (-not $BodyFile) { throw "-BodyFile es obligatorio para '$Action'." }
        if (-not (Test-Path $BodyFile)) { throw "No existe el body file: $BodyFile" }
        $uri = "$base/$($Id)?api-version=$ApiVersion"
        $method = 'Patch'
    }
}

$json = Get-Content $BodyFile -Raw -Encoding utf8
$patch = $json | ConvertFrom-Json
$bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

$wi = Invoke-WorkItemApi -Method $method -Uri $uri -Headers $headers -Bytes $bytes
"id={0}" -f $wi.id

# Relectura independiente: confirma lo que quedo persistido, no lo que devolvio el write.
$verificado = Invoke-WorkItemApi -Method Get -Uri "$base/$($wi.id)?`$expand=relations&api-version=$ApiVersion" -Headers $headers
$reporte = Test-RoundTrip -Patch $patch -WorkItem $verificado
foreach ($linea in $reporte.Lineas) { $linea }

if ($reporte.Problemas -gt 0) {
    "RESULTADO: {0} campo(s) no coinciden. NO reportar el work item como correcto." -f $reporte.Problemas
    exit 1
}
"RESULTADO: todos los campos verificados."
