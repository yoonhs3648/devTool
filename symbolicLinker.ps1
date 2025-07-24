# ===========================
# 1. powershell을 관리자 권한으로 실행
# 2. link_shared.ps1에 있는 디렉토리로 이동
# 3. Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass 입력 후 동의
# 4. .\symbolicLinker.ps1 입력

# ===========================
# 현재 디렉토리 이하에서 심볼릭 링크, 대상 찾기
# Get-ChildItem -Recurse -Attributes ReparsePoint | Select-Object FullName, LinkType, Target

# ===========================
# 심볼릭 링크 삭제
# Remove-Item "[FullName]" -Force


Write-Host "symbolic linker start"
Write-Host " made by hsyoon"

# 인코딩 설정
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Read-PathWithValidation {
    param (
        [string]$PromptMessage
    )
    while ($true) {
        $inputPath = Read-Host $PromptMessage
        if ([string]::IsNullOrWhiteSpace($inputPath)) {
            Write-Host "Path must be entered" -ForegroundColor Red
            continue
        }
        if (-Not (Test-Path $inputPath)) {
            Write-Host "The path entered does not exist. Please re-enter" -ForegroundColor Red
            continue
        }
        # 경로 출력 및 확인
        Write-Host "The path you entered: $inputPath"
        $confirm = Read-Host "Is this the correct route? (Y/N)"
        if ($confirm.ToUpper() -eq "Y") {
            return $inputPath
        }
    }
}

# 공통 JSP 경로 입력 받기
$sharedPath = Read-PathWithValidation "Enter a common sharedFiles path (ex: D:\IntelliJ\myWeb\sharedWebResources)"

# 프로젝트 루트 경로 입력 받기
$projectRoot = Read-PathWithValidation "Please enter a project root path (ex: D:\IntelliJ\myWeb\workspace_myWeb)"

# 대상 모듈 리스트 (필요하면 수정)
$modules = @("dev", "admin")

Write-Host "`n[Verifying Execution Information]"
Write-Host "common sharedFiles path: $sharedPath"
Write-Host "project root path: $projectRoot"
Write-Host "target modules: $($modules -join ', ')"

Read-Host "`nPress Enter to continue..."

foreach ($mod in $modules) {
    $target = Join-Path $projectRoot "myweb.root\myweb.$mod\src\main\webapp\WEB-INF\views\cmn"

    Write-Host "`n[$mod] Removing existing folders: $target"
    if (Test-Path $target) {
        Remove-Item $target -Recurse -Force
    }

    Write-Host "[$mod] Creating symbolic links → $sharedPath"
    New-Item -ItemType SymbolicLink -Path $target -Target $sharedPath
}

Write-Host "`n[Done] All symbolic link generation is complete"
Write-Host " made by hsyoon"
Read-Host "Press Enter to exit..."
