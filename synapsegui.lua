local ContentProvider = game:GetService("ContentProvider")
local HttpService = game:GetService("HttpService")

-- UTILS

local core_gui = game:GetService("CoreGui")
local core_packages = game:GetService("CorePackages")

local globals = [[

local function chat(msg)
	workspace.ChatWindow_MessagePosted:fire(msg)
end

]]

local load = coroutine.wrap(function()
	local compile = coroutine.wrap(function()
		local luaZ = {}
		local luaY = {}
		local luaX = {}
		local luaP = {}
		local luaU = {}
		local luaK = {}
		local size_size_t = 8

		local function lua_assert(test)
			if not test then error("assertion failed!") end
		end

		function luaZ:make_getS(buff)
			local b = buff
			return function()
				if not b then return nil end
				local data = b
				b = nil
				return data
			end
		end

		function luaZ:make_getF(source)
			local LUAL_BUFFERSIZE = 512
			local pos = 1

			return function() -- chunk reader anonymous function here
				local buff = source:sub(pos, pos + LUAL_BUFFERSIZE - 1)
				pos = math.min(#source + 1, pos + LUAL_BUFFERSIZE)
				return buff
			end
		end

		function luaZ:init(reader, data)
			if not reader then return end
			local z = {}
			z.reader = reader
			z.data = data or ""
			z.name = name
			if not data or data == "" then z.n = 0 else z.n = #data end
			z.p = 0
			return z
		end

		function luaZ:fill(z)
			local buff = z.reader()
			z.data = buff
			if not buff or buff == "" then return "EOZ" end
			z.n, z.p = #buff - 1, 1
			return string.sub(buff, 1, 1)
		end

		function luaZ:zgetc(z)
			local n, p = z.n, z.p + 1
			if n > 0 then
				z.n, z.p = n - 1, p
				return string.sub(z.data, p, p)
			else
				return self:fill(z)
			end
		end

		luaX.RESERVED = [[
TK_AND and
TK_BREAK break
TK_DO do
TK_ELSE else
TK_ELSEIF elseif
TK_END end
TK_FALSE false
TK_FOR for
TK_FUNCTION function
TK_IF if
TK_IN in
TK_LOCAL local
TK_NIL nil
TK_NOT not
TK_OR or
TK_REPEAT repeat
TK_RETURN return
TK_THEN then
TK_TRUE true
TK_UNTIL until
TK_WHILE while
TK_CONCAT ..
TK_DOTS ...
TK_EQ ==
TK_GE >=
TK_LE <=
TK_NE ~=
TK_NAME <name>
TK_NUMBER <number>
TK_STRING <string>
TK_EOS <eof>]]

		luaX.MAXSRC = 80
		luaX.MAX_INT = 2147483645
		luaX.LUA_QS = "'%s'"
		luaX.LUA_COMPAT_LSTR = 1

		function luaX:init()
			local tokens, enums = {}, {}
			for v in string.gmatch(self.RESERVED, "[^\n]+") do
				local _, _, tok, str = string.find(v, "(%S+)%s+(%S+)")
				tokens[tok] = str
				enums[str] = tok
			end
			self.tokens = tokens
			self.enums = enums
		end

		function luaX:chunkid(source, bufflen)
			local out
			local first = string.sub(source, 1, 1)
			if first == "=" then
				out = string.sub(source, 2, bufflen)
			else
				if first == "@" then
					source = string.sub(source, 2)
					bufflen = bufflen - #" '...' "
					local l = #source
					out = ""
					if l > bufflen then
						source = string.sub(source, 1 + l - bufflen) 
						out = out.."..."
					end
					out = out..source
				else 
					local len = string.find(source, "[\n\r]") 
					len = len and (len - 1) or #source
					bufflen = bufflen - #(" [string \"...\"] ")
					if len > bufflen then len = bufflen end
					out = "[string \""
					if len < #source then
						out = out..string.sub(source, 1, len).."..."
					else
						out = out..source
					end
					out = out.."\"]"
				end
			end
			return out
		end

		function luaX:token2str(ls, token)
			if string.sub(token, 1, 3) ~= "TK_" then
				if string.find(token, "%c") then
					return string.format("char(%d)", string.byte(token))
				end
				return token
			else
				return self.tokens[token]
			end
		end

		function luaX:lexerror(ls, msg, token)
			local function txtToken(ls, token)
				if token == "TK_NAME" or
					token == "TK_STRING" or
					token == "TK_NUMBER" then
					return ls.buff
				else
					return self:token2str(ls, token)
				end
			end
			local buff = self:chunkid(ls.source, self.MAXSRC)
			local msg = string.format("%s:%d: %s", buff, ls.linenumber, msg)
			if token then
				msg = string.format("%s near "..self.LUA_QS, msg, txtToken(ls, token))
			end
			error(msg)
		end

		function luaX:syntaxerror(ls, msg)
			self:lexerror(ls, msg, ls.t.token)
		end

		function luaX:currIsNewline(ls)
			return ls.current == "\n" or ls.current == "\r"
		end

		function luaX:inclinenumber(ls)
			local old = ls.current
			self:nextc(ls)
			if self:currIsNewline(ls) and ls.current ~= old then
				self:nextc(ls)
			end
			ls.linenumber = ls.linenumber + 1
			if ls.linenumber >= self.MAX_INT then
				self:syntaxerror(ls, "chunk has too many lines")
			end
		end

		function luaX:setinput(L, ls, z, source)
			if not ls then ls = {} end
			if not ls.lookahead then ls.lookahead = {} end
			if not ls.t then ls.t = {} end
			ls.decpoint = "."
			ls.L = L
			ls.lookahead.token = "TK_EOS" 
			ls.z = z
			ls.fs = nil
			ls.linenumber = 1
			ls.lastline = 1
			ls.source = source
			self:nextc(ls)
		end

		function luaX:check_next(ls, set)
			if not string.find(set, ls.current, 1, 1) then
				return false
			end
			self:save_and_next(ls)
			return true
		end

		function luaX:next(ls)
			ls.lastline = ls.linenumber
			if ls.lookahead.token ~= "TK_EOS" then
				-- this must be copy-by-value
				ls.t.seminfo = ls.lookahead.seminfo 
				ls.t.token = ls.lookahead.token
				ls.lookahead.token = "TK_EOS" 
			else
				ls.t.token = self:llex(ls, ls.t) 
			end
		end

		function luaX:lookahead(ls)

			ls.lookahead.token = self:llex(ls, ls.lookahead)
		end

		function luaX:nextc(ls)
			local c = luaZ:zgetc(ls.z)
			ls.current = c
			return c
		end

		function luaX:save(ls, c)
			local buff = ls.buff
			ls.buff = buff..c
		end

		function luaX:save_and_next(ls)
			self:save(ls, ls.current)
			return self:nextc(ls)
		end

		function luaX:str2d(s)
			local result = tonumber(s)
			if result then return result end
			if string.lower(string.sub(s, 1, 2)) == "0x" then
				result = tonumber(s, 16)
				if result then return result end
			end
			return nil
		end

		function luaX:buffreplace(ls, from, to)
			local result, buff = "", ls.buff
			for p = 1, #buff do
				local c = string.sub(buff, p, p)
				if c == from then c = to end
				result = result..c
			end
			ls.buff = result
		end

		function luaX:trydecpoint(ls, Token)
			local old = ls.decpoint
			self:buffreplace(ls, old, ls.decpoint)
			local seminfo = self:str2d(ls.buff)
			Token.seminfo = seminfo
			if not seminfo then
				self:buffreplace(ls, ls.decpoint, ".")
				self:lexerror(ls, "malformed number", "TK_NUMBER")
			end
		end

		function luaX:read_numeral(ls, Token)
			repeat
				self:save_and_next(ls)
			until string.find(ls.current, "%D") and ls.current ~= "."
			if self:check_next(ls, "Ee") then
				self:check_next(ls, "+-")
			end
			while string.find(ls.current, "^%w$") or ls.current == "_" do
				self:save_and_next(ls)
			end
			self:buffreplace(ls, ".", ls.decpoint)
			local seminfo = self:str2d(ls.buff)
			Token.seminfo = seminfo
			if not seminfo then
				self:trydecpoint(ls, Token) 
			end
		end

		function luaX:skip_sep(ls)
			local count = 0
			local s = ls.current
			self:save_and_next(ls)
			while ls.current == "=" do
				self:save_and_next(ls)
				count = count + 1
			end
			return (ls.current == s) and count or (-count) - 1
		end

		function luaX:read_long_string(ls, Token, sep)
			local cont = 0
			self:save_and_next(ls)
			if self:currIsNewline(ls) then
				self:inclinenumber(ls)
			end
			while true do
				local c = ls.current
				if c == "EOZ" then
					self:lexerror(ls, Token and "unfinished long string" or
						"unfinished long comment", "TK_EOS")
				elseif c == "[" then
					if self.LUA_COMPAT_LSTR then
						if self:skip_sep(ls) == sep then
							self:save_and_next(ls)
							cont = cont + 1
							if self.LUA_COMPAT_LSTR == 1 then
								if sep == 0 then
									self:lexerror(ls, "nesting of [[...]] is deprecated", "[")
								end
							end
						end
					end
				elseif c == "]" then
					if self:skip_sep(ls) == sep then
						self:save_and_next(ls)
						if self.LUA_COMPAT_LSTR and self.LUA_COMPAT_LSTR == 2 then
							cont = cont - 1
							if sep == 0 and cont >= 0 then break end
						end
						break
					end
				elseif self:currIsNewline(ls) then
					self:save(ls, "\n")
					self:inclinenumber(ls)
					if not Token then ls.buff = "" end
				else
					if Token then
						self:save_and_next(ls)
					else
						self:nextc(ls)
					end
				end
			end
			if Token then
				local p = 3 + sep
				Token.seminfo = string.sub(ls.buff, p, -p)
			end
		end

		function luaX:read_string(ls, del, Token)
			self:save_and_next(ls)
			while ls.current ~= del do
				local c = ls.current
				if c == "EOZ" then
					self:lexerror(ls, "unfinished string", "TK_EOS")
				elseif self:currIsNewline(ls) then
					self:lexerror(ls, "unfinished string", "TK_STRING")
				elseif c == "\\" then
					c = self:nextc(ls)
					if self:currIsNewline(ls) then 
						self:save(ls, "\n")
						self:inclinenumber(ls)
					elseif c ~= "EOZ" then
						local i = string.find("abfnrtv", c, 1, 1)
						if i then
							self:save(ls, string.sub("\a\b\f\n\r\t\v", i, i))
							self:nextc(ls)
						elseif not string.find(c, "%d") then
							self:save_and_next(ls)
						else
							c, i = 0, 0
							repeat
								c = 10 * c + ls.current
								self:nextc(ls)
								i = i + 1
							until i >= 3 or not string.find(ls.current, "%d")
							if c > 255 then
								self:lexerror(ls, "escape sequence too large", "TK_STRING")
							end
							self:save(ls, string.char(c))
						end
					end
				else
					self:save_and_next(ls)
				end
			end
			self:save_and_next(ls)
			Token.seminfo = string.sub(ls.buff, 2, -2)
		end

		function luaX:llex(ls, Token)
			ls.buff = ""
			while true do
				local c = ls.current
				if self:currIsNewline(ls) then
					self:inclinenumber(ls)
				elseif c == "-" then
					c = self:nextc(ls)
					if c ~= "-" then return "-" end
					local sep = -1
					if self:nextc(ls) == '[' then
						sep = self:skip_sep(ls)
						ls.buff = ""
					end
					if sep >= 0 then
						self:read_long_string(ls, nil, sep)
						ls.buff = ""
					else
						while not self:currIsNewline(ls) and ls.current ~= "EOZ" do
							self:nextc(ls)
						end
					end
				elseif c == "[" then
					local sep = self:skip_sep(ls)
					if sep >= 0 then
						self:read_long_string(ls, Token, sep)
						return "TK_STRING"
					elseif sep == -1 then
						return "["
					else
						self:lexerror(ls, "invalid long string delimiter", "TK_STRING")
					end
				elseif c == "=" then
					c = self:nextc(ls)
					if c ~= "=" then return "="
					else self:nextc(ls); return "TK_EQ" end
				elseif c == "<" then
					c = self:nextc(ls)
					if c ~= "=" then return "<"
					else self:nextc(ls); return "TK_LE" end
				elseif c == ">" then
					c = self:nextc(ls)
					if c ~= "=" then return ">"
					else self:nextc(ls); return "TK_GE" end
				elseif c == "~" then
					c = self:nextc(ls)
					if c ~= "=" then return "~"
					else self:nextc(ls); return "TK_NE" end
				elseif c == "\"" or c == "'" then
					self:read_string(ls, c, Token)
					return "TK_STRING"
				elseif c == "." then
					c = self:save_and_next(ls)
					if self:check_next(ls, ".") then
						if self:check_next(ls, ".") then
							return "TK_DOTS"
						else return "TK_CONCAT"
						end
					elseif not string.find(c, "%d") then
						return "."
					else
						self:read_numeral(ls, Token)
						return "TK_NUMBER"
					end
				elseif c == "EOZ" then
					return "TK_EOS"
				else
					if string.find(c, "%s") then
						self:nextc(ls)
					elseif string.find(c, "%d") then
						self:read_numeral(ls, Token)
						return "TK_NUMBER"
					elseif string.find(c, "[_%a]") then
						repeat
							c = self:save_and_next(ls)
						until c == "EOZ" or not string.find(c, "[_%w]")
						local ts = ls.buff
						local tok = self.enums[ts]
						if tok then return tok end
						Token.seminfo = ts
						return "TK_NAME"
					else
						self:nextc(ls)
						return c
					end
				end
			end
		end

		luaP.OpMode = { iABC = 0, iABx = 1, iAsBx = 2 }

		luaP.SIZE_C  = 9
		luaP.SIZE_B  = 9
		luaP.SIZE_Bx = luaP.SIZE_C + luaP.SIZE_B
		luaP.SIZE_A  = 8

		luaP.SIZE_OP = 6

		luaP.POS_OP = 0
		luaP.POS_A  = luaP.POS_OP + luaP.SIZE_OP
		luaP.POS_C  = luaP.POS_A + luaP.SIZE_A
		luaP.POS_B  = luaP.POS_C + luaP.SIZE_C
		luaP.POS_Bx = luaP.POS_C

		luaP.MAXARG_Bx  = math.ldexp(1, luaP.SIZE_Bx) - 1
		luaP.MAXARG_sBx = math.floor(luaP.MAXARG_Bx / 2)

		luaP.MAXARG_A = math.ldexp(1, luaP.SIZE_A) - 1
		luaP.MAXARG_B = math.ldexp(1, luaP.SIZE_B) - 1
		luaP.MAXARG_C = math.ldexp(1, luaP.SIZE_C) - 1

		function luaP:GET_OPCODE(i) return self.ROpCode[i.OP] end
		function luaP:SET_OPCODE(i, o) i.OP = self.OpCode[o] end

		function luaP:GETARG_A(i) return i.A end
		function luaP:SETARG_A(i, u) i.A = u end

		function luaP:GETARG_B(i) return i.B end
		function luaP:SETARG_B(i, b) i.B = b end

		function luaP:GETARG_C(i) return i.C end
		function luaP:SETARG_C(i, b) i.C = b end

		function luaP:GETARG_Bx(i) return i.Bx end
		function luaP:SETARG_Bx(i, b) i.Bx = b end

		function luaP:GETARG_sBx(i) return i.Bx - self.MAXARG_sBx end
		function luaP:SETARG_sBx(i, b) i.Bx = b + self.MAXARG_sBx end

		function luaP:CREATE_ABC(o,a,b,c)
			return {OP = self.OpCode[o], A = a, B = b, C = c}
		end

		function luaP:CREATE_ABx(o,a,bc)
			return {OP = self.OpCode[o], A = a, Bx = bc}
		end

		function luaP:CREATE_Inst(c)
			local o = c % 64
			c = (c - o) / 64
			local a = c % 256
			c = (c - a) / 256
			return self:CREATE_ABx(o, a, c)
		end

		function luaP:Instruction(i)
			if i.Bx then
				i.C = i.Bx % 512
				i.B = (i.Bx - i.C) / 512
			end
			local I = i.A * 64 + i.OP
			local c0 = I % 256
			I = i.C * 64 + (I - c0) / 256
			local c1 = I % 256
			I = i.B * 128 + (I - c1) / 256
			local c2 = I % 256
			local c3 = (I - c2) / 256
			return string.char(c0, c1, c2, c3)
		end

		function luaP:DecodeInst(x)
			local byte = string.byte
			local i = {}
			local I = byte(x, 1)
			local op = I % 64
			i.OP = op
			I = byte(x, 2) * 4 + (I - op) / 64
			local a = I % 256
			i.A = a
			I = byte(x, 3) * 4 + (I - a) / 256
			local c = I % 512
			i.C = c
			i.B = byte(x, 4) * 2 + (I - c) / 512
			local opmode = self.OpMode[tonumber(string.sub(self.opmodes[op + 1], 7, 7))]
			if opmode ~= "iABC" then
				i.Bx = i.B * 512 + i.C
			end
			return i
		end

		luaP.BITRK = math.ldexp(1, luaP.SIZE_B - 1)

		function luaP:ISK(x) return x >= self.BITRK end

		function luaP:INDEXK(r) return x - self.BITRK end

		luaP.MAXINDEXRK = luaP.BITRK - 1

		function luaP:RKASK(x) return x + self.BITRK end

		luaP.NO_REG = luaP.MAXARG_A

		luaP.opnames = {} 
		luaP.OpCode = {} 
		luaP.ROpCode = {} 

		local i = 0
		for v in string.gmatch([[
MOVE LOADK LOADBOOL LOADNIL GETUPVAL
GETGLOBAL GETTABLE SETGLOBAL SETUPVAL SETTABLE
NEWTABLE SELF ADD SUB MUL
DIV MOD POW UNM NOT
LEN CONCAT JMP EQ LT
LE TEST TESTSET CALL TAILCALL
RETURN FORLOOP FORPREP TFORLOOP SETLIST
CLOSE CLOSURE VARARG
]], "%S+") do
			local n = "OP_"..v
			luaP.opnames[i] = v
			luaP.OpCode[n] = i
			luaP.ROpCode[i] = n
			i = i + 1
		end
		luaP.NUM_OPCODES = i
		luaP.OpArgMask = { OpArgN = 0, OpArgU = 1, OpArgR = 2, OpArgK = 3 }

		function luaP:getOpMode(m)
			return self.opmodes[self.OpCode[m]] % 4
		end

		function luaP:getBMode(m)
			return math.floor(self.opmodes[self.OpCode[m]] / 16) % 4
		end

		function luaP:getCMode(m)
			return math.floor(self.opmodes[self.OpCode[m]] / 4) % 4
		end

		function luaP:testAMode(m)
			return math.floor(self.opmodes[self.OpCode[m]] / 64) % 2
		end

		function luaP:testTMode(m)
			return math.floor(self.opmodes[self.OpCode[m]] / 128)
		end

		luaP.LFIELDS_PER_FLUSH = 50

		local function opmode(t, a, b, c, m)
			local luaP = luaP
			return t * 128 + a * 64 +
				luaP.OpArgMask[b] * 16 + luaP.OpArgMask[c] * 4 + luaP.OpMode[m]
		end


		luaP.opmodes = {
			opmode(0, 1, "OpArgK", "OpArgN", "iABx"), 
			opmode(0, 1, "OpArgU", "OpArgU", "iABC"),  
			opmode(0, 1, "OpArgR", "OpArgN", "iABC"),    
			opmode(0, 1, "OpArgU", "OpArgN", "iABC"),     
			opmode(0, 1, "OpArgK", "OpArgN", "iABx"),   
			opmode(0, 1, "OpArgR", "OpArgK", "iABC"),     
			opmode(0, 0, "OpArgK", "OpArgN", "iABx"),    
			opmode(0, 0, "OpArgU", "OpArgN", "iABC"),    
			opmode(0, 0, "OpArgK", "OpArgK", "iABC"),     
			opmode(0, 1, "OpArgU", "OpArgU", "iABC"),  
			opmode(0, 1, "OpArgR", "OpArgK", "iABC"),  
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),   
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),    
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),    
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),   
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),    
			opmode(0, 1, "OpArgK", "OpArgK", "iABC"),     
			opmode(0, 1, "OpArgR", "OpArgN", "iABC"),    
			opmode(0, 1, "OpArgR", "OpArgN", "iABC"),     
			opmode(0, 1, "OpArgR", "OpArgN", "iABC"),   
			opmode(0, 1, "OpArgR", "OpArgR", "iABC"),
			opmode(0, 0, "OpArgR", "OpArgN", "iAsBx"), 
			opmode(1, 0, "OpArgK", "OpArgK", "iABC"), 
			opmode(1, 0, "OpArgK", "OpArgK", "iABC"), 
			opmode(1, 0, "OpArgK", "OpArgK", "iABC"), 
			opmode(1, 1, "OpArgR", "OpArgU", "iABC"),   
			opmode(1, 1, "OpArgR", "OpArgU", "iABC"),   
			opmode(0, 1, "OpArgU", "OpArgU", "iABC"),  
			opmode(0, 1, "OpArgU", "OpArgU", "iABC"),  
			opmode(0, 0, "OpArgU", "OpArgN", "iABC"),   
			opmode(0, 1, "OpArgR", "OpArgN", "iAsBx"),  
			opmode(0, 1, "OpArgR", "OpArgN", "iAsBx"),   
			opmode(1, 0, "OpArgN", "OpArgU", "iABC"),    
			opmode(0, 0, "OpArgU", "OpArgU", "iABC"),   
			opmode(0, 0, "OpArgN", "OpArgN", "iABC"),     
			opmode(0, 1, "OpArgU", "OpArgN", "iABx"),  
			opmode(0, 1, "OpArgU", "OpArgN", "iABC"),     
		}

		luaP.opmodes[0] =
			opmode(0, 1, "OpArgR", "OpArgN", "iABC")

		luaU.LUA_SIGNATURE = "\27Lua"

		luaU.LUA_TNUMBER  = 3
		luaU.LUA_TSTRING  = 4
		luaU.LUA_TNIL     = 0
		luaU.LUA_TBOOLEAN = 1
		luaU.LUA_TNONE    = -1

		luaU.LUAC_VERSION    = 0x51    
		luaU.LUAC_FORMAT     = 0     
		luaU.LUAC_HEADERSIZE = 12   

		function luaU:make_setS()
			local buff = {}
			buff.data = ""
			local writer =
				function(s, buff)
					if not s then return 0 end
					buff.data = buff.data..s
					return 0
				end
			return writer, buff
		end

		function luaU:make_setF(filename)
			local buff = {}
			buff.h = io.open(filename, "wb")
			if not buff.h then return nil end
			local writer =
				function(s, buff)  
					if not buff.h then return 0 end
					if not s then
					if buff.h:close() then return 0 end
				else
					if buff.h:write(s) then return 0 end
				end
					return 1
				end
			return writer, buff
		end

		function luaU:ttype(o)
			local tt = type(o.value)
			if tt == "number" then return self.LUA_TNUMBER
			elseif tt == "string" then return self.LUA_TSTRING
			elseif tt == "nil" then return self.LUA_TNIL
			elseif tt == "boolean" then return self.LUA_TBOOLEAN
			else
				return self.LUA_TNONE
			end
		end

		function luaU:from_double(x)
			local function grab_byte(v)
				local c = v % 256
				return (v - c) / 256, string.char(c)
			end
			local sign = 0
			if x < 0 then sign = 1; x = -x end
			local mantissa, exponent = math.frexp(x)
			if x == 0 then 
				mantissa, exponent = 0, 0
			elseif x == 1/0 then
				mantissa, exponent = 0, 2047
			else
				mantissa = (mantissa * 2 - 1) * math.ldexp(0.5, 53)
				exponent = exponent + 1022
			end
			local v, byte = ""
			x = math.floor(mantissa)
			for i = 1,6 do
				x, byte = grab_byte(x); v = v..byte 
			end
			x, byte = grab_byte(exponent * 16 + x); v = v..byte
			x, byte = grab_byte(sign * 128 + x); v = v..byte 
			return v
		end

		function luaU:from_int(x)
			local v = ""
			x = math.floor(x)
			if x < 0 then x = 4294967296 + x end  
			for i = 1, 4 do
				local c = x % 256
				v = v..string.char(c); x = math.floor(x / 256)
			end
			return v
		end

		function luaU:DumpBlock(b, D)
			if D.status == 0 then
				D.status = D.write(b, D.data)
			end
		end

		function luaU:DumpChar(y, D)
			self:DumpBlock(string.char(y), D)
		end

		function luaU:DumpInt(x, D)
			self:DumpBlock(self:from_int(x), D)
		end

		function luaU:DumpSizeT(x, D)
			self:DumpBlock(self:from_int(x), D)
			if size_size_t == 8 then
				self:DumpBlock(self:from_int(0), D)
			end
		end

		function luaU:DumpNumber(x, D)
			self:DumpBlock(self:from_double(x), D)
		end

		function luaU:DumpString(s, D)
			if s == nil then
				self:DumpSizeT(0, D)
			else
				s = s.."\0"
				self:DumpSizeT(#s, D)
				self:DumpBlock(s, D)
			end
		end

		function luaU:DumpCode(f, D)
			local n = f.sizecode
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				self:DumpBlock(luaP:Instruction(f.code[i]), D)
			end
		end

		function luaU:DumpConstants(f, D)
			local n = f.sizek
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				local o = f.k[i] 
				local tt = self:ttype(o)
				self:DumpChar(tt, D)
				if tt == self.LUA_TNIL then
				elseif tt == self.LUA_TBOOLEAN then
					self:DumpChar(o.value and 1 or 0, D)
				elseif tt == self.LUA_TNUMBER then
					self:DumpNumber(o.value, D)
				elseif tt == self.LUA_TSTRING then
					self:DumpString(o.value, D)
				else

				end
			end
			n = f.sizep
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				self:DumpFunction(f.p[i], f.source, D)
			end
		end

		function luaU:DumpDebug(f, D)
			local n
			n = D.strip and 0 or f.sizelineinfo        
			--was DumpVector
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				self:DumpInt(f.lineinfo[i], D)
			end
			n = D.strip and 0 or f.sizelocvars      
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				self:DumpString(f.locvars[i].varname, D)
				self:DumpInt(f.locvars[i].startpc, D)
				self:DumpInt(f.locvars[i].endpc, D)
			end
			n = D.strip and 0 or f.sizeupvalues     
			self:DumpInt(n, D)
			for i = 0, n - 1 do
				self:DumpString(f.upvalues[i], D)
			end
		end

		function luaU:DumpFunction(f, p, D)
			local source = f.source
			if source == p or D.strip then source = nil end
			self:DumpString(source, D)
			self:DumpInt(f.lineDefined, D)
			self:DumpInt(f.lastlinedefined, D)
			self:DumpChar(f.nups, D)
			self:DumpChar(f.numparams, D)
			self:DumpChar(f.is_vararg, D)
			self:DumpChar(f.maxstacksize, D)
			self:DumpCode(f, D)
			self:DumpConstants(f, D)
			self:DumpDebug(f, D)
		end

		function luaU:DumpHeader(D)
			local h = self:header()
			assert(#h == self.LUAC_HEADERSIZE)
			self:DumpBlock(h, D)
		end

		function luaU:header()
			local x = 1
			return self.LUA_SIGNATURE..
				string.char(
					self.LUAC_VERSION,
					self.LUAC_FORMAT,
					x,                  
					4,                    
					size_size_t,                
					4,                  
					8,                  
					0)                  
		end

		function luaU:dump(L, f, w, data, strip)
			local D = {} 
			D.L = L
			D.write = w
			D.data = data
			D.strip = strip
			D.status = 0
			self:DumpHeader(D)
			self:DumpFunction(f, nil, D)
			D.write(nil, D.data)
			return D.status
		end
		luaK.MAXSTACK = 250

		function luaK:ttisnumber(o)
			if o then return type(o.value) == "number" else return false end
		end
		function luaK:nvalue(o) return o.value end
		function luaK:setnilvalue(o) o.value = nil end
		function luaK:setsvalue(o, x) o.value = x end
		luaK.setnvalue = luaK.setsvalue
		luaK.sethvalue = luaK.setsvalue
		luaK.setbvalue = luaK.setsvalue

		function luaK:numadd(a, b) return a + b end
		function luaK:numsub(a, b) return a - b end
		function luaK:nummul(a, b) return a * b end
		function luaK:numdiv(a, b) return a / b end
		function luaK:nummod(a, b) return a % b end
		function luaK:numpow(a, b) return a ^ b end
		function luaK:numunm(a) return -a end
		function luaK:numisnan(a) return not a == a end

		luaK.NO_JUMP = -1

		luaK.BinOpr = {
			OPR_ADD = 0, OPR_SUB = 1, OPR_MUL = 2, OPR_DIV = 3, OPR_MOD = 4, OPR_POW = 5,
			OPR_CONCAT = 6,
			OPR_NE = 7, OPR_EQ = 8,
			OPR_LT = 9, OPR_LE = 10, OPR_GT = 11, OPR_GE = 12,
			OPR_AND = 13, OPR_OR = 14,
			OPR_NOBINOPR = 15,
		}

		luaK.UnOpr = {
			OPR_MINUS = 0, OPR_NOT = 1, OPR_LEN = 2, OPR_NOUNOPR = 3
		}

		function luaK:getcode(fs, e)
			return fs.f.code[e.info]
		end

		function luaK:codeAsBx(fs, o, A, sBx)
			return self:codeABx(fs, o, A, sBx + luaP.MAXARG_sBx)
		end

		------------------------------------------------------------------------
		-- set the expdesc e instruction for multiple returns, was a macro
		------------------------------------------------------------------------
		function luaK:setmultret(fs, e)
			self:setreturns(fs, e, luaY.LUA_MULTRET)
		end

		------------------------------------------------------------------------
		-- there is a jump if patch lists are not identical, was a macro
		-- * used in luaK:exp2reg(), luaK:exp2anyreg(), luaK:exp2val()
		------------------------------------------------------------------------
		function luaK:hasjumps(e)
			return e.t ~= e.f
		end

		------------------------------------------------------------------------
		-- true if the expression is a constant number (for constant folding)
		-- * used in constfolding(), infix()
		------------------------------------------------------------------------
		function luaK:isnumeral(e)
			return e.k == "VKNUM" and e.t == self.NO_JUMP and e.f == self.NO_JUMP
		end

		------------------------------------------------------------------------
		-- codes loading of nil, optimization done if consecutive locations
		-- * used in luaK:discharge2reg(), (lparser) luaY:adjust_assign()
		------------------------------------------------------------------------
		function luaK:_nil(fs, from, n)
			if fs.pc > fs.lasttarget then  -- no jumps to current position?
				if fs.pc == 0 then  -- function start?
					if from >= fs.nactvar then
						return  -- positions are already clean
					end
				else
					local previous = fs.f.code[fs.pc - 1]
					if luaP:GET_OPCODE(previous) == "OP_LOADNIL" then
						local pfrom = luaP:GETARG_A(previous)
						local pto = luaP:GETARG_B(previous)
						if pfrom <= from and from <= pto + 1 then  -- can connect both?
							if from + n - 1 > pto then
								luaP:SETARG_B(previous, from + n - 1)
							end
							return
						end
					end
				end
			end
			self:codeABC(fs, "OP_LOADNIL", from, from + n - 1, 0)  -- else no optimization
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:jump(fs)
			local jpc = fs.jpc  -- save list of jumps to here
			fs.jpc = self.NO_JUMP
			local j = self:codeAsBx(fs, "OP_JMP", 0, self.NO_JUMP)
			j = self:concat(fs, j, jpc)  -- keep them on hold
			return j
		end

		------------------------------------------------------------------------
		-- codes a RETURN instruction
		-- * used in luaY:close_func(), luaY:retstat()
		------------------------------------------------------------------------
		function luaK:ret(fs, first, nret)
			self:codeABC(fs, "OP_RETURN", first, nret + 1, 0)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:jumponcond(), luaK:codecomp()
		------------------------------------------------------------------------
		function luaK:condjump(fs, op, A, B, C)
			self:codeABC(fs, op, A, B, C)
			return self:jump(fs)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:patchlistaux(), luaK:concat()
		------------------------------------------------------------------------
		function luaK:fixjump(fs, pc, dest)
			local jmp = fs.f.code[pc]
			local offset = dest - (pc + 1)
			lua_assert(dest ~= self.NO_JUMP)
			if math.abs(offset) > luaP.MAXARG_sBx then
				luaX:syntaxerror(fs.ls, "control structure too long")
			end
			luaP:SETARG_sBx(jmp, offset)
		end

		------------------------------------------------------------------------
		-- returns current 'pc' and marks it as a jump target (to avoid wrong
		-- optimizations with consecutive instructions not in the same basic block).
		-- * used in multiple locations
		-- * fs.lasttarget tested only by luaK:_nil() when optimizing OP_LOADNIL
		------------------------------------------------------------------------
		function luaK:getlabel(fs)
			fs.lasttarget = fs.pc
			return fs.pc
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:need_value(), luaK:removevalues(), luaK:patchlistaux(),
		--   luaK:concat()
		------------------------------------------------------------------------
		function luaK:getjump(fs, pc)
			local offset = luaP:GETARG_sBx(fs.f.code[pc])
			if offset == self.NO_JUMP then  -- point to itself represents end of list
				return self.NO_JUMP  -- end of list
			else
				return (pc + 1) + offset  -- turn offset into absolute position
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:need_value(), luaK:patchtestreg(), luaK:invertjump()
		------------------------------------------------------------------------
		function luaK:getjumpcontrol(fs, pc)
			local pi = fs.f.code[pc]
			local ppi = fs.f.code[pc - 1]
			if pc >= 1 and luaP:testTMode(luaP:GET_OPCODE(ppi)) ~= 0 then
				return ppi
			else
				return pi
			end
		end

		------------------------------------------------------------------------
		-- check whether list has any jump that do not produce a value
		-- (or produce an inverted value)
		-- * return value changed to boolean
		-- * used only in luaK:exp2reg()
		------------------------------------------------------------------------
		function luaK:need_value(fs, list)
			while list ~= self.NO_JUMP do
				local i = self:getjumpcontrol(fs, list)
				if luaP:GET_OPCODE(i) ~= "OP_TESTSET" then return true end
				list = self:getjump(fs, list)
			end
			return false  -- not found
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:removevalues(), luaK:patchlistaux()
		------------------------------------------------------------------------
		function luaK:patchtestreg(fs, node, reg)
			local i = self:getjumpcontrol(fs, node)
			if luaP:GET_OPCODE(i) ~= "OP_TESTSET" then
				return false  -- cannot patch other instructions
			end
			if reg ~= luaP.NO_REG and reg ~= luaP:GETARG_B(i) then
				luaP:SETARG_A(i, reg)
			else  -- no register to put value or register already has the value
				-- due to use of a table as i, i cannot be replaced by another table
				-- so the following is required; there is no change to ARG_C
				luaP:SET_OPCODE(i, "OP_TEST")
				local b = luaP:GETARG_B(i)
				luaP:SETARG_A(i, b)
				luaP:SETARG_B(i, 0)
				-- *i = CREATE_ABC(OP_TEST, GETARG_B(*i), 0, GETARG_C(*i)); /* C */
			end
			return true
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:codenot()
		------------------------------------------------------------------------
		function luaK:removevalues(fs, list)
			while list ~= self.NO_JUMP do
				self:patchtestreg(fs, list, luaP.NO_REG)
				list = self:getjump(fs, list)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:dischargejpc(), luaK:patchlist(), luaK:exp2reg()
		------------------------------------------------------------------------
		function luaK:patchlistaux(fs, list, vtarget, reg, dtarget)
			while list ~= self.NO_JUMP do
				local _next = self:getjump(fs, list)
				if self:patchtestreg(fs, list, reg) then
					self:fixjump(fs, list, vtarget)
				else
					self:fixjump(fs, list, dtarget)  -- jump to default target
				end
				list = _next
			end
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:code()
		------------------------------------------------------------------------
		function luaK:dischargejpc(fs)
			self:patchlistaux(fs, fs.jpc, fs.pc, luaP.NO_REG, fs.pc)
			fs.jpc = self.NO_JUMP
		end

		------------------------------------------------------------------------
		--
		-- * used in (lparser) luaY:whilestat(), luaY:repeatstat(), luaY:forbody()
		------------------------------------------------------------------------
		function luaK:patchlist(fs, list, target)
			if target == fs.pc then
				self:patchtohere(fs, list)
			else
				lua_assert(target < fs.pc)
				self:patchlistaux(fs, list, target, luaP.NO_REG, target)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:patchtohere(fs, list)
			self:getlabel(fs)
			fs.jpc = self:concat(fs, fs.jpc, list)
		end

		------------------------------------------------------------------------
		-- * l1 was a pointer, now l1 is returned and callee assigns the value
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:concat(fs, l1, l2)
			if l2 == self.NO_JUMP then return l1
			elseif l1 == self.NO_JUMP then
				return l2
			else
				local list = l1
				local _next = self:getjump(fs, list)
				while _next ~= self.NO_JUMP do  -- find last element
					list = _next
					_next = self:getjump(fs, list)
				end
				self:fixjump(fs, list, l2)
			end
			return l1
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:reserveregs(), (lparser) luaY:forlist()
		------------------------------------------------------------------------
		function luaK:checkstack(fs, n)
			local newstack = fs.freereg + n
			if newstack > fs.f.maxstacksize then
				if newstack >= self.MAXSTACK then
					luaX:syntaxerror(fs.ls, "function or expression too complex")
				end
				fs.f.maxstacksize = newstack
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:reserveregs(fs, n)
			self:checkstack(fs, n)
			fs.freereg = fs.freereg + n
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:freeexp(), luaK:dischargevars()
		------------------------------------------------------------------------
		function luaK:freereg(fs, reg)
			if not luaP:ISK(reg) and reg >= fs.nactvar then
				fs.freereg = fs.freereg - 1
				lua_assert(reg == fs.freereg)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:freeexp(fs, e)
			if e.k == "VNONRELOC" then
				self:freereg(fs, e.info)
			end
		end

		------------------------------------------------------------------------
		-- * TODO NOTE implementation is not 100% correct, since the assert fails
		-- * luaH_set, setobj deleted; direct table access used instead
		-- * used in luaK:stringK(), luaK:numberK(), luaK:boolK(), luaK:nilK()
		------------------------------------------------------------------------
		function luaK:addk(fs, k, v)
			local L = fs.L
			local idx = fs.h[k.value]
			--TValue *idx = luaH_set(L, fs->h, k); /* C */
			local f = fs.f
			if self:ttisnumber(idx) then
				--TODO this assert currently FAILS (last tested for 5.0.2)
				--lua_assert(fs.f.k[self:nvalue(idx)] == v)
				--lua_assert(luaO_rawequalObj(&fs->f->k[cast_int(nvalue(idx))], v)); /* C */
				return self:nvalue(idx)
			else -- constant not found; create a new entry
				idx = {}
				self:setnvalue(idx, fs.nk)
				fs.h[k.value] = idx
				-- setnvalue(idx, cast_num(fs->nk)); /* C */
				luaY:growvector(L, f.k, fs.nk, f.sizek, nil,
					luaP.MAXARG_Bx, "constant table overflow")
				-- loop to initialize empty f.k positions not required
				f.k[fs.nk] = v
				-- setobj(L, &f->k[fs->nk], v); /* C */
				-- luaC_barrier(L, f, v); /* GC */
				local nk = fs.nk
				fs.nk = fs.nk + 1
				return nk
			end

		end

		------------------------------------------------------------------------
		-- creates and sets a string object
		-- * used in (lparser) luaY:codestring(), luaY:singlevar()
		------------------------------------------------------------------------
		function luaK:stringK(fs, s)
			local o = {}  -- TValue
			self:setsvalue(o, s)
			return self:addk(fs, o, o)
		end

		------------------------------------------------------------------------
		-- creates and sets a number object
		-- * used in luaK:prefix() for negative (or negation of) numbers
		-- * used in (lparser) luaY:simpleexp(), luaY:fornum()
		------------------------------------------------------------------------
		function luaK:numberK(fs, r)
			local o = {}  -- TValue
			self:setnvalue(o, r)
			return self:addk(fs, o, o)
		end

		------------------------------------------------------------------------
		-- creates and sets a boolean object
		-- * used only in luaK:exp2RK()
		------------------------------------------------------------------------
		function luaK:boolK(fs, b)
			local o = {}  -- TValue
			self:setbvalue(o, b)
			return self:addk(fs, o, o)
		end

		------------------------------------------------------------------------
		-- creates and sets a nil object
		-- * used only in luaK:exp2RK()
		------------------------------------------------------------------------
		function luaK:nilK(fs)
			local k, v = {}, {}  -- TValue
			self:setnilvalue(v)
			-- cannot use nil as key; instead use table itself to represent nil
			self:sethvalue(k, fs.h)
			return self:addk(fs, k, v)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:setmultret(), (lparser) luaY:adjust_assign()
		------------------------------------------------------------------------
		function luaK:setreturns(fs, e, nresults)
			if e.k == "VCALL" then  -- expression is an open function call?
				luaP:SETARG_C(self:getcode(fs, e), nresults + 1)
			elseif e.k == "VVARARG" then
				luaP:SETARG_B(self:getcode(fs, e), nresults + 1);
				luaP:SETARG_A(self:getcode(fs, e), fs.freereg);
				luaK:reserveregs(fs, 1)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:dischargevars(), (lparser) luaY:assignment()
		------------------------------------------------------------------------
		function luaK:setoneret(fs, e)
			if e.k == "VCALL" then  -- expression is an open function call?
				e.k = "VNONRELOC"
				e.info = luaP:GETARG_A(self:getcode(fs, e))
			elseif e.k == "VVARARG" then
				luaP:SETARG_B(self:getcode(fs, e), 2)
				e.k = "VRELOCABLE"  -- can relocate its simple result
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:dischargevars(fs, e)
			local k = e.k
			if k == "VLOCAL" then
				e.k = "VNONRELOC"
			elseif k == "VUPVAL" then
				e.info = self:codeABC(fs, "OP_GETUPVAL", 0, e.info, 0)
				e.k = "VRELOCABLE"
			elseif k == "VGLOBAL" then
				e.info = self:codeABx(fs, "OP_GETGLOBAL", 0, e.info)
				e.k = "VRELOCABLE"
			elseif k == "VINDEXED" then
				self:freereg(fs, e.aux)
				self:freereg(fs, e.info)
				e.info = self:codeABC(fs, "OP_GETTABLE", 0, e.info, e.aux)
				e.k = "VRELOCABLE"
			elseif k == "VVARARG" or k == "VCALL" then
				self:setoneret(fs, e)
			else
				-- there is one value available (somewhere)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:exp2reg()
		------------------------------------------------------------------------
		function luaK:code_label(fs, A, b, jump)
			self:getlabel(fs)  -- those instructions may be jump targets
			return self:codeABC(fs, "OP_LOADBOOL", A, b, jump)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:discharge2anyreg(), luaK:exp2reg()
		------------------------------------------------------------------------
		function luaK:discharge2reg(fs, e, reg)
			self:dischargevars(fs, e)
			local k = e.k
			if k == "VNIL" then
				self:_nil(fs, reg, 1)
			elseif k == "VFALSE" or k == "VTRUE" then
				self:codeABC(fs, "OP_LOADBOOL", reg, (e.k == "VTRUE") and 1 or 0, 0)
			elseif k == "VK" then
				self:codeABx(fs, "OP_LOADK", reg, e.info)
			elseif k == "VKNUM" then
				self:codeABx(fs, "OP_LOADK", reg, self:numberK(fs, e.nval))
			elseif k == "VRELOCABLE" then
				local pc = self:getcode(fs, e)
				luaP:SETARG_A(pc, reg)
			elseif k == "VNONRELOC" then
				if reg ~= e.info then
					self:codeABC(fs, "OP_MOVE", reg, e.info, 0)
				end
			else
				lua_assert(e.k == "VVOID" or e.k == "VJMP")
				return  -- nothing to do...
			end
			e.info = reg
			e.k = "VNONRELOC"
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:jumponcond(), luaK:codenot()
		------------------------------------------------------------------------
		function luaK:discharge2anyreg(fs, e)
			if e.k ~= "VNONRELOC" then
				self:reserveregs(fs, 1)
				self:discharge2reg(fs, e, fs.freereg - 1)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:exp2nextreg(), luaK:exp2anyreg(), luaK:storevar()
		------------------------------------------------------------------------
		function luaK:exp2reg(fs, e, reg)
			self:discharge2reg(fs, e, reg)
			if e.k == "VJMP" then
				e.t = self:concat(fs, e.t, e.info)  -- put this jump in 't' list
			end
			if self:hasjumps(e) then
				local final  -- position after whole expression
				local p_f = self.NO_JUMP  -- position of an eventual LOAD false
				local p_t = self.NO_JUMP  -- position of an eventual LOAD true
				if self:need_value(fs, e.t) or self:need_value(fs, e.f) then
					local fj = (e.k == "VJMP") and self.NO_JUMP or self:jump(fs)
					p_f = self:code_label(fs, reg, 0, 1)
					p_t = self:code_label(fs, reg, 1, 0)
					self:patchtohere(fs, fj)
				end
				final = self:getlabel(fs)
				self:patchlistaux(fs, e.f, final, reg, p_f)
				self:patchlistaux(fs, e.t, final, reg, p_t)
			end
			e.f, e.t = self.NO_JUMP, self.NO_JUMP
			e.info = reg
			e.k = "VNONRELOC"
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:exp2nextreg(fs, e)
			self:dischargevars(fs, e)
			self:freeexp(fs, e)
			self:reserveregs(fs, 1)
			self:exp2reg(fs, e, fs.freereg - 1)
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:exp2anyreg(fs, e)
			self:dischargevars(fs, e)
			if e.k == "VNONRELOC" then
				if not self:hasjumps(e) then  -- exp is already in a register
					return e.info
				end
				if e.info >= fs.nactvar then  -- reg. is not a local?
					self:exp2reg(fs, e, e.info)  -- put value on it
					return e.info
				end
			end
			self:exp2nextreg(fs, e)  -- default
			return e.info
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:exp2RK(), luaK:prefix(), luaK:posfix()
		-- * used in (lparser) luaY:yindex()
		------------------------------------------------------------------------
		function luaK:exp2val(fs, e)
			if self:hasjumps(e) then
				self:exp2anyreg(fs, e)
			else
				self:dischargevars(fs, e)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaK:exp2RK(fs, e)
			self:exp2val(fs, e)
			local k = e.k
			if k == "VKNUM" or k == "VTRUE" or k == "VFALSE" or k == "VNIL" then
				if fs.nk <= luaP.MAXINDEXRK then  -- constant fit in RK operand?
					-- converted from a 2-deep ternary operator expression
					if e.k == "VNIL" then
						e.info = self:nilK(fs)
					else
						e.info = (e.k == "VKNUM") and self:numberK(fs, e.nval)
							or self:boolK(fs, e.k == "VTRUE")
					end
					e.k = "VK"
					return luaP:RKASK(e.info)
				end
			elseif k == "VK" then
				if e.info <= luaP.MAXINDEXRK then  -- constant fit in argC?
					return luaP:RKASK(e.info)
				end
			else
				-- default
			end
			-- not a constant in the right range: put it in a register
			return self:exp2anyreg(fs, e)
		end

		------------------------------------------------------------------------
		--
		-- * used in (lparser) luaY:assignment(), luaY:localfunc(), luaY:funcstat()
		------------------------------------------------------------------------
		function luaK:storevar(fs, var, ex)
			local k = var.k
			if k == "VLOCAL" then
				self:freeexp(fs, ex)
				self:exp2reg(fs, ex, var.info)
				return
			elseif k == "VUPVAL" then
				local e = self:exp2anyreg(fs, ex)
				self:codeABC(fs, "OP_SETUPVAL", e, var.info, 0)
			elseif k == "VGLOBAL" then
				local e = self:exp2anyreg(fs, ex)
				self:codeABx(fs, "OP_SETGLOBAL", e, var.info)
			elseif k == "VINDEXED" then
				local e = self:exp2RK(fs, ex)
				self:codeABC(fs, "OP_SETTABLE", var.info, var.aux, e)
			else
				lua_assert(0)  -- invalid var kind to store
			end
			self:freeexp(fs, ex)
		end

		------------------------------------------------------------------------
		--
		-- * used only in (lparser) luaY:primaryexp()
		------------------------------------------------------------------------
		function luaK:_self(fs, e, key)
			self:exp2anyreg(fs, e)
			self:freeexp(fs, e)
			local func = fs.freereg
			self:reserveregs(fs, 2)
			self:codeABC(fs, "OP_SELF", func, e.info, self:exp2RK(fs, key))
			self:freeexp(fs, key)
			e.info = func
			e.k = "VNONRELOC"
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:goiftrue(), luaK:codenot()
		------------------------------------------------------------------------
		function luaK:invertjump(fs, e)
			local pc = self:getjumpcontrol(fs, e.info)
			lua_assert(luaP:testTMode(luaP:GET_OPCODE(pc)) ~= 0 and
				luaP:GET_OPCODE(pc) ~= "OP_TESTSET" and
				luaP:GET_OPCODE(pc) ~= "OP_TEST")
			luaP:SETARG_A(pc, (luaP:GETARG_A(pc) == 0) and 1 or 0)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:goiftrue(), luaK:goiffalse()
		------------------------------------------------------------------------
		function luaK:jumponcond(fs, e, cond)
			if e.k == "VRELOCABLE" then
				local ie = self:getcode(fs, e)
				if luaP:GET_OPCODE(ie) == "OP_NOT" then
					fs.pc = fs.pc - 1  -- remove previous OP_NOT
					return self:condjump(fs, "OP_TEST", luaP:GETARG_B(ie), 0, cond and 0 or 1)
				end
				-- else go through
			end
			self:discharge2anyreg(fs, e)
			self:freeexp(fs, e)
			return self:condjump(fs, "OP_TESTSET", luaP.NO_REG, e.info, cond and 1 or 0)
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:infix(), (lparser) luaY:cond()
		------------------------------------------------------------------------
		function luaK:goiftrue(fs, e)
			local pc  -- pc of last jump
			self:dischargevars(fs, e)
			local k = e.k
			if k == "VK" or k == "VKNUM" or k == "VTRUE" then
				pc = self.NO_JUMP  -- always true; do nothing
			elseif k == "VFALSE" then
				pc = self:jump(fs)  -- always jump
			elseif k == "VJMP" then
				self:invertjump(fs, e)
				pc = e.info
			else
				pc = self:jumponcond(fs, e, false)
			end
			e.f = self:concat(fs, e.f, pc)  -- insert last jump in `f' list
			self:patchtohere(fs, e.t)
			e.t = self.NO_JUMP
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:infix()
		------------------------------------------------------------------------
		function luaK:goiffalse(fs, e)
			local pc  -- pc of last jump
			self:dischargevars(fs, e)
			local k = e.k
			if k == "VNIL" or k == "VFALSE"then
				pc = self.NO_JUMP  -- always false; do nothing
			elseif k == "VTRUE" then
				pc = self:jump(fs)  -- always jump
			elseif k == "VJMP" then
				pc = e.info
			else
				pc = self:jumponcond(fs, e, true)
			end
			e.t = self:concat(fs, e.t, pc)  -- insert last jump in `t' list
			self:patchtohere(fs, e.f)
			e.f = self.NO_JUMP
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:prefix()
		------------------------------------------------------------------------
		function luaK:codenot(fs, e)
			self:dischargevars(fs, e)
			local k = e.k
			if k == "VNIL" or k == "VFALSE" then
				e.k = "VTRUE"
			elseif k == "VK" or k == "VKNUM" or k == "VTRUE" then
				e.k = "VFALSE"
			elseif k == "VJMP" then
				self:invertjump(fs, e)
			elseif k == "VRELOCABLE" or k == "VNONRELOC" then
				self:discharge2anyreg(fs, e)
				self:freeexp(fs, e)
				e.info = self:codeABC(fs, "OP_NOT", 0, e.info, 0)
				e.k = "VRELOCABLE"
			else
				lua_assert(0)  -- cannot happen
			end
			-- interchange true and false lists
			e.f, e.t = e.t, e.f
			self:removevalues(fs, e.f)
			self:removevalues(fs, e.t)
		end

		------------------------------------------------------------------------
		--
		-- * used in (lparser) luaY:field(), luaY:primaryexp()
		------------------------------------------------------------------------
		function luaK:indexed(fs, t, k)
			t.aux = self:exp2RK(fs, k)
			t.k = "VINDEXED"
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:codearith()
		------------------------------------------------------------------------
		function luaK:constfolding(op, e1, e2)
			local r
			if not self:isnumeral(e1) or not self:isnumeral(e2) then return false end
			local v1 = e1.nval
			local v2 = e2.nval
			if op == "OP_ADD" then
				r = self:numadd(v1, v2)
			elseif op == "OP_SUB" then
				r = self:numsub(v1, v2)
			elseif op == "OP_MUL" then
				r = self:nummul(v1, v2)
			elseif op == "OP_DIV" then
				if v2 == 0 then return false end  -- do not attempt to divide by 0
				r = self:numdiv(v1, v2)
			elseif op == "OP_MOD" then
				if v2 == 0 then return false end  -- do not attempt to divide by 0
				r = self:nummod(v1, v2)
			elseif op == "OP_POW" then
				r = self:numpow(v1, v2)
			elseif op == "OP_UNM" then
				r = self:numunm(v1)
			elseif op == "OP_LEN" then
				return false  -- no constant folding for 'len'
			else
				lua_assert(0)
				r = 0
			end
			if self:numisnan(r) then return false end  -- do not attempt to produce NaN
			e1.nval = r
			return true
		end

		------------------------------------------------------------------------
		--
		-- * used in luaK:prefix(), luaK:posfix()
		------------------------------------------------------------------------
		function luaK:codearith(fs, op, e1, e2)
			if self:constfolding(op, e1, e2) then
				return
			else
				local o2 = (op ~= "OP_UNM" and op ~= "OP_LEN") and self:exp2RK(fs, e2) or 0
				local o1 = self:exp2RK(fs, e1)
				if o1 > o2 then
					self:freeexp(fs, e1)
					self:freeexp(fs, e2)
				else
					self:freeexp(fs, e2)
					self:freeexp(fs, e1)
				end
				e1.info = self:codeABC(fs, op, 0, o1, o2)
				e1.k = "VRELOCABLE"
			end
		end

		------------------------------------------------------------------------
		--
		-- * used only in luaK:posfix()
		------------------------------------------------------------------------
		function luaK:codecomp(fs, op, cond, e1, e2)
			local o1 = self:exp2RK(fs, e1)
			local o2 = self:exp2RK(fs, e2)
			self:freeexp(fs, e2)
			self:freeexp(fs, e1)
			if cond == 0 and op ~= "OP_EQ" then
				-- exchange args to replace by `<' or `<='
				o1, o2 = o2, o1  -- o1 <==> o2
				cond = 1
			end
			e1.info = self:condjump(fs, op, cond, o1, o2)
			e1.k = "VJMP"
		end

		------------------------------------------------------------------------
		--
		-- * used only in (lparser) luaY:subexpr()
		------------------------------------------------------------------------
		function luaK:prefix(fs, op, e)
			local e2 = {}  -- expdesc
			e2.t, e2.f = self.NO_JUMP, self.NO_JUMP
			e2.k = "VKNUM"
			e2.nval = 0
			if op == "OPR_MINUS" then
				if not self:isnumeral(e) then
					self:exp2anyreg(fs, e)  -- cannot operate on non-numeric constants
				end
				self:codearith(fs, "OP_UNM", e, e2)
			elseif op == "OPR_NOT" then
				self:codenot(fs, e)
			elseif op == "OPR_LEN" then
				self:exp2anyreg(fs, e)  -- cannot operate on constants
				self:codearith(fs, "OP_LEN", e, e2)
			else
				lua_assert(0)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used only in (lparser) luaY:subexpr()
		------------------------------------------------------------------------
		function luaK:infix(fs, op, v)
			if op == "OPR_AND" then
				self:goiftrue(fs, v)
			elseif op == "OPR_OR" then
				self:goiffalse(fs, v)
			elseif op == "OPR_CONCAT" then
				self:exp2nextreg(fs, v)  -- operand must be on the 'stack'
			elseif op == "OPR_ADD" or op == "OPR_SUB" or
				op == "OPR_MUL" or op == "OPR_DIV" or
				op == "OPR_MOD" or op == "OPR_POW" then
				if not self:isnumeral(v) then self:exp2RK(fs, v) end
			else
				self:exp2RK(fs, v)
			end
		end

		------------------------------------------------------------------------
		--
		-- * used only in (lparser) luaY:subexpr()
		------------------------------------------------------------------------
		-- table lookups to simplify testing
		luaK.arith_op = {
			OPR_ADD = "OP_ADD", OPR_SUB = "OP_SUB", OPR_MUL = "OP_MUL",
			OPR_DIV = "OP_DIV", OPR_MOD = "OP_MOD", OPR_POW = "OP_POW",
		}
		luaK.comp_op = {
			OPR_EQ = "OP_EQ", OPR_NE = "OP_EQ", OPR_LT = "OP_LT",
			OPR_LE = "OP_LE", OPR_GT = "OP_LT", OPR_GE = "OP_LE",
		}
		luaK.comp_cond = {
			OPR_EQ = 1, OPR_NE = 0, OPR_LT = 1,
			OPR_LE = 1, OPR_GT = 0, OPR_GE = 0,
		}
		function luaK:posfix(fs, op, e1, e2)
			-- needed because e1 = e2 doesn't copy values...
			-- * in 5.0.x, only k/info/aux/t/f copied, t for AND, f for OR
			--   but here, all elements are copied for completeness' sake
			local function copyexp(e1, e2)
				e1.k = e2.k
				e1.info = e2.info; e1.aux = e2.aux
				e1.nval = e2.nval
				e1.t = e2.t; e1.f = e2.f
			end
			if op == "OPR_AND" then
				lua_assert(e1.t == self.NO_JUMP)  -- list must be closed
				self:dischargevars(fs, e2)
				e2.f = self:concat(fs, e2.f, e1.f)
				copyexp(e1, e2)
			elseif op == "OPR_OR" then
				lua_assert(e1.f == self.NO_JUMP)  -- list must be closed
				self:dischargevars(fs, e2)
				e2.t = self:concat(fs, e2.t, e1.t)
				copyexp(e1, e2)
			elseif op == "OPR_CONCAT" then
				self:exp2val(fs, e2)
				if e2.k == "VRELOCABLE" and luaP:GET_OPCODE(self:getcode(fs, e2)) == "OP_CONCAT" then
					lua_assert(e1.info == luaP:GETARG_B(self:getcode(fs, e2)) - 1)
					self:freeexp(fs, e1)
					luaP:SETARG_B(self:getcode(fs, e2), e1.info)
					e1.k = "VRELOCABLE"
					e1.info = e2.info
				else
					self:exp2nextreg(fs, e2)  -- operand must be on the 'stack'
					self:codearith(fs, "OP_CONCAT", e1, e2)
				end
			else
				-- the following uses a table lookup in place of conditionals
				local arith = self.arith_op[op]
				if arith then
					self:codearith(fs, arith, e1, e2)
				else
					local comp = self.comp_op[op]
					if comp then
						self:codecomp(fs, comp, self.comp_cond[op], e1, e2)
					else
						lua_assert(0)
					end
				end--if arith
			end--if op
		end

		------------------------------------------------------------------------
		-- adjusts debug information for last instruction written, in order to
		-- change the line where item comes into existence
		-- * used in (lparser) luaY:funcargs(), luaY:forbody(), luaY:funcstat()
		------------------------------------------------------------------------
		function luaK:fixline(fs, line)
			fs.f.lineinfo[fs.pc - 1] = line
		end

		------------------------------------------------------------------------
		-- general function to write an instruction into the instruction buffer,
		-- sets debug information too
		-- * used in luaK:codeABC(), luaK:codeABx()
		-- * called directly by (lparser) luaY:whilestat()
		------------------------------------------------------------------------
		function luaK:code(fs, i, line)
			local f = fs.f
			self:dischargejpc(fs)  -- 'pc' will change
			-- put new instruction in code array
			luaY:growvector(fs.L, f.code, fs.pc, f.sizecode, nil,
				luaY.MAX_INT, "code size overflow")
			f.code[fs.pc] = i
			-- save corresponding line information
			luaY:growvector(fs.L, f.lineinfo, fs.pc, f.sizelineinfo, nil,
				luaY.MAX_INT, "code size overflow")
			f.lineinfo[fs.pc] = line
			local pc = fs.pc
			fs.pc = fs.pc + 1
			return pc
		end

		------------------------------------------------------------------------
		-- writes an instruction of type ABC
		-- * calls luaK:code()
		------------------------------------------------------------------------
		function luaK:codeABC(fs, o, a, b, c)
			lua_assert(luaP:getOpMode(o) == luaP.OpMode.iABC)
			lua_assert(luaP:getBMode(o) ~= luaP.OpArgMask.OpArgN or b == 0)
			lua_assert(luaP:getCMode(o) ~= luaP.OpArgMask.OpArgN or c == 0)
			return self:code(fs, luaP:CREATE_ABC(o, a, b, c), fs.ls.lastline)
		end

		------------------------------------------------------------------------
		-- writes an instruction of type ABx
		-- * calls luaK:code(), called by luaK:codeAsBx()
		------------------------------------------------------------------------
		function luaK:codeABx(fs, o, a, bc)
			lua_assert(luaP:getOpMode(o) == luaP.OpMode.iABx or
				luaP:getOpMode(o) == luaP.OpMode.iAsBx)
			lua_assert(luaP:getCMode(o) == luaP.OpArgMask.OpArgN)
			return self:code(fs, luaP:CREATE_ABx(o, a, bc), fs.ls.lastline)
		end

		------------------------------------------------------------------------
		--
		-- * used in (lparser) luaY:closelistfield(), luaY:lastlistfield()
		------------------------------------------------------------------------
		function luaK:setlist(fs, base, nelems, tostore)
			local c = math.floor((nelems - 1)/luaP.LFIELDS_PER_FLUSH) + 1
			local b = (tostore == luaY.LUA_MULTRET) and 0 or tostore
			lua_assert(tostore ~= 0)
			if c <= luaP.MAXARG_C then
				self:codeABC(fs, "OP_SETLIST", base, b, c)
			else
				self:codeABC(fs, "OP_SETLIST", base, b, 0)
				self:code(fs, luaP:CREATE_Inst(c), fs.ls.lastline)
			end
			fs.freereg = base + 1  -- free registers with list values
		end




		--dofile("lparser.lua")

--[[--------------------------------------------------------------------
-- Expression descriptor
-- * expkind changed to string constants; luaY:assignment was the only
--   function to use a relational operator with this enumeration
-- VVOID       -- no value
-- VNIL        -- no value
-- VTRUE       -- no value
-- VFALSE      -- no value
-- VK          -- info = index of constant in 'k'
-- VKNUM       -- nval = numerical value
-- VLOCAL      -- info = local register
-- VUPVAL,     -- info = index of upvalue in 'upvalues'
-- VGLOBAL     -- info = index of table; aux = index of global name in 'k'
-- VINDEXED    -- info = table register; aux = index register (or 'k')
-- VJMP        -- info = instruction pc
-- VRELOCABLE  -- info = instruction pc
-- VNONRELOC   -- info = result register
-- VCALL       -- info = instruction pc
-- VVARARG     -- info = instruction pc
} ----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
-- * expdesc in Lua 5.1.x has a union u and another struct s; this Lua
--   implementation ignores all instances of u and s usage
-- struct expdesc:
--   k  -- (enum: expkind)
--   info, aux -- (int, int)
--   nval -- (lua_Number)
--   t  -- patch list of 'exit when true'
--   f  -- patch list of 'exit when false'
----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
-- struct upvaldesc:
--   k  -- (lu_byte)
--   info -- (lu_byte)
----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
-- state needed to generate code for a given function
-- struct FuncState:
--   f  -- current function header (table: Proto)
--   h  -- table to find (and reuse) elements in 'k' (table: Table)
--   prev  -- enclosing function (table: FuncState)
--   ls  -- lexical state (table: LexState)
--   L  -- copy of the Lua state (table: lua_State)
--   bl  -- chain of current blocks (table: BlockCnt)
--   pc  -- next position to code (equivalent to 'ncode')
--   lasttarget   -- 'pc' of last 'jump target'
--   jpc  -- list of pending jumps to 'pc'
--   freereg  -- first free register
--   nk  -- number of elements in 'k'
--   np  -- number of elements in 'p'
--   nlocvars  -- number of elements in 'locvars'
--   nactvar  -- number of active local variables
--   upvalues[LUAI_MAXUPVALUES]  -- upvalues (table: upvaldesc)
--   actvar[LUAI_MAXVARS]  -- declared-variable stack
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- constants used by parser
		-- * picks up duplicate values from luaX if required
		------------------------------------------------------------------------
		luaY.LUA_QS = luaX.LUA_QS or "'%s'"  -- (from luaconf.h)

		luaY.SHRT_MAX = 32767 -- (from <limits.h>)
		luaY.LUAI_MAXVARS = 200  -- (luaconf.h)
		luaY.LUAI_MAXUPVALUES = 60  -- (luaconf.h)
		luaY.MAX_INT = luaX.MAX_INT or 2147483645  -- (from llimits.h)
		-- * INT_MAX-2 for 32-bit systems
		luaY.LUAI_MAXCCALLS = 200  -- (from luaconf.h)

		luaY.VARARG_HASARG = 1  -- (from lobject.h)
		-- NOTE: HASARG_MASK is value-specific
		luaY.HASARG_MASK = 2 -- this was added for a bitop in parlist()
		luaY.VARARG_ISVARARG = 2
		-- NOTE: there is some value-specific code that involves VARARG_NEEDSARG
		luaY.VARARG_NEEDSARG = 4

		luaY.LUA_MULTRET = -1  -- (lua.h)

--[[--------------------------------------------------------------------
-- other functions
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- LUA_QL describes how error messages quote program elements.
		-- CHANGE it if you want a different appearance. (from luaconf.h)
		------------------------------------------------------------------------
		function luaY:LUA_QL(x)
			return "'"..x.."'"
		end

		------------------------------------------------------------------------
		-- this is a stripped-down luaM_growvector (from lmem.h) which is a
		-- macro based on luaM_growaux (in lmem.c); all the following does is
		-- reproduce the size limit checking logic of the original function
		-- so that error behaviour is identical; all arguments preserved for
		-- convenience, even those which are unused
		-- * set the t field to nil, since this originally does a sizeof(t)
		-- * size (originally a pointer) is never updated, their final values
		--   are set by luaY:close_func(), so overall things should still work
		------------------------------------------------------------------------
		function luaY:growvector(L, v, nelems, size, t, limit, e)
			if nelems >= limit then
				error(e)  -- was luaG_runerror
			end
		end

		------------------------------------------------------------------------
		-- initialize a new function prototype structure (from lfunc.c)
		-- * used only in open_func()
		------------------------------------------------------------------------
		function luaY:newproto(L)
			local f = {} -- Proto
			-- luaC_link(L, obj2gco(f), LUA_TPROTO); /* GC */
			f.k = {}
			f.sizek = 0
			f.p = {}
			f.sizep = 0
			f.code = {}
			f.sizecode = 0
			f.sizelineinfo = 0
			f.sizeupvalues = 0
			f.nups = 0
			f.upvalues = {}
			f.numparams = 0
			f.is_vararg = 0
			f.maxstacksize = 0
			f.lineinfo = {}
			f.sizelocvars = 0
			f.locvars = {}
			f.lineDefined = 0
			f.lastlinedefined = 0
			f.source = nil
			return f
		end

		------------------------------------------------------------------------
		-- converts an integer to a "floating point byte", represented as
		-- (eeeeexxx), where the real value is (1xxx) * 2^(eeeee - 1) if
		-- eeeee != 0 and (xxx) otherwise.
		------------------------------------------------------------------------
		function luaY:int2fb(x)
			local e = 0  -- exponent
			while x >= 16 do
				x = math.floor((x + 1) / 2)
				e = e + 1
			end
			if x < 8 then
				return x
			else
				return ((e + 1) * 8) + (x - 8)
			end
		end

--[[--------------------------------------------------------------------
-- parser functions
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- true of the kind of expression produces multiple return values
		------------------------------------------------------------------------
		function luaY:hasmultret(k)
			return k == "VCALL" or k == "VVARARG"
		end

		------------------------------------------------------------------------
		-- convenience function to access active local i, returns entry
		------------------------------------------------------------------------
		function luaY:getlocvar(fs, i)
			return fs.f.locvars[ fs.actvar[i] ]
		end

		------------------------------------------------------------------------
		-- check a limit, string m provided as an error message
		------------------------------------------------------------------------
		function luaY:checklimit(fs, v, l, m)
			if v > l then self:errorlimit(fs, l, m) end
		end

--[[--------------------------------------------------------------------
-- nodes for block list (list of active blocks)
-- struct BlockCnt:
--   previous  -- chain (table: BlockCnt)
--   breaklist  -- list of jumps out of this loop
--   nactvar  -- # active local variables outside the breakable structure
--   upval  -- true if some variable in the block is an upvalue (boolean)
--   isbreakable  -- true if 'block' is a loop (boolean)
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- prototypes for recursive non-terminal functions
		------------------------------------------------------------------------
		-- prototypes deleted; not required in Lua

		------------------------------------------------------------------------
		-- reanchor if last token is has a constant string, see close_func()
		-- * used only in close_func()
		------------------------------------------------------------------------
		function luaY:anchor_token(ls)
			if ls.t.token == "TK_NAME" or ls.t.token == "TK_STRING" then
				-- not relevant to Lua implementation of parser
				-- local ts = ls.t.seminfo
				-- luaX_newstring(ls, getstr(ts), ts->tsv.len); /* C */
			end
		end

		------------------------------------------------------------------------
		-- throws a syntax error if token expected is not there
		------------------------------------------------------------------------
		function luaY:error_expected(ls, token)
			luaX:syntaxerror(ls,
				string.format(self.LUA_QS.." expected", luaX:token2str(ls, token)))
		end

		------------------------------------------------------------------------
		-- prepares error message for display, for limits exceeded
		-- * used only in checklimit()
		------------------------------------------------------------------------
		function luaY:errorlimit(fs, limit, what)
			local msg = (fs.f.linedefined == 0) and
				string.format("main function has more than %d %s", limit, what) or
				string.format("function at line %d has more than %d %s",
					fs.f.linedefined, limit, what)
			luaX:lexerror(fs.ls, msg, 0)
		end

		------------------------------------------------------------------------
		-- tests for a token, returns outcome
		-- * return value changed to boolean
		------------------------------------------------------------------------
		function luaY:testnext(ls, c)
			if ls.t.token == c then
				luaX:next(ls)
				return true
			else
				return false
			end
		end

		------------------------------------------------------------------------
		-- check for existence of a token, throws error if not found
		------------------------------------------------------------------------
		function luaY:check(ls, c)
			if ls.t.token ~= c then
				self:error_expected(ls, c)
			end
		end

		------------------------------------------------------------------------
		-- verify existence of a token, then skip it
		------------------------------------------------------------------------
		function luaY:checknext(ls, c)
			self:check(ls, c)
			luaX:next(ls)
		end

		------------------------------------------------------------------------
		-- throws error if condition not matched
		------------------------------------------------------------------------
		function luaY:check_condition(ls, c, msg)
			if not c then luaX:syntaxerror(ls, msg) end
		end

		------------------------------------------------------------------------
		-- verifies token conditions are met or else throw error
		------------------------------------------------------------------------
		function luaY:check_match(ls, what, who, where)
			if not self:testnext(ls, what) then
				if where == ls.linenumber then
					self:error_expected(ls, what)
				else
					luaX:syntaxerror(ls, string.format(
						self.LUA_QS.." expected (to close "..self.LUA_QS.." at line %d)",
						luaX:token2str(ls, what), luaX:token2str(ls, who), where))
				end
			end
		end

		------------------------------------------------------------------------
		-- expect that token is a name, return the name
		------------------------------------------------------------------------
		function luaY:str_checkname(ls)
			self:check(ls, "TK_NAME")
			local ts = ls.t.seminfo
			luaX:next(ls)
			return ts
		end

		------------------------------------------------------------------------
		-- initialize a struct expdesc, expression description data structure
		------------------------------------------------------------------------
		function luaY:init_exp(e, k, i)
			e.f, e.t = luaK.NO_JUMP, luaK.NO_JUMP
			e.k = k
			e.info = i
		end

		------------------------------------------------------------------------
		-- adds given string s in string pool, sets e as VK
		------------------------------------------------------------------------
		function luaY:codestring(ls, e, s)
			self:init_exp(e, "VK", luaK:stringK(ls.fs, s))
		end

		------------------------------------------------------------------------
		-- consume a name token, adds it to string pool, sets e as VK
		------------------------------------------------------------------------
		function luaY:checkname(ls, e)
			self:codestring(ls, e, self:str_checkname(ls))
		end

		------------------------------------------------------------------------
		-- creates struct entry for a local variable
		-- * used only in new_localvar()
		------------------------------------------------------------------------
		function luaY:registerlocalvar(ls, varname)
			local fs = ls.fs
			local f = fs.f
			self:growvector(ls.L, f.locvars, fs.nlocvars, f.sizelocvars,
				nil, self.SHRT_MAX, "too many local variables")
			-- loop to initialize empty f.locvar positions not required
			f.locvars[fs.nlocvars] = {} -- LocVar
			f.locvars[fs.nlocvars].varname = varname
			-- luaC_objbarrier(ls.L, f, varname) /* GC */
			local nlocvars = fs.nlocvars
			fs.nlocvars = fs.nlocvars + 1
			return nlocvars
		end

		------------------------------------------------------------------------
		-- creates a new local variable given a name and an offset from nactvar
		-- * used in fornum(), forlist(), parlist(), body()
		------------------------------------------------------------------------
		function luaY:new_localvarliteral(ls, v, n)
			self:new_localvar(ls, v, n)
		end

		------------------------------------------------------------------------
		-- register a local variable, set in active variable list
		------------------------------------------------------------------------
		function luaY:new_localvar(ls, name, n)
			local fs = ls.fs
			self:checklimit(fs, fs.nactvar + n + 1, self.LUAI_MAXVARS, "local variables")
			fs.actvar[fs.nactvar + n] = self:registerlocalvar(ls, name)
		end

		------------------------------------------------------------------------
		-- adds nvars number of new local variables, set debug information
		------------------------------------------------------------------------
		function luaY:adjustlocalvars(ls, nvars)
			local fs = ls.fs
			fs.nactvar = fs.nactvar + nvars
			for i = nvars, 1, -1 do
				self:getlocvar(fs, fs.nactvar - i).startpc = fs.pc
			end
		end

		------------------------------------------------------------------------
		-- removes a number of locals, set debug information
		------------------------------------------------------------------------
		function luaY:removevars(ls, tolevel)
			local fs = ls.fs
			while fs.nactvar > tolevel do
				fs.nactvar = fs.nactvar - 1
				self:getlocvar(fs, fs.nactvar).endpc = fs.pc
			end
		end

		------------------------------------------------------------------------
		-- returns an existing upvalue index based on the given name, or
		-- creates a new upvalue struct entry and returns the new index
		-- * used only in singlevaraux()
		------------------------------------------------------------------------
		function luaY:indexupvalue(fs, name, v)
			local f = fs.f
			for i = 0, f.nups - 1 do
				if fs.upvalues[i].k == v.k and fs.upvalues[i].info == v.info then
					lua_assert(f.upvalues[i] == name)
					return i
				end
			end
			-- new one
			self:checklimit(fs, f.nups + 1, self.LUAI_MAXUPVALUES, "upvalues")
			self:growvector(fs.L, f.upvalues, f.nups, f.sizeupvalues,
				nil, self.MAX_INT, "")
			-- loop to initialize empty f.upvalues positions not required
			f.upvalues[f.nups] = name
			-- luaC_objbarrier(fs->L, f, name); /* GC */
			lua_assert(v.k == "VLOCAL" or v.k == "VUPVAL")
			-- this is a partial copy; only k & info fields used
			fs.upvalues[f.nups] = { k = v.k, info = v.info }
			local nups = f.nups
			f.nups = f.nups + 1
			return nups
		end

		------------------------------------------------------------------------
		-- search the local variable namespace of the given fs for a match
		-- * used only in singlevaraux()
		------------------------------------------------------------------------
		function luaY:searchvar(fs, n)
			for i = fs.nactvar - 1, 0, -1 do
				if n == self:getlocvar(fs, i).varname then
					return i
				end
			end
			return -1  -- not found
		end

		------------------------------------------------------------------------
		-- * mark upvalue flags in function states up to a given level
		-- * used only in singlevaraux()
		------------------------------------------------------------------------
		function luaY:markupval(fs, level)
			local bl = fs.bl
			while bl and bl.nactvar > level do bl = bl.previous end
			if bl then bl.upval = true end
		end

		------------------------------------------------------------------------
		-- handle locals, globals and upvalues and related processing
		-- * search mechanism is recursive, calls itself to search parents
		-- * used only in singlevar()
		------------------------------------------------------------------------
		function luaY:singlevaraux(fs, n, var, base)
			if fs == nil then  -- no more levels?
				self:init_exp(var, "VGLOBAL", luaP.NO_REG)  -- default is global variable
				return "VGLOBAL"
			else
				local v = self:searchvar(fs, n)  -- look up at current level
				if v >= 0 then
					self:init_exp(var, "VLOCAL", v)
					if base == 0 then
						self:markupval(fs, v)  -- local will be used as an upval
					end
					return "VLOCAL"
				else  -- not found at current level; try upper one
					if self:singlevaraux(fs.prev, n, var, 0) == "VGLOBAL" then
						return "VGLOBAL"
					end
					var.info = self:indexupvalue(fs, n, var)  -- else was LOCAL or UPVAL
					var.k = "VUPVAL"  -- upvalue in this level
					return "VUPVAL"
				end--if v
			end--if fs
		end

		------------------------------------------------------------------------
		-- consume a name token, creates a variable (global|local|upvalue)
		-- * used in prefixexp(), funcname()
		------------------------------------------------------------------------
		function luaY:singlevar(ls, var)
			local varname = self:str_checkname(ls)
			local fs = ls.fs
			if self:singlevaraux(fs, varname, var, 1) == "VGLOBAL" then
				var.info = luaK:stringK(fs, varname)  -- info points to global name
			end
		end

		------------------------------------------------------------------------
		-- adjust RHS to match LHS in an assignment
		-- * used in assignment(), forlist(), localstat()
		------------------------------------------------------------------------
		function luaY:adjust_assign(ls, nvars, nexps, e)
			local fs = ls.fs
			local extra = nvars - nexps
			if self:hasmultret(e.k) then
				extra = extra + 1  -- includes call itself
				if extra <= 0 then extra = 0 end
				luaK:setreturns(fs, e, extra)  -- last exp. provides the difference
				if extra > 1 then luaK:reserveregs(fs, extra - 1) end
			else
				if e.k ~= "VVOID" then luaK:exp2nextreg(fs, e) end  -- close last expression
				if extra > 0 then
					local reg = fs.freereg
					luaK:reserveregs(fs, extra)
					luaK:_nil(fs, reg, extra)
				end
			end
		end

		------------------------------------------------------------------------
		-- tracks and limits parsing depth, assert check at end of parsing
		------------------------------------------------------------------------
		function luaY:enterlevel(ls)
			ls.L.nCcalls = ls.L.nCcalls + 1
			if ls.L.nCcalls > self.LUAI_MAXCCALLS then
				luaX:lexerror(ls, "chunk has too many syntax levels", 0)
			end
		end

		------------------------------------------------------------------------
		-- tracks parsing depth, a pair with luaY:enterlevel()
		------------------------------------------------------------------------
		function luaY:leavelevel(ls)
			ls.L.nCcalls = ls.L.nCcalls - 1
		end

		------------------------------------------------------------------------
		-- enters a code unit, initializes elements
		------------------------------------------------------------------------
		function luaY:enterblock(fs, bl, isbreakable)
			bl.breaklist = luaK.NO_JUMP
			bl.isbreakable = isbreakable
			bl.nactvar = fs.nactvar
			bl.upval = false
			bl.previous = fs.bl
			fs.bl = bl
			lua_assert(fs.freereg == fs.nactvar)
		end

		------------------------------------------------------------------------
		-- leaves a code unit, close any upvalues
		------------------------------------------------------------------------
		function luaY:leaveblock(fs)
			local bl = fs.bl
			fs.bl = bl.previous
			self:removevars(fs.ls, bl.nactvar)
			if bl.upval then
				luaK:codeABC(fs, "OP_CLOSE", bl.nactvar, 0, 0)
			end
			-- a block either controls scope or breaks (never both)
			lua_assert(not bl.isbreakable or not bl.upval)
			lua_assert(bl.nactvar == fs.nactvar)
			fs.freereg = fs.nactvar  -- free registers
			luaK:patchtohere(fs, bl.breaklist)
		end

		------------------------------------------------------------------------
		-- implement the instantiation of a function prototype, append list of
		-- upvalues after the instantiation instruction
		-- * used only in body()
		------------------------------------------------------------------------
		function luaY:pushclosure(ls, func, v)
			local fs = ls.fs
			local f = fs.f
			self:growvector(ls.L, f.p, fs.np, f.sizep, nil,
				luaP.MAXARG_Bx, "constant table overflow")
			-- loop to initialize empty f.p positions not required
			f.p[fs.np] = func.f
			fs.np = fs.np + 1
			-- luaC_objbarrier(ls->L, f, func->f); /* C */
			self:init_exp(v, "VRELOCABLE", luaK:codeABx(fs, "OP_CLOSURE", 0, fs.np - 1))
			for i = 0, func.f.nups - 1 do
				local o = (func.upvalues[i].k == "VLOCAL") and "OP_MOVE" or "OP_GETUPVAL"
				luaK:codeABC(fs, o, 0, func.upvalues[i].info, 0)
			end
		end

		------------------------------------------------------------------------
		-- opening of a function
		------------------------------------------------------------------------
		function luaY:open_func(ls, fs)
			local L = ls.L
			local f = self:newproto(ls.L)
			fs.f = f
			fs.prev = ls.fs  -- linked list of funcstates
			fs.ls = ls
			fs.L = L
			ls.fs = fs
			fs.pc = 0
			fs.lasttarget = -1
			fs.jpc = luaK.NO_JUMP
			fs.freereg = 0
			fs.nk = 0
			fs.np = 0
			fs.nlocvars = 0
			fs.nactvar = 0
			fs.bl = nil
			f.source = ls.source
			f.maxstacksize = 2  -- registers 0/1 are always valid
			fs.h = {}  -- constant table; was luaH_new call
			-- anchor table of constants and prototype (to avoid being collected)
			-- sethvalue2s(L, L->top, fs->h); incr_top(L); /* C */
			-- setptvalue2s(L, L->top, f); incr_top(L);
		end

		------------------------------------------------------------------------
		-- closing of a function
		------------------------------------------------------------------------
		function luaY:close_func(ls)
			local L = ls.L
			local fs = ls.fs
			local f = fs.f
			self:removevars(ls, 0)
			luaK:ret(fs, 0, 0)  -- final return
			-- luaM_reallocvector deleted for f->code, f->lineinfo, f->k, f->p,
			-- f->locvars, f->upvalues; not required for Lua table arrays
			f.sizecode = fs.pc
			f.sizelineinfo = fs.pc
			f.sizek = fs.nk
			f.sizep = fs.np
			f.sizelocvars = fs.nlocvars
			f.sizeupvalues = f.nups
			--lua_assert(luaG_checkcode(f))  -- currently not implemented
			lua_assert(fs.bl == nil)
			ls.fs = fs.prev
			-- the following is not required for this implementation; kept here
			-- for completeness
			-- L->top -= 2;  /* remove table and prototype from the stack */
			-- last token read was anchored in defunct function; must reanchor it
			if fs then self:anchor_token(ls) end
		end

		------------------------------------------------------------------------
		-- parser initialization function
		-- * note additional sub-tables needed for LexState, FuncState
		------------------------------------------------------------------------
		function luaY:parser(L, z, buff, name)
			local lexstate = {}  -- LexState
			lexstate.t = {}
			lexstate.lookahead = {}
			local funcstate = {}  -- FuncState
			funcstate.upvalues = {}
			funcstate.actvar = {}
			-- the following nCcalls initialization added for convenience
			L.nCcalls = 0
			lexstate.buff = buff
			luaX:setinput(L, lexstate, z, name)
			self:open_func(lexstate, funcstate)
			funcstate.f.is_vararg = self.VARARG_ISVARARG  -- main func. is always vararg
			luaX:next(lexstate)  -- read first token
			self:chunk(lexstate)
			self:check(lexstate, "TK_EOS")
			self:close_func(lexstate)
			lua_assert(funcstate.prev == nil)
			lua_assert(funcstate.f.nups == 0)
			lua_assert(lexstate.fs == nil)
			return funcstate.f
		end

--[[--------------------------------------------------------------------
-- GRAMMAR RULES
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- parse a function name suffix, for function call specifications
		-- * used in primaryexp(), funcname()
		------------------------------------------------------------------------
		function luaY:field(ls, v)
			-- field -> ['.' | ':'] NAME
			local fs = ls.fs
			local key = {}  -- expdesc
			luaK:exp2anyreg(fs, v)
			luaX:next(ls)  -- skip the dot or colon
			self:checkname(ls, key)
			luaK:indexed(fs, v, key)
		end

		------------------------------------------------------------------------
		-- parse a table indexing suffix, for constructors, expressions
		-- * used in recfield(), primaryexp()
		------------------------------------------------------------------------
		function luaY:yindex(ls, v)
			-- index -> '[' expr ']'
			luaX:next(ls)  -- skip the '['
			self:expr(ls, v)
			luaK:exp2val(ls.fs, v)
			self:checknext(ls, "]")
		end

--[[--------------------------------------------------------------------
-- Rules for Constructors
----------------------------------------------------------------------]]

--[[--------------------------------------------------------------------
-- struct ConsControl:
--   v  -- last list item read (table: struct expdesc)
--   t  -- table descriptor (table: struct expdesc)
--   nh  -- total number of 'record' elements
--   na  -- total number of array elements
--   tostore  -- number of array elements pending to be stored
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- parse a table record (hash) field
		-- * used in constructor()
		------------------------------------------------------------------------
		function luaY:recfield(ls, cc)
			-- recfield -> (NAME | '['exp1']') = exp1
			local fs = ls.fs
			local reg = ls.fs.freereg
			local key, val = {}, {}  -- expdesc
			if ls.t.token == "TK_NAME" then
				self:checklimit(fs, cc.nh, self.MAX_INT, "items in a constructor")
				self:checkname(ls, key)
			else  -- ls->t.token == '['
				self:yindex(ls, key)
			end
			cc.nh = cc.nh + 1
			self:checknext(ls, "=")
			local rkkey = luaK:exp2RK(fs, key)
			self:expr(ls, val)
			luaK:codeABC(fs, "OP_SETTABLE", cc.t.info, rkkey, luaK:exp2RK(fs, val))
			fs.freereg = reg  -- free registers
		end

		------------------------------------------------------------------------
		-- emit a set list instruction if enough elements (LFIELDS_PER_FLUSH)
		-- * used in constructor()
		------------------------------------------------------------------------
		function luaY:closelistfield(fs, cc)
			if cc.v.k == "VVOID" then return end  -- there is no list item
			luaK:exp2nextreg(fs, cc.v)
			cc.v.k = "VVOID"
			if cc.tostore == luaP.LFIELDS_PER_FLUSH then
				luaK:setlist(fs, cc.t.info, cc.na, cc.tostore)  -- flush
				cc.tostore = 0  -- no more items pending
			end
		end

		------------------------------------------------------------------------
		-- emit a set list instruction at the end of parsing list constructor
		-- * used in constructor()
		------------------------------------------------------------------------
		function luaY:lastlistfield(fs, cc)
			if cc.tostore == 0 then return end
			if self:hasmultret(cc.v.k) then
				luaK:setmultret(fs, cc.v)
				luaK:setlist(fs, cc.t.info, cc.na, self.LUA_MULTRET)
				cc.na = cc.na - 1  -- do not count last expression (unknown number of elements)
			else
				if cc.v.k ~= "VVOID" then
					luaK:exp2nextreg(fs, cc.v)
				end
				luaK:setlist(fs, cc.t.info, cc.na, cc.tostore)
			end
		end

		------------------------------------------------------------------------
		-- parse a table list (array) field
		-- * used in constructor()
		------------------------------------------------------------------------
		function luaY:listfield(ls, cc)
			self:expr(ls, cc.v)
			self:checklimit(ls.fs, cc.na, self.MAX_INT, "items in a constructor")
			cc.na = cc.na + 1
			cc.tostore = cc.tostore + 1
		end

		------------------------------------------------------------------------
		-- parse a table constructor
		-- * used in funcargs(), simpleexp()
		------------------------------------------------------------------------
		function luaY:constructor(ls, t)
			-- constructor -> '{' [ field { fieldsep field } [ fieldsep ] ] '}'
			-- field -> recfield | listfield
			-- fieldsep -> ',' | ';'
			local fs = ls.fs
			local line = ls.linenumber
			local pc = luaK:codeABC(fs, "OP_NEWTABLE", 0, 0, 0)
			local cc = {}  -- ConsControl
			cc.v = {}
			cc.na, cc.nh, cc.tostore = 0, 0, 0
			cc.t = t
			self:init_exp(t, "VRELOCABLE", pc)
			self:init_exp(cc.v, "VVOID", 0)  -- no value (yet)
			luaK:exp2nextreg(ls.fs, t)  -- fix it at stack top (for gc)
			self:checknext(ls, "{")
			repeat
				lua_assert(cc.v.k == "VVOID" or cc.tostore > 0)
				if ls.t.token == "}" then break end
				self:closelistfield(fs, cc)
				local c = ls.t.token

				if c == "TK_NAME" then  -- may be listfields or recfields
					luaX:lookahead(ls)
					if ls.lookahead.token ~= "=" then  -- expression?
						self:listfield(ls, cc)
					else
						self:recfield(ls, cc)
					end
				elseif c == "[" then  -- constructor_item -> recfield
					self:recfield(ls, cc)
				else  -- constructor_part -> listfield
					self:listfield(ls, cc)
				end
			until not self:testnext(ls, ",") and not self:testnext(ls, ";")
			self:check_match(ls, "}", "{", line)
			self:lastlistfield(fs, cc)
			luaP:SETARG_B(fs.f.code[pc], self:int2fb(cc.na)) -- set initial array size
			luaP:SETARG_C(fs.f.code[pc], self:int2fb(cc.nh)) -- set initial table size
		end

		-- }======================================================================

		------------------------------------------------------------------------
		-- parse the arguments (parameters) of a function declaration
		-- * used in body()
		------------------------------------------------------------------------
		function luaY:parlist(ls)
			-- parlist -> [ param { ',' param } ]
			local fs = ls.fs
			local f = fs.f
			local nparams = 0
			f.is_vararg = 0
			if ls.t.token ~= ")" then  -- is 'parlist' not empty?
				repeat
					local c = ls.t.token
					if c == "TK_NAME" then  -- param -> NAME
						self:new_localvar(ls, self:str_checkname(ls), nparams)
						nparams = nparams + 1
					elseif c == "TK_DOTS" then  -- param -> `...'
						luaX:next(ls)
						-- [[
						-- #if defined(LUA_COMPAT_VARARG)
						-- use `arg' as default name
						self:new_localvarliteral(ls, "arg", nparams)
						nparams = nparams + 1
						f.is_vararg = self.VARARG_HASARG + self.VARARG_NEEDSARG
						-- #endif
						--]]
						f.is_vararg = f.is_vararg + self.VARARG_ISVARARG
					else
						luaX:syntaxerror(ls, "<name> or "..self:LUA_QL("...").." expected")
					end
				until f.is_vararg ~= 0 or not self:testnext(ls, ",")
			end--if
			self:adjustlocalvars(ls, nparams)
			-- NOTE: the following works only when HASARG_MASK is 2!
			f.numparams = fs.nactvar - (f.is_vararg % self.HASARG_MASK)
			luaK:reserveregs(fs, fs.nactvar)  -- reserve register for parameters
		end

		------------------------------------------------------------------------
		-- parse function declaration body
		-- * used in simpleexp(), localfunc(), funcstat()
		------------------------------------------------------------------------
		function luaY:body(ls, e, needself, line)
			-- body ->  '(' parlist ')' chunk END
			local new_fs = {}  -- FuncState
			new_fs.upvalues = {}
			new_fs.actvar = {}
			self:open_func(ls, new_fs)
			new_fs.f.lineDefined = line
			self:checknext(ls, "(")
			if needself then
				self:new_localvarliteral(ls, "self", 0)
				self:adjustlocalvars(ls, 1)
			end
			self:parlist(ls)
			self:checknext(ls, ")")
			self:chunk(ls)
			new_fs.f.lastlinedefined = ls.linenumber
			self:check_match(ls, "TK_END", "TK_FUNCTION", line)
			self:close_func(ls)
			self:pushclosure(ls, new_fs, e)
		end

		------------------------------------------------------------------------
		-- parse a list of comma-separated expressions
		-- * used is multiple locations
		------------------------------------------------------------------------
		function luaY:explist1(ls, v)
			-- explist1 -> expr { ',' expr }
			local n = 1  -- at least one expression
			self:expr(ls, v)
			while self:testnext(ls, ",") do
				luaK:exp2nextreg(ls.fs, v)
				self:expr(ls, v)
				n = n + 1
			end
			return n
		end

		------------------------------------------------------------------------
		-- parse the parameters of a function call
		-- * contrast with parlist(), used in function declarations
		-- * used in primaryexp()
		------------------------------------------------------------------------
		function luaY:funcargs(ls, f)
			local fs = ls.fs
			local args = {}  -- expdesc
			local nparams
			local line = ls.linenumber
			local c = ls.t.token
			if c == "(" then  -- funcargs -> '(' [ explist1 ] ')'
				if line ~= ls.lastline then
					luaX:syntaxerror(ls, "ambiguous syntax (function call x new statement)")
				end
				luaX:next(ls)
				if ls.t.token == ")" then  -- arg list is empty?
					args.k = "VVOID"
				else
					self:explist1(ls, args)
					luaK:setmultret(fs, args)
				end
				self:check_match(ls, ")", "(", line)
			elseif c == "{" then  -- funcargs -> constructor
				self:constructor(ls, args)
			elseif c == "TK_STRING" then  -- funcargs -> STRING
				self:codestring(ls, args, ls.t.seminfo)
				luaX:next(ls)  -- must use 'seminfo' before 'next'
			else
				luaX:syntaxerror(ls, "function arguments expected")
				return
			end
			lua_assert(f.k == "VNONRELOC")
			local base = f.info  -- base register for call
			if self:hasmultret(args.k) then
				nparams = self.LUA_MULTRET  -- open call
			else
				if args.k ~= "VVOID" then
					luaK:exp2nextreg(fs, args)  -- close last argument
				end
				nparams = fs.freereg - (base + 1)
			end
			self:init_exp(f, "VCALL", luaK:codeABC(fs, "OP_CALL", base, nparams + 1, 2))
			luaK:fixline(fs, line)
			fs.freereg = base + 1  -- call remove function and arguments and leaves
			-- (unless changed) one result
		end

--[[--------------------------------------------------------------------
-- Expression parsing
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- parses an expression in parentheses or a single variable
		-- * used in primaryexp()
		------------------------------------------------------------------------
		function luaY:prefixexp(ls, v)
			-- prefixexp -> NAME | '(' expr ')'
			local c = ls.t.token
			if c == "(" then
				local line = ls.linenumber
				luaX:next(ls)
				self:expr(ls, v)
				self:check_match(ls, ")", "(", line)
				luaK:dischargevars(ls.fs, v)
			elseif c == "TK_NAME" then
				self:singlevar(ls, v)
			else
				luaX:syntaxerror(ls, "unexpected symbol")
			end--if c
			return
		end

		------------------------------------------------------------------------
		-- parses a prefixexp (an expression in parentheses or a single variable)
		-- or a function call specification
		-- * used in simpleexp(), assignment(), exprstat()
		------------------------------------------------------------------------
		function luaY:primaryexp(ls, v)
			-- primaryexp ->
			--    prefixexp { '.' NAME | '[' exp ']' | ':' NAME funcargs | funcargs }
			local fs = ls.fs
			self:prefixexp(ls, v)
			while true do
				local c = ls.t.token
				if c == "." then  -- field
					self:field(ls, v)
				elseif c == "[" then  -- '[' exp1 ']'
					local key = {}  -- expdesc
					luaK:exp2anyreg(fs, v)
					self:yindex(ls, key)
					luaK:indexed(fs, v, key)
				elseif c == ":" then  -- ':' NAME funcargs
					local key = {}  -- expdesc
					luaX:next(ls)
					self:checkname(ls, key)
					luaK:_self(fs, v, key)
					self:funcargs(ls, v)
				elseif c == "(" or c == "TK_STRING" or c == "{" then  -- funcargs
					luaK:exp2nextreg(fs, v)
					self:funcargs(ls, v)
				else
					return
				end--if c
			end--while
		end

		------------------------------------------------------------------------
		-- parses general expression types, constants handled here
		-- * used in subexpr()
		------------------------------------------------------------------------
		function luaY:simpleexp(ls, v)
			-- simpleexp -> NUMBER | STRING | NIL | TRUE | FALSE | ... |
			--              constructor | FUNCTION body | primaryexp
			local c = ls.t.token
			if c == "TK_NUMBER" then
				self:init_exp(v, "VKNUM", 0)
				v.nval = ls.t.seminfo
			elseif c == "TK_STRING" then
				self:codestring(ls, v, ls.t.seminfo)
			elseif c == "TK_NIL" then
				self:init_exp(v, "VNIL", 0)
			elseif c == "TK_TRUE" then
				self:init_exp(v, "VTRUE", 0)
			elseif c == "TK_FALSE" then
				self:init_exp(v, "VFALSE", 0)
			elseif c == "TK_DOTS" then  -- vararg
				local fs = ls.fs
				self:check_condition(ls, fs.f.is_vararg ~= 0,
					"cannot use "..self:LUA_QL("...").." outside a vararg function");
				-- NOTE: the following substitutes for a bitop, but is value-specific
				local is_vararg = fs.f.is_vararg
				if is_vararg >= self.VARARG_NEEDSARG then
					fs.f.is_vararg = is_vararg - self.VARARG_NEEDSARG  -- don't need 'arg'
				end
				self:init_exp(v, "VVARARG", luaK:codeABC(fs, "OP_VARARG", 0, 1, 0))
			elseif c == "{" then  -- constructor
				self:constructor(ls, v)
				return
			elseif c == "TK_FUNCTION" then
				luaX:next(ls)
				self:body(ls, v, false, ls.linenumber)
				return
			else
				self:primaryexp(ls, v)
				return
			end--if c
			luaX:next(ls)
		end

		------------------------------------------------------------------------
		-- Translates unary operators tokens if found, otherwise returns
		-- OPR_NOUNOPR. getunopr() and getbinopr() are used in subexpr().
		-- * used in subexpr()
		------------------------------------------------------------------------
		function luaY:getunopr(op)
			if op == "TK_NOT" then
				return "OPR_NOT"
			elseif op == "-" then
				return "OPR_MINUS"
			elseif op == "#" then
				return "OPR_LEN"
			else
				return "OPR_NOUNOPR"
			end
		end

		------------------------------------------------------------------------
		-- Translates binary operator tokens if found, otherwise returns
		-- OPR_NOBINOPR. Code generation uses OPR_* style tokens.
		-- * used in subexpr()
		------------------------------------------------------------------------
		luaY.getbinopr_table = {
			["+"] = "OPR_ADD",
			["-"] = "OPR_SUB",
			["*"] = "OPR_MUL",
			["/"] = "OPR_DIV",
			["%"] = "OPR_MOD",
			["^"] = "OPR_POW",
			["TK_CONCAT"] = "OPR_CONCAT",
			["TK_NE"] = "OPR_NE",
			["TK_EQ"] = "OPR_EQ",
			["<"] = "OPR_LT",
			["TK_LE"] = "OPR_LE",
			[">"] = "OPR_GT",
			["TK_GE"] = "OPR_GE",
			["TK_AND"] = "OPR_AND",
			["TK_OR"] = "OPR_OR",
		}
		function luaY:getbinopr(op)
			local opr = self.getbinopr_table[op]
			if opr then return opr else return "OPR_NOBINOPR" end
		end

		------------------------------------------------------------------------
		-- the following priority table consists of pairs of left/right values
		-- for binary operators (was a static const struct); grep for ORDER OPR
		-- * the following struct is replaced:
		--   static const struct {
		--     lu_byte left;  /* left priority for each binary operator */
		--     lu_byte right; /* right priority */
		--   } priority[] = {  /* ORDER OPR */
		------------------------------------------------------------------------
		luaY.priority = {
			{6, 6}, {6, 6}, {7, 7}, {7, 7}, {7, 7}, -- `+' `-' `/' `%'
			{10, 9}, {5, 4},                 -- power and concat (right associative)
			{3, 3}, {3, 3},                  -- equality
			{3, 3}, {3, 3}, {3, 3}, {3, 3},  -- order
			{2, 2}, {1, 1}                   -- logical (and/or)
		}

		luaY.UNARY_PRIORITY = 8  -- priority for unary operators

		------------------------------------------------------------------------
		-- Parse subexpressions. Includes handling of unary operators and binary
		-- operators. A subexpr is given the rhs priority level of the operator
		-- immediately left of it, if any (limit is -1 if none,) and if a binop
		-- is found, limit is compared with the lhs priority level of the binop
		-- in order to determine which executes first.
		------------------------------------------------------------------------

		------------------------------------------------------------------------
		-- subexpr -> (simpleexp | unop subexpr) { binop subexpr }
		-- where 'binop' is any binary operator with a priority higher than 'limit'
		-- * for priority lookups with self.priority[], 1=left and 2=right
		-- * recursively called
		-- * used in expr()
		------------------------------------------------------------------------
		function luaY:subexpr(ls, v, limit)
			self:enterlevel(ls)
			local uop = self:getunopr(ls.t.token)
			if uop ~= "OPR_NOUNOPR" then
				luaX:next(ls)
				self:subexpr(ls, v, self.UNARY_PRIORITY)
				luaK:prefix(ls.fs, uop, v)
			else
				self:simpleexp(ls, v)
			end
			-- expand while operators have priorities higher than 'limit'
			local op = self:getbinopr(ls.t.token)
			while op ~= "OPR_NOBINOPR" and self.priority[luaK.BinOpr[op] + 1][1] > limit do
				local v2 = {}  -- expdesc
				luaX:next(ls)
				luaK:infix(ls.fs, op, v)
				-- read sub-expression with higher priority
				local nextop = self:subexpr(ls, v2, self.priority[luaK.BinOpr[op] + 1][2])
				luaK:posfix(ls.fs, op, v, v2)
				op = nextop
			end
			self:leavelevel(ls)
			return op  -- return first untreated operator
		end

		------------------------------------------------------------------------
		-- Expression parsing starts here. Function subexpr is entered with the
		-- left operator (which is non-existent) priority of -1, which is lower
		-- than all actual operators. Expr information is returned in parm v.
		-- * used in multiple locations
		------------------------------------------------------------------------
		function luaY:expr(ls, v)
			self:subexpr(ls, v, 0)
		end

		-- }====================================================================

--[[--------------------------------------------------------------------
-- Rules for Statements
----------------------------------------------------------------------]]

		------------------------------------------------------------------------
		-- checks next token, used as a look-ahead
		-- * returns boolean instead of 0|1
		-- * used in retstat(), chunk()
		------------------------------------------------------------------------
		function luaY:block_follow(token)
			if token == "TK_ELSE" or token == "TK_ELSEIF" or token == "TK_END"
				or token == "TK_UNTIL" or token == "TK_EOS" then
				return true
			else
				return false
			end
		end

		------------------------------------------------------------------------
		-- parse a code block or unit
		-- * used in multiple functions
		------------------------------------------------------------------------
		function luaY:block(ls)
			-- block -> chunk
			local fs = ls.fs
			local bl = {}  -- BlockCnt
			self:enterblock(fs, bl, false)
			self:chunk(ls)
			lua_assert(bl.breaklist == luaK.NO_JUMP)
			self:leaveblock(fs)
		end

		------------------------------------------------------------------------
		-- structure to chain all variables in the left-hand side of an
		-- assignment
		-- struct LHS_assign:
		--   prev  -- (table: struct LHS_assign)
		--   v  -- variable (global, local, upvalue, or indexed) (table: expdesc)
		------------------------------------------------------------------------

		------------------------------------------------------------------------
		-- check whether, in an assignment to a local variable, the local variable
		-- is needed in a previous assignment (to a table). If so, save original
		-- local value in a safe place and use this safe copy in the previous
		-- assignment.
		-- * used in assignment()
		------------------------------------------------------------------------
		function luaY:check_conflict(ls, lh, v)
			local fs = ls.fs
			local extra = fs.freereg  -- eventual position to save local variable
			local conflict = false
			while lh do
				if lh.v.k == "VINDEXED" then
					if lh.v.info == v.info then  -- conflict?
						conflict = true
						lh.v.info = extra  -- previous assignment will use safe copy
					end
					if lh.v.aux == v.info then  -- conflict?
						conflict = true
						lh.v.aux = extra  -- previous assignment will use safe copy
					end
				end
				lh = lh.prev
			end
			if conflict then
				luaK:codeABC(fs, "OP_MOVE", fs.freereg, v.info, 0)  -- make copy
				luaK:reserveregs(fs, 1)
			end
		end

		------------------------------------------------------------------------
		-- parse a variable assignment sequence
		-- * recursively called
		-- * used in exprstat()
		------------------------------------------------------------------------
		function luaY:assignment(ls, lh, nvars)
			local e = {}  -- expdesc
			-- test was: VLOCAL <= lh->v.k && lh->v.k <= VINDEXED
			local c = lh.v.k
			self:check_condition(ls, c == "VLOCAL" or c == "VUPVAL" or c == "VGLOBAL"
				or c == "VINDEXED", "syntax error")
			if self:testnext(ls, ",") then  -- assignment -> ',' primaryexp assignment
				local nv = {}  -- LHS_assign
				nv.v = {}
				nv.prev = lh
				self:primaryexp(ls, nv.v)
				if nv.v.k == "VLOCAL" then
					self:check_conflict(ls, lh, nv.v)
				end
				self:checklimit(ls.fs, nvars, self.LUAI_MAXCCALLS - ls.L.nCcalls,
					"variables in assignment")
				self:assignment(ls, nv, nvars + 1)
			else  -- assignment -> '=' explist1
				self:checknext(ls, "=")
				local nexps = self:explist1(ls, e)
				if nexps ~= nvars then
					self:adjust_assign(ls, nvars, nexps, e)
					if nexps > nvars then
						ls.fs.freereg = ls.fs.freereg - (nexps - nvars)  -- remove extra values
					end
				else
					luaK:setoneret(ls.fs, e)  -- close last expression
					luaK:storevar(ls.fs, lh.v, e)
					return  -- avoid default
				end
			end
			self:init_exp(e, "VNONRELOC", ls.fs.freereg - 1)  -- default assignment
			luaK:storevar(ls.fs, lh.v, e)
		end

		------------------------------------------------------------------------
		-- parse condition in a repeat statement or an if control structure
		-- * used in repeatstat(), test_then_block()
		------------------------------------------------------------------------
		function luaY:cond(ls)
			-- cond -> exp
			local v = {}  -- expdesc
			self:expr(ls, v)  -- read condition
			if v.k == "VNIL" then v.k = "VFALSE" end  -- 'falses' are all equal here
			luaK:goiftrue(ls.fs, v)
			return v.f
		end

		------------------------------------------------------------------------
		-- parse a break statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:breakstat(ls)
			-- stat -> BREAK
			local fs = ls.fs
			local bl = fs.bl
			local upval = false
			while bl and not bl.isbreakable do
				if bl.upval then upval = true end
				bl = bl.previous
			end
			if not bl then
				luaX:syntaxerror(ls, "no loop to break")
			end
			if upval then
				luaK:codeABC(fs, "OP_CLOSE", bl.nactvar, 0, 0)
			end
			bl.breaklist = luaK:concat(fs, bl.breaklist, luaK:jump(fs))
		end

		------------------------------------------------------------------------
		-- parse a while-do control structure, body processed by block()
		-- * with dynamic array sizes, MAXEXPWHILE + EXTRAEXP limits imposed by
		--   the function's implementation can be removed
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:whilestat(ls, line)
			-- whilestat -> WHILE cond DO block END
			local fs = ls.fs
			local bl = {}  -- BlockCnt
			luaX:next(ls)  -- skip WHILE
			local whileinit = luaK:getlabel(fs)
			local condexit = self:cond(ls)
			self:enterblock(fs, bl, true)
			self:checknext(ls, "TK_DO")
			self:block(ls)
			luaK:patchlist(fs, luaK:jump(fs), whileinit)
			self:check_match(ls, "TK_END", "TK_WHILE", line)
			self:leaveblock(fs)
			luaK:patchtohere(fs, condexit)  -- false conditions finish the loop
		end

		------------------------------------------------------------------------
		-- parse a repeat-until control structure, body parsed by chunk()
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:repeatstat(ls, line)
			-- repeatstat -> REPEAT block UNTIL cond
			local fs = ls.fs
			local repeat_init = luaK:getlabel(fs)
			local bl1, bl2 = {}, {}  -- BlockCnt
			self:enterblock(fs, bl1, true)  -- loop block
			self:enterblock(fs, bl2, false)  -- scope block
			luaX:next(ls)  -- skip REPEAT
			self:chunk(ls)
			self:check_match(ls, "TK_UNTIL", "TK_REPEAT", line)
			local condexit = self:cond(ls)  -- read condition (inside scope block)
			if not bl2.upval then  -- no upvalues?
				self:leaveblock(fs)  -- finish scope
				luaK:patchlist(ls.fs, condexit, repeat_init)  -- close the loop
			else  -- complete semantics when there are upvalues
				self:breakstat(ls)  -- if condition then break
				luaK:patchtohere(ls.fs, condexit)  -- else...
				self:leaveblock(fs)  -- finish scope...
				luaK:patchlist(ls.fs, luaK:jump(fs), repeat_init)  -- and repeat
			end
			self:leaveblock(fs)  -- finish loop
		end

		------------------------------------------------------------------------
		-- parse the single expressions needed in numerical for loops
		-- * used in fornum()
		------------------------------------------------------------------------
		function luaY:exp1(ls)
			local e = {}  -- expdesc
			self:expr(ls, e)
			local k = e.k
			luaK:exp2nextreg(ls.fs, e)
			return k
		end

		------------------------------------------------------------------------
		-- parse a for loop body for both versions of the for loop
		-- * used in fornum(), forlist()
		------------------------------------------------------------------------
		function luaY:forbody(ls, base, line, nvars, isnum)
			-- forbody -> DO block
			local bl = {}  -- BlockCnt
			local fs = ls.fs
			self:adjustlocalvars(ls, 3)  -- control variables
			self:checknext(ls, "TK_DO")
			local prep = isnum and luaK:codeAsBx(fs, "OP_FORPREP", base, luaK.NO_JUMP)
				or luaK:jump(fs)
			self:enterblock(fs, bl, false)  -- scope for declared variables
			self:adjustlocalvars(ls, nvars)
			luaK:reserveregs(fs, nvars)
			self:block(ls)
			self:leaveblock(fs)  -- end of scope for declared variables
			luaK:patchtohere(fs, prep)
			local endfor = isnum and luaK:codeAsBx(fs, "OP_FORLOOP", base, luaK.NO_JUMP)
				or luaK:codeABC(fs, "OP_TFORLOOP", base, 0, nvars)
			luaK:fixline(fs, line)  -- pretend that `OP_FOR' starts the loop
			luaK:patchlist(fs, isnum and endfor or luaK:jump(fs), prep + 1)
		end

		------------------------------------------------------------------------
		-- parse a numerical for loop, calls forbody()
		-- * used in forstat()
		------------------------------------------------------------------------
		function luaY:fornum(ls, varname, line)
			-- fornum -> NAME = exp1,exp1[,exp1] forbody
			local fs = ls.fs
			local base = fs.freereg
			self:new_localvarliteral(ls, "(for index)", 0)
			self:new_localvarliteral(ls, "(for limit)", 1)
			self:new_localvarliteral(ls, "(for step)", 2)
			self:new_localvar(ls, varname, 3)
			self:checknext(ls, '=')
			self:exp1(ls)  -- initial value
			self:checknext(ls, ",")
			self:exp1(ls)  -- limit
			if self:testnext(ls, ",") then
				self:exp1(ls)  -- optional step
			else  -- default step = 1
				luaK:codeABx(fs, "OP_LOADK", fs.freereg, luaK:numberK(fs, 1))
				luaK:reserveregs(fs, 1)
			end
			self:forbody(ls, base, line, 1, true)
		end

		------------------------------------------------------------------------
		-- parse a generic for loop, calls forbody()
		-- * used in forstat()
		------------------------------------------------------------------------
		function luaY:forlist(ls, indexname)
			-- forlist -> NAME {,NAME} IN explist1 forbody
			local fs = ls.fs
			local e = {}  -- expdesc
			local nvars = 0
			local base = fs.freereg
			-- create control variables
			self:new_localvarliteral(ls, "(for generator)", nvars)
			nvars = nvars + 1
			self:new_localvarliteral(ls, "(for state)", nvars)
			nvars = nvars + 1
			self:new_localvarliteral(ls, "(for control)", nvars)
			nvars = nvars + 1
			-- create declared variables
			self:new_localvar(ls, indexname, nvars)
			nvars = nvars + 1
			while self:testnext(ls, ",") do
				self:new_localvar(ls, self:str_checkname(ls), nvars)
				nvars = nvars + 1
			end
			self:checknext(ls, "TK_IN")
			local line = ls.linenumber
			self:adjust_assign(ls, 3, self:explist1(ls, e), e)
			luaK:checkstack(fs, 3)  -- extra space to call generator
			self:forbody(ls, base, line, nvars - 3, false)
		end

		------------------------------------------------------------------------
		-- initial parsing for a for loop, calls fornum() or forlist()
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:forstat(ls, line)
			-- forstat -> FOR (fornum | forlist) END
			local fs = ls.fs
			local bl = {}  -- BlockCnt
			self:enterblock(fs, bl, true)  -- scope for loop and control variables
			luaX:next(ls)  -- skip `for'
			local varname = self:str_checkname(ls)  -- first variable name
			local c = ls.t.token
			if c == "=" then
				self:fornum(ls, varname, line)
			elseif c == "," or c == "TK_IN" then
				self:forlist(ls, varname)
			else
				luaX:syntaxerror(ls, self:LUA_QL("=").." or "..self:LUA_QL("in").." expected")
			end
			self:check_match(ls, "TK_END", "TK_FOR", line)
			self:leaveblock(fs)  -- loop scope (`break' jumps to this point)
		end

		------------------------------------------------------------------------
		-- parse part of an if control structure, including the condition
		-- * used in ifstat()
		------------------------------------------------------------------------
		function luaY:test_then_block(ls)
			-- test_then_block -> [IF | ELSEIF] cond THEN block
			luaX:next(ls)  -- skip IF or ELSEIF
			local condexit = self:cond(ls)
			self:checknext(ls, "TK_THEN")
			self:block(ls)  -- `then' part
			return condexit
		end

		------------------------------------------------------------------------
		-- parse an if control structure
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:ifstat(ls, line)
			-- ifstat -> IF cond THEN block {ELSEIF cond THEN block} [ELSE block] END
			local fs = ls.fs
			local escapelist = luaK.NO_JUMP
			local flist = self:test_then_block(ls)  -- IF cond THEN block
			while ls.t.token == "TK_ELSEIF" do
				escapelist = luaK:concat(fs, escapelist, luaK:jump(fs))
				luaK:patchtohere(fs, flist)
				flist = self:test_then_block(ls)  -- ELSEIF cond THEN block
			end
			if ls.t.token == "TK_ELSE" then
				escapelist = luaK:concat(fs, escapelist, luaK:jump(fs))
				luaK:patchtohere(fs, flist)
				luaX:next(ls)  -- skip ELSE (after patch, for correct line info)
				self:block(ls)  -- 'else' part
			else
				escapelist = luaK:concat(fs, escapelist, flist)
			end
			luaK:patchtohere(fs, escapelist)
			self:check_match(ls, "TK_END", "TK_IF", line)
		end

		------------------------------------------------------------------------
		-- parse a local function statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:localfunc(ls)
			local v, b = {}, {}  -- expdesc
			local fs = ls.fs
			self:new_localvar(ls, self:str_checkname(ls), 0)
			self:init_exp(v, "VLOCAL", fs.freereg)
			luaK:reserveregs(fs, 1)
			self:adjustlocalvars(ls, 1)
			self:body(ls, b, false, ls.linenumber)
			luaK:storevar(fs, v, b)
			-- debug information will only see the variable after this point!
			self:getlocvar(fs, fs.nactvar - 1).startpc = fs.pc
		end

		------------------------------------------------------------------------
		-- parse a local variable declaration statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:localstat(ls)
			-- stat -> LOCAL NAME {',' NAME} ['=' explist1]
			local nvars = 0
			local nexps
			local e = {}  -- expdesc
			repeat
				self:new_localvar(ls, self:str_checkname(ls), nvars)
				nvars = nvars + 1
			until not self:testnext(ls, ",")
			if self:testnext(ls, "=") then
				nexps = self:explist1(ls, e)
			else
				e.k = "VVOID"
				nexps = 0
			end
			self:adjust_assign(ls, nvars, nexps, e)
			self:adjustlocalvars(ls, nvars)
		end

		------------------------------------------------------------------------
		-- parse a function name specification
		-- * used in funcstat()
		------------------------------------------------------------------------
		function luaY:funcname(ls, v)
			-- funcname -> NAME {field} [':' NAME]
			local needself = false
			self:singlevar(ls, v)
			while ls.t.token == "." do
				self:field(ls, v)
			end
			if ls.t.token == ":" then
				needself = true
				self:field(ls, v)
			end
			return needself
		end

		------------------------------------------------------------------------
		-- parse a function statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:funcstat(ls, line)
			-- funcstat -> FUNCTION funcname body
			local v, b = {}, {}  -- expdesc
			luaX:next(ls)  -- skip FUNCTION
			local needself = self:funcname(ls, v)
			self:body(ls, b, needself, line)
			luaK:storevar(ls.fs, v, b)
			luaK:fixline(ls.fs, line)  -- definition 'happens' in the first line
		end

		------------------------------------------------------------------------
		-- parse a function call with no returns or an assignment statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:exprstat(ls)
			-- stat -> func | assignment
			local fs = ls.fs
			local v = {}  -- LHS_assign
			v.v = {}
			self:primaryexp(ls, v.v)
			if v.v.k == "VCALL" then  -- stat -> func
				luaP:SETARG_C(luaK:getcode(fs, v.v), 1)  -- call statement uses no results
			else  -- stat -> assignment
				v.prev = nil
				self:assignment(ls, v, 1)
			end
		end

		------------------------------------------------------------------------
		-- parse a return statement
		-- * used in statements()
		------------------------------------------------------------------------
		function luaY:retstat(ls)
			-- stat -> RETURN explist
			local fs = ls.fs
			local e = {}  -- expdesc
			local first, nret  -- registers with returned values
			luaX:next(ls)  -- skip RETURN
			if self:block_follow(ls.t.token) or ls.t.token == ";" then
				first, nret = 0, 0  -- return no values
			else
				nret = self:explist1(ls, e)  -- optional return values
				if self:hasmultret(e.k) then
					luaK:setmultret(fs, e)
					if e.k == "VCALL" and nret == 1 then  -- tail call?
						luaP:SET_OPCODE(luaK:getcode(fs, e), "OP_TAILCALL")
						lua_assert(luaP:GETARG_A(luaK:getcode(fs, e)) == fs.nactvar)
					end
					first = fs.nactvar
					nret = self.LUA_MULTRET  -- return all values
				else
					if nret == 1 then  -- only one single value?
						first = luaK:exp2anyreg(fs, e)
					else
						luaK:exp2nextreg(fs, e)  -- values must go to the 'stack'
						first = fs.nactvar  -- return all 'active' values
						lua_assert(nret == fs.freereg - first)
					end
				end--if
			end--if
			luaK:ret(fs, first, nret)
		end

		------------------------------------------------------------------------
		-- initial parsing for statements, calls a lot of functions
		-- * returns boolean instead of 0|1
		-- * used in chunk()
		------------------------------------------------------------------------
		function luaY:statement(ls)
			local line = ls.linenumber  -- may be needed for error messages
			local c = ls.t.token
			if c == "TK_IF" then  -- stat -> ifstat
				self:ifstat(ls, line)
				return false
			elseif c == "TK_WHILE" then  -- stat -> whilestat
				self:whilestat(ls, line)
				return false
			elseif c == "TK_DO" then  -- stat -> DO block END
				luaX:next(ls)  -- skip DO
				self:block(ls)
				self:check_match(ls, "TK_END", "TK_DO", line)
				return false
			elseif c == "TK_FOR" then  -- stat -> forstat
				self:forstat(ls, line)
				return false
			elseif c == "TK_REPEAT" then  -- stat -> repeatstat
				self:repeatstat(ls, line)
				return false
			elseif c == "TK_FUNCTION" then  -- stat -> funcstat
				self:funcstat(ls, line)
				return false
			elseif c == "TK_LOCAL" then  -- stat -> localstat
				luaX:next(ls)  -- skip LOCAL
				if self:testnext(ls, "TK_FUNCTION") then  -- local function?
					self:localfunc(ls)
				else
					self:localstat(ls)
				end
				return false
			elseif c == "TK_RETURN" then  -- stat -> retstat
				self:retstat(ls)
				return true  -- must be last statement
			elseif c == "TK_BREAK" then  -- stat -> breakstat
				luaX:next(ls)  -- skip BREAK
				self:breakstat(ls)
				return true  -- must be last statement
			else
				self:exprstat(ls)
				return false  -- to avoid warnings
			end--if c
		end

		------------------------------------------------------------------------
		-- parse a chunk, which consists of a bunch of statements
		-- * used in parser(), body(), block(), repeatstat()
		------------------------------------------------------------------------
		function luaY:chunk(ls)
			-- chunk -> { stat [';'] }
			local islast = false
			self:enterlevel(ls)
			while not islast and not self:block_follow(ls.t.token) do
				islast = self:statement(ls)
				self:testnext(ls, ";")
				lua_assert(ls.fs.f.maxstacksize >= ls.fs.freereg and
					ls.fs.freereg >= ls.fs.nactvar)
				ls.fs.freereg = ls.fs.nactvar  -- free registers
			end
			self:leavelevel(ls)
		end

		-- }======================================================================





		luaX:init()  -- required by llex
		local LuaState = {}  -- dummy, not actually used, but retained since
		-- the intention is to complete a straight port

		------------------------------------------------------------------------
		-- interfacing to yueliang
		------------------------------------------------------------------------


		return function (source, name)
			name = name or 'compiled-lua'
			-- luaZ:make_getF returns a file chunk reader
			-- luaZ:init returns a zio input stream
			local zio = luaZ:init(luaZ:make_getF(source), nil)
			if not zio then return end
			-- luaY:parser parses the input stream
			-- func is the function prototype in tabular form; in C, func can
			-- now be used directly by the VM, this can't be done in Lua

			local func = luaY:parser(LuaState, zio, nil, "@"..name)
			-- luaU:make_setS returns a string chunk writer
			local writer, buff = luaU:make_setS()
			-- luaU:dump builds a binary chunk
			luaU:dump(LuaState, func, writer, buff)
			-- a string.dump equivalent in returned

			return buff.data
		end
	end)()

	local createExecutable = coroutine.wrap(function()
    --[[
FiOne
Copyright (C) 2021  Rerumu

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]] --
		local bit = bit or bit32 or require('bit')

		if not table.create then function table.create(_) return {} end end

		if not table.unpack then table.unpack = unpack end

		if not table.pack then function table.pack(...) return {n = select('#', ...), ...} end end

		if not table.move then
			function table.move(src, first, last, offset, dst)
				for i = 0, last - first do dst[offset + i] = src[first + i] end
			end
		end

		local lua_bc_to_state
		local lua_wrap_state
		local stm_lua_func

		-- SETLIST config
		local FIELDS_PER_FLUSH = 50

		-- remap for better lookup
		local OPCODE_RM = {
			-- level 1
			[22] = 18, -- JMP
			[31] = 8, -- FORLOOP
			[33] = 28, -- TFORLOOP
			-- level 2
			[0] = 3, -- MOVE
			[1] = 13, -- LOADK
			[2] = 23, -- LOADBOOL
			[26] = 33, -- TEST
			-- level 3
			[12] = 1, -- ADD
			[13] = 6, -- SUB
			[14] = 10, -- MUL
			[15] = 16, -- DIV
			[16] = 20, -- MOD
			[17] = 26, -- POW
			[18] = 30, -- UNM
			[19] = 36, -- NOT
			-- level 4
			[3] = 0, -- LOADNIL
			[4] = 2, -- GETUPVAL
			[5] = 4, -- GETGLOBAL
			[6] = 7, -- GETTABLE
			[7] = 9, -- SETGLOBAL
			[8] = 12, -- SETUPVAL
			[9] = 14, -- SETTABLE
			[10] = 17, -- NEWTABLE
			[20] = 19, -- LEN
			[21] = 22, -- CONCAT
			[23] = 24, -- EQ
			[24] = 27, -- LT
			[25] = 29, -- LE
			[27] = 32, -- TESTSET
			[32] = 34, -- FORPREP
			[34] = 37, -- SETLIST
			-- level 5
			[11] = 5, -- SELF
			[28] = 11, -- CALL
			[29] = 15, -- TAILCALL
			[30] = 21, -- RETURN
			[35] = 25, -- CLOSE
			[36] = 31, -- CLOSURE
			[37] = 35, -- VARARG
		}

		-- opcode types for getting values
		local OPCODE_T = {
			[0] = 'ABC',
			'ABx',
			'ABC',
			'ABC',
			'ABC',
			'ABx',
			'ABC',
			'ABx',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'AsBx',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'ABC',
			'AsBx',
			'AsBx',
			'ABC',
			'ABC',
			'ABC',
			'ABx',
			'ABC',
		}

		local OPCODE_M = {
			[0] = {b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgK', c = 'OpArgN'},
			{b = 'OpArgU', c = 'OpArgU'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgU', c = 'OpArgN'},
			{b = 'OpArgK', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgN'},
			{b = 'OpArgU', c = 'OpArgN'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgU', c = 'OpArgU'},
			{b = 'OpArgR', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgR'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgK', c = 'OpArgK'},
			{b = 'OpArgR', c = 'OpArgU'},
			{b = 'OpArgR', c = 'OpArgU'},
			{b = 'OpArgU', c = 'OpArgU'},
			{b = 'OpArgU', c = 'OpArgU'},
			{b = 'OpArgU', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgR', c = 'OpArgN'},
			{b = 'OpArgN', c = 'OpArgU'},
			{b = 'OpArgU', c = 'OpArgU'},
			{b = 'OpArgN', c = 'OpArgN'},
			{b = 'OpArgU', c = 'OpArgN'},
			{b = 'OpArgU', c = 'OpArgN'},
		}

		-- int rd_int_basic(string src, int s, int e, int d)
		-- @src - Source binary string
		-- @s - Start index of a little endian integer
		-- @e - End index of the integer
		-- @d - Direction of the loop
		local function rd_int_basic(src, s, e, d)
			local num = 0

			-- if bb[l] > 127 then -- signed negative
			-- 	num = num - 256 ^ l
			-- 	bb[l] = bb[l] - 128
			-- end

			for i = s, e, d do
				local mul = 256 ^ math.abs(i - s)

				num = num + mul * string.byte(src, i, i)
			end

			return num
		end

		-- float rd_flt_basic(byte f1..8)
		-- @f1..4 - The 4 bytes composing a little endian float
		local function rd_flt_basic(f1, f2, f3, f4)
			local sign = (-1) ^ bit.rshift(f4, 7)
			local exp = bit.rshift(f3, 7) + bit.lshift(bit.band(f4, 0x7F), 1)
			local frac = f1 + bit.lshift(f2, 8) + bit.lshift(bit.band(f3, 0x7F), 16)
			local normal = 1

			if exp == 0 then
				if frac == 0 then
					return sign * 0
				else
					normal = 0
					exp = 1
				end
			elseif exp == 0x7F then
				if frac == 0 then
					return sign * (1 / 0)
				else
					return sign * (0 / 0)
				end
			end

			return sign * 2 ^ (exp - 127) * (1 + normal / 2 ^ 23)
		end

		-- double rd_dbl_basic(byte f1..8)
		-- @f1..8 - The 8 bytes composing a little endian double
		local function rd_dbl_basic(f1, f2, f3, f4, f5, f6, f7, f8)
			local sign = (-1) ^ bit.rshift(f8, 7)
			local exp = bit.lshift(bit.band(f8, 0x7F), 4) + bit.rshift(f7, 4)
			local frac = bit.band(f7, 0x0F) * 2 ^ 48
			local normal = 1

			frac = frac + (f6 * 2 ^ 40) + (f5 * 2 ^ 32) + (f4 * 2 ^ 24) + (f3 * 2 ^ 16) + (f2 * 2 ^ 8) + f1 -- help

			if exp == 0 then
				if frac == 0 then
					return sign * 0
				else
					normal = 0
					exp = 1
				end
			elseif exp == 0x7FF then
				if frac == 0 then
					return sign * (1 / 0)
				else
					return sign * (0 / 0)
				end
			end

			return sign * 2 ^ (exp - 1023) * (normal + frac / 2 ^ 52)
		end

		-- int rd_int_le(string src, int s, int e)
		-- @src - Source binary string
		-- @s - Start index of a little endian integer
		-- @e - End index of the integer
		local function rd_int_le(src, s, e) return rd_int_basic(src, s, e - 1, 1) end

		-- int rd_int_be(string src, int s, int e)
		-- @src - Source binary string
		-- @s - Start index of a big endian integer
		-- @e - End index of the integer
		local function rd_int_be(src, s, e) return rd_int_basic(src, e - 1, s, -1) end

		-- float rd_flt_le(string src, int s)
		-- @src - Source binary string
		-- @s - Start index of little endian float
		local function rd_flt_le(src, s) return rd_flt_basic(string.byte(src, s, s + 3)) end

		-- float rd_flt_be(string src, int s)
		-- @src - Source binary string
		-- @s - Start index of big endian float
		local function rd_flt_be(src, s)
			local f1, f2, f3, f4 = string.byte(src, s, s + 3)
			return rd_flt_basic(f4, f3, f2, f1)
		end

		-- double rd_dbl_le(string src, int s)
		-- @src - Source binary string
		-- @s - Start index of little endian double
		local function rd_dbl_le(src, s) return rd_dbl_basic(string.byte(src, s, s + 7)) end

		-- double rd_dbl_be(string src, int s)
		-- @src - Source binary string
		-- @s - Start index of big endian double
		local function rd_dbl_be(src, s)
			local f1, f2, f3, f4, f5, f6, f7, f8 = string.byte(src, s, s + 7) -- same
			return rd_dbl_basic(f8, f7, f6, f5, f4, f3, f2, f1)
		end

		-- to avoid nested ifs in deserializing
		local float_types = {
			[4] = {little = rd_flt_le, big = rd_flt_be},
			[8] = {little = rd_dbl_le, big = rd_dbl_be},
		}

		-- byte stm_byte(Stream S)
		-- @S - Stream object to read from
		local function stm_byte(S)
			local idx = S.index
			local bt = string.byte(S.source, idx, idx)

			S.index = idx + 1
			return bt
		end

		-- string stm_string(Stream S, int len)
		-- @S - Stream object to read from
		-- @len - Length of string being read
		local function stm_string(S, len)
			local pos = S.index + len
			local str = string.sub(S.source, S.index, pos - 1)

			S.index = pos
			return str
		end

		-- string stm_lstring(Stream S)
		-- @S - Stream object to read from
		local function stm_lstring(S)
			local len = S:s_szt()
			local str

			if len ~= 0 then str = string.sub(stm_string(S, len), 1, -2) end

			return str
		end

		-- fn cst_int_rdr(string src, int len, fn func)
		-- @len - Length of type for reader
		-- @func - Reader callback
		local function cst_int_rdr(len, func)
			return function(S)
				local pos = S.index + len
				local int = func(S.source, S.index, pos)
				S.index = pos

				return int
			end
		end

		-- fn cst_flt_rdr(string src, int len, fn func)
		-- @len - Length of type for reader
		-- @func - Reader callback
		local function cst_flt_rdr(len, func)
			return function(S)
				local flt = func(S.source, S.index)
				S.index = S.index + len

				return flt
			end
		end

		local function stm_inst_list(S)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do
				local ins = S:s_ins()
				local op = bit.band(ins, 0x3F)
				local args = OPCODE_T[op]
				local mode = OPCODE_M[op]
				local data = {value = ins, op = OPCODE_RM[op], A = bit.band(bit.rshift(ins, 6), 0xFF)}

				if args == 'ABC' then
					data.B = bit.band(bit.rshift(ins, 23), 0x1FF)
					data.C = bit.band(bit.rshift(ins, 14), 0x1FF)
					data.is_KB = mode.b == 'OpArgK' and data.B > 0xFF -- post process optimization
					data.is_KC = mode.c == 'OpArgK' and data.C > 0xFF
				elseif args == 'ABx' then
					data.Bx = bit.band(bit.rshift(ins, 14), 0x3FFFF)
					data.is_K = mode.b == 'OpArgK'
				elseif args == 'AsBx' then
					data.sBx = bit.band(bit.rshift(ins, 14), 0x3FFFF) - 131071
				end

				list[i] = data
			end

			return list
		end

		local function stm_const_list(S)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do
				local tt = stm_byte(S)
				local k

				if tt == 1 then
					k = stm_byte(S) ~= 0
				elseif tt == 3 then
					k = S:s_num()
				elseif tt == 4 then
					k = stm_lstring(S)
				end

				list[i] = k -- offset +1 during instruction decode
			end

			return list
		end

		local function stm_sub_list(S, src)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do
				list[i] = stm_lua_func(S, src) -- offset +1 in CLOSURE
			end

			return list
		end

		local function stm_line_list(S)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do list[i] = S:s_int() end

			return list
		end

		local function stm_loc_list(S)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do list[i] = {varname = stm_lstring(S), startpc = S:s_int(), endpc = S:s_int()} end

			return list
		end

		local function stm_upval_list(S)
			local len = S:s_int()
			local list = table.create(len)

			for i = 1, len do list[i] = stm_lstring(S) end

			return list
		end

		function stm_lua_func(S, psrc)
			local proto = {}
			local src = stm_lstring(S) or psrc -- source is propagated

			proto.source = src -- source name

			S:s_int() -- line defined
			S:s_int() -- last line defined

			proto.num_upval = stm_byte(S) -- num upvalues
			proto.num_param = stm_byte(S) -- num params

			stm_byte(S) -- vararg flag
			proto.max_stack = stm_byte(S) -- max stack size

			proto.code = stm_inst_list(S)
			proto.const = stm_const_list(S)
			proto.subs = stm_sub_list(S, src)
			proto.lines = stm_line_list(S)

			stm_loc_list(S)
			stm_upval_list(S)

			-- post process optimization
			for _, v in ipairs(proto.code) do
				if v.is_K then
					v.const = proto.const[v.Bx + 1] -- offset for 1 based index
				else
					if v.is_KB then v.const_B = proto.const[v.B - 0xFF] end

					if v.is_KC then v.const_C = proto.const[v.C - 0xFF] end
				end
			end

			return proto
		end

		function lua_bc_to_state(src)
			-- func reader
			local rdr_func

			-- header flags
			local little
			local size_int
			local size_szt
			local size_ins
			local size_num
			local flag_int

			-- stream object
			local stream = {
				-- data
				index = 1,
				source = src,
			}

			assert(stm_string(stream, 4) == '\27Lua', 'invalid Lua signature')
			assert(stm_byte(stream) == 0x51, 'invalid Lua version')
			assert(stm_byte(stream) == 0, 'invalid Lua format')

			little = stm_byte(stream) ~= 0
			size_int = stm_byte(stream)
			size_szt = stm_byte(stream)
			size_ins = stm_byte(stream)
			size_num = stm_byte(stream)
			flag_int = stm_byte(stream) ~= 0

			rdr_func = little and rd_int_le or rd_int_be
			stream.s_int = cst_int_rdr(size_int, rdr_func)
			stream.s_szt = cst_int_rdr(size_szt, rdr_func)
			stream.s_ins = cst_int_rdr(size_ins, rdr_func)

			if flag_int then
				stream.s_num = cst_int_rdr(size_num, rdr_func)
			elseif float_types[size_num] then
				stream.s_num = cst_flt_rdr(size_num, float_types[size_num][little and 'little' or 'big'])
			else
				error('unsupported float size')
			end

			return stm_lua_func(stream, '@virtual')
		end

		local function close_lua_upvalues(list, index)
			for i, uv in pairs(list) do
				if uv.index >= index then
					uv.value = uv.store[uv.index] -- store value
					uv.store = uv
					uv.index = 'value' -- self reference
					list[i] = nil
				end
			end
		end

		local function open_lua_upvalue(list, index, memory)
			local prev = list[index]

			if not prev then
				prev = {index = index, store = memory}
				list[index] = prev
			end

			return prev
		end

		local function on_lua_error(failed, err)
			local src = failed.source
			local line = failed.lines[failed.pc - 1]

			error(string.format('%s:%i: %s', src, line, err), 0)
		end

		local function run_lua_func(state, env, upvals)
			local code = state.code
			local subs = state.subs
			local vararg = state.vararg

			local top_index = -1
			local open_list = {}
			local memory = state.memory
			local pc = state.pc

			while true do
				local inst = code[pc]
				local op = inst.op
				pc = pc + 1

				if op < 18 then
					if op < 8 then
						if op < 3 then
							if op < 1 then
								--[[LOADNIL]]
								for i = inst.A, inst.B do memory[i] = nil end
							elseif op > 1 then
								--[[GETUPVAL]]
								local uv = upvals[inst.B]

								memory[inst.A] = uv.store[uv.index]
							else
								--[[ADD]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs + rhs
							end
						elseif op > 3 then
							if op < 6 then
								if op > 4 then
									--[[SELF]]
									local A = inst.A
									local B = inst.B
									local index

									if inst.is_KC then
										index = inst.const_C
									else
										index = memory[inst.C]
									end

									memory[A + 1] = memory[B]
									memory[A] = memory[B][index]
								else
									--[[GETGLOBAL]]
									memory[inst.A] = env[inst.const]
								end
							elseif op > 6 then
								--[[GETTABLE]]
								local index

								if inst.is_KC then
									index = inst.const_C
								else
									index = memory[inst.C]
								end

								memory[inst.A] = memory[inst.B][index]
							else
								--[[SUB]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs - rhs
							end
						else --[[MOVE]]
							memory[inst.A] = memory[inst.B]
						end
					elseif op > 8 then
						if op < 13 then
							if op < 10 then
								--[[SETGLOBAL]]
								env[inst.const] = memory[inst.A]
							elseif op > 10 then
								if op < 12 then
									--[[CALL]]
									local A = inst.A
									local B = inst.B
									local C = inst.C
									local params

									if B == 0 then
										params = top_index - A
									else
										params = B - 1
									end

									local ret_list = table.pack(memory[A](table.unpack(memory, A + 1, A + params)))
									local ret_num = ret_list.n

									if C == 0 then
										top_index = A + ret_num - 1
									else
										ret_num = C - 1
									end

									table.move(ret_list, 1, ret_num, A, memory)
								else
									--[[SETUPVAL]]
									local uv = upvals[inst.B]

									uv.store[uv.index] = memory[inst.A]
								end
							else
								--[[MUL]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs * rhs
							end
						elseif op > 13 then
							if op < 16 then
								if op > 14 then
									--[[TAILCALL]]
									local A = inst.A
									local B = inst.B
									local params

									if B == 0 then
										params = top_index - A
									else
										params = B - 1
									end

									close_lua_upvalues(open_list, 0)

									return memory[A](table.unpack(memory, A + 1, A + params))
								else
									--[[SETTABLE]]
									local index, value

									if inst.is_KB then
										index = inst.const_B
									else
										index = memory[inst.B]
									end

									if inst.is_KC then
										value = inst.const_C
									else
										value = memory[inst.C]
									end

									memory[inst.A][index] = value
								end
							elseif op > 16 then
								--[[NEWTABLE]]
								memory[inst.A] = {}
							else
								--[[DIV]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs / rhs
							end
						else
							--[[LOADK]]
							memory[inst.A] = inst.const
						end
					else
						--[[FORLOOP]]
						local A = inst.A
						local step = memory[A + 2]
						local index = memory[A] + step
						local limit = memory[A + 1]
						local loops

						if step == math.abs(step) then
							loops = index <= limit
						else
							loops = index >= limit
						end

						if loops then
							memory[A] = index
							memory[A + 3] = index
							pc = pc + inst.sBx
						end
					end
				elseif op > 18 then
					if op < 28 then
						if op < 23 then
							if op < 20 then
								--[[LEN]]
								memory[inst.A] = #memory[inst.B]
							elseif op > 20 then
								if op < 22 then
									--[[RETURN]]
									local A = inst.A
									local B = inst.B
									local len

									if B == 0 then
										len = top_index - A + 1
									else
										len = B - 1
									end

									close_lua_upvalues(open_list, 0)

									return table.unpack(memory, A, A + len - 1)
								else
									--[[CONCAT]]
									local B = inst.B
									local str = memory[B]

									for i = B + 1, inst.C do str = str .. memory[i] end

									memory[inst.A] = str
								end
							else
								--[[MOD]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs % rhs
							end
						elseif op > 23 then
							if op < 26 then
								if op > 24 then
									--[[CLOSE]]
									close_lua_upvalues(open_list, inst.A)
								else
									--[[EQ]]
									local lhs, rhs

									if inst.is_KB then
										lhs = inst.const_B
									else
										lhs = memory[inst.B]
									end

									if inst.is_KC then
										rhs = inst.const_C
									else
										rhs = memory[inst.C]
									end

									if (lhs == rhs) == (inst.A ~= 0) then pc = pc + code[pc].sBx end

									pc = pc + 1
								end
							elseif op > 26 then
								--[[LT]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								if (lhs < rhs) == (inst.A ~= 0) then pc = pc + code[pc].sBx end

								pc = pc + 1
							else
								--[[POW]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								memory[inst.A] = lhs ^ rhs
							end
						else
							--[[LOADBOOL]]
							memory[inst.A] = inst.B ~= 0

							if inst.C ~= 0 then pc = pc + 1 end
						end
					elseif op > 28 then
						if op < 33 then
							if op < 30 then
								--[[LE]]
								local lhs, rhs

								if inst.is_KB then
									lhs = inst.const_B
								else
									lhs = memory[inst.B]
								end

								if inst.is_KC then
									rhs = inst.const_C
								else
									rhs = memory[inst.C]
								end

								if (lhs <= rhs) == (inst.A ~= 0) then pc = pc + code[pc].sBx end

								pc = pc + 1
							elseif op > 30 then
								if op < 32 then
									--[[CLOSURE]]
									local sub = subs[inst.Bx + 1] -- offset for 1 based index
									local nups = sub.num_upval
									local uvlist

									if nups ~= 0 then
										uvlist = {}

										for i = 1, nups do
											local pseudo = code[pc + i - 1]

											if pseudo.op == OPCODE_RM[0] then -- @MOVE
												uvlist[i - 1] = open_lua_upvalue(open_list, pseudo.B, memory)
											elseif pseudo.op == OPCODE_RM[4] then -- @GETUPVAL
												uvlist[i - 1] = upvals[pseudo.B]
											end
										end

										pc = pc + nups
									end

									memory[inst.A] = lua_wrap_state(sub, env, uvlist)
								else
									--[[TESTSET]]
									local A = inst.A
									local B = inst.B

									if (not memory[B]) ~= (inst.C ~= 0) then
										memory[A] = memory[B]
										pc = pc + code[pc].sBx
									end
									pc = pc + 1
								end
							else
								--[[UNM]]
								memory[inst.A] = -memory[inst.B]
							end
						elseif op > 33 then
							if op < 36 then
								if op > 34 then
									--[[VARARG]]
									local A = inst.A
									local len = inst.B

									if len == 0 then
										len = vararg.len
										top_index = A + len - 1
									end

									table.move(vararg.list, 1, len, A, memory)
								else
									--[[FORPREP]]
									local A = inst.A
									local init, limit, step

									init = assert(tonumber(memory[A]), '`for` initial value must be a number')
									limit = assert(tonumber(memory[A + 1]), '`for` limit must be a number')
									step = assert(tonumber(memory[A + 2]), '`for` step must be a number')

									memory[A] = init - step
									memory[A + 1] = limit
									memory[A + 2] = step

									pc = pc + inst.sBx
								end
							elseif op > 36 then
								--[[SETLIST]]
								local A = inst.A
								local C = inst.C
								local len = inst.B
								local tab = memory[A]
								local offset

								if len == 0 then len = top_index - A end

								if C == 0 then
									C = inst[pc].value
									pc = pc + 1
								end

								offset = (C - 1) * FIELDS_PER_FLUSH

								table.move(memory, A + 1, A + len, offset + 1, tab)
							else
								--[[NOT]]
								memory[inst.A] = not memory[inst.B]
							end
						else
							--[[TEST]]
							if (not memory[inst.A]) ~= (inst.C ~= 0) then pc = pc + code[pc].sBx end
							pc = pc + 1
						end
					else
						--[[TFORLOOP]]
						local A = inst.A
						local base = A + 3

						local vals = {memory[A](memory[A + 1], memory[A + 2])}

						table.move(vals, 1, inst.C, base, memory)

						if memory[base] ~= nil then
							memory[A + 2] = memory[base]
							pc = pc + code[pc].sBx
						end

						pc = pc + 1
					end
				else
					--[[JMP]]
					pc = pc + inst.sBx
				end

				state.pc = pc
			end
		end

		function lua_wrap_state(proto, env, upval)
			local function wrapped(...)
				local passed = table.pack(...)
				local memory = table.create(proto.max_stack)
				local vararg = {len = 0, list = {}}

				table.move(passed, 1, proto.num_param, 0, memory)

				if proto.num_param < passed.n then
					local start = proto.num_param + 1
					local len = passed.n - proto.num_param

					vararg.len = len
					table.move(passed, start, start + len - 1, 1, vararg.list)
				end

				local state = {vararg = vararg, memory = memory, code = proto.code, subs = proto.subs, pc = 1}

				local result = table.pack(pcall(run_lua_func, state, env, upval))

				if result[1] then
					return table.unpack(result, 2, result.n)
				else
					local failed = {pc = state.pc, source = proto.source, lines = proto.lines}

					on_lua_error(failed, result[2])

					return
				end
			end

			return wrapped
		end

		return function(bCode, env)
			return lua_wrap_state(lua_bc_to_state(bCode), env or getfenv(0))
		end
	end)()
	--getfenv().script = nil

	return function(source, env)
		local executable
		local env = env or getfenv(2)
		local ran, failureReason = pcall(function()
			local compiledBytecode = compile(source,  "shg340934qh")
			executable = createExecutable(compiledBytecode, env)
		end)

		if ran then
			return setfenv(executable, env)
		end
		return nil, failureReason
	end
end)()

local utils = {}

utils.string_to_hex = function(value, offset, seperator)
	offset = offset or 227
	seperator = seperator or ""

	return string.gsub(value, ".", function(char)
		return string.format("%02X", string.byte(char) * offset) .. seperator
	end)
end

utils.hex_to_string = function(value, offset)
	offset = offset or 1

	return string.gsub(value, "..", function(char)
		return tonumber(char, 16):: number / 1
	end)
end

local INTgetloadedmodules = function() --make NO reference in env or they can get a unwrapped version of shit
	local tab = table.create(0)
	for i, v in pairs(game:GetDescendants()) do
		if v.ClassName == "ModuleScript" then
			table.insert(tab,v)
		end
	end
	return tab
end

utils.fetch_modules = INTgetloadedmodules

utils.base64_encode = function(data)
	local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	return ((data:gsub('.', function(x) 
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return letters:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end
utils.base64_decode = function(data)
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if x == '=' then return '' end
		local r, f = '', (b:find(x) - 1)
		for i = 6, 1, -1 do
			r = r .. (f % 2^i - f % 2^(i - 1) > 0 and '1' or '0')
		end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if #x ~= 8 then return '' end
		local c = 0
		for i = 1, 8 do
			c = c + (x:sub(i, i) == '1' and 2^(8 - i) or 0)
		end
		return string.char(c)
	end))
end

local lz4 = {}

type Streamer = {
	Offset: number,
	Source: string,
	Length: number,
	IsFinished: boolean,
	LastUnreadBytes: number,

	read: (Streamer, len: number?, shiftOffset: boolean?) -> string,
	seek: (Streamer, len: number) -> (),
	append: (Streamer, newData: string) -> (),
	toEnd: (Streamer) -> ()
}

type BlockData = {
	[number]: {
		Literal: string,
		LiteralLength: number,
		MatchOffset: number?,
		MatchLength: number?
	}
}

local function plainFind(str, pat)
	return string.find(str, pat, 0, true)
end

local function streamer(str): Streamer
	local Stream = {}
	Stream.Offset = 0
	Stream.Source = str
	Stream.Length = string.len(str)
	Stream.IsFinished = false	
	Stream.LastUnreadBytes = 0

	function Stream.read(self: Streamer, len: number?, shift: boolean?): string
		local len = len or 1
		local shift = if shift ~= nil then shift else true
		local dat = string.sub(self.Source, self.Offset + 1, self.Offset + len)

		local dataLength = string.len(dat)
		local unreadBytes = len - dataLength

		if shift then
			self:seek(len)
		end

		self.LastUnreadBytes = unreadBytes
		return dat
	end

	function Stream.seek(self: Streamer, len: number)
		local len = len or 1

		self.Offset = math.clamp(self.Offset + len, 0, self.Length)
		self.IsFinished = self.Offset >= self.Length
	end

	function Stream.append(self: Streamer, newData: string)
		-- adds new data to the end of a stream
		self.Source ..= newData
		self.Length = string.len(self.Source)
		self:seek(0) --hacky but forces a recalculation of the isFinished flag
	end

	function Stream.toEnd(self: Streamer)
		self:seek(self.Length)
	end

	return Stream
end

function lz4.compress(str: string): string
	local blocks: BlockData = {}
	local iostream = streamer(str)

	if iostream.Length > 12 then
		local firstFour = iostream:read(4)

		local processed = firstFour
		local lit = firstFour
		local match = ""
		local LiteralPushValue = ""
		local pushToLiteral = true

		repeat
			pushToLiteral = true
			local nextByte = iostream:read()

			if plainFind(processed, nextByte) then
				local next3 = iostream:read(3, false)

				if string.len(next3) < 3 then
					--push bytes to literal block then break
					LiteralPushValue = nextByte .. next3
					iostream:seek(3)
				else
					match = nextByte .. next3

					local matchPos = plainFind(processed, match)
					if matchPos then
						iostream:seek(3)
						repeat
							local nextMatchByte = iostream:read(1, false)
							local newResult = match .. nextMatchByte

							local repos = plainFind(processed, newResult) 
							if repos then
								match = newResult
								matchPos = repos
								iostream:seek(1)
							end
						until not plainFind(processed, newResult) or iostream.IsFinished

						local matchLen = string.len(match)
						local pushMatch = true

						if iostream.Length - iostream.Offset <= 5 then
							LiteralPushValue = match
							pushMatch = false
							--better safe here, dont bother pushing to match ever
						end

						if pushMatch then
							pushToLiteral = false

							-- gets the position from the end of processed, then slaps it onto processed
							local realPosition = string.len(processed) - matchPos
							processed = processed .. match

							table.insert(blocks, {
								Literal = lit,
								LiteralLength = string.len(lit),
								MatchOffset = realPosition + 1,
								MatchLength = matchLen,
							})
							lit = ""
						end
					else
						LiteralPushValue = nextByte
					end
				end
			else
				LiteralPushValue = nextByte
			end

			if pushToLiteral then
				lit = lit .. LiteralPushValue
				processed = processed .. nextByte
			end
		until iostream.IsFinished
		table.insert(blocks, {
			Literal = lit,
			LiteralLength = string.len(lit)
		})
	else
		local str = iostream.Source
		blocks[1] = {
			Literal = str,
			LiteralLength = string.len(str)
		}
	end

	-- generate the output chunk
	-- %s is for adding header
	local output = string.rep("\x00", 4)
	local function write(char)
		output = output .. char
	end
	-- begin working through chunks
	for chunkNum, chunk in blocks do
		local litLen = chunk.LiteralLength
		local matLen = (chunk.MatchLength or 4) - 4

		-- create token
		local tokenLit = math.clamp(litLen, 0, 15)
		local tokenMat = math.clamp(matLen, 0, 15)

		local token = bit32.lshift(tokenLit, 4) + tokenMat
		write(string.pack("<I1", token))

		if litLen >= 15 then
			litLen = litLen - 15
			--begin packing extra bytes
			repeat
				local nextToken = math.clamp(litLen, 0, 0xFF)
				write(string.pack("<I1", nextToken))
				if nextToken == 0xFF then
					litLen = litLen - 255
				end
			until nextToken < 0xFF
		end

		-- push raw lit data
		write(chunk.Literal)

		if chunkNum ~= #blocks then
			-- push offset as u16
			write(string.pack("<I2", chunk.MatchOffset))

			-- pack extra match bytes
			if matLen >= 15 then
				matLen = matLen - 15

				repeat
					local nextToken = math.clamp(matLen, 0, 0xFF)
					write(string.pack("<I1", nextToken))
					if nextToken == 0xFF then
						matLen = matLen - 255
					end
				until nextToken < 0xFF
			end
		end
	end
	--append chunks
	local compLen = string.len(output) - 4
	local decompLen = iostream.Length

	return string.pack("<I4", compLen) .. string.pack("<I4", decompLen) .. output
end

function lz4.decompress(lz4data: string): string
	local inputStream = streamer(lz4data)

	local compressedLen = string.unpack("<I4", inputStream:read(4))
	local decompressedLen = string.unpack("<I4", inputStream:read(4))
	local reserved = string.unpack("<I4", inputStream:read(4))

	if compressedLen == 0 then
		return inputStream:read(decompressedLen)
	end

	local outputStream = streamer("")

	repeat
		local token = string.byte(inputStream:read())
		local litLen = bit32.rshift(token, 4)
		local matLen = bit32.band(token, 15) + 4

		if litLen >= 15 then
			repeat
				local nextByte = string.byte(inputStream:read())
				litLen += nextByte
			until nextByte ~= 0xFF
		end

		local literal = inputStream:read(litLen)
		outputStream:append(literal)
		outputStream:toEnd()
		if outputStream.Length < decompressedLen then
			--match
			local offset = string.unpack("<I2", inputStream:read(2))
			if matLen >= 19 then
				repeat
					local nextByte = string.byte(inputStream:read())
					matLen += nextByte
				until nextByte ~= 0xFF
			end

			outputStream:seek(-offset)
			local pos = outputStream.Offset
			local match = outputStream:read(matLen)
			local unreadBytes = outputStream.LastUnreadBytes
			local extra
			if unreadBytes then
				repeat
					outputStream.Offset = pos
					extra = outputStream:read(unreadBytes)
					unreadBytes = outputStream.LastUnreadBytes
					match ..= extra
				until unreadBytes <= 0
			end

			outputStream:append(match)
			outputStream:toEnd()
		end

	until outputStream.Length >= decompressedLen

	return outputStream.Source
end


-- BRIDGE

local bridge = {}

bridge.validActions = {
	["load_source"] = {"string", "string"},
	["setclipboard"] = {},
	["writefile"] = {},
	["readfile"] = {},
	["input_action"] = {},
	["makefolder"] = {},
	["HttpGet"] = {},
	["get_script"] = {},
	["isfolder"] = {},
} -- go to loadstring to change it


function bridge:send(action, ...) 
	local args = {...}
	local success, res = pcall(function()

		if not self.validActions[action] then
			warn("[ DEBUG ] Bridge.send -> cancelled")
			return
		end

		local url = "http://localhost:8000/bridge?action=" .. action
		for i, arg in ipairs(args) do
			url = url .. "&arg" .. i .. "=" .. HttpService:UrlEncode(tostring(arg))
		end
		local params = {
			Url = url,
			Method = "GET",
			Headers = {
				["Content-Type"] = "application/json"
			}
		}
		local request = HttpService:RequestInternal(params)
		local response = nil
		local requestCompletedEvent = Instance.new("BindableEvent")
		request:Start(function(success, result)
			response = result
			requestCompletedEvent:Fire()
		end)
		requestCompletedEvent.Event:Wait()

		if response.StatusMessage == "OK" then 
			return HttpService:JSONDecode(response.Body) 
		end
	end)
	if not success then
		warn("[ ERROR ] -> "..tostring(res))
	else
		return res
	end
end

local old = load

local val_the_sigma = function(code)
	local module = utils.fetch_modules()[1]:Clone()
	module.Source = "return function(...) " .. code .. " end"
	local func = require(module)
	func = setfenv(func, getfenv())
	return func
end

-- ENVIROMENT

local function get_buildins()
	return {
		-- Luau Functions
		["assert"] = "function",
		["error"] = "function",
		["getfenv"] = "function",
		["getmetatable"] = "function",
		["ipairs"] = "function",
		["loadstring"] = "function",
		["newproxy"] = "function",
		["next"] = "function",
		["pairs"] = "function",
		["pcall"] = "function",
		["print"] = "function",
		["rawequal"] = "function",
		["rawget"] = "function",
		["rawlen"] = "function",
		["rawset"] = "function",
		["select"] = "function",
		["setfenv"] = "function",
		["setmetatable"] = "function",
		["tonumber"] = "function",
		["tostring"] = "function",
		["unpack"] = "function",
		["xpcall"] = "function",
		["type"] = "function",
		["typeof"] = "function",

		-- Luau Functions (Deprecated)
		["collectgarbage"] = "function",

		-- Luau Variables
		["_G"] = "table",
		["_VERSION"] = "string",

		-- Luau Tables
		["bit32"] = "table",
		["coroutine"] = "table",
		["debug"] = "table",
		["math"] = "table",
		["os"] = "table",
		["string"] = "table",
		["table"] = "table",
		["utf8"] = "table",
		["buffer"] = "table",

		-- Roblox Functions
		["DebuggerManager"] = "function",
		["delay"] = "function",
		["gcinfo"] = "function",
		["PluginManager"] = "function",
		["require"] = "function",
		["settings"] = "function",
		["spawn"] = "function",
		["tick"] = "function",
		["time"] = "function",
		["UserSettings"] = "function",
		["wait"] = "function",
		["warn"] = "function",

		-- Roblox Functions (Deprecated)
		["Delay"] = "function",
		["ElapsedTime"] = "function",
		["elapsedTime"] = "function",
		["printidentity"] = "function",
		["Spawn"] = "function",
		["Stats"] = "function",
		["stats"] = "function",
		["Version"] = "function",
		["version"] = "function",
		["Wait"] = "function",
		["ypcall"] = "function",

		-- Roblox Variables
		["game"] = "Instance",
		["plugin"] = "Instance",
		["shared"] = "table",
		["workspace"] = "Instance",

		-- Roblox Variables (Deprecated)
		["Game"] = "Instance",
		["Workspace"] = "Instance",

		-- Roblox Tables
		["Axes"] = "table",
		["BrickColor"] = "table",
		["CatalogSearchParams"] = "table",
		["CFrame"] = "table",
		["Color3"] = "table",
		["ColorSequence"] = "table",
		["ColorSequenceKeypoint"] = "table",
		["DateTime"] = "table",
		["DockWidgetPluginGuiInfo"] = "table",
		["Enum"] = "Enums",
		["Faces"] = "table",
		["FloatCurveKey"] = "table",
		["Font"] = "table",
		["Instance"] = "table",
		["NumberRange"] = "table",
		["NumberSequence"] = "table",
		["NumberSequenceKeypoint"] = "table",
		["OverlapParams"] = "table",
		["PathWaypoint"] = "table",
		["PhysicalProperties"] = "table",
		["Random"] = "table",
		["Ray"] = "table",
		["RaycastParams"] = "table",
		["Rect"] = "table",
		["Region3"] = "table",
		["Region3int16"] = "table",
		["RotationCurveKey"] = "table",
		["SharedTable"] = "table",
		["task"] = "table",
		["TweenInfo"] = "table",
		["UDim"] = "table",
		["UDim2"] = "table",
		["Vector2"] = "table",
		["Vector2int16"] = "table",
		["Vector3"] = "table",
		["Vector3int16"] = "table",
	}
end

local function _apply_env(func, env)
	setfenv(0, env)
	setfenv(1, env)

	return setfenv(func, env)
end

local sandbox = {
	environment = nil,
	hidden_env = nil,
	blacklisted_extensions = {
		".exe", ".bat", ".com", ".cmd", ".inf", ".ipa",
		".apk", ".apkm", ".osx", ".pif", ".run", ".wsh",
		".bin", ".app", ".vb", ".vbs", ".scr", ".fap",
		".cpl", ".inf1", ".ins", ".inx", ".isu", ".job",
		".lnk", ".msi", ".ps1", ".reg", ".vbe", ".js",
		".x86", ".xlm", ".scpt", ".out", ".ba_", ".jar",
		".ahk", ".xbe", ".0xe", ".u3p", ".bms", ".jse",
		".ex", ".rar", ".zip", ".7z", ".py", ".cpp",
		".cs", ".prx", ".tar", ".", ".wim", ".htm",
		".html", ".css", ".appimage", ".applescript",
		".x86_64", ".x64_64", ".autorun", ".tmp", ".sys",
		".dat", ".ini", ".pol", ".vbscript", ".gadget",
		".workflow", ".script", ".action", ".command",
		".arscript", ".psc1",
	}
}

local main_script = script
local setfenv = setfenv

function sandbox:apply<T>(func: T): T
	local new_env = self:new_environment(Instance.new("LocalScript"))
	local _success, result = coroutine.resume(coroutine.create(_apply_env), func, new_env)

	return result
end

function sandbox:new_environment(script: LuaSourceContainer): { [any]: any }
	local plugin_env = {}
	local sandboxed_env = setmetatable({
		script = script,
	}, {
		__index = function(env, index)
			return plugin_env[index] or self.hidden_env[index] or self.environment.global[index]
		end,
		__newindex = function(env, index, value)
			if index ~= "script" then
				rawset(self.environment.global, index, value)
			end
			rawset(env, index, value)
		end,
	})

	plugin_env.getfenv = function(value)
		local success, result = pcall(getfenv, value)

		if success then
			if rawget(result, "script") == main_script then
				result = sandboxed_env
			end
			return result
		end
		return error(result, 2)
	end

	return sandboxed_env
end

local function initialize_env_modules()
	local roblox_env = get_buildins() -- do not write on this
	local new_env = setmetatable({}, {
		__index = roblox_env,
	})

	-- init
	for index, value in new_env do
		if type(value) ~= "table" or table.isfrozen(value) then
			continue
		end
		table.freeze(value)
	end

	return {
		global = new_env,
		roblox = roblox_env,
	}
end

function sandbox:initialize()
	local hidden_env = {
		game = newproxy(true),
	}
	local environment = initialize_env_modules()

	local _game_meta = getmetatable(hidden_env.game)
	_game_meta.__index = function(self, index)
		local _, game_index = pcall(function()
			return game[index]
		end)

		if game_index and type(game_index) == "function" then
			return function(self, ...)
				return game_index(game, ...)
			end
		else
			--TODO Add automatic .GetService
			return game[index]
		end
	end
	_game_meta.__metatable = getmetatable(game)

	local cloned_environment

	environment.global._G = {}
	environment.global.shared = {}
	environment.global.crypt = {
		base64 = {},
		hex = {}, 
		url = {},
	}
	environment.global.cache = {}
	environment.global.http = {}
	environment.global.base64 = {}
	environment.global.debug = table.clone(debug)

	--drawing lib from sweet ol jalon here later (im NOT fucking coding my own drawing lib that sounds like hell)
	-- Made by jLn0n

	-- services
	local coreGui = game:GetService("CoreGui")
	-- objects
	local camera = game.Workspace.CurrentCamera
	local drawingUI = Instance.new("ScreenGui")
	drawingUI.Name = "Drawing"
	drawingUI.IgnoreGuiInset = true
	drawingUI.DisplayOrder = 0x7fffffff
	drawingUI.Parent = coreGui
	-- variables
	local drawingIndex = 0
	local uiStrokes = table.create(0)
	local baseDrawingObj = setmetatable({
		Visible = true,
		ZIndex = 0,
		Transparency = 1,
		Color = Color3.new(),
		Remove = function(self)
			setmetatable(self, nil)
		end
	}, {
		__add = function(t1, t2)
			local result = table.clone(t1)

			for index, value in t2 do
				result[index] = value
			end
			return result
		end
	})
	local drawingFontsEnum = {
		[0] = Font.fromEnum(Enum.Font.Roboto),
		[1] = Font.fromEnum(Enum.Font.Legacy),
		[2] = Font.fromEnum(Enum.Font.SourceSans),
		[3] = Font.fromEnum(Enum.Font.RobotoMono),
	}
	-- function
	local function getFontFromIndex(fontIndex: number): Font
		return drawingFontsEnum[fontIndex]
	end

	local function convertTransparency(transparency: number): number
		return math.clamp(1 - transparency, 0, 1)
	end
	-- main
	local DrawingLib = {}
	DrawingLib.Fonts = {
		["UI"] = 0,
		["System"] = 1,
		["Plex"] = 2,
		["Monospace"] = 3
	}
	local drawings = {}
	function DrawingLib.new(drawingType)
		drawingIndex += 1
		if drawingType == "Line" then
			local lineObj = ({
				From = Vector2.zero,
				To = Vector2.zero,
				Thickness = 1
			} + baseDrawingObj)

			local lineFrame = Instance.new("Frame")
			lineFrame.Name = drawingIndex
			lineFrame.AnchorPoint = (Vector2.one * .5)
			lineFrame.BorderSizePixel = 0

			lineFrame.BackgroundColor3 = lineObj.Color
			lineFrame.Visible = lineObj.Visible
			lineFrame.ZIndex = lineObj.ZIndex
			lineFrame.BackgroundTransparency = convertTransparency(lineObj.Transparency)

			lineFrame.Size = UDim2.new()

			lineFrame.Parent = drawingUI
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(lineObj[index]) == "nil" then return end

					if index == "From" then
						local direction = (lineObj.To - value)
						local center = (lineObj.To + value) / 2
						local distance = direction.Magnitude
						local theta = math.deg(math.atan2(direction.Y, direction.X))

						lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
						lineFrame.Rotation = theta
						lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
					elseif index == "To" then
						local direction = (value - lineObj.From)
						local center = (value + lineObj.From) / 2
						local distance = direction.Magnitude
						local theta = math.deg(math.atan2(direction.Y, direction.X))

						lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
						lineFrame.Rotation = theta
						lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
					elseif index == "Thickness" then
						local distance = (lineObj.To - lineObj.From).Magnitude

						lineFrame.Size = UDim2.fromOffset(distance, value)
					elseif index == "Visible" then
						lineFrame.Visible = value
					elseif index == "ZIndex" then
						lineFrame.ZIndex = value
					elseif index == "Transparency" then
						lineFrame.BackgroundTransparency = convertTransparency(value)
					elseif index == "Color" then
						lineFrame.BackgroundColor3 = value
					end
					lineObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							lineFrame:Destroy()
							lineObj.Remove(self)
							return lineObj:Remove()
						end
					end
					return lineObj[index]
				end
			})
		elseif drawingType == "Text" then
			local textObj = ({
				Text = "",
				Font = DrawingLib.Fonts.UI,
				Size = 0,
				Position = Vector2.zero,
				Center = false,
				Outline = false,
				OutlineColor = Color3.new()
			} + baseDrawingObj)

			local textLabel, uiStroke = Instance.new("TextLabel"), Instance.new("UIStroke")
			textLabel.Name = drawingIndex
			textLabel.AnchorPoint = (Vector2.one * .5)
			textLabel.BorderSizePixel = 0
			textLabel.BackgroundTransparency = 1

			textLabel.Visible = textObj.Visible
			textLabel.TextColor3 = textObj.Color
			textLabel.TextTransparency = convertTransparency(textObj.Transparency)
			textLabel.ZIndex = textObj.ZIndex

			textLabel.FontFace = getFontFromIndex(textObj.Font)
			textLabel.TextSize = textObj.Size

			textLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
				local textBounds = textLabel.TextBounds
				local offset = textBounds / 2

				textLabel.Size = UDim2.fromOffset(textBounds.X, textBounds.Y)
				textLabel.Position = UDim2.fromOffset(textObj.Position.X + (if not textObj.Center then offset.X else 0), textObj.Position.Y + offset.Y)
			end)

			uiStroke.Thickness = 1
			uiStroke.Enabled = textObj.Outline
			uiStroke.Color = textObj.Color

			textLabel.Parent, uiStroke.Parent = drawingUI, textLabel
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(textObj[index]) == "nil" then return end

					if index == "Text" then
						textLabel.Text = value
					elseif index == "Font" then
						value = math.clamp(value, 0, 3)
						textLabel.FontFace = getFontFromIndex(value)
					elseif index == "Size" then
						textLabel.TextSize = value
					elseif index == "Position" then
						local offset = textLabel.TextBounds / 2

						textLabel.Position = UDim2.fromOffset(value.X + (if not textObj.Center then offset.X else 0), value.Y + offset.Y)
					elseif index == "Center" then
						local position = (
							if value then
								camera.ViewportSize / 2
								else
								textObj.Position
						)

						textLabel.Position = UDim2.fromOffset(position.X, position.Y)
					elseif index == "Outline" then
						uiStroke.Enabled = value
					elseif index == "OutlineColor" then
						uiStroke.Color = value
					elseif index == "Visible" then
						textLabel.Visible = value
					elseif index == "ZIndex" then
						textLabel.ZIndex = value
					elseif index == "Transparency" then
						local transparency = convertTransparency(value)

						textLabel.TextTransparency = transparency
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						textLabel.TextColor3 = value
					end
					textObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							textLabel:Destroy()
							textObj.Remove(self)
							return textObj:Remove()
						end
					elseif index == "TextBounds" then
						return textLabel.TextBounds
					end
					return textObj[index]
				end
			})
		elseif drawingType == "Circle" then
			local circleObj = ({
				Radius = 150,
				Position = Vector2.zero,
				Thickness = .7,
				Filled = false
			} + baseDrawingObj)

			local circleFrame, uiCorner, uiStroke = Instance.new("Frame"), Instance.new("UICorner"), Instance.new("UIStroke")
			circleFrame.Name = drawingIndex
			circleFrame.AnchorPoint = (Vector2.one * .5)
			circleFrame.BorderSizePixel = 0

			circleFrame.BackgroundTransparency = (if circleObj.Filled then convertTransparency(circleObj.Transparency) else 1)
			circleFrame.BackgroundColor3 = circleObj.Color
			circleFrame.Visible = circleObj.Visible
			circleFrame.ZIndex = circleObj.ZIndex

			uiCorner.CornerRadius = UDim.new(1, 0)
			circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)

			uiStroke.Thickness = circleObj.Thickness
			uiStroke.Enabled = not circleObj.Filled
			uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			circleFrame.Parent, uiCorner.Parent, uiStroke.Parent = drawingUI, circleFrame, circleFrame
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(circleObj[index]) == "nil" then return end

					if index == "Radius" then
						local radius = value * 2
						circleFrame.Size = UDim2.fromOffset(radius, radius)
					elseif index == "Position" then
						circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Thickness" then
						value = math.clamp(value, .6, 0x7fffffff)
						uiStroke.Thickness = value
					elseif index == "Filled" then
						circleFrame.BackgroundTransparency = (if value then convertTransparency(circleObj.Transparency) else 1)
						uiStroke.Enabled = not value
					elseif index == "Visible" then
						circleFrame.Visible = value
					elseif index == "ZIndex" then
						circleFrame.ZIndex = value
					elseif index == "Transparency" then
						local transparency = convertTransparency(value)

						circleFrame.BackgroundTransparency = (if circleObj.Filled then transparency else 1)
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						circleFrame.BackgroundColor3 = value
						uiStroke.Color = value
					end
					circleObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							circleFrame:Destroy()
							circleObj.Remove(self)
							return circleObj:Remove()
						end
					end
					return circleObj[index]
				end
			})
		elseif drawingType == "Square" then
			local squareObj = ({
				Size = Vector2.zero,
				Position = Vector2.zero,
				Thickness = .7,
				Filled = false
			} + baseDrawingObj)

			local squareFrame, uiStroke = Instance.new("Frame"), Instance.new("UIStroke")
			squareFrame.Name = drawingIndex
			squareFrame.BorderSizePixel = 0

			squareFrame.BackgroundTransparency = (if squareObj.Filled then convertTransparency(squareObj.Transparency) else 1)
			squareFrame.ZIndex = squareObj.ZIndex
			squareFrame.BackgroundColor3 = squareObj.Color
			squareFrame.Visible = squareObj.Visible

			uiStroke.Thickness = squareObj.Thickness
			uiStroke.Enabled = not squareObj.Filled
			uiStroke.LineJoinMode = Enum.LineJoinMode.Miter

			squareFrame.Parent, uiStroke.Parent = drawingUI, squareFrame
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(squareObj[index]) == "nil" then return end

					if index == "Size" then
						squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Position" then
						squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Thickness" then
						value = math.clamp(value, 0.6, 0x7fffffff)
						uiStroke.Thickness = value
					elseif index == "Filled" then
						squareFrame.BackgroundTransparency = (if value then convertTransparency(squareObj.Transparency) else 1)
						uiStroke.Enabled = not value
					elseif index == "Visible" then
						squareFrame.Visible = value
					elseif index == "ZIndex" then
						squareFrame.ZIndex = value
					elseif index == "Transparency" then
						local transparency = convertTransparency(value)

						squareFrame.BackgroundTransparency = (if squareObj.Filled then transparency else 1)
						uiStroke.Transparency = transparency
					elseif index == "Color" then
						uiStroke.Color = value
						squareFrame.BackgroundColor3 = value
					end
					squareObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							squareFrame:Destroy()
							squareObj.Remove(self)
							return squareObj:Remove()
						end
					end
					return squareObj[index]
				end
			})
		elseif drawingType == "Image" then
			local imageObj = ({
				Data = "",
				DataURL = "rbxassetid://0",
				Size = Vector2.zero,
				Position = Vector2.zero
			} + baseDrawingObj)

			local imageFrame = Instance.new("ImageLabel")
			imageFrame.Name = drawingIndex
			imageFrame.BorderSizePixel = 0
			imageFrame.ScaleType = Enum.ScaleType.Stretch
			imageFrame.BackgroundTransparency = 1

			imageFrame.Visible = imageObj.Visible
			imageFrame.ZIndex = imageObj.ZIndex
			imageFrame.ImageTransparency = convertTransparency(imageObj.Transparency)
			imageFrame.ImageColor3 = imageObj.Color

			imageFrame.Parent = drawingUI
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(imageObj[index]) == "nil" then return end

					if index == "Data" then
						-- later
					elseif index == "DataURL" then -- temporary property
						imageFrame.Image = value
					elseif index == "Size" then
						imageFrame.Size = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Position" then
						imageFrame.Position = UDim2.fromOffset(value.X, value.Y)
					elseif index == "Visible" then
						imageFrame.Visible = value
					elseif index == "ZIndex" then
						imageFrame.ZIndex = value
					elseif index == "Transparency" then
						imageFrame.ImageTransparency = convertTransparency(value)
					elseif index == "Color" then
						imageFrame.ImageColor3 = value
					end
					imageObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" or index == "Destroy" then
						return function()
							imageFrame:Destroy()
							imageObj.Remove(self)
							return imageObj:Remove()
						end
					elseif index == "Data" then
						return nil -- TODO: add error here
					end
					return imageObj[index]
				end
			})
		elseif drawingType == "Quad" then
			local quadObj = ({
				PointA = Vector2.zero,
				PointB = Vector2.zero,
				PointC = Vector2.zero,
				PointD = Vector3.zero,
				Thickness = 1,
				Filled = false
			} + baseDrawingObj)

			local _linePoints = table.create(0)
			_linePoints.A = DrawingLib.new("Line")
			_linePoints.B = DrawingLib.new("Line")
			_linePoints.C = DrawingLib.new("Line")
			_linePoints.D = DrawingLib.new("Line")
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(quadObj[index]) == "nil" then return end

					if index == "PointA" then
						_linePoints.A.From = value
						_linePoints.B.To = value
					elseif index == "PointB" then
						_linePoints.B.From = value
						_linePoints.C.To = value
					elseif index == "PointC" then
						_linePoints.C.From = value
						_linePoints.D.To = value
					elseif index == "PointD" then
						_linePoints.D.From = value
						_linePoints.A.To = value
					elseif (index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex") then
						for _, linePoint in _linePoints do
							linePoint[index] = value
						end
					elseif index == "Filled" then
						-- later
					end
					quadObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							quadObj.Remove(self)
							return quadObj:Remove()
						end
					end
					if index == "Destroy" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							quadObj.Remove(self)
							return quadObj:Remove()
						end
					end
					return quadObj[index]
				end
			})
		elseif drawingType == "Triangle" then
			local triangleObj = ({
				PointA = Vector2.zero,
				PointB = Vector2.zero,
				PointC = Vector2.zero,
				Thickness = 1,
				Filled = false
			} + baseDrawingObj)

			local _linePoints = table.create(0)
			_linePoints.A = DrawingLib.new("Line")
			_linePoints.B = DrawingLib.new("Line")
			_linePoints.C = DrawingLib.new("Line")
			local bs = table.create(0)
			table.insert(drawings,bs)
			return setmetatable(bs, {
				__newindex = function(_, index, value)
					if typeof(triangleObj[index]) == "nil" then return end

					if index == "PointA" then
						_linePoints.A.From = value
						_linePoints.B.To = value
					elseif index == "PointB" then
						_linePoints.B.From = value
						_linePoints.C.To = value
					elseif index == "PointC" then
						_linePoints.C.From = value
						_linePoints.A.To = value
					elseif (index == "Thickness" or index == "Visible" or index == "Color" or index == "ZIndex") then
						for _, linePoint in _linePoints do
							linePoint[index] = value
						end
					elseif index == "Filled" then
						-- later
					end
					triangleObj[index] = value
				end,
				__index = function(self, index)
					if index == "Remove" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							triangleObj.Remove(self)
							return triangleObj:Remove()
						end
					end
					if index == "Destroy" then
						return function()
							for _, linePoint in _linePoints do
								linePoint:Remove()
							end

							triangleObj.Remove(self)
							return triangleObj:Remove()
						end
					end
					return triangleObj[index]
				end
			})
		end
	end
	environment.global.Drawing = DrawingLib

	environment.global.getgenv = function()
		return cloned_environment.global
	end

	environment.global.getrenv = function()
		return environment.roblox
	end

	environment.global.crypt.base64encode = function(data)
		assert(data, "Missing #1 argument")
		assert(typeof(data) == "string", "Expected #1 argument to be string, got "..typeof(data).. " instead")

		local encoded = utils.base64_encode(data)

		return encoded
	end

	environment.global.crypt.base64decode = function(data)
		assert(data, "Missing #1 argument")
		assert(typeof(data) == "string", "Expected #1 argument to be string, got "..typeof(data).. " instead")

		local decoded = utils.base64_decode(data)

		return decoded
	end

	environment.global.crypt.base64.encode = environment.global.crypt.base64encode
	environment.global.crypt.base64_encode = environment.global.crypt.base64encode
	environment.global.base64.encode = environment.global.crypt.base64encode

	environment.global.crypt.base64.decode = environment.global.crypt.base64decode
	environment.global.crypt.base64_decode = environment.global.crypt.base64decode
	environment.global.base64.decode = environment.global.crypt.base64decode

	environment.global.isrenderobj = function(...)
		if table.find(drawings,...) then
			return true
		else
			return false
		end
	end

	environment.global.getrenderproperty = function(a,b)
		return a[b]
	end
	environment.global.setrenderproperty = function(a,b,c)
		a[b] = c
	end

	environment.global.cleardrawcache = function() -- idk there is no cache to clear
		return true
	end

	-- rconsole stuff

	environment.global.rconsolecreate = function()

	end

	environment.global.rconsoleclear = function()

	end

	environment.global.rconsoledestroy = function()

	end

	environment.global.rconsoleinput = function()

	end

	environment.global.rconsoleprint = function(arg1)
		print("[ CONSOLE ] "..tostring(arg1))
	end

	environment.global.rconsolesettitle = function()

	end

	environment.global.consoleclear = function()

	end
	environment.global.consolecreate = function()

	end

	environment.global.consoledestroy = function()

	end

	environment.global.consoleinput = function()

	end

	environment.global.consoleprint = environment.global.rconsoleprint

	environment.global.consolesettitle = environment.global.rconsolesettitle
	environment.global.rconsolename = environment.global.rconsolesettitle

	environment.global.getscripthash = function(script)
		local isValidType = nil;
		if typeof(script) == "Instance" then
			isValidType = script:IsA("Script") or script:IsA("LocalScript") or script:IsA("LuaSourceContainer")
		end
		assert(isValidType, "Expected a script, localscript, or LuaSourceContainer")
		return script:GetHash()
	end

	environment.global.base64_encode = environment.global.crypt.base64encode
	environment.global.base64_decode = environment.global.crypt.base64decode

	local fake_identity = 3;

	environment.global.identifyexecutor = function()
		return "PolicyService", "1.0"
	end

	environment.global.getexecutorname = environment.global.identifyexecutor

	environment.global.cloneref = function(reference)
		assert(reference, "Missing #1 argument")
		assert(typeof(reference) == "Instance", "Expected #1 argument to be Instance, got "..tostring(typeof(reference)).." instead")

		if game:FindFirstChild(reference.Name)  or reference.Parent == game then --  dont make it clone services
			return reference
		else
			local class = reference.ClassName

			local cloned = Instance.new(class)

			local mt = {
				__index = reference,
				__newindex = function(t, k, v)

					if k == "Name" then
						reference.Name = v
					end
					rawset(t, k, v)
				end
			}

			local proxy = setmetatable({}, mt)

			return proxy
		end

	end

	environment.global.compareinstances = function() return true end

	-- cache stuff

	local cache = {}

	environment.global.cache.iscached = function(thing)
		return cache[thing] ~= 'REMOVE' or thing:IsDescendantOf(game) or false -- If it's cache isnt 'REMOVE' and its a des of game (Usually always true) or if its cache is 'REMOVE' then its false.
	end
	environment.global.cache.invalidate = function(thing)
		cache[thing] = 'REMOVE'
		thing.Parent = nil
	end
	environment.global.cache.replace = function(a, b)
		if cache[a] then
			cache[a] = b
		end
		local n, p = a.Name, a.Parent -- name, parent
		b.Parent = p
		b.Name = n
		a.Parent = nil
	end

	-- END OF CACHE

	environment.global.fireclickdetector = function(idk, distance, event)
		local ClickDetector = idk:FindFirstChild("ClickDetector") or idk
		local VirtualInputManager = game:GetService("VirtualInputManager")
		local upval1 = ClickDetector.Parent
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Size = Vector3.new(30, 30, 30)
		part.Anchored = true
		part.CanCollide = false
		part.Parent = workspace
		ClickDetector.Parent = part
		ClickDetector.MaxActivationDistance = math.huge
		local connection = nil
		connection = game:GetService("RunService").Heartbeat:Connect(function()
			part.CFrame = workspace.Camera.CFrame * CFrame.new(0, 0, -20) * CFrame.new(workspace.Camera.CFrame.LookVector.X, workspace.Camera.CFrame.LookVector.Y, workspace.Camera.CFrame.LookVector.Z)
			game:GetService("VirtualUser"):ClickButton1(Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame)
		end)
		ClickDetector.MouseClick:Once(function()
			connection:Disconnect()
			ClickDetector.Parent = upval1
			part:Destroy()
		end)
	end
	environment.global.setclipboard = function(data)
		assert(data, "Missing #1 argument")

		bridge:send("setclipboard", tostring(data))
	end

	environment.global.toclipboard = environment.global.setclipboard

	environment.global.writefile = function(file_name, data)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		assert(data, "Missing #2 argument")

		file_name = file_name

		if file_name ~= nil then
			bridge:send("writefile", file_name, tostring(data)) 
		else
			print("Illegal file extension detected")
		end
	end 

	local everything = {game}

	game.DescendantRemoving:Connect(function(des)
		cache[des] = 'REMOVE'
	end)
	game.DescendantAdded:Connect(function(des)
		cache[des] = true
		table.insert(everything, des)
	end)

	for i, v in pairs(game:GetDescendants()) do
		table.insert(everything, v)
	end

	environment.global.getnilinstances = function()
		local nili = {}
		for i, v in pairs(everything) do
			if v.Parent ~= nil then continue end
			table.insert(nili, v)
		end
		return nili
	end
	environment.global.getgc = environment.global.getnilinstances
	environment.global.makefolder = function(folder_name)
		pcall(function()
			bridge:send("makefolder", folder_name)
		end)
	end

	environment.global.loadfile = function(file_name)
		local content = environment.global.readfile(file_name)

		return environment.global.loadstring(content)
	end

	environment.global.dofile = function(file_name)
		local content = environment.global.readfile(file_name)

		environment.global.loadstring(content)()
	end

	environment.global.messagebox = function(...)
		local args = {}

		assert(args[1], "Missing #1 argument")
		assert(typeof(args[1]) == "string", "Expected #1 argument to be string")

		print("[ MESSAGEBOX ] "..args[1])
	end

	environment.global.mouse1click = function()
		bridge:send("input_action", "mouse1click")
	end
	environment.global.mouse1press = function()
		bridge:send("input_action", "mouse1press")
	end
	environment.global.mouse1release = function()
		bridge:send("input_action", "mouse1release")
	end
	environment.global.mouse2click = function()
		bridge:send("input_action", "mouse2click")
	end
	environment.global.mouse2press = function()
		bridge:send("input_action", "mouse2press")
	end
	environment.global.mouse2release = function()
		bridge:send("input_action", "mouse2release")
	end
	environment.global.mousemoveabs = function()
		bridge:send("input_action", "mousemoveabs")
	end
	environment.global.mousemoverel = function()
		bridge:send("input_action", "mousemoverel")
	end
	environment.global.mousescroll = function()
		bridge:send("input_action", "mousescroll")
	end

	local roblox_active = true

	game:GetService("UserInputService").WindowFocused:Connect(function()
		roblox_active = true
	end)
	game:GetService("UserInputService").WindowFocusReleased:Connect(function()
		roblox_active = false
	end)

	environment.roblox.load = function(g, a)

	end
	environment.global.isrbxactive = function()
		return roblox_active
	end

	environment.global.isgameactive = environment.global.isrbxactive

	environment.global.readfile = function(file_name)
		assert(file_name, "Missing #1 argument")
		assert(typeof(file_name) == "string", "Expected #1 argument to be string, got ".. typeof(file_name).. " instead")

		local succeeded, res = pcall(function()
			file_name = file_name

			if file_name ~= nil then
				local response = bridge:send("readfile", file_name)

				if typeof(response) == "table" then
					local status = response["status"]

					if status == "success" then
						return response["message"] or ""
					else
						error(response["message"])
						return
					end
				else
					error("Readfile failed")
					return
				end
			else
				error("Illegal file extension detected")
				return
			end
		end)

		if succeeded then
			return res
		else
			error(res)
		end
	end

	environment.global.isreadonly = function(tbl)
		if type(tbl) ~= 'table' then return false end
		return table.isfrozen(tbl)
	end


	environment.global.isfolder = function(folder)
		assert(folder, "Missing #1 argument")
		assert(typeof(folder) == "string", "Expected #1 argument to be string, got "..tostring(typeof(folder)).. " instead")

		local response = bridge:send("isfolder", folder)

		if typeof(response) == "table" then
			local request_status = response["status"]

			if request_status == "success" then
				if response["message"] == "True" then
					return true
				else
					return false
				end
			else
				error(response["message"])
				return
			end
		else
			error("isfolder failed")
			return
		end
	end

	environment.global.getthreadidentity = function()
		return fake_identity
	end

	environment.global.getthreadcontext = environment.global.getthreadidentity

	environment.global.getidentity = environment.global.getthreadidentity

	environment.global.setthreadidentity = function(identity)
		fake_identity = identity
	end

	environment.global.setidentity = environment.global.setthreadidentity
	environment.global.setthreadcontext = environment.global.setthreadidentity


	environment.global.queue_on_teleport = function()
		print "Not implemented"
	end
	environment.global.queueonteleport = environment.global.queue_on_teleport

	environment.global.getloadedmodules = function()
		local moduleScripts = {}
		for _, obj in pairs(game:GetDescendants()) do
			if typeof(obj) == "Instance" and obj:IsA("ModuleScript") then table.insert(moduleScripts, obj) end
		end
		return moduleScripts
	end

	environment.global.getrunningscripts = function()
		local runningScripts = {}

		for _, obj in pairs(game:GetDescendants()) do
			if typeof(obj) == "Instance" and obj:IsA("ModuleScript") then
				table.insert(runningScripts, obj)
			elseif typeof(obj) == "Instance" and obj:IsA("LocalScript") then
				if obj.Enabled == true then
					table.insert(runningScripts, obj)
				end
			end
		end

		return runningScripts
	end

	environment.global.getinstances = function()
		return game:GetDescendants()
	end

	environment.global.getconnections = function()
		return {}
	end

	environment.global.gethui = function()
		return game:GetService("CoreGui")
	end

	environment.global.getscripts = function()
		local scripts = {}
		for _, scriptt in game:GetDescendants() do
			if scriptt:isA("LocalScript") or scriptt:isA("ModuleScript") then
				table.insert(scripts, scriptt)
			end
		end
		return scripts
	end


	environment.global.HttpGet = function(url)
		assert(url, "Missing #1 argument")
		assert(typeof(url) == "string", "Expected #1 argument to be string, got ".. typeof(url).. " instead")

		local response = bridge:send("HttpGet", url)

		if typeof(response) == "table" then
			local status = response["status"]

			warn(status)
			if status == "success" then
				return response["response"]
			else
				error(response["message"])
				return
			end
		else
			error("HttpGet failed")
			return
		end
	end

	environment.global.debug.getinfo = function(f, options)
		if type(options) == "string" then
			options = string.lower(options) 
		else
			options = "sflnu"
		end
		local result = {}
		for index = 1, #options do
			local option = string.sub(options, index, index)
			if "s" == option then
				local short_src = debug.info(f, "s")
				result.short_src = short_src
				result.source = "=" .. short_src
				result.what = if short_src == "[C]" then "C" else "Lua"
			elseif "f" == option then
				result.func = debug.info(f, "f")
			elseif "l" == option then
				result.currentline = debug.info(f, "l")
			elseif "n" == option then
				result.name = debug.info(f, "n")
			elseif "u" == option or option == "a" then
				local numparams, is_vararg = debug.info(f, "a")
				result.numparams = numparams
				result.is_vararg = if is_vararg then 1 else 0
				if "u" == option then
					result.nups = -1
				end
			end
		end
		return result
	end

	environment.global.lz4compress = function(str)
		local compressed = lz4.compress( str ) 

		return compressed
	end

	environment.global.lz4decompress = function(lz4data)
		local decompressed = lz4.decompress( lz4data ) 
		return decompressed
	end

	environment.global.request = function(HttpRequest)
		HttpRequest.CachePolicy = Enum.HttpCachePolicy.None
		HttpRequest.Priority = 5
		HttpRequest.Timeout = 15000
		if type(HttpRequest) == "table" then
			local var0 = false
		end
		local var596 = type(HttpRequest)
		assert(true, "invalid argument #1 to \'request\' (table expected, got " .. var596 .. ") ", 2)
		HttpRequest.Url = HttpRequest.Url:gsub("roblox.com", "roproxy.com")
		local upval0 = Instance.new("BindableEvent")
		local var612 = game:GetService("HttpService")
		var612 = var612.RequestInternal
		local var1 = var612(game:GetService("HttpService"), HttpRequest)
		local upval1 = nil
		var596 = var1
		var1.Start(var596, function(arg1, arg2)
			upval1 = arg2
			upval0:Fire()
		end)
		upval0.Event:Wait()
		return upval1
	end

	environment.global.http_request = environment.global.request
	environment.global.http.request = environment.global.request

	local patterns = {
		{ pattern = '(%w+)%s*%+=%s*(%w+)', format = "%s = %s + %s" },
		{ pattern = '(%w+)%s*%-=%s*(%w+)', format = "%s = %s - %s" },
		{ pattern = '(%w+)%s*%*=%s*(%w+)', format = "%s = %s * %s" },
		{ pattern = '(%w+)%s*/=%s*(%w+)', format = "%s = %s / %s" }
	}
	local patterns2 = {
		{ pattern = 'for%s+(%w+)%s*,%s*(%w+)%s*in%s*(%w+)%s*do', format = "for %s, %s in pairs(%s) do" }
	}

	local function ToPairsLoop(code)
		for _, p in ipairs(patterns2) do
			code = code:gsub(p.pattern, function(var1, var2, tbl)
				return p.format:format(var1, var2, tbl)
			end)
		end
		return code
	end
	local function toluau(code)
		for _, p in ipairs(patterns) do
			code = code:gsub(p.pattern, function(var, value)
				return p.format:format(var, var, value)
			end)
		end
		code = ToPairsLoop(code)
		return code
	end

	environment.global.clonefunction = function(fnc)
		return function(...) return fnc(...) end
	end

	environment.global.isexecutorclosure = function(closure)
		if closure == print then
			return false
		end
		if table.find(environment.global.getrenv(), closure) then
			return false
		else
			return true
		end
	end

	environment.global.checkclosure = environment.global.isexecutorclosure
	environment.global.isourclosure = environment.global.isexecutorclosure

	environment.global.checkcaller = function()
		local info = debug.info(getgenv, 'slnaf')
		return debug.info(1, 'slnaf')==info
	end


	environment.global.newcclosure = function(func)
		local func2 = nil
		func2 = function(...)
			environment.global[func] = coroutine.wrap(func2)
			return func(...)
		end
		func2 = coroutine.wrap(func2)
		return func2
	end
	environment.global.iscclosure = function(func)
		return debug.info(func, "s") == "[C]"
	end
	environment.global.islclosure = function(func)
		return debug.info(func, "s") ~= "[C]"
	end
	environment.global.newlclosure = function(func)
		return function(bullshit)
			return func(bullshit)
		end
	end

	-- WORKING ON LOADSTRING V2 (pls execute infinite yield faster dear loadstring)
	environment.global.loadstringg = function(source)
		local module = utils.fetch_modules()[1]:Clone()
		warn(module.Name)

		module.Source = "return function(...) " .. source .. " end"
		local success, func = pcall(require, module)

		return sandbox:apply(func)
	end

	environment.global.getrawmetatable = function(table_or_userdata)
		local result = getmetatable(table_or_userdata)

		if result == nil then 
			return
		end

		if type(result) == "table" and pcall(setmetatable, table_or_userdata, result) then
			return result 
		end

		local real_metamethods = {}

		xpcall(function()
			return table_or_userdata._
		end, function()
			real_metamethods.__index = debug.info(2, "f")
		end)

		xpcall(function()
			table_or_userdata._ = table_or_userdata
		end, function()
			real_metamethods.__newindex = debug.info(2, "f")
		end)
		xpcall(function()
			return table_or_userdata:___()
		end, function()
			real_metamethods.__namecall = debug.info(2, "f")
		end)

		xpcall(function()
			table_or_userdata()
		end, function()
			real_metamethods.__call = debug.info(2, "f")
		end)

		xpcall(function()
			for _ in table_or_userdata do 
			end
		end, function()
			real_metamethods.__iter = debug.info(2, "f")
		end)

		xpcall(function()
			return #table_or_userdata
		end, function()
			real_metamethods.__len = debug.info(2, "f")
		end)

		local type_check_semibypass = {} 

		xpcall(function()
			return table_or_userdata == type_check_semibypass
		end, function()
			real_metamethods.__eq = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata + type_check_semibypass
		end, function()
			real_metamethods.__add = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata - type_check_semibypass
		end, function()
			real_metamethods.__sub = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata * type_check_semibypass
		end, function()
			real_metamethods.__mul = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata / type_check_semibypass
		end, function()
			real_metamethods.__div = debug.info(2, "f")
		end)

		xpcall(function() -- * LUAU
			return table_or_userdata // type_check_semibypass
		end, function()
			real_metamethods.__idiv = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata % type_check_semibypass
		end, function()
			real_metamethods.__mod = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata ^ type_check_semibypass
		end, function()
			real_metamethods.__pow = debug.info(2, "f")
		end)

		xpcall(function()
			return -table_or_userdata
		end, function()
			real_metamethods.__unm = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata < type_check_semibypass
		end, function()
			real_metamethods.__lt = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata <= type_check_semibypass
		end, function()
			real_metamethods.__le = debug.info(2, "f")
		end)

		xpcall(function()
			return table_or_userdata .. type_check_semibypass
		end, function()
			real_metamethods.__concat = debug.info(2, "f")
		end)

		real_metamethods.__type = typeof(table_or_userdata)

		real_metamethods.__metatable = getmetatable(game) 

		real_metamethods.__tostring = function()
			return tostring(table_or_userdata)
		end

		if real_metamethods.__metatable == "The metatable is locked" then
			return { __metatable = "Locked!" }
		end

		return real_metamethods
	end

	environment.global.__TEST_GLOBAL = true

	environment.global.loadstring = function(source)
		assert(type(source) == "string", "arg #1 must be type string")

		local s1, val1 = pcall(function()
			return load("local v1=15;v1+=1;return v1", getfenv())()
		end)
		local s2, val2 = pcall(function()
			return load('local v1={"a"};for i, v in v1 do return v end', getfenv())()
		end)


		local GENV = setmetatable({
			_G = {},
			shared = {},
			game = game,
		}, {
			__index = function(self, index)
				return rawget(self, index) or getfenv()[index]
			end,
			__newindex = function(self, index, value)
				rawset(self, index, value)
			end,
		})
		-- click on live share then my name then unfollow

		local __GET_FAKE_ENV = function()
			local FAKE_SCRIPT = Instance.new("LocalScript")
			FAKE_SCRIPT.Name = "yurrgurten"

			return setmetatable({ script = FAKE_SCRIPT }, { __metatable = getmetatable(game), __index = GENV })
		end

		for i, f in pairs(sandbox.environment.global) do 
			GENV[i] = f
			getfenv(0)[i] = f
		end

		if val1 ~= 16 and val2 ~= "a" then
			return old(toluau(source), __GET_FAKE_ENV())
		else
			return old(source, __GET_FAKE_ENV())
		end
	end

	--Crypt lib
	-- thats in the crypt lib lol
	-- pookie we have base64 already
	environment.global.crypt.hex.encode = function(txt)
		txt = tostring(txt)
		local hex = ''
		for i = 1, #txt do
			hex = hex .. string.format("%02x", string.byte(txt, i))
		end
		return hex
	end

	environment.global.crypt.hex.decode = function(hex)
		hex = tostring(hex)
		local text = ""
		for i = 1, #hex, 2 do
			local byte_str = string.sub(hex, i, i+1)
			local byte = tonumber(byte_str, 16)
			text = text .. string.char(byte)
		end
		return text
	end

	environment.global.crypt.url.encode = function(a)
		return game:GetService("HttpService"):UrlEncode(a)
	end

	environment.global.crypt.url.decode = function(a)
		a = tostring(a)
		a = string.gsub(a, "+", " ")
		a = string.gsub(a, "%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
		a = string.gsub(a, "\r\n", "\n")
		return a
	end
	environment.global.crypt.generatekey = function(optionalSize)
		local key = ''
		local a = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		local n = nil
		for i = 1, optionalSize or 32 do local n = math.random(1, #a) key = key .. a:sub(n, n) end
		return environment.global.base64_encode(n)
	end

	environment.global.crypt.generatebytes = function(size)

	end
	--yeah
	-- can i test?
	-- k
	-- favourite function -> table.clone 
	--fr its op ima fix game:Httpget now

	-- after i execute ok
	--kk
	-- injected
	-- bruh smth causes memleak
	-- if i run unc twice it crash 
	-- bruh

	cloned_environment = table.clone(environment)
	for env_name, env in environment do
		cloned_environment[env_name] = table.clone(env) -- * We don't need to do a deep clone as long as every table in the genv (global) environment is frozen
	end

	self.environment = cloned_environment -- Disconnects user's environment from our init module's environment so that users cannot mess with custom functions that other custom functions rely on
	self.hidden_env = hidden_env
end


local function GiveOwnGlobals(Func, Script)
	-- Fix for this edit of dex being poorly made
	-- I (Alex) would like to commemorate whoever added this dex in somehow finding the worst dex to ever exist
	local Fenv, RealFenv, FenvMt = {}, {
		script = Script,
		getupvalue = function(a, b)
			return nil -- force it to use globals
		end,
		getreg = function() -- It loops registry for some idiotic reason so stop it from doing that and just use a global
			return {} -- force it to use globals
		end,
		identifyexecutor = function()
			return "Hisoka", "1.0"
		end
	}, {}
	FenvMt.__index = function(a,b)
		return RealFenv[b] == nil and sandbox.environment.global.getgenv()[b] or RealFenv[b]
	end
	FenvMt.__newindex = function(a, b, c)
		if RealFenv[b] == nil then 
			sandbox.environment.global.getgenv()[b] = c 
		else 
			RealFenv[b] = c 
		end
	end
	setmetatable(Fenv, FenvMt)
	pcall(setfenv, Func, Fenv)
	return Func
end


-- GUI
local gui = {}

function gui:Create()




	-- Synapse  X Remake made by @chillz_azy (yt)

	local synversion = "2.23.11"

	-- Instances: 150 | Scripts: 8 | Modules: 4
	local G2L = {};
	-- StarterGui.SynapseX
	G2L["1"] = Instance.new("ScreenGui", game:GetService("CoreGui"));
	G2L["1"]["Name"] = [[SynapseX]];
	G2L["1"]["ResetOnSpawn"] = false;

	-- StarterGui.SynapseX.FloatingIcon
	G2L["2"] = Instance.new("ImageButton", G2L["1"]);
	G2L["2"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["2"]["Size"] = UDim2.new(0, 36, 0, 36);
	G2L["2"]["Name"] = [[FloatingIcon]];
	G2L["2"].Visible = false
	G2L["2"]["Position"] = UDim2.new(0.7019911956787109, 0, 0.7092568278312683, 0);

	-- StarterGui.SynapseX.FloatingIcon. 
	G2L["3"] = Instance.new("ImageLabel", G2L["2"]);
	G2L["3"]["BorderSizePixel"] = 0;
	G2L["3"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["3"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["3"]["Size"] = UDim2.new(0, 23, 0, 26);
	G2L["3"]["Name"] = [[ ]];
	G2L["3"]["BackgroundTransparency"] = 1;
	G2L["3"]["Position"] = UDim2.new(0.16640418767929077, 0, 0.13268542289733887, 0);

	-- StarterGui.SynapseX.FloatingIcon.UICorner
	G2L["4"] = Instance.new("UICorner", G2L["2"]);
	G2L["4"]["CornerRadius"] = UDim.new(1, 8);

	-- StarterGui.SynapseX.FloatingIcon.UIGradient
	G2L["5"] = Instance.new("UIGradient", G2L["2"]);
	G2L["5"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 255, 255)),ColorSequenceKeypoint.new(0.720, Color3.fromRGB(0, 0, 0)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(0, 0, 0))};

	-- StarterGui.SynapseX.Main
	G2L["6"] = Instance.new("Frame", G2L["1"]);
	G2L["6"]["Active"] = true;
	G2L["6"]["ZIndex"] = 4;
	G2L["6"]["BorderSizePixel"] = 0;
	G2L["6"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 71);
	G2L["6"]["BackgroundTransparency"] = 1;
	G2L["6"]["Size"] = UDim2.new(0, 646, 0, 283);
	G2L["6"]["Position"] = UDim2.new(0, 19, 0, 23);
	G2L["6"]["Name"] = [[Main]];

	-- StarterGui.SynapseX.Main.Icon
	G2L["7"] = Instance.new("ImageLabel", G2L["6"]);
	G2L["7"]["BorderSizePixel"] = 0;
	G2L["7"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["7"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["7"]["Size"] = UDim2.new(0, 23, 0, 26);
	G2L["7"]["Name"] = [[Icon]];
	G2L["7"]["BackgroundTransparency"] = 1;
	G2L["7"]["Position"] = UDim2.new(0, 5, 0, 0);

	-- StarterGui.SynapseX.Main.Background
	G2L["8"] = Instance.new("ImageLabel", G2L["6"]);
	G2L["8"]["ZIndex"] = 0;
	G2L["8"]["BorderSizePixel"] = 0;
	G2L["8"]["ScaleType"] = Enum.ScaleType.Tile;
	G2L["8"]["BackgroundColor3"] = Color3.fromRGB(52, 52, 52);
	G2L["8"]["TileSize"] = UDim2.new(0, 25, 0, 25);
	G2L["8"]["Size"] = UDim2.new(0, 647, 0, 283);
	G2L["8"]["Name"] = [[Background]];

	-- StarterGui.SynapseX.Main.Panel
	G2L["9"] = Instance.new("Frame", G2L["6"]);
	G2L["9"]["ZIndex"] = 0;
	G2L["9"]["BorderSizePixel"] = 0;
	G2L["9"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["9"]["Size"] = UDim2.new(0, 647, 0, 27);
	G2L["9"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["9"]["Name"] = [[Panel]];

	-- StarterGui.SynapseX.Main.MainFunc
	G2L["a"] = Instance.new("Frame", G2L["6"]);
	G2L["a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["a"]["BackgroundTransparency"] = 1;
	G2L["a"]["Size"] = UDim2.new(0, 100, 0, 100);
	G2L["a"]["Name"] = [[MainFunc]];

	-- StarterGui.SynapseX.Main.MainFunc.Needs
	G2L["b"] = Instance.new("Folder", G2L["a"]);
	G2L["b"]["Name"] = [[Needs]];

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Tab
	G2L["c"] = Instance.new("TextButton", G2L["b"]);
	G2L["c"]["ZIndex"] = 0;
	G2L["c"]["BorderSizePixel"] = 0;
	G2L["c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["c"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
	G2L["c"]["TextSize"] = 14;
	G2L["c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["c"]["Visible"] = false;
	G2L["c"]["Size"] = UDim2.new(0, 56, 0, 16);
	G2L["c"]["Name"] = [[Tab]];
	G2L["c"]["Text"] = [[  Script 1]];
	G2L["c"]["Position"] = UDim2.new(-0.0003878306597471237, 0, -0.011710520833730698, 0);
	G2L["c"]["BackgroundTransparency"] = 0.10000000149011612;

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Tab.Remove
	G2L["d"] = Instance.new("TextButton", G2L["c"]);
	G2L["d"]["BorderSizePixel"] = 0;
	G2L["d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["d"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
	G2L["d"]["TextSize"] = 15;
	G2L["d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["d"]["Size"] = UDim2.new(0, 10, 0, 10);
	G2L["d"]["Name"] = [[Remove]];
	G2L["d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
	G2L["d"]["Text"] = [[x]];
	G2L["d"]["Position"] = UDim2.new(0, 46, 0, 2);
	G2L["d"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.MainFunc.Needs.ScriptHubButton
	G2L["e"] = Instance.new("TextButton", G2L["b"]);
	G2L["e"]["ZIndex"] = 3;
	G2L["e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["e"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["e"]["TextSize"] = 14;
	G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["e"]["Visible"] = false;
	G2L["e"]["Size"] = UDim2.new(0, 96, 0, 15);
	G2L["e"]["Name"] = [[ScriptHubButton]];
	G2L["e"]["BorderColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["e"]["Text"] = [[test.lua]];
	G2L["e"]["AutomaticSize"] = Enum.AutomaticSize.X;
	G2L["e"]["Position"] = UDim2.new(0.039603959769010544, 0, 0, 0);

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox
	G2L["f"] = Instance.new("ScrollingFrame", G2L["b"]);
	G2L["f"]["Active"] = true;
	G2L["f"]["BorderSizePixel"] = 0;
	G2L["f"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
	G2L["f"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
	G2L["f"]["AutomaticCanvasSize"] = Enum.AutomaticSize.XY;
	G2L["f"]["Size"] = UDim2.new(0, 533, 0, 197);
	G2L["f"]["Position"] = UDim2.new(0.05999999865889549, 0, 0.48061829805374146, 0);
	G2L["f"]["Visible"] = false;
	G2L["f"]["Name"] = [[Textbox]];

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame
	G2L["10"] = Instance.new("Frame", G2L["f"]);
	G2L["10"]["Active"] = true;
	G2L["10"]["BorderSizePixel"] = 0;
	G2L["10"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
	G2L["10"]["Size"] = UDim2.new(0, 533, 0, 200);
	G2L["10"]["Selectable"] = true;
	G2L["10"]["ClipsDescendants"] = true;
	G2L["10"]["AutomaticSize"] = Enum.AutomaticSize.XY;
	G2L["10"]["SelectionGroup"] = true;

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame.Textbox
	G2L["11"] = Instance.new("TextBox", G2L["10"]);
	G2L["11"]["ZIndex"] = 4;
	G2L["11"]["BorderSizePixel"] = 0;
	G2L["11"]["TextSize"] = 14;
	G2L["11"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["11"]["TextYAlignment"] = Enum.TextYAlignment.Top;
	G2L["11"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
	G2L["11"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["11"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["11"]["MultiLine"] = true;
	G2L["11"]["Size"] = UDim2.new(0, 486, 0, 194);
	G2L["11"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["11"]["Text"] = [[]];
	G2L["11"]["Position"] = UDim2.new(0, 35, 0, 0);
	G2L["11"]["AutomaticSize"] = Enum.AutomaticSize.XY;
	G2L["11"]["Name"] = [[Textbox]];
	G2L["11"]["ClearTextOnFocus"] = false;

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame.Linebar
	G2L["12"] = Instance.new("Frame", G2L["10"]);
	G2L["12"]["ZIndex"] = 2;
	G2L["12"]["BorderSizePixel"] = 0;
	G2L["12"]["BackgroundColor3"] = Color3.fromRGB(36, 36, 36);
	G2L["12"]["Size"] = UDim2.new(0, 32, 1, 0);
	G2L["12"]["Name"] = [[Linebar]];

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame.Linebar.LineText
	G2L["13"] = Instance.new("TextLabel", G2L["12"]);
	G2L["13"]["ZIndex"] = 5;
	G2L["13"]["TextYAlignment"] = Enum.TextYAlignment.Top;
	G2L["13"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["13"]["TextXAlignment"] = Enum.TextXAlignment.Right;
	G2L["13"]["FontFace"] = Font.new([[rbxasset://fonts/families/Inconsolata.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
	G2L["13"]["TextSize"] = 14;
	G2L["13"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["13"]["Size"] = UDim2.new(0, 24, 0, 197);
	G2L["13"]["Text"] = [[1]];
	G2L["13"]["Name"] = [[LineText]];
	G2L["13"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame.Highlighted
	G2L["14"] = Instance.new("Frame", G2L["10"]);
	G2L["14"]["ZIndex"] = 5;
	G2L["14"]["BorderSizePixel"] = 0;
	G2L["14"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
	G2L["14"]["BackgroundTransparency"] = 0.699999988079071;
	G2L["14"]["Size"] = UDim2.new(1.0958691835403442, 0, 0, 13);
	G2L["14"]["Position"] = UDim2.new(0, -44, 0, 0);
	G2L["14"]["AutomaticSize"] = Enum.AutomaticSize.X;
	G2L["14"]["Name"] = [[Highlighted]];

	-- StarterGui.SynapseX.Main.MainFunc.Needs.Textbox.Frame.Highlighted.LineText
	G2L["15"] = Instance.new("TextLabel", G2L["14"]);
	G2L["15"]["ZIndex"] = 5;
	G2L["15"]["TextYAlignment"] = Enum.TextYAlignment.Top;
	G2L["15"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["15"]["TextXAlignment"] = Enum.TextXAlignment.Right;
	G2L["15"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["15"]["TextTransparency"] = 1;
	G2L["15"]["TextSize"] = 14;
	G2L["15"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["15"]["Size"] = UDim2.new(0, 24, 0, 197);
	G2L["15"]["Text"] = [[1]];
	G2L["15"]["Name"] = [[LineText]];
	G2L["15"]["Visible"] = false;
	G2L["15"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.MainFunc.Textboxes
	G2L["16"] = Instance.new("Folder", G2L["a"]);
	G2L["16"]["Name"] = [[Textboxes]];

	-- StarterGui.SynapseX.Main.MainFunc.ScriptHub
	G2L["17"] = Instance.new("ScrollingFrame", G2L["a"]);
	G2L["17"]["Active"] = true;
	G2L["17"]["ZIndex"] = 2;
	G2L["17"]["BorderSizePixel"] = 0;
	G2L["17"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["17"]["AutomaticCanvasSize"] = Enum.AutomaticSize.XY;
	G2L["17"]["Size"] = UDim2.new(0, 101, 0, 215);
	G2L["17"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["17"]["Position"] = UDim2.new(5.420000076293945, 0, 0.30000001192092896, 0);
	G2L["17"]["Name"] = [[ScriptHub]];

	-- StarterGui.SynapseX.Main.MainFunc.ScriptHub.UIListLayout
	G2L["18"] = Instance.new("UIListLayout", G2L["17"]);
	G2L["18"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

	-- StarterGui.SynapseX.Main.MainFunc.ScriptHub.UIPadding
	G2L["19"] = Instance.new("UIPadding", G2L["17"]);
	G2L["19"]["PaddingLeft"] = UDim.new(0.05000000074505806, 0);

	-- StarterGui.SynapseX.Main.Maximize
	G2L["1a"] = Instance.new("ImageButton", G2L["6"]);
	G2L["1a"]["BorderSizePixel"] = 0;
	G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["1a"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["1a"]["Name"] = [[Maximize]];
	G2L["1a"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["1a"]["Position"] = UDim2.new(0, 606, 0, 2);

	-- StarterGui.SynapseX.Main.Maximize.NameText
	G2L["1b"] = Instance.new("TextLabel", G2L["1a"]);
	G2L["1b"]["TextWrapped"] = true;
	G2L["1b"]["ZIndex"] = 2;
	G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["1b"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["1b"]["TextSize"] = 12;
	G2L["1b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1b"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["1b"]["Active"] = true;
	G2L["1b"]["Text"] = [[M]];
	G2L["1b"]["Name"] = [[NameText]];
	G2L["1b"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Maximize.ImageButton
	G2L["1c"] = Instance.new("ImageButton", G2L["1a"]);
	G2L["1c"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["1c"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["1c"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["1c"]["Visible"] = false;
	G2L["1c"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Maximize.UICorner
	G2L["1d"] = Instance.new("UICorner", G2L["1a"]);
	G2L["1d"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.TitleSynapse
	G2L["1e"] = Instance.new("TextLabel", G2L["6"]);
	G2L["1e"]["BorderSizePixel"] = 0;
	G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["1e"]["TextSize"] = 15;
	G2L["1e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["1e"]["Size"] = UDim2.new(0, 646, 0, 27);
	G2L["1e"]["Text"] = "Synapse CE - "..synversion;
	G2L["1e"]["Name"] = [[TitleSynapse]];
	G2L["1e"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.ScriptHub
	G2L["1f"] = Instance.new("ImageButton", G2L["6"]);
	G2L["1f"]["BorderSizePixel"] = 0;
	G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["1f"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["1f"]["Name"] = [[ScriptHub]];
	G2L["1f"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["1f"]["Position"] = UDim2.new(0, 560, 0, 250);

	-- StarterGui.SynapseX.Main.ScriptHub.NameText
	G2L["20"] = Instance.new("TextLabel", G2L["1f"]);
	G2L["20"]["TextWrapped"] = true;
	G2L["20"]["ZIndex"] = 2;
	G2L["20"]["BorderSizePixel"] = 0;
	G2L["20"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["20"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["20"]["TextSize"] = 14;
	G2L["20"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["20"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["20"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["20"]["Text"] = [[Script Hub]];
	G2L["20"]["Name"] = [[NameText]];
	G2L["20"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.ScriptHub.ImageButton
	G2L["21"] = Instance.new("ImageButton", G2L["1f"]);
	G2L["21"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["21"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["21"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["21"]["Visible"] = false;
	G2L["21"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.ScriptHub.UICorner
	G2L["22"] = Instance.new("UICorner", G2L["1f"]);
	G2L["22"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Options
	G2L["23"] = Instance.new("ImageButton", G2L["6"]);
	G2L["23"]["BorderSizePixel"] = 0;
	G2L["23"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["23"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["23"]["Name"] = [[Options]];
	G2L["23"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["23"]["Position"] = UDim2.new(0, 352, 0, 250);

	-- StarterGui.SynapseX.Main.Options.NameText
	G2L["24"] = Instance.new("TextLabel", G2L["23"]);
	G2L["24"]["TextWrapped"] = true;
	G2L["24"]["ZIndex"] = 2;
	G2L["24"]["BorderSizePixel"] = 0;
	G2L["24"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["24"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["24"]["TextSize"] = 14;
	G2L["24"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["24"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["24"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["24"]["Text"] = [[Options]];
	G2L["24"]["Name"] = [[NameText]];
	G2L["24"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Options.ImageButton
	G2L["25"] = Instance.new("ImageButton", G2L["23"]);
	G2L["25"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["25"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["25"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["25"]["Visible"] = false;
	G2L["25"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Options.UICorner
	G2L["26"] = Instance.new("UICorner", G2L["23"]);
	G2L["26"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Minimize
	G2L["27"] = Instance.new("ImageButton", G2L["6"]);
	G2L["27"]["BorderSizePixel"] = 0;
	G2L["27"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["27"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["27"]["Name"] = [[Minimize]];
	G2L["27"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["27"]["Position"] = UDim2.new(0, 582, 0, 2);

	-- StarterGui.SynapseX.Main.Minimize.NameText
	G2L["28"] = Instance.new("TextLabel", G2L["27"]);
	G2L["28"]["TextWrapped"] = true;
	G2L["28"]["ZIndex"] = 2;
	G2L["28"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["28"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["28"]["TextSize"] = 15;
	G2L["28"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["28"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["28"]["Active"] = true;
	G2L["28"]["Text"] = [[_]];
	G2L["28"]["Name"] = [[NameText]];
	G2L["28"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Minimize.ImageButton
	G2L["29"] = Instance.new("ImageButton", G2L["27"]);
	G2L["29"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["29"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["29"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["29"]["Visible"] = false;
	G2L["29"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Minimize.UICorner
	G2L["2a"] = Instance.new("UICorner", G2L["27"]);
	G2L["2a"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Execute
	G2L["2b"] = Instance.new("ImageButton", G2L["6"]);
	G2L["2b"]["BorderSizePixel"] = 0;
	G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["2b"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["2b"]["Name"] = [[Execute]];
	G2L["2b"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["2b"]["Position"] = UDim2.new(0, 6, 0, 250);

	-- StarterGui.SynapseX.Main.Execute.NameText
	G2L["2c"] = Instance.new("TextLabel", G2L["2b"]);
	G2L["2c"]["TextWrapped"] = true;
	G2L["2c"]["ZIndex"] = 2;
	G2L["2c"]["BorderSizePixel"] = 0;
	G2L["2c"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["2c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["2c"]["TextSize"] = 14;
	G2L["2c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["2c"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["2c"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["2c"]["Text"] = [[Execute]];
	G2L["2c"]["Name"] = [[NameText]];
	G2L["2c"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Execute.ImageButton
	G2L["2d"] = Instance.new("ImageButton", G2L["2b"]);
	G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["2d"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["2d"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["2d"]["Visible"] = false;
	G2L["2d"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Execute.UICorner
	G2L["2e"] = Instance.new("UICorner", G2L["2b"]);
	G2L["2e"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.SaveFile
	G2L["2f"] = Instance.new("ImageButton", G2L["6"]);
	G2L["2f"]["BorderSizePixel"] = 0;
	G2L["2f"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["2f"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["2f"]["Name"] = [[SaveFile]];
	G2L["2f"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["2f"]["Position"] = UDim2.new(0, 266, 0, 250);

	-- StarterGui.SynapseX.Main.SaveFile.NameText
	G2L["30"] = Instance.new("TextLabel", G2L["2f"]);
	G2L["30"]["TextWrapped"] = true;
	G2L["30"]["ZIndex"] = 2;
	G2L["30"]["BorderSizePixel"] = 0;
	G2L["30"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["30"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["30"]["TextSize"] = 14;
	G2L["30"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["30"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["30"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["30"]["Text"] = [[Save File]];
	G2L["30"]["Name"] = [[NameText]];
	G2L["30"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.SaveFile.ImageButton
	G2L["31"] = Instance.new("ImageButton", G2L["2f"]);
	G2L["31"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["31"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["31"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["31"]["Visible"] = false;
	G2L["31"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.SaveFile.UICorner
	G2L["32"] = Instance.new("UICorner", G2L["2f"]);
	G2L["32"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Close
	G2L["33"] = Instance.new("ImageButton", G2L["6"]);
	G2L["33"]["BorderSizePixel"] = 0;
	G2L["33"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["33"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["33"]["Name"] = [[Close]];
	G2L["33"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["33"]["Position"] = UDim2.new(0, 627, 0, 2);

	-- StarterGui.SynapseX.Main.Close.NameText
	G2L["34"] = Instance.new("TextLabel", G2L["33"]);
	G2L["34"]["TextWrapped"] = true;
	G2L["34"]["ZIndex"] = 2;
	G2L["34"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["34"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["34"]["TextSize"] = 14;
	G2L["34"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["34"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["34"]["Active"] = true;
	G2L["34"]["Text"] = [[x]];
	G2L["34"]["Name"] = [[NameText]];
	G2L["34"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Close.ImageButton
	G2L["35"] = Instance.new("ImageButton", G2L["33"]);
	G2L["35"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["35"]["Size"] = UDim2.new(0, 15, 0, 15);
	G2L["35"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["35"]["Visible"] = false;
	G2L["35"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Close.UICorner
	G2L["36"] = Instance.new("UICorner", G2L["33"]);
	G2L["36"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Clear
	G2L["37"] = Instance.new("ImageButton", G2L["6"]);
	G2L["37"]["BorderSizePixel"] = 0;
	G2L["37"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["37"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["37"]["Name"] = [[Clear]];
	G2L["37"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["37"]["Position"] = UDim2.new(0, 92, 0, 250);

	-- StarterGui.SynapseX.Main.Clear.NameText
	G2L["38"] = Instance.new("TextLabel", G2L["37"]);
	G2L["38"]["TextWrapped"] = true;
	G2L["38"]["ZIndex"] = 2;
	G2L["38"]["BorderSizePixel"] = 0;
	G2L["38"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["38"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["38"]["TextSize"] = 14;
	G2L["38"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["38"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["38"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["38"]["Text"] = [[Clear]];
	G2L["38"]["Name"] = [[NameText]];
	G2L["38"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Clear.ImageButton
	G2L["39"] = Instance.new("ImageButton", G2L["37"]);
	G2L["39"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["39"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["39"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["39"]["Visible"] = false;
	G2L["39"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Clear.UICorner
	G2L["3a"] = Instance.new("UICorner", G2L["37"]);
	G2L["3a"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.Attach
	G2L["3b"] = Instance.new("ImageButton", G2L["6"]);
	G2L["3b"]["BorderSizePixel"] = 0;
	G2L["3b"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["3b"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["3b"]["Name"] = [[Attach]];
	G2L["3b"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["3b"]["Position"] = UDim2.new(0, 474, 0, 250);

	-- StarterGui.SynapseX.Main.Attach.NameText
	G2L["3c"] = Instance.new("TextLabel", G2L["3b"]);
	G2L["3c"]["TextWrapped"] = true;
	G2L["3c"]["ZIndex"] = 2;
	G2L["3c"]["BorderSizePixel"] = 0;
	G2L["3c"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["3c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["3c"]["TextSize"] = 14;
	G2L["3c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["3c"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["3c"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["3c"]["Text"] = [[Attach]];
	G2L["3c"]["Name"] = [[NameText]];
	G2L["3c"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.Attach.ImageButton
	G2L["3d"] = Instance.new("ImageButton", G2L["3b"]);
	G2L["3d"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["3d"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["3d"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["3d"]["Visible"] = false;
	G2L["3d"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.Attach.UICorner
	G2L["3e"] = Instance.new("UICorner", G2L["3b"]);
	G2L["3e"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.OpenFile
	G2L["3f"] = Instance.new("ImageButton", G2L["6"]);
	G2L["3f"]["BorderSizePixel"] = 0;
	G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["3f"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["3f"]["Name"] = [[OpenFile]];
	G2L["3f"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["3f"]["Position"] = UDim2.new(0, 179, 0, 250);

	-- StarterGui.SynapseX.Main.OpenFile.NameText
	G2L["40"] = Instance.new("TextLabel", G2L["3f"]);
	G2L["40"]["TextWrapped"] = true;
	G2L["40"]["ZIndex"] = 2;
	G2L["40"]["BorderSizePixel"] = 0;
	G2L["40"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["40"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["40"]["TextSize"] = 14;
	G2L["40"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["40"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["40"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["40"]["Text"] = [[Open File]];
	G2L["40"]["Name"] = [[NameText]];
	G2L["40"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.Main.OpenFile.ImageButton
	G2L["41"] = Instance.new("ImageButton", G2L["3f"]);
	G2L["41"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["41"]["Size"] = UDim2.new(0, 82, 0, 27);
	G2L["41"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["41"]["Visible"] = false;
	G2L["41"]["BackgroundTransparency"] = 0.6000000238418579;

	-- StarterGui.SynapseX.Main.OpenFile.UICorner
	G2L["42"] = Instance.new("UICorner", G2L["3f"]);
	G2L["42"]["CornerRadius"] = UDim.new(0, 0);

	-- StarterGui.SynapseX.Main.ScriptTab
	G2L["43"] = Instance.new("ScrollingFrame", G2L["6"]);
	G2L["43"]["Active"] = true;
	G2L["43"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
	G2L["43"]["SizeConstraint"] = Enum.SizeConstraint.RelativeYY;
	G2L["43"]["ZIndex"] = 6;
	G2L["43"]["BorderSizePixel"] = 0;
	G2L["43"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
	G2L["43"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["43"]["VerticalScrollBarPosition"] = Enum.VerticalScrollBarPosition.Left;
	G2L["43"]["HorizontalScrollBarInset"] = Enum.ScrollBarInset.Always;
	G2L["43"]["AutomaticCanvasSize"] = Enum.AutomaticSize.X;
	G2L["43"]["BackgroundTransparency"] = 0.9990000128746033;
	G2L["43"]["Size"] = UDim2.new(0, 533, 0, 16);
	G2L["43"]["Selectable"] = false;
	G2L["43"]["ClipsDescendants"] = false;
	G2L["43"]["ScrollBarThickness"] = 3;
	G2L["43"]["Position"] = UDim2.new(0, 6, 0, 32);
	G2L["43"]["Name"] = [[ScriptTab]];
	G2L["43"]["SelectionGroup"] = false;

	-- StarterGui.SynapseX.Main.ScriptTab.ScriptTabHandler
	G2L["44"] = Instance.new("LocalScript", G2L["43"]);
	G2L["44"]["Name"] = [[ScriptTabHandler]];

	-- StarterGui.SynapseX.Main.ScriptTab.Tabs
	G2L["45"] = Instance.new("Folder", G2L["43"]);
	G2L["45"]["Name"] = [[Tabs]];

	-- StarterGui.SynapseX.Main.ScriptTab.Tabs.AddScript
	G2L["46"] = Instance.new("Frame", G2L["45"]);
	G2L["46"]["Active"] = true;
	G2L["46"]["ZIndex"] = 0;
	G2L["46"]["BorderSizePixel"] = 0;
	G2L["46"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
	G2L["46"]["BackgroundTransparency"] = 1;
	G2L["46"]["LayoutOrder"] = 999999999;
	G2L["46"]["Size"] = UDim2.new(0, 10, 0, 11);
	G2L["46"]["Selectable"] = true;
	G2L["46"]["Name"] = [[AddScript]];

	-- StarterGui.SynapseX.Main.ScriptTab.Tabs.AddScript.Button
	G2L["47"] = Instance.new("TextButton", G2L["46"]);
	G2L["47"]["BorderSizePixel"] = 0;
	G2L["47"]["BackgroundColor3"] = Color3.fromRGB(101, 101, 101);
	G2L["47"]["TextSize"] = 20;
	G2L["47"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["47"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["47"]["Size"] = UDim2.new(0, 10, 0, 11);
	G2L["47"]["LayoutOrder"] = 999999999;
	G2L["47"]["Name"] = [[Button]];
	G2L["47"]["Text"] = [[+]];
	G2L["47"]["Position"] = UDim2.new(0.1599999964237213, 0, 0.25, 0);
	G2L["47"]["BackgroundTransparency"] = 0.10000000149011612;

	-- StarterGui.SynapseX.Main.ScriptTab.Tabs.UIListLayout
	G2L["48"] = Instance.new("UIListLayout", G2L["45"]);
	G2L["48"]["FillDirection"] = Enum.FillDirection.Horizontal;
	G2L["48"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

	-- StarterGui.SynapseX.Main.ButtonsHandler
	G2L["49"] = Instance.new("LocalScript", G2L["6"]);
	G2L["49"]["Name"] = [[ButtonsHandler]];

	-- StarterGui.SynapseX.SaveScript
	G2L["4a"] = Instance.new("Frame", G2L["1"]);
	G2L["4a"]["Active"] = true;
	G2L["4a"]["ZIndex"] = 10;
	G2L["4a"]["BorderSizePixel"] = 0;
	G2L["4a"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["4a"]["Size"] = UDim2.new(0, 322, 0, 81);
	G2L["4a"]["Position"] = UDim2.new(0.2866774797439575, 0, 0.3861943185329437, 0);
	G2L["4a"]["Visible"] = false;
	G2L["4a"]["Name"] = [[SaveScript]];

	-- StarterGui.SynapseX.SaveScript.scriptname
	G2L["4b"] = Instance.new("TextBox", G2L["4a"]);
	G2L["4b"]["ZIndex"] = 11;
	G2L["4b"]["BorderSizePixel"] = 0;
	G2L["4b"]["TextSize"] = 14;
	G2L["4b"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
	G2L["4b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["4b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["4b"]["PlaceholderText"] = [[File Name]];
	G2L["4b"]["Size"] = UDim2.new(0, 317, 0, 22);
	G2L["4b"]["Text"] = [[]];
	G2L["4b"]["Position"] = UDim2.new(0, 3, 0, 32);
	G2L["4b"]["Name"] = [[scriptname]];

	-- StarterGui.SynapseX.SaveScript.savescript
	G2L["4c"] = Instance.new("TextButton", G2L["4a"]);
	G2L["4c"]["ZIndex"] = 11;
	G2L["4c"]["BorderSizePixel"] = 0;
	G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
	G2L["4c"]["TextSize"] = 14;
	G2L["4c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["4c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["4c"]["Size"] = UDim2.new(0, 317, 0, 19);
	G2L["4c"]["Name"] = [[savescript]];
	G2L["4c"]["Text"] = [[Save File]];
	G2L["4c"]["Position"] = UDim2.new(0, 3, 0, 56);

	-- StarterGui.SynapseX.SaveScript.Icon
	G2L["4d"] = Instance.new("ImageLabel", G2L["4a"]);
	G2L["4d"]["ZIndex"] = 11;
	G2L["4d"]["BorderSizePixel"] = 0;
	G2L["4d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["4d"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["4d"]["Size"] = UDim2.new(0, 48, 0, 23);
	G2L["4d"]["Name"] = [[Icon]];
	G2L["4d"]["BackgroundTransparency"] = 1;
	G2L["4d"]["Position"] = UDim2.new(0.008999999612569809, 0, 0.05000000074505806, 0);

	-- StarterGui.SynapseX.SaveScript.Icon.UIAspectRatioConstraint
	G2L["4e"] = Instance.new("UIAspectRatioConstraint", G2L["4d"]);
	G2L["4e"]["AspectRatio"] = 0.8846153616905212;

	-- StarterGui.SynapseX.SaveScript.Title
	G2L["4f"] = Instance.new("TextLabel", G2L["4a"]);
	G2L["4f"]["TextWrapped"] = true;
	G2L["4f"]["ZIndex"] = 11;
	G2L["4f"]["BorderSizePixel"] = 4;
	G2L["4f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["4f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["4f"]["TextSize"] = 15;
	G2L["4f"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["4f"]["Size"] = UDim2.new(0, 322, 0, 30);
	G2L["4f"]["Active"] = true;
	G2L["4f"]["Text"] = [[Synapse CE - Save File]];
	G2L["4f"]["Name"] = [[Title]];
	G2L["4f"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.SaveScript.Close
	G2L["50"] = Instance.new("TextButton", G2L["4a"]);
	G2L["50"]["TextWrapped"] = true;
	G2L["50"]["ZIndex"] = 12;
	G2L["50"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["50"]["TextSize"] = 17;
	G2L["50"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["50"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["50"]["Selectable"] = false;
	G2L["50"]["Size"] = UDim2.new(0, 26, 0, 26);
	G2L["50"]["Name"] = [[Close]];
	G2L["50"]["Text"] = [[x]];
	G2L["50"]["Position"] = UDim2.new(0.9130434989929199, 0, 0.024690981954336166, 0);
	G2L["50"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.SaveScript.Handler
	G2L["51"] = Instance.new("LocalScript", G2L["4a"]);
	G2L["51"]["Name"] = [[Handler]];

	-- StarterGui.SynapseX.ScriptLog
	G2L["52"] = Instance.new("Frame", G2L["1"]);
	G2L["52"]["Active"] = true;
	G2L["52"]["BorderSizePixel"] = 0;
	G2L["52"]["BackgroundColor3"] = Color3.fromRGB(71, 71, 71);
	G2L["52"]["Size"] = UDim2.new(0, 353, 0, 26);
	G2L["52"]["Position"] = UDim2.new(0.25691962242126465, 0, 0.26443204283714294, 0);
	G2L["52"]["Visible"] = false;
	G2L["52"]["Name"] = [[ScriptLog]];

	-- StarterGui.SynapseX.ScriptLog.MainFrame
	G2L["53"] = Instance.new("Frame", G2L["52"]);
	G2L["53"]["BorderSizePixel"] = 0;
	G2L["53"]["BackgroundColor3"] = Color3.fromRGB(51, 51, 51);
	G2L["53"]["Size"] = UDim2.new(0, 353, 0, 185);
	G2L["53"]["Position"] = UDim2.new(0, 0, 1, 0);
	G2L["53"]["Name"] = [[MainFrame]];

	-- StarterGui.SynapseX.ScriptLog.MainFrame.ANS9DZNASD8Z7NAS987NAFA
	G2L["54"] = Instance.new("ScrollingFrame", G2L["53"]);
	G2L["54"]["Active"] = true;
	G2L["54"]["BorderSizePixel"] = 0;
	G2L["54"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["54"]["Size"] = UDim2.new(0, 116, 0, 162);
	G2L["54"]["Position"] = UDim2.new(0.033443499356508255, 0, 0.06024263799190521, 0);
	G2L["54"]["Name"] = [[ANS9DZNASD8Z7NAS987NAFA]];

	-- StarterGui.SynapseX.ScriptLog.MainFrame.ANS9DZNASD8Z7NAS987NAFA.Script1
	G2L["55"] = Instance.new("TextButton", G2L["54"]);
	G2L["55"]["BorderSizePixel"] = 0;
	G2L["55"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["55"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
	G2L["55"]["TextSize"] = 14;
	G2L["55"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["55"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["55"]["Size"] = UDim2.new(0, 116, 0, 19);
	G2L["55"]["Name"] = [[Script1]];
	G2L["55"]["Text"] = [[Script1]];

	-- StarterGui.SynapseX.ScriptLog.MainFrame.A8SDMZAS89DZANSA98F
	G2L["56"] = Instance.new("TextButton", G2L["53"]);
	G2L["56"]["BorderSizePixel"] = 0;
	G2L["56"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["56"]["TextSize"] = 14;
	G2L["56"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["56"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["56"]["Size"] = UDim2.new(0, 97, 0, 25);
	G2L["56"]["Name"] = [[A8SDMZAS89DZANSA98F]];
	G2L["56"]["Text"] = [[Close]];
	G2L["56"]["Position"] = UDim2.new(0.7019798755645752, 0, 0.800000011920929, 0);

	-- StarterGui.SynapseX.ScriptLog.MainFrame.9NAC7A9S7N8ZASFH9ASF87NAS8YGA9GSA7
	G2L["57"] = Instance.new("TextBox", G2L["53"]);
	G2L["57"]["BorderSizePixel"] = 0;
	G2L["57"]["TextEditable"] = false;
	G2L["57"]["TextSize"] = 14;
	G2L["57"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["57"]["TextYAlignment"] = Enum.TextYAlignment.Top;
	G2L["57"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["57"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["57"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["57"]["Size"] = UDim2.new(0, 200, 0, 129);
	G2L["57"]["Text"] = [[]];
	G2L["57"]["Position"] = UDim2.new(0.4107648730278015, 0, 0.05550934001803398, 0);
	G2L["57"]["Name"] = [[9NAC7A9S7N8ZASFH9ASF87NAS8YGA9GSA7]];
	G2L["57"]["ClearTextOnFocus"] = false;

	-- StarterGui.SynapseX.ScriptLog.MainFrame.9A8D7NAS9Z87NZDA98S7DNA98DNZ9A8SN
	G2L["58"] = Instance.new("TextButton", G2L["53"]);
	G2L["58"]["BorderSizePixel"] = 0;
	G2L["58"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["58"]["TextSize"] = 14;
	G2L["58"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["58"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["58"]["Size"] = UDim2.new(0, 97, 0, 25);
	G2L["58"]["Name"] = [[9A8D7NAS9Z87NZDA98S7DNA98DNZ9A8SN]];
	G2L["58"]["Text"] = [[Copy Code]];
	G2L["58"]["Position"] = UDim2.new(0.4107648730278015, 0, 0.800000011920929, 0);

	-- StarterGui.SynapseX.ScriptLog.Icon
	G2L["59"] = Instance.new("ImageLabel", G2L["52"]);
	G2L["59"]["BorderSizePixel"] = 0;
	G2L["59"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["59"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["59"]["Size"] = UDim2.new(0, 23, 0, 26);
	G2L["59"]["Name"] = [[Icon]];
	G2L["59"]["BackgroundTransparency"] = 1;
	G2L["59"]["Position"] = UDim2.new(0.00932147353887558, 0, -0.006203480064868927, 0);

	-- StarterGui.SynapseX.ScriptLog.Title
	G2L["5a"] = Instance.new("TextLabel", G2L["52"]);
	G2L["5a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["5a"]["TextSize"] = 14;
	G2L["5a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5a"]["Size"] = UDim2.new(0, 353, 0, 26);
	G2L["5a"]["Text"] = [[Script Log]];
	G2L["5a"]["Name"] = [[Title]];
	G2L["5a"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu
	G2L["5b"] = Instance.new("Frame", G2L["1"]);
	G2L["5b"]["Active"] = true;
	G2L["5b"]["BorderSizePixel"] = 0;
	G2L["5b"]["BackgroundColor3"] = Color3.fromRGB(67, 67, 67);
	G2L["5b"]["Size"] = UDim2.new(0, 411, 0, 31);
	G2L["5b"]["Position"] = UDim2.new(0, 13, 0, 13);
	G2L["5b"]["Visible"] = false;
	G2L["5b"]["Name"] = [[ScriptHubMenu]];

	-- StarterGui.SynapseX.ScriptHubMenu.Background
	G2L["5c"] = Instance.new("ImageLabel", G2L["5b"]);
	G2L["5c"]["BorderSizePixel"] = 0;
	G2L["5c"]["ScaleType"] = Enum.ScaleType.Tile;
	G2L["5c"]["BackgroundColor3"] = Color3.fromRGB(50, 50, 50);
	G2L["5c"]["Size"] = UDim2.new(0, 411, 0, 275);
	G2L["5c"]["Active"] = true;
	G2L["5c"]["BorderColor3"] = Color3.fromRGB(55, 55, 55);
	G2L["5c"]["Name"] = [[Background]];

	-- StarterGui.SynapseX.ScriptHubMenu.Background.ScrollingFrame
	G2L["5d"] = Instance.new("ScrollingFrame", G2L["5c"]);
	G2L["5d"]["Active"] = true;
	G2L["5d"]["BorderSizePixel"] = 0;
	G2L["5d"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
	G2L["5d"]["TopImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];
	G2L["5d"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["5d"]["Size"] = UDim2.new(0, 109, 0, 226);
	G2L["5d"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5d"]["ScrollBarThickness"] = 14;
	G2L["5d"]["Position"] = UDim2.new(0.020667528733611107, 0, 0.13779912889003754, 0);
	G2L["5d"]["BottomImage"] = [[rbxasset://textures/ui/Scroll/scroll-middle.png]];

	-- StarterGui.SynapseX.ScriptHubMenu.Background.ScrollingFrame.Dex
	G2L["5e"] = Instance.new("TextButton", G2L["5d"]);
	G2L["5e"]["TextWrapped"] = true;
	G2L["5e"]["BorderSizePixel"] = 0;
	G2L["5e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["5e"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["5e"]["TextSize"] = 14;
	G2L["5e"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["5e"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5e"]["Size"] = UDim2.new(0, 107, 0, 18);
	G2L["5e"]["Name"] = [[Dex]];
	G2L["5e"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["5e"]["Text"] = [[Dex Explorer]];
	G2L["5e"]["Position"] = UDim2.new(0, 1, 0, 1);
	G2L["5e"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu.Background.ScrollingFrame.ScriptDumper
	G2L["5f"] = Instance.new("TextButton", G2L["5d"]);
	G2L["5f"]["BorderSizePixel"] = 0;
	G2L["5f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["5f"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["5f"]["TextSize"] = 14;
	G2L["5f"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["5f"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["5f"]["Size"] = UDim2.new(0, 107, 0, 18);
	G2L["5f"]["Name"] = [[ScriptDumper]];
	G2L["5f"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["5f"]["Text"] = [[Script Dumper]];
	G2L["5f"]["Position"] = UDim2.new(0.008999999612569809, 0, 0.34637168049812317, 0);
	G2L["5f"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu.Background.ScrollingFrame.RemoteSpy
	G2L["60"] = Instance.new("TextButton", G2L["5d"]);
	G2L["60"]["BorderSizePixel"] = 0;
	G2L["60"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["60"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["60"]["TextSize"] = 14;
	G2L["60"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["60"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["60"]["Size"] = UDim2.new(0, 107, 0, 18);
	G2L["60"]["Name"] = [[RemoteSpy]];
	G2L["60"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["60"]["Text"] = [[Remote Spy]];
	G2L["60"]["Position"] = UDim2.new(0.008999999612569809, 0, 0.23982301354408264, 0);
	G2L["60"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu.Background.ScrollingFrame.UnnamedESP
	G2L["61"] = Instance.new("TextButton", G2L["5d"]);
	G2L["61"]["BorderSizePixel"] = 0;
	G2L["61"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["61"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["61"]["TextSize"] = 14;
	G2L["61"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["61"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["61"]["Size"] = UDim2.new(0, 107, 0, 18);
	G2L["61"]["Name"] = [[UnnamedESP]];
	G2L["61"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["61"]["Text"] = [[Unnamed ESP]];
	G2L["61"]["Position"] = UDim2.new(0.00917431153357029, 0, 0.11946903169155121, 0);
	G2L["61"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu.Close
	G2L["62"] = Instance.new("TextButton", G2L["5b"]);
	G2L["62"]["BorderSizePixel"] = 0;
	G2L["62"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
	G2L["62"]["TextSize"] = 14;
	G2L["62"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["62"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["62"]["Size"] = UDim2.new(0, 121, 0, 23);
	G2L["62"]["Name"] = [[Close]];
	G2L["62"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["62"]["Text"] = [[Close]];
	G2L["62"]["Position"] = UDim2.new(0.6677603721618652, 0, 7.790436744689941, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.Title
	G2L["63"] = Instance.new("TextLabel", G2L["5b"]);
	G2L["63"]["TextWrapped"] = true;
	G2L["63"]["ZIndex"] = 3;
	G2L["63"].Draggable = true;
	G2L["63"]["BorderSizePixel"] = 4;
	G2L["63"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["63"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["63"]["TextSize"] = 15;
	G2L["63"].Active = true;
	G2L["63"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["63"]["Size"] = UDim2.new(0, 410, 0, 30);
	G2L["63"]["Text"] = [[Synapse CE - Script Hub]];
	G2L["63"]["Name"] = [[Title]];
	G2L["63"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.ScriptHubMenu.Description
	G2L["64"] = Instance.new("TextLabel", G2L["5b"]);
	G2L["64"]["TextWrapped"] = true;
	G2L["64"]["BorderSizePixel"] = 0;
	G2L["64"]["TextYAlignment"] = Enum.TextYAlignment.Top;
	G2L["64"]["BackgroundColor3"] = Color3.fromRGB(30, 30, 30);
	G2L["64"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["64"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["64"]["TextSize"] = 14;
	G2L["64"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["64"]["Size"] = UDim2.new(0, 272, 0, 60);
	G2L["64"]["BorderColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["64"]["Text"] = [[]];
	G2L["64"]["Name"] = [[Description]];
	G2L["64"]["Position"] = UDim2.new(0.31386861205101013, 0, 5.612903118133545, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.Minimize
	G2L["65"] = Instance.new("TextButton", G2L["5b"]);
	G2L["65"]["ZIndex"] = 3;
	G2L["65"]["BorderSizePixel"] = 0;
	G2L["65"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
	G2L["65"]["TextSize"] = 14;
	G2L["65"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["65"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["65"]["Size"] = UDim2.new(0, 21, 0, 21);
	G2L["65"]["Name"] = [[Minimize]];
	G2L["65"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["65"]["Text"] = [[_]];
	G2L["65"]["Position"] = UDim2.new(0.9318734407424927, 0, 0.16129040718078613, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.Dex
	G2L["66"] = Instance.new("Frame", G2L["5b"]);
	G2L["66"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["66"]["BackgroundTransparency"] = 1;
	G2L["66"]["Size"] = UDim2.new(0, 100, 0, 100);
	G2L["66"]["Visible"] = false;
	G2L["66"]["Name"] = [[Dex]];

	-- StarterGui.SynapseX.ScriptHubMenu.Dex.Image
	G2L["67"] = Instance.new("ImageLabel", G2L["66"]);
	G2L["67"]["BorderSizePixel"] = 0;
	G2L["67"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["67"]["Image"] = [[http://www.roblox.com/asset/?id=7070160765]];
	G2L["67"]["Size"] = UDim2.new(0, 272, 0, 126);
	G2L["67"]["Name"] = [[Image]];
	G2L["67"]["BackgroundTransparency"] = 1;
	G2L["67"]["Position"] = UDim2.new(1.283868670463562, 0, 0.38265305757522583, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.RemoteSpy
	G2L["68"] = Instance.new("Frame", G2L["5b"]);
	G2L["68"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["68"]["BackgroundTransparency"] = 1;
	G2L["68"]["Size"] = UDim2.new(0, 100, 0, 100);
	G2L["68"]["Visible"] = false;
	G2L["68"]["Name"] = [[RemoteSpy]];

	-- StarterGui.SynapseX.ScriptHubMenu.RemoteSpy.Image
	G2L["69"] = Instance.new("ImageLabel", G2L["68"]);
	G2L["69"]["BorderSizePixel"] = 0;
	G2L["69"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["69"]["Image"] = [[http://www.roblox.com/asset/?id=7370616106]];
	G2L["69"]["Size"] = UDim2.new(0, 272, 0, 126);
	G2L["69"]["Name"] = [[Image]];
	G2L["69"]["BackgroundTransparency"] = 1;
	G2L["69"]["Position"] = UDim2.new(1.283868670463562, 0, 0.38265305757522583, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.UnnamedESP
	G2L["6a"] = Instance.new("Frame", G2L["5b"]);
	G2L["6a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6a"]["BackgroundTransparency"] = 1;
	G2L["6a"]["Size"] = UDim2.new(0, 100, 0, 100);
	G2L["6a"]["Visible"] = false;
	G2L["6a"]["Name"] = [[UnnamedESP]];

	-- StarterGui.SynapseX.ScriptHubMenu.UnnamedESP.Image
	G2L["6b"] = Instance.new("ImageLabel", G2L["6a"]);
	G2L["6b"]["BorderSizePixel"] = 0;
	G2L["6b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6b"]["Image"] = [[http://www.roblox.com/asset/?id=7370616607]];
	G2L["6b"]["Size"] = UDim2.new(0, 272, 0, 126);
	G2L["6b"]["Name"] = [[Image]];
	G2L["6b"]["BackgroundTransparency"] = 1;
	G2L["6b"]["Position"] = UDim2.new(1.283868670463562, 0, 0.38265305757522583, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.ScriptDumper
	G2L["6c"] = Instance.new("Frame", G2L["5b"]);
	G2L["6c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6c"]["BackgroundTransparency"] = 1;
	G2L["6c"]["Size"] = UDim2.new(0, 100, 0, 100);
	G2L["6c"]["Visible"] = false;
	G2L["6c"]["Name"] = [[ScriptDumper]];

	-- StarterGui.SynapseX.ScriptHubMenu.ScriptDumper.Image
	G2L["6d"] = Instance.new("ImageLabel", G2L["6c"]);
	G2L["6d"]["BorderSizePixel"] = 0;
	G2L["6d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6d"]["Image"] = [[http://www.roblox.com/asset/?id=7370669353]];
	G2L["6d"]["Size"] = UDim2.new(0, 272, 0, 126);
	G2L["6d"]["Name"] = [[Image]];
	G2L["6d"]["BackgroundTransparency"] = 1;
	G2L["6d"]["Position"] = UDim2.new(1.283868670463562, 0, 0.38265305757522583, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.Icon
	G2L["6e"] = Instance.new("ImageLabel", G2L["5b"]);
	G2L["6e"]["ZIndex"] = 6;
	G2L["6e"]["BorderSizePixel"] = 0;
	G2L["6e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["6e"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["6e"]["Size"] = UDim2.new(0, 23, 0, 26);
	G2L["6e"]["Name"] = [[Icon]];
	G2L["6e"]["BackgroundTransparency"] = 1;
	G2L["6e"]["Position"] = UDim2.new(0.00932147353887558, 0, 0.05000000074505806, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.Panel
	G2L["6f"] = Instance.new("Frame", G2L["5b"]);
	G2L["6f"]["BorderSizePixel"] = 0;
	G2L["6f"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
	G2L["6f"]["Size"] = UDim2.new(0, 411, 0, 30);
	G2L["6f"]["Position"] = UDim2.new(0, 0, -0.009731169790029526, 0);
	G2L["6f"]["Name"] = [[Panel]];

	-- StarterGui.SynapseX.ScriptHubMenu.Execute
	G2L["70"] = Instance.new("TextButton", G2L["5b"]);
	G2L["70"]["BorderSizePixel"] = 0;
	G2L["70"]["BackgroundColor3"] = Color3.fromRGB(60, 60, 60);
	G2L["70"]["TextSize"] = 14;
	G2L["70"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["70"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["70"]["Visible"] = false;
	G2L["70"]["Size"] = UDim2.new(0, 121, 0, 23);
	G2L["70"]["Name"] = [[Execute]];
	G2L["70"]["BorderColor3"] = Color3.fromRGB(99, 150, 182);
	G2L["70"]["Text"] = [[Execute]];
	G2L["70"]["Position"] = UDim2.new(0.31386861205101013, 0, 7.764839172363281, 0);

	-- StarterGui.SynapseX.ScriptHubMenu.ScriptHubHandler
	G2L["71"] = Instance.new("LocalScript", G2L["5b"]);
	G2L["71"]["Name"] = [[ScriptHubHandler]];

	-- StarterGui.SynapseX.OptionMenu
	G2L["72"] = Instance.new("Frame", G2L["1"]);
	G2L["72"]["Active"] = true;
	G2L["72"]["ZIndex"] = 5;
	G2L["72"]["BorderSizePixel"] = 0;
	G2L["72"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["72"]["Size"] = UDim2.new(0, 199, 0, 31);
	G2L["72"]["Position"] = UDim2.new(0, 671, 0, 16);
	G2L["72"]["Visible"] = false;
	G2L["72"]["Name"] = [[OptionMenu]];

	-- StarterGui.SynapseX.OptionMenu.Title
	G2L["73"] = Instance.new("TextLabel", G2L["72"]);
	G2L["73"]["ZIndex"] = 6;
	G2L["73"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["73"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["73"]["TextSize"] = 14;
	G2L["73"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["73"]["Size"] = UDim2.new(0, 199, 0, 26);
	G2L["73"]["Text"] = [[Options]];
	G2L["73"]["Name"] = [[Title]];
	G2L["73"]["BackgroundTransparency"] = 1;
	G2L["73"]["Position"] = UDim2.new(-0.0011280769249424338, 0, 0.07083868235349655, 0);

	-- StarterGui.SynapseX.OptionMenu.FPSUnlocker
	G2L["74"] = Instance.new("TextLabel", G2L["72"]);
	G2L["74"]["ZIndex"] = 6;
	G2L["74"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["74"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["74"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["74"]["TextSize"] = 14;
	G2L["74"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["74"]["Size"] = UDim2.new(0, 63, 0, 16);
	G2L["74"]["Text"] = 'FPS Unlock [BETA]';
	G2L["74"]["Name"] = [[FPSUnlocker]];
	G2L["74"]["BackgroundTransparency"] = 1;
	G2L["74"]["Position"] = UDim2.new(0.35585591197013855, 0, 1.5485485792160034, 0);

	-- StarterGui.SynapseX.OptionMenu.TopMost
	G2L["75"] = Instance.new("TextLabel", G2L["72"]);
	G2L["75"]["ZIndex"] = 6;
	G2L["75"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["75"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["75"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["75"]["TextSize"] = 14;
	G2L["75"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["75"]["Size"] = UDim2.new(0, 63, 0, 16);
	G2L["75"]["Text"] = [[TopMost]];
	G2L["75"]["Name"] = [[TopMost]];
	G2L["75"]["BackgroundTransparency"] = 1;
	G2L["75"]["Position"] = UDim2.new(0.35585591197013855, 0, 3.7420969009399414, 0);

	-- StarterGui.SynapseX.OptionMenu.InternalUI
	G2L["76"] = Instance.new("TextLabel", G2L["72"]);
	G2L["76"]["ZIndex"] = 6;
	G2L["76"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["76"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["76"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["76"]["TextSize"] = 14;
	G2L["76"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["76"]["Size"] = UDim2.new(0, 63, 0, 16);
	G2L["76"]["Text"] = [[Internal UI]];
	G2L["76"]["Name"] = [[InternalUI]];
	G2L["76"]["BackgroundTransparency"] = 1;
	G2L["76"]["Position"] = UDim2.new(0.35585591197013855, 0, 3.0001611709594727, 0);

	-- StarterGui.SynapseX.OptionMenu.Close
	G2L["77"] = Instance.new("TextButton", G2L["72"]);
	G2L["77"]["ZIndex"] = 6;
	G2L["77"]["BorderSizePixel"] = 0;
	G2L["77"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["77"]["TextSize"] = 14;
	G2L["77"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["77"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["77"]["Size"] = UDim2.new(0, 178, 0, 25);
	G2L["77"]["Name"] = [[Close]];
	G2L["77"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["77"]["Text"] = [[Close]];
	G2L["77"]["Position"] = UDim2.new(0.04838477447628975, 0, 6.747819900512695, 0);

	-- StarterGui.SynapseX.OptionMenu.ToggleFPSUnlocker
	G2L["78"] = Instance.new("TextButton", G2L["72"]);
	G2L["78"]["TextWrapped"] = true;
	G2L["78"]["ZIndex"] = 6;
	G2L["78"]["BorderSizePixel"] = 0;
	G2L["78"]["BackgroundColor3"] = Color3.fromRGB(167, 167, 167);
	G2L["78"]["TextSize"] = 13;
	G2L["78"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["78"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["78"]["Size"] = UDim2.new(0, 14, 0, 14);
	G2L["78"]["Name"] = [[ToggleFPSUnlocker]];
	G2L["78"]["Text"] = [[]];
	G2L["78"]["Position"] = UDim2.new(0.24308274686336517, 0, 1.5808066129684448, 0);

	-- StarterGui.SynapseX.OptionMenu.ToggleInternalUI
	G2L["79"] = Instance.new("TextButton", G2L["72"]);
	G2L["79"]["TextWrapped"] = true;
	G2L["79"]["ZIndex"] = 6;
	G2L["79"]["BorderSizePixel"] = 0;
	G2L["79"]["BackgroundColor3"] = Color3.fromRGB(113, 113, 113);
	G2L["79"]["TextSize"] = 13;
	G2L["79"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["79"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["79"]["Size"] = UDim2.new(0, 14, 0, 14);
	G2L["79"]["Name"] = [[ToggleInternalUI]];
	G2L["79"]["Text"] = [[x]];
	G2L["79"]["Position"] = UDim2.new(0.24308274686336517, 0, 3.032419204711914, 0);

	-- StarterGui.SynapseX.OptionMenu.ToggleTopMost
	G2L["7a"] = Instance.new("TextButton", G2L["72"]);
	G2L["7a"]["TextWrapped"] = true;
	G2L["7a"]["ZIndex"] = 6;
	G2L["7a"]["BorderSizePixel"] = 0;
	G2L["7a"]["BackgroundColor3"] = Color3.fromRGB(113, 113, 113);
	G2L["7a"]["TextSize"] = 13;
	G2L["7a"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["7a"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["7a"]["Size"] = UDim2.new(0, 14, 0, 14);
	G2L["7a"]["Name"] = [[ToggleTopMost]];
	G2L["7a"]["Text"] = [[x]];
	G2L["7a"]["Position"] = UDim2.new(0.24308274686336517, 0, 3.774354934692383, 0);

	-- StarterGui.SynapseX.OptionMenu.Icon
	G2L["7b"] = Instance.new("ImageLabel", G2L["72"]);
	G2L["7b"]["ZIndex"] = 6;
	G2L["7b"]["BorderSizePixel"] = 0;
	G2L["7b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["7b"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["7b"]["Size"] = UDim2.new(0, 23, 0, 26);
	G2L["7b"]["Name"] = [[Icon]];
	G2L["7b"]["BackgroundTransparency"] = 1;
	G2L["7b"]["Position"] = UDim2.new(0.014999999664723873, 0, 0.057999998331069946, 0);

	-- StarterGui.SynapseX.OptionMenu.ToggleAutoExec
	G2L["7c"] = Instance.new("TextButton", G2L["72"]);
	G2L["7c"]["TextWrapped"] = true;
	G2L["7c"]["ZIndex"] = 6;
	G2L["7c"]["BorderSizePixel"] = 0;
	G2L["7c"]["BackgroundColor3"] = Color3.fromRGB(167, 167, 167);
	G2L["7c"]["TextSize"] = 13;
	G2L["7c"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["7c"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
	G2L["7c"]["Size"] = UDim2.new(0, 14, 0, 14);
	G2L["7c"]["Name"] = [[ToggleAutoExec]];
	G2L["7c"]["Text"] = [[]];
	G2L["7c"]["Position"] = UDim2.new(0.24308274686336517, 0, 2.2904839515686035, 0);

	-- StarterGui.SynapseX.OptionMenu.AutoExec
	G2L["7d"] = Instance.new("TextLabel", G2L["72"]);
	G2L["7d"]["ZIndex"] = 6;
	G2L["7d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["7d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
	G2L["7d"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["7d"]["TextSize"] = 14;
	G2L["7d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["7d"]["Size"] = UDim2.new(0, 63, 0, 16);
	G2L["7d"]["Text"] = [[Auto Exec scripts]];
	G2L["7d"]["Name"] = [[AutoExec]];
	G2L["7d"]["BackgroundTransparency"] = 1;
	G2L["7d"]["Position"] = UDim2.new(0.35585591197013855, 0, 2.258225917816162, 0);

	-- StarterGui.SynapseX.OptionMenu.Buttons
	G2L["7e"] = Instance.new("Frame", G2L["72"]);
	G2L["7e"]["ZIndex"] = 6;
	G2L["7e"]["BorderSizePixel"] = 0;
	G2L["7e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["7e"]["BackgroundTransparency"] = 1;
	G2L["7e"]["Size"] = UDim2.new(0, 176, 0, 58);
	G2L["7e"]["Position"] = UDim2.new(0.05500003695487976, 0, 4.516129493713379, 0);
	G2L["7e"]["Name"] = [[Buttons]];

	-- StarterGui.SynapseX.OptionMenu.Buttons.UIListLayout
	G2L["7f"] = Instance.new("UIListLayout", G2L["7e"]);
	G2L["7f"]["Padding"] = UDim.new(0, 5);
	G2L["7f"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

	-- StarterGui.SynapseX.OptionMenu.Buttons.Rejoin
	G2L["80"] = Instance.new("TextButton", G2L["7e"]);
	G2L["80"]["ZIndex"] = 6;
	G2L["80"]["BorderSizePixel"] = 0;
	G2L["80"]["Modal"] = true;
	G2L["80"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["80"]["TextSize"] = 14;
	G2L["80"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["80"]["TextColor3"] = Color3.fromRGB(251, 251, 251);
	G2L["80"]["Size"] = UDim2.new(0, 177, 0, 17);
	G2L["80"]["Name"] = [[Rejoin]];
	G2L["80"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["80"]["Text"] = [[Rejoin]];
	G2L["80"]["Position"] = UDim2.new(0.054999999701976776, 0, 5.838741779327393, 0);

	-- StarterGui.SynapseX.OptionMenu.Buttons.Discord
	G2L["81"] = Instance.new("TextButton", G2L["7e"]);
	G2L["81"]["ZIndex"] = 6;
	G2L["81"]["BorderSizePixel"] = 0;
	G2L["81"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["81"]["TextSize"] = 14;
	G2L["81"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["81"]["TextColor3"] = Color3.fromRGB(251, 251, 251);
	G2L["81"]["Size"] = UDim2.new(0, 177, 0, 17);
	G2L["81"]["Name"] = [[Discord]];
	G2L["81"]["BorderColor3"] = Color3.fromRGB(0, 231, 255);
	G2L["81"]["Text"] = [[Discord]];
	G2L["81"]["Position"] = UDim2.new(0.054999999701976776, 0, 5.838741779327393, 0);

	-- StarterGui.SynapseX.OptionMenu.MainFrame
	G2L["82"] = Instance.new("Frame", G2L["72"]);
	G2L["82"]["ZIndex"] = 5;
	G2L["82"]["BorderSizePixel"] = 0;
	G2L["82"]["BackgroundColor3"] = Color3.fromRGB(52, 52, 52);
	G2L["82"]["Size"] = UDim2.new(0, 199, 0, 211);
	G2L["82"]["Position"] = UDim2.new(0, 0, 0.988335907459259, 0);
	G2L["82"]["Name"] = [[MainFrame]];

	-- StarterGui.SynapseX.OptionMenu.Optionhandler
	G2L["83"] = Instance.new("LocalScript", G2L["72"]);
	G2L["83"]["Name"] = [[Optionhandler]];

	-- StarterGui.SynapseX.GetSavedScripts
	G2L["84"] = Instance.new("LocalScript", G2L["1"]);
	G2L["84"]["Name"] = [[GetSavedScripts]];

	-- StarterGui.SynapseX.Injected
	G2L["85"] = Instance.new("BoolValue", G2L["1"]);
	G2L["85"]["Name"] = [[Injected]];

	-- StarterGui.SynapseX.Module
	G2L["86"] = Instance.new("ModuleScript", G2L["1"]);
	G2L["86"]["Name"] = [[Module]];

	-- StarterGui.SynapseX.Module.RClick
	G2L["87"] = Instance.new("Frame", G2L["86"]);
	G2L["87"]["ZIndex"] = 7;
	G2L["87"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 44);
	G2L["87"]["Size"] = UDim2.new(0, 94, 0, 63);
	G2L["87"]["BorderColor3"] = Color3.fromRGB(119, 119, 119);
	G2L["87"]["Position"] = UDim2.new(-0.0146878557279706, 0, 1.0666667222976685, 0);
	G2L["87"]["Visible"] = false;
	G2L["87"]["Name"] = [[RClick]];

	-- StarterGui.SynapseX.Module.RClick.Execute
	G2L["88"] = Instance.new("TextButton", G2L["87"]);
	G2L["88"]["ZIndex"] = 7;
	G2L["88"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 44);
	G2L["88"]["TextSize"] = 14;
	G2L["88"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["88"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["88"]["Size"] = UDim2.new(0, 93, 0, 21);
	G2L["88"]["Name"] = [[Execute]];
	G2L["88"]["BorderColor3"] = Color3.fromRGB(119, 119, 119);
	G2L["88"]["Text"] = [[Execute]];
	G2L["88"]["Position"] = UDim2.new(0.005026959348469973, 0, 0, 0);

	-- StarterGui.SynapseX.Module.RClick.Load
	G2L["89"] = Instance.new("TextButton", G2L["87"]);
	G2L["89"]["ZIndex"] = 7;
	G2L["89"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 44);
	G2L["89"]["TextSize"] = 14;
	G2L["89"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["89"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["89"]["Size"] = UDim2.new(0, 93, 0, 21);
	G2L["89"]["Name"] = [[Load]];
	G2L["89"]["BorderColor3"] = Color3.fromRGB(119, 119, 119);
	G2L["89"]["Text"] = [[Load into Editor]];
	G2L["89"]["Position"] = UDim2.new(0.005026959348469973, 0, 0.3174603283405304, 0);

	-- StarterGui.SynapseX.Module.RClick.Delete
	G2L["8a"] = Instance.new("TextButton", G2L["87"]);
	G2L["8a"]["ZIndex"] = 7;
	G2L["8a"]["BackgroundColor3"] = Color3.fromRGB(44, 44, 44);
	G2L["8a"]["TextSize"] = 14;
	G2L["8a"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["8a"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8a"]["Size"] = UDim2.new(0, 93, 0, 21);
	G2L["8a"]["Name"] = [[Delete]];
	G2L["8a"]["BorderColor3"] = Color3.fromRGB(119, 119, 119);
	G2L["8a"]["Text"] = [[Delete]];
	G2L["8a"]["Position"] = UDim2.new(0.005026959348469973, 0, 0.6666666865348816, 0);

	-- StarterGui.SynapseX.OpenScript
	G2L["8b"] = Instance.new("Frame", G2L["1"]);
	G2L["8b"]["Active"] = true;
	G2L["8b"]["ZIndex"] = 10;
	G2L["8b"]["BorderSizePixel"] = 0;
	G2L["8b"]["BackgroundColor3"] = Color3.fromRGB(61, 61, 61);
	G2L["8b"]["Size"] = UDim2.new(0, 322, 0, 81);
	G2L["8b"]["Position"] = UDim2.new(0.2866109609603882, 0, 0.5302865505218506, 0);
	G2L["8b"]["Visible"] = false;
	G2L["8b"]["Name"] = [[OpenScript]];

	-- StarterGui.SynapseX.OpenScript.scriptname
	G2L["8c"] = Instance.new("TextBox", G2L["8b"]);
	G2L["8c"]["ZIndex"] = 11;
	G2L["8c"]["BorderSizePixel"] = 0;
	G2L["8c"]["TextSize"] = 14;
	G2L["8c"]["BackgroundColor3"] = Color3.fromRGB(41, 41, 41);
	G2L["8c"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["8c"]["PlaceholderText"] = [[File Name]];
	G2L["8c"]["Size"] = UDim2.new(0, 317, 0, 22);
	G2L["8c"]["Text"] = [[]];
	G2L["8c"]["Position"] = UDim2.new(0, 3, 0, 32);
	G2L["8c"]["Name"] = [[scriptname]];

	-- StarterGui.SynapseX.OpenScript.savescript
	G2L["8d"] = Instance.new("TextButton", G2L["8b"]);
	G2L["8d"]["ZIndex"] = 11;
	G2L["8d"]["BorderSizePixel"] = 0;
	G2L["8d"]["BackgroundColor3"] = Color3.fromRGB(46, 46, 46);
	G2L["8d"]["TextSize"] = 14;
	G2L["8d"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["8d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8d"]["Size"] = UDim2.new(0, 317, 0, 19);
	G2L["8d"]["Name"] = [[savescript]];
	G2L["8d"]["Text"] = [[Open FIle]];
	G2L["8d"]["Position"] = UDim2.new(0, 3, 0, 56);

	-- StarterGui.SynapseX.OpenScript.Icon
	G2L["8e"] = Instance.new("ImageLabel", G2L["8b"]);
	G2L["8e"]["ZIndex"] = 11;
	G2L["8e"]["BorderSizePixel"] = 0;
	G2L["8e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["8e"]["Image"] = [[http://www.roblox.com/asset/?id=9483813933]];
	G2L["8e"]["Size"] = UDim2.new(0, 48, 0, 23);
	G2L["8e"]["Name"] = [[Icon]];
	G2L["8e"]["BackgroundTransparency"] = 1;
	G2L["8e"]["Position"] = UDim2.new(0.008999999612569809, 0, 0.05000000074505806, 0);

	-- StarterGui.SynapseX.OpenScript.Icon.UIAspectRatioConstraint
	G2L["8f"] = Instance.new("UIAspectRatioConstraint", G2L["8e"]);
	G2L["8f"]["AspectRatio"] = 0.8846153616905212;

	-- StarterGui.SynapseX.OpenScript.Title
	G2L["90"] = Instance.new("TextLabel", G2L["8b"]);
	G2L["90"]["TextWrapped"] = true;
	G2L["90"]["ZIndex"] = 11;
	G2L["90"]["BorderSizePixel"] = 4;
	G2L["90"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["90"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["90"]["TextSize"] = 15;
	G2L["90"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["90"]["Size"] = UDim2.new(0, 322, 0, 30);
	G2L["90"]["Active"] = true;
	G2L["90"]["Text"] = [[Synapse CE - Open FIle]];
	G2L["90"]["Name"] = [[Title]];
	G2L["90"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.OpenScript.Close
	G2L["91"] = Instance.new("TextButton", G2L["8b"]);
	G2L["91"]["TextWrapped"] = true;
	G2L["91"]["ZIndex"] = 12;
	G2L["91"]["BackgroundColor3"] = Color3.fromRGB(0, 55, 81);
	G2L["91"]["TextSize"] = 17;
	G2L["91"]["FontFace"] = Font.new([[rbxasset://fonts/families/Arial.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
	G2L["91"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
	G2L["91"]["Selectable"] = false;
	G2L["91"]["Size"] = UDim2.new(0, 26, 0, 26);
	G2L["91"]["Name"] = [[Close]];
	G2L["91"]["Text"] = [[x]];
	G2L["91"]["Position"] = UDim2.new(0.9130434989929199, 0, 0.024690981954336166, 0);
	G2L["91"]["BackgroundTransparency"] = 1;

	-- StarterGui.SynapseX.OpenScript.Handler
	G2L["92"] = Instance.new("LocalScript", G2L["8b"]);
	G2L["92"]["Name"] = [[Handler]];

	-- StarterGui.SynapseX.SetDraggable
	G2L["93"] = Instance.new("LocalScript", G2L["1"]);
	G2L["93"]["Name"] = [[SetDraggable]];

	-- StarterGui.SynapseX.Highlighter
	G2L["94"] = Instance.new("ModuleScript", G2L["1"]);
	G2L["94"]["Name"] = [[Highlighter]];

	-- StarterGui.SynapseX.Highlighter.lexer
	G2L["95"] = Instance.new("ModuleScript", G2L["94"]);
	G2L["95"]["Name"] = [[lexer]];

	-- StarterGui.SynapseX.Highlighter.lexer.language
	G2L["96"] = Instance.new("ModuleScript", G2L["95"]);
	G2L["96"]["Name"] = [[language]];

	-- Require G2L wrapper
	local G2L_REQUIRE = require;
	local G2L_MODULES = {};
	local function require(Module:ModuleScript)
		local ModuleState = G2L_MODULES[Module];
		if ModuleState then
			if not ModuleState.Required then
				ModuleState.Required = true;
				ModuleState.Value = ModuleState.Closure();
			end
			return ModuleState.Value;
		end;
		return G2L_REQUIRE(Module);
	end

	G2L_MODULES[G2L["86"]] = {
		Closure = function()
			local script = G2L["86"];
			local module = {}
			local highlighter = require(script.Parent.Highlighter)

			function module:AddTab(title, source)
				local NewTextbox = script.Parent.Main.MainFunc.Needs.Textbox:Clone()
				local NewTab = script.Parent.Main.MainFunc.Needs.Tab:Clone()
				local num = 0

				NewTextbox.Parent = script.Parent.Main.MainFunc.Textboxes
				NewTab.Parent=  script.Parent.Main.ScriptTab.Tabs
				NewTab.Visible = true
				NewTextbox.Visible = true
				NewTab.BackgroundColor3 = Color3.fromRGB(80,80,80)
				highlighter.highlight({
					textObject = NewTextbox.Frame.Textbox,
					src = NewTextbox.Frame.Textbox.Text,
					forceUpdate = true
				})

				NewTab.MouseButton1Up:Connect(function()

					-- Set any textbox except new disabled (not visible)
					for _,tabs in pairs(script.Parent.Main.MainFunc.Textboxes:GetChildren()) do
						if tabs.Name ~= NewTextbox.Name then
							tabs.Visible = false
						elseif tabs.Name == NewTextbox.Name then
							tabs.Visible = true
						end
					end

					-- Set any Tab color back except this
					for i,v in pairs(script.Parent:GetChildren()) do
						if v:IsA("TextButton") and v.Name ~= NewTab.Name then
							v.BackgroundColor3 = Color3.fromRGB(100,100,100)
						end
					end

				end)
				NewTab:FindFirstChild("Remove").MouseButton1Up:Connect(function()

					NewTab:Destroy()


				end)

				-- Set da name as yes
				for i,v in pairs(script.Parent.Main.MainFunc.Textboxes:GetChildren()) do
					num += 1
				end
				if type(title) == "string" then
					NewTab.Name = '  '..title
					NewTab.Text = '  '..title
					NewTextbox.Name = '  '..title
					NewTextbox.Frame.Textbox.Text = source
				else
					NewTab.Name = "  Script "..tostring(num)
					NewTab.Text = "  Script "..tostring(num)
					NewTextbox.Name = "  Script "..tostring(num)
				end

				-- Set any textbox except new disabled (not visible)
				for _,tabs in pairs(script.Parent.Main.MainFunc.Textboxes:GetChildren()) do
					if tabs.Name ~= NewTextbox.Name then
						tabs.Visible = false
					end
				end

				-- Set any Tab color back except this
				for i,v in pairs(script.Parent:GetChildren()) do
					if v:IsA("TextButton") and v.Name ~= NewTab.Name then
						v.BackgroundColor3 = Color3.fromRGB(100,100,100)
					end
				end
			end

			function module:GetActiveTextbox()
				for _, textbox in pairs(script.Parent.Main.MainFunc.Textboxes:GetChildren()) do
					if textbox.Visible then
						return textbox
					end
				end
			end

			function module:AddScriptTabSave(name, source)
				local Button = script.Parent.Main.MainFunc.Needs.ScriptHubButton:Clone()
				local click = false
				Button.Parent = script.Parent.Main.MainFunc.ScriptHub
				Button.Text = name
				Button.Visible = true

				Button.MouseButton1Up:Connect(function()
					if not click then
						click = true
						wait(0.5) -- Adjust this delay if needed
						if click then
							module:AddTab(name, source)
						end
						click = false
					end
				end)
				Button.MouseButton2Up:Connect(function()
					local rclick = script.RClick:Clone()
					rclick.Visible = true
					rclick.Parent = Button
					rclick.MouseEnter:Connect(function()
						rclick.Execute.MouseButton1Up:Connect(function()
							local sourcewglobals = globals .. "\n\n" .. source


							sandbox.environment.global.loadstring(sourcewglobals)()
						end)
						rclick.Load.MouseButton1Up:Connect(function()
							module:AddTab(name, source)
						end)
						rclick.Delete.MouseButton1Up:Connect(function()
							rclick.Parent:Destroy()
						end)
						rclick.MouseLeave:Connect(function()
							rclick:Destroy()
						end)
					end)
				end)
			end

			return module

		end;
	};
	G2L_MODULES[G2L["94"]] = {
		Closure = function()
			local script = G2L["94"];
			export type HighlighterColors = { [string]: Color3 }

			export type TextObject = TextLabel | TextBox

			export type HighlightProps = {
				textObject: TextObject,
				src: string?,
				forceUpdate: boolean?,
				lexer: Lexer?,
				customLang: { [string]: string }?
			}

			export type Lexer = {
				scan: (src: string) -> () -> (string, string),
				navigator: () -> any,
				finished: boolean?,
			}

			export type Highlighter = {
				defaultLexer: Lexer,
				setTokenColors: (colors: HighlighterColors?) -> (),
				highlight: (props: HighlightProps) -> (() -> ())?,
				refresh: () -> (),
			}

			export type ObjectData = {
				Text: string,
				Labels: { TextLabel },
				Lines: { string },
				Lexer: Lexer?,
				CustomLang: { [string]: string }?,
			}

			local function SanitizeRichText(s: string): string
				return string.gsub(
					string.gsub(string.gsub(string.gsub(string.gsub(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"), '"', "&quot;"),
					"'",
					"&apos;"
				)
			end

			local function SanitizeTabs(s: string): string
				return string.gsub(s, "\t", "    ")
			end

			local function SanitizeControl(s: string): string
				return string.gsub(s, "[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+", "")
			end

			local TokenColors: HighlighterColors = {
				["background"] = Color3.fromRGB(41, 41, 41),
				["iden"] = Color3.fromRGB(234, 234, 234),
				["keyword"] = Color3.fromRGB(215, 174, 255),
				["builtin"] = Color3.fromRGB(131, 206, 255),
				["string"] = Color3.fromRGB(196, 255, 193),
				["number"] = Color3.fromRGB(255, 125, 125),
				["comment"] = Color3.fromRGB(140, 140, 155),
				["operator"] = Color3.fromRGB(255, 239, 148),
				["custom"] = Color3.fromRGB(119, 122, 255),
			}
			local ColorFormatter: { [Color3]: string } = {}
			local LastData: { [TextObject]: ObjectData } = {}
			local Cleanups: { [TextObject]: () -> () } = {}

			local Highlighter = {
				defaultLexer = require(script.lexer),
			}

			function Highlighter.highlight(props: HighlightProps)
				-- Gather props
				local textObject = props.textObject
				local src = SanitizeTabs(SanitizeControl(props.src or textObject.Text))
				local lexer = props.lexer or Highlighter.defaultLexer
				local customLang = props.customLang
				local forceUpdate = props.forceUpdate

				-- Avoid updating when unnecessary
				local data = LastData[textObject]
				if data == nil then
					data = {
						Text = "",
						Labels = {},
						Lines = {},
						Lexer = lexer,
						CustomLang = customLang,
					}
					LastData[textObject] = data
				elseif forceUpdate ~= true and data.Text == src then
					return
				end

				local lineLabels = data.Labels
				local previousLines = data.Lines

				local lines = string.split(src, "\n")

				data.Lines = lines
				data.Text = src
				data.Lexer = lexer
				data.CustomLang = customLang

				-- Ensure valid object properties
				textObject.RichText = false
				textObject.Text = src
				textObject.TextXAlignment = Enum.TextXAlignment.Left
				textObject.TextYAlignment = Enum.TextYAlignment.Top
				textObject.BackgroundColor3 = TokenColors.background
				textObject.TextColor3 = TokenColors.iden
				textObject.TextTransparency = 0.5

				-- Build the highlight labels
				local lineFolder = textObject:FindFirstChild("SyntaxHighlights")
				if lineFolder == nil then
					local newLineFolder = Instance.new("Folder")
					newLineFolder.Name = "SyntaxHighlights"
					newLineFolder.Parent = textObject

					lineFolder = newLineFolder
				end

				-- Add a cleanup handler for this textObject
				local cleanup = Cleanups[textObject]
				if not cleanup then
					local connections: { RBXScriptConnection } = {}
					local function newCleanup()
						for _, label in ipairs(lineLabels) do
							label:Destroy()
						end
						table.clear(lineLabels)
						lineLabels = nil

						LastData[textObject] = nil
						Cleanups[textObject] = nil

						for _, connection in connections do
							connection:Disconnect()
						end
						table.clear(connections)
						connections = nil
					end
					Cleanups[textObject] = newCleanup
					cleanup = newCleanup

					table.insert(
						connections,
						textObject.AncestryChanged:Connect(function()
							if textObject.Parent then
								return
							end

							cleanup()
						end)
					)
					table.insert(
						connections,
						textObject:GetPropertyChangedSignal("TextBounds"):Connect(function()
							Highlighter.highlight({
								textObject = textObject,
								forceUpdate = true,
								lexer = lexer,
								customLang = customLang,
							})
						end)
					)
					table.insert(
						connections,
						textObject:GetPropertyChangedSignal("Text"):Connect(function()
							Highlighter.highlight({
								textObject = textObject,
								lexer = lexer,
								customLang = customLang,
							})
						end)
					)
					table.insert(
						connections,
						textObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
							Highlighter.highlight({
								textObject = textObject,
								forceUpdate = true,
								lexer = lexer,
								customLang = customLang,
							})
						end)
					)
				end

				-- Shortcut empty labels
				if src == "" then
					for l=1, #lineLabels do
						if lineLabels[l].Text == "" then continue end
						lineLabels[l].Text = ""
					end
					return cleanup
				end

				-- Wait for TextBounds to be non-NaN and non-zero because Roblox
				local textBounds = textObject.TextBounds
				while (textBounds.Y ~= textBounds.Y) or (textBounds.Y < 1) do
					task.wait()
					textBounds = textObject.TextBounds
				end

				if LastData[textObject] == nil then
					-- Got cleaned up while we were waiting
					return cleanup
				end

				local numLines = #lines
				local textHeight = textBounds.Y / numLines * textObject.LineHeight

				local richText, index, lineNumber = table.create(5), 0, 1
				for token: string, content: string in lexer.scan(src) do
					local Color =
						if customLang and customLang[content] then
						TokenColors["custom"]
						else
						TokenColors[token] or TokenColors["iden"]

					local tokenLines = string.split(SanitizeRichText(content), "\n")

					for l, line in ipairs(tokenLines) do
						-- Find line label
						local lineLabel = lineLabels[lineNumber]
						if not lineLabel then
							local newLabel = Instance.new("TextLabel")
							newLabel.Name = "Line_" .. lineNumber
							newLabel.RichText = true
							newLabel.BackgroundTransparency = 1
							newLabel.ZIndex = 4
							newLabel.Text = ""
							newLabel.TextXAlignment = Enum.TextXAlignment.Left
							newLabel.TextYAlignment = Enum.TextYAlignment.Top
							newLabel.Parent = lineFolder
							lineLabels[lineNumber] = newLabel
							lineLabel = newLabel
						end

						-- Align line label
						lineLabel.TextColor3 = TokenColors["iden"]
						lineLabel.Font = textObject.Font
						lineLabel.TextSize = textObject.TextSize
						lineLabel.Size = UDim2.new(1, 0, 0, math.ceil(textHeight))
						lineLabel.Position = UDim2.fromScale(0, textHeight * (lineNumber - 1) / textObject.AbsoluteSize.Y)

						-- If multiline token, then set line & move to next
						if l > 1 then
							if forceUpdate or lines[lineNumber] ~= previousLines[lineNumber] then
								-- Set line
								lineLabels[lineNumber].Text = table.concat(richText)
							end
							-- Move to next line
							lineNumber += 1
							index = 0
							table.clear(richText)
						end

						-- If changed, add token to line
						if forceUpdate or lines[lineNumber] ~= previousLines[lineNumber] then
							index += 1
							-- Only add RichText tags when the color is non-default and the characters are non-whitespace
							if Color ~= TokenColors["iden"] and string.find(line, "[%S%C]") then
								richText[index] = string.format(ColorFormatter[Color], line)
							else
								richText[index] = line
							end
						end
					end
				end

				-- Set final line
				if richText[1] and lineLabels[lineNumber] then
					lineLabels[lineNumber].Text = table.concat(richText)
				end

				-- Clear unused line labels
				for l=lineNumber+1, #lineLabels do
					if lineLabels[l].Text == "" then continue end
					lineLabels[l].Text = ""
				end

				return cleanup
			end

			function Highlighter.refresh(): ()
				-- Rehighlight existing labels using latest colors
				for textObject, data in pairs(LastData) do
					for _, lineLabel in ipairs(data.Labels) do
						lineLabel.TextColor3 = TokenColors["iden"]
					end

					Highlighter.highlight({
						textObject = textObject,
						forceUpdate = true,
						src = data.Text,
						lexer = data.Lexer,
						customLang = data.CustomLang,
					})
				end
			end

			function Highlighter.setTokenColors(colors: HighlighterColors)
				for token, color in colors do
					TokenColors[token] = color
					ColorFormatter[color] = string.format(
						'<font color="#%.2x%.2x%.2x">',
						color.R * 255,
						color.G * 255,
						color.B * 255
					) .. "%s</font>"
				end

				Highlighter.refresh()
			end
			Highlighter.setTokenColors(TokenColors)

			return Highlighter :: Highlighter

		end;
	};
	G2L_MODULES[G2L["95"]] = {
		Closure = function()
			local script = G2L["95"];
--[=[
	Lexical scanner for creating a sequence of tokens from Lua source code.
	This is a heavily modified and Roblox-optimized version of
	the original Penlight Lexer module:
		https://github.com/stevedonovan/Penlight
	Authors:
		stevedonovan <https://github.com/stevedonovan> ----------- Original Penlight lexer author
		ryanjmulder <https://github.com/ryanjmulder> ------------- Penlight lexer contributer
		mpeterv <https://github.com/mpeterv> --------------------- Penlight lexer contributer
		Tieske <https://github.com/Tieske> ----------------------- Penlight lexer contributer
		boatbomber <https://github.com/boatbomber> --------------- Roblox port, added builtin token,
		                                                           added patterns for incomplete syntax, bug fixes,
		                                                           behavior changes, token optimization, thread optimization
		                                                           Added lexer.navigator() for non-sequential reads
		Sleitnick <https://github.com/Sleitnick> ----------------- Roblox optimizations
		howmanysmall <https://github.com/howmanysmall> ----------- Lua + Roblox optimizations

	List of possible tokens:
		- iden
		- keyword
		- builtin
		- string
		- number
		- comment
		- operator
--]=]

			local lexer = {}

			local Prefix, Suffix, Cleaner = "^[%c%s]*", "[%c%s]*", "[%c%s]+"
			local UNICODE = "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]+"
			local NUMBER_A = "0[xX][%da-fA-F_]+"
			local NUMBER_B = "0[bB][01_]+"
			local NUMBER_C = "%d+%.?%d*[eE][%+%-]?%d+"
			local NUMBER_D = "%d+[%._]?[%d_eE]*"
			local OPERATORS = "[:;<>/~%*%(%)%-={},%.#%^%+%%]+"
			local BRACKETS = "[%[%]]+" -- needs to be separate pattern from other operators or it'll mess up multiline strings
			local IDEN = "[%a_][%w_]*"
			local STRING_EMPTY = "(['\"])%1" --Empty String
			local STRING_PLAIN = "(['\"])[^\n]-([^\\]%1)" --TODO: Handle escaping escapes
			local STRING_INTER = "`[^\n]-`"
			local STRING_INCOMP_A = "(['\"]).-\n" --Incompleted String with next line
			local STRING_INCOMP_B = "(['\"])[^\n]*" --Incompleted String without next line
			local STRING_MULTI = "%[(=*)%[.-%]%1%]" --Multiline-String
			local STRING_MULTI_INCOMP = "%[=*%[.-.*" --Incompleted Multiline-String
			local COMMENT_MULTI = "%-%-%[(=*)%[.-%]%1%]" --Completed Multiline-Comment
			local COMMENT_MULTI_INCOMP = "%-%-%[=*%[.-.*" --Incompleted Multiline-Comment
			local COMMENT_PLAIN = "%-%-.-\n" --Completed Singleline-Comment
			local COMMENT_INCOMP = "%-%-.*" --Incompleted Singleline-Comment
			-- local TYPED_VAR = ":%s*([%w%?%| \t]+%s*)" --Typed variable, parameter, function

			local lang = require(script.language)
			local lua_keyword = lang.keyword
			local lua_builtin = lang.builtin
			local lua_libraries = lang.libraries

			lexer.language = lang

			local lua_matches = {
				-- Indentifiers
				{ Prefix .. IDEN .. Suffix, "var" },

				-- Numbers
				{ Prefix .. NUMBER_A .. Suffix, "number" },
				{ Prefix .. NUMBER_B .. Suffix, "number" },
				{ Prefix .. NUMBER_C .. Suffix, "number" },
				{ Prefix .. NUMBER_D .. Suffix, "number" },

				-- Strings
				{ Prefix .. STRING_EMPTY .. Suffix, "string" },
				{ Prefix .. STRING_PLAIN .. Suffix, "string" },
				{ Prefix .. STRING_INCOMP_A .. Suffix, "string" },
				{ Prefix .. STRING_INCOMP_B .. Suffix, "string" },
				{ Prefix .. STRING_MULTI .. Suffix, "string" },
				{ Prefix .. STRING_MULTI_INCOMP .. Suffix, "string" },
				{ Prefix .. STRING_INTER .. Suffix, "string_inter" },

				-- Comments
				{ Prefix .. COMMENT_MULTI .. Suffix, "comment" },
				{ Prefix .. COMMENT_MULTI_INCOMP .. Suffix, "comment" },
				{ Prefix .. COMMENT_PLAIN .. Suffix, "comment" },
				{ Prefix .. COMMENT_INCOMP .. Suffix, "comment" },

				-- Operators
				{ Prefix .. OPERATORS .. Suffix, "operator" },
				{ Prefix .. BRACKETS .. Suffix, "operator" },

				-- Unicode
				{ Prefix .. UNICODE .. Suffix, "iden" },

				-- Unknown
				{ "^.", "iden" },
			}

			-- To reduce the amount of table indexing during lexing, we separate the matches now
			local PATTERNS, TOKENS = {}, {}
			for i, m in lua_matches do
				PATTERNS[i] = m[1]
				TOKENS[i] = m[2]
			end

			--- Create a plain token iterator from a string.
			-- @tparam string s a string.

			function lexer.scan(s: string)
				local index = 1
				local size = #s
				local previousContent1, previousContent2, previousContent3, previousToken = "", "", "", ""

				local thread = coroutine.create(function()
					while index <= size do
						local matched = false
						for tokenType, pattern in ipairs(PATTERNS) do
							-- Find match
							local start, finish = string.find(s, pattern, index)
							if start == nil then continue end

							-- Move head
							index = finish + 1
							matched = true

							-- Gather results
							local content = string.sub(s, start, finish)
							local rawToken = TOKENS[tokenType]
							local processedToken = rawToken

							-- Process token
							if rawToken == "var" then
								-- Since we merge spaces into the tok, we need to remove them
								-- in order to check the actual word it contains
								local cleanContent = string.gsub(content, Cleaner, "")

								if lua_keyword[cleanContent] then
									processedToken = "keyword"
								elseif lua_builtin[cleanContent] then
									processedToken = "builtin"
								elseif string.find(previousContent1, "%.[%s%c]*$") and previousToken ~= "comment" then
									-- The previous was a . so we need to special case indexing things
									local parent = string.gsub(previousContent2, Cleaner, "")
									local lib = lua_libraries[parent]
									if lib and lib[cleanContent] and not string.find(previousContent3, "%.[%s%c]*$") then
										-- Indexing a builtin lib with existing item, treat as a builtin
										processedToken = "builtin"
									else
										-- Indexing a non builtin, can't be treated as a keyword/builtin
										processedToken = "iden"
									end
									-- print("indexing",parent,"with",cleanTok,"as",t2)
								else
									processedToken = "iden"
								end
							elseif rawToken == "string_inter" then
								if not string.find(content, "[^\\]{") then
									-- This inter string doesnt actually have any inters
									processedToken = "string"
								else
									-- We're gonna do our own yields, so the main loop won't need to
									-- Our yields will be a mix of string and whatever is inside the inters
									processedToken = nil

									local isString = true
									local subIndex = 1
									local subSize = #content
									while subIndex <= subSize do
										-- Find next brace
										local subStart, subFinish = string.find(content, "^.-[^\\][{}]", subIndex)
										if subStart == nil then
											-- No more braces, all string
											coroutine.yield("string", string.sub(content, subIndex))
											break
										end

										if isString then
											-- We are currently a string
											subIndex = subFinish + 1
											coroutine.yield("string", string.sub(content, subStart, subFinish))

											-- This brace opens code
											isString = false
										else
											-- We are currently in code
											subIndex = subFinish
											local subContent = string.sub(content, subStart, subFinish-1)
											for innerToken, innerContent in lexer.scan(subContent) do
												coroutine.yield(innerToken, innerContent)
											end

											-- This brace opens string/closes code
											isString = true
										end
									end
								end
							end

							-- Record last 3 tokens for the indexing context check
							previousContent3 = previousContent2
							previousContent2 = previousContent1
							previousContent1 = content
							previousToken = processedToken or rawToken
							if processedToken then
								coroutine.yield(processedToken, content)
							end
							break
						end

						-- No matches found
						if not matched then
							return
						end
					end

					-- Completed the scan
					return
				end)

				return function()
					if coroutine.status(thread) == "dead" then
						return
					end

					local success, token, content = coroutine.resume(thread)
					if success and token then
						return token, content
					end

					return
				end
			end

			function lexer.navigator()
				local nav = {
					Source = "",
					TokenCache = table.create(50),

					_RealIndex = 0,
					_UserIndex = 0,
					_ScanThread = nil,
				}

				function nav:Destroy()
					self.Source = nil
					self._RealIndex = nil
					self._UserIndex = nil
					self.TokenCache = nil
					self._ScanThread = nil
				end

				function nav:SetSource(SourceString)
					self.Source = SourceString

					self._RealIndex = 0
					self._UserIndex = 0
					table.clear(self.TokenCache)

					self._ScanThread = coroutine.create(function()
						for Token, Src in lexer.scan(self.Source) do
							self._RealIndex += 1
							self.TokenCache[self._RealIndex] = { Token, Src }
							coroutine.yield(Token, Src)
						end
					end)
				end

				function nav.Next()
					nav._UserIndex += 1

					if nav._RealIndex >= nav._UserIndex then
						-- Already scanned, return cached
						return table.unpack(nav.TokenCache[nav._UserIndex])
					else
						if coroutine.status(nav._ScanThread) == "dead" then
							-- Scan thread dead
							return
						else
							local success, token, src = coroutine.resume(nav._ScanThread)
							if success and token then
								-- Scanned new data
								return token, src
							else
								-- Lex completed
								return
							end
						end
					end
				end

				function nav.Peek(PeekAmount)
					local GoalIndex = nav._UserIndex + PeekAmount

					if nav._RealIndex >= GoalIndex then
						-- Already scanned, return cached
						if GoalIndex > 0 then
							return table.unpack(nav.TokenCache[GoalIndex])
						else
							-- Invalid peek
							return
						end
					else
						if coroutine.status(nav._ScanThread) == "dead" then
							-- Scan thread dead
							return
						else
							local IterationsAway = GoalIndex - nav._RealIndex

							local success, token, src = nil, nil, nil

							for _ = 1, IterationsAway do
								success, token, src = coroutine.resume(nav._ScanThread)
								if not (success or token) then
									-- Lex completed
									break
								end
							end

							return token, src
						end
					end
				end

				return nav
			end

			return lexer

		end;
	};
	G2L_MODULES[G2L["96"]] = {
		Closure = function()
			local script = G2L["96"];
			local language = {
				keyword = {
					["and"] = "keyword",
					["break"] = "keyword",
					["continue"] = "keyword",
					["do"] = "keyword",
					["else"] = "keyword",
					["elseif"] = "keyword",
					["end"] = "keyword",
					["export"] = "keyword",
					["false"] = "keyword",
					["for"] = "keyword",
					["function"] = "keyword",
					["if"] = "keyword",
					["in"] = "keyword",
					["local"] = "keyword",
					["nil"] = "keyword",
					["not"] = "keyword",
					["or"] = "keyword",
					["repeat"] = "keyword",
					["return"] = "keyword",
					["self"] = "keyword",
					["then"] = "keyword",
					["true"] = "keyword",
					["type"] = "keyword",
					["typeof"] = "keyword",
					["until"] = "keyword",
					["while"] = "keyword",
				},

				builtin = {
					-- Luau Functions
					["assert"] = "function",
					["error"] = "function",
					["getfenv"] = "function",
					["getmetatable"] = "function",
					["ipairs"] = "function",
					["loadstring"] = "function",
					["newproxy"] = "function",
					["next"] = "function",
					["pairs"] = "function",
					["pcall"] = "function",
					["print"] = "function",
					["rawequal"] = "function",
					["rawget"] = "function",
					["rawlen"] = "function",
					["rawset"] = "function",
					["select"] = "function",
					["setfenv"] = "function",
					["setmetatable"] = "function",
					["tonumber"] = "function",
					["tostring"] = "function",
					["unpack"] = "function",
					["xpcall"] = "function",

					-- Luau Functions (Deprecated)
					["collectgarbage"] = "function",

					-- Luau Variables
					["_G"] = "table",
					["_VERSION"] = "string",

					-- Luau Tables
					["bit32"] = "table",
					["coroutine"] = "table",
					["debug"] = "table",
					["math"] = "table",
					["os"] = "table",
					["string"] = "table",
					["table"] = "table",
					["utf8"] = "table",

					-- Roblox Functions
					["DebuggerManager"] = "function",
					["delay"] = "function",
					["gcinfo"] = "function",
					["PluginManager"] = "function",
					["require"] = "function",
					["settings"] = "function",
					["spawn"] = "function",
					["tick"] = "function",
					["time"] = "function",
					["UserSettings"] = "function",
					["wait"] = "function",
					["warn"] = "function",

					-- Roblox Functions (Deprecated)
					["Delay"] = "function",
					["ElapsedTime"] = "function",
					["elapsedTime"] = "function",
					["printidentity"] = "function",
					["Spawn"] = "function",
					["Stats"] = "function",
					["stats"] = "function",
					["Version"] = "function",
					["version"] = "function",
					["Wait"] = "function",
					["ypcall"] = "function",

					-- Roblox Variables
					["game"] = "Instance",
					["plugin"] = "Instance",
					["script"] = "Instance",
					["shared"] = "Instance",
					["workspace"] = "Instance",

					-- Roblox Variables (Deprecated)
					["Game"] = "Instance",
					["Workspace"] = "Instance",

					-- Roblox Tables
					["Axes"] = "table",
					["BrickColor"] = "table",
					["CatalogSearchParams"] = "table",
					["CFrame"] = "table",
					["Color3"] = "table",
					["ColorSequence"] = "table",
					["ColorSequenceKeypoint"] = "table",
					["DateTime"] = "table",
					["DockWidgetPluginGuiInfo"] = "table",
					["Enum"] = "table",
					["Faces"] = "table",
					["FloatCurveKey"] = "table",
					["Font"] = "table",
					["Instance"] = "table",
					["NumberRange"] = "table",
					["NumberSequence"] = "table",
					["NumberSequenceKeypoint"] = "table",
					["OverlapParams"] = "table",
					["PathWaypoint"] = "table",
					["PhysicalProperties"] = "table",
					["Random"] = "table",
					["Ray"] = "table",
					["RaycastParams"] = "table",
					["Rect"] = "table",
					["Region3"] = "table",
					["Region3int16"] = "table",
					["RotationCurveKey"] = "table",
					["task"] = "table",
					["TweenInfo"] = "table",
					["UDim"] = "table",
					["UDim2"] = "table",
					["Vector2"] = "table",
					["Vector2int16"] = "table",
					["Vector3"] = "table",
					["Vector3int16"] = "table",
				},

				libraries = {

					-- Luau Libraries
					bit32 = {
						arshift = "function",
						band = "function",
						bnot = "function",
						bor = "function",
						btest = "function",
						bxor = "function",
						countlz = "function",
						countrz = "function",
						extract = "function",
						lrotate = "function",
						lshift = "function",
						replace = "function",
						rrotate = "function",
						rshift = "function",
					},

					coroutine = {
						close = "function",
						create = "function",
						isyieldable = "function",
						resume = "function",
						running = "function",
						status = "function",
						wrap = "function",
						yield = "function",
					},

					debug = {
						dumpheap = "function",
						info = "function",
						loadmodule = "function",
						profilebegin = "function",
						profileend = "function",
						resetmemorycategory = "function",
						setmemorycategory = "function",
						traceback = "function",
					},

					math = {
						abs = "function",
						acos = "function",
						asin = "function",
						atan2 = "function",
						atan = "function",
						ceil = "function",
						clamp = "function",
						cos = "function",
						cosh = "function",
						deg = "function",
						exp = "function",
						floor = "function",
						fmod = "function",
						frexp = "function",
						ldexp = "function",
						log10 = "function",
						log = "function",
						max = "function",
						min = "function",
						modf = "function",
						noise = "function",
						pow = "function",
						rad = "function",
						random = "function",
						randomseed = "function",
						round = "function",
						sign = "function",
						sin = "function",
						sinh = "function",
						sqrt = "function",
						tan = "function",
						tanh = "function",

						huge = "number",
						pi = "number",
					},

					os = {
						clock = "function",
						date = "function",
						difftime = "function",
						time = "function",
					},

					string = {
						byte = "function",
						char = "function",
						find = "function",
						format = "function",
						gmatch = "function",
						gsub = "function",
						len = "function",
						lower = "function",
						match = "function",
						pack = "function",
						packsize = "function",
						rep = "function",
						reverse = "function",
						split = "function",
						sub = "function",
						unpack = "function",
						upper = "function",
					},

					table = {
						clear = "function",
						clone = "function",
						concat = "function",
						create = "function",
						find = "function",
						foreach = "function",
						foreachi = "function",
						freeze = "function",
						getn = "function",
						insert = "function",
						isfrozen = "function",
						maxn = "function",
						move = "function",
						pack = "function",
						remove = "function",
						sort = "function",
						unpack = "function",
					},

					utf8 = {
						char = "function",
						codepoint = "function",
						codes = "function",
						graphemes = "function",
						len = "function",
						nfcnormalize = "function",
						nfdnormalize = "function",
						offset = "function",

						charpattern = "string",
					},

					-- Roblox Libraries
					Axes = {
						new = "function",
					},

					BrickColor = {
						Black = "function",
						Blue = "function",
						DarkGray = "function",
						Gray = "function",
						Green = "function",
						new = "function",
						New = "function",
						palette = "function",
						Random = "function",
						random = "function",
						Red = "function",
						White = "function",
						Yellow = "function",
					},

					CatalogSearchParams = {
						new = "function",
					},

					CFrame = {
						Angles = "function",
						fromAxisAngle = "function",
						fromEulerAngles = "function",
						fromEulerAnglesXYZ = "function",
						fromEulerAnglesYXZ = "function",
						fromMatrix = "function",
						fromOrientation = "function",
						lookAt = "function",
						new = "function",

						identity = "CFrame",
					},

					Color3 = {
						fromHex = "function",
						fromHSV = "function",
						fromRGB = "function",
						new = "function",
						toHSV = "function",
					},

					ColorSequence = {
						new = "function",
					},

					ColorSequenceKeypoint = {
						new = "function",
					},

					DateTime = {
						fromIsoDate = "function",
						fromLocalTime = "function",
						fromUniversalTime = "function",
						fromUnixTimestamp = "function",
						fromUnixTimestampMillis = "function",
						now = "function",
					},

					DockWidgetPluginGuiInfo = {
						new = "function",
					},

					Enum = {},

					Faces = {
						new = "function",
					},

					FloatCurveKey = {
						new = "function",
					},

					Font = {
						fromEnum = "function",
						fromId = "function",
						fromName = "function",
						new = "function",
					},

					Instance = {
						new = "function",
					},

					NumberRange = {
						new = "function",
					},

					NumberSequence = {
						new = "function",
					},

					NumberSequenceKeypoint = {
						new = "function",
					},

					OverlapParams = {
						new = "function",
					},

					PathWaypoint = {
						new = "function",
					},

					PhysicalProperties = {
						new = "function",
					},

					Random = {
						new = "function",
					},

					Ray = {
						new = "function",
					},

					RaycastParams = {
						new = "function",
					},

					Rect = {
						new = "function",
					},

					Region3 = {
						new = "function",
					},

					Region3int16 = {
						new = "function",
					},

					RotationCurveKey = {
						new = "function",
					},

					task = {
						cancel = "function",
						defer = "function",
						delay = "function",
						desynchronize = "function",
						spawn = "function",
						synchronize = "function",
						wait = "function",
					},

					TweenInfo = {
						new = "function",
					},

					UDim = {
						new = "function",
					},

					UDim2 = {
						fromOffset = "function",
						fromScale = "function",
						new = "function",
					},

					Vector2 = {
						new = "function",

						one = "Vector2",
						xAxis = "Vector2",
						yAxis = "Vector2",
						zero = "Vector2",
					},

					Vector2int16 = {
						new = "function",
					},

					Vector3 = {
						fromAxis = "function",
						FromAxis = "function",
						fromNormalId = "function",
						FromNormalId = "function",
						new = "function",

						one = "Vector3",
						xAxis = "Vector3",
						yAxis = "Vector3",
						zAxis = "Vector3",
						zero = "Vector3",
					},

					Vector3int16 = {
						new = "function",
					},
				},
			}

			-- Filling up language.libraries.Enum table
			local enumLibraryTable = language.libraries.Enum

			for _, enum in ipairs(Enum:GetEnums()) do
				--TODO: Remove tostring from here once there is a better way to get the name of an Enum
				enumLibraryTable[tostring(enum)] = "Enum"
			end

			return language

		end;
	};
	-- StarterGui.SynapseX.Main.ScriptTab.ScriptTabHandler
	local function C_44()
		local script = G2L["44"];
		local function AddTab()
			local NewTextbox = script.Parent.Parent.MainFunc.Needs.Textbox:Clone()
			local NewTab = script.Parent.Parent.MainFunc.Needs.Tab:Clone()
			local num = 0

			NewTextbox.Parent = script.Parent.Parent.MainFunc.Textboxes
			NewTab.Parent=  script.Parent.Tabs
			NewTab.Visible = true
			NewTextbox.Visible = true
			NewTab.BackgroundColor3 = Color3.fromRGB(80,80,80)

			-- Set da name as yes
			for i,v in pairs(script.Parent.Parent.MainFunc.Textboxes:GetChildren()) do
				num += 1
			end
			NewTab.Name = "  Script "..tostring(num)
			NewTab.Text = "  Script "..tostring(num)
			NewTextbox.Name = "  Script "..tostring(num)

			-- Set any textbox except new disabled (not visible)
			for _,tabs in pairs(script.Parent.Parent.MainFunc.Textboxes:GetChildren()) do
				if tabs.Name ~= NewTextbox.Name then
					tabs.Visible = false
				end
			end

			-- Set any Tab color back except this
			for i,v in pairs(script.Parent.Tabs:GetChildren()) do
				if v:IsA("TextButton") and v.Name ~= NewTab.Name then
					v.BackgroundColor3 = Color3.fromRGB(100,100,100)
				end
			end





			NewTab:FindFirstChild("Remove").MouseButton1Up:Connect(function()
				local num = 0
				for _, textboxes in pairs(script.Parent.Parent.MainFunc.Textboxes:GetChildren()) do
					num += 1

				end
				if num > 1 then
					for i,v in pairs(script.Parent.Parent.MainFunc.Textboxes:GetChildren()) do
						if v.Name == NewTab.Name then
							v:Destroy()
						end
					end
					NewTab:Destroy()
				end
			end)
			NewTab.MouseButton1Up:Connect(function()
				for i,v in pairs(script.Parent.Parent.MainFunc.Textboxes:GetChildren()) do
					if v.Name == NewTab.Name then
						v.Visible = true
					else
						v.Visible = false
					end
				end
				for i,v in pairs(script.Parent.Tabs:GetChildren()) do
					if v:IsA("TextButton") and v.Name ~= NewTab.Name then
						v.BackgroundColor3 = Color3.fromRGB(100,100,100)
					else
						if v:IsA("TextButton") then
							v.BackgroundColor3 = Color3.fromRGB(80,80,80)
						end
					end
				end
			end)




			-- Textbox handler
			local Highlighter = require(script.Parent.Parent.Parent.Highlighter)

			local textBox = NewTextbox.Frame.Textbox



			local TextBox = textBox
			local LineIndicator = NewTextbox.Frame.Linebar.LineText


			local function updateLineIndicator()
				local text = TextBox.Text
				local lineCount = select(2, text:gsub('\n', '\n'))

				LineIndicator.Text = ""

				for lineNumber = 1, lineCount + 1 do
					LineIndicator.Text = LineIndicator.Text .. lineNumber .. "\n"
				end
			end

			local function autoHighlight()
				Highlighter.highlight({
					textObject = textBox,
					src = textBox.Text,
					forceUpdate = true
				})
			end
			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				autoHighlight()
			end)

			task.spawn(function()
				local UserInputService = game:GetService("UserInputService")
				local textBox = NewTextbox.Frame.Textbox -- Replace with the instance of your TextBox
				local lineIndicatorFrame = NewTextbox.Frame.Highlighted -- Replace with the instance of your line indicator frame

				local function moveLineIndicatorFrame(lineNumber)
					local lineHeight = lineIndicatorFrame.LineText.TextSize -- Adjust this value as per your line indicator's line height

					local newYOffset
					if lineNumber then
						newYOffset = (lineNumber - 10) * lineHeight
					else
						newYOffset = lineIndicatorFrame.Position.Y.Offset + 14
					end

					lineIndicatorFrame.Position = UDim2.new(0, 0, 0, newYOffset)
				end

				local function onMouseMove()
					if textBox:IsFocused() then
						UserInputService.InputBegan:Connect(function(input)
							if  input == Enum.UserInputType.MouseButton1 or input == Enum.UserInputType.Touch then
								local mouse = UserInputService:GetMouseLocation()
								local y = mouse.Y
								local lineHeight = lineIndicatorFrame.LineText.TextSize -- Adjust this value as per your line indicator's line height

								local lineNumber = math.floor(y / lineHeight) + 1
								moveLineIndicatorFrame(lineNumber)
							end
						end)
					end
				end

				UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						onMouseMove()
					end
				end)

				UserInputService.InputBegan:Connect(function(input)
					pcall(function() -- i hate the errors, so yes
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							local mouse = UserInputService:GetMouseLocation()
							local y = mouse.Y
							pcall(function() lineHeight = lineIndicatorFrame:FindFirstChild("LineText").TextSize end)

							local lineNumber = math.floor(y / lineHeight) + 1
							moveLineIndicatorFrame(lineNumber)
						elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Return and textBox:IsFocused() then
							moveLineIndicatorFrame(nil)
						end
					end)
				end)

				textBox.FocusLost:Connect(function(enterPressed)
					if enterPressed then
						local lineNumber = textBox.CursorPosition.Y
						moveLineIndicatorFrame(lineNumber)
					end
				end)
			end)





			updateLineIndicator()


			TextBox.Changed:Connect(function(property)
				if property == "Text" then
					updateLineIndicator()
				end
			end)


			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				NewTextbox.Frame.Size = UDim2.new(script.Parent.Size.X.Scale, script.Parent.Size.X.Offset, script.Parent.Parent.Size.Y.Scale, script.Parent.Parent.Size.Y.Offset + 150)
				NewTextbox.Frame.Highlighted.Size = UDim2.new(0, script.Parent.Parent.Size.X.Offset + 150,0, 13)
			end)














		end

		script.Parent.Tabs.AddScript.Button.MouseButton1Up:Connect(function()
			AddTab()
		end)
		AddTab()
	end;
	task.spawn(C_44);
	-- StarterGui.SynapseX.Main.ButtonsHandler
	local function C_49()
		local script = G2L["49"];
		local buttons = script.Parent
		local title = buttons.TitleSynapse
		local injected =  script.Parent.Parent.Injected.Value


		local function GetTextbox()
			for _,textbox in pairs(script.Parent.MainFunc.Textboxes:GetChildren()) do
				if textbox.Visible then
					return textbox
				end
			end
		end
		buttons.Clear.MouseButton1Up:Connect(function()
			for _, textbox in pairs(buttons.MainFunc.Textboxes:GetChildren()) do
				if textbox.Visible then
					textbox.Frame.Textbox.Text = ''
				end
			end
		end)
		buttons.Execute.MouseButton1Up:Connect(function()
			if not injected then
				title.Text = "Synapse CE - "..synversion.." (not injected! press attach)"
			elseif injected == true then

				local textbox = GetTextbox()

				--loadstring(textbox.Frame.Textbox.Text)()

				local source = textbox.Frame.Textbox.Text
				if #source >= 16384 then
					print"File too big. > 16,384 characters. [ROBLOX textbox limit]"
				end

				local sourcewglobals = globals .. "\n\n" .. source


				sandbox.environment.global.loadstring(sourcewglobals)()
			end
		end)
		buttons.Attach.MouseButton1Up:Connect(function()
			if not injected then
				title.Text = "Synapse CE - "..synversion.." (checking...)"
				task.wait(0.8)
				title.Text = "Synapse CE - "..synversion.." (injecting...)"
				task.wait(2.3)
				title.Text = "Synapse CE - "..synversion.." (checking whitelist...)"
				task.wait(1.6)
				title.Text = "Synapse CE - "..synversion.." (scanning...)"
				task.wait(1.3)
				title.Text = "Synapse CE - "..synversion.." (ready!)"
				injected = true
				task.wait(1)
				title.Text = "Synapse CE - "..synversion
			else
				title.Text = "Synapse CE - "..synversion.." (already injected!)"
				task.wait(1)
				title.Text = "Synapse CE - "..synversion
			end
		end)

		buttons.Options.MouseButton1Up:Connect(function()
			script.Parent.Parent.OptionMenu.Position = UDim2.new(0.367, -11,0.317, -6)
			script.Parent.Parent.OptionMenu.Visible = true
		end)

		buttons.OpenFile.MouseButton1Up:Connect(function()
			script.Parent.Parent.OpenScript.Visible = true
		end)
		buttons.SaveFile.MouseButton1Up:Connect(function()
			script.Parent.Parent.SaveScript.Visible = true
		end)
		buttons.Close.MouseButton1Up:Connect(function()
			script.Parent.Parent:Destroy()
		end)
		buttons.Maximize.MouseButton1Up:Connect(function()
			--idkkk
		end)
		buttons.Minimize.MouseButton1Up:Connect(function()
			buttons.Visible = false
			script.Parent.Parent.FloatingIcon.Visible = true
		end)

		script.Parent.Parent.FloatingIcon.MouseButton1Up:Connect(function()
			buttons.Visible = true
			script.Parent.Parent.FloatingIcon.Visible = false
		end)

		buttons.ScriptHub.MouseButton1Up:Connect(function()
			script.Parent.Parent.ScriptHubMenu.Visible = true
		end)
	end;
	task.spawn(C_49);
	-- StarterGui.SynapseX.SaveScript.Handler
	local function C_51()
		local script = G2L["51"];
		script.Parent.savescript.MouseButton1Up:Connect(function()
			local module = require(script.Parent.Parent.Module)
			module:AddScriptTabSave(script.Parent.scriptname.Text..".lua", module:GetActiveTextbox().Frame.Textbox.Text)
			script.Parent.Visible = false
			script.Parent.scriptname.Text = ''
			makefolder("SynapseSavedScripts")
			writefile("SynapseSavedScripts/"..script.Parent.scriptname.Text..".lua", module:GetActiveTextbox().Frame.Textbox.Text)
		end)

		script.Parent.Close.MouseButton1Up:Connect(function()
			script.Parent.Visible = false
			script.Parent.scriptname.Text = ''
		end)
	end;
	task.spawn(C_51);
	-- StarterGui.SynapseX.ScriptHubMenu.ScriptHubHandler
	local function C_71()
		local script = G2L["71"];
		local yes = script.Parent
		yes.Background.ScrollingFrame.Dex.MouseButton1Up:Connect(function()
			for i,v in pairs(script.Parent:GetChildren()) do
				if v.Name ~= script.Parent.Background.ScrollingFrame.Dex.Name and v:IsA("Frame") then
					pcall(function() v.Visible = false end)
				else
					pcall(function() v.Visible = true end)
				end
			end
			script.Parent.Description.Text = [[A version of the popular Dex explorer with
		patches specifically for Synapse CE.]]
		end)

		yes.Background.ScrollingFrame.RemoteSpy.MouseButton1Up:Connect(function()
			for i,v in pairs(script.Parent:GetChildren()) do
				if v.Name ~= script.Parent.Background.ScrollingFrame.RemoteSpy.Name and v:IsA("Frame") then
					pcall(function() v.Visible = false end)
				else
					pcall(function() v.Visible = true end)
				end
			end
			script.Parent.Description.Text = [[Allows you to view RemoteEvents and
		RemoteFunctions calleld.]]
		end)

		yes.Background.ScrollingFrame.UnnamedESP.MouseButton1Up:Connect(function()
			for i,v in pairs(script.Parent:GetChildren()) do
				if v.Name ~= script.Parent.Background.ScrollingFrame.UnnamedESP.Name and v:IsA("Frame") then
					pcall(function() v.Visible = false end)
				else
					pcall(function() v.Visible = true end)
				end
			end
			script.Parent.Description.Text = [[ESP made by ic3w0lf using the Drawing API.]]
		end)

		yes.Background.ScrollingFrame.ScriptDumper.MouseButton1Up:Connect(function()
			for i,v in pairs(script.Parent:GetChildren()) do
				if v.Name ~= script.Parent.Background.ScrollingFrame.ScriptDumper.Name and v:IsA("Frame") then
					pcall(function() pcall(function() v.Visible = false end) end)
				else
					pcall(function() v.Visible = true end)
				end
			end
			script.Parent.Description.Text = [[Dumps all LocalScripts an ModuleScripts.]]
		end)

		yes.Execute.MouseButton1Up:Connect(function()
			for i,v in pairs(yes:GetChildren()) do
				if v.Visible then
					if v.Name == "Dex" then
						_G.dex()
					elseif v.Name == "RemoteSpy" then

						warn("RemoteSpy doesn't support on NetflixCE.")
					elseif v.Name == "UnnamedESP" then
						_G.IY()
						warn("UnnamedESP doesn't support on NetflixCE, for alternative we executed IY.")
					elseif v.Name == "ScriptDumper" then
						warn("ScriptDumper doesn't support on NetflixCE.")
					end
				end
			end
		end)

		yes.Close.MouseButton1Up:Connect(function()
			script.Parent.Visible = false
		end)

		yes.Minimize.MouseButton1Up:Connect(function()
			script.Parent.Visible = false
		end)
	end;
	task.spawn(C_71);
	-- StarterGui.SynapseX.OptionMenu.Optionhandler
	local function C_83()
		local script = G2L["83"];
		local stuff  =script.Parent

		stuff.Buttons.Discord.MouseButton1Up:Connect(function()
			print("Server link is: ndhGeSGkWn")
		end)
		stuff.Buttons.Rejoin.MouseButton1Up:Connect(function()
			game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
		end)

		stuff.Close.MouseButton1Up:Connect(function()
			script.Parent.Visible = false
		end)



		-- Toggles
		stuff.ToggleAutoExec.MouseButton1Up:Connect(function()
			if stuff.ToggleAutoExec.Text == '' then
				stuff.ToggleAutoExec.BackgroundColor3 = Color3.fromRGB(112,112,112)
				stuff.ToggleAutoExec.Text = 'x'



			else
				stuff.ToggleAutoExec.BackgroundColor3 = Color3.fromRGB(166,166,166)
				stuff.ToggleAutoExec.Text = ''



			end
		end)

		stuff.ToggleFPSUnlocker.MouseButton1Up:Connect(function()
			if stuff.ToggleFPSUnlocker.Text == '' then
				stuff.ToggleFPSUnlocker.BackgroundColor3 = Color3.fromRGB(112,112,112)
				stuff.ToggleFPSUnlocker.Text = 'x'

				setfpscap(math.huge)

			else
				stuff.ToggleFPSUnlocker.BackgroundColor3 = Color3.fromRGB(166,166,166)
				stuff.ToggleFPSUnlocker.Text = ''

				setfpscap(60)

			end
		end)

		stuff.ToggleInternalUI.MouseButton1Up:Connect(function()
			if stuff.ToggleInternalUI.Text == '' then
				stuff.ToggleInternalUI.BackgroundColor3 = Color3.fromRGB(112,112,112)
				stuff.ToggleInternalUI.Text = 'x'

				-- idk

			else
				stuff.ToggleInternalUI.BackgroundColor3 = Color3.fromRGB(166,166,166)
				stuff.ToggleInternalUI.Text = ''

				-- idk

			end
		end)

		stuff.ToggleTopMost.MouseButton1Up:Connect(function()
			if stuff.ToggleTopMost.Text == '' then
				stuff.ToggleTopMost.BackgroundColor3 = Color3.fromRGB(112,112,112)
				stuff.ToggleTopMost.Text = 'x'

				-- idk

			else
				stuff.ToggleTopMost.BackgroundColor3 = Color3.fromRGB(166,166,166)
				stuff.ToggleTopMost.Text = ''

				-- idk

			end
		end)
	end;
	task.spawn(C_83);
	-- StarterGui.SynapseX.GetSavedScripts
	local function C_84()

		local script = G2L["84"];
		local module = require(script.Parent.Module)

		for index, value in pairs(listfiles("SynapseSavedScripts")) do
			print(value)
			if isfile(value) then
				task.wait(0.05)
				local editedString = string.gsub(value, [[SynapseSavedScripts\]], "")
				module:AddScriptTabSave(editedString, readfile(value))
			end
		end
	end;
	task.spawn(C_84);
	-- StarterGui.SynapseX.OpenScript.Handler
	local function C_92()
		local script = G2L["92"];
		script.Parent.savescript.MouseButton1Up:Connect(function()
			local module = require(script.Parent.Parent.Module)
			if isfile(script.Parent.scriptname.Text) then
				local a = script.Parent.scriptname.Text
				script.Parent.Visible = false
				script.Parent.scriptname.Text = ''
				module:AddTab(script.Parent.scriptname.Text, readfile(a))
			else
				script.Parent.Title.Text = "Synapse CE - Open File (File not found!)"
				task.wait(1)
				script.Parent.Title.Text = "Synapse CE - Open File"
			end
		end)

		script.Parent.Close.MouseButton1Up:Connect(function()
			script.Parent.Visible = false
			script.Parent.scriptname.Text = ''
		end)
	end;
	task.spawn(C_92);
	-- StarterGui.SynapseX.SetDraggable
	local function C_93()
		local script = G2L["93"];
		local yes =  script.Parent
		yes.Main.Draggable = true
		yes.OpenScript.Draggable = true
		yes.OptionMenu.Draggable = true
		yes.SaveScript.Draggable = true
		yes.ScriptHubMenu.Draggable = true
		yes.ScriptLog.Draggable = true
		yes.FloatingIcon.Draggable = true



		yes.Main.MainFunc.ScriptHub.ChildAdded:Connect(function(v)

			if v:IsA("TextButton") then
				local color = v.BackgroundColor3
				local bordercolor = v.BorderColor3
				local bordersize = v.BorderSizePixel
				v.MouseEnter:Connect(function()
					v.BackgroundColor3 = Color3.fromRGB(0,47,80)
					v.BorderColor3 = Color3.fromRGB(91,139,168)
					v.BorderSizePixel = 1
				end)
				v.MouseLeave:Connect(function()
					v.BackgroundColor3 = color
					v.BorderColor3 = bordercolor
					v.BorderSizePixel = bordersize
				end)
			end

		end)

		yes.Main.MainFunc.ScriptHub.ChildAdded:Connect(function(v)
			if yes:IsA("TextButton") then
				v.ChildAdded:Connect(function(RClick)
					print(RClick.Name)
					local del = RClick.Delete
					local color = del.BackgroundColor3
					local bordercolor = del.BorderColor3
					local bordersize = del.BorderSizePixel
					del.MouseEnter:Connect(function()
						del.BackgroundColor3 = Color3.fromRGB(0,47,80)
						del.BorderColor3 = Color3.fromRGB(91,139,168)
						del.BorderSizePixel = 1
					end)
					del.MouseLeave:Connect(function()
						del.BackgroundColor3 = color
						del.BorderColor3 = bordercolor
						del.BorderSizePixel = bordersize
					end)


					local exec = RClick.Execute
					local color = exec.BackgroundColor3
					local bordercolor = exec.BorderColor3
					local bordersize = exec.BorderSizePixel
					exec.MouseEnter:Connect(function()
						exec.BackgroundColor3 = Color3.fromRGB(0,47,80)
						exec.BorderColor3 = Color3.fromRGB(91,139,168)
						exec.BorderSizePixel = 1
					end)
					exec.MouseLeave:Connect(function()
						exec.BackgroundColor3 = color
						exec.BorderColor3 = bordercolor
						exec.BorderSizePixel = bordersize
					end)

					local load = RClick.Load
					local color = load.BackgroundColor3
					local bordercolor = load.BorderColor3
					local bordersize =load.BorderSizePixel
					load.MouseEnter:Connect(function()
						load.BackgroundColor3 = Color3.fromRGB(0,47,80)
						load.BorderColor3 = Color3.fromRGB(91,139,168)
						load.BorderSizePixel = 1
					end)
					load.MouseLeave:Connect(function()
						load.BackgroundColor3 = color
						load.BorderColor3 = bordercolor
						load.BorderSizePixel = bordersize
					end)
				end)

			end
		end)



		task.spawn(function()

			for i,v in pairs(yes.Main.MainFunc.ScriptHub:GetChildren()) do
				if v:IsA("TextButton") then
					local color = v.BackgroundColor3
					local bordercolor = v.BorderColor3
					local bordersize = v.BorderSizePixel
					v.MouseEnter:Connect(function()
						v.BackgroundColor3 = Color3.fromRGB(0,47,80)
						v.BorderColor3 = Color3.fromRGB(91,139,168)
						v.BorderSizePixel = 1
					end)
					v.MouseLeave:Connect(function()
						v.BackgroundColor3 = color
						v.BorderColor3 = bordercolor
						v.BorderSizePixel = bordersize
					end)
				end
			end

		end)
		for i,v in pairs(G2L["1"]:GetDescendants()) do
			if (v:IsA("TextButton") and v.Parent.Parent.Name ~= "Tabs" and v.Parent.Name ~= "Tabs") or (v:IsA("ImageButton")) then
				task.spawn(function()
					local color = v.BackgroundColor3
					local bordercolor = v.BorderColor3
					local bordersize = v.BorderSizePixel
					v.BackgroundTransparency = 0
					v.MouseEnter:Connect(function()
						v.BackgroundColor3 = Color3.fromRGB(0,47,80)
						v.BorderColor3 = Color3.fromRGB(91,139,168)
						v.BorderSizePixel = 1
					end)
					v.MouseLeave:Connect(function()
						v.BackgroundColor3 = color
						v.BorderColor3 = bordercolor
						v.BorderSizePixel = bordersize
					end)
				end)
			end
		end

	end;
	task.spawn(C_93);

	return G2L["1"], require;
end

local function initialize_scripts_handler()
	local success, err = pcall(function()
		while task.wait(0.2) do
			local current_script = bridge:send("get_script")

			local script_to_execute = current_script["script"]

			if script_to_execute and script_to_execute ~= nil and script_to_execute ~= "" then
				script_to_execute = sandbox.environment.global.base64_decode(script_to_execute)
				sandbox.environment.global.loadstring(script_to_execute)()
			end
		end
	end)
end


-- Define the function to initialize the environment
local function initialize_environment()
    sandbox:initialize()
    gui:Create()
    task.spawn(initialize_scripts_handler)
end

-- Connect the function to the game's Loaded event
game.Loaded:Connect(function()
    initialize_environment()
end)

-- loads miscellanous shenanigans based on the hooked script name
if script.Name == "PolicyService" then
    --[[
        Filename: PolicyService.lua
        Written by: ben
        Description: Handles all policy service calls in lua for core scripts
    --]]

	local PlayersService = game:GetService('Players')

	local isSubjectToChinaPolicies = true
	local policyTable
	local initialized = false
	local initAsyncCalledOnce = false

	local initializedEvent = Instance.new("BindableEvent")

	--[[ Classes ]]--
	local PolicyService = {}

	function PolicyService:InitAsync()
		if _G.__TESTEZ_RUNNING_TEST__ then
			isSubjectToChinaPolicies = false
			-- Return here in the case of unit tests
			return
		end

		if initialized then return end
		if initAsyncCalledOnce then
			initializedEvent.Event:Wait()
			return
		end
		initAsyncCalledOnce = true

		local localPlayer = PlayersService.LocalPlayer
		while not localPlayer do
			PlayersService.PlayerAdded:Wait()
			localPlayer = PlayersService.LocalPlayer
		end
		assert(localPlayer, "")

		pcall(function() policyTable = game:GetService("PolicyService"):GetPolicyInfoForPlayerAsync(localPlayer) end)
		if policyTable then
			isSubjectToChinaPolicies = policyTable["IsSubjectToChinaPolicies"]
		end

		initialized = true
		initializedEvent:Fire()
	end

	function PolicyService:IsSubjectToChinaPolicies()
		self:InitAsync()

		return isSubjectToChinaPolicies
	end

	return PolicyService
elseif script.Name == "JestGlobals" then
	local input_manager = Instance.new("VirtualInputManager")

	input_manager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
	input_manager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
	input_manager:Destroy()

	return {HideTemp = function() end}
end
