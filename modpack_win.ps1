#
# KSPtoMars Windows Modpack v1.7.2-dev
#

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
  [string]$k,
  [switch]$b,
  [switch]$c,
  [switch]$f
)
$BackupPath = [guid]::NewGuid().Guid
$startingPath = $PWD
$gameDataPath = "$k/GameData"
$ksp2mModsPath = "$k/ksp2m_mods"

#Definition of function for easy unzipping later on
function unzip($file, $targetDir) {
  Add-Type -assembly "system.io.compression.filesystem"
  [io.compression.zipfile]::ExtractToDirectory($file, $targetDir)
}

# Function for downloading files in arrays.
$ErrorActionPreference= 'silentlycontinue'
function download($array) {
  $status = $True
  for($i=0;$i -lt $array.length;$i++){
    if ($status){$errorcount = 0}
    Write-Output "[$($i+1) of $($array.length)]: $($array[$i][1])"
    Invoke-WebRequest -Uri $array[$i][0] -OutFile $array[$i][1] -ErrorVariable +err
    if (-not $?) {
      $status = $?
      $errorcount = $errorcount + 1
      if ($errorcount -lt 3){
        Write-Output "Failed to download $($array[$i][1]). Trying again.`r`n"
      }else{
        Write-Output "Failed to download $($array[$i][1]) three (3) consecutive times. `r`n`r`nPlease make sure you have an internet connection and the newest version`r`nof the KSPtoMars mod installer. `r`nThe error message was: `r`n`r`n$($err[$($err.lenght - 1)])"
        rollback($BackupPath)
      }
      $i = $i - 1
    }
  }
}

# Rollback function
function rollback($RPATH){
  Remove-Item -Recurse -Force $gameDataPath
  new-item -itemtype directory $gameDataPath > $null
  new-item -itemtype directory $gameDataPath/Squad > $null
  Move-Item -Recurse $RPATH $gameDataPath/Squad
  exit
}


Write-Output "`r`nThis is v1.7.2-dev of the ksp2mars modpack script for windows.`r`n`r`n"

if (Test-Path $gameDataPath/Squad) {
  Set-Location $k
  Write-Output "Creating backup...`r`n"
  Move-Item $gameDataPath/Squad $BackupPath
  Remove-Item -Recurse -Force $gameDataPath
  new-item -itemtype directory $gameDataPath > $null
  Copy-Item -Recurse $BackupPath $gameDataPath/Squad
}else{
  Write-Output "The specified path does not seem to contain a valid install of KSP."
  exit
}

# Create folders
if (Test-Path $ksp2mModsPath){
  Remove-Item -Recurse -Force $ksp2mModsPath
}

new-item -itemtype directory $ksp2mModsPath > $null
Set-Location $ksp2mModsPath

If ($b) {
  Write-Output "Preparing beauty install."
}ElseIf ($c){
  Write-Output "Preparing base install."
}ElseIf ($f){
  Write-Output "Preparing full install."
}Else{
  Write-Output "Preparing developer install."
}

# Download base mods!
Write-Output "`r`nDownloading all mods. This will take a while."

