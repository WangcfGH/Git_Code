local Queue = class('Queue')

function Queue:ctor()
    self:init()
end

function Queue:init()
    self:reset()
end

function Queue:pushBack(...)
    self._queue[self._first + self._count] = {...}
    self._count = self._count + 1
end

function Queue:pop()
    if self._count <= 0 then
        print('Queue:pop queue is nil')
        self:reset()
        return nil
    end

    local data = self._queue[self._first]

    -- clean
    self._queue[self._first] = nil
    self._first = self._first + 1
    self._count = self._count - 1

    return data
end

function Queue:reset()
    self._queue = {}
    self._first = 1
    self._count = 0
end

function Queue:size()
    return self._count
end


return Queue