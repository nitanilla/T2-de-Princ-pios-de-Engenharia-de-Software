--[[
Title: Programming Style Exercise - Pipeline
Authors: Hugo Rodrigues Manhães (Writer), Jordan Rodrigues Rangel (Reviewer)
Date: 29/04/2017
Version: 1.0
Size: 8.192 bytes
]]--

function readFile(pathToFile)
	--[[
	Pre-condition: The function receives a valid non-empty string that
				   corresponds to a valid existent text file
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

function filterCharsAndNormalize(stringData)
	--[[
	Pre-condition: The function receives the entire contents
				   of a file on a string
    Post-condition: The function has taken out all non-alphanumeric
					characters and substituted them with a white space,
					and also substituted all uppercase letters with 
					their lowercase counterparts
	Argumentation: Considering that the pre-condition is true, the string
				   is non-empty and as such, the native gsub function will
				   work, since the Regular Expression is equivalent to all
				   non-alphanumeric characters, and the substitution is the
				   white space. The same can be said of the native lower function.
	]]--
	
	normalizedString = string.gsub(stringData, '[^a-zA-Z0-9]', ' ')
	normalizedString = string.lower(normalizedString)
	
	return normalizedString
end

function scan(stringData)
	--[[
	Pre-condition: The string has no non-alphanumeric characters separated by
				   white spaces and is all lowercase.
	Post-condition: The function generates a table in which every entry
					is a word of the original string.
	Argumentation: Considering that the pre-condition is true, the string 
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
	Pre-condition: Every element of the table passed as an argument
				   is a lowercase word.
	Post-condition: The returned table has all the original elements
				    of the original table save for all stop words contained
					in the stop_words.txt file.
	Argumentation: The same argumentation of the readFile function can be made for 
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
	
	stopWordsTable = {}
	
	--revisão Roxana
	--segundo o livro, neste estilo os caracteres alphanumericos não são filtrados da lista de stopwords
	--nesta mesma função, o lowercase deve ser aplicado nos stopwords
	--veja na página 41 do estilo a restrição do estilo "No shared state between functions"
	--a linha 99 o filterCharsAndNormalize() manda a lista de stopwords para ser filtrado e normalizado (lowercase)
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
	Pre-condition: The argument table will have only non-stop
				   words as its' elements.
	Post-condition: The returned table will have pairs of word/frequency,
					in which each frequency will be correctly the correponding
					number of occurrences of said word in the argument table.
	Argumentation: The "for" parses through the entirety of the table elements only once,
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

function printAllSorted(wordFrequencies)
	--[[
	Pre-condition: The argument table has only word/frequency pairs for elements.
	Post-condition: The function prints the 25 most frequent words and their 
					correspondent frequency.
	Argumentation: Considering that the compare function used in the native sort
				   function is correct, in the sense that it correctly points out
				   which of two words has more occurrences and thefore bigger frequency,
				   the sort function will correctly order the keyTable table. As such, 
				   since the "for" will pass through all elements of the keyTable table
				   in the correct order, it will correctly print the 25 most frequent words
				   and their frequencies.
	]]--
	
	function compare(a,b)
		return wordFrequencies[a] > wordFrequencies[b]
	end
	
	local keyTable = {}
	
	for key in pairs(wordFrequencies) do table.insert(keyTable, key) end
	
	table.sort(keyTable,compare)
	
	twentyFifthFlag = 0
	for _, key in pairs(keyTable) do
		if twentyFifthFlag == 25 then
			break
		end
		print(key .. " - " .. wordFrequencies[key])
		twentyFifthFlag = twentyFifthFlag + 1
	end
end

printAllSorted(frequencies(removeStopWords(scan(filterCharsAndNormalize(readFile("text.txt"))))))
