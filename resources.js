const fs = require('fs')
const util = require('util');
const Promise = require('bluebird');
const { exec } = require('child_process');
const readFile = util.promisify(fs.readFile)
const writeFile = util.promisify(fs.writeFile)
const deleteFile = fs.unlinkSync
const execCommand = util.promisify(exec)
const diff = require('deep-diff').diff;
const deepAssign = require('deep-assign');
const _ = require('lodash')

let targetName  = "layout"
const startTime = Date.now()

const CHANGETYPE = {
    DEPENDENCIES : "DEPENDENCIES",
    RESOURCES : "RESOURCES",
    ALL : "ALL",
    NONE : "NONE"
}

const DEPENDENCYTYPE = {
    SINGLETON : "SINGLETON",
    INSTANCE : "INSTANCE"
}

const args = process.argv.slice(2);
if(args.length > 0) {
    targetName = args[0]
}

console.log(targetName)

const parseProject = execCommand("plutil -convert json -r App.xcodeproj/project.pbxproj -o project.local.json")

const getChangeList = function() {
    return new Promise((resolve, reject) => {
        execCommand("git status --porcelain | sed s/^...// | grep .swift ").then( ({ stdout }) => {
            resolve(stdout.split("\n").filter(name => name.length > 0).filter(name => name != "R.swift"))
        }).catch(() => resolve([]))
    })
}

const getStoredSet = function() {
    return new Promise((resolve) => {
        readFile(targetName + '.local.json').then(JSON.parse).then(resolve).catch(() => { resolve({})})
    })
}

const getResourcesForFiles = function(files) {

    return new Promise((resolve, reject) => {
        Promise.all([
            extractFilesWithClass(files.layout ? Object.keys(files.layout) : files, "Layout"),
            extractFilesWithClass(files.resources ? Object.keys(files.resources) : files, "Resource"),
            extractFilesWithClass(files.rawResources ? Object.keys(files.rawResources) : files, "RawResource"),
        ]).then(([layoutFiles, resourceFiles, rawResourceFiles]) => {
            Promise.all([
                extractResources(resourceFiles)
            ]).then(([resourceValues]) => {
                let resources = {
                    layout : layoutFiles.reduce((acc, file, index) => {
                        acc[file.file] = file.resources
                        return acc
                    }, {}),
                    resources : resourceFiles.reduce((acc, file, index) => {
                        acc[file.file] = {
                            key : file.resources[0],
                            values : resourceValues.filter(res => res.file == file.file)[0].resources || []
                        }
                        return acc
                    }, {}),
                    rawResources : rawResourceFiles.reduce((acc, file, index) => {
                        acc[file.file] = {
                            key : file.resources[0]
                        }
                        return acc
                    }, {}),
                }
                resolve(resources)
            }).catch(reject)
        }).catch(reject)
    })
}

const dataSets = function () {
    return new Promise((resolve, reject) => {

        const getDataSets = () => {
            Promise.all([
                getTargetFiles(),
                getChangeList(),
                getStoredSet()
            ]).then(([targetFiles, changedFiles, storedResources]) => {
                Promise.all([
                        targetFiles,
                        changedFiles,
                        storedResources,
                        extractStrings(),
                        extractImages(),
                        getResourcesForFiles(storedResources.resources === undefined ? targetFiles : storedResources.resources || changedFiles),
                        extractDependencies(storedResources.dependencies === undefined ? targetFiles : Object.keys(storedResources.dependencies) || changedFiles)
                    ])
                    .then(resolve)
                    .catch(reject)
            }).catch(reject)
        }

        readFile('report.local.json').then(JSON.parse).then(report => {
            if(report.lastTarget != targetName) {
                deleteFile(targetName + '.local.json')
            }
            getDataSets()
        }).catch(getDataSets)

    })
}

