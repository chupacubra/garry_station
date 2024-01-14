-- regex patterns
local pattern = {
	b        = "%[b%](%a+)%[%/b%]",
	i        = "%[i%](%a+)%[%/i%]",
	u        = "%[u%](%a+)%[%/u%]",
	s        = "%[s%](%a+)%[%/s%]",
	center   = "%[center%](%a+)%[%/center%]",
	img      = "%[img%]((?!%a+data:)%a+)%[%/img%]",
	youtube  = "%[youtube%](%w*?)%[%/youtube%]",
	youtube2 = "%[youtube width=(%d*?) height=(%d*?)%](%w*?)%[%/youtube%]",
	size     = "%[size=(%d*?)%](%a+)%[%/size%]",
	color    = "%[color=([#%w]*?)%](%a+)%[%/color%]",
	quote    = "%[quote%](%a+)%[%/quote%]",
	quote2   = "%[quote=(%w*?)%](%a+)%[%/quote%]",
	li       = "%[%*%](%a+)(?=\n%[%*%]|\n%[%/list%])",
	list     = "%[list%](%a+)%[%/list%]",
	list2    = "%[list=1%](%a+)%[%/list%]",
	list3    = "%[list=a%](%a+)%[%/list%]",
	n        = "\n(?![^%[]*%\[%\/code%\])",
	code     = "%\[code%\](%a+)%\[%\/code%\]",
	code2    = "%\[code=(%\w*?)%\](%a+)%\[%\/code%\]",

    sign     = "%[sign%]",
    time     = "%[time%]",
    write     = "%[write%]",
}

