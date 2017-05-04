function extractWords(pathToFile)
	local file = io.open(pathToFile, "rb")
	local fileData = file:read("*all")
	local fileDataFiltered = string.gsub(fileData, '[^a-zA-Z0-9]', ' ')
	local fileDataNormalized = string.lower(fileDataFiltered)
	
	local wordTable = {}
	
	for i in string.gmatch(fileDataNormalized, "%S+") do
		table.insert(wordTable, i)
	end
	
	local stopWordsFile = io.open("stop_words.txt", "rb")
	local stopWordsFileData = stopWordsFile:read("*all")
	local filteredStopWordsString = string.gsub(stopWordsFileData, '[^a-zA-Z0-9]', ' ')
	local stopWordsTable = {}
	
	for stopWordsTableElement in string.gmatch(filteredStopWordsString, "%S+") do
		stopWordsTable[stopWordsTableElement] = stopWordsTableElement
	end
	
	local lowercaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
	
	for letter in lowercaseAlphabet:gmatch"." do
		stopWordsTable[letter] = letter
	end
	
	local noStopWordsTable = {}
	
	for _, word in pairs(wordTable) do
		if not stopWordsTable[word] then
			table.insert(noStopWordsTable, word)
		end
	end
	
	return noStopWordsTable
end

function frequencies(wordList)
	local wordFrequencies = {}
	
	for _, word in pairs(wordList) do
		if wordFrequencies[word] then
			wordFrequencies[word] = wordFrequencies[word] + 1
		else
			wordFrequencies[word] = 1
		end
	end
	
	return wordFrequencies
end

function sort(wordFrequencies)
	local sortedWordFrequencies = {}
	
	for word, frequency in pairs(wordFrequencies) do
		table.insert(sortedWordFrequencies, {word = word, frequency = frequency})
	end
	
	function compare(a, b)
		return a.frequency > b.frequency
	end
	
	table.sort(sortedWordFrequencies, compare)
	
	return sortedWordFrequencies
end

function profile(trackedFunction)
	function profileWrapper(...)
		local startTime = os.clock()
		local returnValue = trackedFunction.functionWrap(...)
		local elapsedTime = os.clock() - startTime
		
		print(trackedFunction.name .. " took " .. elapsedTime .. " secs")
		
		return returnValue
	end
	
	return profileWrapper
end

local extractWordsWrap = {name = "extractWords", functionWrap = extractWords}
local frequenciesWrap = {name = "frequencies", functionWrap = frequencies}
local sortWrap = {name = "sort", functionWrap = sort}
local trackedFunctions = { extractWordsWrap, frequenciesWrap, sortWrap }

for _, trackedFunction in pairs(trackedFunctions) do
	_G[trackedFunction.name] = profile(trackedFunction)
end

local wordFrequencies = sort(frequencies(extractWords("text.txt")))
local wordFrequenciesPrinted = 0

for _, wordFrequency in pairs(wordFrequencies) do
	print(wordFrequency.word, wordFrequency.frequency)
	wordFrequenciesPrinted = wordFrequenciesPrinted + 1
	
	if wordFrequenciesPrinted == 25 then
		break
	end
end