$baseModPack = @(
  @("http://kerbalstuff.com/mod/361/NEBULA%20Decals/download/1.01", "NebulaDecals.zip"),                                                                    #KSP v0.25
  @("http://github.com/NathanKell/CrossFeedEnabler/releases/download/v3.3/CrossFeedEnabler_v3.3.zip", "CrossFeedEnabler.zip"),                              #KSP v1.0
  @("http://github.com/Starwaster/DeadlyReentry/releases/download/v7.1.0/DeadlyReentry_7.1.0_The_Melificent_Edition.zip", "DeadlyReentry.zip"),             #KSP v1.0
  @("http://github.com/codepoetpbowden/ConnectedLivingSpace/releases/download/1.1.3.1/Connected_Living_Space-1.1.3.1.zip", "Connected_Living_Space.zip"),   #KSP v1.0.2
  @("http://beta.kerbalstuff.com/mod/67/KW%20Rocketry/download/2.7", "KWRocketry.zip"),                                                                     #KSP v1.0.2
  @("http://kerbalstuff.com/mod/26/NovaPunch/download/2.09", "NovaPunch2.zip"),                                                                             #KSP v1.0.2
  @("http://kerbalstuff.com/mod/71/RealChute%20Parachute%20Systems/download/1.3.2.3", "RealChute.zip"),                                                     #KSP v1.0.2
  @("http://github.com/Crzyrndm/RW-Saturatable/releases/download/1.10.1/Saturatable.RW.v1.10.1.0.zip", "Saturatable.RW.zip"),                               #KSP v1.0.2
  @("http://github.com/taraniselsu/TacLifeSupport/releases/download/v0.11.1.20/TacLifeSupport_0.11.1.20.zip", "TacLifeSupport.zip"),                        #KSP v1.0.2
  @("http://blizzy.de/toolbar/Toolbar-1.7.9.zip", "Toolbar.zip"),                                                                                           #KSP v1.0.2
  @("http://kerbal.curseforge.com/ksp-mods/228561-kerbal-inventory-system-kis/files/2240842/download", "KIS.zip"),                                          #KSP v1.0.2
  @("http://kerbal.curseforge.com/ksp-mods/223900-kerbal-attachment-system-kas/files/2240844/download", "KAS.zip"),                                         #KSP v1.0.2
  @("http://github.com/UbioWeldingLtd/UbioWeldContinued/releases/download/2.1.3/UbioWeldContinued-2.1.3.zip", "UbioWeldContinued.zip"),                     #KSP v1.0.2
  @("http://kerbalstuff.com/mod/668/PersistentRotation/download/0.5.3", "PersistentRotation.zip"),                                                          #KSP v1.0.2
  @("http://kerbalstuff.com/mod/450/Hullcam%20VDS/download/0.40", "HullcaMove-ItemDS.zip"),                                                                 #KSP v1.0.2
  @("http://dl.orangedox.com/ilvCeXLsPxxWNdz1VY/JDiminishingRTG_v1.3a.zip?dl=1", "JDiminishingRTG.zip"),                                                    #KSP v1.0.2
  @("http://github.com/ferram4/BetterBuoyancy/releases/download/v1.3/BetterBuoyancy_v1.3.zip", "BetterBuoyancy.zip"),                                       #KSP v1.0.3
  @("http://github.com/ferram4/Ferram-Aerospace-Research/releases/download/v0.15_3_1_Garabedian/FAR_0_15_3_1_Garabedian.zip", "FAR.zip"),                   #KSP v1.0.3
  @("http://github.com/ferram4/Kerbal-Joint-Reinforcement/releases/download/v3.1.4/KerbalJointReinforcement_v3.1.4.zip", "KerbalJointReinforcement.zip"),   #KSP v1.0.3
  @("http://github.com/KSP-RO/RSS-Textures/releases/download/v10.0/2048.zip", "2048.zip"),                                                                  #KSP v?.?.?
  @("http://github.com/BobPalmer/MKS/releases/download/0.31.4/UKS_0.31.4.zip", "UKS.zip"),                                                                  #KSP v?.?.?
  @("http://ksptomars.org/public/HabitatPack_04.1.zip", "HabitatPack.zip"),                                                                                 #KSP v?.?.?
  @("http://ksptomars.org/public/AIES_Aerospace151.zip", "AIES_Aerospace151.zip"),                                                                          #KSP v?.?.?
  @("http://dl.dropboxusercontent.com/u/72893034/AIES_Patches/AIES_Node_Patch.cfg.zip", "AIES_Node_Patch.cfg.zip"),                                         #KSP v?.?.?
  @("http://ksptomars.org/public/KSPtoMars.zip", "KSPtoMars.zip"),                                                                                          #KSP v?.?.?
  @("http://github.com/Mihara/RasterPropMonitor/releases/download/v0.21.0/RasterPropMonitor.0.21.0.zip", "RasterPropMonitor.zip"),                          #KSP v1.0.4
  @("http://github.com/camlost2/AJE/releases/download/2.2.1/Advanced_Jet_Engine-2.2.1.zip", "Advanced_Jet_Engine.zip"),                                     #KSP v1.0.4
  @("http://kerbalstuff.com/mod/27/FASA/download/5.35", "FASA.zip"),                                                                                        #KSP v1.0.4
  @("http://kerbal.curseforge.com/ksp-mods/220462-ksp-avc-add-on-version-checker/files/2216818/download", "ksp-avc.zip"),                                   #KSP v1.0.4
  @("http://github.com/KSP-RO/SolverEngines/releases/download/v1.5/SolverEngines_v1.5.zip", "SolverEngines.zip"),                                           #KSP v1.0.4
  @("http://github.com/e-dog/ProceduralFairings/releases/download/v3.15/ProcFairings_3.15.zip", "ProcFairings.zip"),                                        #KSP v1.0.4
  @("http://github.com/NathanKell/ModularFuelSystem/releases/download/rf-v10.4.4/RealFuels_v10.4.4.zip", "RealFuels.zip"),                                  #KSP v1.0.4
  @("http://github.com/KSP-RO/RealismOverhaul/releases/download/v10.1.0/RealismOverhaul-v10.1.0.zip", "RealismOverhaul.zip"),                               #KSP v1.0.4
  @("http://github.com/KSP-RO/RealSolarSystem/releases/download/v10.1/RealSolarSystem_v10.1.zip", "RealSolarSystem.zip"),                                   #KSP v1.0.4
  @("http://github.com/RemoteTechnologiesGroup/RemoteTech/releases/download/1.6.7/RemoteTech-1.6.7.zip", "RemoteTech.zip"),                                 #KSP v1.0.4
  @("http://github.com/ducakar/TextureReplacer/releases/download/v2.4.7/TextureReplacer-2.4.7.zip", "TextureReplacer.zip"),                                 #KSP v1.0.4
  @("http://kerbal.curseforge.com/ksp-mods/220213-taurus-hcv-3-75-m-csm-system/files/2244776/download", "Taurus.zip"),                                      #KSP v1.0.4
  @("http://github.com/DMagic1/Orbital-Science/releases/download/v1.0.7/DMagic_Orbital_Science-1.0.7.zip", "DMagic_Orbital_Science.zip"),                   #KSP v1.0.4
  @("http://github.com/timmersuk/Timmers_KSP/releases/download/0.7.3.3/KeepFit-0.7.3.3.zip", "KeepFit.zip"),                                                #KSP v1.0.4
  @("http://kerbalstuff.com/mod/8/Magic%20Smoke%20Industries%20Infernal%20Robotics/download/0.21.3", "InfernalRobotics.zip"),                               #KSP v1.0.4
  @("http://github.com/ClawKSP/KSP-Stock-Bug-Fix-Modules/releases/download/v1.0.4a.1/StockBugFixModules.v1.0.4a.1.zip", "StockBugFixModules.zip"),          #KSP v1.0.4
  @("http://github.com/ClawKSP/KSP-Stock-Bug-Fix-Modules/releases/download/v1.0.4a.1/StockPlusController.zip", "StockPlusController.cfg"),                  #KSP v1.0.4
  @("http://github.com/KSP-KOS/KOS/releases/download/v0.17.3/kOS-v0.17.3.zip", "kOS.zip"),                                                                  #KSP v1.0.4
  @("http://kerbalstuff.com/mod/250/Universal%20Storage/download/1.1.0.6", "UniversalStorage.zip"),                                                         #KSP v1.0.4
  @("http://kerbalstuff.com/mod/344/TweakScale%20-%20Rescale%20Everything%21/download/v2.2.1", "TweakScale.zip"),                                           #KSP v1.0.4
  @("http://kerbalstuff.com/mod/515/B9%20Aerospace%20Procedural%20Parts/download/0.40", "B9ProcParts.zip"),                                                 #KSP v1.0.4
  @("http://kerbalstuff.com/mod/255/TweakableEverything/download/1.12", "TweakableEverything.zip"),                                                         #KSP v1.0.4
  @("http://github.com/Swamp-Ig/ProceduralParts/releases/download/v1.1.6/ProceduralParts-1.1.6.zip", "ProceduralParts.zip"),                                #KSP v1.0.4
  @("https://ksp.sarbian.com/jenkins/job/ModularFlightIntegrator/9/artifact/ModularFlightIntegrator-1.1.1.0.zip", "ModularFlightIntegrator.zip"),           #KSP v1.0.4
  @("http://github.com/KSP-RO/RealHeat/releases/download/v1.0/RealHeat_v1.0.zip", "RealHeat.zip"),                                                          #KSP v1.0.4
  @("http://github.com/BobPalmer/CommunityResourcePack/releases/download/0.4.3/CRP_0.4.3.zip", "CRP.zip")                                                   #KSP v1.0.4
)

Write-Output "`r`nDownloading Base Mods."
download($baseModPack)

# Dev mods!
if (-not $b -and -not $c){
  $devModPack = @(
    @("http://github.com/snjo/FShangarExtender/releases/download/v3.3/FShangarExtender_3_3.zip", "FShangarExtender.zip"),                                   #KSP v1.0
    @("http://kerbalstuff.com/mod/414/StripSymmetry/download/v1.6", "StripSymmetry.zip"),                                                                   #KSP v1.0
    @("http://kerbal.curseforge.com/ksp-mods/220602-rcs-build-aid/files/2243090/download", "RCSbuildAid.zip"),                                              #KSP v1.0.2
    @("http://kerbalstuff.com/mod/731/Vessel%20Viewer/download/0.71", "VesselViewer.zip"),                                                                  #KSP v1.0.2
    @("http://github.com/Crzyrndm/FilterExtension/releases/download/2.3.0/Filter.Extensions.v2.3.0.1.zip", "Filter.Extensions.zip"),                        #KSP v1.0.3
    @("http://github.com/MachXXV/EditorExtensions/releases/download/v2.12/EditorExtensions_v2.12.zip", "EditorExtensions.zip"),                             #KSP v1.0.3
    @("http://ksptomars.org/public/HyperEdit-1.4.1_for-KSP-1.0.zip", "HyperEdit.zip"),                                                                      #KSP v?.?.?
    @("http://kerbal.curseforge.com/ksp-mods/220530-part-wizard/files/2246104/download", "PartWizard.zip"),                                                 #KSP v1.0.4
    @("http://kerbal.curseforge.com/ksp-mods/220221-mechjeb/files/2245658/download", "mechjeb2.zip"),                                                       #KSP v1.0.4
    @("http://github.com/nodrog6/LightsOut/releases/download/v0.1.4/LightsOut-v0.1.4.zip", "LightsOut.zip"),                                                #KSP v1.0.4
    @("https://github.com/CYBUTEK/KerbalEngineer/releases/download/1.0.17.0/KerbalEngineer-1.0.17.0.zip", "KerbalEngineer.zip"),                            #KSP v1.0.4
    @("http://kerbalstuff.com/mod/776/Take%20Command/download/1.1.4", "TakeCommand.zip"),                                                                   #KSP v1.0.4
    @("http://github.com/malahx/QuickSearch/releases/download/v1.13/QuickSearch-1.13.zip", "QuickSearch.zip"),                                              #KSP v1.0.x
    @("http://github.com/malahx/QuickScroll/releases/download/v1.31/QuickScroll-1.31.zip", "QuickScroll.zip")                                               #KSP v1.0.x
  )

  Write-Output "`r`nDownloading Dev Mods."
  download($devModPack)
}

# Beauty mods!
if ($b -or $f){
  Remove-Item -force 2048.zip #Remove low resolution RSS textures.

  $beautyModPack = @(
    @("http://kerbal.curseforge.com/ksp-mods/224876-planetshine/files/2237465/download", "PlanetShine.zip"),                                                #KSP v1.0
    @("http://kerbalstuff.com/mod/224/Rover%20Wheel%20Sounds/download/1.2", "RoverWheelSounds.zip"),                                                        #KSP v1.0
    @("http://kerbalstuff.com/mod/190/Camera%20Tools/download/v1.3", "CameraTools.zip"),                                                                    #KSP v1.0.2
    @("http://kerbalstuff.com/mod/381/Collision%20FX/download/3.2", "CollisionFX.zip"),                                                                     #KSP v1.0.2
    @("http://kerbalstuff.com/mod/700/Scatterer/download/0.151", "Scatterer.zip"),                                                                          #KSP v1.0.2
    @("http://github.com/KSP-RO/RSS-Textures/releases/download/v10.0/8192.zip", "8192.zip"),                                                                #KSP v?.?.?
    @("http://github.com/MOARdV/DistantObject/releases/download/v1.5.7/DistantObject_1.5.7.zip", "DistantObject.zip"),                                      #KSP v1.0.4
    @("http://beta.kerbalstuff.com/mod/124/Chatterer/download/0.9.5", "Chatterer.zip"),                                                                     #KSP v1.0.4
    @("http://kerbalstuff.com/mod/817/EngineLighting/download/1.4.0", "EngineLighting.zip"),                                                                #KSP v1.0.4
    @("http://kerbal.curseforge.com/ksp-mods/220207-hotrockets-particle-fx-replacement/files/2244672/download", "hotrocket.zip"),                           #KSP v1.0.4
    @("http://kerbalstuff.com/mod/743/Improved%20Chase%20Camera/download/v1.5.1", "ImprovedChaseCam.zip"),                                                  #KSP v1.0.4
    @("http://github.com/richardbunt/Telemachus/releases/download/v1.4.30.0/Telemachus_1_4_30_0.zip", "Telemachus.zip"),                                    #KSP v1.0.4 
    @("https://ksp.sarbian.com/jenkins/job/SmokeScreen/44/artifact/SmokeScreen-2.6.6.0.zip", "SmokeScreen.zip"),                                            #KSP v1.0.x
    @("http://github.com/HappyFaceIndustries/BetterTimeWarp/releases/download/2.0/BetterTimeWarp_2.0.zip", "BetterTimeWarp.zip")                            #KSP v1.0.x
  )

  Write-Output "`r`nDownloading Beauty Mods."
  download($beautyModPack)
}

