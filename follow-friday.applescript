##############################################
-- Properties
##############################################
set AppleScript's text item delimiters to ","
property fileName : "Follow Friday Message.txt"
property newLine : "\n\n"

##############################################
-- List Handler
##############################################

-- Insert item into a list
on insertItemInList(theItem, theList, thePosition)
	set theListCount to length of theList
	if thePosition is 0 then
		return false
	else if thePosition is less than 0 then
		if (thePosition * -1) is greater than theListCount + 1 then return false
	else
		if thePosition is greater than theListCount + 1 then return false
	end if
	if thePosition is less than 0 then
		if (thePosition * -1) is theListCount + 1 then
			set beginning of theList to theItem
		else
			set theList to reverse of theList
			set thePosition to (thePosition * -1)
			if thePosition is 1 then
				set beginning of theList to theItem
			else if thePosition is (theListCount + 1) then
				set end of theList to theItem
			else
				set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
			end if
			set theList to reverse of theList
		end if
	else
		if thePosition is 1 then
			set beginning of theList to theItem
		else if thePosition is (theListCount + 1) then
			set end of theList to theItem
		else
			set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
		end if
	end if
	return theList
end insertItemInList

##############################################
-- File Reading and Writing
##############################################

-- Reading and Writing Params
on writeTextToFile(theText, theFile, overwriteExistingContent)
	try
		set theFile to theFile as string
		set theOpenedFile to open for access file theFile with write permission
		
		if overwriteExistingContent is true then set eof of theOpenedFile to 0
		write theText to theOpenedFile starting at eof
		close access theOpenedFile
		
		return true
	on error
		try
			close access file theFile
		end try
		
		return false
	end try
end writeTextToFile

-- Write to file
on writeFile(theContent, writable)
	set this_Story to theContent
	set theFile to (((path to desktop folder) as string) & fileName)
	writeTextToFile(this_Story, theFile, writable)
end writeFile

-- Open a File
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile

##############################################
-- Interact with the DOM
##############################################

-- Get Recently Interacted User
on getUser(instance)
	tell application "Safari"
		set theInput to do JavaScript "document.querySelectorAll('article > div > div + div a div + div span')[" & instance & "].innerText" in document 1
		
		return theInput
	end tell
end getUser

on iterateLoop(instance)
	set theCount to instance
	set theList to {}
	set AppleScript's text item delimiters to ", "
	
	repeat
		set updatedCount to (theCount + 1)
		try
			set rowData to getUser(updatedCount)
			if theList does not contain rowData then
				insertItemInList(rowData, theList, 1)
			end if
			set theCount to theCount + 1
		on error
			exit repeat
		end try
	end repeat
	
	return the reverse of theList as text
end iterateLoop

# Write to the file
on followFriday()
	set userNames to iterateLoop(-1) as text
	writeFile("Follow these awesome folks!" & newLine & iterateLoop(-1), false)
end followFriday

######
followFriday()
