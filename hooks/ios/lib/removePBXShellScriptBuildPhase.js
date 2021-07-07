module.exports = (pbxProject, comment) => {
    const { PBXNativeTarget, PBXShellScriptBuildPhase } = pbxProject.hash.project.objects
    const ids = []

    for (var id in PBXShellScriptBuildPhase) {
        if (/_comment$/.test(id)) {
            if (PBXShellScriptBuildPhase[id] === comment) {
                ids.push(id, id.replace('_comment', ''))
            }
        }
    }

    for (var nativeTargetId in PBXNativeTarget) {
        if (/_comment$/.test(nativeTargetId)) {
            continue
        }

        const nativeTarget = PBXNativeTarget[nativeTargetId]

        nativeTarget.buildPhases = nativeTarget.buildPhases.filter(
            buildPhase => !ids.includes(buildPhase.value)
        )
    }

    ids.forEach(id => delete PBXShellScriptBuildPhase[id])
}
