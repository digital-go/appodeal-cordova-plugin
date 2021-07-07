module.exports = (pbxProject, comment, shellScript, shellPath = '/bin/sh') => {
    const buildPhase = {
        buildActionMask: 2147483647,
        files: [],
        inputPaths: [],
        isa: 'PBXShellScriptBuildPhase',
        outputPaths: [],
        runOnlyForDeploymentPostprocessing: 0,
        shellPath,
        shellScript,
        showEnvVarsInLog: 0,
    }
    const id = pbxProject.generateUuid()

    const { PBXNativeTarget, PBXShellScriptBuildPhase } = pbxProject.hash.project.objects

    PBXShellScriptBuildPhase[id] = buildPhase
    PBXShellScriptBuildPhase[`${id}_comment`] = comment

    for (var nativeTargetId in PBXNativeTarget) {
        if (/_comment$/.test(nativeTargetId)) {
            continue
        }

        const nativeTarget = PBXNativeTarget[nativeTargetId]

        nativeTarget.buildPhases.push({
            value: id,
            comment: comment,
        })
    }
}
