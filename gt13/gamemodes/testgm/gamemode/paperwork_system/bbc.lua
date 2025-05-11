-- regex patterns
local pattern = {
	b        = "%[b%](.-)%[%/b%]",
	i        = "%[i%](.-)%[%/i%]",
	u        = "%[u%](.-)%[%/u%]",
	s        = "%[s%](.-)%[%/s%]",
	center   = "%[center%](.-)%[%/center%]",
	li       = "%[%*%](.-)%[%/%*%]",
	list     = "%[list%](.-)%[%/list%]",
	n        = "%[%n%]",
	code     = "%[code%](.-)%[%/code%]",

    sign     = "%[sign%]",
    time     = "%[time%]",
    write     = "%[write%]",
}

-- match replacements
local replace = {
	b        = [[<strong>%1</strong>]],
	i        = [[<em>%1</em>]],
	u        = [[<span style="text-decoration:underline;">%1</span>]],
	s        = [[<del>%1</del>]],
	center   = [[<div style="text-align:center;">%1</div>]],
	li       = [[<li>%1</li>]],
	list     = [[<ul style="list-style-type:disc;">%1</ul>]],
	n        = [[<br />]] .. "\n",
	code     = [[<pre><code class="nohighlight">%1</code></pre>]],
}

local bbcode = {
	-- Process `b` tag
	b = function(text)
		print(text, pattern.b, replace.b,  string.gsub(text, pattern.b, replace.b))
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
	-- Process `list` tag
	list = function(text)
		text = string.gsub(text, pattern.li,    replace.li)
		text = string.gsub(text, pattern.list,  replace.list)

		return text
	end,

	n = function(text)
		return string.gsub(text, pattern.n, replace.n)
	end,

	code = function(text)
		text = string.gsub(text, pattern.code,  replace.code )
		return text
	end,

    sign = function(text, ply)
        local name 
        if SERVER then
            name = ply:GS_GetName()
		end
        if name == nil then return text end
        return string.gsub(text, pattern.sign, "<span style='font-size:125%;font-family: Bell MT,serif;'>"..name.."</span>")
    end,

    time = function(text, ply)
        return string.gsub(text, pattern.time, getGameTimeStamp())
    end,

    write = function(text, ply)
        return string.gsub(text, pattern.write, [[<a href="javascript:paper.luaprint(']]..gentocken()..[[')">Write</a>]])
    end,
}


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
	"n",
	"center",
	"list",
}

local text_only = {
	"b",
	"i",
	"u",
	"s",
	"center",
}


local paperwork_only = {
    "sign",
    "time",
    "write",
}

local proccesing = {
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
	proccesing = proccesing
}


-- Process select tags
function BBCProccesing(text, tags, ply)
	print(text, tags, ply)
	for category, tag in pairs(BBCodeTags[tags]) do
		replf = bbcode[tag]
		if ply then
			text = replf(text, ply) or text
		else
			text = replf(text, ply) or text
		end
    end
	return text
end

/*
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
*/