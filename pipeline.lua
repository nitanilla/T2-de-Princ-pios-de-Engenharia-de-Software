function readFile(pathToFile)
	--[[
	Takes a path to a file and returns the entire
	contents of the file as a string
	]]--
	
	local file = io.open(pathToFile, "rb")
	
	local stringData = file:read("*all")
	
	return stringData
end

function filterCharsAndNormalize(stringData)
	--[[
	Takes a string and return a copy with all nonalphanumeric
	chars replaced by white space
	]]--
	
	normalizedString = string.gsub(stringData, '[^a-zA-Z0-9]', ' ')
	normalizedString = string.lower(normalizedString)
	
	return normalizedString
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
	
	stopWordsTable = {}
	
	for stopWordsTableElement in string.gmatch(filterCharsAndNormalize(stringData), "%S+") do
		table.insert(stopWordsTable, stopWordsTableElement)
	end
	
	lowercaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
	
	for letter in lowercaseAlphabet:gmatch"." do
		table.insert(stopWordsTable, letter)
	end
	
	noStopWordsTable = {}
	
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

function printAllSorted(wordFrequencies)
	--[[
	Takes a dictionary of words and their frequencies
	and prints a list of pairs where the entries are 
	sorted by frequency
	]]--
	
	function compare(a,b)
		return wordFrequencies[a] > wordFrequencies[b]
	end
	
	local tkeys = {}
	
	for k in pairs(wordFrequencies) do table.insert(tkeys, k) end
	
	table.sort(tkeys,compare)
	
	twentyFifthFlag = 0
	for _, k in pairs(tkeys) do
		if twentyFifthFlag == 25 then
			break
		end
		print(k .. " - " .. wordFrequencies[k])
		twentyFifthFlag = twentyFifthFlag + 1
	end
end

printAllSorted(frequencies(removeStopWords(scan(filterCharsAndNormalize(readFile("text.txt"))))))