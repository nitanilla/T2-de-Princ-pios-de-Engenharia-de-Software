--[[
Title: Programming Style Exercise - Things
Authors: Hugo Rodrigues Manhães (Writer), Jordan Rodrigues Rangel (Reviewer)
Date: 29/04/2017
Version: 1.0
Size: 8400 bytes
]]--

local DataStorageManager = {}
DataStorageManager.__index = DataStorageManager

function DataStorageManager.new(pathToFile)
	--[[
	Pre-condition: The function receives a valid non-empty string that
				   corresponds to a valid existent text file.
	Post-condition: The function generated a new DataStorageManager
					that contains a data element which contains the entire
					contents of the text file, whose path was passed as an
					argument, as a string.
	Argumentation: The function will correctly open the text file, given
				   that it is using native functions and that the pre-condition
				   is true. This in turn will make the data variable correctly be
				   the entire contents of the text file as a string. It the uses
				   the native setmetatable function, which will create the DataStorageManager
				   table.
	]]--
	local file = io.open(pathToFile, "rb")
	local fileData = file:read("*all")
	local fileDataFiltered = string.gsub(fileData, '[^a-zA-Z0-9]', ' ')
	return setmetatable({data = string.lower(fileDataFiltered)}, DataStorageManager)
end

function DataStorageManager:words()
	--[[
	Pre-condition: The DataStorageManager already has a data element that
				   correctly contains the entire contents of a text file
				   as a string.
    Post-condition: The function returns a table containing words of the
					data string as each element.
	Argumentation: Considering that the pre-condition is true, the data
				   element of DataStorageManager will have a string that
				   corresponds to the entire contents of a text file, and
				   since it is already filtered from when the DataStorageManager
				   was created, the native functions used in this function will 
				   correctly separate the words and put then into the returned
				   table.
	]]--
	
	wordTable = {}
	
	for i in string.gmatch(self.data, "%S+") do
		table.insert(wordTable, i)
	end
	return wordTable
end

local StopWordManager = {}
StopWordManager.__index = StopWordManager

function StopWordManager.new()
	--[[
	Pre-condition: A "stop_words.txt" text file exists and
				   it contains all stop words.
	Post-condition: The function returns a StopWordManager that
					contains a stopWords table, which contains stop
					words for elements.
	Argumentation: Considering that the pre-condition is true, it
				   will correctly open the stop_words.txt file since
				   it is correctly using native functions to open it.
				   As such, it will correctly fill the stopWordsTable
				   with stop words, given that it is using native
				   functions to parse the contents of the file text
				   that is turned into a string.
	]]--
	local stopWordsFile = io.open("stop_words.txt", "rb")
	local stopWordsFileData = stopWordsFile:read("*all")
	
	local stopWordsTable = {}
	
	local filteredStopWordsString = string.gsub(stopWordsFileData, '[^a-zA-Z0-9]', ' ')
	
	for stopWordsTableElement in string.gmatch(filteredStopWordsString, "%S+") do
		table.insert(stopWordsTable, stopWordsTableElement)
	end
	
	local lowercaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
	
	for letter in lowercaseAlphabet:gmatch"." do
		table.insert(stopWordsTable, letter)
	end
	
	return setmetatable({stopWords = stopWordsTable}, StopWordManager)
end

function StopWordManager:isStopWord(word)
	--[[
	Pre-condition: The function receives a non-empty string that
				   corresponds to a word. The StopWordManager table
				   has an element that contains all stop words in a
				   table.
	Post-condition: The function correctly identifies if the word
					passed as an argument is a stop word.
    Argumentation: Considering that the pre-condition is true, the 
				   stop words table will have all stop words, and as
				   such, it will parse through all stop words and then
				   correctly identify if it belongs to the table, which
				   will mean if it is a word stop or not.
	]]--
	for _,stopWord in pairs(self.stopWords) do
		if word == stopWord then
			return true
		end
	end
	
	return false
end