const extractDependencies = function(targetFiles) {

    const readDependencies = function(file) {
        return new Promise((resolve, reject) => {
            Promise.all([
                execCommand("cat '" + file.file + "' | grep \"static func\" | sed -n 's/.*static func *\\([a-zA-Z0-9_\\-]*\\) *.*> *\\([a-zA-Z0-9_\\-]*\\) *.*/\\1|\\2/p'"),
                execCommand("cat '" + file.file + "' | grep \"static let\" | sed -n 's/.*static let *\\([a-zA-Z0-9_\\-]*\\) *: *\\([a-zA-Z0-9_\\-]*\\) *.*=.*/\\1|\\2/p'")
            ])
            .then(([instances, singletons]) => {
                file.values = []
                singletons.stdout.split("\n").filter(string => string.length > 0).forEach(pair => {
                    let [name, className] = pair.split("|")
                    file.values.push({ name : name, class : className, type : DEPENDENCYTYPE.SINGLETON})
                })
                instances.stdout.split("\n").filter(string => string.length > 0).forEach(pair => {
                    let [name, className] = pair.split("|")
                    file.values.push({ name : name, class : className, type : DEPENDENCYTYPE.INSTANCE})
                })
                resolve(file)
            }).catch(reject)
        })
    }

    return new Promise((resolve, reject) => {
        extractFilesWithClass(targetFiles, "DependencyModule")
            .then(files => {
                return Promise.map(files, file => readDependencies(file))
            })
            .then(dep => {
                resolve(dep.reduce((acc, d) => {
                    acc[d.file] = {
                        values : d.values,
                        class : d.resources[0]
                    }
                    return acc
                }, {}))
            })
            .catch(reject)
    })
}

const getTargetFiles = function() {

    return new Promise((resolve, reject) => {
        readFile("project.local.json").then(file => {
            const project = JSON.parse(file)
            const targets = Object.values(project.objects).filter(obj => obj.isa == "PBXNativeTarget" && obj.name == targetName)

            if(targets.length > 0) {
                const layoutTarget = targets[0]
                const files = layoutTarget.buildPhases.flatMap(id => {
                    return (project.objects[id].isa == "PBXSourcesBuildPhase" && project.objects[id].files != undefined) ? project.objects[id].files : []
                })
                const fileNames = files.map(id => {
                    switch(project.objects[id].isa) {
                        case "PBXBuildFile" :
                            return project.objects[project.objects[id].fileRef].path
                        case "PBXFileReference" :
                            return project.objects[id].path
                    }
                })
                execCommand("find ${PWD} -not -path \"*/Pods/*\" -not -path \"*/preview/*\" -not -path \"*/external/*\" -name '*.swift'").then(result => {
                    let projectFiles = result.stdout.split("\n").map(name => name.replace(__dirname + "/", "")).filter(name => name.length > 0)
                    let targetFiles = fileNames.filter(name => name != "R.swift")
                    resolve(projectFiles.filter(path => {
                        let pathElements = path.split("/")
                        return targetFiles.includes(pathElements[pathElements.length-1])
                    }))
                })

            } else { reject(new Error("no target found")) }

        })
    })
}

const extractResources = function(targetFiles) {

    const extractValues = function(file) {
        return new Promise((resolve, reject) => {
            execCommand("cat '" + file.file + "' | grep \"lazy var\" | sed -n 's/.*lazy var *\\([a-zA-Z0-9_\\-]*\\) *.*=.*/\\1/p'").then(({ stdout })=> {
                resolve({ file : file.file, resources : stdout.split("\n").filter(string => string.length > 0)})
            }).catch(reject)
            /*
            execCommand("sed -i '' -e 's/ let / lazy var /g' " + file.file).then(() => {

            }).catch(reject)*/
        })
    }

    return new Promise((resolve, reject) => {
        Promise.map(targetFiles, file => extractValues(file), {concurrency : 100}).then(resolve).catch(reject)
    })
}

const checkFileForClass = function(file, className) {
    return new Promise((resolve,reject) => {
        execCommand("cat '" + file + "' | grep \"class\"| sed -n 's/.*class *\\(.*\\) *: *"+ className +".*/\\1/p' | sort -u").then(result => {
            resolve(result.stdout.length > 0 ? file : undefined)
        }).catch(reject)
    })
}

const extractFilesWithClass = function(targetFiles, className) {
    return new Promise((resolve, reject) => {
        Promise.map(targetFiles, file => checkFileForClass(file, className), { concurrency:  100}).then(result => {
            getClassNamesFor([...new Set(result.flatMap(strings => strings))].filter(path => path !== undefined), className)
                .then(resolve)
                .catch(reject)
        }).catch(reject)
    })
}

