#============================================================================================
#============================================================================================
# ===== 모듈 목록 및 context 매핑 ( TODO: 추가가 필요하면 추가하세요 ("웹모듈" = "컨텍스트경로") ) =====
#============================================================================================
#============================================================================================
$modules = @{
	"myweb.dev" = "dev"
	"myweb.admin" = "admin"
	"myweb.core" = "core"
	#"myweb.test" = "test"
}
#============================================================================================
#============================================================================================

#============================================================================================
# 각 웹모듈의 pom.xml에 있는 모듈의존성 추출을 위한 groupID
$GROUP_ID = "yoon.hyeonsang"	#com.covision
#============================================================================================

#============================================================================================
# 톰캣 컨텍스트 재로드시 필요한 tomcat-user.xml의 값
$USER_NAME = "hsyoon"
$USER_PASSWORD = "hsyoon"
$USER_ROLES = "manager-script,admin-gui,manager-gui"
#============================================================================================


# 인코딩 설정
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ===== PowerShell이 입력받은 파라미터 =====
$connectorPort    = $args[1]
$serverPort       = [int]$connectorPort - 75
$debugPort     = [int]$connectorPort - 3075
$DDEPLOY_PATH     = $args[2]
$MAVEN_PATH       = $args[3]
$SETTINGS_XML_PATH = $args[4]
$TOMCAT_PATH      = $args[5]
$WORKSPACE_PATH   = $args[6]

# ===== 환경변수 등록 =====
$env:JAVA_OPTS = "-DDEPLOY_PATH=$DDEPLOY_PATH -Dfile.encoding=UTF-8"
$env:CATALINA_HOME = $TOMCAT_PATH
$env:CATALINA_BASE = $TOMCAT_PATH

# ===== 사용자 확인용 로그 =====
Write-Host ""
Write-Host ""
Write-Host "runner.ps1 를 시작합니다" -ForegroundColor Magenta

Write-Host ""
Write-Host "[INFO] 사용자 입력 환경변수" -ForegroundColor Cyan
Write-Host "connectorPort번호 : $connectorPort" -ForegroundColor Cyan
Write-Host "serverPort번호 : $serverPort" -ForegroundColor Cyan
Write-Host "Covi_property(DDEPLOY_PATH)경로 : $DDEPLOY_PATH" -ForegroundColor Cyan
Write-Host "MAVEN_PATH경로 : $MAVEN_PATH" -ForegroundColor Cyan
Write-Host "고객사 메이븐 세팅xml 경로 : $SETTINGS_XML_PATH" -ForegroundColor Cyan
Write-Host "톰캣 경로 : $TOMCAT_PATH" -ForegroundColor Cyan
Write-Host "WORKSPACE_PATH 경로 : $WORKSPACE_PATH" -ForegroundColor Cyan
Write-Host "CATALINA_HOME 경로 : $TOMCAT_PATH" -ForegroundColor Cyan
Write-Host "CATALINA_BASE 경로 : $TOMCAT_PATH" -ForegroundColor Cyan

# ===== 디버깅 환경변수 추가 등록 ====
Write-Host ""
Write-Host "[INFO] 디버깅 옵션을 JPDA_OPTS에 설정합니다" -ForegroundColor Cyan
$debugOptions = "-agentlib:jdwp=transport=dt_socket,address=localhost:$debugPort,suspend=n,server=y"
$env:JPDA_OPTS = $debugOptions
Write-Host "디버그 포트: $debugPort" -ForegroundColor Cyan
Write-Host "JPDA_OPTS 옵션: $debugOptions" -ForegroundColor Cyan

Start-Sleep -Seconds 1