local WordFrequencyManager = {}
WordFrequencyManager.__index = WordFrequencyManager

function WordFrequencyManager.new()
	--[[
	Pre-condition: There's no relevant pre-condition.
	Post-condition: The function correctly creates a
					WordFrequencyManager which contains
					a wordFrequencies table which is empty.
	Argumentation: The function only uses native functions and as
				   such, it proves itself.
	]]--
	return setmetatable({wordFrequencies = {}},WordFrequencyManager)
end

function WordFrequencyManager:incrementCount(word)
	--[[
	Pre-condition: The function receives a non-empty word
	Post-condition: The function correctly increments the
					number of occurrences of the word passed
					as argument and store in its' correct index
					in the wordFrequencies table of the WordFrequencyManager.
	Argumentation: Considering the pre-condition to be true and that the
				   WordFrequencyManager has a non-empty WordFrequencies
				   table, it will correctly increment it given that it
				   will have a index for the word passed as argument.
	]]--
	if self.wordFrequencies[word] then
		self.wordFrequencies[word] = self.wordFrequencies[word] + 1
	else
		self.wordFrequencies[word] = 1
	end
end

function WordFrequencyManager:sorted()
	--[[
	Pre-condition: The wordFrequencies table is non-empty and is
				   filled with the correct number of occurences
				   for each word in its' correct index.
	Post-condition: The function will correctly order the returned
					wordKeyTable by frequency.
	Argumentation: Given that the compare function correctly tells
				   which of two words has the most number of occurences,
				   the native sort function will correctly order the
				   wordKeyTable.
	]]--
	function compare(a,b)
		return self.wordFrequencies[a] > self.wordFrequencies[b]
	end
	
	local wordKeyTable = {}
	
	for key in pairs(self.wordFrequencies) do table.insert(wordKeyTable, key) end
	
	table.sort(wordKeyTable,compare)
	
	return wordKeyTable
end

local WordFrequencyController = {}
WordFrequencyController.__index = WordFrequencyController

function WordFrequencyController.new(pathToFile)
	--[[
	Pre-condition: The function receives a valid non-empty string that
				   corresponds to a valid existent text file.
	Post-condition: The function creates a WordFrequencyController that
					contains a DataStorageManager, a StopWordManager and
					a WordFrequencyManager, all correctly initialized.
	Argumentation: Considering the pre-condition to be true, and given that
				   it either uses native functions or functions that are already
				   argumented, the post-condition proves itself.
	]]--
	return setmetatable({storageManager = DataStorageManager.new(pathToFile),
	                     stopWordManager = StopWordManager.new(),
						 wordFrequencyManager = WordFrequencyManager.new()},WordFrequencyController)
end

function WordFrequencyController:run()
	--[[
	Pre-condition: The WordFrequencyController is already initialized.
	Post-condition: The function prints the 25 most frequent words of a text file.
	Argumentation: Considering the pre-condition to be true, the post-condition proves
				   itself, considering that it uses only classes and functions that are
				   already argumented to do each step that leads to a sorted table. It then
				   iterates in a "for" to print the first 25 elements of the sorted table.
	]]--
	for _,word in pairs(self.storageManager:words()) do
		if not self.stopWordManager:isStopWord(word) then
			self.wordFrequencyManager:incrementCount(word)
		end
	end
	
	local wordKeyTable = self.wordFrequencyManager:sorted()
	
	twentyFifthFlag = 0
	top25SortedFrequenciesString = ""
	
	for _, key in pairs(wordKeyTable) do
		if twentyFifthFlag == 25 then
			break
		end
		top25SortedFrequenciesString = top25SortedFrequenciesString .. key .. " - " .. self.wordFrequencyManager.wordFrequencies[key] .. '\n'
		twentyFifthFlag = twentyFifthFlag + 1
	end
	
	print(top25SortedFrequenciesString)
end

WordFrequencyController.new("text.txt"):run()
--ver comentarios no pull-request
