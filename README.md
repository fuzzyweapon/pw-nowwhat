# pw-nowwhat
NowWhat is a packwiz modpack for Minecraft.  It contains mods from both Curseforge and Modrinth.

---

It's a Brave New World!

You don't know why, but you're on this world (NowWhat) and something happened here long ago.  Seems like no one can pass on to the next phase of being, so it's time to make the most of NowWhat.

---

The NowWhat modpack focuses on a balanced pack, prioritizing heavy optimization and centering around Create for its automation needs and a few extras for more casual flavor players.  It also offers some creator centered mods, as the NowWhat server the pack was made for is focused on worldbuilding (mostly the old-fashioned way).

---

## Getting Started

1.  Download and install [ATLauncher](https://atlauncher.com/downloads) for your OS
2.  Launch ATLauncher
3.  Click `Vanilla Packs` tab on the right
4.  Enter the following information to create a new instance:
    - Instance Name:  `NowWhat`
    - Description:  `Minecraft 1.19.2, Fabric 0.14.17`
    - Minecraft Version:  `1.19.2`
    - Loader?:  `Fabric`
    - Loader Version:  `0.14.17`
5.  Click `Create Instance` button
6.  Click the `Instances` tab
7.  In NowWhat `Settings` > `Commands`, set the following:
    - `Enable commands?` to `Yes`
    - `Pre-launch command` to `java -jar packwiz-installer-bootstrap.jar --bootstrap-update-url https://api.github.com/repos/fuzzyweapon/packwiz-installer/releases/latest -s client http://now-what.duckdns.org:8080/pack.toml`
8.  In NowWhat `Settings` > `Java/Minecraft`, set the following:
    - `Maximum Memory/Ram` to `6,144`
    - `Java Parameters` to `-Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:-UseBiasedLocking -XX:UseAVX=3 -XX:+UseStringDeduplication -XX:+UseFastUnorderedTimeStamps -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:+UseFMA -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+SegmentedCodeCache -XX:+UseFastJNIAccessors -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+TrustFinalNonStaticFields -XX:ThreadPriorityPolicy=1 -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Xlog:async -Djava.security.egd=file:/dev/urandom --add-modules jdk.incubator.vector`
9.  After `Save`-ing the settings, click the `Open Folder` button for the NowWhat instance
10. Download the latest [packwiz-installer-bootstrap.jar](https://github.com/packwiz/packwiz-installer-bootstrap/releases/latest/download/packwiz-installer-bootstrap.jar) into the instance directory from step 9
11. Click the `Play` button
12. Select optional clientside mods or continue \
_It is recommended to set these once and then use continue from that point forward since the installer does not remember user choices_
13. *Close all the browser download windows while Minecraft launches (this will take a long time; go make a sandwich)
14. Create a new `Multiplayer` server entry in Minecraft if it does not exist:
    - `Server Name` - `NowWhat`
    - `Server Address` - `now-what.duckdns.org`
15. Join the server!

*Please note!  During the course of the installer, it will open a lot of browser windows to automatically install the mods that require them to be installed via a download link.  During this time, do not touch anything.  The installer will download and move these to the correct destination.

## Playing After Setting Up

1.  Launch ATLauncher
2.  Click the `Play` button in the `Instances` tab next to NowWhat
3.  Make a sandwich while you wait for it to launch
4.  Join the server!
s