# ===== 구동 시작 =====
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host " ██╗   ██╗  ██████╗  ██████╗ ███╗   ██╗" -ForegroundColor Yellow
Write-Host " ██║   ██║ ██╔═══██╗██╔═══██╗████╗  ██║" -ForegroundColor Yellow
Write-Host " ████████╝ ██║   ██║██║   ██║██╔██╗ ██║" -ForegroundColor Yellow
Write-Host "   ║██║    ██║   ██║██║   ██║██║╚██╗██║" -ForegroundColor Yellow
Write-Host "   ║██║    ╚██████╔╝╚██████╔╝██║ ╚████║" -ForegroundColor Yellow
Write-Host "   ╚══╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   YOON" -ForegroundColor Yellow
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "██╗  ██╗██╗   ██╗███████╗ ██████╗ ███╗   ██╗" -ForegroundColor Green
Write-Host "██║  ██║██║   ██║██╔════╝██╔═══██╗████╗  ██║" -ForegroundColor Green
Write-Host "███████║████████╝█████╗  ██║   ██║██╔██╗ ██║" -ForegroundColor Green
Write-Host "██╔══██║  ║██║   ██╔══╝  ██║   ██║██║╚██╗██║" -ForegroundColor Green
Write-Host "██║  ██║  ║██║   ███████╗╚██████╔╝██║ ╚████║" -ForegroundColor Green
Write-Host "╚═╝  ╚═╝  ╚══╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═══╝   HYEON" -ForegroundColor Green
Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor Gray
Write-Host "███████╗ █████╗ ███╗   ██╗ ██████╗" -ForegroundColor Blue
Write-Host "██╔════╝██╔══██╗████╗  ██║██╔════╝" -ForegroundColor Blue
Write-Host "███████╗███████║██╔██╗ ██║██║ ███║" -ForegroundColor Blue
Write-Host "╚════██║██╔══██║██║╚██╗██║██║  ██║" -ForegroundColor Blue
Write-Host "███████║██║  ██║██║ ╚████║╚██████║" -ForegroundColor Blue
Write-Host "╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝   SANG" -ForegroundColor Blue
Write-Host "─────────────────────────────────────────────────────────────"
Write-Host " Made By hsyoon" -ForegroundColor Magenta
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""

#============================================================================================
#============================================================================================
#================================= 서버 및 프로젝트 환경구성 시작 ================================
#============================================================================================
#============================================================================================

# 포트 사용 여부 확인
$connectorPortInfo = Get-NetTCPConnection -LocalPort $connectorPort -ErrorAction SilentlyContinue
$serverPortInfo = Get-NetTCPConnection -LocalPort $serverPort -ErrorAction SilentlyContinue

$connectorPortInUse = $connectorPortInfo -ne $null
$serverPortInUse = $serverPortInfo -ne $null

# 포트 점유 여부 및 강제종료 확인
if ($connectorPortInUse -or $serverPortInUse) {
	$allPortInfo = @()
	if ($connectorPortInUse) { $allPortInfo += $connectorPortInfo }
	if ($serverPortInUse) { $allPortInfo += $serverPortInfo }

	$pids = $allPortInfo | Select-Object -ExpandProperty OwningProcess -Unique

	if ($pids.Count -gt 0) {
		Write-Host "[WARN] $connectorPort 포트를 점유 중인 프로세스가 존재합니다" -ForegroundColor Yellow
		Write-Host @"
┌────────────────────────────────────────────────────────────────────────────────┐
│   $connectorPort 포트를 점유 중인 프로세스를 종료할까요?                                 │
│   네:y  아니요:n                                                               │
└────────────────────────────────────────────────────────────────────────────────┘
￣￣￣￣￣ヽ___ノ￣￣￣￣￣￣￣￣￣
        Ｏ
         o
        ,. ─冖'⌒'─､
       ノ       ＼
       / ,r‐へへく⌒'￢､  ヽ
      {ノ へ._、 ,,／~  〉 ｝
     ／プ￣￣y'¨Y´￣￣ヽ─}j=く
    ノ /レ'>ー{___ｭーー'  ﾘ,ｲ}
   / _勺 ｲ;；∵r===､､∴'∵;  シ 
  ,/ └'ノ ＼  ご    ノ{ー—､__
  人＿_/ー┬ー个-､＿＿,,.. ‐´ 〃ァーｧー＼
. /  |／ |::::|､      〃 /:::/ ヽ
/    |  |::::|＼､_________／ /:::/〃  |
"@ -ForegroundColor Yellow
		Write-Host ""
		$isSucess = $false

		do {
			$userInput = Read-Host "[y/n]  "
			switch ($userInput.ToLower()) {
				'y' {
					try
					{
						foreach ($processId in $pids) {
							Stop-Process -Id $processId -Force -ErrorAction Stop
							Write-Host "[INFO] PID $processId 프로세스를 종료했습니다" -ForegroundColor Cyan
						}
						$isSucess = $true
					}
					catch
					{
						Write-Host "[ERROR] PID $processId 프로세스 종료에 실패했습니다: $_" -ForegroundColor Red
						Write-Host "runner.ps1 실행을 종료합니다..." -ForegroundColor Red
						Write-Host " Made By hsyoon" -ForegroundColor Magenta
						exit 1
					}
				}
				'n' {
					Write-Host "runner.ps1 실행을 종료합니다..." -ForegroundColor Red
					Write-Host " Made By hsyoon" -ForegroundColor Magenta
					exit 1
				}
				default {
					Write-Host "[WARN] 유효하지 않은 입력입니다. 'y' 또는 'n'을 입력해주세요" -ForegroundColor Yellow
				}
			}
		} while(-not $isSucess)
	} else {
		Write-Host "[ERROR] 포트를 점유한 프로세스를 찾을 수 없습니다" -ForegroundColor Red
		Write-Host "runner.ps1 실행을 종료합니다..." -ForegroundColor Red
		Write-Host " Made By hsyoon" -ForegroundColor Magenta
		exit 1
	}
}

