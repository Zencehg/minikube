<#
.Synopsis
   Script to install web application with Helm
.DESCRIPTION
   Script will install web application, based on the input parameter (httpd or nginx) adn will remove the installed application
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>

Param(
    [ValidateSet('nginx', 'httpd')]
    [string]$app,
    [string]$path
)

Set-Location -Path $path
Install-Module powershell-yaml -Confirm -Scope CurrentUser
Import-Module powershell-yaml

$config = Get-Content configuration\app.yaml | ConvertFrom-Yaml

if ($app -eq 'httpd') { 
    $uninstApp = 'nginx'
    $uninstNamespace = $config.$uninstApp.namespace
}
else {
    $uninstApp = 'httpd'
    $uninstNamespace = $config.$uninstApp.namespace
}

# check if other app is installed 
$json = helm list -A -o json | ConvertFrom-Json

if ($json.name -contains $uninstApp) {
    helm uninstall $uninstApp -n $uninstNamespace
}

# get installation params
$namespace = $config.$app.namespace
$chartPath = $config.$app.chart
$port = $config.$app.port

# run helm install or upgrade
try {

    if ($json.name -contains $app) {
        $chartPath
        helm upgrade $app "$chartPath" -n $namespace --set service.port=$port
    }
    else {
        $chartPath
        helm install $app "$chartPath" -n $namespace --set service.port=$port
    }

}

catch {
}