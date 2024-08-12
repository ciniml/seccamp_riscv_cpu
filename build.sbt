// See README.md for license details.

ThisBuild / scalaVersion     := "2.13.12"
ThisBuild / version          := "0.1.0"
ThisBuild / organization     := "%ORGANIZATION%"

lazy val commonSettings = Seq (
  libraryDependencies ++= Seq(
    "org.chipsalliance" %% "chisel" % "6.2.0",
    "org.scalatest" %% "scalatest" % "3.2.16" % "test"
  ),
  scalacOptions ++= Seq(
    "-language:reflectiveCalls",
    "-deprecation",
    "-feature",
    "-Xcheckinit",
    "-Ymacro-annotations"
  ),
  addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % "6.2.0" cross CrossVersion.full),
)

lazy val fpga_samples = (project in file("./external/fpga_samples/chisel")).
  settings(
    commonSettings,
    name := "fpga_samples"
  )

lazy val cpu_design = (project in file("./cpu_design")).
  settings(
    commonSettings,
    name := "cpu_design"
  ).
  dependsOn(fpga_samples)

lazy val root = (project in file("."))
  .aggregate(cpu_design, fpga_samples)