Start-Sleep -Seconds 5

# ===== 프로젝트 전체 빌드 시작 =====
Write-Host ""
Write-Host ""
Write-Host "[INFO] 프로젝트 빌드를 시작합니다" -ForegroundColor Cyan


foreach ($module in $modules.Keys) {
	Write-Host ""
	Write-Host "[INFO] 빌드중...: $module" -ForegroundColor Cyan

	$ctxName = $modules[$module]

	# & $MAVEN_PATH clean package -DskipTests -pl $module -am -s $SETTINGS_XML_PATH     #전체빌드+패키징(속도매우느림)
	& $MAVEN_PATH compile -DskipTests -T 4 -pl $module -am -s $SETTINGS_XML_PATH		#병렬증분빌드(성능을 위해 컴파일만 한다)

	if ($LASTEXITCODE -ne 0) {
		Write-Host ""
		Write-Host "[ERROR] 빌드에 실패했습니다: $module" -ForegroundColor Red
		Write-Host "[ERROR] runner.ps1 실행을 종료합니다..." -ForegroundColor Red
		Write-Host " Made By hsyoon" -ForegroundColor Magenta
		exit $LASTEXITCODE
	} else {
		Write-Host "[INFO] 빌드를 성공했습니다: $module" -ForegroundColor Cyan
	}
}

# ===== 웹모듈별 context.xml 설정 =====
$contextPath = "$TOMCAT_PATH\conf\Catalina\localhost"

Write-Host ""
Write-Host ""
Write-Host "[INFO] tomcat 구성 준비를 시작합니다" -ForegroundColor Cyan

# ===== Catalina/localhost 디렉토리 초기화 및 생성 =====
if (Test-Path $contextPath) {
	Write-Host "[INFO] Tomcat의 configuration 경로가 존재합니다: $contextPath" -ForegroundColor Cyan
	#Remove-Item -Path "$contextPath\*" -Recurse -Force
} else {
	Write-Host "[INFO] Tomcat의 configuration 경로를 생성합니다: $contextPath" -ForegroundColor Cyan
	New-Item -ItemType Directory -Path $contextPath -Force | Out-Null
}

$moduleDependencies = @()
Write-Host "[INFO] 웹모듈 단위로 context.xml 생성중..." -ForegroundColor Cyan

