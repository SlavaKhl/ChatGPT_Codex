[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Owner = "SlavaKhl",

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Repository = "ChatGPT_Codex"
)

$headers = @{
    Accept                 = "application/vnd.github+json"
    "X-GitHub-Api-Version" = "2026-03-10"
    "User-Agent"           = "ChatGPT-Codex-Project"
}

if ($env:GITHUB_TOKEN) {
    $headers.Authorization = "Bearer $($env:GITHUB_TOKEN)"
}

$encodedOwner = [Uri]::EscapeDataString($Owner)
$encodedRepository = [Uri]::EscapeDataString($Repository)
$uri = "https://api.github.com/repos/$encodedOwner/$encodedRepository"

try {
    $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    $message = "GitHub API request failed"

    if ($statusCode) {
        $message += " with HTTP status $statusCode"
    }

    Write-Error "$message. Check the repository name, network connection, and optional GITHUB_TOKEN."
    exit 1
}

[PSCustomObject]@{
    FullName       = $response.full_name
    Visibility     = $response.visibility
    DefaultBranch  = $response.default_branch
    OpenIssues     = $response.open_issues_count
    LastPushUtc    = $response.pushed_at
    RepositoryUrl  = $response.html_url
    ApiUrl         = $response.url
}