-- match replacements
local replace = {
	b        = [[<strong>%1</strong>]],
	i        = [[<em>%1</em>]],
	u        = [[<span style="text-decoration:underline;">%1</span>]],
	s        = [[<del">%1</del>]],
	center   = [[<div style="text-align:center;">%1</div>]],
	spoiler  = [[<span class="spoiler">%1</span>]],
	img      = [[<img src="%1" alt="" />]],
	youtube  = [[<iframe width="640" height="360" src="https://www.youtube.com/embed/%1" frameborder="0" allowfullscreen></iframe>]],
	youtube2 = [[<iframe width="%1" height="%2" src="https://www.youtube.com/embed/%3" frameborder="0" allowfullscreen></iframe>]],
	size     = [[<span style="font-size:%1%%; line-height:normal;">%2</span>]],
	color    = [[<span style="color:%1;">%2</span>]],
	quote    = [[<quote>%1</quote>]],
	quote2   = [[<quote><cite>%1</cite>%2</quote>]],
	li       = [[<li>%1</li>]],
	list     = [[<ul style="list-style-type:disc;">%1</ul>]],
	list2    = [[<ol style="list-style-type:decimal;">%1</ol>]],
	list3    = [[<ol style="list-style-type:lower-alpha;">%1</ol>]],
	n        = [[<br />]] .. "\n",
	code     = [[<pre><code class="nohighlight">%1</code></pre>]],
	code2    = [[<pre><code class="%1">%2</code></pre>]],
}

local bbcode = {
	-- Process `b` tag
	b = function(text)
		return string.gsub(text, pattern.b, replace.b)
	end,
	-- Process `i` tag
	i = function(text)
		return string.gsub(text, pattern.i, replace.i)
	end,
	-- Process `u` tag
	u = function(text)
		return string.gsub(text, pattern.u, replace.u)
	end,
	-- Process `s` tag
	s = function(text)
		return string.gsub(text, pattern.s, replace.s)
	end,
	-- Process `center` tag
	center = function(text)
		return string.gsub(text, pattern.center, replace.center)
	end,
	-- Process `spoiler` tag
	spoiler = function(text)
		return string.gsub(text, pattern.spoiler, replace.spoiler)
	end,
	-- Process `img` tag
	img = function(text)
		return string.gsub(text, pattern.img, replace.img)
	end,
	-- Process `youtube` tag
	youtube = function(text)
		text = string.gsub(text, pattern.youtube,  replace.youtube)
		text = string.gsub(text, pattern.youtube2, replace.youtube2)
		return text
	end,
	-- Process `size` tag
	size = function(text)
		return string.gsub(text, pattern.size, replace.size)
	end,
	-- Process `color` tag
	color = function(text)
		return string.gsub(text, pattern.color, replace.color)
	end,
	-- Process `quote` tag
	quote = function(text)
		text = string.gsub(text, pattern.quote,  replace.quote)
		text = string.gsub(text, pattern.quote2, replace.quote2)
		return text
	end,
	-- Process `list` tag
	list = function(text)
		text = string.gsub(text, pattern.li,    replace.li)
		text = string.gsub(text, pattern.list,  replace.list)
		text = string.gsub(text, pattern.list2, replace.list2)
		text = string.gsub(text, pattern.list3, replace.list3)
		return text
	end,
	-- Process `n` tag
	-- Convert all `\n` characters to `<br />` except within a code tag!
	-- Make sure to run this at the end, but before `code`
	n = function(text)
		return string.gsub(text, pattern.n, replace.n)
	end,
	-- Process `code` tag
	-- Designed to work with highlight.js (http://highlightjs.org)
	code = function(text)
		text = string.gsub(text, pattern.code,  replace.code,  nil, cf)
		text = string.gsub(text, pattern.code2, replace.code2)
		return text
	end,

    -- PAPERWORK TAGS
    sign = function(text, ply)
        --if CLIENT then return text end
        local name = ""
        if SERVER then
            name = ply:GS_GetName()
        else
            -- we dont have info about our char in client 
        end
        if name == nil then return text end
        return string.gsub(text, pattern.sign, "<span style='font-size:125%;font-family: Bell MT,serif;'>"..name.."</span>")
    end,

    time = function(text, ply)
        //if CLIENT then return text end
        return string.gsub(text, pattern.time, getGameTimeStamp())
    end,

    write = function(text, ply)
        //if CLIENT then return text end
        return [[<a href="javascript:paper.luaprint(']]..gentocken()..[[')">Write</a>]]
    end,
}

-- Process select tags
function BBCProccesing(text, tags, ply)
	for category, tag in pairs(BBCode[tags]) do
        if category == "paperwork_only" then
            text = bbcode[tag] and bbcode[tag](text, ply) or text
        else
		    text = bbcode[tag] and bbcode[tag](text) or text
        end
    end
	return text
end

-- Add new tags
function BBCExtend(tag, patt, repl)
	if type(tag) == "string" and type(patt) == "string" then
	    if type(repl) == "string" then
            pattern[tag] = patt
            replace[tag] = repl
            bbcode[tag]  = function(text)
                return string.gsub(text, pattern[tag], replace[tag])
            end
        elseif type(repl) == "function" then
            pattern[tag] = patt
            bbcode[tag]  = repl
        end
	end
end

-- Some defaults
local basic = {
	"b",
	"i",
	"u",
	"s",
	"quote",
}

local all = {
	"b",
	"i",
	"u",
	"s",
	"center",
	"spoiler",
	"img",
	"youtube",
	"size",
	"color",
	"quote",
	"list",
	"n",
	"code"
}

local text_only = {
	"b",
	"i",
	"u",
	"s",
	"center",
	"spoiler",
	"size",
	"color",
	"quote",
}

local embed_only = {
	"img",
	"youtube"
}

local paperwork_only = {
    "sign",
    "time",
    "write",
}

BBCodeTags = {
    basic = basic,
    all = all,
    text_only = text_only,
    embed_only = embed_only,
    paperwork_only = paperwork_only,
}

--[[
return setmetatable({
	_LICENSE     = "MIT/X11",
	_URL         = "https://github.com/karai17/lua-bbcode",
	_VERSION     = "1.0",
	_DESCRIPTION = "BBCode parser for Lua.",
	extend       = extend,
	all          = all,
	text_only    = text_only,
	embed_only   = embed_only,
	basic        = basic
}, {
	__call = function(_, ...) return process(...) end
})
--]]