foreach ($module in $modules.Keys) {
	$ctxName = $modules[$module]
	$ctxFile = "$contextPath\$ctxName.xml"
	$docBasePath = "$WORKSPACE_PATH\$module\src\main\webapp"
	$preResourcesPath = "$WORKSPACE_PATH\$module\target\classes"
	$postResourcesPath = ""
	$preResourcesXml = ""

	Write-Host ""
	Write-Host "[INFO] $ctxName 의 context.xml를 생성합니다. -> $ctxName.xml" -ForegroundColor Cyan

	#각 웹모듈의 pom.xml을 동적으로 읽어서 프로젝트 내 jar 의존성 (framework 또는 resources) 추출
	$modulePath = "$WORKSPACE_PATH\$module\pom.xml"
	if (Test-Path $modulePath) {
		[xml]$pomXml = Get-Content $modulePath -Raw -Encoding UTF8
		$dependencies = $pomXml.project.dependencies.dependency

		foreach ($dependency in $dependencies) {
			if ($dependency.groupId -eq $GROUP_ID){
				$artifactId = $dependency.artifactId

				#실시간 배포를 위해 변수에 추가
				$moduleDependencies += $artifactId

				$classPath = "$WORKSPACE_PATH\$artifactId\target\classes"
				$preResourcesXml += "		<PreResources base=`"$classPath`" className=`"org.apache.catalina.webresources.DirResourceSet`" webAppMount=`"/WEB-INF/classes`" />`r`n"
			}
		}
	} else {
		Write-Host "[ERROR] $modulePath 를 찾을 수 없습니다" -ForegroundColor Red
		Write-Host "runner.ps1 실행을 종료합니다..." -ForegroundColor Red
		Write-Host " Made By hsyoon" -ForegroundColor Magenta
		exit 1
	}

	if (Test-Path $ctxFile) {
		#TODO: context.xml을 만드는건 시간이 다소 오래걸리는 작업이여서 파일이 이미 존재할 경우 스킵한다. 만약 메이븐 의존성의 변경이 있으면 각 웹모듈의 context.xml을 삭제해야 새로 만들어진다
		Write-Host "[INFO] $ctxName 의 context.xml 파일이 이미 존재합니다 /$ctxName -> $ctxFile" -ForegroundColor Cyan
		#Remove-Item -Path $ctxFile -Force
		continue
	}

	Push-Location $WORKSPACE_PATH
	# Maven 명령 실행 결과를 파일로 저장
	$outputFile = "${ctxName}_dependency_list.txt"
	mvn dependency:list -DoutputAbsoluteArtifactFilename=true `
    -pl $module `
    -s $SETTINGS_XML_PATH `
    > $outputFile

	# 확인 로그
	if (Test-Path $outputFile) {
		Write-Host "[INFO] $ctxName Maven 의존성 리스트 파일: $WORKSPACE_PATH\$outputFile" -ForegroundColor Cyan
	} else {
		Write-Host "[ERROR] Maven dependency 조회에 실패했습니다: $module" -ForegroundColor Red
		Write-Host "[ERROR] runner.ps1 실행을 종료합니다..." -ForegroundColor Red
		Write-Host " Made By hsyoon" -ForegroundColor Magenta
		exit 1
	}

	# 결과 파일에서 .jar 경로를 읽어서 PostResources 태그 생성
	Get-Content $outputFile | Where-Object { $_ -match ".*\.jar" } | ForEach-Object {
		if ($_ -match "([A-Z]:\\[^:]+\.jar)") {
			$jarFullPath = $matches[1]
			$jarName = [System.IO.Path]::GetFileName($jarFullPath)

			# framework는 실시간 배포를 위해 PreResources로 등록하고 PostResources에서 필터링한다
			if ($jarName -match "^(.+?)-[\d\.]+\.jar$") {
				$moduleName = $matches[1]

				# 이미 PreResources에 등록된 모듈이면 건너뜀
				if ($moduleDependencies -contains $moduleName) {
					return
				}
			}

			$webAppMount = "/WEB-INF/lib/$jarName"

			# PostResources 한 줄 추가
			$postResourcesPath += "        <PostResources base=`"$jarFullPath`" className=`"org.apache.catalina.webresources.FileResourceSet`" webAppMount=`"$webAppMount`" />`r`n"
		}
	}

	# ===== hot deploy를 지원하는 웹모듈별 context.xml 내용 생성 =====
	$contextContent = @"
<Context docBase="$docBasePath" reloadable="true">
	<Resources>
		<PreResources base="$preResourcesPath" className="org.apache.catalina.webresources.DirResourceSet" webAppMount="/WEB-INF/classes" />
$preResourcesXml
$postResourcesPath
	</Resources>
</Context>
"@

	# ===== context.xml파일 생성 =====
	$contextContent | Set-Content -Encoding UTF8 $ctxFile
	Write-Host "[INFO] 웹모듈의 context.xml 생성을 성공했습니다: /$ctxName -> $ctxFile" -ForegroundColor Cyan
}

# ===== jar 모듈 컴파일 =====
$moduleDependencies = $moduleDependencies | Select-Object -Unique	# 중복되는 의존성 처리

foreach ($moduleDependency in $moduleDependencies) {
	Write-Host ""
	Write-Host "[INFO] 빌드중...: $moduleDependency" -ForegroundColor Cyan

	& $MAVEN_PATH compile -DskipTests -T 4 -pl $moduleDependency -am -s $SETTINGS_XML_PATH		#병렬증분빌드
	if ($LASTEXITCODE -ne 0) {
		Write-Host ""
		Write-Host "[ERROR] 빌드에 실패했습니다: $moduleDependency" -ForegroundColor Red
		Write-Host "[ERROR] runner.ps1 실행을 종료합니다..." -ForegroundColor Red
		Write-Host " Made By hsyoon" -ForegroundColor Magenta
		exit $LASTEXITCODE
	} else {
		Write-Host "[INFO] 빌드를 성공했습니다: $moduleDependency" -ForegroundColor Cyan
	}
}

# ==== server.xml의 서버 포트번호 설정 ====
$SERVER_XML = "$TOMCAT_PATH\conf\server.xml"

Write-Host ""
Write-Host ""
Write-Host "[INFO] server.xml 업데이트 중..." -ForegroundColor Cyan
Write-Host "[INFO] server포트(shutdown포트)번호를 $serverPort 로 설정합니다" -ForegroundColor Cyan
Write-Host "[INFO] connector포트번호를 $connectorPort 로 설정합니다" -ForegroundColor Cyan

# 기존 server.xml 읽기
$content = Get-Content $SERVER_XML
# server포트(shutdown포트) 교체
$content = $content -replace '<Server port="[^"]*"', "<Server port=`"$serverPort`""
# connector포트 교체
$content = $content -replace '<Connector port="[^"]*"', "<Connector port=`"$connectorPort`""
#TODO: connector의 redirectPort는 http커넥터가 https로 리다이렉트 할때 어떤 포트로 리다이렉트 할지 지정하는 설정 -> http만 쓰는 로컬개발에서는 의미없다(겹쳐도 상관없음)
# server.xml 업데이트
$content | Set-Content $SERVER_XML

Write-Host "[INFO] server.xml 업데이트를 성공했습니다: $SERVER_XML" -ForegroundColor Cyan

# ==== 톰캣 컨텍스트 재로드를 위한 tomcat-user.xml 설정 ====
$TOMCAT_USERS_XML = "$TOMCAT_PATH\conf\tomcat-users.xml"

Write-Host ""
Write-Host ""
Write-Host "[INFO] tomcat-users.xml 업데이트 중..." -ForegroundColor Cyan
Write-Host "[INFO] 사용자 정보: username=$USER_NAME, password=$USER_PASSWORD, roles=$USER_ROLES" -ForegroundColor Cyan

# 기존 tomcat-users.xml 읽기
$content = Get-Content $TOMCAT_USERS_XML -Raw

# 사용자 태그 생성
$userTag = "<user username=`"$USER_NAME`" password=`"$USER_PASSWORD`" roles=`"$USER_ROLES`" />"

if ($content -notmatch "<user username=`"$USER_NAME`"") {
	$content = $content -replace "</tomcat-users>", "    $userTag`r`n</tomcat-users>"
	$content | Set-Content $TOMCAT_USERS_XML -Encoding UTF8
	Write-Host "[INFO] tomcat-users.xml 업데이트를 성공했습니다" -ForegroundColor Cyan
} else {
	Write-Host "[INFO] 사용자 정보가 이미 tomcat-users.xml에 등록되었습니다" -ForegroundColor Cyan
}



