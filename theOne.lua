local TheOne = {}
TheOne.__index = TheOne

function TheOne.new(value)
	return setmetatable({value = value}, TheOne)
end

function TheOne:bind(functionToBind)
	self.value = functionToBind(self.value)
	return self
end

function TheOne:printSelf()
	print(self.value)
end

function readFile(pathToFile)
	--[[
	Takes a path to a file and returns the entire
	contents of the file as a string
	]]--
	
	local file = io.open(pathToFile, "rb")
	
	local stringData = file:read("*all")
	
	return stringData
end

function filterChars(stringData)
	--[[
	Takes a string and return a copy with all nonalphanumeric
	chars replaced by white space
	]]--
	
	filteredString = string.gsub(stringData, '[^a-zA-Z0-9]', ' ')
	
	return filteredString
end

function normalizeString(filteredString)
	return string.lower(filteredString)
end

function scan(stringData)
	--[[
	Takes a string and scans for words, returning
	a list of words.
	]]--
	
	wordTable = {}
	
	for i in string.gmatch(stringData, "%S+") do
		table.insert(wordTable, i)
	end
	
	return wordTable
end

function removeStopWords(wordTable)
	--[[
	Takes a list of words and returns a copy with all stop
	words removed
	]]--
	
	local file = io.open("stop_words.txt", "rb")
	
	local stringData = file:read("*all")
	
	local stopWordsTable = {}
	
	for stopWordsTableElement in string.gmatch(filterChars(stringData), "%S+") do
		table.insert(stopWordsTable, stopWordsTableElement)
	end
	
	lowercaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
	
	for letter in lowercaseAlphabet:gmatch"." do
		table.insert(stopWordsTable, letter)
	end
	
	local noStopWordsTable = {}
	
	for _, wordTableElement in pairs(wordTable) do
		belongsToTableFlag = true
		for _,stopWordsTableElement in pairs(stopWordsTable) do
			if stopWordsTableElement == wordTableElement then
				belongsToTableFlag = false
				break
			end
		end
		
		if belongsToTableFlag then
			table.insert(noStopWordsTable,wordTableElement)
		end
	end
	
	return noStopWordsTable
end

function frequencies(noStopWordsTable)
	--[[
	Takes a list of words and returns a dictionary associating
	words with frequencies of occurence
	]]--
	
	wordFrequencies = {}
	
	for _, word in pairs(noStopWordsTable) do
		if wordFrequencies[word] then
			wordFrequencies[word] = wordFrequencies[word] + 1
		else
			wordFrequencies[word] = 1
		end
	end
	
	return wordFrequencies
end

function top25SortedFrequencies(wordFrequencies)
	--[[
	Takes a dictionary of words and their frequencies
	and returns a string with the concatenation of the
	25 most frequent words with their frequencies.
	]]--
	
	function compare(a,b)
		return wordFrequencies[a] > wordFrequencies[b]
	end
	
	local tkeys = {}
	
	for k in pairs(wordFrequencies) do table.insert(tkeys, k) end
	
	table.sort(tkeys,compare)
	
	twentyFifthFlag = 0
	top25SortedFrequenciesString = ""
	
	for _, k in pairs(tkeys) do
		if twentyFifthFlag == 25 then
			break
		end
		top25SortedFrequenciesString = top25SortedFrequenciesString .. k .. " - " .. wordFrequencies[k] .. '\n'
		twentyFifthFlag = twentyFifthFlag + 1
	end
	
	return top25SortedFrequenciesString
end

local theOne = TheOne.new("text.txt")
theOne:bind(readFile)
theOne:bind(filterChars)
theOne:bind(normalizeString)
theOne:bind(scan)
theOne:bind(removeStopWords)
theOne:bind(frequencies)
theOne:bind(top25SortedFrequencies)
theOne:printSelf()