const getClassNamesFor = function(targetFiles, type) {
    return new Promise((resolve, reject) => {
        const read = function(file) {
            return new Promise((resolve, reject) => {
                execCommand("cat '" + file + "' | grep \"class\"| sed -n 's/.*class *\\(.*\\) *: *" + type + ".*/\\1/p' | sort -u").then(result => {
                    resolve({ file : file, resources : result.stdout.split("\n").filter(name => name.length > 0)})
                }).catch(reject)
            })
        }

        Promise.map(targetFiles, file => read(file), { concurrency:  100}).then(result => {
            resolve([...new Set(result.flatMap(res => res))])
        }).catch(reject)
    })
}

const extractIdentifiers = function(file) {
    return new Promise((resolve,reject) => {
        Promise.all([
            extractIds(file),
            extractEvents(file)
        ]).then(([ids, events]) => {
            resolve({ file : file, event : events, id : ids})
        }).catch(reject)
    })

}

const extractImages = function() {
    return new Promise((resolve, reject) => {
        execCommand("find ${PWD} -not -path \"*/Pods/*\" -type d -name \"*.imageset\" | sed 's!.*/!!' | sed 's/\\.[^.]*$//'").then( ({ stdout }) => {
            resolve(stdout.split("\n").filter(name => name.length > 0))
        }).catch(reject)
    })
}

const extractStrings = function() {
    return new Promise((resolve, reject) => {
        execCommand("find ${PWD} -not -path \"*/Pods/*\" -not -path \"*/preview/*\" -not -path \"*/external/*\" -name \"*.strings\"").then( ({ stdout }) => {
            let files = stdout.split("\n").filter(name => name.length > 0)
            Promise.all(files.map(file => execCommand("cat '" + file + "' | sed -n 's/(*)*=.*//p'"))).then(result => {
                resolve([...new Set(result.flatMap(strings => strings.stdout.split("\n").filter(name => name.length > 0)))])
            }).catch(reject)
        }).catch(reject)
    })
}

const extractIds = function(file) {
    return new Promise((resolve, reject) => {
        execCommand("cat '" + file + "' | grep \"R\\.id\\.\"| sed 's/.*R\\.id\\.\\([a-zA-Z0-9_\\-]*\\).*/\\1/' | sort -u").then(({ stdout }) => {
            resolve(stdout.split("\n").filter(name => name.length > 0))
        }).catch(reject)
    })
}

const extractEvents = function(file) {
    return new Promise((resolve, reject) => {
        execCommand("cat '" + file + "' | grep \"R\\.event\\.\" | grep -v \"func\" | grep -v \"R\\.event\\.[a-zA-Z0-9_\\-]*\\.\"| sed 's/.*R\\.event\\.\\([a-zA-Z0-9_\\-]*\\).* as \\([a-zA-Z0-9_\\-]*\\).*/\\1\\(Any)/' | sed 's/.*R\\.event\\.\\([a-zA-Z0-9_\\-]*\\).*/\\1/' | sort -u").then(({ stdout }) => {
            resolve(stdout.split("\n").filter(name => name.length > 0))
        }).catch(() => resolve([]))
    })
}

const compareSets = function(stored, generated) {
    return new Promise((resolve, reject) => {
        let _diff = diff(stored, generated)
        let changes = []
        if(_diff != undefined && _diff.length > 0) {
            if(_diff.filter(d => d.path[0] == CHANGETYPE.DEPENDENCIES.toLowerCase()).length > 0) changes.push(CHANGETYPE.DEPENDENCIES)
            if(_diff.filter(d => d.path[0] != CHANGETYPE.DEPENDENCIES.toLowerCase()).length > 0) changes.push(CHANGETYPE.RESOURCES)
            let unique = [...new Set(changes)]
            return resolve((unique.length > 1) ?  CHANGETYPE.ALL : unique[0])
        } else {
            return resolve(CHANGETYPE.NONE)
        }
    })

    /*
    const compare = function (arr1, arr2) {
        if(arr1 === undefined || arr2 === undefined) { return false }
        return arr1.length == arr2.length && arr1.every((u, i) => u === arr2[i])
    }

    return new Promise((resolve) => {
        let identifiersCompareResult = Object.entries(generated.identifiers).flatMap(([file, identifiers]) => {
            return compare(((stored.identifiers || {})[file] || {}).id, identifiers.id) && compare(((stored.identifiers || {})[file] || {}).event, identifiers.event)
        })

        let resourcesCompareResult = Object.entries(generated.resources.resources).flatMap(([file, resource]) => {
            return compare((((stored.resources || {}).resources || {})[file] || {}).values, resource.values)
        })

        resolve([generated,
            !(compare(stored.string, generated.string)
            && compare(stored.image, generated.image)
            && compare(Object.keys(((stored.resources || {}).layout || {})), Object.keys(((generated.resources || {}).layout || {})))
            && !identifiersCompareResult.includes(false)
            && !resourcesCompareResult.includes(false)
            )]
        )
    })
    */
}