#============================================================================================
#============================================================================================
#================================= 서버 및 프로젝트 환경구성 끝 =================================
#============================================================================================
#============================================================================================




#============================================================================================
#============================================================================================
#================================= 실시간 배포 프로세스 등록 시작 ================================
#============================================================================================
#============================================================================================
Write-Host ""
Write-Host ""
Write-Host "[INFO] 실시간 자동 배포 프로세스를 구성합니다" -ForegroundColor Cyan

$deployLogDir = Join-Path $TOMCAT_PATH "logs"
if (-not (Test-Path $deployLogDir)){
	New-Item -ItemType Directory -Path $deployLogDir -Force | Out-Null
}
Write-Host "[INFO] 배포로그: $deployLogDir\auto-deploy.$(Get-Date -Format 'yyyy-MM-dd').log" -ForegroundColor Cyan
Write-Host ""

# ===== jar 모듈 감시 설정 =====
foreach ($artifactId in $moduleDependencies) {
	$sourceDir = Join-Path $WORKSPACE_PATH "$artifactId\src\main\java"
	$logDir = $deployLogDir

	Write-Host "[INFO] $artifactId 감시 등록 중..." -ForegroundColor Cyan

	# 백그라운드 감시 작업
	$script = {
		param($artifactId, $sourceDir, $WORKSPACE_PATH, $MAVEN_PATH, $SETTINGS_XML_PATH, $logDir, $connectorPort, $modules, $USER_NAME, $USER_PASSWORD)

		#auto-deploy 로그 기록
		function Write-DeployLog($message) {
			$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
			$datePart = Get-Date -Format "yyyy-MM-dd"
			$deployLogFileName = "auto-deploy.$datePart.log"
			$deployLogPath = Join-Path $logDir $deployLogFileName
			"[$timestamp] $message" | Out-File -Append -Encoding UTF8 $deployLogPath
		}

		#톰캣 컨텍스트 재로드
		function Reload-TomcatContext($contextPath) {
			$tomcatManagerUrl = "http://localhost:$connectorPort/manager/text/reload?path=/$contextPath"
			$username = $USER_NAME
			$password = $USER_PASSWORD

			$pair = "$username`:$password"
			$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

			$headers = @{
				Authorization = "Basic $encodedAuth"
			}

			try {
				$response = Invoke-RestMethod -Uri $tomcatManagerUrl -Headers $headers -Method Get
				Write-DeployLog "톰캣 컨텍스트 재로드(/$contextPath) : $response"
			}
			catch {
				Write-DeployLog "톰캣 컨텍스트 재로드 실패(/$contextPath): $($_.Exception.Message)"
			}
		}

		# ===== Java 컴파일 =====
		$isBuilding = $false
		$debounceTimer = New-Object Timers.Timer
		$debounceTimer.Interval = 3000
		$debounceTimer.AutoReset = $false
		$debounceTimer.Enabled = $false

		function Compile-Java {
			if ($isBuilding) { return }
			$isBuilding = $true
			Write-DeployLog "[INFO] 컴파일 시작: $artifactId"

			try {
				Push-Location $WORKSPACE_PATH
				$compileOutput = & $MAVEN_PATH compile -DskipTests -pl $artifactId -am -s $SETTINGS_XML_PATH 2>&1
				$compileSuccess = $true

				foreach ($line in $compileOutput) {
					Write-DeployLog "[INFO] [Maven] $line"
					if ($line -match 'COMPILATION ERROR' -or $line -match 'BUILD FAILURE') {
						$compileSuccess = $false
					}
				}

				if (-not $compileSuccess) {
					Write-DeployLog "[ERROR] 컴파일 실패: $artifactId - 반영을 중단합니다"
					return
				}

				Write-DeployLog "[INFO] 컴파일 완료: $artifactId"

				# jar모듈은 모든 웹모듈에 의존성이 있다고 판단하고 모든 웹모듈을 톰캣 컨텍스트 재로드 한다
				foreach ($contextName in $modules.Values) {
					Reload-TomcatContext $contextName
				}
			}
			catch {
				Write-DeployLog "[ERROR] 컴파일 실패: $artifactId - 오류: $($_.Exception.Message)"
			}
			finally {
				Pop-Location
				$isBuilding = $false
			}
		}

		# ===== Java 감시자 설정 =====
		$javaWatcher = New-Object System.IO.FileSystemWatcher
		$javaWatcher.Path = $sourceDir
		$javaWatcher.Filter = "*.java"
		$javaWatcher.IncludeSubdirectories = $true
		$javaWatcher.EnableRaisingEvents = $true

		Register-ObjectEvent -InputObject $debounceTimer -EventName Elapsed -Action {
			Compile-Java
		} | Out-Null

		$onChanged = {
			$changedFile = $Event.SourceEventArgs.FullPath
			$changeType = $Event.SourceEventArgs.ChangeType

			# 저장되지 않은 IntelliJ 임시 파일 무시
			if ($changedFile -like "*.tmp" -or $changedFile -like "*___jb_tmp___*" -or $changedFile -like "*___jb_old___*") {
				return
			}

			if (-not (Test-Path $changedFile)) {
				Write-DeployLog "[WARN] changedFile 파일 없음: $changedFile"
				return
			}

			Write-DeployLog "[DEBUG] Java 소스 변경 감지($changeType): $changedFile"
			$debounceTimer.Stop()
			$debounceTimer.Start()
		}

		Register-ObjectEvent $javaWatcher Changed -Action $onChanged | Out-Null
		Register-ObjectEvent $javaWatcher Created -Action $onChanged | Out-Null
		Register-ObjectEvent $javaWatcher Renamed -Action $onChanged | Out-Null

		while ($true) {
			Start-Sleep -Seconds 1
		}
	}

	# 백그라운드로 감시 작업 시작
	Start-Job -ScriptBlock $script -ArgumentList $artifactId, $sourceDir, $WORKSPACE_PATH, $MAVEN_PATH, $SETTINGS_XML_PATH, $logDir, $connectorPort, $modules, $USER_NAME, $USER_PASSWORD | Out-Null

	Write-Host "[INFO] $artifactId 감시 등록 성공" -ForegroundColor Cyan
}



