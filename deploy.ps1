# Godot HTML5 Project Deploy Script
# Automates exporting Godot 4.x projects to the gh-pages worktree

param (
    [string]$Project,
    [string]$GodotPath,
    [switch]$Force,
    [switch]$Help,
    [switch]$Auto
)

# Show help if requested
if ($Help) {
    Write-Host @"
Godot Deploy Script - Usage:
  deploy [<project_name_or_number>] [options]

Options:
  -GodotPath <path>     Path to the Godot executable.
  -Project <name>       Force export a specific project directory (e.g., '08_balloon' or 'balloon' or '08').
  -Force                Force re-export even if the project is already exported.
  -Auto                 Auto/quick mode (accepts all defaults, commits, and pushes automatically).
  -Help                 Show this help message.

Examples:
  deploy                Check and deploy any missing projects (default behavior).
  deploy balloon        Export the balloon project.
  deploy -Auto          Automatically deploy all missing/modified projects without prompting.
  deploy 08 -Auto       Automatically deploy project 08 with default settings.
"@
    exit 0
}

# Clear screen for beautiful CLI output
Clear-Host

function Write-Header ($text) {
    Write-Host ""
    Write-Host "=== $text ===" -ForegroundColor Cyan -BackgroundColor Black
    Write-Host ""
}

function Write-Success ($text) {
    Write-Host "[SUCCESS] $text" -ForegroundColor Green
}

function Write-Info ($text) {
    Write-Host "[INFO] $text" -ForegroundColor Yellow
}

function Write-ErrorLog ($text) {
    Write-Host "[ERROR] $text" -ForegroundColor Red
}

Write-Header "Godot Game Portfolio Deployer"

# 1. Resolve Godot Executable Path
$godotExe = ""
if ($GodotPath) {
    if (Test-Path $GodotPath) {
        $godotExe = $GodotPath
    } else {
        Write-ErrorLog "Specified Godot path not found: $GodotPath"
        exit 1
    }
}

if (-not $godotExe) {
    # Try the user's specific path
    $knownPath = "C:\Users\Home\Desktop\Godot_v4.7-beta2.exe"
    if (Test-Path $knownPath) {
        $godotExe = $knownPath
    }
}

if (-not $godotExe) {
    # Search the Desktop for Godot*.exe
    Write-Info "Searching Desktop for Godot executable..."
    $desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
    $desktopGodot = Get-ChildItem -Path $desktopPath -Filter "Godot*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($desktopGodot) {
        $godotExe = $desktopGodot.FullName
    }
}

if (-not $godotExe) {
    # Check system PATH
    $pathGodot = Get-Command "godot" -ErrorAction SilentlyContinue
    if ($pathGodot) {
        $godotExe = $pathGodot.Source
    }
}

if (-not $godotExe) {
    Write-ErrorLog "Could not locate Godot executable!"
    Write-ErrorLog "Please place Godot on your Desktop or specify its path using: deploy -GodotPath <path>"
    exit 1
}

Write-Success "Found Godot Executable: $godotExe"

# 2. Setup mappings and project configurations
# Directory name in workspace -> URL-friendly folder name in gh-pages
$deployMappings = @{
    "01_Wanderer" = "wanderer"
    "02_Ricochet" = "ricochet"
    "03_fruit"    = "fruit"
    "04_pong"     = "pong"
    "05_flappy"   = "flappy"
    "06_breakout" = "breakout"
    "07_clicker"  = "cookie"
    "08_balloon"  = "balloon"
}

# Directory name in workspace -> Nice human-readable title for gh-pages/index.html
$titleMappings = @{
    "01_Wanderer" = "Wanderer"
    "02_Ricochet" = "Ricochet"
    "03_fruit"    = "Fruit Frenzy"
    "04_pong"     = "Ping Pong"
    "05_flappy"   = "Flappy Bird"
    "06_breakout" = "Breakout"
    "07_clicker"  = "Cookie Clicker"
    "08_balloon"  = "Pop a Balloon"
}