const buildResources = function(generated) {

    return new Promise((resolve, reject) => {

        let indent1 = "    "
        let indent2 = "        "
        let indent3 = "            "

        const lowercaseFirst = (s) => {
            if (typeof s !== 'string') return ''
            return s.charAt(0).toLowerCase() + s.slice(1)
        }

        const getEnum = (name, contents, type) => {
            let _enum = []
            _enum.push(indent1 + "enum " + name.toLowerCase().trim() + (type !== undefined ? " : " + type + " {" : " {"))
            contents.forEach(entry => _enum.push(indent2 + "case " + entry))
            _enum.push(indent1 + "}")
            return _enum
        }


        let contents = []
        contents.push("import UIKit")
        contents.push("class R { ")

        Object.values(generated.resources.rawResources).forEach(res => contents.push(indent1 + "static let " + res.key.trim().toLowerCase() + " = " + res.key.trim() + "()"))
        Object.values(generated.resources.resources).forEach(res => contents.push(...getEnum(res.key, res.values, "String")))
        contents.push(...getEnum("image", generated.image, "String"))
        contents.push(...getEnum("string", generated.string, "String"))
        contents.push(...getEnum("id", [...new Set(Object.values(generated.identifiers).flatMap(entry => entry.id))], "String"))

        contents.push(indent1 + "enum layout {")
        Object.values(generated.resources.layout).flatMap(layouts => layouts).forEach(layout => contents.push(indent2 + "static let " + lowercaseFirst(layout) + " = " + layout.trim() + "()"))
        contents.push(indent1 + "}")

        contents.push(indent1 + "enum event {")
        let events = [...new Set(Object.values(generated.identifiers).flatMap(entry => entry.event))]
        events.forEach(entry => contents.push(indent2 + "case " + entry))
        contents.push(indent2 + "enum plain : String {")
        events.forEach(entry => contents.push(indent3 + "case " + entry.replace("(Any)", "")))
        contents.push(indent2 + "}")

        contents.push(indent2 + "var plainEvent : R.event.plain {")
        contents.push(indent3 + "switch self {")
        events.forEach(entry => contents.push(indent3 + "case ." + entry.replace("(Any)", "") + ": return R.event.plain." + entry.replace("(Any)", "")))
        contents.push(indent3 + "}")

        contents.push(indent2 + "}")
        contents.push(indent1 + "}")
        contents.push("}")
        contents.push("@objcMembers class ResourcePool : NSObject {")
        Object.values(generated.resources.resources).forEach(res => contents.push(indent1 + "static let " + res.key.trim().toLowerCase() + " = " + res.key.trim() + "()"))
        contents.push("}")

        Object.values(generated.resources.resources).forEach(res => {
            contents.push("extension R." + res.key.trim().toLowerCase() + " {")
            contents.push(indent1 + "func get<T>() -> T! {")
            contents.push(indent2 + "return (ResourcePool." + res.key.trim().toLowerCase() + ".value(forKey: self.rawValue) as! T)")
            contents.push(indent1 + "}")
            contents.push("}")
        })


        execCommand("find ${PWD} -name R.swift").then(({stdout}) => {
            let paths = stdout.split("\n").filter(file => file.length > 0)
            Promise.map(paths, path => writeFile(path, contents.join("\n")))
                .then(resolve)
                .catch(reject)
        })

    })
}