# ===== 모듈별 감시 설정 =====
foreach ($module in $modules.Keys) {
	$contextName = $modules[$module]
	$sourceJavaDir = Join-Path $WORKSPACE_PATH "$module\src\main\java"
	$sourceWebappDir = Join-Path $WORKSPACE_PATH "$module\src\main\webapp"
	$targetWebappDir = Join-Path $WORKSPACE_PATH "$module\target\$contextName"
	$logDir = $deployLogDir

	Write-Host "[INFO] $module 감시 등록 중..." -ForegroundColor Cyan

	# ===== 모듈별 감시기 스크립트 =====
	$script = {
		param($sourceJavaDir, $sourceWebappDir, $targetWebappDir, $module, $contextName, $WORKSPACE_PATH, $MAVEN_PATH, $SETTINGS_XML_PATH, $logDir, $connectorPort, $USER_NAME, $USER_PASSWORD)

		#auto-deploy 로그 기록
		function Write-DeployLog($message) {
			$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
			$datePart = Get-Date -Format "yyyy-MM-dd"
			$deployLogFileName = "auto-deploy.$datePart.log"
			$deployLogPath = Join-Path $logDir $deployLogFileName
			"[$timestamp] $message" | Out-File -Append -Encoding UTF8 $deployLogPath
		}

		#톰캣 컨텍스트 재로드
		function Reload-TomcatContext($contextPath) {
			$tomcatManagerUrl = "http://localhost:$connectorPort/manager/text/reload?path=/$contextPath"
			$username = $USER_NAME
			$password = $USER_PASSWORD

			$pair = "$username`:$password"
			$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))

			$headers = @{
				Authorization = "Basic $encodedAuth"
			}

			try {
				$response = Invoke-RestMethod -Uri $tomcatManagerUrl -Headers $headers -Method Get
				Write-DeployLog "톰캣 컨텍스트 재로드(/$contextPath) : $response"
			}
			catch {
				Write-DeployLog "톰캣 컨텍스트 재로드 실패(/$contextPath): $($_.Exception.Message)"
			}
		}

		# ===== 웹 리소스 복사 함수 =====
		function Copy-WebResource($filePath) {
			if (-not (Test-Path $filePath)) { return }

			$relativePath = $filePath.Substring($sourceWebappDir.Length).TrimStart('\')
			$destinationPath = Join-Path $targetWebappDir $relativePath
			$destinationDir = Split-Path $destinationPath

			# 저장되지 않은 IntelliJ 임시 파일 무시
			if ($filePath -like "*___jb_tmp___*" -or $filePath -like "*___jb_old___*" -or $filePath -like "*.tmp") {
				return
			}

			Write-DeployLog "[INFO] 웹리소스 배포 시작: $relativePath"

			try {
				if (-not (Test-Path $destinationDir)) {
					New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
				}
				Copy-Item -Path $filePath -Destination $destinationPath -Force
				Write-DeployLog "[INFO] 웹리소스 배포 완료: $relativePath"
			}
			catch {
				Write-DeployLog "[ERROR] 웹리소스 배포 실패: $relativePath - 오류: $($_.Exception.Message)"
			}
		}

		# ===== Java 컴파일 =====
		$isBuilding = $false
		$debounceJavaTimer = New-Object Timers.Timer
		$debounceJavaTimer.Interval = 3000
		$debounceJavaTimer.AutoReset = $false
		$debounceJavaTimer.Enabled = $false

		function Compile-Java($moduleName, $contextName) {
			if ($isBuilding) { return }
			$isBuilding = $true
			Write-DeployLog "[INFO] 컴파일 시작: $moduleName"

			try {
				Push-Location $WORKSPACE_PATH
				& $MAVEN_PATH compile -DskipTests -pl $moduleName -am -s $SETTINGS_XML_PATH 2>&1 | ForEach-Object {
					Write-DeployLog "[INFO] [Maven] $_"
				}
				Write-DeployLog "[INFO] 컴파일 완료: $moduleName"

				Reload-TomcatContext $contextName
			}
			catch {
				Write-DeployLog "[ERROR] 컴파일 실패: $moduleName - 오류: $($_.Exception.Message)"
			}
			finally {
				Pop-Location
				$isBuilding = $false
			}
		}

		# ===== Java 감시자 설정 =====
		$javaWatcher = New-Object System.IO.FileSystemWatcher
		$javaWatcher.Path = $sourceJavaDir
		$javaWatcher.Filter = "*.java"
		$javaWatcher.IncludeSubdirectories = $true
		$javaWatcher.EnableRaisingEvents = $true

		Register-ObjectEvent -InputObject $debounceJavaTimer -EventName Elapsed -Action {
			Compile-Java $using:module $using:contextName
		} | Out-Null

		$javaChangedAction = {
			$changedFile = $Event.SourceEventArgs.FullPath
			$changeType = $Event.SourceEventArgs.ChangeType

			# 저장되지 않은 IntelliJ 임시 파일 무시
			if ($changedFile -like "*___jb_tmp___*" -or $changedFile -like "*___jb_old___*" -or $changedFile -like "*.tmp") {
				return
			}

			Write-DeployLog "[DEBUG] Java 소스 변경 감지($changeType) - $changedFile"
			$debounceJavaTimer.Stop()
			$debounceJavaTimer.Start()
		}

		Register-ObjectEvent $javaWatcher Changed -Action $javaChangedAction | Out-Null
		Register-ObjectEvent $javaWatcher Created -Action $javaChangedAction | Out-Null
		Register-ObjectEvent $javaWatcher Renamed -Action $javaChangedAction | Out-Null

		# ===== 웹 리소스 감시자 설정 =====
		$webWatcher = New-Object System.IO.FileSystemWatcher
		$webWatcher.Path = $sourceWebappDir
		$webWatcher.Filter = "*.*"
		$webWatcher.IncludeSubdirectories = $true
		$webWatcher.EnableRaisingEvents = $true

		$copyAction = {
			$filePath = $Event.SourceEventArgs.FullPath

			# 저장되지 않은 IntelliJ 임시 파일 무시
			if ($filePath -like "*___jb_tmp___*" -or $filePath -like "*___jb_old___*" -or $filePath -like "*.tmp") {
				return
			}

			Copy-WebResource $filePath
		}

		Register-ObjectEvent $webWatcher Changed -Action $copyAction | Out-Null
		Register-ObjectEvent $webWatcher Created -Action $copyAction | Out-Null
		Register-ObjectEvent $webWatcher Renamed -Action $copyAction | Out-Null

		# ===== 루프 유지 =====
		while ($true) {
			Start-Sleep -Seconds 1
		}
	}

	Start-Job -ScriptBlock $script -ArgumentList $sourceJavaDir, $sourceWebappDir, $targetWebappDir, $module, $contextName, $WORKSPACE_PATH, $MAVEN_PATH, $SETTINGS_XML_PATH, $logDir, $connectorPort, $USER_NAME, $USER_PASSWORD | Out-Null

	Write-Host "[INFO] $module 감시 등록 성공" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[INFO] 백그라운드에서 모든 웹 모듈에 대한 실시간 감시가 시작되었습니다" -ForegroundColor Cyan