# 3. Find and scan Godot projects
$projectDirs = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -match '^\d+_' } | Sort-Object Name

if ($projectDirs.Count -eq 0) {
    Write-ErrorLog "No Godot project directories found (e.g. '08_balloon') in $PSScriptRoot!"
    exit 1
}

# Determine if we are in interactive mode (i.e. no specific project argument provided and no auto mode)
$isInteractive = $true
if ($Project -or $Auto) {
    $isInteractive = $false
}

# Filter by user selection
$targetProjects = @()
if (-not $isInteractive) {
    if ($Project) {
        Write-Info "Searching for project matching: '$Project'..."
        foreach ($dir in $projectDirs) {
            if ($dir.Name -like "*$Project*" -or $deployMappings[$dir.Name] -like "*$Project*") {
                $targetProjects += $dir
            }
        }
        if ($targetProjects.Count -eq 0) {
            Write-ErrorLog "No project directory matches '$Project'!"
            exit 1
        }
    } else {
        # Auto mode without a specified project: find all missing/out-of-date projects
        Write-Info "Auto mode: Scanning for missing or outdated projects..."
        $missingProjects = @()
        foreach ($dir in $projectDirs) {
            $deployName = $deployMappings[$dir.Name]
            if (-not $deployName) {
                $deployName = ($dir.Name -replace '^\d+_', '').ToLower()
            }
            $indexPath = Join-Path $PSScriptRoot "gh-pages\$deployName\index.html"
            
            $isOutdated = $false
            if (-not (Test-Path $indexPath)) {
                $isOutdated = $true
            } else {
                $exportTime = (Get-Item $indexPath).LastWriteTime
                $sourceFiles = Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                               Where-Object { $_.FullName -notmatch '\\\.godot\\' -and $_.Name -ne 'export_presets.cfg' }
                $lastSourceWrite = $null
                if ($sourceFiles) {
                    $lastSourceWrite = ($sourceFiles | Measure-Object -Property LastWriteTime -Maximum).Maximum
                }
                if ($lastSourceWrite -and $lastSourceWrite -gt $exportTime) {
                    $isOutdated = $true
                }
            }
            if ($isOutdated) {
                $missingProjects += $dir
            }
        }
        $targetProjects = $missingProjects
    }
} else {
    # Interactive project selection menu
    Write-Header "Project Selection Menu"
    
    $missingProjects = @()
    
    for ($i = 0; $i -lt $projectDirs.Count; $i++) {
        $dir = $projectDirs[$i]
        $deployName = $deployMappings[$dir.Name]
        if (-not $deployName) {
            $deployName = ($dir.Name -replace '^\d+_', '').ToLower()
        }
        
        $indexPath = Join-Path $PSScriptRoot "gh-pages\$deployName\index.html"
        
        $status = "Up-to-date"
        if (-not (Test-Path $indexPath)) {
            $status = "Missing/Not Exported"
            $missingProjects += $dir
        } else {
            # Check if any source file in the project has been modified after the last export
            $exportTime = (Get-Item $indexPath).LastWriteTime
            
            # Find the most recently modified source file, excluding the .godot directory and export_presets.cfg
            $sourceFiles = Get-ChildItem -Path $dir.FullName -Recurse -File -ErrorAction SilentlyContinue | 
                           Where-Object { $_.FullName -notmatch '\\\.godot\\' -and $_.Name -ne 'export_presets.cfg' }
            
            $lastSourceWrite = $null
            if ($sourceFiles) {
                $lastSourceWrite = ($sourceFiles | Measure-Object -Property LastWriteTime -Maximum).Maximum
            }
            
            if ($lastSourceWrite -and $lastSourceWrite -gt $exportTime) {
                $status = "Outdated / Modified"
                $missingProjects += $dir
            }
        }
        
        $title = $titleMappings[$dir.Name]
        if (-not $title) {
            # Try reading project.godot config/name
            $projectGodotPath = Join-Path $dir.FullName "project.godot"
            if (Test-Path $projectGodotPath) {
                $godotContent = Get-Content $projectGodotPath -Raw
                if ($godotContent -match 'config/name="([^"]+)"') {
                    $title = $Matches[1]
                }
            }
            if (-not $title) {
                $title = (Get-Culture).TextInfo.ToTitleCase($deployName)
            }
        }
        
        Write-Host "  [$($i + 1)] $($dir.Name) - $title ($status)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "  [0] Deploy all missing/not exported projects ($($missingProjects.Count) found)" -ForegroundColor Cyan
    Write-Host "  [F] Fast/Auto Mode - Deploy missing/outdated projects automatically with all defaults" -ForegroundColor Green
    Write-Host "  [A] Force rebuild & deploy ALL projects ($($projectDirs.Count) found)" -ForegroundColor Yellow
    Write-Host "  [Q] Quit" -ForegroundColor Red
    Write-Host ""
    
    $selection = Read-Host "Choose an option [Default: 0]"
    $selection = $selection.Trim().ToUpper()
    if (-not $selection) {
        $selection = "0"
    }
    
    if ($selection -eq 'Q') {
        Write-Info "Exiting deploy script."
        exit 0
    } elseif ($selection -eq 'A') {
        $targetProjects = $projectDirs
        $Force = $true
    } elseif ($selection -eq 'F') {
        if ($missingProjects.Count -eq 0) {
            Write-Success "All projects are already exported! (Choose specific number or 'A' to rebuild anyway)"
            exit 0
        }
        $targetProjects = $missingProjects
        $Auto = $true
        $isInteractive = $false
    } elseif ($selection -eq '0') {
        if ($missingProjects.Count -eq 0) {
            Write-Success "All projects are already exported! (Choose specific number or 'A' to rebuild anyway)"
            exit 0
        }
        $targetProjects = $missingProjects
    } else {
        if ([int]::TryParse($selection, [ref]$index) -and $index -gt 0 -and $index -le $projectDirs.Count) {
            $targetProjects = @($projectDirs[$index - 1])
            
            # Offer to force export if already exists
            $deployName = $deployMappings[$targetProjects[0].Name]
            if (-not $deployName) {
                $deployName = ($targetProjects[0].Name -replace '^\d+_', '').ToLower()
            }
            $indexPath = Join-Path $PSScriptRoot "gh-pages\$deployName\index.html"
            if (Test-Path $indexPath) {
                $forceResponse = Read-Host "Project already exported. Force re-export? (y/n) [Default: y]"
                if ($forceResponse.Trim().ToLower() -eq 'n') {
                    Write-Info "Skipping export. Project is already exported."
                    exit 0
                } else {
                    $Force = $true
                }
            }
        } else {
            Write-ErrorLog "Invalid selection!"
            exit 1
        }
    }
}

if ($targetProjects.Count -eq 0) {
    Write-Success "No projects selected or all projects are already exported!"
    exit 0
}

Write-Info ("Found " + $targetProjects.Count + " project(s) to deploy: " + ($targetProjects.Name -join ", "))

# Track exported project titles for the final commit message
$exportedTitles = @()

# 4. Process each target project
foreach ($projectDir in $targetProjects) {
    $dirName = $projectDir.Name
    $deployName = $deployMappings[$dirName]
    if (-not $deployName) {
        $deployName = ($dirName -replace '^\d+_', '').ToLower()
    }
    
    $projectTitle = $titleMappings[$dirName]
    if (-not $projectTitle) {
        # Fallback: try parsing project.godot for config/name
        $projectGodotPath = Join-Path $projectDir.FullName "project.godot"
        if (Test-Path $projectGodotPath) {
            $godotContent = Get-Content $projectGodotPath -Raw
            if ($godotContent -match 'config/name="([^"]+)"') {
                $projectTitle = $Matches[1]
            }
        }
        if (-not $projectTitle) {
            # Ultimate fallback: titlecase of deployName
            $projectTitle = (Get-Culture).TextInfo.ToTitleCase($deployName)
        }
    }

    # If running interactively, allow modifying metadata and choosing portfolio inclusion
    $addToPortfolio = $true
    if ($isInteractive) {
        Write-Header "Configure Metadata for: $dirName"
        $userInputTitle = Read-Host "Game Title [Default: '$projectTitle']"
        $userInputTitle = $userInputTitle.Trim()
        if ($userInputTitle) {
            $projectTitle = $userInputTitle
        }
        
        $userInputSlug = Read-Host "URL Folder Name (lowercase, no spaces) [Default: '$deployName']"
        $userInputSlug = $userInputSlug.Trim().ToLower()
        if ($userInputSlug) {
            $deployName = $userInputSlug
        }
        
        $portfolioResponse = Read-Host "Add this game to the main portfolio index.html list? (y/n) [Default: y]"
        if ($portfolioResponse.Trim().ToLower() -eq 'n') {
            $addToPortfolio = $false
        }
    }

    Write-Header "Deploying: $dirName -> gh-pages/$deployName ($projectTitle)"

    # A. Check and generate export_presets.cfg if missing
    $presetsPath = Join-Path $projectDir.FullName "export_presets.cfg"
    if (-not (Test-Path $presetsPath)) {
        Write-Info "Creating missing export_presets.cfg for Web export..."
        $presetContent = @"
[preset.0]

name="Web"
platform="Web"
runnable=true
dedicated_server=false
custom_features=""
export_filter="all_resources"
export_path="web_build/index.html"

[preset.0.options]

custom_template/debug=""
custom_template/release=""
variant/extensions_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
progressive_web_app/enabled=false
"@
        [System.IO.File]::WriteAllText($presetsPath, $presetContent)
        Write-Success "Created export_presets.cfg"
    }

    # B. Prepare gh-pages output directory
    $exportDir = Join-Path $PSScriptRoot "gh-pages\$deployName"
    if (-not (Test-Path $exportDir)) {
        New-Item -ItemType Directory -Path $exportDir | Out-Null
        Write-Info "Created export folder: gh-pages/$deployName"
    }

    $exportIndexPath = Join-Path $exportDir "index.html"

    # C. Run Godot Web export
    Write-Info "Running Godot Web export (headless)..."
    $exportArgs = @(
        "--headless",
        "--path", $projectDir.FullName,
        "--export-release", "Web",
        $exportIndexPath
    )

    # Launch Godot synchronously, suppressing messy beta logs via temp redirect files
    $outTemp = Join-Path $env:TEMP "godot_export_out.log"
    $errTemp = Join-Path $env:TEMP "godot_export_err.log"
    
    $process = Start-Process -FilePath $godotExe -ArgumentList $exportArgs -NoNewWindow -Wait -PassThru -RedirectStandardOutput $outTemp -RedirectStandardError $errTemp
    
    if ($process.ExitCode -ne 0) {
        Write-ErrorLog "Godot export failed with exit code $($process.ExitCode)!"
        if (Test-Path $errTemp) {
            $errContent = Get-Content $errTemp -Raw
            if ($errContent) {
                Write-ErrorLog "Godot Error Output:"
                Write-Host $errContent -ForegroundColor Red
            }
        }
        if (Test-Path $outTemp) {
            $outContent = Get-Content $outTemp -Raw
            if ($outContent) {
                Write-ErrorLog "Godot Standard Output:"
                Write-Host $outContent -ForegroundColor Gray
            }
        }
    }

    # Clean up temp files if they exist
    if (Test-Path $outTemp) { Remove-Item $outTemp -Force | Out-Null }
    if (Test-Path $errTemp) { Remove-Item $errTemp -Force | Out-Null }

    if ($process.ExitCode -ne 0) {
        continue
    }

    Write-Success "Project exported successfully to gh-pages/$deployName/"

    $exportedTitles += $projectTitle

    # D. Update portfolio source data and rebuild the React/shadcn index page
    if ($addToPortfolio) {
        $gamesDataPath = Join-Path $PSScriptRoot "portfolio-src\src\data\games.ts"
        if (-not (Test-Path $gamesDataPath)) {
            Write-Warning "portfolio-src\src\data\games.ts not found - skipping portfolio update."
        } else {
            $numberPrefix = "99"
            if ($dirName -match '^(\d+)') { $numberPrefix = $Matches[1] }
            $intNumber = [int]$numberPrefix

            # Build a short one-line description based on the title
            $descriptionMap = @{
                "Wanderer"       = "Top-down exploration with smooth tile-based movement."
                "Ricochet"       = "Bounce projectiles off walls to hit targets."
                "Fruit Frenzy"   = "Catch falling fruit before it hits the ground."
                "Ping Pong"      = "Classic two-paddle pong with velocity-based physics."
                "Flappy Bird"    = "Navigate through gaps - simple input, brutal difficulty."
                "Breakout"       = "Destroy all bricks with a bouncing ball and paddle."
                "Cookie Clicker" = "Idle clicking game with upgrades and passive income."
                "Pop a Balloon"  = "Pop balloons as fast as you can before time runs out."
                "3D Ball"        = "Roll a ball through a 3D environment."
            }
            $description = $descriptionMap[$projectTitle]
            if (-not $description) { $description = "Assignment $intNumber game." }

            $gamesContent = [System.IO.File]::ReadAllText($gamesDataPath)

            # Check if this game is already in games.ts
            $hrefPattern = 'href: "' + $deployName + '/index.html"'
            if ($gamesContent -match [regex]::Escape($hrefPattern)) {
                Write-Info "Game '$projectTitle' already in games.ts - skipping."
            } else {
                Write-Info "Adding '$projectTitle' to games.ts..."

                # Build the new entry using string concatenation to avoid here-string quoting issues
                $q = '"'
                $newEntry  = "`n  {`n"
                $newEntry += "    number: $intNumber,`n"
                $newEntry += "    title: $q$projectTitle$q,`n"
                $newEntry += "    description: $q$description$q,`n"
                $newEntry += "    href: $q$deployName/index.html$q,`n"
                $newEntry += '    tags: ["2D"],' + "`n"
                $newEntry += "  },"

                # Insert the new entry before the closing ]; of the games array (on its own line)
                $gamesContent = $gamesContent -replace '(?m)^(\];)', ($newEntry + "`n" + '$1')
                [System.IO.File]::WriteAllText($gamesDataPath, $gamesContent)
                Write-Success "Added '$projectTitle' to games.ts!"
            }

            # Rebuild the portfolio React app
            Write-Info "Rebuilding portfolio (npm run build)..."
            $portfolioSrcPath = Join-Path $PSScriptRoot "portfolio-src"
            $buildProcess = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "npm run build" -WorkingDirectory $portfolioSrcPath -NoNewWindow -Wait -PassThru
            if ($buildProcess.ExitCode -ne 0) {
                Write-ErrorLog "Portfolio build failed! Check portfolio-src for errors."
            } else {
                # Copy fresh build output to gh-pages root
                $distPath = Join-Path $portfolioSrcPath "dist\*"
                $ghPagesPath = Join-Path $PSScriptRoot "gh-pages"
                Copy-Item -Path $distPath -Destination $ghPagesPath -Recurse -Force
                Write-Success "Portfolio rebuilt and copied to gh-pages/!"
            }
        }
    } else {
        Write-Info "Skipping portfolio rebuild for this game."
    }
}

# 5. Git Status and Deployment Interaction
Write-Header "Deployment and Git Status"
$gitDir = Join-Path $PSScriptRoot "gh-pages"

if (Test-Path (Join-Path $gitDir ".git")) {
    $changes = git -C $gitDir status --porcelain
    if ($changes) {
        Write-Info "Uncommitted changes detected in gh-pages worktree:"
        Write-Host $changes -ForegroundColor Gray
        
        Write-Host ""
        $response = "y"
        if (-not $Auto) {
            $response = Read-Host "Do you want to commit these changes to deploy? (y/n) [Default: y]"
        }
        if ($response.Trim().ToLower() -ne 'n') {
            # Construct a dynamic default commit message based on exported games
            $defaultMsg = "deploy: automated Godot project export"
            if ($exportedTitles.Count -gt 0) {
                $defaultMsg = "deploy: export " + ($exportedTitles -join ", ")
            }
            
            $commitMsg = ""
            if (-not $Auto) {
                $commitMsg = Read-Host "Enter deployment commit message [Default: '$defaultMsg']"
                $commitMsg = $commitMsg.Trim()
            }
            if (-not $commitMsg) {
                $commitMsg = $defaultMsg
            }
            
            Write-Info "Adding and committing changes..."
            git -C $gitDir add -A
            git -C $gitDir commit -m $commitMsg
            
            $pushResponse = "y"
            if (-not $Auto) {
                $pushResponse = Read-Host "Push to GitHub Pages now? (y/n) [Default: y]"
            }
            if ($pushResponse.Trim().ToLower() -ne 'n') {
                Write-Info "Pushing to remote repository..."
                git -C $gitDir push origin HEAD:gh-pages
                if ($LASTEXITCODE -ne 0) {
                    Write-ErrorLog "Failed to push changes to remote repository! (Exit code: $LASTEXITCODE)"
                } else {
                    Write-Success "Deployment pushed and completed!"
                }
            } else {
                Write-Info "Skipping push. Changes committed locally."
            }
        } else {
            Write-Info "Skipping git commit/push. Build completed locally."
        }
    } else {
        Write-Success "No changes in gh-pages worktree. Everything up to date!"
    }
} else {
    Write-Warning "gh-pages is not a Git repository worktree. Skipping Git deploy."
}

# 6. Outer Repository Git Status and Commit Interaction
Write-Header "Outer Repository Git Status"
if (Test-Path (Join-Path $PSScriptRoot ".git")) {
    $outerChanges = git -C $PSScriptRoot status --porcelain
    if ($outerChanges) {
        Write-Info "Uncommitted changes/untracked files detected in outer repository:"
        Write-Host $outerChanges -ForegroundColor Gray
        
        Write-Host ""
        $outerResponse = "y"
        if (-not $Auto) {
            $outerResponse = Read-Host "Do you want to commit these outer repository changes? (y/n) [Default: y]"
        }
        if ($outerResponse.Trim().ToLower() -ne 'n') {
            # Construct a dynamic default outer repository commit message
            $defaultOuterMsg = "update games"
            if ($exportedTitles.Count -gt 0) {
                $defaultOuterMsg = "update: export " + ($exportedTitles -join ", ")
            }
            
            $msg = ""
            if (-not $Auto) {
                $msg = Read-Host "Enter commit message [Default: '$defaultOuterMsg']"
                $msg = $msg.Trim()
            }
            if (-not $msg) {
                $msg = $defaultOuterMsg
            }
            
            Write-Info "Adding and committing outer changes..."
            git -C $PSScriptRoot add -A
            git -C $PSScriptRoot commit -m $msg
            
            $outerPushResponse = "y"
            if (-not $Auto) {
                $outerPushResponse = Read-Host "Push outer changes to remote now? (y/n) [Default: y]"
            }
            if ($outerPushResponse.Trim().ToLower() -ne 'n') {
                Write-Info "Pushing outer changes to remote..."
                $currentBranch = git -C $PSScriptRoot branch --show-current
                if (-not $currentBranch) { $currentBranch = "master" }
                git -C $PSScriptRoot push origin $currentBranch
                if ($LASTEXITCODE -ne 0) {
                    Write-ErrorLog "Failed to push outer changes to remote repository! (Exit code: $LASTEXITCODE)"
                } else {
                    Write-Success "Outer repository changes committed and pushed successfully!"
                }
            } else {
                Write-Info "Skipping outer repository push. Changes committed locally."
            }
        } else {
            Write-Info "Skipping outer repository commit/push."
        }
    } else {
        Write-Success "No changes in outer repository. Everything up to date!"
    }
}

Write-Host ""
Write-Success "Deployment run completed!"
