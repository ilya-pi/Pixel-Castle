local json = require ("libs.dkjson")
local bmp = require ("libs.bmp")

local resourcesMapping = {
	{
		resourceFolder = "resources/castles",
		outputFileName = "output/castles.json"
	},
	{
		resourceFolder = "resources/clouds",
		outputFileName = "output/clouds.json"
	}
}

function saveToFile(string, fileName)
	local f,err = io.open(fileName, "w")
	if not f then return print(err) end
	f:write(string)
	f:close()
end

function scanDir(directory)
    local i, fileNames = 0, {}
    for filename in io.popen('ls -a "'..directory..'"'):lines() do
        i = i + 1
        fileNames[i] = filename
    end
    return fileNames
end

function stringEndsWith(s,suffix)
   return suffix=='' or string.sub(s,-string.len(suffix))==suffix
end

function processResourceFolder(resourceFolder, outputFile)
	local extension = "bmp"
	local bmpFileNames = {}
	local allBitmapsDataTable = {}

	local allFilesTable = scanDir(resourceFolder)
	for i,v in ipairs(allFilesTable) do
		if(stringEndsWith(v, extension)) then
			table.insert(bmpFileNames, v)
		end 
	end

	for i,fileName in ipairs(bmpFileNames) do
		local f = assert(io.open(resourceFolder.."/"..fileName, "rb"))
		local image = f:read("*a")
		f:close()

		local fileNameWithoutEx = string.sub(fileName, 1, -(string.len(extension)+2) )

		local bitmapDataTable = bmp.parseBitmap(image, fileNameWithoutEx)
		table.insert(allBitmapsDataTable, bitmapDataTable)
	end
		
	local bitmapsJsonTable = json.encode(allBitmapsDataTable, { indent = true })
	saveToFile(bitmapsJsonTable, outputFile)
end

function createAllResources(args)
	local currentDir = io.popen("pwd"):read("*l")
	print("current dir " .. currentDir)

	for i = 1, table.getn(resourcesMapping), 1 do
		processResourceFolder(currentDir.."/"..resourcesMapping[i].resourceFolder, currentDir.."/"..resourcesMapping[i].outputFileName)
	end
	--for mapping in resourcesMapping do
	--	processResourceFolder(currentDir.."/"..mapping.resourceFolder, currentDir.."/"..mapping.outputFileName)
	--end
end

createAllResources(nil)