const buildDependencies = function(generated) {
    return new Promise((resolve, reject) => {

        let indent1 = "    "
        let indent2 = "        "
        let indent3 = "            "

        let contents = []
        contents.push("import Foundation")
        contents.push("class Injector{")
        contents.push(indent1 + "public static let dependencies : Dictionary<Injector.classes,()->AnyObject> = [")
        Object.values(generated.dependencies).forEach(dep => {
            dep.values.forEach(val => {
                switch (val.type) {
                    case DEPENDENCYTYPE.SINGLETON :
                        contents.push(indent2 + "." + val.class + " : { return "+ dep.class.trim() +"." + val.name + " },")
                        break

                    case DEPENDENCYTYPE.INSTANCE :
                        // TODO Instance injection
                        break
                }
            })
        })
        if(Object.values(generated.dependencies).length == 0) contents.push(indent2 + ":")
        contents.push(indent1 + "]")
        contents.push("}")

        contents.push("extension Injector{")
        contents.push(indent1 + "enum classes : String {")
        Object.values(generated.dependencies).forEach(dep => {
            dep.values.forEach(val => contents.push(indent2 + "case " + val.class))
        })
        contents.push(indent2 + "case none")
        contents.push(indent2 + "static func fromClassName(_ name : String) -> classes {")
        contents.push(indent3 + "return Injector.classes(rawValue : name) ?? .none")
        contents.push(indent2 + "}")
        contents.push(indent1 + "}")
        contents.push("}")

        contents.push("open class DependencyModule{}")
        contents.push("func inject<T>() -> T {")
        contents.push(indent1 + "return inject(String(describing : T.self))")
        contents.push("}")
        contents.push("func inject<T>(_ c : T.Type) -> T {")
        contents.push(indent1 + "return inject(String(describing : c))")
        contents.push("}")
        contents.push("private func inject<T>(_ name : String) -> T {")
        contents.push(indent1 + "if let dep : ()->AnyObject =  Injector.dependencies[Injector.classes.fromClassName(name)], let obj = dep() as? T {")
        contents.push(indent2 + "return obj")
        contents.push(indent1 + "}")
        contents.push(indent1 + "fatalError(\"dependency for \\(name).self not found\")")
        contents.push("}")

        execCommand("find ${PWD} -name Injector.swift").then(({stdout}) => {
            let paths = stdout.split("\n").filter(file => file.length > 0)
            Promise.map(paths, path => writeFile(path, contents.join("\n")))
                .then(resolve)
                .catch(reject)
        })
    })
}

const save = function([generated, result]) {
    console.log("Changes found in : " + result)
    return new Promise((resolve, reject) => {
        writeFile(targetName + '.local.json', JSON.stringify(generated))
           .then(() => {
               let promises = []
               switch (result) {
                   case CHANGETYPE.ALL :
                       promises.push(buildResources(generated))
                       promises.push(buildDependencies(generated))
                       break
                   case CHANGETYPE.DEPENDENCIES :
                       promises.push(buildDependencies(generated))
                       break
                   case CHANGETYPE.RESOURCES :
                       promises.push(buildResources(generated))
                       break
                   case CHANGETYPE.NONE : return resolve()
               }

               Promise.all(promises)
                   .then(resolve)
                   .catch(reject)

            })
            .catch(reject)
    })
}

const checkDiff = function([targetFiles, changedFiles, storedSet, strings, images, resources, dependencies]) {
    return new Promise((resolve, reject) => {
        let filesToProcess = targetFiles.filter(name => (storedSet.identifiers || {})[name] == undefined)
        changedFiles = changedFiles.filter(name => targetFiles.includes(name))
        filesToProcess = [...new Set(filesToProcess.concat(changedFiles))]
        console.log("all files loaded in " + (Date.now() - startTime) / 1000 + "s")
        console.log("Files to process found : " + filesToProcess.length)
        if(filesToProcess.length > 0) {
            Promise.map(filesToProcess, file => extractIdentifiers(file)).then(result => {
                let generated = {
                    image : images,
                    string : strings,
                    dependencies : Object.assign({}, storedSet.dependencies || {}, dependencies),
                    resources : Object.assign({}, storedSet.resources || {}, resources),
                    identifiers : Object.assign({}, storedSet.identifiers || {}, result.reduce((acc, file) => {
                        acc[file.file] = { event : file.event, id : file.id}
                        return acc
                    },{}))
                }
                compareSets(storedSet, generated).then(result => {
                    console.log("all resources compared in " + (Date.now() - startTime) / 1000 + "s")
                    resolve([generated, result])
                }).catch(reject)
            }).catch(reject)
        } else {
            resolve([storedSet, CHANGETYPE.NONE])
        }

    })
}

const writeReport = function() {
    return writeFile('report.local.json', JSON.stringify({
        lastTarget : targetName
    }))
}



parseProject
    .then(dataSets)
    .then(checkDiff)
    .then(save)
    .then(writeReport)
    .then(() => {
        deleteFile('project.local.json')
        console.log("done in " + (Date.now() - startTime) / 1000 + "s")
    })
    .catch(console.log)

/*
    Script für DI instances anpassen'
 */
