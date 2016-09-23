slv = slv or {}

slv.module_info = {
   name = "scintillua-verb",
   version = 0.1,
   date = "2016-09-23",
   description = "Using scintillua lexers to pretty print verbatim code",
   author = "Christophe Jorssen",
   copyright = "Christophe Jorssen",
   licence = "GNU General Public Licence version 3"
}

slv.lexer = require('lexers.lexer')

local write_nl = texio.write_nl

-- Should I consider the whole buffer or lines after lines?
local buffer = ""
local lines = {}

function slv.find_end_slv_environment(line)
   i, j = string.find(line, "\\end{slverbatim}")
   if i == nil then
      buffer = buffer .. line .. "\n"
      lines[#lines + 1] = line
      return ""
   else 
      return nil
   end
end

function slv.begin_buffer()
   buffer = ""
   lines = {}
   luatexbase.add_to_callback('process_input_buffer',
			      slv.find_end_slv_environment,
			      'Finds the end of the slverbatim environment')
end

function slv.end_buffer()
   luatexbase.remove_from_callback('process_input_buffer',
				   'Finds the end of the slverbatim environment')
   -- slv.lex(buffer)
   slv.lex(lines)
end

function slv.lex(tobelexed)
   if type(tobelexed) == "table" then
      local i, j
      local tokens
      for i = 1, #tobelexed do
	 write_nl(tobelexed[i])
	 tokens = slv.lexer[slv.currentlexer]:lex(tobelexed[i])
	 for j = 1, #tokens, 2 do
	    write_nl(tokens[j] .. '\t' .. tokens[j + 1])
	 end
      end
   else
      local tokens = slv.lexer[slv.currentlexer]:lex(buffer)
      local i
      for i = 1, #tokens, 2 do
	 write_nl(tokens[i] .. "\t" .. tokens[i + 1])
      end
   end
end

local nodenew = node.new
local nodecopy = node.copy
local nodetail = node.tail
local nodeinsertbefore = node.insert_before
local nodeinsertafter = node.insert_after
local noderemove = node.remove
local nodeid = node.id
local nodetraverseid = node.traverse_id
local nodeslide = node.slide

HHEAD = nodeid("hhead")
RULE = nodeid("rule")
GLUE = nodeid("glue")
WHATSIT = nodeid("whatsit")
PDF_COLORSTACK = node.subtype("pdf_colorstack")
PDF_LITERAL = node.subtype("pdf_literal")
GLYPH = nodeid("glyph")
GLUE = nodeid("glue")
PENALTY = nodeid("penalty")
GLUE_SPEC = nodeid("glue_spec")
KERN = nodeid("kern")
color_push = nodenew(WHATSIT, PDF_COLORSTACK)
color_pop = nodenew(WHATSIT, PDF_COLORSTACK)
color_push.stack = 0
color_pop.stack = 0
color_push.command = 1
color_pop.command = 2

-- Local Variables:
-- coding: utf-8-unix
-- End:
