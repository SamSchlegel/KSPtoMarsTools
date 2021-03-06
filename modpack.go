package main

import (
  "fmt"
  "os"
  "github.com/KSPtoMars/KSPtoMarsTools/libraries/argumenthandler"
  "github.com/KSPtoMars/KSPtoMarsTools/libraries/installsteps"
)

func main() {

  // Parse input Arguments. Check path and Flags
  inputArguments, err := argumenthandler.CheckArguments()
  if err != nil {
    fmt.Println(err)
    os.Exit(1)
  }

  fmt.Println("\nThis is v4.0.6-beta of the ksp2mars modpack script.\n")

  // Start with mod installation
  if (inputArguments.BeautyFlag) {
    fmt.Println("Preparing beauty install.\n")
  } else if (inputArguments.CoreFlag){
    fmt.Println("Preparing base install.\n")
  } else if (inputArguments.FullFlag){
    fmt.Println("Preparing full install.\n")
  } else {
    fmt.Println("Preparing developer install.\n")
  }

  // Setup all necessary paths
  relevantPaths := installsteps.SetupPaths(inputArguments)

  // Download necessary mods
  if err := installsteps.DownloadNecessaryMods(inputArguments, &relevantPaths); err != nil {
      fmt.Println ("There has been a critical error during downloading! Aborting and rolling back...")
      fmt.Println (err)
      os.RemoveAll(relevantPaths.Ksp2mModsPath)
      os.Exit(1)
  }

  // Unpack all zip files
  if err := installsteps.UnpackAllZipFiles(&relevantPaths); err != nil {
      fmt.Println ("There has been a critical error during unpacking! Aborting and rolling back...")
      fmt.Println (err)
      os.RemoveAll(relevantPaths.Ksp2mModsPath)
      os.Exit(1)
  }

  // Remove outdated dependencies (especially if dependency will be installed anyway)
  installsteps.RemoveOldDependencies(&relevantPaths)

  // Move mods to GameData Folder
  backupPath := installsteps.CreateBackup(&relevantPaths)

  // Move mods to GameData Folder
  if err := installsteps.MoveMods(&relevantPaths); err != nil {
    fmt.Println ("There has been a critical error during copying! Aborting and rolling back...")
    fmt.Println (err)
    os.RemoveAll(relevantPaths.Ksp2mModsPath)
    installsteps.RollBack(&relevantPaths, &backupPath)
  }

  // Clean up
  installsteps.CleanUp(&relevantPaths, &backupPath)

  // Remove unneeded Parts
  installsteps.RemoveUnneededParts(&relevantPaths)

  fmt.Println ("Finished!")
  
}
