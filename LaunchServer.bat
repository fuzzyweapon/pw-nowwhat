@ECHO OFF

:: When setting the memory below make sure to include the amount of ram letter. M = MB, G = GB. Don't use 1GB for example, it's 1G ::

:: This is 64-bit memory ::
set memsixtyfourmax=6G
set memsixtyfourstart=4G

:: This is 32-bit memory - maximum 1.2G ish::
set memthirtytwomax=1G
set memthirtytwostart=1G

:: The path to the Java to use. Wrap in double quotes ("C:\Path\To\Java\bin\java"). Use "java" to point to system default install.
set javapath="java"

:: Any additional arguments to pass to Java such as Metaspace, GC or anything else
set jvmargs="-Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:-UseBiasedLocking -XX:UseAVX=3 -XX:+UseStringDeduplication -XX:+UseFastUnorderedTimeStamps -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:+UseFMA -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+SegmentedCodeCache -XX:+UseFastJNIAccessors -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+TrustFinalNonStaticFields -XX:ThreadPriorityPolicy=1 -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Xlog:async -Djava.security.egd=file:/dev/urandom --add-modules jdk.incubator.vector"

:: Don't edit past this point ::

set launchargs=%*
:: Launcher can specify path to java using a custom token
IF "%1"=="ATLcustomjava" (
    for /f "tokens=2,* delims= " %%a in ("%*") do set launchargs=%%b

    echo "Using launcher provided Java from %2"
    SET javapath="%2"
)

if $SYSTEM_os_arch==x86 (
    echo OS is 32
    set startmem=%memthirtytwostart%
    set maxmem=%memthirtytwomax%
) else (
    echo OS is 64
    set startmem=%memsixtyfourstart%
    set maxmem=%memsixtyfourmax%
)

echo.
echo Printing Java version, if the Java version doesn't show below, your Java path is incorrect
"%javapath%" -version
echo.

echo Launching fabric-server-launch.jar with '%maxmem%' max memory, jvm args '%jvmargs%' and arguments '%launchargs%'

:: add nogui to the end of this line to disable the gui ::
"%javapath%" -Xms%startmem% -Xmx%maxmem% %jvm_args% -jar fabric-server-launch.jar %launchargs%
PAUSE