# Unzip all the mods
Write-Output "`r`nExtracting Mods"
$childItems = Get-ChildItem $ksp2mModsPath -Filter *.zip
$index = 0
$childItems |
foreach-Object {
  $index = $index + 1
  $dirname = $_.FullName | %{$_ -replace ".zip",""}
  new-item -itemtype directory $dirname > $null
  if ($?){
    Write-Output "[$index of $($childItems.count)]: $_"
    unzip $_.FullName $dirname > $null
  }else{  
    Write-Output "Could not unpack $_ - new-item -itemtype directory failed"
  }
}

# Remove outdated dependencies (especially if dependency will be installed anyway)
Remove-Item -force -recurse $ksp2mModsPath/UKS/GameData/CommunityResourcePack
Remove-Item -force -recurse $ksp2mModsPath/Advanced_Jet_Engine/GameData/SolverEngines
Remove-Item -force -recurse $ksp2mModsPath/B9ProcParts/GameData/CrossFeedEnabler
Remove-Item -force -recurse $ksp2mModsPath/DeadlyReentry/ModularFlightIntegrator
Remove-Item -force -recurse $ksp2mModsPath/FAR/GameData/ModularFlightIntegrator
Remove-Item -force -recurse $ksp2mModsPath/FASA/GameData/JSI
Remove-Item -force -recurse $ksp2mModsPath/RealFuels/CommunityResourcePack
Remove-Item -force -recurse $ksp2mModsPath/RealFuels/SolverEngines
Remove-Item -force -recurse $ksp2mModsPath/RealHeat/ModularFlightIntegrator
Remove-Item -force -recurse $ksp2mModsPath/UniversalStorage/CommunityResourcePack

