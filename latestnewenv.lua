--!nocheck

local load = coroutine.wrap(function()
	local compile = coroutine.wrap(function()
		local luaZ = table.create(0)
		local luaY = table.create(0)
		local luaX = table.create(0)
		local luaP = table.create(0)
		local luaU = table.create(0)
		local luaK = table.create(0)
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
			local z = table.create(0)
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
			local tokens, enums = table.create(0), table.create(0)
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
			if not ls then ls = table.create(0) end
			if not ls.lookahead then ls.lookahead = table.create(0) end
			if not ls.t then ls.t = table.create(0) end
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
			local i = table.create(0)
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
		
		luaP.opnames = table.create(0) 
		luaP.OpCode = table.create(0) 
		luaP.ROpCode = table.create(0) 
		
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
			local buff = table.create(0)
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
			local buff = table.create(0)
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
			local D = table.create(0) 
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
				idx = table.create(0)
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
			local o = table.create(0)  -- TValue
			self:setsvalue(o, s)
			return self:addk(fs, o, o)
		end
		
		------------------------------------------------------------------------
		-- creates and sets a number object
		-- * used in luaK:prefix() for negative (or negation of) numbers
		-- * used in (lparser) luaY:simpleexp(), luaY:fornum()
		------------------------------------------------------------------------
		function luaK:numberK(fs, r)
			local o = table.create(0)  -- TValue
			self:setnvalue(o, r)
			return self:addk(fs, o, o)
		end
		
		------------------------------------------------------------------------
		-- creates and sets a boolean object
		-- * used only in luaK:exp2RK()
		------------------------------------------------------------------------
		function luaK:boolK(fs, b)
			local o = table.create(0)  -- TValue
			self:setbvalue(o, b)
			return self:addk(fs, o, o)
		end
		
		------------------------------------------------------------------------
		-- creates and sets a nil object
		-- * used only in luaK:exp2RK()
		------------------------------------------------------------------------
		function luaK:nilK(fs)
			local k, v = table.create(0), table.create(0)  -- TValue
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
			local e2 = table.create(0)  -- expdesc
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
			local f = table.create(0) -- Proto
			-- luaC_link(L, obj2gco(f), LUA_TPROTO); /* GC */
			f.k = table.create(0)
			f.sizek = 0
			f.p = table.create(0)
			f.sizep = 0
			f.code = table.create(0)
			f.sizecode = 0
			f.sizelineinfo = 0
			f.sizeupvalues = 0
			f.nups = 0
			f.upvalues = table.create(0)
			f.numparams = 0
			f.is_vararg = 0
			f.maxstacksize = 0
			f.lineinfo = table.create(0)
			f.sizelocvars = 0
			f.locvars = table.create(0)
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
			f.locvars[fs.nlocvars] = table.create(0) -- LocVar
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
			fs.h = table.create(0)  -- constant table; was luaH_new call
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
			local lexstate = table.create(0)  -- LexState
			lexstate.t = table.create(0)
			lexstate.lookahead = table.create(0)
			local funcstate = table.create(0)  -- FuncState
			funcstate.upvalues = table.create(0)
			funcstate.actvar = table.create(0)
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
			local key = table.create(0)  -- expdesc
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
			local key, val = table.create(0), table.create(0)  -- expdesc
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
			local cc = table.create(0)  -- ConsControl
			cc.v = table.create(0)
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
			local new_fs = table.create(0)  -- FuncState
			new_fs.upvalues = table.create(0)
			new_fs.actvar = table.create(0)
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
			local args = table.create(0)  -- expdesc
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
					local key = table.create(0)  -- expdesc
					luaK:exp2anyreg(fs, v)
					self:yindex(ls, key)
					luaK:indexed(fs, v, key)
				elseif c == ":" then  -- ':' NAME funcargs
					local key = table.create(0)  -- expdesc
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
				local v2 = table.create(0)  -- expdesc
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
			local bl = table.create(0)  -- BlockCnt
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
			local e = table.create(0)  -- expdesc
			-- test was: VLOCAL <= lh->v.k && lh->v.k <= VINDEXED
			local c = lh.v.k
			self:check_condition(ls, c == "VLOCAL" or c == "VUPVAL" or c == "VGLOBAL"
				or c == "VINDEXED", "syntax error")
			if self:testnext(ls, ",") then  -- assignment -> ',' primaryexp assignment
				local nv = table.create(0)  -- LHS_assign
				nv.v = table.create(0)
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
			local v = table.create(0)  -- expdesc
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
			local bl = table.create(0)  -- BlockCnt
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
			local bl1, bl2 = table.create(0), table.create(0)  -- BlockCnt
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
			local e = table.create(0)  -- expdesc
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
			local bl = table.create(0)  -- BlockCnt
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
			local e = table.create(0)  -- expdesc
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
			local bl = table.create(0)  -- BlockCnt
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
			local v, b = table.create(0), table.create(0)  -- expdesc
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
			local e = table.create(0)  -- expdesc
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
			local v, b = table.create(0), table.create(0)  -- expdesc
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
			local v = table.create(0)  -- LHS_assign
			v.v = table.create(0)
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
			local e = table.create(0)  -- expdesc
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
		local LuaState = table.create(0)  -- dummy, not actually used, but retained since
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
		local bit = bit32
		
		local lua_bc_to_state = nil
		local lua_wrap_state = nil
		local stm_lua_func = nil
		
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
		local AG = 'OpArgN'
		local AU = 'OpArgU'
		local AKYE = 'OpArgK'
		local OPCODE_M = {
			[0] = {b = 'OpArgR', c = AG},
			{b = AKYE, c = AG},
			{b = AU, c = AU},
			{b = 'OpArgR', c = AG},
			{b = AU, c = AG},
			{b = AKYE, c = AG},
			{b = 'OpArgR', c = AKYE},
			{b = AKYE, c = AG},
			{b = AU, c = AG},
			{b = AKYE, c = AKYE},
			{b = AU, c = AU},
			{b = 'OpArgR', c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = 'OpArgR', c = AG},
			{b = 'OpArgR', c = AG},
			{b = 'OpArgR', c = AG},
			{b = 'OpArgR', c = 'OpArgR'},
			{b = 'OpArgR', c = AG},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = AKYE, c = AKYE},
			{b = 'OpArgR', c = AU},
			{b = 'OpArgR', c = AU},
			{b = AU, c = AU},
			{b = AU, c = AU},
			{b = AU, c = AG},
			{b = 'OpArgR', c = AG},
			{b = 'OpArgR', c = AG},
			{b = AG, c = AU},
			{b = AU, c = AU},
			{b = AG, c = AG},
			{b = AU, c = AG},
			{b = AU, c = AG},
		}
		local function pow2(num)
			return math.pow(2, num)
		end
		-- int rd_int_basic(string src, int s, int e, int d)
		-- @src - Source binary string
		-- @s - Start index of a little endian integer
		-- @e - End index of the integer
		-- @d - Direction of the loop
		local function rd_int_basic(src, start, times, by)
			local num = 0
			
			for i = start, times, by do
				task.spawn(function()
					num += math.pow(256, math.abs(i - start)) * string.byte(src, i, i)
				end) --usually fast enough to be accurate will change if needed
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
					return sign * 9e909
				else
					return (0 / 0)
				end
			end
			
			return sign * pow2((exp - 127) * (1 + normal / pow2(23)))
		end
		
		-- double rd_dbl_basic(byte f1..8)
		-- @f1..8 - The 8 bytes composing a little endian double
		local function rd_dbl_basic(f1, f2, f3, f4, f5, f6, f7, f8)
			local sign = (-1) ^ bit.rshift(f8, 7)
			local exp = bit.lshift(bit.band(f8, 0x7F), 4) + bit.rshift(f7, 4)
			local frac = (bit.band(f7, 0x0F) * pow2(48)) + ((f6 * pow2(40)) + (f5 * pow2(32)) + (f4 * pow2(24)) + (f3 * pow2(16)) + (f2 * pow2(8)) + f1) / pow2(52)
			local normal = 1
			local nan = 0/0
			if exp == 0 then
				if frac == 0 then
					return frac
				else
					normal = 0
					exp = 1
				end
			elseif exp == 0x7FF then
				if frac == 0 then
					return sign * 9e909
				else
					return nan
				end
			end
			
			return sign * pow2((exp - 1023) * (normal + frac))
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
					data.is_KB = mode.b == AKYE and data.B > 0xFF -- post process optimization
					data.is_KC = mode.c == AKYE and data.C > 0xFF
				elseif args == 'ABx' then
					data.Bx = bit.band(bit.rshift(ins, 14), 0x3FFFF)
					data.is_K = mode.b == AKYE
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
			local proto = table.create(0)
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
			local open_list = table.create(0)
			local memory = state.memory
			local pc = state.pc
			
			while true do
				local inst = code[pc]
				local op = inst.op
				pc += 1
				
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
								memory[inst.A] = table.create(0)
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
							pc += inst.sBx
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
									
									if (lhs == rhs) == (inst.A ~= 0) then pc += code[pc].sBx end
									
									pc += 1
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
								
								if (lhs < rhs) == (inst.A ~= 0) then pc += code[pc].sBx end
								
								pc += 1
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
							
							if inst.C ~= 0 then pc += 1 end
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
								
								if (lhs <= rhs) == (inst.A ~= 0) then pc += code[pc].sBx end
								
								pc += 1
							elseif op > 30 then
								if op < 32 then
									--[[CLOSURE]]
									local sub = subs[inst.Bx + 1] -- offset for 1 based index
									local nups = sub.num_upval
									local uvlist
									
									if nups ~= 0 then
										uvlist = table.create(0)
										
										for i = 1, nups do
											local pseudo = code[pc + i - 1]
											
											if pseudo.op == OPCODE_RM[0] then -- @MOVE
												uvlist[i - 1] = open_lua_upvalue(open_list, pseudo.B, memory)
											elseif pseudo.op == OPCODE_RM[4] then -- @GETUPVAL
												uvlist[i - 1] = upvals[pseudo.B]
											end
										end
										
										pc += nups
									end
									
									memory[inst.A] = lua_wrap_state(sub, env, uvlist)
								else
									--[[TESTSET]]
									local A = inst.A
									local B = inst.B
									
									if (not memory[B]) ~= (inst.C ~= 0) then
										memory[A] = memory[B]
										pc += code[pc].sBx
									end
									pc += 1
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
									
									pc += inst.sBx
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
									pc += 1
								end
								
								offset = (C - 1) * FIELDS_PER_FLUSH
								
								table.move(memory, A + 1, A + len, offset + 1, tab)
							else
								--[[NOT]]
								memory[inst.A] = not memory[inst.B]
							end
						else
							--[[TEST]]
							if (not memory[inst.A]) ~= (inst.C ~= 0) then pc += code[pc].sBx end
							pc += 1
						end
					else
						--[[TFORLOOP]]
						local A = inst.A
						local base = A + 3
						
						local vals = {memory[A](memory[A + 1], memory[A + 2])}
						
						table.move(vals, 1, inst.C, base, memory)
						
						if memory[base] ~= nil then
							memory[A + 2] = memory[base]
							pc += code[pc].sBx
						end
						
						pc += 1
					end
				else
					--[[JMP]]
					pc += inst.sBx
				end
				
				state.pc = pc
			end
		end
		
		function lua_wrap_state(proto, env, upval)
			local function wrapped(...)
				local passed = table.pack(...)
				local memory = table.create(proto.max_stack)
				local vararg = {len = 0, list = table.create(0)}
				
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
	
	return function(source, env)
		local executable
		local env = env or getfenv(2)
		local ran, failureReason = pcall(function()
			local compiledBytecode = compile(source,  "")
			executable = createExecutable(compiledBytecode, env)
		end)
		
		if ran then
			return setfenv(executable, env)
		end
		return failureReason
	end
end)()
task.spawn(function()
	repeat task.wait() until game:IsLoaded()
	local solaramode = false
	local NotifLib = Instance.new("ScreenGui")
	local Center = Instance.new("Frame")
	local Holder = Instance.new("Frame")
	local Template = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Main = Instance.new("TextLabel")
	local Secondary = Instance.new("TextLabel")
	local Y = Instance.new("TextButton")
	local UICorner_2 = Instance.new("UICorner")
	local N = Instance.new("TextButton")
	local UICorner_3 = Instance.new("UICorner")
	local UIListLayout = Instance.new("UIListLayout")
	
	NotifLib.Name = "NotifLib"
	NotifLib.Parent = game:GetService("CoreGui")
	NotifLib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	Center.Name = "Center"
	Center.Parent = NotifLib
	Center.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Center.BackgroundTransparency = 1
	Center.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Center.BorderSizePixel = 0
	Center.Position = UDim2.new(0.5, 0, 0, 0)
	Center.Size = UDim2.new(0, 1, 0, 1)
	
	Holder.Name = "Holder"
	Holder.Parent = Center
	Holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Holder.BackgroundTransparency = 1
	Holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Holder.BorderSizePixel = 0
	Holder.Position = UDim2.new(-124, 0, 16, 0)
	Holder.Size = UDim2.new(0, 250, 0, 300)
	
	Template.Name = "Template"
	Template.Parent = Holder
	Template.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	Template.BackgroundTransparency = 0.400
	Template.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Template.BorderSizePixel = 0
	Template.Position = UDim2.new(0, -124, 0, 16)
	Template.Size = UDim2.new(0, 250, 0, 100)
	Template.Visible = false
	
	UICorner.Parent = Template
	
	Main.Name = "Main"
	Main.Parent = Template
	Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Main.BackgroundTransparency = 1
	Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Main.BorderSizePixel = 0
	Main.Position = UDim2.new(0.200000003, 0, 0.0900000036, 0)
	Main.Size = UDim2.new(0, 150, 0, 25)
	Main.Font = Enum.Font.Unknown
	Main.Text = "Lorem Ipsum"
	Main.TextColor3 = Color3.fromRGB(255, 255, 255)
	Main.TextScaled = true
	Main.TextSize = 14.000
	Main.TextWrapped = true
	
	Secondary.Name = "Secondary"
	Secondary.Parent = Template
	Secondary.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Secondary.BackgroundTransparency = 1
	Secondary.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Secondary.BorderSizePixel = 0
	Secondary.Position = UDim2.new(0.100000001, 0, 0.340000004, 0)
	Secondary.Size = UDim2.new(0, 200, 0, 40)
	Secondary.Font = Enum.Font.Unknown
	Secondary.Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam placerat velit arcu, vitae bibendum risus fringilla ac."
	Secondary.TextColor3 = Color3.fromRGB(255, 255, 255)
	Secondary.TextScaled = true
	Secondary.TextSize = 14.000
	Secondary.TextWrapped = true
	
	Y.Name = "Y"
	Y.Parent = Template
	Y.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	Y.BackgroundTransparency = 0.500
	Y.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Y.BorderSizePixel = 0
	Y.Position = UDim2.new(0.699999988, 0, 0.74000001, 0)
	Y.Size = UDim2.new(0, 50, 0, 20)
	Y.Font = Enum.Font.Unknown
	Y.Text = "Yes"
	Y.TextColor3 = Color3.fromRGB(255, 255, 255)
	Y.TextScaled = true
	Y.TextSize = 14.000
	Y.TextWrapped = true
	
	UICorner_2.CornerRadius = UDim.new(0, 5)
	UICorner_2.Parent = Y
	
	N.Name = "N"
	N.Parent = Template
	N.BackgroundColor3 = Color3.fromRGB(25, 29, 38)
	N.BackgroundTransparency = 0.500
	N.BorderColor3 = Color3.fromRGB(0, 0, 0)
	N.BorderSizePixel = 0
	N.Position = UDim2.new(0.100000001, 0, 0.74000001, 0)
	N.Size = UDim2.new(0, 50, 0, 20)
	N.Font = Enum.Font.Unknown
	N.Text = "No"
	N.TextColor3 = Color3.fromRGB(255, 255, 255)
	N.TextScaled = true
	N.TextSize = 14.000
	N.TextWrapped = true
	
	UICorner_3.CornerRadius = UDim.new(0, 5)
	UICorner_3.Parent = N
	
	UIListLayout.Parent = Holder
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 5)
	
	Main.FontFace = Font.new("rbxassetid://11702779409")
	Secondary.FontFace = Font.new("rbxassetid://11702779409")
	Y.FontFace = Font.new("rbxassetid://11702779409")
	N.FontFace = Font.new("rbxassetid://11702779409")
	
	local notiflib = table.create(0)
	local temp = Template
	local core = Holder
	
	notiflib.Notify = function(header,details,time,callback,data)
		if not header then error("No Header Text...") end
		if typeof(header) ~= "string" then error("Header Text MUST be a string!") end
		if not details then error("No Detail Text...") end
		if typeof(details) ~= "string" then error("Detail Text MUST be a string!") end
		local notif = temp:Clone()
		notif.Name = "Notification"
		notif.Parent = core
		if not data then
			notif.Y.Visible = false
			notif.N.Visible = false
		end
		local script = Instance.new("LocalScript", notif)
		notif.Transparency = 1
		notif.Y.Transparency = 1
		notif.N.Transparency = 1
		notif.Y.TextTransparency = 1
		notif.N.TextTransparency = 1
		notif.Main.TextTransparency = 1
		notif.Secondary.TextTransparency = 1
		notif.Main.Text = header
		notif.Secondary.Text = details
		local stroke = Instance.new("UIStroke", notif)
		stroke.Color = Color3.fromRGB(255,255,255)
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.Transparency = 0.9
		local s2 = stroke:Clone()
		s2.Parent = notif.Y
		s2.Transparency = 0.8
		local s3 = s2:Clone()
		s3.Parent = notif.N
		notif.Visible = true
		local sound = Instance.new("Sound", workspace)
		sound.SoundId = "rbxassetid://4612373884"
		sound.Volume = 2
		sound.Looped = false
		sound.Playing = true
		game:GetService("TweenService"):Create(notif,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.4}):Play()
		game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.5}):Play()
		game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=0.5}):Play()
		game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.Main,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		game:GetService("TweenService"):Create(notif.Secondary,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=0}):Play()
		local function dest()
			game:GetService("TweenService"):Create(notif,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {Transparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Y,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.N,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Main,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			game:GetService("TweenService"):Create(notif.Secondary,TweenInfo.new(0.3,Enum.EasingStyle.Quint), {TextTransparency=1}):Play()
			wait(0.3)
			wait(0.1)
			notif:Destroy()
			sound:Destroy()
		end
		if data then
			notif.N.Text = data[1]
			notif.Y.Text = data[2]
			local h = false
			notif.N.Activated:Connect(function()
				if h == false then
					h = true
					callback(false)
					dest()
				end
			end)
			notif.Y.Activated:Connect(function()
				if h == false then
					h = true
					callback(true)
					dest()
				end
			end)
		end
		delay(time,dest)
	end
	notiflib.Notify("", "Injected", 5)
	local objectbridge = Instance.new("ObjectValue", game.CoreGui)
	objectbridge.Name = "GETBYTECODE"
	local cevery = false
	local env = nil
	local wrapped = table.create(0)
	local cachedi = table.create(0)
	local wrap = nil
	local vim = Instance.new("VirtualInputManager")
	local execname = "humorouscartel"
	local indexable = game.HttpService:GenerateGUID(false) --to prevent easily unwrapping our own shit yk to break out of the wrap
	local blockedmethods = {"PromptBundlePurchase","PerformPurchaseV2", "PromptGamePassPurchase", "PromptProductPurchase", "PromptPurchase", "PromptRobloxPurchase", "PromptThirdPartyPurchase", "OpenBrowserWindow", "OpenNativeOverlay", "HttpRequestAsync", "AddCoreScriptLocal", "EmitHybridEvent", "ExecuteJavaScript", "OpenBrowserWindow", "OpenNativeOverlay", "ReturnToJavaScript", "SendCommand", "Call", "GetLast", "GetMessageId", "GetProtocolMethodRequestMessageId", "GetProtocolMethodResponseMessageId", "MakeRequest", "Publish", "PublishProtocolMethodRequest", "PublishProtocolMethodResponse", "Subscribe", "SubscribeToProtocolMethodRequest","SubscribeToProtocolMethodResponse","MakeRequest","ReportAbuse","ReportAbuseV3"} --put your blocked methods as strings capitals dont matter lmao
	local unwrap = nil
	local debuginstance = false
	local debuginstancebutnotlaggyasshit = false
	local raped = table.create(0)
	local game = game
	if solaramode == true then
		game = getfenv(loadfile).unwrap(game)
	end
	
	local bridge = table.create(0)
	
	function bridge:send(action, ...) 
		local args = {...}
		local success, res = pcall(function()
			
			local url = "http://localhost:8000/bridge?action=" .. action
			for i, arg in ipairs(args) do
				url = url .. "&arg" .. i .. "=" .. game.HttpService:UrlEncode(tostring(arg))
			end
			local params = {
				Url = url,
				Method = "GET",
				Headers = {
					["Content-Type"] = "application/json"
				}
			}
			local request = game.HttpService:RequestInternal(params)
			local response = nil
			local requestCompletedEvent = Instance.new("BindableEvent")
			request:Start(function(success, result)
				response = result
				requestCompletedEvent:Fire()
			end)
			requestCompletedEvent.Event:Wait()
			
			if response.StatusMessage == "OK" then 
				return game.HttpService:JSONDecode(response.Body) 
			end
		end)
		if not success then
			warn("[ERRRO] -> "..tostring(res))
			return "ERROR: " .. tostring(res)
		else
			return res
		end
	end
	
	wrap = function(towrap)
		if table.find(wrapped,towrap) then
			return raped[table.find(wrapped,towrap)]
		end
		if debuginstance == true then
			print("wrapped:",towrap)
		end
		local id = #wrapped + 1
		wrapped[id] = towrap
		local newstance = newproxy(true)
		raped[id] = newstance
		local meta = getmetatable(newstance)
		meta.__index = function(_,index)
			index = string.gsub(index, "\0", "")
			if debuginstancebutnotlaggyasshit == true then
				print(towrap, "indexed with",index)
			end
			local _, t_index = pcall(function()
				return towrap[index]
			end)
			if index == indexable then
				return function(_,...)
					return id
				end
			end
			if string.lower(index) == "getservice" or string.lower(index) == "service" then
				return function(_, ...)
					if ... == "VirtualInputManager" then
						return wrap(Instance.new("VirtualInputManager"))
					end
					return wrap(game:GetService(...))
				end
			elseif index == "HttpGet" then
				return function(self, url)    
					assert(typeof(url)=="string", "Expected string for URL")
					local toret
					local W = Instance.new("BindableEvent")
					game:GetService("HttpService"):RequestInternal({Url = url:gsub('roblox.com','roproxy.com'), CachePolicy = Enum.HttpCachePolicy.None, Headers = {["Fingerprint"] = "FINGERME"}}):Start(function(success, data)
						toret = data.Body
						
						W:fire()
					end)
					
					W.Event:Wait()
					
					return toret
				end
				
			elseif t_index and type(t_index) == "function" and index == "Connect" then
				return function(_, func)
					towrap:Connect(function(A)
						if type(A) == "userdata" then
							A = wrap(A)
						end
						return A
					end)
				end
			elseif t_index and type(t_index) == "function" then
				if table.find(blockedmethods, string.lower(index)) then
					error(execname .. " has blocked this method for security reason's.",2)
				end
				return function(_, ...)
					local balls = t_index(towrap, ...)
					if type(balls) == "table" and type(balls[1]) == "userdata" then
						for i, v in pairs(balls) do
							balls[i] = wrap(v)
						end
					end
					return balls
				end
			elseif string.lower(index) == "clone" then
				return wrap(towrap:Clone())
			elseif t_index and type(t_index) ~= "userdata" then
				return t_index
			elseif t_index and type(t_index) == "userdata" then
				local toret = t_index
				if table.find(wrapped, toret) then
					local index = table.find(wrapped, toret)
					toret = raped[index]
				else
					toret = wrap(toret)
				end
				return toret
			else
				local toret = nil
				if towrap == game then
					toret = game:GetService(index)
					if toret == nil then
						toret = game[index]
					end
				else
					toret = towrap[index]
				end
				if table.find(wrapped, toret) then
					local index = table.find(wrapped, toret)
					toret = raped[index]
				end
				return toret
			end
		end
		meta.__newindex = function(_, toset, thing)
			if debuginstancebutnotlaggyasshit == true then
				print(towrap, "set value", toset, "to", thing)
			end
			thing = unwrap(thing)
			local worked, result = pcall(function()
				towrap[toset] = thing
			end)
			if not worked then
				error(result,2)
			end
		end
		meta.__metatable = "This metatable is locked"
		meta.__tostring = tostring(towrap)
		return newstance
	end
	
	unwrap = function(wrappedw)
		local worked, unwrapped = pcall(function()
			local ida = wrappedw[indexable]
			local id = ida()
			return wrapped[id]
		end)
		if worked == false then
			--handle errors maybe
		end
		local unwrapped = unwrapped or wrappedw
		if type(unwrapped) == "string" then
			unwrapped = wrappedw
		end
		return unwrapped
	end
	local anew = Instance.new
	local new = function(class, parent)
		if debuginstancebutnotlaggyasshit == true then
			print("made", class, "with parent", unwrap(parent))
		end
		parent = unwrap(parent)
		local thing = anew(class, parent)
		local new = wrap(thing)
		if parent == nil then
			cachedi[new] = new
		end
		return new
	end
	
	local Instance = table.create(0)
	Instance.new = new
	
	local topg = game
	local game = wrap(game)
	local workspace = game.Workspace
	local renv = table.create(0)
	local defenv = {"DockWidgetPluginGuiInfo","warn","tostring","gcinfo","os","tick","task","getfenv","pairs","NumberSequence","assert","rawlen","tonumber","CatalogSearchParams","Enum","Delay","OverlapParams","Stats","_G","UserSettings","coroutine","NumberRange","buffer","shared","NumberSequenceKeypoint","PhysicalProperties","PluginManager","Vector2int16","UDim2","loadstring","printidentity","Version","Vector2","UDim","Game","delay","spawn","Ray","string","xpcall","SharedTable","RotationCurveKey","DateTime","print","ColorSequence","debug","RaycastParams","Workspace","unpack","TweenInfo","Random","require","Vector3","bit32","Vector3int16","setmetatable","next","Instance","Font","FloatCurveKey","ipairs","plugin","Faces","rawequal","Region3int16","collectgarbage","game","getmetatable","Spawn","ColorSequenceKeypoint","Region3","utf8","Color3","CFrame","rawset","PathWaypoint","typeof","workspace","ypcall","settings","Wait","math","version","pcall","stats","elapsedTime","type","wait","ElapsedTime","select","time","DebuggerManager","rawget","table","Rect","BrickColor","setfenv","_VERSION","Axes","error","newproxy",}
	for i, v in pairs(defenv) do
		renv[v] = getfenv()[v]
	end
	local instances_reg = setmetatable({ [game] = true }, { __mode = "ks" })
	local touchers_reg = setmetatable({}, { __mode = "ks" })
	
	local function addToInstancesReg(descendant: Instance)
		if instances_reg[descendant] then
			return
		end
		instances_reg[descendant] = true
	end
	local function filterAllInstances(filter)
		local result = {}
		local idx = 1
		
		for instance in instances_reg do
			if not (filter(instance)) then
				continue
			end
			result[idx] = instance
			idx += 1
		end
		return result
	end
	
	game.DescendantAdded:Connect(addToInstancesReg)
	game.DescendantRemoving:Connect(addToInstancesReg)
	
	
	local function table_find(t, val)
		for i,v in t do
			if v == val then
				return i
			end
		end
	end
	
	local function getc(str)
		local sum = 0
		for i,v in pairs(str:split("")) do
			sum += string.byte(sum)
		end
		return sum
	end
	

	
	defenv = nil
	local genv = table.create(0)
	--Defaults
	genv.game = game
	genv.workspace = workspace
	genv.Instance = Instance
	genv.Game = game
	genv.Workspace = workspace
	renv.game = game
	renv.Game = game
	renv.workspace = workspace
	renv.Workspace = workspace
	--UNC
	genv.identifyexecutor = function()
		return execname, "1.0.0 NIGGER EDITION"
	end
	
	genv.spoofinstance = function(spoofing, new_instance)
		assert(typeof(spoofing) == "Instance", `arg #1 must be type Instance`)
		assert(typeof(new_instance) == "Instance" or type(new_instance) == "number", `arg #2 must be type Instance`) -- ? or number ?
		task.spawn(bridge.send, bridge, "spoof_instance", spoofing, new_instance)
	end
	
	genv.getmodules = function()
		return filterAllInstances(function(instance)
			return instance:IsA("ModuleScript")
		end)
	end
	
	genv.base64_encode = function(args)
		local self1 = bridge:send("base64encode", args)
		return self1
	end
	
	genv.base64_decode = function(args)
		local self1 = bridge:send("base64decode", args)
		return self1
	end
	
	if not getgenv().crypt then
		getgenv().crypt = {}
	end
	
	genv.crypt = {
		base64encode = function(args)
			local self1 = bridge:send("base64encode", args)
			return self1
		end;
		base64decode = function(args)
			local self1 = bridge:send("base64decode", args)
			return self1
		end;
		encrypt = function(str, key, iv, cbc)
			iv = iv or "lol"
			local byteChange = (getc(cbc)+getc(iv)+getc(key))%7
			local res = ""
			for _,v in pairs(str:split("")) do
				res = res..(string.char(string.byte(v)+byteChange))
			end
			return res, iv
		end;
		decrypt = function(str, key, iv, cbc)
			local bC = (getc(cbc)+getc(iv)+getc(key))%7
			local res = ""
			for _,v in pairs(str:split("")) do
				res = res..(string.char(string.byte(v)-bC))
			end
			return res
		end;
		generatebytes = function(size)
			if type(size) ~= 'number' then
				return error('missing arguement #1 to \'generatebytes\' (number expected)')
			end
			return genv.crypt.generatekey(size) -- must run this unc fix first
		end;
		generatekey = function(size)
			local size = size or 32
			local tab = table.create(size)
			for i=1, size do
				tab[i] = string.char(math.random(0, 255))
			end
			return genv.base64_encode(table.concat(tab))
		end;
	}
	
	genv.getinfo = function(func)
		local funcName = table_find(genv, func)
		return {
			source = "=[env]",
			short_src = " ",
			func = func,
			what = funcName ~= nil and "C" or "Lua",
			currentline = -1,
			name = funcName or "unknown",
			nups = -1,
			numparams = -1,
			is_vararg = 0
		}
	end
	
	genv.debug = {
		getinfo = genv.getinfo,
		info = function(f, o)
			if o:lower() == "s" then
				for i,v in genv do
					if f == v then
						return "[C]"
					end
				end
				return debug.info(f,o)
			else
				return debug.info(f,o)
			end
		end,
		getprotos = function()
			return {}
		end,
		getproto = function(_,_,b)
			local f = function()
				return b
			end
			return b and {f} or f
		end,
		getstack = function(_,a)
			return not a and {"ab"} or "ab"
		end,
		getconstant = function(_,i)
			local t = {[1] = "print", [3] = "Hello, world!"}
			return t[i]
		end,
		getconstants = function()
			return {}
		end,
		getupvalues = function()
			return {}
		end,
		setconstant = function()
			return {}
		end,
		getupvalue = function()
			return {}
		end,
		setstack = function()
			return {}
		end,
		setupvalue = function()
			return {}
		end,
	}
	
	genv.fireclickdetector = function(fcd, distance, event)
		local ClickDetector = fcd:FindFirstChild("ClickDetector") or fcd
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
	
	genv.sethiddenproperty = function(instance, property_name, value)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		assert(type(property_name) == "string", `arg #2 must be type string`)
		local was_scriptable = genv.setscriptable(instance, property_name, true)
		local o, err = pcall(function()
		instance[property_name] = value
		end)
		if not was_scriptable then
		genv.setscriptable(instance, property_name, was_scriptable)
		end
		if o then
		return was_scriptable
		else
		error(err, 2)
		end
	end
	
	local _loaded_saveinstance
	
	genv.saveinstance = function(...)
		if not _loaded_saveinstance then
			local params = {
				RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
				SSI = "saveinstance",
			}
			
			local content = genv.httpget(params.RepoURL .. params.SSI .. ".luau", true)
			_loaded_saveinstance = genv.loadstring(content, params.SSI)()
		end
		
		return _loaded_saveinstance(...)
	end
	
	genv.gethiddenproperty = function(instance, property_name)
		assert(typeof(instance) == "Instance", `arg #1 must be type Instance`)
		assert(type(property_name) == "string", `arg #2 must be type string`)
		if genv.isscriptable(instance, property_name) then
			return instance[property_name] -- * This will error if it's an invalid property but that should intended
		end
		return genv.gethiddenproperties(instance)[property_name]
	end
	
	genv.firetouchinterest = function(toucher: BasePart, to_touch: BasePart, touch_value: number)
		assert(typeof(toucher) == "Instance" and toucher:IsA("BasePart"), `arg #1 must be BasePart`)
		assert(typeof(to_touch) == "Instance" and to_touch:IsA("BasePart"), `arg #2 must be BasePart`)
		assert(type(touch_value) == "number", "arg #3 must be type number")
		if not touchers_reg[toucher] then
			touchers_reg[toucher] = {}
		end
		local part_address = genv.getinstanceaddress(to_touch)
		if touch_value == 0 then
			if touchers_reg[toucher][part_address] then
				return
			end
			local fake_part = Instance.new("Part", to_touch)
			fake_part.CanCollide = false
			fake_part.CanTouch = true
			fake_part.Anchored = true
			fake_part.Transparency = 1
			
			genv.spoofinstance(fake_part, to_touch)
			touchers_reg[toucher][part_address] = task.spawn(function()
				while true do
					fake_part.CFrame = toucher.CFrame
					task.wait()
				end
			end)
		elseif touch_value == 1 then
			if not touchers_reg[toucher][part_address] then
				return
			end
			genv.spoofinstance(to_touch, part_address)
			local toucher_thread = table.remove(touchers_reg[toucher], part_address)
			task.cancel(toucher_thread)
		end
	end
	
	genv.fireproximityprompt = function(proximityprompt, amount, skip)
		assert(
			typeof(proximityprompt) == "Instance" and proximityprompt:IsA("ProximityPrompt"),
			`arg #1 must be ProximityPrompt`
		)
		
		if amount ~= nil then
			assert(type(amount) == "number", `arg #2 must be type number`)
			if skip ~= nil then
				assert(type(skip) == "boolean", `arg #3 must be type boolean`)
			end
		end
		
		local oldHoldDuration = proximityprompt.HoldDuration
		local oldMaxDistance = proximityprompt.MaxActivationDistance
		
		proximityprompt.MaxActivationDistance = 9e9 -- client replicated only
		proximityprompt:InputHoldBegin()
		
		for i = 1, amount or 1 do -- or 1 cuz number can be nil
			if skip then
				proximityprompt.HoldDuration = 0
			else
				task.wait(proximityprompt.HoldDuration + 0.01) -- better than wait()
			end
		end
		
		proximityprompt:InputHoldEnd()
		proximityprompt.MaxActivationDistance = oldMaxDistance
		proximityprompt.HoldDuration = oldHoldDuration
	end
	
	genv.setsimulationradius = function(newRadius, newMaxRadius)
		assert(newRadius, `arg #1 is missing`)
		assert(type(newRadius) == "number", `arg #1 must be type number`)
		
		local LocalPlayer = game:GetService("Players").LocalPlayer
		if LocalPlayer then
			LocalPlayer.SimulationRadius = newRadius
			LocalPlayer.MaximumSimulationRadius = newMaxRadius or newRadius
		end
	end
	
	genv.isnetworkowner = function(part)
		assert(typeof(part) == "Instance" and part:IsA("BasePart"), `arg #1 must be BasePart`)
		if part.Anchored then
			return false
		end
		return part.ReceiveAge == 0
	end
	
	genv.newcclosure = function(func)
		local func2 = nil
		func2 = function(...)
			genv[func] = coroutine.wrap(func2)
			return func(...)
		end
		func2 = coroutine.wrap(func2)
		return func2
	end
	genv.iscclosure = function(func)
		return debug.info(func, "s") == "[C]"
	end
	genv.islclosure = function(func)
		return debug.info(func, "s") ~= "[C]"
	end
	genv.newlclosure = function(func) --i see this in other executors? why the fuck does it exist? dm me if you know 🙏
		return function(bullshit)
			return func(bullshit)
		end
	end
	genv.keypress = function(key)
		vim:SendKeyEvent(true, key, false, nil)
	end
	
	genv.mouse1click = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 0, true, game, false)
		task.wait()
		vim:SendMouseButtonEvent(x, y, 0, false, game, false)
	end
	
	genv.mouse2click = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 1, true, game, false)
		task.wait()
		vim:SendMouseButtonEvent(x, y, 1, false, game, false)
	end
	
	genv.mouse1press = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 0, true, game, false)
	end
	
	genv.mouse1release = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 0, false, game, false)
	end
	
	genv.mouse2press = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 1, true, game, false)
	end
	
	genv.mouse2release = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseButtonEvent(x, y, 1, false, game, false)
	end
	
	genv.mousescroll = function(x, y, a)
		x = x or 0
		y = y or 0
		a = a or 0
		vim:SendMouseWheelEvent(x, y, a, game)
	end
	
	genv.mousemoverel = function(relx, rely)
		local pos = workspace.CurrentCamera.ViewportSize
		relx = relx or 0
		rely = rely or 0
		local x = pos.X * relx
		local y = pos.Y * rely
		vim:SendMouseMoveEvent(x, y, game)
	end
	
	genv.mousemoveabs = function(x, y)
		x = x or 0
		y = y or 0
		vim:SendMouseMoveEvent(x, y, game)
	end
	
	genv.setthreadidentity = function(threadidentity)
		threadidentity = genv.getthreadidentity
	end
	
	genv.keyrelease = function(key)
		vim:SendKeyEvent(false, key, false, nil)
	end
	genv.getobjects = function(id)
		if not string.find(tostring(id), "rbxassetid://") then
			id = "rbxassetid://" .. tostring(id)
		end
		return { game:GetService("InsertService"):LoadLocalAsset(id) }
	end
	
	genv.getrawmetatable = function(obj)
		local mt = getmetatable(obj)
		if typeof(mt) ~= "table" then 
			return setmetatable({}, {
				__index = function(self, name)
					return obj[name]
				end,
				__newindex = function(self, name, value)
					obj[name] = value
				end,
				__eq = function(self, eq)
					return typeof(eq) == "table"
				end,
				__len = function()
					return #obj
				end,
			})
		else
			return mt
		end
	end
	
	getgenv().hookfunction = function(func, rep)
		for i,v in pairs(getfenv()) do
			if v == func then
				getfenv()[i] = rep
			end
		end
	end
	
	getgenv().rconsoletablerem = {}
	local par = game:GetService("CoreGui")
	getgenv().rconsolecreate = function(text, color)
		if not par:FindFirstChild("rconsole") then
			getgenv().rconsoletablerem = {}
			getgenv().rconsoleConverted = {
				["_rconsole"] = Instance.new("ScreenGui");
				["_Frame"] = Instance.new("Frame");
				["_min"] = Instance.new("TextButton");
				["_LocalScript"] = Instance.new("LocalScript");
				["_TextBox"] = Instance.new("TextBox");
				["_max1"] = Instance.new("TextButton");
				["_max2"] = Instance.new("TextButton");
				["_max3"] = Instance.new("TextButton");
				["_max4"] = Instance.new("TextButton");
				["_close"] = Instance.new("TextButton");
				["_closescript"] = Instance.new("LocalScript");
				["_TextLabel"] = Instance.new("TextLabel");
				["_Dragify"] = Instance.new("LocalScript");
				["_LocalScript1"] = Instance.new("LocalScript");
			}
		end
		getgenv().rconsoleConverted["_rconsole"].ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		getgenv().rconsoleConverted["_rconsole"].Name = "rconsole"
		getgenv().rconsoleConverted["_rconsole"].Parent = par
		
		getgenv().rconsoleConverted["_Frame"].BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_Frame"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_Frame"].BorderSizePixel = 0
		if not par:FindFirstChild("rconsole") then
			getgenv().rconsoleConverted["_Frame"].Position = UDim2.new(0.36141479, 0, 0.332802534, 0)
		else
			getgenv().rconsoleConverted["_Frame"].Position = getgenv().rconsoleConverted["_Frame"].Position
		end
		getgenv().rconsoleConverted["_Frame"].Size = UDim2.new(0, 694, 0, 294)
		getgenv().rconsoleConverted["_Frame"].Parent = getgenv().rconsoleConverted["_rconsole"]
		getgenv().rconsoleConverted["_min"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_min"].Text = "-"
		getgenv().rconsoleConverted["_min"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_min"].TextSize = 72
		getgenv().rconsoleConverted["_min"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_min"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_min"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_min"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_min"].Position = UDim2.new(0.877521634, 0, -0.0510204099, 0)
		getgenv().rconsoleConverted["_min"].Size = UDim2.new(0, 15, 0, 50)
		getgenv().rconsoleConverted["_min"].Name = "min"
		getgenv().rconsoleConverted["_min"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_TextBox"].CursorPosition = -1
		getgenv().rconsoleConverted["_TextBox"].ClearTextOnFocus = false
		getgenv().rconsoleConverted["_TextBox"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_TextBox"].RichText = true
		getgenv().rconsoleConverted["_TextBox"].Text = ""
		getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(204.0000182390213, 204.0000182390213, 204.0000182390213) -- nah
		getgenv().rconsoleConverted["_TextBox"].TextDirection = Enum.TextDirection.RightToLeft
		getgenv().rconsoleConverted["_TextBox"].TextEditable = false
		getgenv().rconsoleConverted["_TextBox"].TextSize = 14
		getgenv().rconsoleConverted["_TextBox"].TextWrapped = true
		getgenv().rconsoleConverted["_TextBox"].TextXAlignment = Enum.TextXAlignment.Left
		getgenv().rconsoleConverted["_TextBox"].TextYAlignment = Enum.TextYAlignment.Top
		getgenv().rconsoleConverted["_TextBox"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_TextBox"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_TextBox"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_TextBox"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_TextBox"].Position = UDim2.new(0, 0, 0.119047619, 0)
		getgenv().rconsoleConverted["_TextBox"].Size = UDim2.new(0, 694, 0, 259)
		getgenv().rconsoleConverted["_TextBox"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_max1"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_max1"].Text = "-"
		getgenv().rconsoleConverted["_max1"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max1"].TextSize = 72
		getgenv().rconsoleConverted["_max1"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max1"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_max1"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_max1"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_max1"].Position = UDim2.new(0.793982983, 0, 0.0546244942, 0)
		getgenv().rconsoleConverted["_max1"].Rotation = -90
		getgenv().rconsoleConverted["_max1"].Size = UDim2.new(0, 200, 0, 0)
		getgenv().rconsoleConverted["_max1"].Name = "max1"
		getgenv().rconsoleConverted["_max1"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_max2"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_max2"].Text = "-"
		getgenv().rconsoleConverted["_max2"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max2"].TextSize = 72
		getgenv().rconsoleConverted["_max2"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max2"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_max2"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_max2"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_max2"].Position = UDim2.new(0.775181472, 0, 0.0546244942, 0)
		getgenv().rconsoleConverted["_max2"].Rotation = -90
		getgenv().rconsoleConverted["_max2"].Size = UDim2.new(0, 200, 0, 0)
		getgenv().rconsoleConverted["_max2"].Name = "max2"
		getgenv().rconsoleConverted["_max2"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_max3"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_max3"].Text = "-"
		getgenv().rconsoleConverted["_max3"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max3"].TextSize = 72
		getgenv().rconsoleConverted["_max3"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max3"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_max3"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_max3"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_max3"].Position = UDim2.new(0.937443197, 0, -0.0748299286, 0)
		getgenv().rconsoleConverted["_max3"].Size = UDim2.new(0, 0, 0, 50)
		getgenv().rconsoleConverted["_max3"].Name = "max3"
		getgenv().rconsoleConverted["_max3"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_max4"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_max4"].Text = "-"
		getgenv().rconsoleConverted["_max4"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max4"].TextSize = 72
		getgenv().rconsoleConverted["_max4"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_max4"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_max4"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_max4"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_max4"].Position = UDim2.new(0.937443197, 0, -0.0306122452, 0)
		getgenv().rconsoleConverted["_max4"].Size = UDim2.new(0, 2, 0, 50)
		getgenv().rconsoleConverted["_max4"].Name = "max4"
		getgenv().rconsoleConverted["_max4"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_close"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_close"].Text = "X"
		getgenv().rconsoleConverted["_close"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_close"].TextSize = 27
		getgenv().rconsoleConverted["_close"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_close"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_close"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_close"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_close"].Position = UDim2.new(0.962536037, 0, 0, 0)
		getgenv().rconsoleConverted["_close"].Size = UDim2.new(0, 26, 0, 35)
		getgenv().rconsoleConverted["_close"].Name = "close"
		getgenv().rconsoleConverted["_close"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		getgenv().rconsoleConverted["_TextLabel"].Font = Enum.Font.SourceSans
		getgenv().rconsoleConverted["_TextLabel"].RichText = true
		getgenv().rconsoleConverted["_TextLabel"].Text = ""
		getgenv().rconsoleConverted["_TextLabel"].TextColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_TextLabel"].TextScaled = true
		getgenv().rconsoleConverted["_TextLabel"].TextSize = 14
		getgenv().rconsoleConverted["_TextLabel"].TextWrapped = true
		getgenv().rconsoleConverted["_TextLabel"].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		getgenv().rconsoleConverted["_TextLabel"].BackgroundTransparency = 1
		getgenv().rconsoleConverted["_TextLabel"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		getgenv().rconsoleConverted["_TextLabel"].BorderSizePixel = 0
		getgenv().rconsoleConverted["_TextLabel"].Size = UDim2.new(0, 609, 0, 42)
		getgenv().rconsoleConverted["_TextLabel"].Parent = getgenv().rconsoleConverted["_Frame"]
		
		
		local fake_module_scripts = {}
		
		local function BDYORWU_fake_script() -- Fake Script: StarterGui.rconsole.Frame.min.LocalScript
			local script = Instance.new("LocalScript")
			script.Name = "LocalScript"
			script.Parent = getgenv().rconsoleConverted["_min"]
			local req = require
			local require = function(obj)
				local fake = fake_module_scripts[obj]
				if fake then
					return fake()
				end
				return req(obj)
			end
			
			script.Parent.MouseButton1Down:Connect(function()
				script.Parent.Parent.Visible = false
			end)
		end
		local function FOWXFT_fake_script() -- Fake Script: StarterGui.rconsole.Frame.close.closescript
			local script = Instance.new("LocalScript")
			script.Name = "closescript"
			script.Parent = getgenv().rconsoleConverted["_close"]
			local req = require
			local require = function(obj)
				local fake = fake_module_scripts[obj]
				if fake then
					return fake()
				end
				return req(obj)
			end
			
			script.Parent.MouseButton1Down:Connect(function()
				script.Parent.Parent.Parent:Destroy()
			end)
		end
		local function JLOCYX_fake_script() -- Fake Script: StarterGui.rconsole.Frame.Dragify
			local script = Instance.new("LocalScript")
			script.Name = "Dragify"
			script.Parent = getgenv().rconsoleConverted["_Frame"]
			local req = require
			local require = function(obj)
				local fake = fake_module_scripts[obj]
				if fake then
					return fake()
				end
				return req(obj)
			end
			
			local UIS = game:GetService("UserInputService")
			local function dragify(Frame)
				local dragToggle = nil
				local dragSpeed = 0.15
				local dragInput = nil
				local dragStart = nil
				local dragPos = nil
				local function updateInput(input)
					local Delta = input.Position - dragStart
					local Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + Delta.X, startPos.Y.Scale, startPos.Y.Offset + Delta.Y)
					game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.15), {
						Position = Position
					}):Play()
				end
				Frame.InputBegan:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and UIS:GetFocusedTextBox() == nil then
						dragToggle = true
						dragStart = input.Position
						startPos = Frame.Position
						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								dragToggle = false
							end
						end)
					end
				end)
				Frame.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
						dragInput = input
					end
				end)
				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if input == dragInput and dragToggle then
						updateInput(input)
					end
				end)
			end
			dragify(script.Parent)
			
		end
		local function OOBMK_fake_script() -- Fake Script: StarterGui.rconsole.LocalScript
			local script = Instance.new("LocalScript")
			script.Name = "LocalScript"
			script.Parent = getgenv().rconsoleConverted["_rconsole"]
			local req = require
			local require = function(obj)
				local fake = fake_module_scripts[obj]
				if fake then
					return fake()
				end
				return req(obj)
			end
			
			local uis = game:GetService("UserInputService")
			uis.InputBegan:Connect(function(inp)
				if inp.KeyCode == Enum.KeyCode.RightControl then
					script.Parent.Frame.Visible = not script.Parent.Frame.Visible
				end
			end)
		end
		
		coroutine.wrap(BDYORWU_fake_script)()
		coroutine.wrap(FOWXFT_fake_script)()
		coroutine.wrap(JLOCYX_fake_script)()
		coroutine.wrap(OOBMK_fake_script)()
	end
	getgenv().rconsoleclear = function()
		if not par:FindFirstChild("rconsole") then
			error("No Console Found.")
		else
			getgenv().rconsoleConverted["_TextBox"].Text = ""
			getgenv().rconsoletablerem = {}
			makeonestring = ""
		end
	end
	getgenv().rconsoleprint = function(text, color)
		text = text .. "\n"
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
		else
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			if getgenv().rconsoleConverted["_TextBox"].TextColor3 ~= Color3.fromRGB(204.0000182390213, 204.0000182390213, 204.0000182390213) then
				getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(204.0000182390213, 204.0000182390213, 204.0000182390213)
			end
		end
	end
	
	getgenv().rconsoleerr = function(text, color)
		text = text .. "\n"
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(255, 0, 0)
		else
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
	getgenv().rconsoleinfo = function(text, color)
		text = text .. "\n"
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(0, 204, 255)
		else
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(0, 204, 255)
		end
	end
	getgenv().rconsolewarn = function(text, color)
		text = text .. "\n"
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(238, 255, 0)
		else
			table.insert(getgenv().rconsoletablerem, text)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			getgenv().rconsoleConverted["_TextBox"].TextColor3 = Color3.fromRGB(238, 255, 0)
		end
	end
	getgenv().rconsoledestroy = function()
		if not par:FindFirstChild("rconsole") then
			error("No Console Found.")
		else
			par:FindFirstChild("rconsole"):Destroy()
		end
	end
	getgenv().rconsolesettitle = function(text)
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			getgenv().rconsoleConverted["_TextLabel"].Text = text
		else
			getgenv().rconsoleConverted["_TextLabel"].Text = text
		end
	end
	getgenv().rconsolename = function(text)
		if not par:FindFirstChild("rconsole") then
			rconsolecreate()
			task.wait(0.25)
			getgenv().rconsoleConverted["_TextLabel"].Text = text
		else
			getgenv().rconsoleConverted["_TextLabel"].Text = text
		end
	end
	getgenv().rconsoleinput = function()
		if not par:FindFirstChild("rconsole") then
			error("No Console Found.")
		else
			getgenv().rconsoleConverted["_TextBox"].TextEditable = true
			getgenv().rconsoleConverted["_TextBox"].Text = ""
			local toreturn = nil
			getgenv().rconsoleConverted["_TextBox"].InputEnded:Connect(function(inp)
				if inp.KeyCode == Enum.KeyCode.Return then
					toreturn = getgenv().rconsoleConverted["_TextBox"].Text
					getgenv().rconsoleConverted["_TextBox"].Text = ""
					getgenv().rconsoleConverted["_TextBox"].TextEditable = false
				end
			end)
			local prev = getgenv().rconsoletablerem
			makeonestring = table.concat(prev, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring .. string.gsub(getgenv().rconsoleConverted["_TextBox"].Text, makeonestring, "")
			repeat
				task.wait()
			until toreturn ~= nil
			toreturn = string.gsub(toreturn, makeonestring, "")
			table.insert(getgenv().rconsoletablerem, toreturn)
			makeonestring = table.concat(getgenv().rconsoletablerem, "")
			getgenv().rconsoleConverted["_TextBox"].Text = makeonestring
			return toreturn
		end
	end
	
	genv.customprint = function(text, properties, imageId)
		print(text)
		task.wait(.025)
		local msg = game:GetService("CoreGui").DevConsoleMaster.DevConsoleWindow.DevConsoleUI:WaitForChild("MainView").ClientLog[tostring(#game:GetService("CoreGui").DevConsoleMaster.DevConsoleWindow.DevConsoleUI.MainView.ClientLog:GetChildren())-1].msg
		for i, x in pairs(properties) do
			msg[i] = x
		end
		if imageId then
			msg.Parent.image.Image = imageId
		end
	end
	
	genv.getdevice = function()
		local inputsrv = game:GetService("UserInputService")
		if inputsrv:GetPlatform() == Enum.Platform.Windows then
			return 'Windows'
		elseif inputsrv:GetPlatform() == Enum.Platform.OSX then
			return 'macOS'
		elseif inputsrv:GetPlatform() == Enum.Platform.IOS then
			return 'iOS'
		elseif inputsrv:GetPlatform() == Enum.Platform.UWP then
			return 'Windows (Microsoft Store)'
		elseif inputsrv:GetPlatform() == Enum.Platform.Android then
			return 'Android'
		else
			return 'Unknown'
		end
	end
	
	genv.getplayers = function()
		local players = {}
		for _, x in pairs(game:GetService("Players"):GetPlayers()) do
			players[x.Name] = x
		end
		players["LocalPlayer"] = game:GetService("Players").LocalPlayer
		return players
	end
	
	genv.setfpscap = function(bruh)
		local SetTo = bruh or 0
		if SetTo == 0 then SetTo = SetTo > 0 and 1.0 / SetTo or 1.0 / 10000.0 end
		game:GetService("TaskSchedulerTargetFps", tostring(SetTo))
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		settings().Rendering.AntiAliasing = Enum.AntiAliasingMode.None
		settings().Rendering.PerformanceStatsEnabled = false
		game:GetService("RunService"):Set3dRenderingEnabled(false)
		settings().Physics.AllowSleep = false
		game:GetService("RunService").Stepped:Connect(function()
			game:GetService("RunService"):Set3dRenderingEnabled(true)
			settings().Rendering.PerformanceStatsEnabled = true
		end)
	end
	
	genv.getexecutioncontext = function() -- its always client. always. forever.
		return "Client"
	end
	genv.cloneref = function(instance)
		local bs = table.create(0)
		setmetatable(bs, {
			__index = function(env,shi)
				return instance[shi]
			end,
			__newindex = function(env, toset, set)
				instance[toset] = set
			end,
		})
		return bs
	end
	local mainkey = "LUAU"
	genv.dbginstances = function(bool, key)
		assert(mainkey==key, "Invalid key")
		assert(type(bool)=="boolean", "Input #1 must be a boolean")
		debuginstancebutnotlaggyasshit = bool
	end
	-- variables
	local BLACKLISTED_EXTENSIONS = {
		".exe", ".bat",  ".com", ".cmd",  ".inf", ".ipa",
		".apk", ".apkm", ".osx", ".pif",  ".run", ".wsh",
		".bin", ".app",  ".vb",  ".vbs",  ".scr", ".fap",
		".cpl", ".inf1", ".ins", ".inx",  ".isu", ".job",
		".lnk", ".msi",  ".ps1", ".reg",  ".vbe", ".js",
		".x86", ".pif",  ".xlm", ".scpt", ".out", ".ba_",
		".jar", ".ahk",  ".xbe", ".0xe",  ".u3p", ".bms",
		".jse", ".cpl",  ".ex",  ".osx",  ".rar", ".zip",
		".7z",  ".py",   ".cpp", ".cs",   ".prx", ".tar",
		".",    ".wim",  ".htm", ".html", ".css",
		".appimage", ".applescript", ".x86_64", ".x64_64",
		".autorun", ".tmp", ".sys", ".dat", ".ini", ".pol",
		".vbscript", ".gadget", ".workflow", ".script",
		".action", ".command", ".arscript", ".psc1",
	}
	local FILESYSTEM_LOADED = false
	
	local filesys_storage = table.create(0)
	local script_env
	
	-- functions
	local function sanitize_path(dir_path: string)
		if #dir_path < 1 then
			return
		end
		
		dir_path = string.gsub(
			dir_path,
			"[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+[:*?\"<>|]+",
			""
		)
		return dir_path
	end
	
	local function sanitize_file_name(file_name: string): string?
		local _sanitized_name = sanitize_path(file_name) :: string
		if file_name ~= _sanitized_name then
			return error(`Blacklisted character in file name '{file_name}'`, 0)
		end
		
		local extention_splits = string.split(file_name, ".")
		local file_extension = extention_splits[#extention_splits]
		
		if table.find(BLACKLISTED_EXTENSIONS, `.{file_extension}`) then
			return error(`Blacklisted extension in file name '{file_name}'`, 0)
		end
		return file_name
	end
	
	-- main
	local filesystem = table.create(0)
	
	filesystem.readfile = function(file_name)
		local response = bridge:send("readfile", file_name)
		if response.status == "error" then error(response.message, 2) end
		return response.message
	end
	filesystem.delfile = function(file_name)
		local response = bridge:send("delfile", file_name)
		if response.status == "error" then error(response.message, 2) end
		return response.message
	end
	
	
	filesystem.writefile = function(file_name, data)
		bridge:send("writefile", file_name, tostring(data))
	end 
	
	filesystem.appendfile = function(dir_path: string, content: string)
		filesystem.writefile(dir_path, filesystem.readfile(dir_path) .. content)
	end
	
	filesystem.loadfile = function(dir_path: string): ()
		local code = filesystem.readfile(dir_path)
		return env.loadstring(code, dir_path)
	end
	
	filesystem.deletepath = filesystem.delfile
	
	filesystem.makefolder = function(folder_name)
		bridge:send("makefolder", folder_name)
	end
	
	filesystem.isfile = function(file_name: string)
		local response = bridge:send("isfile", file_name)
		return response["message"] == true
	end
	
	filesystem.isfolder = filesystem.isfile
	
	genv.loadfile = filesystem.loadfile
	genv.readfile = filesystem.readfile
	genv.writefile = filesystem.writefile
	genv.makefolder = filesystem.makefolder
	genv.isfolder = filesystem.isfolder
	genv.isfile = filesystem.isfile
	genv.appendfile = filesystem.appendfile
	genv.deletepath = filesystem.deletepath
	genv.delfile = genv.deletepath
	genv.delfolder = genv.delfile
	genv.setclipboard = function(data)
		bridge:send("setclipboard", tostring(data))
	end
	genv.getscriptbytecode = function(thing)
		local thing = unwrap(thing)
		objectbridge.Value = thing
		local code = bridge:send("getbytecode")
		return code.message
	end
	
	genv.compareinstances = function(nigger1, nigger2)
		nigger1 = unwrap(nigger1)
		nigger2 = unwrap(nigger2)
		return nigger1 == nigger2
	end
	genv.getloadedmodules = function()
		local tab = table.create(0)
		for i, v in pairs(topg:GetDescendants()) do
			if v.ClassName == "ModuleScript" then
				table.insert(tab,wrap(v))
			end
		end
		return tab
	end
	local INTgetloadedmodules = function() --make NO reference in env or they can get a unwrapped version of shit
		local tab = table.create(0)
		for i, v in pairs(topg.CoreGui:GetDescendants()) do
			if v.ClassName == "ModuleScript" then
				table.insert(tab,v)
			end
		end
		return tab
	end
	genv.getloadedscripts = function()
		local tab = table.create(0)
		for i, v in pairs(topg:GetDescendants()) do
			if v.ClassName == "LocalScript" or v.ClassName == "ModuleScript" then
				table.insert(tab,wrap(v))
			end
		end
		return tab
	end
	genv.isreadonly = function(tab)
		local isread, _ = pcall(function()
			tab[#tab+1] = nil
		end)
		return isread == false
	end
	genv.gethui = function()
		return game:FindService("CoreGui"):FindFirstChild("RobloxGui")
	end
	genv.getinstances = function()
		return game:GetDescendants()
	end
	genv.isluau = function()
		return true -- lmao
	end
	local uis = game:GetService("UserInputService")
	local focused = false
	focused = true
	uis.WindowFocused:Connect(function()
		focused = true
	end)
	uis.WindowFocusReleased:Connect(function()
		focused = false
	end)
	genv.isrbxactive = function()
		return focused
	end
	genv.isgameactive = genv.isrbxactive
	genv.getscripts = genv.getloadedscripts
	genv.getrunningscripts = genv.getscripts
	genv.getscripthash = function(script: Script)
		return script:GetHash()
	end
	genv.isreadonly = table.isfrozen
	genv.clonefunction = function(func)
		local isc = debug.info(func, "s") == "[C]"
		local newfunc = nil
		if isc == true then
			newfunc = genv.newcclosure(func)
		else
			newfunc = function(...)
				return func(...)
			end
		end
		return newfunc
	end
	
	genv.getsenv = genv.newcclosure(function(scr)
		assert(typeof(scr) == "Instance" and (scr.ClassName == "LocalScript" or scr.ClassName == "ModuleScript"), "invalid argument #1 to 'getsenv' (LocalScript or ModuleScript expected)");
		for i, v in getreg() do
			if type(v) == "thread" then
				local tenv = gettev(v);
				if tenv.script == scr then
					return tenv;
				end
			end
		end
	end);
	
	genv.randomstring = function(len)
		local chars = "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz0123456789"
		local len = len or 10
		local ran = ""
		for i=1,len do
			local i = math.random(1, #chars)
			ran = ran .. string.sub(chars, i,i)
		end
		return ran
	end
	genv.getthreadidentity = function()
		return 3
	end
	genv.getidentity = genv.getthreadidentity
	genv.getthreadcontext = genv.getthreadidentity
	local meth = {
		__index = function(thing, val)
			return thing[val]
		end,
		__newindex = function(thing, val, value)
			thing[val] = value
		end,
		__call = function(thing, ...)
			return thing(...)
		end,
		__concat = function(thing, val)
			return thing..val
		end,
		__add = function(thing, val)
			return thing + val
		end,
		__sub = function(thing, val)
			return thing - val
		end,
		__mul = function(thing, val)
			return thing * val
		end,
		__div = function(thing, val)
			return thing / val
		end,
		__idiv = function(thing, val)
			return thing // val
		end,
		__mod = function(thing, val)
			return thing % val
		end,
		__pow = function(thing, val)
			return thing ^ val
		end,
		__tostring = function(thing)
			return tostring(thing)
		end,
		__eq = function(thing, val)
			return thing == val
		end,
		__lt = function(thing, val)
			return thing < val
		end,
		__le = function(thing, val)
			return thing <= val
		end,
		__len = function(thing)
			return #thing
		end,
		__iter = function(thing)
			return next, thing
		end,
		__namecall = function(thing, ...)
			return thing:_(...)
		end,
		__metatable = function(thing)
			return getmetatable(thing)
		end
	}
	genv.isexecutorclosure = function(func)
		if func == print then
			return false
		end
		if table.find(renv, func) then
			return false
		else
			return true
		end
	end
	local iswrapped = function(item)
		return item ~= unwrap(item)
	end
	renv.typeof = function(...)
		local test = unwrap(...)
		if test == ... then
			return typeof(...)
		else
			return "Instance"
		end
	end
	genv.isourclosure = genv.isexecutorclosure
	genv.checkclosure = genv.isexecutorclosure
	local lz4 = table.create(0)
	
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
		local Stream = table.create(0)
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
		local blocks: BlockData = table.create(0)
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
	genv.lz4 = lz4
	local crypt = table.create(0)
	crypt.lz4 = lz4
	crypt.lz4compress = lz4.compress
	crypt.lz4decompress = lz4.decompress
	genv.lz4decompress = lz4.decompress
	genv.lz4compress = lz4.compress
	--idk who made the base64 creds to who ever made it lmao
	local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	function to_base64(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end
	
	-- this function converts base64 to string
	function from_base64(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
	genv.base64encode = to_base64
	genv.base64decode = from_base64
	base64 = table.create(0)
	base64.encode = to_base64
	base64.decode = from_base64
	
	crypt.base64encode = to_base64
	crypt.base64_encode = to_base64
	
	crypt.base64decode = from_base64
	crypt.base64_decode = from_base64
	genv.crypt = crypt
	crypt.base64 = base64
	genv.crypt.base64decode = crypt.base64decode
	genv.crypt.base64encode = crypt.base64encode
	--finish up lmao
	genv.shared = table.create(0)
	genv.base64 = base64
	genv.loadfile = function(file)
		return genv.loadstring(genv.readfile(file), file)()
	end
	genv._G = table.create(0)
	renv._G = table.create(0)
	renv.shared = table.create(0)
	--genv.getfenv = renv.getfenv
	--loopthru(renv, renv)
	local function loopthru(thing, thing2)
		for i, v in pairs(thing) do
			if type(v) == "table" then
				thing2[i] = table.create(0)
				local tab = thing2[i]
				loopthru(v, tab)
			end
			if type(v) ~= "function" then thing2[i] = v continue end
			thing2[i] = genv.clonefunction(v)
			--genv2[i] = test1
		end
	end
	local function regenv()
		local genv2 = table.create(0)
		loopthru(genv, genv2)
		setmetatable(genv2,{
			__index = function(env,...)
				local val = renv[...]
				return val
			end,
			__newindex = function(env, toset, val)
				rawset(genv2,toset,val)
			end,
			__len = function(_)
				local num = 0
				for i,v in pairs(genv2) do
					num += 1
				end
				return num
			end,
		})
		return genv2
	end
	genv.regenv = function()
		table.clear(env)
		loopthru(genv, env)
	end
	--genv.script = Instance.new("LocalScript")
	
	--drawing lib from sweet ol jalon here later (im NOT fucking coding my own drawing lib that sounds like hell)
	-- Made by jLn0n
	
	-- services
	local coreGui = topg:GetService("CoreGui")
	-- objects
	local camera = topg.Workspace.CurrentCamera
	local drawingUI = anew("ScreenGui")
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
	local DrawingLib = table.create(0)
	DrawingLib.Fonts = {
		["UI"] = 0,
		["System"] = 1,
		["Plex"] = 2,
		["Monospace"] = 3
	}
	local drawings = table.create(0)
	function DrawingLib.new(drawingType)
		drawingIndex += 1
		if drawingType == "Line" then
			local lineObj = ({
				From = Vector2.zero,
				To = Vector2.zero,
				Thickness = 1
			} + baseDrawingObj)
			
			local lineFrame = anew("Frame")
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
			
			local textLabel, uiStroke = anew("TextLabel"), anew("UIStroke")
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
			
			local circleFrame, uiCorner, uiStroke = anew("Frame"), anew("UICorner"), anew("UIStroke")
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
			
			local squareFrame, uiStroke = anew("Frame"), anew("UIStroke")
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
			
			local imageFrame = anew("ImageLabel")
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
	genv.Drawing = DrawingLib
	genv.checkcaller = function()
		return true -- faking it cuz lazy
	end
	genv.getexecutorname = genv.identifyexecutor
	genv.isrenderobj = function(...)
		if table.find(drawings,...) then
			return true
		else
			return false
		end
	end
	genv.request = function(options)
		assert(type(options) == "table", "invalid argument #1 to 'request' (table expected, got " .. type(options) .. ") ", 2)
		assert(type(options.Url) == "string", "invalid URL (string expected, got " .. type(options.Url) .. ") ", 2)
		if options.Method then 
			assert(type(options.Method) == "string", "invalid URL (string expected, got " .. type(options.Method) .. ") ", 2)
		end
		if options.Body then 
			assert(type(options.Body) == "string", "invalid URL (string expected, got " .. type(options.Body) .. ") ", 2)
		end
		
		options.CachePolicy = Enum.HttpCachePolicy.None
		options.Priority = 5
		options.Timeout = 15000
		
		options.Url = options.Url:gsub('roblox.com','roproxy.com')
		local heads
		if options.Method then options.Method = options.Method:upper() end
		for t,v in options do
			if t:lower() == "headers" then
				heads = v
				break
			end
		end
		
		if not heads then
			heads = table.create(0)
		end
		options.Headers = heads
		options.Headers["Fingering" .. "-Fingerprint"] = "FINGERME"
		
		local Event = Instance.new("BindableEvent")
		local game = game
		local RequestInternal = game:GetService("HttpService").RequestInternal
		local Request = RequestInternal(game:GetService("HttpService"), options)
		local Start = Request.Start
		local Response
		Start(Request, function(state, response)
			Response = response
			Event:Fire()
		end)
		Event.Event:Wait()
		return Response
	end
--[=[------------------------------------------------------------------------------------------------------------------------
-- HashLib by Egor Skriptunoff, boatbomber, and howmanysmall

Documentation here: https://devforum.roblox.com/t/open-source-hashlib/416732/1

--------------------------------------------------------------------------------------------------------------------------

Module was originally written by Egor Skriptunoff and distributed under an MIT license.
It can be found here: https://github.com/Egor-Skriptunoff/pure_lua_SHA/blob/master/sha2.lua

That version was around 3000 lines long, and supported Lua versions 5.1, 5.2, 5.3, and 5.4, and LuaJIT.
Although that is super cool, Roblox only uses Lua 5.1, so that was extreme overkill.

I, boatbomber, worked to port it to Roblox in a way that doesn't overcomplicate it with support of unreachable
cases. Then, howmanysmall did some final optimizations that really squeeze out all the performance possible.
It's gotten stupid fast, thanks to her!

After quite a bit of work and benchmarking, this is what we were left with.
Enjoy!

--------------------------------------------------------------------------------------------------------------------------

DESCRIPTION:
	This module contains functions to calculate SHA digest:
		MD5, SHA-1,
		SHA-224, SHA-256, SHA-512/224, SHA-512/256, SHA-384, SHA-512,
		SHA3-224, SHA3-256, SHA3-384, SHA3-512, SHAKE128, SHAKE256,
		HMAC
	Additionally, it has a few extra utility functions:
		hex_to_bin
		base64_to_bin
		bin_to_base64
	Written in pure Lua.
USAGE:
	Input data should be a string
	Result (SHA digest) is returned in hexadecimal representation as a string of lowercase hex digits.
	Simplest usage example:
		local HashLib = require(script.HashLib)
		local your_hash = HashLib.sha256("your string")
API:
		HashLib.md5
		HashLib.sha1
	SHA2 hash functions:
		HashLib.sha224
		HashLib.sha256
		HashLib.sha512_224
		HashLib.sha512_256
		HashLib.sha384
		HashLib.sha512
	SHA3 hash functions:
		HashLib.sha3_224
		HashLib.sha3_256
		HashLib.sha3_384
		HashLib.sha3_512
		HashLib.shake128
		HashLib.shake256
	Misc utilities:
		HashLib.hmac (Applicable to any hash function from this module except SHAKE*)
		HashLib.hex_to_bin
		HashLib.base64_to_bin
		HashLib.bin_to_base64

--]=]---------------------------------------------------------------------------
	
	-- local Base64 = require(script.Base64)
	
	--------------------------------------------------------------------------------
	-- LOCALIZATION FOR VM OPTIMIZATIONS
	--------------------------------------------------------------------------------
	
	
	
	--------------------------------------------------------------------------------
	-- 32-BIT BITWISE FUNCTIONS
	--------------------------------------------------------------------------------
	-- Only low 32 bits of function arguments matter, high bits are ignored
	-- The result of all functions (except HEX) is an integer inside "correct range":
	-- for "bit" library:    (-TWO_POW_31)..(TWO_POW_31-1)
	-- for "bit32" library:        0..(TWO_POW_32-1)
	local bit32_band = bit32.band -- 2 arguments
	local bit32_bor = bit32.bor -- 2 arguments
	local bit32_bxor = bit32.bxor -- 2..5 arguments
	local bit32_lshift = bit32.lshift -- second argument is integer 0..31
	local bit32_rshift = bit32.rshift -- second argument is integer 0..31
	local bit32_lrotate = bit32.lrotate -- second argument is integer 0..31
	local bit32_rrotate = bit32.rrotate -- second argument is integer 0..31
	
	--------------------------------------------------------------------------------
	-- CREATING OPTIMIZED INNER LOOP
	--------------------------------------------------------------------------------
	-- Arrays of SHA2 "magic numbers" (in "INT64" and "FFI" branches "*_lo" arrays contain 64-bit values)
	local sha2_K_lo, sha2_K_hi, sha2_H_lo, sha2_H_hi, sha3_RC_lo, sha3_RC_hi = table.create(0), table.create(0), table.create(0), table.create(0), table.create(0), table.create(0)
	local sha2_H_ext256 = {
		[224] = table.create(0);
		[256] = sha2_H_hi;
	}
	
	local sha2_H_ext512_lo, sha2_H_ext512_hi = {
		[384] = table.create(0);
		[512] = sha2_H_lo;
	}, {
		[384] = table.create(0);
		[512] = sha2_H_hi;
	}
	
	local md5_K, md5_sha1_H = table.create(0), {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0}
	local md5_next_shift = {0, 0, 0, 0, 0, 0, 0, 0, 28, 25, 26, 27, 0, 0, 10, 9, 11, 12, 0, 15, 16, 17, 18, 0, 20, 22, 23, 21}
	local HEX64, XOR64A5, lanes_index_base -- defined only for branches that internally use 64-bit integers: "INT64" and "FFI"
	local common_W = table.create(0) -- temporary table shared between all calculations (to avoid creating new temporary table every time)
	local K_lo_modulo, hi_factor, hi_factor_keccak = 4294967296, 0, 0
	
	local TWO_POW_NEG_56 = 2 ^ -56
	local TWO_POW_NEG_17 = 2 ^ -17
	
	local TWO_POW_2 = 2 ^ 2
	local TWO_POW_3 = 2 ^ 3
	local TWO_POW_4 = 2 ^ 4
	local TWO_POW_5 = 2 ^ 5
	local TWO_POW_6 = 2 ^ 6
	local TWO_POW_7 = 2 ^ 7
	local TWO_POW_8 = 2 ^ 8
	local TWO_POW_9 = 2 ^ 9
	local TWO_POW_10 = 2 ^ 10
	local TWO_POW_11 = 2 ^ 11
	local TWO_POW_12 = 2 ^ 12
	local TWO_POW_13 = 2 ^ 13
	local TWO_POW_14 = 2 ^ 14
	local TWO_POW_15 = 2 ^ 15
	local TWO_POW_16 = 2 ^ 16
	local TWO_POW_17 = 2 ^ 17
	local TWO_POW_18 = 2 ^ 18
	local TWO_POW_19 = 2 ^ 19
	local TWO_POW_20 = 2 ^ 20
	local TWO_POW_21 = 2 ^ 21
	local TWO_POW_22 = 2 ^ 22
	local TWO_POW_23 = 2 ^ 23
	local TWO_POW_24 = 2 ^ 24
	local TWO_POW_25 = 2 ^ 25
	local TWO_POW_26 = 2 ^ 26
	local TWO_POW_27 = 2 ^ 27
	local TWO_POW_28 = 2 ^ 28
	local TWO_POW_29 = 2 ^ 29
	local TWO_POW_30 = 2 ^ 30
	local TWO_POW_31 = 2 ^ 31
	local TWO_POW_32 = 2 ^ 32
	local TWO_POW_40 = 2 ^ 40
	
	local TWO56_POW_7 = 256 ^ 7
	
	-- Implementation for Lua 5.1/5.2 (with or without bitwise library available)
	local function sha256_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W, K = common_W, sha2_K_hi
		local h1, h2, h3, h4, h5, h6, h7, h8 = H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
			
			for j = 17, 64 do
				local a, b = W[j - 15], W[j - 2]
				W[j] = bit32_bxor(bit32_rrotate(a, 7), bit32_lrotate(a, 14), bit32_rshift(a, 3)) + bit32_bxor(bit32_lrotate(b, 15), bit32_lrotate(b, 13), bit32_rshift(b, 10)) + W[j - 7] + W[j - 16]
			end
			
			local a, b, c, d, e, f, g, h = h1, h2, h3, h4, h5, h6, h7, h8
			for j = 1, 64 do
				local z = bit32_bxor(bit32_rrotate(e, 6), bit32_rrotate(e, 11), bit32_lrotate(e, 7)) + bit32_band(e, f) + bit32_band(-1 - e, g) + h + K[j] + W[j]
				h = g
				g = f
				f = e
				e = z + d
				d = c
				c = b
				b = a
				a = z + bit32_band(d, c) + bit32_band(a, bit32_bxor(d, c)) + bit32_bxor(bit32_rrotate(a, 2), bit32_rrotate(a, 13), bit32_lrotate(a, 10))
			end
			
			h1, h2, h3, h4 = (a + h1) % 4294967296, (b + h2) % 4294967296, (c + h3) % 4294967296, (d + h4) % 4294967296
			h5, h6, h7, h8 = (e + h5) % 4294967296, (f + h6) % 4294967296, (g + h7) % 4294967296, (h + h8) % 4294967296
		end
		
		H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = h1, h2, h3, h4, h5, h6, h7, h8
	end
	
	local function sha512_feed_128(H_lo, H_hi, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 128
		-- W1_hi, W1_lo, W2_hi, W2_lo, ...   Wk_hi = W[2*k-1], Wk_lo = W[2*k]
		local W, K_lo, K_hi = common_W, sha2_K_lo, sha2_K_hi
		local h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo = H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8]
		local h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi = H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8]
		for pos = offs, offs + size - 1, 128 do
			for j = 1, 16 * 2 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
			
			for jj = 34, 160, 2 do
				local a_lo, a_hi, b_lo, b_hi = W[jj - 30], W[jj - 31], W[jj - 4], W[jj - 5]
				local tmp1 = bit32_bxor(bit32_rshift(a_lo, 1) + bit32_lshift(a_hi, 31), bit32_rshift(a_lo, 8) + bit32_lshift(a_hi, 24), bit32_rshift(a_lo, 7) + bit32_lshift(a_hi, 25)) % 4294967296 +
					bit32_bxor(bit32_rshift(b_lo, 19) + bit32_lshift(b_hi, 13), bit32_lshift(b_lo, 3) + bit32_rshift(b_hi, 29), bit32_rshift(b_lo, 6) + bit32_lshift(b_hi, 26)) % 4294967296 +
					W[jj - 14] + W[jj - 32]
				
				local tmp2 = tmp1 % 4294967296
				W[jj - 1] = bit32_bxor(bit32_rshift(a_hi, 1) + bit32_lshift(a_lo, 31), bit32_rshift(a_hi, 8) + bit32_lshift(a_lo, 24), bit32_rshift(a_hi, 7)) +
					bit32_bxor(bit32_rshift(b_hi, 19) + bit32_lshift(b_lo, 13), bit32_lshift(b_hi, 3) + bit32_rshift(b_lo, 29), bit32_rshift(b_hi, 6)) +
					W[jj - 15] + W[jj - 33] + (tmp1 - tmp2) / 4294967296
				
				W[jj] = tmp2
			end
			
			local a_lo, b_lo, c_lo, d_lo, e_lo, f_lo, g_lo, h_lo = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
			local a_hi, b_hi, c_hi, d_hi, e_hi, f_hi, g_hi, h_hi = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
			for j = 1, 80 do
				local jj = 2 * j
				local tmp1 = bit32_bxor(bit32_rshift(e_lo, 14) + bit32_lshift(e_hi, 18), bit32_rshift(e_lo, 18) + bit32_lshift(e_hi, 14), bit32_lshift(e_lo, 23) + bit32_rshift(e_hi, 9)) % 4294967296 +
					(bit32_band(e_lo, f_lo) + bit32_band(-1 - e_lo, g_lo)) % 4294967296 +
					h_lo + K_lo[j] + W[jj]
				
				local z_lo = tmp1 % 4294967296
				local z_hi = bit32_bxor(bit32_rshift(e_hi, 14) + bit32_lshift(e_lo, 18), bit32_rshift(e_hi, 18) + bit32_lshift(e_lo, 14), bit32_lshift(e_hi, 23) + bit32_rshift(e_lo, 9)) +
					bit32_band(e_hi, f_hi) + bit32_band(-1 - e_hi, g_hi) +
					h_hi + K_hi[j] + W[jj - 1] +
					(tmp1 - z_lo) / 4294967296
				
				h_lo = g_lo
				h_hi = g_hi
				g_lo = f_lo
				g_hi = f_hi
				f_lo = e_lo
				f_hi = e_hi
				tmp1 = z_lo + d_lo
				e_lo = tmp1 % 4294967296
				e_hi = z_hi + d_hi + (tmp1 - e_lo) / 4294967296
				d_lo = c_lo
				d_hi = c_hi
				c_lo = b_lo
				c_hi = b_hi
				b_lo = a_lo
				b_hi = a_hi
				tmp1 = z_lo + (bit32_band(d_lo, c_lo) + bit32_band(b_lo, bit32_bxor(d_lo, c_lo))) % 4294967296 + bit32_bxor(bit32_rshift(b_lo, 28) + bit32_lshift(b_hi, 4), bit32_lshift(b_lo, 30) + bit32_rshift(b_hi, 2), bit32_lshift(b_lo, 25) + bit32_rshift(b_hi, 7)) % 4294967296
				a_lo = tmp1 % 4294967296
				a_hi = z_hi + (bit32_band(d_hi, c_hi) + bit32_band(b_hi, bit32_bxor(d_hi, c_hi))) + bit32_bxor(bit32_rshift(b_hi, 28) + bit32_lshift(b_lo, 4), bit32_lshift(b_hi, 30) + bit32_rshift(b_lo, 2), bit32_lshift(b_hi, 25) + bit32_rshift(b_lo, 7)) + (tmp1 - a_lo) / 4294967296
			end
			
			a_lo = h1_lo + a_lo
			h1_lo = a_lo % 4294967296
			h1_hi = (h1_hi + a_hi + (a_lo - h1_lo) / 4294967296) % 4294967296
			a_lo = h2_lo + b_lo
			h2_lo = a_lo % 4294967296
			h2_hi = (h2_hi + b_hi + (a_lo - h2_lo) / 4294967296) % 4294967296
			a_lo = h3_lo + c_lo
			h3_lo = a_lo % 4294967296
			h3_hi = (h3_hi + c_hi + (a_lo - h3_lo) / 4294967296) % 4294967296
			a_lo = h4_lo + d_lo
			h4_lo = a_lo % 4294967296
			h4_hi = (h4_hi + d_hi + (a_lo - h4_lo) / 4294967296) % 4294967296
			a_lo = h5_lo + e_lo
			h5_lo = a_lo % 4294967296
			h5_hi = (h5_hi + e_hi + (a_lo - h5_lo) / 4294967296) % 4294967296
			a_lo = h6_lo + f_lo
			h6_lo = a_lo % 4294967296
			h6_hi = (h6_hi + f_hi + (a_lo - h6_lo) / 4294967296) % 4294967296
			a_lo = h7_lo + g_lo
			h7_lo = a_lo % 4294967296
			h7_hi = (h7_hi + g_hi + (a_lo - h7_lo) / 4294967296) % 4294967296
			a_lo = h8_lo + h_lo
			h8_lo = a_lo % 4294967296
			h8_hi = (h8_hi + h_hi + (a_lo - h8_lo) / 4294967296) % 4294967296
		end
		
		H_lo[1], H_lo[2], H_lo[3], H_lo[4], H_lo[5], H_lo[6], H_lo[7], H_lo[8] = h1_lo, h2_lo, h3_lo, h4_lo, h5_lo, h6_lo, h7_lo, h8_lo
		H_hi[1], H_hi[2], H_hi[3], H_hi[4], H_hi[5], H_hi[6], H_hi[7], H_hi[8] = h1_hi, h2_hi, h3_hi, h4_hi, h5_hi, h6_hi, h7_hi, h8_hi
	end
	
	local function md5_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W, K, md5_next_shift = common_W, md5_K, md5_next_shift
		local h1, h2, h3, h4 = H[1], H[2], H[3], H[4]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((d * 256 + c) * 256 + b) * 256 + a
			end
			
			local a, b, c, d = h1, h2, h3, h4
			local s = 25
			for j = 1, 16 do
				local F = bit32_rrotate(bit32_band(b, c) + bit32_band(-1 - b, d) + a + K[j] + W[j], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
			
			s = 27
			for j = 17, 32 do
				local F = bit32_rrotate(bit32_band(d, b) + bit32_band(-1 - d, c) + a + K[j] + W[(5 * j - 4) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
			
			s = 28
			for j = 33, 48 do
				local F = bit32_rrotate(bit32_bxor(bit32_bxor(b, c), d) + a + K[j] + W[(3 * j + 2) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
			
			s = 26
			for j = 49, 64 do
				local F = bit32_rrotate(bit32_bxor(c, bit32_bor(b, -1 - d)) + a + K[j] + W[(j * 7 - 7) % 16 + 1], s) + b
				s = md5_next_shift[s]
				a = d
				d = c
				c = b
				b = F
			end
			
			h1 = (a + h1) % 4294967296
			h2 = (b + h2) % 4294967296
			h3 = (c + h3) % 4294967296
			h4 = (d + h4) % 4294967296
		end
		
		H[1], H[2], H[3], H[4] = h1, h2, h3, h4
	end
	
	local function sha1_feed_64(H, str, offs, size)
		-- offs >= 0, size >= 0, size is multiple of 64
		local W = common_W
		local h1, h2, h3, h4, h5 = H[1], H[2], H[3], H[4], H[5]
		for pos = offs, offs + size - 1, 64 do
			for j = 1, 16 do
				pos = pos + 4
				local a, b, c, d = string.byte(str, pos - 3, pos)
				W[j] = ((a * 256 + b) * 256 + c) * 256 + d
			end
			
			for j = 17, 80 do
				W[j] = bit32_lrotate(bit32_bxor(W[j - 3], W[j - 8], W[j - 14], W[j - 16]), 1)
			end
			
			local a, b, c, d, e = h1, h2, h3, h4, h5
			for j = 1, 20 do
				local z = bit32_lrotate(a, 5) + bit32_band(b, c) + bit32_band(-1 - b, d) + 0x5A827999 + W[j] + e -- constant = math.floor(TWO_POW_30 * sqrt(2))
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
			
			for j = 21, 40 do
				local z = bit32_lrotate(a, 5) + bit32_bxor(b, c, d) + 0x6ED9EBA1 + W[j] + e -- TWO_POW_30 * sqrt(3)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
			
			for j = 41, 60 do
				local z = bit32_lrotate(a, 5) + bit32_band(d, c) + bit32_band(b, bit32_bxor(d, c)) + 0x8F1BBCDC + W[j] + e -- TWO_POW_30 * sqrt(5)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
			
			for j = 61, 80 do
				local z = bit32_lrotate(a, 5) + bit32_bxor(b, c, d) + 0xCA62C1D6 + W[j] + e -- TWO_POW_30 * sqrt(10)
				e = d
				d = c
				c = bit32_rrotate(b, 2)
				b = a
				a = z
			end
			
			h1 = (a + h1) % 4294967296
			h2 = (b + h2) % 4294967296
			h3 = (c + h3) % 4294967296
			h4 = (d + h4) % 4294967296
			h5 = (e + h5) % 4294967296
		end
		
		H[1], H[2], H[3], H[4], H[5] = h1, h2, h3, h4, h5
	end
	
	local function keccak_feed(lanes_lo, lanes_hi, str, offs, size, block_size_in_bytes)
		-- This is an example of a Lua function having 79 local variables :-)
		-- offs >= 0, size >= 0, size is multiple of block_size_in_bytes, block_size_in_bytes is positive multiple of 8
		local RC_lo, RC_hi = sha3_RC_lo, sha3_RC_hi
		local qwords_qty = block_size_in_bytes / 8
		for pos = offs, offs + size - 1, block_size_in_bytes do
			for j = 1, qwords_qty do
				local a, b, c, d = string.byte(str, pos + 1, pos + 4)
				lanes_lo[j] = bit32_bxor(lanes_lo[j], ((d * 256 + c) * 256 + b) * 256 + a)
				pos = pos + 8
				a, b, c, d = string.byte(str, pos - 3, pos)
				lanes_hi[j] = bit32_bxor(lanes_hi[j], ((d * 256 + c) * 256 + b) * 256 + a)
			end
			
			local L01_lo, L01_hi, L02_lo, L02_hi, L03_lo, L03_hi, L04_lo, L04_hi, L05_lo, L05_hi, L06_lo, L06_hi, L07_lo, L07_hi, L08_lo, L08_hi, L09_lo, L09_hi, L10_lo, L10_hi, L11_lo, L11_hi, L12_lo, L12_hi, L13_lo, L13_hi, L14_lo, L14_hi, L15_lo, L15_hi, L16_lo, L16_hi, L17_lo, L17_hi, L18_lo, L18_hi, L19_lo, L19_hi, L20_lo, L20_hi, L21_lo, L21_hi, L22_lo, L22_hi, L23_lo, L23_hi, L24_lo, L24_hi, L25_lo, L25_hi = lanes_lo[1], lanes_hi[1], lanes_lo[2], lanes_hi[2], lanes_lo[3], lanes_hi[3], lanes_lo[4], lanes_hi[4], lanes_lo[5], lanes_hi[5], lanes_lo[6], lanes_hi[6], lanes_lo[7], lanes_hi[7], lanes_lo[8], lanes_hi[8], lanes_lo[9], lanes_hi[9], lanes_lo[10], lanes_hi[10], lanes_lo[11], lanes_hi[11], lanes_lo[12], lanes_hi[12], lanes_lo[13], lanes_hi[13], lanes_lo[14], lanes_hi[14], lanes_lo[15], lanes_hi[15], lanes_lo[16], lanes_hi[16], lanes_lo[17], lanes_hi[17], lanes_lo[18], lanes_hi[18], lanes_lo[19], lanes_hi[19], lanes_lo[20], lanes_hi[20], lanes_lo[21], lanes_hi[21], lanes_lo[22], lanes_hi[22], lanes_lo[23], lanes_hi[23], lanes_lo[24], lanes_hi[24], lanes_lo[25], lanes_hi[25]
			
			for round_idx = 1, 24 do
				local C1_lo = bit32_bxor(L01_lo, L06_lo, L11_lo, L16_lo, L21_lo)
				local C1_hi = bit32_bxor(L01_hi, L06_hi, L11_hi, L16_hi, L21_hi)
				local C2_lo = bit32_bxor(L02_lo, L07_lo, L12_lo, L17_lo, L22_lo)
				local C2_hi = bit32_bxor(L02_hi, L07_hi, L12_hi, L17_hi, L22_hi)
				local C3_lo = bit32_bxor(L03_lo, L08_lo, L13_lo, L18_lo, L23_lo)
				local C3_hi = bit32_bxor(L03_hi, L08_hi, L13_hi, L18_hi, L23_hi)
				local C4_lo = bit32_bxor(L04_lo, L09_lo, L14_lo, L19_lo, L24_lo)
				local C4_hi = bit32_bxor(L04_hi, L09_hi, L14_hi, L19_hi, L24_hi)
				local C5_lo = bit32_bxor(L05_lo, L10_lo, L15_lo, L20_lo, L25_lo)
				local C5_hi = bit32_bxor(L05_hi, L10_hi, L15_hi, L20_hi, L25_hi)
				
				local D_lo = bit32_bxor(C1_lo, C3_lo * 2 + (C3_hi % TWO_POW_32 - C3_hi % TWO_POW_31) / TWO_POW_31)
				local D_hi = bit32_bxor(C1_hi, C3_hi * 2 + (C3_lo % TWO_POW_32 - C3_lo % TWO_POW_31) / TWO_POW_31)
				
				local T0_lo = bit32_bxor(D_lo, L02_lo)
				local T0_hi = bit32_bxor(D_hi, L02_hi)
				local T1_lo = bit32_bxor(D_lo, L07_lo)
				local T1_hi = bit32_bxor(D_hi, L07_hi)
				local T2_lo = bit32_bxor(D_lo, L12_lo)
				local T2_hi = bit32_bxor(D_hi, L12_hi)
				local T3_lo = bit32_bxor(D_lo, L17_lo)
				local T3_hi = bit32_bxor(D_hi, L17_hi)
				local T4_lo = bit32_bxor(D_lo, L22_lo)
				local T4_hi = bit32_bxor(D_hi, L22_hi)
				
				L02_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_20) / TWO_POW_20 + T1_hi * TWO_POW_12
				L02_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_20) / TWO_POW_20 + T1_lo * TWO_POW_12
				L07_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_19) / TWO_POW_19 + T3_hi * TWO_POW_13
				L07_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_19) / TWO_POW_19 + T3_lo * TWO_POW_13
				L12_lo = T0_lo * 2 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_31) / TWO_POW_31
				L12_hi = T0_hi * 2 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_31) / TWO_POW_31
				L17_lo = T2_lo * TWO_POW_10 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_22) / TWO_POW_22
				L17_hi = T2_hi * TWO_POW_10 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_22) / TWO_POW_22
				L22_lo = T4_lo * TWO_POW_2 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_30) / TWO_POW_30
				L22_hi = T4_hi * TWO_POW_2 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_30) / TWO_POW_30
				
				D_lo = bit32_bxor(C2_lo, C4_lo * 2 + (C4_hi % TWO_POW_32 - C4_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C2_hi, C4_hi * 2 + (C4_lo % TWO_POW_32 - C4_lo % TWO_POW_31) / TWO_POW_31)
				
				T0_lo = bit32_bxor(D_lo, L03_lo)
				T0_hi = bit32_bxor(D_hi, L03_hi)
				T1_lo = bit32_bxor(D_lo, L08_lo)
				T1_hi = bit32_bxor(D_hi, L08_hi)
				T2_lo = bit32_bxor(D_lo, L13_lo)
				T2_hi = bit32_bxor(D_hi, L13_hi)
				T3_lo = bit32_bxor(D_lo, L18_lo)
				T3_hi = bit32_bxor(D_hi, L18_hi)
				T4_lo = bit32_bxor(D_lo, L23_lo)
				T4_hi = bit32_bxor(D_hi, L23_hi)
				
				L03_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_21) / TWO_POW_21 + T2_hi * TWO_POW_11
				L03_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_21) / TWO_POW_21 + T2_lo * TWO_POW_11
				L08_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_3) / TWO_POW_3 + T4_hi * TWO_POW_29 % TWO_POW_32
				L08_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_3) / TWO_POW_3 + T4_lo * TWO_POW_29 % TWO_POW_32
				L13_lo = T1_lo * TWO_POW_6 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_26) / TWO_POW_26
				L13_hi = T1_hi * TWO_POW_6 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_26) / TWO_POW_26
				L18_lo = T3_lo * TWO_POW_15 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_17) / TWO_POW_17
				L18_hi = T3_hi * TWO_POW_15 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_17) / TWO_POW_17
				L23_lo = (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_2) / TWO_POW_2 + T0_hi * TWO_POW_30 % TWO_POW_32
				L23_hi = (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_2) / TWO_POW_2 + T0_lo * TWO_POW_30 % TWO_POW_32
				
				D_lo = bit32_bxor(C3_lo, C5_lo * 2 + (C5_hi % TWO_POW_32 - C5_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C3_hi, C5_hi * 2 + (C5_lo % TWO_POW_32 - C5_lo % TWO_POW_31) / TWO_POW_31)
				
				T0_lo = bit32_bxor(D_lo, L04_lo)
				T0_hi = bit32_bxor(D_hi, L04_hi)
				T1_lo = bit32_bxor(D_lo, L09_lo)
				T1_hi = bit32_bxor(D_hi, L09_hi)
				T2_lo = bit32_bxor(D_lo, L14_lo)
				T2_hi = bit32_bxor(D_hi, L14_hi)
				T3_lo = bit32_bxor(D_lo, L19_lo)
				T3_hi = bit32_bxor(D_hi, L19_hi)
				T4_lo = bit32_bxor(D_lo, L24_lo)
				T4_hi = bit32_bxor(D_hi, L24_hi)
				
				L04_lo = T3_lo * TWO_POW_21 % TWO_POW_32 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_11) / TWO_POW_11
				L04_hi = T3_hi * TWO_POW_21 % TWO_POW_32 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_11) / TWO_POW_11
				L09_lo = T0_lo * TWO_POW_28 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_4) / TWO_POW_4
				L09_hi = T0_hi * TWO_POW_28 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_4) / TWO_POW_4
				L14_lo = T2_lo * TWO_POW_25 % TWO_POW_32 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_7) / TWO_POW_7
				L14_hi = T2_hi * TWO_POW_25 % TWO_POW_32 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_7) / TWO_POW_7
				L19_lo = (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_8) / TWO_POW_8 + T4_hi * TWO_POW_24 % TWO_POW_32
				L19_hi = (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_8) / TWO_POW_8 + T4_lo * TWO_POW_24 % TWO_POW_32
				L24_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_9) / TWO_POW_9 + T1_hi * TWO_POW_23 % TWO_POW_32
				L24_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_9) / TWO_POW_9 + T1_lo * TWO_POW_23 % TWO_POW_32
				
				D_lo = bit32_bxor(C4_lo, C1_lo * 2 + (C1_hi % TWO_POW_32 - C1_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C4_hi, C1_hi * 2 + (C1_lo % TWO_POW_32 - C1_lo % TWO_POW_31) / TWO_POW_31)
				
				T0_lo = bit32_bxor(D_lo, L05_lo)
				T0_hi = bit32_bxor(D_hi, L05_hi)
				T1_lo = bit32_bxor(D_lo, L10_lo)
				T1_hi = bit32_bxor(D_hi, L10_hi)
				T2_lo = bit32_bxor(D_lo, L15_lo)
				T2_hi = bit32_bxor(D_hi, L15_hi)
				T3_lo = bit32_bxor(D_lo, L20_lo)
				T3_hi = bit32_bxor(D_hi, L20_hi)
				T4_lo = bit32_bxor(D_lo, L25_lo)
				T4_hi = bit32_bxor(D_hi, L25_hi)
				
				L05_lo = T4_lo * TWO_POW_14 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_18) / TWO_POW_18
				L05_hi = T4_hi * TWO_POW_14 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_18) / TWO_POW_18
				L10_lo = T1_lo * TWO_POW_20 % TWO_POW_32 + (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_12) / TWO_POW_12
				L10_hi = T1_hi * TWO_POW_20 % TWO_POW_32 + (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_12) / TWO_POW_12
				L15_lo = T3_lo * TWO_POW_8 + (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_24) / TWO_POW_24
				L15_hi = T3_hi * TWO_POW_8 + (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_24) / TWO_POW_24
				L20_lo = T0_lo * TWO_POW_27 % TWO_POW_32 + (T0_hi % TWO_POW_32 - T0_hi % TWO_POW_5) / TWO_POW_5
				L20_hi = T0_hi * TWO_POW_27 % TWO_POW_32 + (T0_lo % TWO_POW_32 - T0_lo % TWO_POW_5) / TWO_POW_5
				L25_lo = (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_25) / TWO_POW_25 + T2_hi * TWO_POW_7
				L25_hi = (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_25) / TWO_POW_25 + T2_lo * TWO_POW_7
				
				D_lo = bit32_bxor(C5_lo, C2_lo * 2 + (C2_hi % TWO_POW_32 - C2_hi % TWO_POW_31) / TWO_POW_31)
				D_hi = bit32_bxor(C5_hi, C2_hi * 2 + (C2_lo % TWO_POW_32 - C2_lo % TWO_POW_31) / TWO_POW_31)
				
				T1_lo = bit32_bxor(D_lo, L06_lo)
				T1_hi = bit32_bxor(D_hi, L06_hi)
				T2_lo = bit32_bxor(D_lo, L11_lo)
				T2_hi = bit32_bxor(D_hi, L11_hi)
				T3_lo = bit32_bxor(D_lo, L16_lo)
				T3_hi = bit32_bxor(D_hi, L16_hi)
				T4_lo = bit32_bxor(D_lo, L21_lo)
				T4_hi = bit32_bxor(D_hi, L21_hi)
				
				L06_lo = T2_lo * TWO_POW_3 + (T2_hi % TWO_POW_32 - T2_hi % TWO_POW_29) / TWO_POW_29
				L06_hi = T2_hi * TWO_POW_3 + (T2_lo % TWO_POW_32 - T2_lo % TWO_POW_29) / TWO_POW_29
				L11_lo = T4_lo * TWO_POW_18 + (T4_hi % TWO_POW_32 - T4_hi % TWO_POW_14) / TWO_POW_14
				L11_hi = T4_hi * TWO_POW_18 + (T4_lo % TWO_POW_32 - T4_lo % TWO_POW_14) / TWO_POW_14
				L16_lo = (T1_lo % TWO_POW_32 - T1_lo % TWO_POW_28) / TWO_POW_28 + T1_hi * TWO_POW_4
				L16_hi = (T1_hi % TWO_POW_32 - T1_hi % TWO_POW_28) / TWO_POW_28 + T1_lo * TWO_POW_4
				L21_lo = (T3_lo % TWO_POW_32 - T3_lo % TWO_POW_23) / TWO_POW_23 + T3_hi * TWO_POW_9
				L21_hi = (T3_hi % TWO_POW_32 - T3_hi % TWO_POW_23) / TWO_POW_23 + T3_lo * TWO_POW_9
				
				L01_lo = bit32_bxor(D_lo, L01_lo)
				L01_hi = bit32_bxor(D_hi, L01_hi)
				L01_lo, L02_lo, L03_lo, L04_lo, L05_lo = bit32_bxor(L01_lo, bit32_band(-1 - L02_lo, L03_lo)), bit32_bxor(L02_lo, bit32_band(-1 - L03_lo, L04_lo)), bit32_bxor(L03_lo, bit32_band(-1 - L04_lo, L05_lo)), bit32_bxor(L04_lo, bit32_band(-1 - L05_lo, L01_lo)), bit32_bxor(L05_lo, bit32_band(-1 - L01_lo, L02_lo))
				L01_hi, L02_hi, L03_hi, L04_hi, L05_hi = bit32_bxor(L01_hi, bit32_band(-1 - L02_hi, L03_hi)), bit32_bxor(L02_hi, bit32_band(-1 - L03_hi, L04_hi)), bit32_bxor(L03_hi, bit32_band(-1 - L04_hi, L05_hi)), bit32_bxor(L04_hi, bit32_band(-1 - L05_hi, L01_hi)), bit32_bxor(L05_hi, bit32_band(-1 - L01_hi, L02_hi))
				L06_lo, L07_lo, L08_lo, L09_lo, L10_lo = bit32_bxor(L09_lo, bit32_band(-1 - L10_lo, L06_lo)), bit32_bxor(L10_lo, bit32_band(-1 - L06_lo, L07_lo)), bit32_bxor(L06_lo, bit32_band(-1 - L07_lo, L08_lo)), bit32_bxor(L07_lo, bit32_band(-1 - L08_lo, L09_lo)), bit32_bxor(L08_lo, bit32_band(-1 - L09_lo, L10_lo))
				L06_hi, L07_hi, L08_hi, L09_hi, L10_hi = bit32_bxor(L09_hi, bit32_band(-1 - L10_hi, L06_hi)), bit32_bxor(L10_hi, bit32_band(-1 - L06_hi, L07_hi)), bit32_bxor(L06_hi, bit32_band(-1 - L07_hi, L08_hi)), bit32_bxor(L07_hi, bit32_band(-1 - L08_hi, L09_hi)), bit32_bxor(L08_hi, bit32_band(-1 - L09_hi, L10_hi))
				L11_lo, L12_lo, L13_lo, L14_lo, L15_lo = bit32_bxor(L12_lo, bit32_band(-1 - L13_lo, L14_lo)), bit32_bxor(L13_lo, bit32_band(-1 - L14_lo, L15_lo)), bit32_bxor(L14_lo, bit32_band(-1 - L15_lo, L11_lo)), bit32_bxor(L15_lo, bit32_band(-1 - L11_lo, L12_lo)), bit32_bxor(L11_lo, bit32_band(-1 - L12_lo, L13_lo))
				L11_hi, L12_hi, L13_hi, L14_hi, L15_hi = bit32_bxor(L12_hi, bit32_band(-1 - L13_hi, L14_hi)), bit32_bxor(L13_hi, bit32_band(-1 - L14_hi, L15_hi)), bit32_bxor(L14_hi, bit32_band(-1 - L15_hi, L11_hi)), bit32_bxor(L15_hi, bit32_band(-1 - L11_hi, L12_hi)), bit32_bxor(L11_hi, bit32_band(-1 - L12_hi, L13_hi))
				L16_lo, L17_lo, L18_lo, L19_lo, L20_lo = bit32_bxor(L20_lo, bit32_band(-1 - L16_lo, L17_lo)), bit32_bxor(L16_lo, bit32_band(-1 - L17_lo, L18_lo)), bit32_bxor(L17_lo, bit32_band(-1 - L18_lo, L19_lo)), bit32_bxor(L18_lo, bit32_band(-1 - L19_lo, L20_lo)), bit32_bxor(L19_lo, bit32_band(-1 - L20_lo, L16_lo))
				L16_hi, L17_hi, L18_hi, L19_hi, L20_hi = bit32_bxor(L20_hi, bit32_band(-1 - L16_hi, L17_hi)), bit32_bxor(L16_hi, bit32_band(-1 - L17_hi, L18_hi)), bit32_bxor(L17_hi, bit32_band(-1 - L18_hi, L19_hi)), bit32_bxor(L18_hi, bit32_band(-1 - L19_hi, L20_hi)), bit32_bxor(L19_hi, bit32_band(-1 - L20_hi, L16_hi))
				L21_lo, L22_lo, L23_lo, L24_lo, L25_lo = bit32_bxor(L23_lo, bit32_band(-1 - L24_lo, L25_lo)), bit32_bxor(L24_lo, bit32_band(-1 - L25_lo, L21_lo)), bit32_bxor(L25_lo, bit32_band(-1 - L21_lo, L22_lo)), bit32_bxor(L21_lo, bit32_band(-1 - L22_lo, L23_lo)), bit32_bxor(L22_lo, bit32_band(-1 - L23_lo, L24_lo))
				L21_hi, L22_hi, L23_hi, L24_hi, L25_hi = bit32_bxor(L23_hi, bit32_band(-1 - L24_hi, L25_hi)), bit32_bxor(L24_hi, bit32_band(-1 - L25_hi, L21_hi)), bit32_bxor(L25_hi, bit32_band(-1 - L21_hi, L22_hi)), bit32_bxor(L21_hi, bit32_band(-1 - L22_hi, L23_hi)), bit32_bxor(L22_hi, bit32_band(-1 - L23_hi, L24_hi))
				L01_lo = bit32_bxor(L01_lo, RC_lo[round_idx])
				L01_hi = L01_hi + RC_hi[round_idx] -- RC_hi[] is either 0 or 0x80000000, so we could use fast addition instead of slow XOR
			end
			
			lanes_lo[1] = L01_lo
			lanes_hi[1] = L01_hi
			lanes_lo[2] = L02_lo
			lanes_hi[2] = L02_hi
			lanes_lo[3] = L03_lo
			lanes_hi[3] = L03_hi
			lanes_lo[4] = L04_lo
			lanes_hi[4] = L04_hi
			lanes_lo[5] = L05_lo
			lanes_hi[5] = L05_hi
			lanes_lo[6] = L06_lo
			lanes_hi[6] = L06_hi
			lanes_lo[7] = L07_lo
			lanes_hi[7] = L07_hi
			lanes_lo[8] = L08_lo
			lanes_hi[8] = L08_hi
			lanes_lo[9] = L09_lo
			lanes_hi[9] = L09_hi
			lanes_lo[10] = L10_lo
			lanes_hi[10] = L10_hi
			lanes_lo[11] = L11_lo
			lanes_hi[11] = L11_hi
			lanes_lo[12] = L12_lo
			lanes_hi[12] = L12_hi
			lanes_lo[13] = L13_lo
			lanes_hi[13] = L13_hi
			lanes_lo[14] = L14_lo
			lanes_hi[14] = L14_hi
			lanes_lo[15] = L15_lo
			lanes_hi[15] = L15_hi
			lanes_lo[16] = L16_lo
			lanes_hi[16] = L16_hi
			lanes_lo[17] = L17_lo
			lanes_hi[17] = L17_hi
			lanes_lo[18] = L18_lo
			lanes_hi[18] = L18_hi
			lanes_lo[19] = L19_lo
			lanes_hi[19] = L19_hi
			lanes_lo[20] = L20_lo
			lanes_hi[20] = L20_hi
			lanes_lo[21] = L21_lo
			lanes_hi[21] = L21_hi
			lanes_lo[22] = L22_lo
			lanes_hi[22] = L22_hi
			lanes_lo[23] = L23_lo
			lanes_hi[23] = L23_hi
			lanes_lo[24] = L24_lo
			lanes_hi[24] = L24_hi
			lanes_lo[25] = L25_lo
			lanes_hi[25] = L25_hi
		end
	end
	
	--------------------------------------------------------------------------------
	-- MAGIC NUMBERS CALCULATOR
	--------------------------------------------------------------------------------
	-- Q:
	--    Is 53-bit "double" math enough to calculate square roots and cube roots of primes with 64 correct bits after decimal point?
	-- A:
	--    Yes, 53-bit "double" arithmetic is enough.
	--    We could obtain first 40 bits by direct calculation of p^(1/3) and next 40 bits by one step of Newton's method.
	do
		local function mul(src1, src2, factor, result_length)
			-- src1, src2 - long integers (arrays of digits in base TWO_POW_24)
			-- factor - small integer
			-- returns long integer result (src1 * src2 * factor) and its floating point approximation
			local result, carry, value, weight = table.create(result_length), 0, 0, 1
			for j = 1, result_length do
				for k = math.max(1, j + 1 - #src2), math.min(j, #src1) do
					carry = carry + factor * src1[k] * src2[j + 1 - k] -- "int32" is not enough for multiplication result, that's why "factor" must be of type "double"
				end
				
				local digit = carry % TWO_POW_24
				result[j] = math.floor(digit)
				carry = (carry - digit) / TWO_POW_24
				value = value + digit * weight
				weight = weight * TWO_POW_24
			end
			
			return result, value
		end
		
		local idx, step, p, one, sqrt_hi, sqrt_lo = 0, {4, 1, 2, -2, 2}, 4, {1}, sha2_H_hi, sha2_H_lo
		repeat
			p = p + step[p % 6]
			local d = 1
			repeat
				d = d + step[d % 6]
				if d * d > p then
					-- next prime number is found
					local root = p ^ (1 / 3)
					local R = root * TWO_POW_40
					R = mul(table.create(1, math.floor(R)), one, 1, 2)
					local _, delta = mul(R, mul(R, R, 1, 4), -1, 4)
					local hi = R[2] % 65536 * 65536 + math.floor(R[1] / 256)
					local lo = R[1] % 256 * 16777216 + math.floor(delta * (TWO_POW_NEG_56 / 3) * root / p)
					
					if idx < 16 then
						root = math.sqrt(p)
						R = root * TWO_POW_40
						R = mul(table.create(1, math.floor(R)), one, 1, 2)
						_, delta = mul(R, R, -1, 2)
						local hi = R[2] % 65536 * 65536 + math.floor(R[1] / 256)
						local lo = R[1] % 256 * 16777216 + math.floor(delta * TWO_POW_NEG_17 / root)
						local idx = idx % 8 + 1
						sha2_H_ext256[224][idx] = lo
						sqrt_hi[idx], sqrt_lo[idx] = hi, lo + hi * hi_factor
						if idx > 7 then
							sqrt_hi, sqrt_lo = sha2_H_ext512_hi[384], sha2_H_ext512_lo[384]
						end
					end
					
					idx = idx + 1
					sha2_K_hi[idx], sha2_K_lo[idx] = hi, lo % K_lo_modulo + hi * hi_factor
					break
				end
			until p % d == 0
		until idx > 79
	end
	
	-- Calculating IVs for SHA512/224 and SHA512/256
	for width = 224, 256, 32 do
		local H_lo, H_hi = table.create(0), nil
		if XOR64A5 then
			for j = 1, 8 do
				H_lo[j] = XOR64A5(sha2_H_lo[j])
			end
		else
			H_hi = table.create(0)
			for j = 1, 8 do
				H_lo[j] = bit32_bxor(sha2_H_lo[j], 0xA5A5A5A5) % 4294967296
				H_hi[j] = bit32_bxor(sha2_H_hi[j], 0xA5A5A5A5) % 4294967296
			end
		end
		
		sha512_feed_128(H_lo, H_hi, "SHA-512/" .. tostring(width) .. "\128" .. string.rep("\0", 115) .. "\88", 0, 128)
		sha2_H_ext512_lo[width] = H_lo
		sha2_H_ext512_hi[width] = H_hi
	end
	
	-- Constants for MD5
	do
		for idx = 1, 64 do
			-- we can't use formula math.floor(abs(sin(idx))*TWO_POW_32) because its result may be beyond integer range on Lua built with 32-bit integers
			local hi, lo = math.modf(math.abs(math.sin(idx)) * TWO_POW_16)
			md5_K[idx] = hi * 65536 + math.floor(lo * TWO_POW_16)
		end
	end
	
	-- Constants for SHA3
	do
		local sh_reg = 29
		local function next_bit()
			local r = sh_reg % 2
			sh_reg = bit32_bxor((sh_reg - r) / 2, 142 * r)
			return r
		end
		
		for idx = 1, 24 do
			local lo, m = 0, nil
			for _ = 1, 6 do
				m = m and m * m * 2 or 1
				lo = lo + next_bit() * m
			end
			
			local hi = next_bit() * m
			sha3_RC_hi[idx], sha3_RC_lo[idx] = hi, lo + hi * hi_factor_keccak
		end
	end
	
	--------------------------------------------------------------------------------
	-- MAIN FUNCTIONS
	--------------------------------------------------------------------------------
	local function sha256ext(width, message)
		-- Create an instance (private objects for current calculation)
		local Array256 = sha2_H_ext256[width] -- # == 8
		local length, tail = 0, ""
		local H = table.create(8)
		H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8] = Array256[1], Array256[2], Array256[3], Array256[4], Array256[5], Array256[6], Array256[7], Array256[8]
		
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					local tailLength = #tail
					if tail ~= "" and tailLength + partLength >= 64 then
						offs = 64 - tailLength
						sha256_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
					
					local size = partLength - offs
					local size_tail = size % 64
					sha256_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(10) --{tail, "\128", string.rep("\0", (-9 - length) % 64 + 1)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64 + 1)
					
					tail = nil
					-- Assuming user data length is shorter than (TWO_POW_53)-9 bytes
					-- Anyway, it looks very unrealistic that someone would spend more than a year of calculations to process TWO_POW_53 bytes of data by using this Lua script :-)
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move decimal point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
					
					final_blocks = table.concat(final_blocks)
					sha256_feed_64(H, final_blocks, 0, #final_blocks)
					local max_reg = width / 32
					for j = 1, max_reg do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
					
					H = table.concat(H, "", 1, max_reg)
				end
				
				return H
			end
		end
		
		if message then
			-- Actually perform calculations and return the SHA256 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA256 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function sha512ext(width, message)
		
		-- Create an instance (private objects for current calculation)
		local length, tail, H_lo, H_hi = 0, "", table.pack(table.unpack(sha2_H_ext512_lo[width])), not HEX64 and table.pack(table.unpack(sha2_H_ext512_hi[width]))
		
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 128 then
						offs = 128 - #tail
						sha512_feed_128(H_lo, H_hi, tail .. string.sub(message_part, 1, offs), 0, 128)
						tail = ""
					end
					
					local size = partLength - offs
					local size_tail = size % 128
					sha512_feed_128(H_lo, H_hi, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(3) --{tail, "\128", string.rep("\0", (-17-length) % 128 + 9)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-17 - length) % 128 + 9)
					
					tail = nil
					-- Assuming user data length is shorter than (TWO_POW_53)-17 bytes
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move floating point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
					
					final_blocks = table.concat(final_blocks)
					sha512_feed_128(H_lo, H_hi, final_blocks, 0, #final_blocks)
					local max_reg = math.ceil(width / 64)
					
					if HEX64 then
						for j = 1, max_reg do
							H_lo[j] = HEX64(H_lo[j])
						end
					else
						for j = 1, max_reg do
							H_lo[j] = string.format("%08x", H_hi[j] % 4294967296) .. string.format("%08x", H_lo[j] % 4294967296)
						end
						
						H_hi = nil
					end
					
					H_lo = string.sub(table.concat(H_lo, "", 1, max_reg), 1, width / 4)
				end
				
				return H_lo
			end
		end
		
		if message then
			-- Actually perform calculations and return the SHA512 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA512 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function md5(message)
		
		-- Create an instance (private objects for current calculation)
		local H, length, tail = table.create(4), 0, ""
		H[1], H[2], H[3], H[4] = md5_sha1_H[1], md5_sha1_H[2], md5_sha1_H[3], md5_sha1_H[4]
		
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 64 then
						offs = 64 - #tail
						md5_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
					
					local size = partLength - offs
					local size_tail = size % 64
					md5_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(3) --{tail, "\128", string.rep("\0", (-9 - length) % 64)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64)
					tail = nil
					length = length * 8 -- convert "byte-counter" to "bit-counter"
					for j = 4, 11 do
						local low_byte = length % 256
						final_blocks[j] = string.char(low_byte)
						length = (length - low_byte) / 256
					end
					
					final_blocks = table.concat(final_blocks)
					md5_feed_64(H, final_blocks, 0, #final_blocks)
					for j = 1, 4 do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
					
					H = string.gsub(table.concat(H), "(..)(..)(..)(..)", "%4%3%2%1")
				end
				
				return H
			end
		end
		
		if message then
			-- Actually perform calculations and return the MD5 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get MD5 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function sha1(message)
		-- Create an instance (private objects for current calculation)
		local H, length, tail = table.pack(table.unpack(md5_sha1_H)), 0, ""
		
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					length = length + partLength
					local offs = 0
					if tail ~= "" and #tail + partLength >= 64 then
						offs = 64 - #tail
						sha1_feed_64(H, tail .. string.sub(message_part, 1, offs), 0, 64)
						tail = ""
					end
					
					local size = partLength - offs
					local size_tail = size % 64
					sha1_feed_64(H, message_part, offs, size - size_tail)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					local final_blocks = table.create(10) --{tail, "\128", string.rep("\0", (-9 - length) % 64 + 1)}
					final_blocks[1] = tail
					final_blocks[2] = "\128"
					final_blocks[3] = string.rep("\0", (-9 - length) % 64 + 1)
					tail = nil
					
					-- Assuming user data length is shorter than (TWO_POW_53)-9 bytes
					-- TWO_POW_53 bytes = TWO_POW_56 bits, so "bit-counter" fits in 7 bytes
					length = length * (8 / TWO56_POW_7) -- convert "byte-counter" to "bit-counter" and move decimal point to the left
					for j = 4, 10 do
						length = length % 1 * 256
						final_blocks[j] = string.char(math.floor(length))
					end
					
					final_blocks = table.concat(final_blocks)
					sha1_feed_64(H, final_blocks, 0, #final_blocks)
					for j = 1, 5 do
						H[j] = string.format("%08x", H[j] % 4294967296)
					end
					
					H = table.concat(H)
				end
				
				return H
			end
		end
		
		if message then
			-- Actually perform calculations and return the SHA-1 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA-1 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function keccak(block_size_in_bytes, digest_size_in_bytes, is_SHAKE, message)
		-- "block_size_in_bytes" is multiple of 8
		if type(digest_size_in_bytes) ~= "number" then
			-- arguments in SHAKE are swapped:
			--    NIST FIPS 202 defines SHAKE(message,num_bits)
			--    this module   defines SHAKE(num_bytes,message)
			-- it's easy to forget about this swap, hence the check
			error("Argument 'digest_size_in_bytes' must be a number", 2)
		end
		
		-- Create an instance (private objects for current calculation)
		local tail, lanes_lo, lanes_hi = "", table.create(25, 0), hi_factor_keccak == 0 and table.create(25, 0)
		local result
		
		--~     pad the input N using the pad function, yielding a padded bit string P with a length divisible by r (such that n = len(P)/r is integer),
		--~     break P into n consecutive r-bit pieces P0, ..., Pn-1 (last is zero-padded)
		--~     initialize the state S to a string of b 0 bits.
		--~     absorb the input into the state: For each block Pi,
		--~         extend Pi at the end by a string of c 0 bits, yielding one of length b,
		--~         XOR that with S and
		--~         apply the block permutation f to the result, yielding a new state S
		--~     initialize Z to be the empty string
		--~     while the length of Z is less than d:
		--~         append the first r bits of S to Z
		--~         if Z is still less than d bits long, apply f to S, yielding a new state S.
		--~     truncate Z to d bits
		local function partial(message_part)
			if message_part then
				local partLength = #message_part
				if tail then
					local offs = 0
					if tail ~= "" and #tail + partLength >= block_size_in_bytes then
						offs = block_size_in_bytes - #tail
						keccak_feed(lanes_lo, lanes_hi, tail .. string.sub(message_part, 1, offs), 0, block_size_in_bytes, block_size_in_bytes)
						tail = ""
					end
					
					local size = partLength - offs
					local size_tail = size % block_size_in_bytes
					keccak_feed(lanes_lo, lanes_hi, message_part, offs, size - size_tail, block_size_in_bytes)
					tail = tail .. string.sub(message_part, partLength + 1 - size_tail)
					return partial
				else
					error("Adding more chunks is not allowed after receiving the result", 2)
				end
			else
				if tail then
					-- append the following bits to the message: for usual SHA3: 011(0*)1, for SHAKE: 11111(0*)1
					local gap_start = is_SHAKE and 31 or 6
					tail = tail .. (#tail + 1 == block_size_in_bytes and string.char(gap_start + 128) or string.char(gap_start) .. string.rep("\0", (-2 - #tail) % block_size_in_bytes) .. "\128")
					keccak_feed(lanes_lo, lanes_hi, tail, 0, #tail, block_size_in_bytes)
					tail = nil
					
					local lanes_used = 0
					local total_lanes = math.floor(block_size_in_bytes / 8)
					local qwords = table.create(0)
					
					local function get_next_qwords_of_digest(qwords_qty)
						-- returns not more than 'qwords_qty' qwords ('qwords_qty' might be non-integer)
						-- doesn't go across keccak-buffer boundary
						-- block_size_in_bytes is a multiple of 8, so, keccak-buffer contains integer number of qwords
						if lanes_used >= total_lanes then
							keccak_feed(lanes_lo, lanes_hi, "\0\0\0\0\0\0\0\0", 0, 8, 8)
							lanes_used = 0
						end
						
						qwords_qty = math.floor(math.min(qwords_qty, total_lanes - lanes_used))
						if hi_factor_keccak ~= 0 then
							for j = 1, qwords_qty do
								qwords[j] = HEX64(lanes_lo[lanes_used + j - 1 + lanes_index_base])
							end
						else
							for j = 1, qwords_qty do
								qwords[j] = string.format("%08x", lanes_hi[lanes_used + j] % 4294967296) .. string.format("%08x", lanes_lo[lanes_used + j] % 4294967296)
							end
						end
						
						lanes_used = lanes_used + qwords_qty
						return string.gsub(table.concat(qwords, "", 1, qwords_qty), "(..)(..)(..)(..)(..)(..)(..)(..)", "%8%7%6%5%4%3%2%1"), qwords_qty * 8
					end
					
					local parts = table.create(0) -- digest parts
					local last_part, last_part_size = "", 0
					
					local function get_next_part_of_digest(bytes_needed)
						-- returns 'bytes_needed' bytes, for arbitrary integer 'bytes_needed'
						bytes_needed = bytes_needed or 1
						if bytes_needed <= last_part_size then
							last_part_size = last_part_size - bytes_needed
							local part_size_in_nibbles = bytes_needed * 2
							local result = string.sub(last_part, 1, part_size_in_nibbles)
							last_part = string.sub(last_part, part_size_in_nibbles + 1)
							return result
						end
						
						local parts_qty = 0
						if last_part_size > 0 then
							parts_qty = 1
							parts[parts_qty] = last_part
							bytes_needed = bytes_needed - last_part_size
						end
						
						-- repeats until the length is enough
						while bytes_needed >= 8 do
							local next_part, next_part_size = get_next_qwords_of_digest(bytes_needed / 8)
							parts_qty = parts_qty + 1
							parts[parts_qty] = next_part
							bytes_needed = bytes_needed - next_part_size
						end
						
						if bytes_needed > 0 then
							last_part, last_part_size = get_next_qwords_of_digest(1)
							parts_qty = parts_qty + 1
							parts[parts_qty] = get_next_part_of_digest(bytes_needed)
						else
							last_part, last_part_size = "", 0
						end
						
						return table.concat(parts, "", 1, parts_qty)
					end
					
					if digest_size_in_bytes < 0 then
						result = get_next_part_of_digest
					else
						result = get_next_part_of_digest(digest_size_in_bytes)
					end
					
				end
				
				return result
			end
		end
		
		if message then
			-- Actually perform calculations and return the SHA3 digest of a message
			return partial(message)()
		else
			-- Return function for chunk-by-chunk loading
			-- User should feed every chunk of input data as single argument to this function and finally get SHA3 digest by invoking this function without an argument
			return partial
		end
	end
	
	local function HexToBinFunction(hh)
		return string.char(tonumber(hh, 16))
	end
	
	local function hex2bin(hex_string)
		return (string.gsub(hex_string, "%x%x", HexToBinFunction))
	end
	
	local base64_symbols = {
		["+"] = 62, ["-"] = 62, [62] = "+";
		["/"] = 63, ["_"] = 63, [63] = "/";
		["="] = -1, ["."] = -1, [-1] = "=";
	}
	
	local symbol_index = 0
	for j, pair in {"AZ", "az", "09"} do
		for ascii = string.byte(pair), string.byte(pair, 2) do
			local ch = string.char(ascii)
			base64_symbols[ch] = symbol_index
			base64_symbols[symbol_index] = ch
			symbol_index = symbol_index + 1
		end
	end
	
	local function bin2base64(binary_string)
		local stringLength = #binary_string
		local result = table.create(math.ceil(stringLength / 3))
		local length = 0
		
		for pos = 1, #binary_string, 3 do
			local c1, c2, c3, c4 = string.byte(string.sub(binary_string, pos, pos + 2) .. '\0', 1, -1)
			length = length + 1
			result[length] =
				base64_symbols[math.floor(c1 / 4)] ..
				base64_symbols[c1 % 4 * 16 + math.floor(c2 / 16)] ..
				base64_symbols[c3 and c2 % 16 * 4 + math.floor(c3 / 64) or -1] ..
				base64_symbols[c4 and c3 % 64 or -1]
		end
		
		return table.concat(result)
	end
	
	local function base642bin(base64_string)
		local result, chars_qty = table.create(0), 3
		for pos, ch in string.gmatch(string.gsub(base64_string, "%s+", ""), "()(.)") do
			local code = base64_symbols[ch]
			if code < 0 then
				chars_qty = chars_qty - 1
				code = 0
			end
			
			local idx = pos % 4
			if idx > 0 then
				result[-idx] = code
			else
				local c1 = result[-1] * 4 + math.floor(result[-2] / 16)
				local c2 = (result[-2] % 16) * 16 + math.floor(result[-3] / 4)
				local c3 = (result[-3] % 4) * 64 + code
				result[#result + 1] = string.sub(string.char(c1, c2, c3), 1, chars_qty)
			end
		end
		
		return table.concat(result)
	end
	
	local block_size_for_HMAC -- this table will be initialized at the end of the module
	--local function pad_and_xor(str, result_length, byte_for_xor)
	--	return string.gsub(str, ".", function(c)
	--		return string.char(bit32_bxor(string.byte(c), byte_for_xor))
	--	end) .. string.rep(string.char(byte_for_xor), result_length - #str)
	--end
	
	-- For the sake of speed of converting hexes to strings, there's a map of the conversions here
	local BinaryStringMap = table.create(0)
	for Index = 0, 255 do
		BinaryStringMap[string.format("%02x", Index)] = string.char(Index)
	end
	
	-- Update 02.14.20 - added AsBinary for easy GameAnalytics replacement.
	local function hmac(hash_func, key, message, AsBinary)
		-- Create an instance (private objects for current calculation)
		local block_size = block_size_for_HMAC[hash_func]
		if not block_size then
			error("Unknown hash function", 2)
		end
		
		local KeyLength = #key
		if KeyLength > block_size then
			key = string.gsub(hash_func(key), "%x%x", HexToBinFunction)
			KeyLength = #key
		end
		
		local append = hash_func()(string.gsub(key, ".", function(c)
			return string.char(bit32_bxor(string.byte(c), 0x36))
		end) .. string.rep("6", block_size - KeyLength)) -- 6 = string.char(0x36)
		
		local result
		
		local function partial(message_part)
			if not message_part then
				result = result or hash_func(
					string.gsub(key, ".", function(c)
						return string.char(bit32_bxor(string.byte(c), 0x5c))
					end) .. string.rep("\\", block_size - KeyLength) -- \ = string.char(0x5c)
						.. (string.gsub(append(), "%x%x", HexToBinFunction))
				)
				
				return result
			elseif result then
				error("Adding more chunks is not allowed after receiving the result", 2)
			else
				append(message_part)
				return partial
			end
		end
		
		if message then
			-- Actually perform calculations and return the HMAC of a message
			local FinalMessage = partial(message)()
			return AsBinary and (string.gsub(FinalMessage, "%x%x", BinaryStringMap)) or FinalMessage
		else
			-- Return function for chunk-by-chunk loading of a message
			-- User should feed every chunk of the message as single argument to this function and finally get HMAC by invoking this function without an argument
			return partial
		end
	end
	
	local sha = {
		md5 = md5,
		sha1 = sha1,
		-- SHA2 hash functions:
		sha224 = function(message)
			return sha256ext(224, message)
		end;
		
		sha256 = function(message)
			return sha256ext(256, message)
		end;
		
		sha512_224 = function(message)
			return sha512ext(224, message)
		end;
		
		sha512_256 = function(message)
			return sha512ext(256, message)
		end;
		
		sha384 = function(message)
			return sha512ext(384, message)
		end;
		
		sha512 = function(message)
			return sha512ext(512, message)
		end;
		
		-- SHA3 hash functions:
		sha3_224 = function(message)
			return keccak((1600 - 2 * 224) / 8, 224 / 8, false, message)
		end;
		
		sha3_256 = function(message)
			return keccak((1600 - 2 * 256) / 8, 256 / 8, false, message)
		end;
		
		sha3_384 = function(message)
			return keccak((1600 - 2 * 384) / 8, 384 / 8, false, message)
		end;
		
		sha3_512 = function(message)
			return keccak((1600 - 2 * 512) / 8, 512 / 8, false, message)
		end;
		
		shake128 = function(message, digest_size_in_bytes)
			return keccak((1600 - 2 * 128) / 8, digest_size_in_bytes, true, message)
		end;
		
		shake256 = function(message, digest_size_in_bytes)
			return keccak((1600 - 2 * 256) / 8, digest_size_in_bytes, true, message)
		end;
		
		-- misc utilities:
		hmac = hmac; -- HMAC(hash_func, key, message) is applicable to any hash function from this module except SHAKE*
		hex_to_bin = hex2bin; -- converts hexadecimal representation to binary string
		base64_to_bin = base642bin; -- converts base64 representation to binary string
		bin_to_base64 = bin2base64; -- converts binary string to base64 representation
		-- base64_encode = Base64.Encode;
		-- base64_decode = Base64.Decode;
	}
	
	block_size_for_HMAC = {
		[sha.md5] = 64;
		[sha.sha1] = 64;
		[sha.sha224] = 64;
		[sha.sha256] = 64;
		[sha.sha512_224] = 128;
		[sha.sha512_256] = 128;
		[sha.sha384] = 128;
		[sha.sha512] = 128;
		[sha.sha3_224] = (1600 - 2 * 224) / 8;
		[sha.sha3_256] = (1600 - 2 * 256) / 8;
		[sha.sha3_384] = (1600 - 2 * 384) / 8;
		[sha.sha3_512] = (1600 - 2 * 512) / 8;
	}
	local hashlib = sha
	crypt.hash = function(data, algorithm)
		return hashlib[string.gsub(algorithm, "-", "_")](data)
	end
	crypt.hmac = function(data, key, asBinary)
		return hashlib.hmac(hashlib.sha512_256, data, key, asBinary)
	end
	crypt.generatebytes = function(size)
		local bytes = table.create(size)
		for i = 1, size do
			bytes[i] = string.char(math.random(0, 255))
		end
		
		return crypt.base64encode(table.concat(bytes))
	end
	crypt.generatekey = function()
		return crypt.generatebytes(32)
	end
--[[
ADVANCED ENCRYPTION STANDARD (AES)

Implementation of secure symmetric-key encryption specifically in Luau
Includes ECB, CBC, PCBC, CFB, OFB and CTR modes without padding.
Made by @RobloxGamerPro200007 (verify the original asset)

MORE INFORMATION: https://devforum.roblox.com/t/advanced-encryption-standard-in-luau/2009120
]]
	-- Taken from https://devforum.roblox.com/t/advanced-encryption-standard-in-luau/ WITH PATCHES
	
	-- SUBSTITUTION BOXES
	local s_box 	= { 99, 124, 119, 123, 242, 107, 111, 197,  48,   1, 103,  43, 254, 215, 171, 118, 202,
		130, 201, 125, 250,  89,  71, 240, 173, 212, 162, 175, 156, 164, 114, 192, 183, 253, 147,  38,  54,
		63, 247, 204,  52, 165, 229, 241, 113, 216,  49,  21,   4, 199,  35, 195,  24, 150,   5, 154,   7,
		18, 128, 226, 235,  39, 178, 117,   9, 131,  44,  26,  27, 110,  90, 160,  82,  59, 214, 179,  41,
		227,  47, 132,  83, 209,   0, 237,  32, 252, 177,  91, 106, 203, 190,  57,  74,  76,  88, 207, 208,
		239, 170, 251,  67,  77,  51, 133,  69, 249,   2, 127,  80,  60, 159, 168,  81, 163,  64, 143, 146,
		157,  56, 245, 188, 182, 218,  33,  16, 255, 243, 210, 205,  12,  19, 236,  95, 151,  68,  23, 196,
		167, 126,  61, 100,  93,  25, 115,  96, 129,  79, 220,  34,  42, 144, 136,  70, 238, 184,  20, 222,
		94,  11, 219, 224,  50,  58,  10,  73,   6,  36,  92, 194, 211, 172,  98, 145, 149, 228, 121, 231,
		200,  55, 109, 141, 213,  78, 169, 108,  86, 244, 234, 101, 122, 174,   8, 186, 120,  37,  46,  28,
		166, 180, 198, 232, 221, 116,  31,  75, 189, 139, 138, 112,  62, 181, 102,  72,   3, 246,  14,  97,
		53,  87, 185, 134, 193,  29, 158, 225, 248, 152,  17, 105, 217, 142, 148, 155,  30, 135, 233, 206,
		85,  40, 223, 140, 161, 137,  13, 191, 230,  66, 104,  65, 153,  45,  15, 176,  84, 187,  22}
	local inv_s_box	= { 82,   9, 106, 213,  48,  54, 165,  56, 191,  64, 163, 158, 129, 243, 215, 251, 124,
		227,  57, 130, 155,  47, 255, 135,  52, 142,  67,  68, 196, 222, 233, 203,  84, 123, 148,  50, 166,
		194,  35,  61, 238,  76, 149,  11,  66, 250, 195,  78,   8,  46, 161, 102,  40, 217,  36, 178, 118,
		91, 162,  73, 109, 139, 209,  37, 114, 248, 246, 100, 134, 104, 152,  22, 212, 164,  92, 204,  93,
		101, 182, 146, 108, 112,  72,  80, 253, 237, 185, 218,  94,  21,  70,  87, 167, 141, 157, 132, 144,
		216, 171,   0, 140, 188, 211,  10, 247, 228,  88,   5, 184, 179,  69,   6, 208,  44,  30, 143, 202,
		63,  15,   2, 193, 175, 189,   3,   1,  19, 138, 107,  58, 145,  17,  65,  79, 103, 220, 234, 151,
		242, 207, 206, 240, 180, 230, 115, 150, 172, 116,  34, 231, 173,  53, 133, 226, 249,  55, 232,  28,
		117, 223, 110,  71, 241,  26, 113,  29,  41, 197, 137, 111, 183,  98,  14, 170,  24, 190,  27, 252,
		86,  62,  75, 198, 210, 121,  32, 154, 219, 192, 254, 120, 205,  90, 244,  31, 221, 168,  51, 136,
		7, 199,  49, 177,  18,  16,  89,  39, 128, 236,  95,  96,  81, 127, 169,  25, 181,  74,  13,  45,
		229, 122, 159, 147, 201, 156, 239, 160, 224,  59,  77, 174,  42, 245, 176, 200, 235, 187,  60, 131,
		83, 153,  97,  23,  43,   4, 126, 186, 119, 214,  38, 225, 105,  20,  99,  85,  33,  12, 125}
	
	-- ROUND CONSTANTS ARRAY
	local rcon = {  0,   1,   2,   4,   8,  16,  32,  64, 128,  27,  54, 108, 216, 171,  77, 154,  47,  94,
		188,  99, 198, 151,  53, 106, 212, 179, 125, 250, 239, 197, 145,  57}
	-- MULTIPLICATION OF BINARY POLYNOMIAL
	local function xtime(x)
		local i = bit32.lshift(x, 1)
		return if bit32.band(x, 128) == 0 then i else bit32.bxor(i, 27) % 256
	end
	
	-- TRANSFORMATION FUNCTIONS
	local function subBytes		(s, inv) 		-- Processes State using the S-box
		inv = if inv then inv_s_box else s_box
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = inv[s[i][j] + 1]
			end
		end
	end
	local function shiftRows		(s, inv) 	-- Processes State by circularly shifting rows
		s[1][3], s[2][3], s[3][3], s[4][3] = s[3][3], s[4][3], s[1][3], s[2][3]
		if inv then
			s[1][2], s[2][2], s[3][2], s[4][2] = s[4][2], s[1][2], s[2][2], s[3][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[2][4], s[3][4], s[4][4], s[1][4]
		else
			s[1][2], s[2][2], s[3][2], s[4][2] = s[2][2], s[3][2], s[4][2], s[1][2]
			s[1][4], s[2][4], s[3][4], s[4][4] = s[4][4], s[1][4], s[2][4], s[3][4]
		end
	end
	local function addRoundKey	(s, k) 			-- Processes Cipher by adding a round key to the State
		for i = 1, 4 do
			for j = 1, 4 do
				s[i][j] = bit32.bxor(s[i][j], k[i][j])
			end
		end
	end
	local function mixColumns	(s, inv) 		-- Processes Cipher by taking and mixing State columns
		local t, u
		if inv then
			for i = 1, 4 do
				t = xtime(xtime(bit32.bxor(s[i][1], s[i][3])))
				u = xtime(xtime(bit32.bxor(s[i][2], s[i][4])))
				s[i][1], s[i][2] = bit32.bxor(s[i][1], t), bit32.bxor(s[i][2], u)
				s[i][3], s[i][4] = bit32.bxor(s[i][3], t), bit32.bxor(s[i][4], u)
			end
		end
		
		local i
		for j = 1, 4 do
			i = s[j]
			t, u = bit32.bxor		(i[1], i[2], i[3], i[4]), i[1]
			for k = 1, 4 do
				i[k] = bit32.bxor	(i[k], t, xtime(bit32.bxor(i[k], i[k + 1] or u)))
			end
		end
	end
	
	-- BYTE ARRAY UTILITIES
	local function bytesToMatrix	(t, c, inv) -- Converts a byte array to a 4x4 matrix
		if inv then
			table.move		(c[1], 1, 4, 1, t)
			table.move		(c[2], 1, 4, 5, t)
			table.move		(c[3], 1, 4, 9, t)
			table.move		(c[4], 1, 4, 13, t)
		else
			for i = 1, #c / 4 do
				table.clear	(t[i])
				table.move	(c, i * 4 - 3, i * 4, 1, t[i])
			end
		end
		
		return t
	end
	local function xorBytes		(t, a, b) 		-- Returns bitwise XOR of all their bytes
		table.clear		(t)
		
		for i = 1, math.min(#a, #b) do
			table.insert(t, bit32.bxor(a[i], b[i]))
		end
		return t
	end
	local function incBytes		(a, inv)		-- Increment byte array by one
		local o = true
		for i = if inv then 1 else #a, if inv then #a else 1, if inv then 1 else - 1 do
			if a[i] == 255 then
				a[i] = 0
			else
				a[i] += 1
				o = false
				break
			end
		end
		
		return o, a
	end
	
	-- MAIN ALGORITHM
	local function expandKey	(key) 				-- Key expansion
		local kc = bytesToMatrix(if #key == 16 then {table.create(0), table.create(0), table.create(0), table.create(0)} elseif #key == 24 then {table.create(0), table.create(0), table.create(0), table.create(0)
			, table.create(0), table.create(0)} else {table.create(0), table.create(0), table.create(0), table.create(0), table.create(0), table.create(0), table.create(0), table.create(0)}, key)
		local is = #key / 4
		local i, t, w = 2, table.create(0), nil
		
		while #kc < (#key / 4 + 7) * 4 do
			w = table.clone	(kc[#kc])
			if #kc % is == 0 then
				table.insert(w, table.remove(w, 1))
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
				w[1]	 = bit32.bxor(w[1], rcon[i])
				i 	+= 1
			elseif #key == 32 and #kc % is == 4 then
				for j = 1, 4 do
					w[j] = s_box[w[j] + 1]
				end
			end
			
			table.clear	(t)
			xorBytes	(w, table.move(w, 1, 4, 1, t), kc[#kc - is + 1])
			table.insert(kc, w)
		end
		
		table.clear		(t)
		for i = 1, #kc / 4 do
			table.insert(t, table.create(0))
			table.move	(kc, i * 4 - 3, i * 4, 1, t[#t])
		end
		return t
	end
	local function encrypt	(key, km, pt, ps, r) 	-- Block cipher encryption
		bytesToMatrix	(ps, pt)
		addRoundKey		(ps, km[1])
		
		for i = 2, #key / 4 + 6 do
			subBytes	(ps)
			shiftRows	(ps)
			mixColumns	(ps)
			addRoundKey	(ps, km[i])
		end
		subBytes		(ps)
		shiftRows		(ps)
		addRoundKey		(ps, km[#km])
		
		return bytesToMatrix(r, ps, true)
	end
	local function decrypt	(key, km, ct, cs, r) 	-- Block cipher decryption
		bytesToMatrix	(cs, ct)
		
		addRoundKey		(cs, km[#km])
		shiftRows		(cs, true)
		subBytes		(cs, true)
		for i = #key / 4 + 6, 2, - 1 do
			addRoundKey	(cs, km[i])
			mixColumns	(cs, true)
			shiftRows	(cs, true)
			subBytes	(cs, true)
		end
		
		addRoundKey		(cs, km[1])
		return bytesToMatrix(r, cs, true)
	end
	
	-- INITIALIZATION FUNCTIONS
	local function convertType	(a) 					-- Converts data to bytes if possible
		if type(a) == "string" then
			local r = table.create(0)
			
			for i = 1, string.len(a), 7997 do
				table.move({string.byte(a, i, i + 7996)}, 1, 7997, i, r)
			end
			return r
		elseif type(a) == "table" then
			for _, i in a do
				assert(type(i) == "number" and math.floor(i) == i and 0 <= i and i < 256,
					"Unable to cast value to bytes")
			end
			return a
		else
			error("Unable to cast value to bytes")
		end
	end
	local function deepCopy(Original)
		local copy = table.create(0)
		for key, val in Original do
			local Type = typeof(val)
			if Type == "table" then
				val = deepCopy(val)
			end
			copy[key] = val
		end
		return copy
	end
	local function init			(key, txt, m, iv, s) 	-- Initializes functions if possible
		key = convertType(key)
		assert(#key == 16 or #key == 24 or #key == 32, "Key must be either 16, 24 or 32 bytes long")
		txt = convertType(txt)
		assert(#txt % (s or 16) == 0, "Input must be a multiple of " .. (if s then "segment size " .. s
			else "16") .. " bytes in length")
		if m then
			if type(iv) == "table" then
				iv = table.clone(iv)
				local l, e 		= iv.Length, iv.LittleEndian
				assert(type(l) == "number" and 0 < l and l <= 16,
					"Counter value length must be between 1 and 16 bytes")
				iv.Prefix 		= convertType(iv.Prefix or table.create(0))
				iv.Suffix 		= convertType(iv.Suffix or table.create(0))
				assert(#iv.Prefix + #iv.Suffix + l == 16, "Counter must be 16 bytes long")
				iv.InitValue 	= if iv.InitValue == nil then {1} else table.clone(convertType(iv.InitValue
				))
				assert(#iv.InitValue <= l, "Initial value length must be of the counter value")
				iv.InitOverflow = if iv.InitOverflow == nil then table.create(l, 0) else table.clone(
				convertType(iv.InitOverflow))
				assert(#iv.InitOverflow <= l,
					"Initial overflow value length must be of the counter value")
				for _ = 1, l - #iv.InitValue do
					table.insert(iv.InitValue, 1 + if e then #iv.InitValue else 0, 0)
				end
				for _ = 1, l - #iv.InitOverflow do
					table.insert(iv.InitOverflow, 1 + if e then #iv.InitOverflow else 0, 0)
				end
			elseif type(iv) ~= "function" then
				local i, t = if iv then convertType(iv) else table.create(16, 0), table.create(0)
				assert(#i == 16, "Counter must be 16 bytes long")
				iv = {Length = 16, Prefix = t, Suffix = t, InitValue = i,
					InitOverflow = table.create(16, 0)}
			end
		elseif m == false then
			iv 	= if iv == nil then  table.create(16, 0) else convertType(iv)
			assert(#iv == 16, "Initialization vector must be 16 bytes long")
		end
		if s then
			s = math.floor(tonumber(s) or 1)
			assert(type(s) == "number" and 0 < s and s <= 16, "Segment size must be between 1 and 16 bytes"
			)
		end
		
		return key, txt, expandKey(key), iv, s
	end
	type bytes = {number} -- Type instance of a valid bytes object
	
	-- CIPHER MODES OF OPERATION
	local aes = {
		-- Electronic codebook (ECB)
		encrypt_ECB = function(key : bytes, plainText : bytes, initVector : bytes?) 									: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			
			local iv = deepCopy(initVector)
			local b, k, s, t = table.create(0), table.create(0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, k, s, t), 1, 16, i, b)
			end
			
			return b, iv
		end,
		decrypt_ECB = function(key : bytes, cipherText : bytes, initVector : bytes?) 								: bytes
			local km
			key, cipherText, km = init(key, cipherText, false, initVector)
			
			local b, k, s, t = table.create(0), table.create(0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(decrypt(key, km, k, s, t), 1, 16, i, b)
			end
			
			return b
		end,
		-- Cipher block chaining (CBC)
		encrypt_CBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, p, s, t = table.create(0), table.create(0), initVector, {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(t, k, p), s, p), 1, 16, i, b)
			end
			
			return b, iv
		end,
		decrypt_CBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)
			
			local b, k, p, s, t = table.create(0), table.create(0), initVector, {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(k, decrypt(key, km, k, s, t), p), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, p)
			end
			
			return b
		end,
		-- Propagating cipher block chaining (PCBC)
		encrypt_PCBC = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, c, p, s, t = table.create(0), table.create(0), initVector, table.create(16, 0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, xorBytes(k, xorBytes(t, c, k), p), s, c), 1, 16, i, b)
				table.move(plainText, i, i + 15, 1, p)
			end
			
			return b, iv
		end,
		decrypt_PCBC = function(key : bytes, cipherText : bytes, initVector : bytes?) 			: bytes
			local km
			key, cipherText, km, initVector = init(key, cipherText, false, initVector)
			
			local b, k, c, p, s, t = table.create(0), table.create(0), initVector, table.create(16, 0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #cipherText, 16 do
				table.move(cipherText, i, i + 15, 1, k)
				table.move(xorBytes(p, decrypt(key, km, k, s, t), xorBytes(k, c, p)), 1, 16, i, b)
				table.move(cipherText, i, i + 15, 1, c)
			end
			
			return b
		end,
		-- Cipher feedback (CFB)
		encrypt_CFB = function(key : bytes, plainText : bytes, initVector : bytes?, segmentSize : number?)
			: bytes
			local km
			key, plainText, km, initVector, segmentSize = init(key, plainText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)
			local iv = deepCopy(initVector)
			local b, k, p, q, s, t = table.create(0), table.create(0), initVector, table.create(0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #plainText, segmentSize do
				table.move(plainText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(q, 1, p[j])
				end
				table.move(q, 1, 16, 1, p)
			end
			
			return b, iv
		end,
		decrypt_CFB = function(key : bytes, cipherText : bytes, initVector : bytes, segmentSize : number?)
			: bytes
			local km
			key, cipherText, km, initVector, segmentSize = init(key, cipherText, false, initVector,
				if segmentSize == nil then 1 else segmentSize)
			
			local b, k, p, q, s, t = table.create(0), table.create(0), initVector, table.create(0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #cipherText, segmentSize do
				table.move(cipherText, i, i + segmentSize - 1, 1, k)
				table.move(xorBytes(q, encrypt(key, km, p, s, t), k), 1, segmentSize, i, b)
				for j = 16, segmentSize + 1, - 1 do
					table.insert(k, 1, p[j])
				end
				table.move(k, 1, 16, 1, p)
			end
			
			return b
		end,
		-- Output feedback (OFB)
		encrypt_OFB = function(key : bytes, plainText : bytes, initVector : bytes?) 			: bytes
			local km
			key, plainText, km, initVector = init(key, plainText, false, initVector)
			local iv = deepCopy(initVector)
			local b, k, p, s, t = table.create(0), table.create(0), initVector, {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0)
			for i = 1, #plainText, 16 do
				table.move(plainText, i, i + 15, 1, k)
				table.move(encrypt(key, km, p, s, t), 1, 16, 1, p)
				table.move(xorBytes(t, k, p), 1, 16, i, b)
			end
			
			return b, iv
		end,
		-- Counter (CTR)
		encrypt_CTR = function(key : bytes, plainText : bytes, counter : ((bytes) -> bytes) | bytes | { [
			string]: any }?) : bytes
			local km
			key, plainText, km, counter = init(key, plainText, true, counter)
			local iv = deepCopy(counter)
			local b, k, c, s, t, r, n = table.create(0), table.create(0), table.create(0), {table.create(0), table.create(0), table.create(0), table.create(0)}, table.create(0), type(counter) == "table", nil
			for i = 1, #plainText, 16 do
				if r then
					if i > 1 and incBytes(counter.InitValue, counter.LittleEndian) then
						table.move(counter.InitOverflow, 1, 16, 1, counter.InitValue)
					end
					table.clear	(c)
					table.move	(counter.Prefix, 1, #counter.Prefix, 1, c)
					table.move	(counter.InitValue, 1, counter.Length, #c + 1, c)
					table.move	(counter.Suffix, 1, #counter.Suffix, #c + 1, c)
				else
					n = convertType(counter(c, (i + 15) / 16))
					assert		(#n == 16, "Counter must be 16 bytes long")
					table.move	(n, 1, 16, 1, c)
				end
				table.move(plainText, i, i + 15, 1, k)
				table.move(xorBytes(c, encrypt(key, km, c, s, t), k), 1, 16, i, b)
			end
			
			return b, iv
		end
	} -- Returns the library
	local modes = table.create(0)
	
	for _, ciphermode in { "ECB", "CBC", "PCBC", "CFB", "OFB", "CTR" } do -- Missing: GCM (important)
		local encrypt = aes["encrypt_" .. ciphermode]
		local decrypt = aes["decrypt_" .. ciphermode]
		
		modes[string.lower(ciphermode)] = { encrypt = encrypt, decrypt = decrypt or encrypt }
	end
	
	-- Function to add PKCS#7 padding to a string
	local function PKCS7_unpad(inputString)
		local blockSize = 16
		local length = (#inputString % blockSize)
		
		-- Only add padding if needed
		if 0 == length then
			return inputString
		end
		
		local paddingSize = blockSize - length
		
		local padding = string.rep(string.char(paddingSize), paddingSize)
		return inputString .. padding
	end
	
	-- Function to remove PKCS#7 padding from a padded string
	local function PKCS7_pad(paddedString)
		local lastByte = string.byte(paddedString, -1)
		
		-- Check if padding is present
		if lastByte <= 16 and 0 < lastByte then
			return string.sub(paddedString, 1, -lastByte - 1)
		else
			return paddedString
		end
	end
	
	local function table_type(t)
		local ct = 1
		for i in t do
			if i ~= ct then
				return "dictionary"
			end
			ct += 1
		end
		return "array"
	end
	
	local function bytes_to_char(t)
		return string.char(unpack(t))
	end
	
	local function crypt_generalized(action: string?)
		return function(data: string, key: string, iv: string?, mode: string?): (string, string)
			if mode and type(mode) == "string" then
				mode = string.lower(mode)
				mode = modes[mode]
			else
				mode = modes.cbc -- Default
			end
			
			if iv then
				iv = crypt.base64decode(iv)
				pcall(function()
					iv = game:GetService("HttpService"):JSONDecode(iv)
				end)
				if 16 < #iv then
					iv = string.sub(iv, 1, 16)
				elseif #iv < 16 then
					iv = PKCS7_unpad(iv)
				end
			end
			
			pcall(function()
				key = crypt.base64decode(key)
			end)
			
			-- TODO This code below is even worse
			local crypt_f = mode[action]
			data, iv = crypt_f(key, if action == "encrypt" then PKCS7_unpad(data) else crypt.base64decode(data), iv)
			
			data = bytes_to_char(data)
			
			if action == "decrypt" then
				data = PKCS7_pad(data)
			else
				if table_type(iv) == "array" then
					iv = bytes_to_char(iv)
				else
					iv = game:GetService("HttpService"):JSONEncode(iv)
				end
				iv = crypt.base64encode(iv)
				data = crypt.base64encode(data)
			end
			
			return data, iv
		end
	end
	
	crypt.encrypt = crypt_generalized("encrypt")
	crypt.decrypt = crypt_generalized("decrypt")
	local everything = {topg}
	topg.DescendantAdded:Connect(function(desc)
		table.insert(everything, desc)
	end)
	for i, v in pairs(topg:GetDescendants()) do
		table.insert(everything, v)
	end
	topg.DescendantAdded:Connect(function(des: Instance)
		cachedi[des] = des
		des.Destroying:Connect(function()
			cachedi[des] = nil
		end)
	end)
	for i, v in pairs(game:GetDescendants()) do
		cachedi[v] = v
	end
	local cache = table.create(0)
	genv.cache = cache
	cache.iscached = function(thing)
		if type(thing) == "userdata" and cachedi[unwrap(thing)] ~= "no" then
			return true
		end
		return cachedi[unwrap(thing)] == unwrap(thing)
	end
	cache.invalidate = function(thing)
		thing = unwrap(thing)
		cachedi[thing] = "no"
		thing.Parent = nil
	end
	cache.replace = function(inst, inst2)
		inst = unwrap(inst)
		inst2 = unwrap(inst2)
		cachedi[inst] = inst2
		inst2.Parent = inst.Parent
		inst2.Name = inst.Name
		inst.Parent = nil
	end
	genv.cleardrawcache = function() -- idk there is no cache to clear
		return true
	end
	
	genv.setreadonly = function(t, lock)
		if table.isfrozen(t) then
			if lock then
				return
			end
		else
			if not lock then
				return
			end
			table.freeze(t)
		end
	end
	
	genv.getfflag = function(flag)
		assert(type(flag) == "string", "arg #1 must be type string")
		assert(flag ~= "", `arg #1 cannot be empty`)
		
		for container, methods in
			{ [game] = { "GetFastFlag", "GetFastString", "GetFastInt" }, [settings()] = { "GetFFlag", "GetFVariable" } }
		do
			for _, method in methods do
				local s, r = pcall(container[method], container, flag)
				if s then
					return r
				end
			end
		end
	end
	local RunService = game:GetService("RunService")
	local Capped, FractionOfASecond
	local Heartbeat = RunService.Heartbeat
	genv.setfpscap = function(fps_cap)
		if fps_cap == 0 or fps_cap == nil or 1e4 <= fps_cap then -- ~7k fps is the highest people have gotten; --?maybe compare to getfpsmax instead? (but we have to ensure getfpsmax is accurate first)
			if Capped then
				task.cancel(Capped)
				Capped = nil
				FractionOfASecond = nil
			end
			return
		end
		
		FractionOfASecond = 1 / fps_cap
		if Capped then
			return
		end
		local function Capper()
			-- * Modified version of https://github.com/MaximumADHD/Super-Nostalgia-Zone/blob/540221bc945a8fc3a45baf51b40e02272a21329d/Client/FpsCap.client.lua#
			local t0 = os.clock()
			Heartbeat:Wait()
			-- repeat until t0 + t1 < tick()
			-- local count = 0
			while os.clock() <= t0 + FractionOfASecond do -- * not using repeat to avoid unreasonable extra iterations
				-- count+=1
			end
			-- task.spawn(print,count)
		end
		Capper() -- Yield until it kicks in basically
		Capped = task.spawn(function()
			-- capping = true -- * this works too
			while true do
				Capper()
			end
		end)
	end
	
	genv.lrm_load_script = function(script_id)
		local code = [[
                    ce_like_loadstring_fn = loadstring;
                    loadstring = nil;

                    ]]..genv.httpget("https://api.luarmor.net/files/v3/l/" .. script_id .. ".lua")
		return genv.loadstring(code)({ Origin = "humorouscartel" })
	end
	local GENV = getgenv()
	local function Define(...)
		local aliases = table.pack(...)
		local value = table.remove(aliases, aliases.n)
		for _,key in ipairs(aliases) do
			GENV[key] = value
		end
		return value
	end
	
	
	local function DefineCClosure(...)
		local aliases = table.pack(...)
		local value = genv.newcclosure(table.remove(aliases, aliases.n))
		for _,key in ipairs(aliases) do
			GENV[key] = value
		end
		return value
	end
	
	-- Auto wrap hook in newcclosure:
	genv.hookfunction = function(func, hook)
		if (genv.iscclosure(func) and genv.islclosure(hook)) then
			return genv.hookfunction(func, genv.newcclosure(hook))
		else
		    return genv.hookfunction(func, hook)
		end
    end
	
	genv.setscriptable = function(instance, property_name, scriptable)
		assert(typeof(instance) == "Instance", "arg #1 must be type Instance")
		assert(type(property_name) == "string", "arg #2 must be type string")
		assert(type(scriptable) == "boolean", "arg #3 must be type boolean")
		if genv.isscriptable(instance, property_name) then
			return false
		end
		return bridge:send("set_scriptable", {instance = instance, property_name = property_name, scriptable = scriptable})
	end
	
	genv.isscriptable = function(inst, prop)
		local bool, _ = pcall(function()
			inst[prop] = inst[prop]
		end)
		return bool
	end
	genv.getnilinstances = function()
		local nili = table.create(0)
		for i, v in pairs(everything) do
			if v.Parent ~= nil then continue end
			table.insert(nili, v)
		end
		return nili
	end
	genv.fireclickdetector = function(part, nn, nnn)
		pcall(function()
			local cd = part:FindFirstChild("ClickDetector") or part
			
			local oldParent = cd.Parent
			local p = Instance.new("Part")
			p.Transparency = 1
			p.Size = Vector3.new(30,30,30)
			p.Anchored = true
			p.CanCollide = false
			p.Parent = workspace
			cd.Parent = p
			cd.MaxActivationDistance = math.huge
			
			local conn
			
			conn = game["Run Service"].Heartbeat:Connect(function()
				p.CFrame = workspace.Camera.CFrame *CFrame.new(0,0,-20) * CFrame.new(workspace.Camera.CFrame.LookVector.X,workspace.Camera.CFrame.LookVector.Y,workspace.Camera.CFrame.LookVector.Z)
				game:GetService("VirtualUser"):ClickButton1(Vector2.new(20, 20), workspace:FindFirstChildOfClass("Camera").CFrame)
			end)
			
			cd.MouseClick:Once(function() 
				conn:Disconnect() 
				cd.Parent = oldParent
				p:Destroy() 
			end)
		end)
	end
	genv.getgc = genv.getnilinstances
	genv.getrenderproperty = function(a,b)
		return a[b]
	end
	genv.setrenderproperty = function(a,b,c)
		a[b] = c
	end
	genv.Drawing = DrawingLib
	genv.Drawing.Fonts = DrawingLib.Fonts
	DrawingLib.Fonts.UI = 0
	genv.crypt = crypt
	genv.cache = cache
	genv.getgenv = function(...)
		return env
	end
	genv.getrenv = function(...)
		return renv
	end
	genv.iswrapped = function(thing)
		return unwrap(thing) ~= thing
	end
	local function execute(code, chunkname)
		local toret = load(code:gsub("(%a+)%s*([%+%-%*/])=%s*", "%1 = %1 %2 "), env)
		local cl = toret
		if type(toret) ~= "function" then
			toret = function(...)
				error(cl,2)
			end
		end
		return toret
	end
	genv.loadstring = function(code, chunkname)
		return execute(code)
	end
	genv.makegenv = regenv
	local pps = 20
	genv.setpps = function(numb)
		assert(type(numb) == "number", "First input must be a number!")
		pps = numb
	end
	env = regenv()
	renv._G = table.create(0)
	renv.shared = table.create(0)
	setfenv(0, env)
	setfenv(1, env)
	task.spawn(function()
		while task.wait() do
			local ret = bridge:send("POLL")
			for i, code in pairs(ret) do
				task.spawn(function()
					local worked, err = pcall(function()
						execute(code)()
					end)
					if not worked then
						task.spawn(function()
							error(err,2)
						end)
					end
				end)
			end
		end
	end)
	--lets auto execute the stuff
	bridge:send("AE")
end)
local CorePackages = game:GetService("CorePackages")
local Lumberyak = require(CorePackages.Lumberyak)

local logger = Lumberyak.Logger.new(nil, "CoreLogger")

local fastLevel = game:DefineFastString("DebugLuaLogLevel", "")
local level = logger.Levels.fromString(fastLevel)
local pattern = game:DefineFastString("DebugLuaLogPattern", "")

logger:setContext({prefix = "[{loggerName}] - "})
logger:addSink({
	maxLevel = level,
	log = function(_, message, context)
		if string.match(message, pattern) then
			print(message)
		end
	end,
})

return logger
