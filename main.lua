-- local utils = require 'mp.utils'
-- local directory = mp.find_config_file(".")
-- local direc = utils.split_path(directory)
local directory = mp.get_script_directory()
local py_path = directory .. "\\danmaku2ass.py"
local py_path2 = directory .. "\\niconvert.pyw"
local xmlfile = directory .. "\\bilitemp.danmaku.xml"
local assfile = directory .. "\\bilitemp.ass"
local assfile2 = directory .. "\\bilitemp.danmaku.ass"
local xmlfiletemp = directory .. "\\bilitemp.danmaku.xml.part"
-- local cookie = directory .. "\\bilibili.com_cookies.txt"

function loadsub()
	local biliurl = mp.get_property("path")
	local download = { 'yt-dlp', biliurl, '--skip-download', '--write-subs', '--retries', '3', '--paths', directory, '--output', 'bilitemp.%(ext)s' }
	local convert = { 'python', py_path, '-o', assfile, '-s', '1920x1080', '-fs', '63', '-a', '0.95', '-dm', '10', xmlfile }
	local convert2 = { 'python', py_path2, '-o', assfile, '+f', 'sans-serif', '+s', '63', '+l', '0', '+a', 'async', xmlfile }
	if biliurl:lower():match("bilibili") ~= nil and biliurl:lower():match("http") ~= nil then
		mp.register_event("file-loaded", setvf)
		local method1 = mp.command_native_async({
			name = 'subprocess',
			playback_only = false,
			capture_stdout = true,
			args = download
		},function(success, result, error)
			if result.status == 0 then
				mp.command_native_async({
					name = 'subprocess',
					playback_only = false,
					capture_stdout = true,
					args = convert
				},function(success, result, error)
					if result.status == 0 then
						setsub()
					else mp.command_native_async({
						name = 'subprocess',
						playback_only = false,
						capture_stdout = true,
						args = convert2
					},function(success, result, error)
						if result.status == 0 then
							setsub()
						else end
					end) end
				end)
			else loadsub2() end
		end)
	else end
end

function loadsub2 ()
	local biliurl = mp.get_property("path")
	local download2 = { 'BBDown', biliurl, '--danmaku-only', '--work-dir', directory, '-F', 'bilitemp.danmaku' }
	local convert = { 'python', py_path, '-o', assfile, '-s', '1920x1080', '-fs', '63', '-a', '0.95', '-dm', '10', xmlfile }
	local convert2 = { 'python', py_path2, '-o', assfile, '+f', 'sans-serif', '+s', '63', '+l', '0', '+a', 'async', xmlfile }
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = download2
		},function(success, result, error)
			if result.status == 0 then
				mp.command_native_async({
					name = 'subprocess',
					playback_only = false,
					capture_stdout = true,
					args = convert
				},function(success, result, error)
					if result.status == 0 then
						setsub()
					else mp.command_native_async({
						name = 'subprocess',
						playback_only = false,
						capture_stdout = true,
						args = convert2
					},function(success, result, error)
						if result.status == 0 then
							setsub()
						else mp.commandv("vf", "clr", "") end
					  end)
					end
				  end)
			else mp.commandv("vf", "clr", "") end
		end)
end

function setsub()
	-- mp.set_property_native("options/sub-file-paths", directory)
	-- mp.set_property("sub-auto", "all")
	-- mp.commandv("rescan-external-files", "reselect")
	mp.commandv("sub-add", assfile)
	-- mp.register_event("file-loaded", setvf)
end

function setvf()
	local display = mp.get_property_number("display-fps")
	local arg3 = 'lavfi="fps=fps=' .. display .. ':round=down"'
	-- mp.msg.info(arg3)
	-- mp.observe_property("container-fps", "native", function(name, value)
	-- 	mp.msg.info(mp.get_property_native("container-fps"))
    --     if value < 58 then
	-- 		mp.commandv("vf", "set", arg3)
    --         mp.unobserve_property("container-fps")
    --     end
    -- end)
	-- local subinfo = mp.get_property("current-tracks/sub")
	-- mp.msg.info(subinfo)
	if mp.get_property_native("container-fps") < 58 then
		mp.commandv("vf", "set", arg3) end
end

function unloadsub()
	mp.set_property_native("options/sub-file-paths", "")
	mp.set_property("sub-auto", "fuzzy")
	mp.commandv("vf", "clr", "")
end

function clean()
    if assfile then
		os.remove(xmlfile)
        os.remove(assfile)
		os.remove(xmlfiletemp)
		os.remove(assfile2)
    end
end

mp.register_event("start-file", loadsub)
mp.register_event("end-file", unloadsub)
mp.register_event("shutdown", clean)
-- mp.add_key_binding("B", loadsub)
