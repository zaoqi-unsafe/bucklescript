importScripts('./exports.js')
onmessage = function(e){
    var out = ocaml.compile(e.data[0])
    console.log(`webworker ${out}`)
    // postMessage([e.data[0]])
}