# Move all the mods to GameData folder
Write-Output "`r`nMoving Mods"
Get-ChildItem $ksp2mModsPath/*/* -Filter GameData |
foreach-Object {
  Copy-Item -force -recurse $_/* $gameDataPath
}

# Custom move for base install
Copy-Item -force -recurse $ksp2mModsPath/CrossFeedEnabler/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/DeadlyReentry/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/RealFuels/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/RealHeat/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/RealSolarSystem/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/Toolbar/Toolbar-1.7.9/GameData/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/ksp-avc/* $gameDataPath
Copy-Item -force -recurse "$ksp2mModsPath/KWRocketry/KW Release Package v2.7 (Open this, don't extract it)/GameData/*" $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/UniversalStorage/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/StockBugFixModules/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/AIES_Aerospace151/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/HullcaMove-ItemDS/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/JDiminishingRTG/JDiminishingRTG_v1_3a/GameData/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/NebulaDecals/NEBULA/* $gameDataPath

# Custom move for dev
if (-not $b -and -not $c){
Copy-Item -force -recurse $ksp2mModsPath/mechjeb2/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/VesselViewer/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/FShangarExtender/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/PartWizard/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/RCSbuildAid/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/StripSymmetry/Gamedata/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/EditorExtensions/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/KerbalEngineer/* $gameDataPath
}

# Custom move for beauty
if ($b -or $f){
Copy-Item -force -recurse $ksp2mModsPath/hotrocket/* $gameDataPath
Copy-Item -force -recurse "$ksp2mModsPath/DistantObject/Alternate Planet Color Configs/Real Solar System (metaphor's PlanetFactory config)/*" $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/EngineLighting/EngineLight/GameData/* $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/ImprovedChaseCam/* $gameDataPath
Copy-Item -force -recurse "$ksp2mModsPath/PlanetShine/Alternate Colors/Real Solar System/*" $gameDataPath
Copy-Item -force -recurse $ksp2mModsPath/RoverWheelSounds/* $gameDataPath
}

# Fix some configs
Write-Output "`r`nAdapting Configs"
Copy-Item -recurse -force $ksp2mModsPath/RealismOverhaul/GameData/* $gameDataPath #We do this to make sure that we use the RO/RSS configs and not the configs provided by plugins installed after RO/RSS
Copy-Item -force $ksp2mModsPath/RealismOverhaul/GameData/RealismOverhaul/RemoteTech_Settings.cfg $gameDataPath/RemoteTech/RemoteTech_Settings.cfg
Copy-Item -force $ksp2mModsPath/TextureReplacer/Extras/MM_ReflectionPluginWrapper.cfg $gameDataPath
Copy-Item -force $ksp2mModsPath/StockPlusController.cfg $gameDataPath
Copy-Item -force $ksp2mModsPath/AIES_Node_Patch.cfg/AIES_Node_Patch.cfg $gameDataPath

# Clean up
Write-Output "`r`nStarting Clean up"
Remove-Item -Recurse -Force ksp2m_mods
Set-Location $gameDataPath
new-item -itemtype directory licensesAndReadmes > $null
if (Test-Path *.txt){
Move-Item *.txt licensesAndReadmes
}
if (Test-Path *.md){
Move-Item *.md licensesAndReadmes
}
if (Test-Path *.pdf){
Move-Item *.pdf licensesAndReadmes
}
if (Test-Path *.htm){
Move-Item *.htm licensesAndReadmes
}

# Remove old versions of ModuleManager
Write-Output "`r`nRemoving old ModuleManager Versions"
if (Test-Path ModuleManager.2.5.1.dll) {
  Remove-Item ModuleManager.2.5.1.dll
}
Remove-Item ModuleManager.2.6.1.dll, ModuleManager.2.6.3.dll, ModuleManager.2.6.5.dll

# Remove unneeded parts
Write-Output "`r`nRemoving unneeded parts"

# AIES
if (Test-Path -d $gameDataPath/AIES_Aerospace){
  Set-Location $gameDataPath/AIES_Aerospace
  Remove-Item -Recurse -Force Aero
  Set-Location $gameDataPath/AIES_Aerospace/Command
  Remove-Item -Recurse -Force AIESorbiterpod
  Set-Location $gameDataPath/AIES_Aerospace/FuelTank
  Remove-Item -Recurse -Force "AIESfueltank 7k", "AIESFueltank superior3", AIESFueltanksul, AIESrcs125ra, "AIEStank MR1", AIEStank1300cl, AIEStankMER1, AIEStankMER6, AIEStankminsond
  Set-Location $gameDataPath/AIES_Aerospace/Structure
  Remove-Item -Recurse -Force "AIES *", AIESadapterrads, AIESbase*, AIESdec*, "AIESdesacoplador sat1"
  Set-Location $gameDataPath
}

# HabitatPack
if (Test-Path -d $gameDataPath/HabitatPack){
  Set-Location $gameDataPath/HabitatPack/Parts
  Remove-Item -Recurse -Force Basemount, orbitalorb
  Set-Location $gameDataPath
}

# Deadly Reentry
if (Test-Path -d $gameDataPath/DeadlyReentry){
  Remove-Item -Recurse -Force $gameDataPath/DeadlyReentry/Plugins
  Remove-Item -Recurse -Force $gameDataPath/DeadlyReentry/Sounds
  Remove-Item -Force "$gameDataPath/DeadlyReentry/*.cfg"
  Set-Location $gameDataPath
}

# FASA
if (Test-Path -d $gameDataPath/FASA){
  Set-Location $gameDataPath/FASA
  Remove-Item -Recurse -Force Agencies, Flags, ICBM, Mercury, Resources
  Set-Location $gameDataPath/FASA/Apollo
  Remove-Item -Recurse -Force ApolloCSM, FASA_Apollo_Fairings, FASA_Apollo_Str, Science
  Set-Location $gameDataPath/FASA/Apollo/LEM
  Remove-Item -Recurse -Force Antennas, AscentStage, DescentStage, DockingCone, InterStage, LandingLegs
  Set-Location $gameDataPath/FASA/Gemini2
  Remove-Item -Recurse -Force FASA_ASAS_MiniComp, FASA_Fairings_Plate_2m, FASA_Gemini_BigG, FASA_Gemini_Dec_Dark, FASA_Gemini_Engine_Fuel2, FASA_Gemini_LES, FASA_Gemini_LFT, FASA_Gemini_LFTLong, FASA_Gemini_Lander_Eng, FASA_Gemini_Lander_Legs, FASA_Gemini_Lander_Pod, FASA_Gemini_MOL, FASA_Gemini_NoseCone2, FASA_Gemini_Parachute2, FASA_Gemini_Pod2, FASA_Gemini_RCS_Thruster, FASA_Gemini_SAS_RCS, FASA_WingGemini, SmallGearBay, FASA_Gemini_Centaur
  Set-Location $gameDataPath/FASA/Gemini2/FASA_Gemini_LR91_Pack
  Remove-Item -Force *Fairing*, *LFT*
  Set-Location $gameDataPath/FASA/Gemini2/FASA_Agena
  Remove-Item -Force *Fairing*, *LFT*
  Set-Location $gameDataPath/FASA/Probes
  Remove-Item -Recurse -Force Explorer, Pioneer, Probe_Parachute_Box
  Set-Location $gameDataPath
}

# DMagic -> UniversalStorage Parts
if(Test-Path -d $gameDataPath/DMagicOrbitalScience){
  Remove-Item -Recurse -Force $gameDataPath/DMagicOrbitalScience/UniversalStorage
  Set-Location $gameDataPath
}

# KW Rocketry
if(Test-Path -d $gameDataPath/KWRocketry){
  Set-Location $gameDataPath/KWRocketry/Parts/Fuel/KW_Universal_Tanks
  Remove-Item -Force 1*, 2_*, 2m*, 3*, 5*, KW_C*, KW_F*, P*, R*, KW_AdapterF*
  Remove-Item -Recurse -Force $gameDataPath/KWRocketry/Parts/Control/KWRadialSAS
  Remove-Item -Recurse -Force $gameDataPath/KWRocketry/Parts/Structural/KWFuelAdapter
  Set-Location $gameDataPath
}

# MechJeb2
if(Test-Path -d $gameDataPath/MechJeb2){
  Remove-Item -Recurse -Force $gameDataPath/MechJeb2/Parts
  Set-Location $gameDataPath
}

# NovaPunch2 
if(Test-Path -d $gameDataPath/NovaPunch2){
  Set-Location $gameDataPath/NovaPunch2
  Remove-Item -Recurse -Force Agencies, Flags
  Set-Location $gameDataPath/NovaPunch2/Parts
  Remove-Item -Recurse -Force ControlPods, Fairings, FuelTanks, NoseCone, SAS, YawmasterCSM, RCS
  Set-Location $gameDataPath/NovaPunch2/Parts/CouplersAndAdapters
  Remove-Item -Recurse -Force NP_interstage*
  Set-Location $gameDataPath/NovaPunch2/Parts/Freyja
  Remove-Item -Recurse -Force FreyjaEng, FreyjaRCS, FreyjaTrunk
  Set-Location $gameDataPath/NovaPunch2/Parts/Odin2
  Remove-Item -Recurse -Force OdinFairings, OdinPod, OdinRCS, OdinServiceModule
  Set-Location $gameDataPath/NovaPunch2/Parts/Thor
  Remove-Item -Recurse -Force NP_ThorLanderRCS, NP_ThorLanderRCSTank, NP_ThorAscentPackage, NP_ThorDescentPackage, NP_ThorLanderStrut2, NP_ThorLanderASAS
  Remove-Item -Recurse -Force $gameDataPath/NovaPunch2/Parts/Parachutes/NP_chute_FuelTankCapParachute
  Remove-Item -Recurse -Force $gameDataPath/NovaPunch2/Parts/Misc/NP_Leg_HeavyLeg
  Remove-Item -Recurse -Force $gameDataPath/NovaPunch2/Parts/LaunchEscape/NP_LES_RCS_nanocone
  Remove-Item -Recurse -Force $gameDataPath/NovaPunch2/Parts/Odin2/OdinShield
  Set-Location $gameDataPath
}

# Squad
Set-Location $gameDataPath/Squad
Remove-Item -Recurse -Force Agencies, Flags 2> $null
Set-Location $gameDataPath/Squad/Parts/Aero
Remove-Item -Recurse -Force fairings 2> $null
Set-Location $gameDataPath/Squad/Parts/FuelTank
Remove-Item -Recurse -Force RCSFuel*, Size3*, adapter*, fuelTankJ*, fuelTankO*, fuelTankT100, fuelTankT200, fuelTankT400, fuelTankT800, fuelTankX*, mk2*, mk3*, xenon* 2> $null
Set-Location $gameDataPath

# UKS/MKS
if(Test-Path -d $gameDataPath/UmbraSpaceIndustries){
  Remove-Item -Recurse -Force $gameDataPath/UmbraSpaceIndustries/Kolonization/Flags
  Set-Location $gameDataPath/UmbraSpaceIndustries/Kolonization/Parts
  Remove-Item -force MK3*, MKS_A*, MKS_C*, MKS_D*, MKS_E*, MKS_F*, MKS_K*, MKS_L*, MKS_M*, MKS_P*, MKS_S*, MKS_W*, MKV_Ag*, MKV_B*, MKV_L*, MKV_Pod.cfg, MKV_W*, MiniRover.cfg, OKS_A*, OKS_Col*, OKS_Ha*, OKS_K*, OKS_P*, OKS_S*, OKS_W*, OctoLander.cfg, ScanOMatic.cfg
  Set-Location $gameDataPath/UmbraSpaceIndustries/Kontainers
  Remove-Item -force Kontainer*
  Set-Location $gameDataPath/UmbraSpaceIndustries/Kontainers/Assets
  Remove-Item -force Kontainer*
  Set-Location $gameDataPath
}

# UniversalStorage
if(Test-Path -d $gameDataPath/UniversalStorage){
  Remove-Item -Recurse -Force UniversalStorage/Flags
  Set-Location $gameDataPath
}

# TACLS
if(Test-Path -d $gameDataPath/ThunderAerospace){
  Set-Location $gameDataPath/ThunderAerospace
  Remove-Item -Recurse -Force TacLifeSupportContainers, TacLifeSupportHexCans, TacLifeSupportMFT
  Set-Location $gameDataPath
}

# Taurus HCV
if(Test-Path -d $gameDataPath/RSCapsuledyne){
  Set-Location $gameDataPath/RSCapsuledyne/Parts
  Remove-Item -Recurse -Force Engine, FuelTank, OreTank, Nuke
  Set-Location $gameDataPath
}

# Realism Overhaul
if(Test-Path -d $gameDataPath/RealismOverhaul){
  Remove-Item -Recurse -Force $gameDataPath/RealismOverhaul/Parts/NoseconeCockpit
  Set-Location $gameDataPath
}

Remove-Item -Recurse -Force "$k/$BackupPath"
Set-Location $startingPath

Write-Output "`r`n`r`nFinished!"