Write-Host "[INFO] 변경이 감지되면 자동으로 컴파일 및 배포됩니다" -ForegroundColor Cyan

#============================================================================================
#============================================================================================
#================================= 실시간 배포 프로세스 등록 끝 =================================
#============================================================================================
#============================================================================================




#============================================================================================
#============================================================================================
#========================================== 톰캣 시작 =========================================
#============================================================================================
#============================================================================================

# ===== Tomcat 시작 메시지 =====
Write-Host ""
Write-Host ""
Write-Host "Hello Tomcat..!!! Made by hsyoon" -ForegroundColor Green
Write-Host @"
＼　　ヽ　　　　i　　|　　　　 /　　　/　
　　　＼　
톰켓을 시작합니다...
Made by hsyoon

　　　　　　　　　　　　　　;' ':;,　　 　　　 ,;'':;,
　　　　　　　　　　　　　;'　　 ':;,.,..,,,;'　　　';,
　　ー　　　　　　　　 ,:'　　　　　　　　 　　　　::::::::､
　_＿　　　　　　　　,:' ／ 　 　　　　＼ 　　　　　::::::::',
　　　　　二　　　　:'　 ●　　　　　 ●　 　　　　　　::::::::i.
　　￣　　　　　　　i　'''　(_人__)　　''''　　 ::::::::::i
　　　　-‐　　　　　 :　 　　　　　　　　　 　　　　　::::::::i
　　　　　　　　　　　`:,､ 　　　　　 　 　　　 :::::::::: /
　　　　／　　　　　　 ,:'　　　　　　　 : ::::::::::::｀:､
　　　　　　　　　　　 ,:'　　　　　　　　 : : ::::::::::｀:､
"@ -ForegroundColor Green
Write-Host " Made By hsyoon" -ForegroundColor Magenta
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""


Start-Sleep -Seconds 5

# ===== Tomcat 시작 =====
Write-Host "[INFO] 디버깅을하려면 IDE내 debugger를 구성하세요" -ForegroundColor Cyan
Write-Host "1)Run/Debug Configurations" -ForegroundColor Magenta
Write-Host "2)Remote JVM Debug" -ForegroundColor Magenta
Write-Host "3)Debugger mode: Attach to remote JVM" -ForegroundColor Magenta
Write-Host "4)Transport: Socket" -ForegroundColor Magenta
Write-Host "5)Host: 127.0.0.1" -ForegroundColor Magenta
Write-Host "6)Port: $debugPort" -ForegroundColor Magenta
Write-Host "6)Command line arguments for remote JVM: -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$debugPort" -ForegroundColor Magenta
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
& "$TOMCAT_PATH\bin\catalina.bat" jpda run | ForEach-Object {
	if ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} FATAL") {
		Write-Host $_ -ForegroundColor Magenta
	} elseif ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} ERROR") {
		Write-Host $_ -ForegroundColor Red
	} elseif ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} WARN") {
		Write-Host $_ -ForegroundColor Yellow
	} elseif ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} INFO") {
		Write-Host $_ -ForegroundColor Green
	} elseif ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} DEBUG") {
		Write-Host $_ -ForegroundColor Cyan
	} elseif ($_ -match "^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2},\d{3} TRACE") {
		Write-Host $_ -ForegroundColor DarkGray
	} else {
		Write-Host $_
	}
}