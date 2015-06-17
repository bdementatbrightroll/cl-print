require 'net/http'
require 'rubygems'
require 'json'
require "open-uri"

DELAY = 3

HOST = "http://52.28.115.200"

SERVICE_URL = HOST + ":1337/cannes/photos"
DOWNLOAD_URL = HOST + "/cannes/uploads/"
DOWNLOAD_DIR =  Dir.pwd + "/photos/"
KNOWN_FILE = Dir.pwd + "/photos.txt"

while true do 

	# check for new photos
	url = URI.parse(SERVICE_URL)
	req = Net::HTTP::Get.new(url.to_s)
	begin
		res = Net::HTTP.start(url.host, url.port) { |http|
			http.request(req)
		}
	rescue
		sleep(DELAY)
		return;
	end
	
	photos = JSON.parse(res.body)
	known = File.readlines(KNOWN_FILE)
	toPrint = []

	# compare with locallly known
	for photo in photos do
		photo = photo[0]
		if known.include? (photo + "\n")
			next
		else 
			toPrint.push(photo)
			File.open(KNOWN_FILE, 'a') { |f| f.write(photo + "\n") }
		end
	end

	if toPrint.length == 0
		puts "No new photos! Trying again in " + DELAY.to_s + " seconds"
	else 
		puts "Printing " + toPrint.length.to_s + " photos"
	end

	for photo in toPrint
		
		fileName = photo + ".png";
		fileLocation = DOWNLOAD_DIR + fileName

		# download new photos
		open(DOWNLOAD_URL + photo + ".png") { |f|
			File.open(fileLocation, "wb") do |file|
				file.puts f.read
			end
		}
	
		command = [
				# "ColorModel=", # / Color Model: *RGB16
				# "CNIJProfileID=", # / ProfileID: *1 2 3 4 5 6 7 8 9
				"Resolution=600x600dpi", # / Output Resolution: 300x300dpi *600x600dpi
				"PageSize=Custom.102x155mm", # / PageSize: *Letter Letter.FullBleed Legal Tabloid Tabloid.FullBleed A5 A4 A4.FullBleed A3 A3.FullBleed 329x483mm 329x483mm.FullBleed B5 B4 4x6 4x6.FullBleed 5x7 5x7.FullBleed 8x10 8x10.FullBleed 10x12 10x12.FullBleed 89x127mm 89x127mm.FullBleed Postcard Postcard.FullBleed DoublePostcard Env10 EnvDL EnvYou4 98x190mm 55x91mm 55x91mm.FullBleed Custom.WIDTHxHEIGHT
				# "CNIJCartridge=", # / BJ Cartridge: *1
				"CNIJMediaType=0", # / Media Type: *0 50 51 63 42 68 28 8 56 27 54 7 16 18 36
				# "CNIJMediaSupply=", # / Paper Source: *7
				"CNIJPrintQuality=20", # / Quality: 0 5 10 *15 20
				"CNIJDitherPattern=2595", # / Halftoning: 2560 *2595
				# "CNIJGrayScale=", # / Grayscale Printing: *0 1
				"CNIJGamma2=22", # / Brightness: 14 *18 22
				"CNIJAmountOfExtension=3", # / Amount of Extension: 0 1 *2 3
				"CNIJMarginType=0", # / MarginType: *0 1
				# "CNIJPaperGapCommand=", # / PaperGapCommand: *10
				# "CNIJDiscTrayForm=", # / DiscTrayForm: *10
				# "CNIJBanner=", # / Banner: *5
				# "CNIJSGColorMode=", # / SGColorMode: *127
				# "CNIJISaveMode=", # / ISaveMode: *30
				# "CNIJMediaGroup=", # / MediaGroup: *99
				# "CNIJDuplexSurface=", # / DuplexSurface: *0
				# "CNIJDataDirection=", # / DataDirection: *0
				# "CNIJSpecialMode=", # / SpecialMode: *0
				# "CNIJManualSelectSupply=", # / ManualSelectSupply: *10
				# "CNIJIntent2=", # / Color Mode: *1
				# "CNIJBlackAdjustment=", # / BlackAdjustment: *10
				# "CNIJEmergencyMode=", # / EmergencyMode: *127
				# "CNIJLongLifeMode=", # / LongLifeMode: *30
				# "CNIJCartridgeSelect=", # / CartridgeSelect: *0
				"CNIJPrintMode2=5", # / Print Quality: 1 *2 3 5
				# "CNIJPZVividPosiProcess=", # / Vivid Photo: *0
				# "CNIJGrayScaleCheckBox=", # / Grayscale Printing: *0 1
				"CNIJPQualitySlider=5", # / Quality: 1 2 *3 4 5
				# "CNIJHalfToneRadio=", # / Halftoning: 1 *2
				# "CNIJMediaSupplyMenuItem=", # / MediaSupplyMenuItem: *1
				# "CNIJProfileType=", # / ProfileType: 0 *1
				# "CNIJPDEEnable=", # / PDEEnable: 0 *1
				# "CNIJRGB2GrayConvert=", # / RGB2GrayConvert: *0 1
				# "CNIJPreviewSampleType=", # / Sample Type: *1 3 4
				# "CNIJColorPatternCheckBox=", # / View Color Pattern: *0 1
				# "CNIJColorAdjustMode=", # / ColorAdjustMode: *1
				# "CNIJMediaSense=", # / MediaSense: *10
				# "CNIJStapleSide=3", # / Stapling Side: *1 2 3 4
				# "CNIJExtDDIStapleMarginSupport=", # / ExtDDIStapleMarginSupport: *1
				# "CNIJExtDDISupportAppType=", # / ExtDDISupportAppType: *1
				# "CNIJTableSwitchInfo=", # / TableSwitchInfo: *0
			]

		command = "lpr -o" + command.join(" -o ") + " " + fileLocation
		puts command
		system(command) or raise "Printing failed!"
	end
	sleep(DELAY)
end