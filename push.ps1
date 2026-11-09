$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

Write-Host "=== laofu-rhetoric 发布助手 ===" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path ".git")) {
    $name  = (Read-Host "git 署名（会公开显示在提交记录里）").Trim()
    $email = (Read-Host "git 邮箱").Trim()

    git init -b main | Out-Null

    # 用环境变量传作者信息，避免中文在命令行参数里被转码
    $env:GIT_AUTHOR_NAME     = $name
    $env:GIT_AUTHOR_EMAIL    = $email
    $env:GIT_COMMITTER_NAME  = $name
    $env:GIT_COMMITTER_EMAIL = $email

    $msgFile = Join-Path $env:TEMP "laofu-commitmsg.txt"
    [System.IO.File]::WriteAllText(
        $msgFile,
        "老夫体：民间大师说话机制的通用拆解",
        (New-Object System.Text.UTF8Encoding($false))
    )

    git add -A
    git commit -F $msgFile | Out-Null
    Remove-Item $msgFile -Force

    Write-Host "本地提交完成。" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "已存在 git 仓库，跳过初始化。" -ForegroundColor Yellow
}

$user = (Read-Host "GitHub 用户名").Trim()

if (git remote | Select-String -Quiet '^origin$') {
    git remote remove origin
}
git remote add origin "https://github.com/$user/laofu-rhetoric.git"
git branch -M main

Write-Host ""
Write-Host "开始推送，稍后会弹浏览器让你登录 GitHub……" -ForegroundColor Yellow
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "完成：https://github.com/$user/laofu-rhetoric" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "推送失败。最常见原因：网页上还没建仓库，或仓库名不是 laofu-rhetoric。" -ForegroundColor Red
}
