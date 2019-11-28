other = { foo = 3 }
t = setmetatable({foo = 5}, { __index = other })
print(t.foo)
