#!/bin/bash

# When setting the memory below make sure to include the amount of ram letter. M = MB, G = GB. Don't use 1GB for example, it's 1G
MEMORY="6G"

# The path to the Java to use. Wrap in double quotes ("/opt/jre-17/bin/java"). Use "java" to point to system default install.
JAVAPATH="java"

# Any additional arguments to pass to Java such as Metaspace, GC or anything else
JVMARGS="-Xms4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:-UseBiasedLocking -XX:UseAVX=3 -XX:+UseStringDeduplication -XX:+UseFastUnorderedTimeStamps -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:+UseFMA -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+SegmentedCodeCache -XX:+UseFastJNIAccessors -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+OmitStackTraceInFastThrow -XX:+TrustFinalNonStaticFields -XX:ThreadPriorityPolicy=1 -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseFastStosb -XX:+UseNewLongLShift -XX:+UseVectorCmov -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Xlog:async -Djava.security.egd=file:/dev/urandom --add-modules jdk.incubator.vector"

# Don't edit past this point

cd "`dirname "$0"`"

LAUNCHARGS="$@"
# Launcher can specify path to java using a custom token
if [ "$1" = "ATLcustomjava" ]; then
    LAUNCHARGS="${@:2}"

    echo "Using launcher provided Java from $2"
    JAVAPATH="$2"
fi

echo
echo "Printing Java version, if the Java version doesn't show below, your Java path is incorrect"
$JAVAPATH -version
echo

echo "Launching fabric-server-launch.jar with '$MEMORY' max memory, jvm args '$JVMARGS' and arguments '$LAUNCHARGS'"

$JAVAPATH -Xmx$MEMORY $JVMARGS   -jar fabric-server-launch.jar "$LAUNCHARGS"
read -n1 -r -p "Press any key to close..."
