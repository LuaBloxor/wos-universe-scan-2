let entries = document.body.textContent.split("\n").map(x=>JSON.parse(x)) -- input from text file document
let systems = {}
entries.forEach(entry=>{
	for(coordinate in entry){
		systems[coordinate] = entry[coordinate]
	}
})
console.log(Object.keys(systems).length)
copy(systems) -- output to clipboard
