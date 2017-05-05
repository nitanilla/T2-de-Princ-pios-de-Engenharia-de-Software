function extractWords(pathToFile)
	--[[
	Pre-condition:	The function receives a valid non-empty string that
					corresponds to a valid existent text file.
	Post-condition:	The function returns a table with all words from the file pointed by
					"pathToFile", except for the non-alphanumeric characters and the words inside
					the "stop_words.txt" file. All words are in lowercase.
	Argumentation:	Files are open with the native function "file:read". All non-alphanumeric
					characters are substituted for white spaces with the native function "string.gsub".
					The words are then put inside tables with the help of the native function "string.gmatch",
					which splits the string into words separated by white spaces. The result is achieved
					by inserting the words inside a table except for all stop words.
	]]--
	
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
	--[[
	Pre-condition:	The argument table will have only non-stop words as its' elements.
	Post-condition:	The returned table will have pairs of word/frequency, in which each frequency
					will be correctly the correponding number of occurrences of said word in the argument table.
	Argumentation:	The "for" parses through the entirety of the table elements only once,
					and as such it will only count each occurrence once, and so by the end
					of it, it will have correctly counted all occurrences of each word.
	]]--
	
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
	--[[
	Pre-condition:	The argument table has only word/frequency pairs for elements.
	Post-condition:	Returns an array (table with indices and the correspondent elements instead key-value pairs)
					of tables that contains the words and their frequencies. This array is sorted in
					descending order.
	Argumentation:	The array is created by iterating over the "wordFrequencies" and inserting its key-value pairs
					as elements. The array is then sorted with the native "sort" function and the correspondent
					"compare" function.
	]]--
	
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
	--[[
	Pre-condition:	The parameter "trackedFunction" is a table containing a function and its name.
	Post-condition:	Returns a function which prints the time neeeded to execute the function wrapped inside "trackedFunction"
					and then returns its return value.
	Argumentation:	The "os.clock()" is checked before and after the execution of the function, which
					has its return value assigned into the local variable "returnValue".
					The execution time is printed with the native function "print" and then
					"returnValue" is returned.
	]]--
	
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