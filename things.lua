local DataStorageManager = {}
DataStorageManager.__index = DataStorageManager

--[[Models the contents of the file]]--

function DataStorageManager.new(pathToFile)
	local file = io.open(pathToFile, "rb")
	local fileData = file:read("*all")
	local fileDataFiltered = string.gsub(fileData, '[^a-zA-Z0-9]', ' ')
	return setmetatable({data = string.lower(fileDataFiltered)}, DataStorageManager)
end

function DataStorageManager:words()
	--[[Returns the list words in storage]]--
	
	wordTable = {}
	
	for i in string.gmatch(self.data, "%S+") do
		table.insert(wordTable, i)
	end
	return wordTable
end

local StopWordManager = {}
StopWordManager.__index = StopWordManager

--[[Models the contents of the file]]--

function StopWordManager.new()
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
	for _,stopWord in pairs(self.stopWords) do
		if word == stopWord then
			return true
		end
	end
	
	return false
end

local WordFrequencyManager = {}
WordFrequencyManager.__index = WordFrequencyManager

--[[Keeps the word frequency data]]--

function WordFrequencyManager.new()
	return setmetatable({wordFrequencies = {}},WordFrequencyManager)
end

function WordFrequencyManager:incrementCount(word)
	if self.wordFrequencies[word] then
		self.wordFrequencies[word] = self.wordFrequencies[word] + 1
	else
		self.wordFrequencies[word] = 1
	end
end

function WordFrequencyManager:sorted()
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
	return setmetatable({storageManager = DataStorageManager.new(pathToFile),
	                     stopWordManager = StopWordManager.new(),
						 wordFrequencyManager = WordFrequencyManager.new()},WordFrequencyController)
end

function WordFrequencyController:run()
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