--[[
Title: Programming Style Exercise - TheOne
Authors: Hugo Rodrigues Manhães (Reviewer), Jordan Rodrigues Rangel (Writer)
Date: 04/05/2017
Version: 1.0
Size: 8.180 bytes
]]--

local TheOne = {}
TheOne.__index = TheOne

function TheOne.new(value)
	--[[
	Pre-condition:
	Post-condition:	Returns a new table with the parameter "value" as a key-value pair.
					This table is configured with the metatable that defines the methods for
					the implementation of the "The One" style.
	Argumentation:	The native method "setmetatable" is used with the wanted pair and the "TheOne" prototype table.
	]]--

	return setmetatable({value = value}, TheOne)
end

function TheOne:bind(functionToBind)
	--[[
	Pre-condition:	"functionToBind" must be a function.
	Post-condition:	The "value" property of the self table is updated with return of the "functionToBind", which
					is called with old value of the "value" property. The updated table is returned.
	Argumentation:	There is an assignment done which updates the "value" property with the return of "functionToBind".
					Then the self table is returned.
	]]--

	self.value = functionToBind(self.value)
	return self
end

function TheOne:printSelf()
	--[[
	Pre-condition:
	Post-condition:	The "value" property of the self table is printed.
	Argumentation:	The native function "print" is called with the "value" property as argument.
	]]--

	print(self.value)
end

function readFile(pathToFile)
	--[[
	Pre-condition: The function receives a valid non-empty string that
				   corresponds to a valid existent text file.
	Post-condition: The function correctly reads the file and has put all
				   its' contents to a string.
	Argumentation: Considering that the pre-condition is true, the call to the
				   native function io.open is correct, because it receives
				   a valid path to a file, therefore it will correctly
				   open the file. The read function is also working correctly
				   because the file variable is correctly a opened file.
	]]--

	local file = io.open(pathToFile, "rb")

	local stringData = file:read("*all")

	return stringData
end

function filterChars(stringData)
	--[[
	Pre-condition:	The function receives the entire contents
					of a file on a string
    Post-condition:	The function has taken out all non-alphanumeric
					characters and substituted them with a white space.
	Argumentation:	Considering that the pre-condition is true, the string
					is non-empty and as such, the native gsub function will
					work, since the Regular Expression is equivalent to all
					non-alphanumeric characters, and the substitution is the
					white space.
	]]--

	filteredString = string.gsub(stringData, '[^a-zA-Z0-9]', ' ')

	return filteredString
end

function normalizeString(filteredString)
	--[[
	Pre-condition: "filteredString" is a string composed by words separated by white spaces.
	Post-condition:	Returns a string with all uppercase letters from "filteredString" substituted with their lowercase counterparts.
	Argumentation:	The native function "string.lower" is called with the "filteredString" as argument.
	]]--

	return string.lower(filteredString)
end

function scan(stringData)
	--[[
	Pre-condition:	"filteredString" is a string composed by words separated by white spaces with all characters lowercase.
	Post-condition:	The function generates a table in which every entry
					is a word of the original string.
	Argumentation:	Considering that the pre-condition is true, the string 
					will have all words separated by white spaces, which is
					the pre-requisite for the native function gmatch to get
					all words, which in turn will have the "for" insert all
					words into the table that is the return value of the function.
	]]--

	wordTable = {}

	for i in string.gmatch(stringData, "%S+") do
		table.insert(wordTable, i)
	end

	return wordTable
end

function removeStopWords(wordTable)
	--[[
	Pre-condition:	Every element of the table passed as an argument is a lowercase word.
	Post-condition:	The returned table has all the original elements of the
					original table save for all stop words contained in the stop_words.txt file.
	Argumentation:	The same argumentation of the readFile function can be made for 
					the opening of the stop_words file. Considering this to be true, the 
					stringData will contain all stop words. By the same argumentation of 
					the scan function, the stopWordsTable variable will have all stop words as
					elements of the table. Considering this to also be true, then the nested
					"for" loop will, for every word of the argument table, search for its'
					existence in the stop words table. If it is, it won't be put in the
					returned table. This will lead to the post-condition.
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
	Pre-condition:	The argument table will have only non-stop words as its' elements.
	Post-condition:	The returned table will have pairs of word/frequency, in which each frequency
					will be correctly the correponding number of occurrences of said word in the argument table.
	Argumentation:	The "for" parses through the entirety of the table elements only once,
					and as such it will only count each occurrence once, and so by the end
					of it, it will have correctly counted all occurrences of each word.
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
	Pre-condition:	The argument table has only word/frequency pairs for elements.
	Post-condition:	Takes a dictionary of words and their frequencies
					and returns a string with the concatenation of the
					25 most frequent words with their frequencies.
	Argumentation:	An array (table with indices and the correspondent elements instead key-value pairs)
					of tables that contains the words and their frequencies. This array is then sorted
					with the native sort function. A "compare" function is provided to order the array
					descendingly. The first 25 words are printed with their frequencies while the last "for"
					executed. There is a counter variable that checks if the limit of 25 is already achieved.
	]]--

	function compare(a,b)
		return wordFrequencies[a] > wordFrequencies[b]
	end

	local wordFrequenciesArray = {}

	for wordFrequency in pairs(wordFrequencies) do
		table.insert(wordFrequenciesArray, wordFrequency)
	end

	table.sort(wordFrequenciesArray,compare)

	twentyFifthFlag = 0
	top25SortedFrequenciesString = ""

	for _, k in pairs(wordFrequenciesArray) do
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
