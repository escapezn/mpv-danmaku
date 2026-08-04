-- local utils = require 'mp.utils'
-- local directory = mp.find_config_file(".")
-- local direc = utils.split_path(directory)
local directory = mp.get_script_directory()
local py_path = directory .. "\\danmaku2ass.py"
local py_path2 = directory .. "\\niconvert.pyw"
local xmlfile = nil
local assfile = nil
local created_files = {}
local find_cmd = { 'python', '-X', 'utf8', '-c', [==[
import sys, glob, os
d = sys.argv[1]
fs = [f for f in glob.glob(os.path.join(d, '*.xml')) if os.path.isfile(f)]
print(max(fs, key=os.path.getmtime) if fs else '')
]==], directory }
-- local cookie = directory .. "\\bilibili.com_cookies.txt"

function findxml(callback)
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = find_cmd
	},function(success, result, error)
		local path = nil
		if success and result.status == 0 and result.stdout then
			path = result.stdout:gsub("%s+$", "")
			if path == "" then path = nil end
		end
		callback(path)
	end)
end

function handle_downloaded()
	findxml(function(path)
		if not path then
			mp.commandv("vf", "clr", "")
			return
		end
		xmlfile = path
		assfile = path:gsub("%.xml$", ".ass")
		created_files[xmlfile] = true
		created_files[assfile] = true
		local convert = { 'python', py_path, '-o', assfile, '-s', '1920x1080', '-fs', '63', '-a', '0.95', '-dm', '10', xmlfile }
		local convert2 = { 'python', py_path2, '-o', assfile, '+f', 'sans-serif', '+s', '63', '+l', '0', '+a', 'async', xmlfile }
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
			end) end
		end)
	end)
end

function loadsub()
	local biliurl = mp.get_property("path")
	local download = { 'yt-dlp', biliurl, '--skip-download', '--write-subs', '--retries', '3', '--paths', directory }
	if biliurl:lower():match("bilibili") ~= nil and biliurl:lower():match("http") ~= nil then
		mp.register_event("file-loaded", setvf)
		mp.command_native_async({
			name = 'subprocess',
			playback_only = false,
			capture_stdout = true,
			args = download
		},function(success, result, error)
			if result.status == 0 then
				handle_downloaded()
			else loadsub2() end
		end)
	else end
end

function loadsub2 ()
	local biliurl = mp.get_property("path")
	local download2 = { 'BBDown', biliurl, '--danmaku-only', '--work-dir', directory }
	mp.command_native_async({
		name = 'subprocess',
		playback_only = false,
		capture_stdout = true,
		args = download2
		},function(success, result, error)
			if result.status == 0 then
				handle_downloaded()
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
	for path in pairs(created_files) do
		os.remove(path)
		os.remove(path .. ".part")
	end
end

mp.register_event("start-file", loadsub)
mp.register_event("end-file", unloadsub)
mp.register_event("shutdown", clean)
-- mp.add_key_binding("B", loadsub)
